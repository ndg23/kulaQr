# ⚡ Quick Start - Auto-Paiement sur Complétion

## 🎯 Objectif

Automatiser le paiement: `status='completed'` → `payment_status='paid'`

---

## 📝 Installation (2 minutes)

### Étape 1: SQL Migration
```sql
-- Copier/coller tout le contenu dans Supabase SQL Editor
-- Fichier: bdd/migration_auto_payment_on_completed.sql
```

### Étape 2: Test
```sql
SELECT * FROM test_auto_payment_trigger();
-- Attendu: 4 lignes, toutes avec passed = true ✅
```

### Étape 3: Correction Anciennes Commandes (Optionnel)
```sql
SELECT * FROM fix_completed_unpaid_orders();
-- Corrige les commandes completed mais unpaid
```

---

## ✨ Utilisation

### Avant
```sql
UPDATE orders SET status = 'completed' WHERE id = 'xxx';
-- Résultat: completed, mais TOUJOURS unpaid ❌
```

### Maintenant
```sql
UPDATE orders SET status = 'completed' WHERE id = 'xxx';
-- Résultat: completed ET automatiquement paid ✅
--           payment_method = 'cash' (par défaut)
```

---

## 🎨 Interface (Aucun changement nécessaire!)

Le trigger fonctionne **automatiquement** en arrière-plan:

```typescript
// Staff/Admin - Code existant fonctionne tel quel
await supabase
  .from('orders')
  .update({ status: 'completed' })
  .eq('id', orderId);

// ✨ MAGIE: payment_status devient 'paid' automatiquement!
```

---

## 🧪 Test Rapide

```sql
-- 1. Créer commande test
INSERT INTO orders (establishment_id, table_number, status, payment_status, total_amount)
SELECT id, 999, 'pending', 'unpaid', 1000
FROM establishments LIMIT 1;

-- 2. Marquer completed
UPDATE orders SET status = 'completed' WHERE table_number = 999;

-- 3. Vérifier (devrait être 'paid')
SELECT status, payment_status, payment_method 
FROM orders WHERE table_number = 999;

-- 4. Nettoyer
DELETE FROM orders WHERE table_number = 999;
```

---

## 📊 Vérifications

### Trigger Actif?
```sql
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE trigger_name = 'trigger_auto_payment_on_completed';
-- Doit retourner 1 ligne
```

### Statistiques
```sql
SELECT * FROM order_payment_stats;
-- Vue des commandes par statut/paiement
```

---

## ⚙️ Fonctionnalités

| Feature | Status |
|---------|--------|
| Auto-paiement sur completed | ✅ |
| Méthode par défaut (cash) | ✅ |
| Note automatique ajoutée | ✅ |
| Fonction de test | ✅ |
| Correction rétroactive | ✅ |
| Vue statistiques | ✅ |

---

## 🆘 Problèmes?

### Trigger ne fonctionne pas
```sql
-- Vérifier s'il existe
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'trigger_auto_payment_on_completed';

-- Réappliquer si nécessaire
DROP TRIGGER IF EXISTS trigger_auto_payment_on_completed ON orders;
-- Puis réexécuter la migration
```

### Désactiver temporairement
```sql
ALTER TABLE orders DISABLE TRIGGER trigger_auto_payment_on_completed;
-- Pour réactiver:
ALTER TABLE orders ENABLE TRIGGER trigger_auto_payment_on_completed;
```

---

## 📚 Documentation

- **Guide complet:** `AUTO_PAYMENT_ON_COMPLETED.md`
- **Fichier SQL:** `bdd/migration_auto_payment_on_completed.sql`

---

**Temps d'installation:** 2 minutes  
**Complexité:** ⭐☆☆☆☆ (Très facile)  
**Impact:** ✨ Automatisation complète du paiement
