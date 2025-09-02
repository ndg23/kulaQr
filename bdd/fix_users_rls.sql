-- Script de correction des politiques RLS pour la table users
-- À exécuter dans Supabase SQL Editor

-- 1. Désactiver temporairement RLS sur la table users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. Supprimer toutes les politiques existantes sur users
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Administrators can manage all users" ON users;
DROP POLICY IF EXISTS "Allow user registration" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can delete their own profile" ON users;

-- 3. Réactiver RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 4. Créer une politique simple pour permettre l'inscription
CREATE POLICY "Allow user registration" ON users 
FOR INSERT WITH CHECK (true);

-- 5. Créer une politique pour permettre aux utilisateurs de voir leur profil
CREATE POLICY "Users can view their own profile" ON users 
FOR SELECT USING (auth.uid() = id);

-- 6. Créer une politique pour permettre aux utilisateurs de modifier leur profil
CREATE POLICY "Users can update their own profile" ON users 
FOR UPDATE USING (auth.uid() = id);

-- 7. Créer une politique pour permettre aux administrateurs de tout faire
CREATE POLICY "Administrators can manage all users" ON users 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- 8. Vérifier que les politiques sont créées
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;
