    ------------------------------------------
    -- Nettoyage initial des objets existants
    ------------------------------------------
    DO $$ 
    BEGIN
    -- Suppression des vues
    DROP VIEW IF EXISTS admin_statistics CASCADE;
    DROP VIEW IF EXISTS monthly_growth_stats CASCADE;
    DROP VIEW IF EXISTS popular_restaurants CASCADE;
    DROP VIEW IF EXISTS recent_activity CASCADE;

    -- Suppression des triggers
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
        DROP TRIGGER IF EXISTS update_users_updated_at ON users;
        DROP TRIGGER IF EXISTS subscription_validity_trigger ON users;
    END IF;

    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'establishments') THEN
        DROP TRIGGER IF EXISTS update_establishments_updated_at ON establishments CASCADE;
        DROP TRIGGER IF EXISTS establishment_slug_trigger ON establishments CASCADE;
        DROP TRIGGER IF EXISTS establishment_cleanup_trigger ON establishments CASCADE;
    END IF;

    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'products') THEN
        DROP TRIGGER IF EXISTS products_count_trigger ON products CASCADE;
        DROP TRIGGER IF EXISTS check_product_limits ON products CASCADE;
    END IF;

    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'categories') THEN
        DROP TRIGGER IF EXISTS check_category_limits ON categories CASCADE;
    END IF;

    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'staff') THEN
        DROP TRIGGER IF EXISTS update_staff_updated_at ON staff;
        DROP TRIGGER IF EXISTS log_staff_activity ON staff;
    END IF;

    -- Suppression des policies
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'establishments') THEN
        DROP POLICY IF EXISTS "Public establishments are viewable by everyone" ON establishments CASCADE;
        DROP POLICY IF EXISTS "Users can update their own establishments" ON establishments CASCADE;
        DROP POLICY IF EXISTS "Admin users can manage all establishments" ON establishments CASCADE;
    END IF;

    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'staff') THEN
        DROP POLICY IF EXISTS "Staff members are viewable by establishment owners" ON staff;
        DROP POLICY IF EXISTS "Users can manage their establishment staff" ON staff;
    END IF;

    -- Suppression des fonctions (après avoir supprimé les triggers qui en dépendent)
    DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
    DROP FUNCTION IF EXISTS update_category_product_count() CASCADE;
    DROP FUNCTION IF EXISTS check_subscription_limits() CASCADE;
    DROP FUNCTION IF EXISTS generate_establishment_slug() CASCADE;
    DROP FUNCTION IF EXISTS update_last_login() CASCADE;
    DROP FUNCTION IF EXISTS check_subscription_validity() CASCADE;
    DROP FUNCTION IF EXISTS cleanup_related_data() CASCADE;
    DROP FUNCTION IF EXISTS generate_random_pin() CASCADE;
    DROP FUNCTION IF EXISTS create_staff_pin() CASCADE;
    DROP FUNCTION IF EXISTS regenerate_staff_pin() CASCADE;
    DROP FUNCTION IF EXISTS log_staff_activity() CASCADE;
    DROP FUNCTION IF EXISTS get_popular_restaurants() CASCADE;
    DROP FUNCTION IF EXISTS get_order_stats() CASCADE;
    END $$;

    -- Suppression des tables dans l'ordre pour respecter les contraintes de clé étrangère
    DROP TABLE IF EXISTS qr_scans CASCADE;
    DROP TABLE IF EXISTS qr_codes CASCADE;
    DROP TABLE IF EXISTS products CASCADE;
    DROP TABLE IF EXISTS categories CASCADE;
    DROP TABLE IF EXISTS staff CASCADE;
    DROP TABLE IF EXISTS establishments CASCADE;
    DROP TABLE IF EXISTS establishment_types CASCADE;
    DROP TABLE IF EXISTS users CASCADE;

    -- Suppression des extensions

    ------------------------------------------
    -- Extensions
    ------------------------------------------

    ------------------------------------------
    -- Tables principales
    ------------------------------------------

    -- Users table
    CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    full_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'owner',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    subscription_tier TEXT DEFAULT 'free',
    subscription_ends_at TIMESTAMP WITH TIME ZONE
    );

    -- Types d'établissements
    CREATE TABLE establishment_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT,
    description TEXT,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Establishments table
    CREATE TABLE establishments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    address TEXT,
    phone TEXT,
    opening_hours TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_by UUID REFERENCES auth.users(id),
    owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    type_id UUID REFERENCES establishment_types(id),
    is_active BOOLEAN DEFAULT TRUE,
    currency TEXT DEFAULT 'XOF',
    subscription_type TEXT DEFAULT 'basic',
    max_categories INTEGER DEFAULT 5,
    max_products INTEGER DEFAULT 20,
    custom_domain TEXT,
    theme_settings JSONB DEFAULT '{}',
    analytics_enabled BOOLEAN DEFAULT FALSE,
    qr_prefix TEXT
    );

    -- Staff table
    CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    pin VARCHAR(6) NOT NULL,
    role TEXT DEFAULT 'server',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    UNIQUE(establishment_id, username)
    );

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
    product_count INTEGER DEFAULT 0,
    UNIQUE(establishment_id, name)
    );

    -- Products table
    CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    order_number INTEGER NOT NULL DEFAULT 0,
    allergens TEXT[],
    UNIQUE(category_id, name)
    );

    -- QR codes table
    CREATE TABLE qr_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_number INTEGER DEFAULT 0,
    UNIQUE(establishment_id, table_number)
    );

    -- QR scans tracking
    CREATE TABLE qr_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    establishment_id UUID REFERENCES establishments(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET,
    referrer TEXT
    );

    CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  table_number INTEGER,
  status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  payment_status VARCHAR(50) DEFAULT 'unpaid', -- 'unpaid', 'paid'
  payment_method VARCHAR(50),
  notes TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  rating_comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for order items
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);



CREATE TABLE IF NOT EXISTS staff_activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  details JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_staff_id ON staff_activity_logs(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_establishment_id ON staff_activity_logs(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_created_at ON staff_activity_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_action ON staff_activity_logs(action);

    ------------------------------------------
    -- Fonctions
    ------------------------------------------

    -- Fonction pour updated_at
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    -- Fonction pour le comptage des produits
    CREATE OR REPLACE FUNCTION update_category_product_count()
    RETURNS TRIGGER AS $$
    BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE categories 
        SET product_count = product_count + 1
        WHERE id = NEW.category_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE categories 
        SET product_count = product_count - 1
        WHERE id = OLD.category_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.category_id != OLD.category_id THEN
        UPDATE categories 
        SET product_count = product_count - 1
        WHERE id = OLD.category_id;
        UPDATE categories 
        SET product_count = product_count + 1
        WHERE id = NEW.category_id;
    END IF;
    RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;




-- Fonction pour générer un slug à partir du nom de l'établissement
CREATE OR REPLACE FUNCTION generate_establishment_slug()
RETURNS TRIGGER AS $$
DECLARE
  base_slug TEXT;
  new_slug TEXT;
  counter INTEGER := 1;
BEGIN
  -- Convertir le nom en slug (minuscules, remplacer espaces par tirets, enlever caractères spéciaux)
  base_slug := LOWER(REGEXP_REPLACE(NEW.name, '[^\w\s-]', '', 'g'));
  base_slug := REGEXP_REPLACE(base_slug, '\s+', '-', 'g');
  
  -- Essayer d'utiliser le slug de base
  new_slug := base_slug;
  
  -- Si le slug existe déjà, ajouter un nombre à la fin
  WHILE EXISTS (SELECT 1 FROM establishments WHERE slug = new_slug AND id != NEW.id) LOOP
    new_slug := base_slug || '-' || counter;
    counter := counter + 1;
  END LOOP;
  
  NEW.slug := new_slug;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour générer automatiquement le slug
CREATE TRIGGER establishment_slug_trigger
BEFORE INSERT OR UPDATE OF name ON establishments
FOR EACH ROW
WHEN (NEW.slug IS NULL OR OLD.name != NEW.name)
EXECUTE FUNCTION generate_establishment_slug();