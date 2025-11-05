-- ==========================================
-- KULA QR - COMPLETE DATABASE SCHEMA
-- ==========================================
-- This file contains the complete database structure
-- Execute in Supabase SQL Editor

-- ==========================================
-- CLEANUP EXISTING STRUCTURE
-- ==========================================
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all policies
    FOR r IN (SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON %I.%I CASCADE', r.policyname, r.schemaname, r.tablename);
    END LOOP;
    
    -- Drop all triggers
    FOR r IN (SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_schema = 'public') LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', r.trigger_name, r.event_object_table);
    END LOOP;
    
    -- Drop all functions
    FOR r IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS %I() CASCADE', r.routine_name);
    END LOOP;
END $$;

-- Disable RLS temporarily
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS products DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_codes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_scans DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS restaurant_tables DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff_activity_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishment_types DISABLE ROW LEVEL SECURITY;

-- Drop tables in correct order
DROP TABLE IF EXISTS staff_activity_logs CASCADE;
DROP TABLE IF EXISTS restaurant_tables CASCADE;
DROP TABLE IF EXISTS qr_scans CASCADE;
DROP TABLE IF EXISTS qr_codes CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS establishments CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS establishment_types CASCADE;

-- Drop views
DROP VIEW IF EXISTS admin_statistics CASCADE;
DROP VIEW IF EXISTS monthly_growth_stats CASCADE;
DROP VIEW IF EXISTS popular_restaurants CASCADE;
DROP VIEW IF EXISTS recent_activity CASCADE;
DROP VIEW IF EXISTS popular_establishments CASCADE;
DROP VIEW IF EXISTS staff_activity CASCADE;
DROP VIEW IF EXISTS order_statistics CASCADE;
DROP VIEW IF EXISTS qr_code_analytics CASCADE;
DROP VIEW IF EXISTS dashboard_stats CASCADE;
DROP VIEW IF EXISTS table_statistics CASCADE;

-- ==========================================
-- CORE TABLES
-- ==========================================

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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    order_number INTEGER NOT NULL DEFAULT 0,
    orders_count INTEGER DEFAULT 0,
    allergens TEXT[],
    UNIQUE(category_id, name)
);

-- Restaurant Tables
-- CREATE TABLE restaurant_tables (
--     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--     establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
--     table_number VARCHAR(10) NOT NULL,
--     capacity INT,
--     status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
--     qr_code_id UUID,
--     location_description TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     created_by UUID REFERENCES auth.users(id),
--     is_active BOOLEAN DEFAULT true,
--     UNIQUE(establishment_id, table_number)
-- );

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_id UUID REFERENCES tables(id),
    table_number INTEGER,
    staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'completed', 'cancelled')),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(50) DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    rating_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- QR codes table
CREATE TABLE qr_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_number INTEGER DEFAULT 0,
    UNIQUE(establishment_id, table_number)
);

-- QR scans tracking
CREATE TABLE qr_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id),
    table_number INTEGER,
    session_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET,
    referrer TEXT
);

-- Staff activity logs
CREATE TABLE staff_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- Establishments indexes
CREATE INDEX IF NOT EXISTS idx_establishments_user_id ON establishments(user_id);
CREATE INDEX IF NOT EXISTS idx_establishments_slug ON establishments(slug);
CREATE INDEX IF NOT EXISTS idx_establishments_active ON establishments(is_active);
CREATE INDEX IF NOT EXISTS idx_establishments_type_id ON establishments(type_id);

-- Staff indexes
CREATE INDEX IF NOT EXISTS idx_staff_establishment_id ON staff(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_establishment_id ON categories(establishment_id);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);

-- Products indexes
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_establishment_id ON products(establishment_id);
CREATE INDEX IF NOT EXISTS idx_products_available ON products(is_available);

-- Tables indexes
CREATE INDEX IF NOT EXISTS idx_restaurant_tables_establishment ON restaurant_tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_tables_status ON restaurant_tables(status);

-- Orders indexes
CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_id ON orders(table_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_number ON orders(table_number);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_staff_id ON orders(staff_id);

-- Order items indexes
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- QR codes indexes
CREATE INDEX IF NOT EXISTS idx_qr_codes_establishment_id ON qr_codes(establishment_id);

-- QR scans indexes
CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_session_id ON qr_scans(session_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at);

-- Staff activity indexes
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_staff_id ON staff_activity_logs(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_establishment_id ON staff_activity_logs(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_created_at ON staff_activity_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_action ON staff_activity_logs(action);

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================

-- Admin user check function
CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID DEFAULT auth.uid()) 
RETURNS BOOLEAN 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Ajouter une vérification rapide pour éviter des requêtes inutiles
    IF user_uuid IS NULL THEN
        RETURN FALSE;
    END IF;
    
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = user_uuid AND role = 'admin'
    );
END;
$$;

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generate establishment slug function
CREATE OR REPLACE FUNCTION generate_establishment_slug()
RETURNS TRIGGER AS $$
DECLARE
    base_slug TEXT;
    new_slug TEXT;
    counter INTEGER := 1;
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        base_slug := LOWER(REGEXP_REPLACE(NEW.name, '[^\w\s-]', '', 'g'));
        base_slug := REGEXP_REPLACE(base_slug, '\s+', '-', 'g');
        new_slug := base_slug;
        
        WHILE EXISTS (SELECT 1 FROM establishments WHERE slug = new_slug AND id != NEW.id) LOOP
            new_slug := base_slug || '-' || counter;
            counter := counter + 1;
        END LOOP;
        
        NEW.slug := new_slug;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update product count function
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

-- Update table status on order function
CREATE OR REPLACE FUNCTION update_table_status_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.table_id IS NOT NULL THEN
        UPDATE restaurant_tables
        SET status = 'occupied'
        WHERE id = NEW.table_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND NEW.table_id IS NOT NULL THEN
        UPDATE restaurant_tables
        SET status = 'available'
        WHERE id = NEW.table_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Updated_at triggers
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER establishments_updated_at
    BEFORE UPDATE ON establishments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER restaurant_tables_updated_at
    BEFORE UPDATE ON restaurant_tables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Slug generation trigger
CREATE TRIGGER establishment_slug_trigger
    BEFORE INSERT OR UPDATE ON establishments
    FOR EACH ROW
    EXECUTE FUNCTION generate_establishment_slug();

-- Product count trigger
CREATE TRIGGER products_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_category_product_count();

-- Table status trigger
CREATE TRIGGER update_table_status_trigger
    AFTER INSERT OR UPDATE OF status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_table_status_on_order();

-- ==========================================
-- ROW LEVEL SECURITY POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishment_types ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow user registration" ON users 
    FOR INSERT WITH CHECK (true);

-- Establishments policies
CREATE POLICY "Public establishments are viewable by everyone" ON establishments
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can manage their own establishments" ON establishments
    FOR ALL USING (
        auth.uid() = created_by OR 
        auth.uid() = owner_id OR 
        auth.uid() = user_id OR
        is_admin_user()
    );

CREATE POLICY "Users can insert establishments" ON establishments 
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Staff policies
-- Remplacer la politique actuelle par celle-ci
CREATE POLICY "Staff viewable by establishment owners" ON staff
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM establishments 
            WHERE id = staff.establishment_id AND user_id = auth.uid()
        ) OR is_admin_user()
    );

-- Politique unifiée pour la gestion du staff
CREATE OR REPLACE POLICY "Staff management policy" ON staff
    FOR ALL USING (
        -- Les propriétaires d'établissement peuvent gérer leur staff
        EXISTS (
            SELECT 1 FROM establishments 
            WHERE id = staff.establishment_id AND user_id = auth.uid()
        ) OR
        -- Les admins peuvent tout gérer
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- Categories policies
CREATE POLICY "Categories are viewable by everyone" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Categories manageable by establishment owners" ON categories
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = categories.establishment_id
        ) OR is_admin_user()
    );

-- Products policies
CREATE POLICY "Products are viewable by everyone" ON products
    FOR SELECT USING (true);

CREATE POLICY "Products manageable by establishment owners" ON products
    FOR ALL USING (
        auth.uid() IN (
            SELECT e.user_id FROM establishments e
            JOIN categories c ON c.establishment_id = e.id
            WHERE c.id = products.category_id
        ) OR is_admin_user()
    );

-- Restaurant tables policies
CREATE POLICY "Tables viewable by establishment staff" ON restaurant_tables
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = restaurant_tables.establishment_id
        ) OR
        auth.uid() IN (
            SELECT id FROM staff WHERE establishment_id = restaurant_tables.establishment_id
        ) OR
        is_admin_user()
    );

CREATE POLICY "Tables manageable by establishment owners" ON restaurant_tables
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = restaurant_tables.establishment_id
        ) OR is_admin_user()
    );

-- Orders policies
CREATE POLICY "Orders viewable by establishment owners" ON orders
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = orders.establishment_id
        ) OR is_admin_user()
    );

CREATE POLICY "Allow anonymous order creation" ON orders
    FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Orders manageable by establishment staff" ON orders
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = orders.establishment_id
        ) OR
        auth.uid() IN (
            SELECT id FROM staff WHERE establishment_id = orders.establishment_id
        ) OR
        is_admin_user()
    );

-- Order items policies
CREATE POLICY "Order items viewable with orders" ON order_items
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders WHERE
            auth.uid() IN (
                SELECT user_id FROM establishments WHERE id = orders.establishment_id
            ) OR is_admin_user()
        )
    );

CREATE POLICY "Allow anonymous order_item creation" ON order_items
    FOR INSERT TO anon WITH CHECK (true);

-- QR codes policies
CREATE POLICY "QR codes manageable by establishment owners" ON qr_codes
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = qr_codes.establishment_id
        ) OR is_admin_user()
    );

-- QR scans policies
CREATE POLICY "QR scans viewable by establishment owners" ON qr_scans
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = qr_scans.establishment_id
        ) OR is_admin_user()
    );

CREATE POLICY "Allow anonymous QR scan tracking" ON qr_scans
    FOR INSERT WITH CHECK (true);

-- Staff activity logs policies
CREATE POLICY "Activity logs viewable by establishment owners" ON staff_activity_logs
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = staff_activity_logs.establishment_id
        ) OR is_admin_user()
    );

-- Establishment types policies (public read-only)
CREATE POLICY "Establishment types are publicly viewable" ON establishment_types
    FOR SELECT USING (is_active = true);

-- Admin policies (override all others)
CREATE POLICY "Admins can manage everything - users" ON users
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - establishments" ON establishments
    FOR ALL USING (is_admin_user());

-- Politique supprimée pour éviter la récursion infinie

CREATE POLICY "Admins can manage everything - categories" ON categories
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - products" ON products
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - tables" ON restaurant_tables
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - orders" ON orders
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - qr_codes" ON qr_codes
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - establishment_types" ON establishment_types
    FOR ALL USING (is_admin_user());

-- ==========================================
-- ESSENTIAL VIEWS
-- ==========================================

-- Dashboard statistics view
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT
    establishment_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    COUNT(DISTINCT table_number) AS tables_served,
    EXTRACT(HOUR FROM created_at) AS hour_of_day
FROM orders
WHERE created_at >= CURRENT_DATE
GROUP BY establishment_id, EXTRACT(HOUR FROM created_at);

-- Popular establishments view
CREATE OR REPLACE VIEW popular_establishments AS
SELECT 
    e.id,
    e.name,
    e.description,
    e.image_url,
    e.slug,
    COUNT(DISTINCT o.id) as order_count,
    COUNT(qs.id) as scan_count,
    COALESCE(AVG(o.rating), 4.5) as avg_rating,
    COUNT(DISTINCT p.id) as product_count,
    COUNT(DISTINCT c.id) as category_count
FROM establishments e
LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
LEFT JOIN orders o ON o.establishment_id = e.id
LEFT JOIN categories c ON c.establishment_id = e.id
LEFT JOIN products p ON p.establishment_id = e.id
WHERE e.is_active = true
GROUP BY e.id, e.name, e.description, e.image_url, e.slug
ORDER BY order_count DESC, scan_count DESC;

-- Table statistics view
CREATE OR REPLACE VIEW table_statistics AS
SELECT 
    rt.id AS table_id,
    rt.table_number,
    rt.establishment_id,
    rt.status,
    COUNT(o.id) AS total_orders,
    COUNT(CASE WHEN o.created_at >= CURRENT_DATE THEN 1 END) AS today_orders,
    MAX(o.created_at) AS last_order_date,
    ROUND(AVG(o.total_amount)::numeric, 2) AS average_order_amount
FROM restaurant_tables rt
LEFT JOIN orders o ON o.table_id = rt.id
GROUP BY rt.id, rt.table_number, rt.establishment_id, rt.status;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '🎉 DATABASE SCHEMA CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Tables: %, Functions: %, Views: %', 
        (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public'),
        (SELECT COUNT(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')),
        (SELECT COUNT(*) FROM pg_views WHERE schemaname = 'public');
    RAISE NOTICE '🔒 Row Level Security enabled on all tables';
    RAISE NOTICE '✅ Ready for use!';
END $$;
