-- 🔒 POLITIQUES RLS COMPLÈTES POUR TOUTES LES TABLES
-- ⚠️ ATTENTION : Exécuter APRÈS schema1.sql

-- 0. CRÉER LA FONCTION HELPER is_admin_user() EN PREMIER
CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID DEFAULT auth.uid()) 
RETURNS BOOLEAN 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users 
    WHERE id = user_uuid AND role = 'admin'
  );
END;
$$;

-- 1. NETTOYAGE COMPLET DES POLITIQUES EXISTANTES
-- Désactiver RLS temporairement pour éviter les conflits
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS products DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_codes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_scans DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff_activity_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishment_types DISABLE ROW LEVEL SECURITY;

  ------------------------------------------
  -- Activation du RLS pour toutes les tables
  ------------------------------------------
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
  ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
  ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
  ALTER TABLE products ENABLE ROW LEVEL SECURITY;
  ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
  ALTER TABLE qr_scans ENABLE ROW LEVEL SECURITY;

  ------------------------------------------
  -- Policies pour Users
  ------------------------------------------
  CREATE POLICY "Users can view their own profile"
    ON users
    FOR SELECT
    USING (auth.uid() = id);

  CREATE POLICY "Users can update their own profile"
    ON users
    FOR UPDATE
    USING (auth.uid() = id);

  ------------------------------------------
  -- Policies pour Establishments
  ------------------------------------------
  CREATE POLICY "Public establishments are viewable by everyone"
    ON establishments
    FOR SELECT
    USING (is_active = true);

  CREATE POLICY "Users can update their own establishments"
    ON establishments
    FOR UPDATE
    USING (
      auth.uid() = created_by OR
      auth.uid() = owner_id OR
      auth.uid() IN (
        SELECT id FROM staff 
        WHERE establishment_id = establishments.id 
        AND role = 'manager'
      )
    );

  CREATE POLICY "Users can insert their own establishments"
    ON establishments
    FOR INSERT
    WITH CHECK (auth.uid() = created_by);

  CREATE POLICY "Users can delete their own establishments"
    ON establishments
    FOR DELETE
    USING (auth.uid() = created_by OR auth.uid() = owner_id);

  ------------------------------------------
  -- Policies pour Staff
  ------------------------------------------
  CREATE POLICY "Staff members are viewable by establishment owners"
    ON staff
    FOR SELECT
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = staff.establishment_id
      )
    );

  CREATE POLICY "Users can manage their establishment staff"
    ON staff
    FOR ALL
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = staff.establishment_id
      )
    );

  ------------------------------------------
  -- Policies pour Categories
  ------------------------------------------
  CREATE POLICY "Categories are viewable by everyone"
    ON categories
    FOR SELECT
    USING (true);

  CREATE POLICY "Categories can be managed by establishment owners and staff"
    ON categories
    FOR ALL
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = categories.establishment_id
      ) OR
      auth.uid() IN (
        SELECT id FROM staff 
        WHERE establishment_id = categories.establishment_id 
        AND role IN ('manager', 'admin')
      )
    );

  ------------------------------------------
  -- Policies pour Products
  ------------------------------------------
  CREATE POLICY "Products are viewable by everyone"
    ON products
    FOR SELECT
    USING (true);

  CREATE POLICY "Products can be managed by establishment owners and staff"
    ON products
    FOR ALL
    USING (
      auth.uid() IN (
        SELECT e.user_id 
        FROM establishments e
        JOIN categories c ON c.establishment_id = e.id
        WHERE c.id = products.category_id
      ) OR
      auth.uid() IN (
        SELECT s.id 
        FROM staff s
        JOIN categories c ON c.establishment_id = s.establishment_id
        WHERE c.id = products.category_id 
        AND s.role IN ('manager', 'admin')
      )
    );

  ------------------------------------------
  -- Policies pour QR Codes
  ------------------------------------------
  CREATE POLICY "QR codes are viewable by establishment owners"
    ON qr_codes
    FOR SELECT
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = qr_codes.establishment_id
      )
    );

  CREATE POLICY "QR codes can be managed by establishment owners"
    ON qr_codes
    FOR ALL
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = qr_codes.establishment_id
      )
    );

  ------------------------------------------
  -- Policies pour QR Scans
  ------------------------------------------
  CREATE POLICY "QR scans are viewable by establishment owners"
    ON qr_scans
    FOR SELECT
    USING (
      auth.uid() IN (
        SELECT user_id FROM establishments 
        WHERE id = qr_scans.establishment_id
      )
    );

  CREATE POLICY "QR scans can be inserted by anyone"
    ON qr_scans
    FOR INSERT
    WITH CHECK (true);

  ------------------------------------------
  -- Policies pour les administrateurs
  ------------------------------------------
  CREATE POLICY "Administrators can do everything"
    ON users
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can manage all establishments"
    ON establishments
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can manage all staff"
    ON staff
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can manage all categories"
    ON categories
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can manage all products"
    ON products
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can manage all QR codes"
    ON qr_codes
    FOR ALL
    USING (is_admin_user());

  CREATE POLICY "Administrators can view all QR scans"
    ON qr_scans
    FOR SELECT
    USING (is_admin_user()); 

    -- Autoriser les insertions anonymes dans la table orders
  CREATE POLICY "Allow anonymous order creation" 
  ON public.orders FOR INSERT 
  TO anon
  WITH CHECK (true);

  -- Autoriser les insertions anonymes dans la table order_items
  CREATE POLICY "Allow anonymous order_item creation" 
  ON public.order_items FOR INSERT 
  TO anon
  WITH CHECK (true);

  -- Politiques spéciales pour l'inscription des utilisateurs
  CREATE POLICY "Allow user registration" ON users 
  FOR INSERT WITH CHECK (true);

  CREATE POLICY "Users can insert establishments" ON establishments 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

  CREATE POLICY "Users can insert staff" ON staff 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

  CREATE POLICY "Users can insert categories" ON categories 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

  CREATE POLICY "Users can insert products" ON products 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

  CREATE POLICY "Users can insert QR codes" ON qr_codes 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

  -- Réactiver RLS sur toutes les tables
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
  ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
  ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
  ALTER TABLE products ENABLE ROW LEVEL SECURITY;
  ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
  ALTER TABLE qr_scans ENABLE ROW LEVEL SECURITY;
  ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
  ALTER TABLE staff_activity_logs ENABLE ROW LEVEL SECURITY;
  ALTER TABLE establishment_types ENABLE ROW LEVEL SECURITY;

  -- Vérification finale
  DO $$
  BEGIN
    RAISE NOTICE '🔒 POLITIQUES RLS CRÉÉES AVEC SUCCÈS !';
    RAISE NOTICE '📋 Prochaine étape : Exécuter trigger.sql pour créer les fonctions et triggers.';
  END $$;