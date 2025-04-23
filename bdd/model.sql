-- Vérifier si les tables existent avant de supprimer les triggers
DO $$ 
BEGIN
  -- Suppression des triggers seulement si les tables existent
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    DROP TRIGGER IF EXISTS update_users_updated_at ON users;
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'establishments') THEN
    DROP TRIGGER IF EXISTS update_establishments_updated_at ON establishments;
    DROP TRIGGER IF EXISTS establishment_slug_trigger ON establishments;
    DROP TRIGGER IF EXISTS establishment_cleanup_trigger ON establishments;
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'products') THEN
    DROP TRIGGER IF EXISTS products_count_trigger ON products;
    DROP TRIGGER IF EXISTS check_product_limits ON products;
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'categories') THEN
    DROP TRIGGER IF EXISTS check_category_limits ON categories;
  END IF;

  -- Suppression des policies si les tables existent
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'establishments') THEN
    DROP POLICY IF EXISTS "Public establishments are viewable by everyone" ON establishments;
    DROP POLICY IF EXISTS "Users can update their own establishments" ON establishments;
    DROP POLICY IF EXISTS "Admin users can manage all establishments" ON establishments;
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'categories') THEN
    DROP POLICY IF EXISTS "Categories are viewable by everyone" ON categories;
    DROP POLICY IF EXISTS "Users can manage their establishment categories" ON categories;
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'products') THEN
    DROP POLICY IF EXISTS "Products are viewable by everyone" ON products;
    DROP POLICY IF EXISTS "Users can manage their establishment products" ON products;
  END IF;
END $$;

-- Suppression des fonctions
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS update_category_product_count();
DROP FUNCTION IF EXISTS check_subscription_limits();
DROP FUNCTION IF EXISTS generate_establishment_slug();
DROP FUNCTION IF EXISTS update_last_login();
DROP FUNCTION IF EXISTS check_subscription_validity();
DROP FUNCTION IF EXISTS cleanup_related_data();

-- Suppression des tables dans l'ordre pour respecter les contraintes de clé étrangère
DROP TABLE IF EXISTS qr_codes;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS establishments;
DROP TABLE IF EXISTS users;

-- Suppression des extensions
DROP EXTENSION IF EXISTS "uuid-ossp";

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (informations supplémentaires pour les utilisateurs)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  full_name TEXT,
  phone TEXT,
  role TEXT DEFAULT 'owner',  -- 'owner', 'manager', 'staff', etc.
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMP WITH TIME ZONE,
  subscription_tier TEXT DEFAULT 'free',  -- 'free', 'premium', 'enterprise'
  subscription_ends_at TIMESTAMP WITH TIME ZONE
);

-- Trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Types d'établissements
CREATE TABLE establishment_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  icon TEXT,  -- Nom de l'icône Lucide
  description TEXT,
  features JSONB DEFAULT '{}',  -- Fonctionnalités spécifiques au type
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Restaurants table (établissements)
CREATE TABLE establishments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,  -- Pour les URLs
  description TEXT,
  image_url TEXT,
  address TEXT,
  phone TEXT,
  opening_hours TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT TRUE,
  currency TEXT DEFAULT 'XOF',
  subscription_type TEXT DEFAULT 'basic',
  max_categories INTEGER DEFAULT 5,
  max_products INTEGER DEFAULT 20,
  custom_domain TEXT,
  theme_settings JSONB DEFAULT '{}',
  analytics_enabled BOOLEAN DEFAULT FALSE,
  qr_prefix TEXT,
  created_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  type_id UUID REFERENCES establishment_types(id)
);

-- Trigger pour establishments updated_at
CREATE TRIGGER update_establishments_updated_at
BEFORE UPDATE ON establishments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  order_number INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(establishment_id, name),
  product_count INTEGER DEFAULT 0
);

-- Products table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT TRUE,
  order_number INTEGER NOT NULL DEFAULT 0,
  allergens TEXT[],  -- Information importante pour les clients
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  UNIQUE(category_id, name)
);

-- Tables QR codes
CREATE TABLE qr_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER DEFAULT 0,
  UNIQUE(establishment_id, table_number)
);

-- Row Level Security Policies
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;

-- Establishments policies
CREATE POLICY "Public establishments are viewable by everyone" ON establishments
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own establishments" 
ON establishments FOR UPDATE 
USING (auth.uid() = created_by);

CREATE POLICY "Admin users can manage all establishments" 
ON establishments FOR ALL 
USING (
  auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  )
);

-- Categories policies
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (true);

CREATE POLICY "Users can manage their establishment categories" ON categories
  FOR ALL USING (
    auth.uid() IN (
      SELECT user_id FROM establishments 
      WHERE id = categories.establishment_id
    )
  );

-- Products policies
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

CREATE POLICY "Users can manage their establishment products" ON products
  FOR ALL USING (
    auth.uid() IN (
      SELECT e.user_id 
      FROM establishments e
      JOIN categories c ON c.establishment_id = e.id
      WHERE c.id = products.category_id
    )
  );

-- Create indexes for better performance
CREATE INDEX idx_categories_establishment ON categories(establishment_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_establishments_created_by ON establishments(created_by);
CREATE INDEX idx_establishments_subscription_type ON establishments(subscription_type);
-- Allow authenticated users to upload images
CREATE POLICY "Allow authenticated uploads" 
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'images');

-- Allow public access to read images
CREATE POLICY "Allow public read access" 
ON storage.objects 
FOR SELECT 
TO public 
USING (bucket_id = 'images');

-- Insérer les types par défaut
INSERT INTO establishment_types (name, slug, icon, description) VALUES
  ('Restaurant traditionnel', 'restaurant', 'UtensilsCrossed', 'Restaurant avec service à table'),
  ('Fast-food', 'fast-food', 'Pizza', 'Restauration rapide'),
  ('Café', 'cafe', 'Coffee', 'Café et salon de thé'),
  ('Bar', 'bar', 'Wine', 'Bar et débit de boissons'),
  ('Bistrot', 'bistrot', 'Beer', 'Bistrot et brasserie'),
  ('Food truck', 'food-truck', 'Truck', 'Restaurant mobile'),
  ('Traiteur', 'traiteur', 'ChefHat', 'Service de traiteur'),
  ('Pâtisserie', 'patisserie', 'Cake', 'Pâtisserie et boulangerie');
