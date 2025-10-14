-- Script pour corriger la récursion infinie dans les politiques RLS de la table staff
-- Exécuter ce script dans le dashboard Supabase → SQL Editor

-- 1. Supprimer toutes les politiques existantes sur la table staff
DROP POLICY IF EXISTS "Staff viewable by establishment owners" ON staff;
DROP POLICY IF EXISTS "Users can manage their establishment staff" ON staff;
DROP POLICY IF EXISTS "Admins can manage everything - staff" ON staff;
DROP POLICY IF EXISTS "Staff management policy" ON staff;

-- 2. Créer une nouvelle politique unifiée sans récursion
CREATE POLICY "Staff unified policy" ON staff
    FOR ALL USING (
        -- Les propriétaires d'établissement peuvent gérer leur staff
        EXISTS (
            SELECT 1 FROM establishments 
            WHERE id = staff.establishment_id AND user_id = auth.uid()
        ) OR
        -- Les admins peuvent tout gérer (sans utiliser is_admin_user() pour éviter la récursion)
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- 3. Vérifier que les politiques ont été créées correctement
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'staff';
