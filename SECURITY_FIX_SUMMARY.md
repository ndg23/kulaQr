# 🔐 Correction Sécurité - Propriétaires Bloqués et Commandes

## 📋 Résumé Exécutif

**Problème identifié:** Les établissements continuaient à recevoir des commandes même lorsque leur propriétaire était bloqué (`is_active = false`).

**Impact:** Risque de sécurité majeur - clients pouvaient passer commande auprès d'établissements suspendus.

**Solution:** Migration SQL complète + amélioration UI pour bloquer automatiquement les commandes.

---

## ✅ Fichiers Créés/Modifiés

### 1. Migration SQL
**Fichier:** `/bdd/migration_secure_order_creation.sql`

**Contenu:**
- ✅ Nouvelle politique RLS sécurisée
- ✅ Fonction `can_receive_orders(UUID)` 
- ✅ Vue `active_establishments_for_orders`
- ✅ Trigger d'annulation automatique des commandes
- ✅ Fonction de test de sécurité
- ✅ Index de performance

### 2. Documentation Détaillée
**Fichier:** `/SECURITY_BLOCKED_OWNERS.md`

**Contenu:**
- 📖 Explication complète du problème
- 📊 Scénarios d'utilisation
- 🧪 Tests de sécurité
- 📝 Guide d'utilisation
- ⚠️ Avertissements et bonnes pratiques

### 3. Amélioration UI Admin
**Fichier:** `/pages/admin/orders/[id].vue`

**Modifications:**
- ✅ Affichage du statut du propriétaire
- ⚠️ Alerte visuelle si propriétaire bloqué
- ✅ Badge coloré (Actif/Bloqué)
- 📧 Information email du propriétaire

---

## 🎯 Comportement AVANT vs APRÈS

### ❌ AVANT (Problématique)

```sql
CREATE POLICY "Allow anonymous order creation" ON orders
    FOR INSERT TO anon WITH CHECK (true);
```

**Résultat:**
- ⚠️ Propriétaire bloqué → Commandes acceptées ❌
- ⚠️ Établissement inactif → Commandes acceptées ❌
- ⚠️ Aucune vérification de statut

### ✅ APRÈS (Sécurisé)

```sql
CREATE POLICY "Allow order creation for active establishments only" ON orders
    FOR INSERT WITH CHECK (
        establishment_id IN (
            SELECT e.id 
            FROM establishments e
            INNER JOIN users u ON e.user_id = u.id
            WHERE e.is_active = true 
            AND u.is_active = true
        )
    );
```

**Résultat:**
- ✅ Propriétaire bloqué → Commandes bloquées ✓
- ✅ Établissement inactif → Commandes bloquées ✓
- ✅ Commandes en cours annulées automatiquement
- ✅ Double vérification (établissement + propriétaire)

---

## 🚀 Instructions d'Application

### Étape 1: Appliquer la Migration

```bash
# Via Supabase SQL Editor (Recommandé)
1. Ouvrir Supabase Dashboard
2. Aller dans SQL Editor
3. Copier le contenu de: bdd/migration_secure_order_creation.sql
4. Exécuter le script

# OU via psql
psql -d votre_base -f bdd/migration_secure_order_creation.sql
```

### Étape 2: Tester la Migration

```sql
-- Test 1: Fonction de test
SELECT * FROM test_order_creation_security();

-- Test 2: Vérifier les établissements actifs
SELECT * FROM active_establishments_for_orders;

-- Test 3: Tester un établissement spécifique
SELECT can_receive_orders('uuid-de-votre-etablissement');
```

### Étape 3: Vérifier l'Interface Admin

1. Se connecter en tant qu'admin
2. Aller dans `/admin/orders/[id]`
3. Vérifier l'affichage du statut du propriétaire
4. Bloquer un propriétaire de test
5. Vérifier que l'alerte rouge apparaît

---

## 📊 Scénarios de Test

### Test 1: Propriétaire Actif ✅

```sql
-- Setup
UPDATE users SET is_active = true WHERE id = 'owner-test-1';
UPDATE establishments SET is_active = true WHERE user_id = 'owner-test-1';

-- Test (devrait RÉUSSIR)
INSERT INTO orders (establishment_id, table_number, total_amount)
SELECT id, 1, 5000 FROM establishments WHERE user_id = 'owner-test-1';

-- Résultat attendu: Commande créée ✅
```

### Test 2: Propriétaire Bloqué ❌

```sql
-- Setup
UPDATE users SET is_active = false WHERE id = 'owner-test-2';

-- Test (devrait ÉCHOUER)
INSERT INTO orders (establishment_id, table_number, total_amount)
SELECT id, 1, 5000 FROM establishments WHERE user_id = 'owner-test-2';

-- Résultat attendu: ERREUR - new row violates row-level security policy ❌
```

### Test 3: Annulation Automatique ⚠️

```sql
-- 1. Créer une commande en attente
INSERT INTO orders (establishment_id, table_number, status, total_amount)
SELECT id, 1, 'pending', 5000 FROM establishments WHERE user_id = 'owner-test-3';

-- 2. Bloquer le propriétaire
UPDATE users SET is_active = false WHERE id = 'owner-test-3';

-- 3. Vérifier l'annulation (devrait être cancelled)
SELECT status, notes FROM orders 
WHERE establishment_id IN (
    SELECT id FROM establishments WHERE user_id = 'owner-test-3'
)
ORDER BY created_at DESC LIMIT 1;

-- Résultat attendu: 
-- status = 'cancelled'
-- notes contient 'Compte propriétaire désactivé'
```

---

## 🎨 Aperçu Interface Admin

### Propriétaire Actif
```
┌─────────────────────────────────────────┐
│ 🏪 Établissement                        │
├─────────────────────────────────────────┤
│ 🟠 Restaurant Le Gourmet                │
│ 📍 123 Rue de Paris                     │
│ ✅ Actif                                │
│                                         │
│ 👤 Propriétaire                         │
│ ✅ Actif                                │
│ Jean Dupont                             │
│ jean@example.com                        │
│                                         │
│ ✅ Peut recevoir des commandes          │
└─────────────────────────────────────────┘
```

### Propriétaire Bloqué
```
┌─────────────────────────────────────────┐
│ 🏪 Établissement                        │
├─────────────────────────────────────────┤
│ 🟠 Restaurant Le Gourmet                │
│ 📍 123 Rue de Paris                     │
│ ✅ Actif                                │
│                                         │
│ 👤 Propriétaire                         │
│ 🔴 Bloqué                               │
│ Jean Dupont                             │
│ jean@example.com                        │
│                                         │
│ ⚠️ PROPRIÉTAIRE BLOQUÉ                  │
│ Cet établissement ne peut plus          │
│ recevoir de nouvelles commandes.        │
│ Les commandes en attente ont été        │
│ automatiquement annulées.               │
└─────────────────────────────────────────┘
```

---

## 🔍 Monitoring et Audit

### Voir les Propriétaires Bloqués

```sql
SELECT 
    u.id,
    u.full_name,
    u.email,
    u.is_active,
    COUNT(e.id) as nb_establishments
FROM users u
LEFT JOIN establishments e ON e.user_id = u.id
WHERE u.is_active = false
GROUP BY u.id, u.full_name, u.email, u.is_active;
```

### Voir les Commandes Annulées Automatiquement

```sql
SELECT 
    o.id,
    o.created_at,
    o.updated_at,
    e.name as establishment,
    u.full_name as owner,
    o.total_amount,
    o.notes
FROM orders o
JOIN establishments e ON o.establishment_id = e.id
JOIN users u ON e.user_id = u.id
WHERE o.status = 'cancelled'
  AND o.notes LIKE '%propriétaire désactivé%'
ORDER BY o.updated_at DESC
LIMIT 50;
```

### Statistiques

```sql
SELECT 
    COUNT(*) FILTER (WHERE u.is_active = false) as owners_blocked,
    COUNT(*) FILTER (WHERE u.is_active = true) as owners_active,
    COUNT(DISTINCT e.id) FILTER (WHERE u.is_active = false) as establishments_blocked,
    COUNT(o.id) FILTER (
        WHERE o.status = 'cancelled' 
        AND o.notes LIKE '%propriétaire désactivé%'
        AND o.updated_at >= CURRENT_DATE
    ) as orders_auto_cancelled_today
FROM users u
LEFT JOIN establishments e ON e.user_id = u.id
LEFT JOIN orders o ON o.establishment_id = e.id
WHERE u.role IN ('owner', 'manager');
```

---

## ⚠️ Avertissements Importants

### Pour les Administrateurs

1. **Blocage Immédiat**
   - Le blocage prend effet **immédiatement**
   - Aucun délai de grâce
   - Les commandes en cours sont annulées

2. **Communication Nécessaire**
   - ⚠️ Informer le propriétaire AVANT de bloquer
   - 📧 Envoyer un email explicatif
   - 📞 Contacter par téléphone si urgent

3. **Traçabilité**
   - 📝 Documenter la raison du blocage
   - 📅 Noter la date et l'heure
   - 👤 Indiquer qui a effectué le blocage

### Bonnes Pratiques

```sql
-- ❌ MAUVAIS: Bloquer sans prévenir
UPDATE users SET is_active = false WHERE id = 'xxx';

-- ✅ BON: Processus complet
-- 1. Vérifier l'impact
SELECT 
    COUNT(o.id) as pending_orders,
    SUM(o.total_amount) as pending_amount
FROM orders o
JOIN establishments e ON o.establishment_id = e.id
WHERE e.user_id = 'xxx'
  AND o.status IN ('pending', 'processing');

-- 2. Contacter le propriétaire
-- 3. Documenter la raison
-- 4. Bloquer
UPDATE users SET is_active = false WHERE id = 'xxx';

-- 5. Vérifier l'annulation
SELECT * FROM orders 
WHERE establishment_id IN (SELECT id FROM establishments WHERE user_id = 'xxx')
AND status = 'cancelled'
AND notes LIKE '%propriétaire désactivé%';
```

---

## 🔄 Déblocage

### Processus de Déblocage

```sql
-- 1. Débloquer le propriétaire
UPDATE users 
SET is_active = true 
WHERE id = 'xxx';

-- 2. Vérifier que l'établissement peut recevoir des commandes
SELECT can_receive_orders(id) 
FROM establishments 
WHERE user_id = 'xxx';

-- Résultat attendu: true
```

### Effets du Déblocage

- ✅ Connexion immédiate possible
- ✅ Peut recevoir de nouvelles commandes
- ⚠️ Les commandes annulées restent annulées (pas de restauration automatique)
- ✅ Établissement réapparaît dans `active_establishments_for_orders`

---

## 📚 Documentation Associée

1. **Migration SQL:** `/bdd/migration_secure_order_creation.sql`
2. **Documentation Complète:** `/SECURITY_BLOCKED_OWNERS.md`
3. **Module Admin Orders:** `/ADMIN_ORDERS_MODULE.md`

---

## 🎓 Résumé des Changements

| Aspect | Avant | Après |
|--------|-------|-------|
| Propriétaire bloqué peut recevoir commandes | ❌ OUI | ✅ NON |
| Vérification statut établissement | ❌ NON | ✅ OUI |
| Vérification statut propriétaire | ❌ NON | ✅ OUI |
| Annulation auto commandes | ❌ NON | ✅ OUI |
| Alerte visuelle UI | ❌ NON | ✅ OUI |
| Fonction helper `can_receive_orders` | ❌ NON | ✅ OUI |
| Vue `active_establishments_for_orders` | ❌ NON | ✅ OUI |
| Tests de sécurité | ❌ NON | ✅ OUI |

---

**Date:** 19 Novembre 2025  
**Version:** 1.0.0  
**Impact:** MAJEUR - Sécurité  
**Type:** Migration + UI

**Status:** ✅ Prêt pour production
