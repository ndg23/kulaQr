# 🚀 GUIDE DE RECONSTRUCTION COMPLÈTE DE LA BASE DE DONNÉES

## ⚠️ ATTENTION
Ce guide vous permet de remettre complètement à zéro votre base de données Supabase et de la reconstruire proprement.

## 📋 ÉTAPES DE RECONSTRUCTION

### **ÉTAPE 1 : NETTOYAGE COMPLET**
1. Allez dans votre **Supabase Dashboard**
2. Cliquez sur **SQL Editor**
3. Copiez et collez le contenu de `clean_start.sql`
4. Cliquez sur **Run**
5. Attendez la confirmation : "🎉 NETTOYAGE TERMINÉ !"

### **ÉTAPE 2 : CRÉATION DE LA STRUCTURE**
1. Dans le même **SQL Editor**
2. Copiez et collez le contenu de `schema1.sql`
3. Cliquez sur **Run**
4. Vérifiez qu'il n'y a pas d'erreurs

### **ÉTAPE 3 : CRÉATION DES POLITIQUES RLS**
1. Copiez et collez le contenu de `policies2.sql`
2. Cliquez sur **Run**
3. Vérifiez qu'il n'y a pas d'erreurs

### **ÉTAPE 4 : CRÉATION DES TRIGGERS**
1. Copiez et collez le contenu de `trigger.sql`
2. Cliquez sur **Run**
3. Vérifiez qu'il n'y a pas d'erreurs

### **ÉTAPE 5 : CRÉATION DES VUES**
1. Copiez et collez le contenu de `views.sql`
2. Cliquez sur **Run**
3. Vérifiez qu'il n'y a pas d'erreurs

### **ÉTAPE 6 : INSERTION DES DONNÉES INITIALES**
1. Copiez et collez le contenu de `seeds.sql`
2. Cliquez sur **Run**
3. Vérifiez qu'il n'y a pas d'erreurs

## 🔍 VÉRIFICATIONS APRÈS CHAQUE ÉTAPE

### **Après schema1.sql :**
- Tables créées ✅
- Colonnes correctes ✅
- Contraintes appliquées ✅

### **Après policies2.sql :**
- RLS activé sur toutes les tables ✅
- Politiques créées ✅
- Pas d'erreurs de récursion ✅

### **Après trigger.sql :**
- Fonctions créées ✅
- Triggers attachés ✅
- Pas d'erreurs de dépendances ✅

### **Après views.sql :**
- Vues créées ✅
- Requêtes valides ✅

### **Après seeds.sql :**
- Types d'établissements insérés ✅
- Données de test créées ✅

## 🧪 TEST FINAL

1. Retournez sur votre formulaire d'inscription
2. Créez un compte test
3. Vérifiez que l'utilisateur et l'établissement sont créés
4. Vérifiez la console pour les logs

## 🚨 EN CAS DE PROBLÈME

Si une étape échoue :
1. **Notez l'erreur exacte**
2. **Vérifiez la console Supabase**
3. **Exécutez à nouveau `clean_start.sql`**
4. **Recommencez depuis l'étape qui a échoué**

## 📊 VÉRIFICATION FINALE

Après toutes les étapes, exécutez cette requête pour vérifier que tout est en place :

```sql
-- Vérification finale
SELECT 
    schemaname,
    tablename,
    'TABLE' as object_type
FROM pg_tables 
WHERE schemaname = 'public'
UNION ALL
SELECT 
    schemaname,
    policyname as tablename,
    'POLICY' as object_type
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY object_type, tablename;
```

## 🎯 OBJECTIF

À la fin, vous devriez avoir :
- ✅ 10 tables créées
- ✅ RLS activé sur toutes les tables
- ✅ Politiques de sécurité fonctionnelles
- ✅ Triggers automatisés
- ✅ Vues analytiques
- ✅ Données initiales

**Prêt à commencer ? Commencez par l'ÉTAPE 1 !** 🚀
