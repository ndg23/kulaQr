-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Restaurants table (établissements)
CREATE TABLE establishments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  address TEXT,
  phone TEXT,
  opening_hours TEXT,
  rating DECIMAL(2,1) DEFAULT 4.5,
  review_count INTEGER DEFAULT 0,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT TRUE
);

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  order_number INTEGER NOT NULL DEFAULT 0
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
  order_number INTEGER NOT NULL DEFAULT 0
);

-- Orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER,
  status TEXT NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(10,2) NOT NULL
);

-- Order items table
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL
);

-- QR codes table
CREATE TABLE qr_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER,
  scan_count INTEGER NOT NULL DEFAULT 0
);

-- Row Level Security Policies
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
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

-- Orders policies
CREATE POLICY "Orders are viewable by establishment owners" ON orders
  FOR SELECT USING (
    auth.uid() IN (
      SELECT user_id FROM establishments 
      WHERE id = orders.establishment_id
    )
  );

CREATE POLICY "Anyone can create orders" ON orders
  FOR INSERT WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX idx_categories_establishment ON categories(establishment_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_establishment ON orders(establishment_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);