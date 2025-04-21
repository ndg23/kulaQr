-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
  currency TEXT DEFAULT 'EUR'
);

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  order_number INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(establishment_id, name)
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
  UNIQUE(category_id, name)
);

-- Tables QR codes
CREATE TABLE qr_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER NOT NULL,
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

CREATE POLICY "Users can insert their own establishments" ON establishments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own establishments" ON establishments
  FOR UPDATE USING (auth.uid() = user_id);

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