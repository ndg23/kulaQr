-- Script de correction des politiques RLS pour la table establishments
-- À exécuter dans Supabase SQL Editor

-- 1. Désactiver temporairement RLS sur la table establishments
ALTER TABLE establishments DISABLE ROW LEVEL SECURITY;

-- 2. Supprimer toutes les politiques existantes sur establishments
DROP POLICY IF EXISTS "Users can view their own establishments" ON establishments;
DROP POLICY IF EXISTS "Administrators can manage all establishments" ON establishments;
DROP POLICY IF EXISTS "Users can insert establishments" ON establishments;
DROP POLICY IF EXISTS "Users can update their own establishments" ON establishments;
DROP POLICY IF EXISTS "Users can delete their own establishments" ON establishments;

-- 3. Réactiver RLS
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;

-- 4. Créer une politique pour permettre l'insertion d'établissements
CREATE POLICY "Users can insert establishments" ON establishments 
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 5. Créer une politique pour permettre aux utilisateurs de voir leurs établissements
CREATE POLICY "Users can view their own establishments" ON establishments 
FOR SELECT USING (auth.uid() = user_id);

-- 6. Créer une politique pour permettre aux utilisateurs de modifier leurs établissements
CREATE POLICY "Users can update their own establishments" ON establishments 
FOR UPDATE USING (auth.uid() = user_id);

-- 7. Créer une politique pour permettre aux utilisateurs de supprimer leurs établissements
CREATE POLICY "Users can delete their own establishments" ON establishments 
FOR DELETE USING (auth.uid() = user_id);

-- 8. Créer une politique pour permettre aux administrateurs de tout faire
CREATE POLICY "Administrators can manage all establishments" ON establishments 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- 9. Vérifier que les politiques sont créées
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'establishments'
ORDER BY policyname;
