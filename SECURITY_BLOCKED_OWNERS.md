# Sécurité des Commandes - Gestion des Propriétaires Bloqués

## 🔴 Problème Identifié

**Question:** Si un owner est bloqué, est-ce que son établissement continue de recevoir les commandes ou alors il ne doit plus se connecter?

**Réponse:** Actuellement, **OUI** - c'est un problème de sécurité! ❌

### Comportement Actuel (AVANT la migration)

```sql
-- Politique permissive actuelle
CREATE POLICY "Allow anonymous order creation" ON orders
    FOR INSERT TO anon WITH CHECK (true);
```

**Problèmes:**
1. ✅ N'importe qui peut créer une commande
2. ❌ Aucune vérification si l'établissement est actif
3. ❌ Aucune vérification si le propriétaire est actif/bloqué
4. ❌ Les commandes continuent même si le propriétaire est bloqué

## ✅ Solution Implémentée

### 1. Nouvelle Politique de Sécurité

```sql
CREATE POLICY "Allow order creation for active establishments only" ON orders
    FOR INSERT 
    TO anon, authenticated
    WITH CHECK (
        establishment_id IN (
            SELECT e.id 
            FROM establishments e
            INNER JOIN users u ON e.user_id = u.id
            WHERE e.id = establishment_id
            AND e.is_active = true  -- ✅ Établissement actif
            AND u.is_active = true  -- ✅ Propriétaire actif
        )
    );
```

### 2. Fonction Helper

```sql
CREATE FUNCTION can_receive_orders(establishment_uuid UUID)
RETURNS BOOLEAN
```

**Usage:**
```sql
SELECT can_receive_orders('uuid-de-etablissement');
-- Retourne true uniquement si établissement ET propriétaire sont actifs
```

### 3. Trigger Automatique

Lorsqu'un propriétaire est bloqué (`is_active = false`):
- ✅ Toutes les commandes en attente sont **automatiquement annulées**
- ✅ Une note est ajoutée expliquant l'annulation
- ✅ Seules les commandes récentes (< 24h) sont annulées

```sql
-- Exemple d'annulation automatique
UPDATE orders
SET status = 'cancelled',
    notes = notes || '\n\nCommande annulée - Compte propriétaire désactivé'
WHERE establishment_id IN (
    SELECT id FROM establishments WHERE user_id = 'owner_bloqué_id'
)
AND status IN ('pending', 'processing');
```

### 4. Vue des Établissements Actifs

```sql
CREATE VIEW active_establishments_for_orders AS
SELECT e.*, u.is_active as owner_active
FROM establishments e
INNER JOIN users u ON e.user_id = u.id
WHERE e.is_active = true
  AND u.is_active = true;
```

## 🎯 Comportement Final

### Scénario 1: Propriétaire Actif
```
Owner: is_active = true
Establishment: is_active = true
→ ✅ PEUT recevoir des commandes
```

### Scénario 2: Propriétaire Bloqué
```
Owner: is_active = false  ← BLOQUÉ
Establishment: is_active = true
→ ❌ NE PEUT PAS recevoir de nouvelles commandes
→ ⚠️ Commandes en cours automatiquement annulées
→ ❌ Ne peut plus se connecter à son compte
```

### Scénario 3: Établissement Inactif
```
Owner: is_active = true
Establishment: is_active = false  ← INACTIF
→ ❌ NE PEUT PAS recevoir des commandes
→ ✅ Le propriétaire peut toujours se connecter
```

### Scénario 4: Les Deux Inactifs
```
Owner: is_active = false  ← BLOQUÉ
Establishment: is_active = false  ← INACTIF
→ ❌ NE PEUT PAS recevoir des commandes
→ ❌ Ne peut plus se connecter
```

## 📊 Impact sur les Différents Acteurs

### Pour les Clients
- **Avant:** Pouvaient commander même si le propriétaire était bloqué ❌
- **Après:** Ne peuvent commander que si tout est actif ✅
- **Expérience:** Protection contre les établissements non opérationnels

### Pour le Propriétaire Bloqué
- **Connexion:** ❌ NE PEUT PLUS se connecter (auth.users bloqué)
- **Commandes:** ❌ NE REÇOIT PLUS de nouvelles commandes
- **Commandes en cours:** ⚠️ Annulées automatiquement
- **Données:** ✅ Conservées mais inaccessibles

### Pour l'Administrateur
- **Contrôle:** ✅ Blocage immédiat et complet
- **Audit:** ✅ Historique des commandes annulées
- **Déblocage:** ✅ Réactivation simple (`UPDATE users SET is_active = true`)

### Pour le Staff
- **Établissement du propriétaire bloqué:** ❌ Ne peut plus accéder
- **Leurs propres commandes:** ⚠️ Annulées si liées à l'établissement

## 🔧 Utilisation

### Bloquer un Propriétaire

```sql
-- Option 1: Via SQL direct
UPDATE users 
SET is_active = false 
WHERE id = 'uuid-du-proprietaire';

-- Résultat automatique:
-- 1. Propriétaire ne peut plus se connecter
-- 2. Établissements ne reçoivent plus de commandes
-- 3. Commandes en attente annulées automatiquement
```

```typescript
// Option 2: Via l'interface admin
await supabase
  .from('users')
  .update({ is_active: false })
  .eq('id', userId);
```

### Débloquer un Propriétaire

```sql
UPDATE users 
SET is_active = true 
WHERE id = 'uuid-du-proprietaire';

-- Résultat:
-- 1. Propriétaire peut se reconnecter
-- 2. Établissements peuvent recevoir des commandes
-- 3. Opérations reprennent normalement
```

### Vérifier le Statut

```sql
-- Vérifier si un établissement peut recevoir des commandes
SELECT can_receive_orders('uuid-etablissement');

-- Voir tous les établissements actifs
SELECT * FROM active_establishments_for_orders;

-- Vérifier le statut d'un propriétaire
SELECT 
    u.id,
    u.full_name,
    u.is_active as owner_active,
    e.id as establishment_id,
    e.name as establishment_name,
    e.is_active as establishment_active,
    can_receive_orders(e.id) as can_receive_orders
FROM users u
LEFT JOIN establishments e ON e.user_id = u.id
WHERE u.id = 'uuid-proprietaire';
```

## 🧪 Tests de Sécurité

### Test 1: Vérifier la Fonction
```sql
SELECT * FROM test_order_creation_security();
```

### Test 2: Tentative de Commande sur Compte Bloqué
```sql
-- 1. Bloquer un propriétaire
UPDATE users SET is_active = false WHERE id = 'test-owner-id';

-- 2. Tenter de créer une commande (devrait échouer)
INSERT INTO orders (establishment_id, table_number, total_amount)
SELECT id, 1, 1000 
FROM establishments 
WHERE user_id = 'test-owner-id';
-- Résultat attendu: ERREUR - Policy violation

-- 3. Débloquer
UPDATE users SET is_active = true WHERE id = 'test-owner-id';

-- 4. Retenter (devrait réussir)
INSERT INTO orders (establishment_id, table_number, total_amount)
SELECT id, 1, 1000 
FROM establishments 
WHERE user_id = 'test-owner-id';
-- Résultat attendu: SUCCÈS
```

## 📝 Logs et Audit

### Commandes Annulées Automatiquement

Les commandes annulées contiennent dans le champ `notes`:
```
Commande annulée automatiquement - Compte propriétaire désactivé le 2025-11-19 14:30:00
```

### Requête pour Voir les Annulations

```sql
SELECT 
    o.id,
    o.created_at,
    o.updated_at,
    o.status,
    o.notes,
    e.name as establishment_name,
    u.full_name as owner_name
FROM orders o
JOIN establishments e ON o.establishment_id = e.id
JOIN users u ON e.user_id = u.id
WHERE o.notes LIKE '%Compte propriétaire désactivé%'
ORDER BY o.updated_at DESC;
```

## ⚠️ Avertissements

### Important pour les Admins

1. **Blocage Immédiat:** Le blocage est instantané, les commandes en cours sont annulées
2. **Pas de Préavis:** Aucune notification automatique au propriétaire
3. **Réversible:** Le déblocage restaure immédiatement l'accès
4. **Données Conservées:** Rien n'est supprimé, juste bloqué

### Recommandations

1. ⚠️ **Avertir avant de bloquer** - Contacter le propriétaire
2. ✅ **Documenter la raison** - Ajouter une note dans un système de tickets
3. 📧 **Notifier par email** - Informer le propriétaire du blocage
4. 🔍 **Vérifier l'impact** - Regarder les commandes en cours avant de bloquer

## 🔄 Migration

### Appliquer la Migration

```bash
# Via psql
psql -d kulaQr -f bdd/migration_secure_order_creation.sql

# Ou via Supabase SQL Editor
# Copier/coller le contenu du fichier
```

### Rollback (Si Nécessaire)

```sql
-- Revenir à l'ancienne politique permissive
DROP POLICY IF EXISTS "Allow order creation for active establishments only" ON orders;
CREATE POLICY "Allow anonymous order creation" ON orders FOR INSERT TO anon WITH CHECK (true);
DROP FUNCTION IF EXISTS can_receive_orders(UUID);
DROP VIEW IF EXISTS active_establishments_for_orders;
DROP TRIGGER IF EXISTS trigger_block_orders_on_owner_deactivation ON users;
DROP FUNCTION IF EXISTS block_pending_orders_on_owner_deactivation();
```

## 📊 Statistiques

### Voir l'Impact du Blocage

```sql
-- Nombre de propriétaires bloqués
SELECT COUNT(*) FROM users WHERE is_active = false;

-- Nombre d'établissements affectés
SELECT COUNT(*) 
FROM establishments e
JOIN users u ON e.user_id = u.id
WHERE u.is_active = false;

-- Commandes annulées automatiquement aujourd'hui
SELECT COUNT(*) 
FROM orders
WHERE status = 'cancelled'
  AND notes LIKE '%propriétaire désactivé%'
  AND updated_at >= CURRENT_DATE;
```

---

## 🎓 Résumé

**Question initiale:** Si un owner est bloqué, son établissement continue-t-il de recevoir des commandes?

**Réponse AVANT migration:** ❌ OUI (problème de sécurité)

**Réponse APRÈS migration:** ✅ NON (sécurisé)

**Actions automatiques lors du blocage:**
1. ❌ Plus de connexion possible
2. ❌ Plus de nouvelles commandes
3. ⚠️ Commandes en cours annulées
4. ✅ Données conservées
5. ✅ Réversible immédiatement

---

**Date de création:** 19 Novembre 2025  
**Version:** 1.0.0  
**Fichier de migration:** `bdd/migration_secure_order_creation.sql`
