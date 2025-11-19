# 💳 Auto-Paiement lors de la Complétion de Commande

## 📋 Résumé

**Fonctionnalité:** Lorsqu'une commande passe au statut `completed`, elle est **automatiquement** marquée comme `paid` si elle était `unpaid`.

## 🎯 Comportement

### Avant le Trigger
```
Commande: status = 'pending', payment_status = 'unpaid'
↓ UPDATE status = 'completed'
Résultat: status = 'completed', payment_status = 'unpaid' ❌
```

### Avec le Trigger
```
Commande: status = 'pending', payment_status = 'unpaid'
↓ UPDATE status = 'completed'
Résultat: status = 'completed', payment_status = 'paid' ✅
          payment_method = 'cash' (par défaut)
```

## ⚙️ Logique du Trigger

```sql
SI (status change vers 'completed' ET payment_status = 'unpaid')
ALORS
    payment_status := 'paid'
    SI (payment_method IS NULL)
        payment_method := 'cash'
    FIN SI
    Ajouter note: "Paiement automatique enregistré"
FIN SI
```

## 🚀 Installation

### Étape 1: Appliquer la Migration
```bash
# Via Supabase SQL Editor
# Copier/coller le contenu de:
bdd/migration_auto_payment_on_completed.sql
```

### Étape 2: Tester
```sql
SELECT * FROM test_auto_payment_trigger();

-- Résultat attendu: 4 tests passés ✅
```

### Étape 3: Corriger les Anciennes Commandes
```sql
-- Mettre à jour les commandes déjà complétées mais non payées
SELECT * FROM fix_completed_unpaid_orders();

-- Retourne: Liste des commandes corrigées avec leurs nouveaux statuts
```

## 📊 Cas d'Usage

### Cas 1: Nouvelle Commande → Completed
```sql
-- 1. Créer une commande
INSERT INTO orders (establishment_id, table_number, status, payment_status, total_amount)
VALUES ('est-123', 5, 'pending', 'unpaid', 5000);

-- 2. Marquer comme completed
UPDATE orders SET status = 'completed' WHERE id = 'order-123';

-- Résultat automatique:
-- ✅ payment_status = 'paid'
-- ✅ payment_method = 'cash'
-- ✅ Note ajoutée dans le champ notes
```

### Cas 2: Commande Déjà Payée
```sql
-- 1. Commande avec paiement
INSERT INTO orders (establishment_id, table_number, status, payment_status, payment_method, total_amount)
VALUES ('est-123', 5, 'pending', 'paid', 'card', 5000);

-- 2. Marquer comme completed
UPDATE orders SET status = 'completed' WHERE id = 'order-123';

-- Résultat:
-- ✅ payment_status reste 'paid'
-- ✅ payment_method reste 'card'
-- ❌ Aucune modification (déjà payée)
```

### Cas 3: Depuis l'Interface Admin/Staff
```typescript
// Dans votre code Vue/TypeScript
await supabase
  .from('orders')
  .update({ status: 'completed' })
  .eq('id', orderId);

// Le trigger s'exécute automatiquement
// Aucun code supplémentaire nécessaire! ✨
```

## 🔍 Fonctions Helper

### 1. Vérifier si Auto-Paiement se Déclenchera
```sql
SELECT will_auto_pay_on_completion('order-uuid-here');

-- Retourne:
-- true  = La commande sera auto-payée lors de la complétion
-- false = La commande ne sera pas auto-payée (déjà paid ou completed)
```

### 2. Statistiques de Paiement
```sql
SELECT * FROM order_payment_stats;

-- Résultat: Tableau des commandes par statut et payment_status
-- status    | payment_status | count | total_amount | avg_amount | payment_method
-- ----------|----------------|-------|--------------|------------|---------------
-- pending   | unpaid         | 10    | 50000        | 5000       | NULL
-- completed | paid           | 25    | 125000       | 5000       | cash
-- completed | paid           | 15    | 90000        | 6000       | card
```

### 3. Corriger Toutes les Anciennes Commandes
```sql
SELECT * FROM fix_completed_unpaid_orders();

-- Retourne: Liste des commandes corrigées
-- order_id | previous_payment_status | new_payment_status | payment_method
-- ---------|------------------------|-------------------|---------------
-- xxx-123  | unpaid                 | paid              | cash
-- xxx-456  | unpaid                 | paid              | cash
```

## 🎨 Impact sur l'Interface

### Page Admin Orders - Détail
Aucun changement nécessaire! Le trigger fonctionne en backend.

### Workflow Staff
```
1. Client termine son repas
2. Staff clique "Marquer comme Terminée"
3. ✨ MAGIE: Paiement automatiquement enregistré
4. Commande apparaît comme "Completed" ET "Paid"
```

### Workflow Admin
```
1. Admin consulte une commande completed
2. Voit automatiquement payment_status = 'paid'
3. Voit payment_method = 'cash' (ou autre si spécifié)
4. Voit la note: "Paiement automatique enregistré..."
```

## 📝 Notes dans les Commandes

Le trigger ajoute automatiquement une note:

```
Paiement automatique enregistré lors de la complétion de la commande.
```

**Si des notes existaient déjà:**
```
[Notes existantes]

Paiement automatique enregistré lors de la complétion de la commande.
```

## ⚠️ Avertissements

### Important
1. **Méthode de Paiement par Défaut:** Si aucune méthode n'est spécifiée, `cash` est utilisé
2. **Irréversible:** Le changement est permanent (sauf correction manuelle)
3. **Historique:** La note ajoutée permet de tracer l'auto-paiement

### Recommandations
1. ✅ Définir `payment_method` AVANT de marquer comme completed
2. ✅ Vérifier le montant avant de compléter
3. ✅ Former le staff sur le nouveau workflow

## 🧪 Tests

### Test Complet
```sql
-- Exécuter tous les tests
SELECT * FROM test_auto_payment_trigger();

-- Résultat attendu:
-- test_name                      | passed | message
-- -------------------------------|--------|----------------------------------
-- Test 1: Create unpaid order    | true   | Commande créée avec...
-- Test 2: Auto-payment...        | true   | Commande auto-payée...
-- Test 3: Default payment method | true   | Méthode de paiement définie...
-- Cleanup                        | true   | Commande de test supprimée
```

### Test Manuel Simple
```sql
-- 1. Créer une commande de test
INSERT INTO orders (establishment_id, table_number, status, payment_status, total_amount)
SELECT id, 999, 'pending', 'unpaid', 1000
FROM establishments WHERE is_active = true LIMIT 1
RETURNING id;

-- Noter l'ID retourné (ex: abc-123)

-- 2. Vérifier le statut actuel
SELECT id, status, payment_status, payment_method 
FROM orders WHERE id = 'abc-123';
-- Résultat: pending | unpaid | NULL

-- 3. Marquer comme completed
UPDATE orders SET status = 'completed' WHERE id = 'abc-123';

-- 4. Vérifier le nouveau statut
SELECT id, status, payment_status, payment_method, notes
FROM orders WHERE id = 'abc-123';
-- Résultat: completed | paid | cash | "Paiement automatique..."

-- 5. Nettoyer
DELETE FROM orders WHERE id = 'abc-123';
```

## 🔄 Rollback

Si vous devez désactiver cette fonctionnalité:

```sql
-- Supprimer le trigger
DROP TRIGGER IF EXISTS trigger_auto_payment_on_completed ON orders;

-- Supprimer les fonctions
DROP FUNCTION IF EXISTS auto_payment_on_order_completed();
DROP FUNCTION IF EXISTS will_auto_pay_on_completion(UUID);
DROP FUNCTION IF EXISTS fix_completed_unpaid_orders();
DROP FUNCTION IF EXISTS test_auto_payment_trigger();

-- Supprimer la vue
DROP VIEW IF EXISTS order_payment_stats;
```

## 📊 Statistiques et Monitoring

### Commandes Auto-Payées Aujourd'hui
```sql
SELECT COUNT(*) as auto_paid_today
FROM orders
WHERE status = 'completed'
  AND payment_status = 'paid'
  AND notes LIKE '%Paiement automatique enregistré%'
  AND updated_at >= CURRENT_DATE;
```

### Taux d'Auto-Paiement
```sql
SELECT 
    COUNT(*) FILTER (WHERE notes LIKE '%Paiement automatique%') as auto_paid,
    COUNT(*) FILTER (WHERE notes NOT LIKE '%Paiement automatique%') as manual_paid,
    COUNT(*) as total_completed
FROM orders
WHERE status = 'completed'
  AND payment_status = 'paid'
  AND created_at >= CURRENT_DATE - INTERVAL '30 days';
```

### Méthodes de Paiement Utilisées
```sql
SELECT 
    payment_method,
    COUNT(*) as count,
    SUM(total_amount) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value
FROM orders
WHERE status = 'completed'
  AND payment_status = 'paid'
GROUP BY payment_method
ORDER BY count DESC;
```

## 🎓 FAQ

### Q: Que se passe-t-il si je spécifie déjà payment_method='card'?
**R:** Le trigger respecte votre choix. Seul 'cash' est utilisé si payment_method est NULL.

### Q: Puis-je désactiver temporairement le trigger?
**R:** Oui, exécutez:
```sql
ALTER TABLE orders DISABLE TRIGGER trigger_auto_payment_on_completed;
```
Pour réactiver:
```sql
ALTER TABLE orders ENABLE TRIGGER trigger_auto_payment_on_completed;
```

### Q: Le trigger fonctionne-t-il rétroactivement?
**R:** Non, seulement pour les futures modifications. Utilisez `fix_completed_unpaid_orders()` pour les anciennes commandes.

### Q: Comment vérifier que le trigger est actif?
**R:** 
```sql
SELECT 
    trigger_name, 
    event_manipulation, 
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trigger_auto_payment_on_completed';
```

## ✅ Checklist de Vérification

Après installation:
- [ ] Migration SQL appliquée sans erreur
- [ ] Tests passent (4/4 ✅)
- [ ] Trigger visible dans information_schema.triggers
- [ ] Test manuel réussi (création → complétion → auto-paiement)
- [ ] Anciennes commandes corrigées avec `fix_completed_unpaid_orders()`
- [ ] Staff/Admin informés du nouveau comportement

---

**Date:** 19 Novembre 2025  
**Version:** 1.0.0  
**Fichier:** `bdd/migration_auto_payment_on_completed.sql`  
**Impact:** Automatisation du workflow de paiement ✨
