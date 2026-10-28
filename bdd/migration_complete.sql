-- ==========================================================================
-- KULA QR - MIGRATION COMPLETE
-- ==========================================================================
-- A executer UNE FOIS sur une base Supabase vide (SQL Editor > New query > Run).
-- Tout s'execute dans une transaction : en cas d'erreur, rien n'est applique.
--
-- Remplace, dans cet ordre : schema.sql, tables.sql, settings.sql, trigger_auth.sql,
-- qr_support_requests.sql, staff.sql, activity_tracking.sql, views.sql,
-- dashboard_views.sql, subscription_auto_block_corrected.sql,
-- dashboard_kpi_functions_manual.sql, migration_secure_order_creation.sql,
-- migration_auto_payment_on_completed.sql, migration_add_session_id_to_qr_scans.sql,
-- migration_add_staff_to_orders.sql, migrations/add_coordinates_columns.sql.
--
-- Sections :
--   1. Schema de base (tables, index, triggers, RLS, buckets de stockage)
--   2. Fonctionnalites (support QR, PIN staff, activites, vues, abonnements, KPI)
--   3. Durcissement securite
-- ==========================================================================

BEGIN;

-- ##########################################################################
-- 1. SCHEMA DE BASE
-- ##########################################################################
-- KULA QR - SCHEMA DE BASE (tables, index, triggers, RLS)
-- ==========================================
-- Base vide uniquement : ce fichier ne supprime rien.
-- Remplace schema.sql + tables.sql + settings.sql + trigger_auth.sql
-- + migration_add_session_id_to_qr_scans.sql + migration_add_staff_to_orders.sql
-- + add_coordinates_columns.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ==========================================
-- TABLES
-- ==========================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    email TEXT,
    full_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'owner',
    status TEXT DEFAULT 'active',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    subscription_tier TEXT DEFAULT 'free',
    subscription_status TEXT DEFAULT 'active',
    subscription_starts_at TIMESTAMP WITH TIME ZONE,
    subscription_ends_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS establishment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT,
    description TEXT,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS establishments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    name TEXT NOT NULL,
    -- NULL accepte : le trigger generate_establishment_slug le remplit
    slug TEXT UNIQUE,
    description TEXT,
    image_url TEXT,
    address TEXT,
    longitude DECIMAL(11, 8),
    latitude DECIMAL(10, 8),
    phone TEXT,
    email TEXT,
    opening_hours TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_by UUID REFERENCES auth.users(id),
    owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    -- Le code utilise les deux noms
    type_id UUID REFERENCES establishment_types(id),
    establishment_type_id UUID REFERENCES establishment_types(id),
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

CREATE TABLE IF NOT EXISTS staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    full_name TEXT,
    email TEXT,
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    pin VARCHAR(6) NOT NULL,
    role TEXT DEFAULT 'staff' CHECK (role IN ('manager', 'staff', 'waiter', 'kitchen')),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    UNIQUE(establishment_id, username)
);

CREATE TABLE IF NOT EXISTS categories (
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

CREATE TABLE IF NOT EXISTS products (
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

-- Tables physiques du restaurant (remplace restaurant_tables)
CREATE TABLE IF NOT EXISTS tables (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    table_number VARCHAR(10) NOT NULL,
    capacity INT,
    type VARCHAR(20) DEFAULT 'SIMPLE' CHECK (type IN ('VIP', 'SIMPLE', 'STANDARD')),
    section_name VARCHAR(100) DEFAULT 'ETAGE',
    floor_level VARCHAR(50),
    location_description TEXT,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
    is_active BOOLEAN DEFAULT true,
    qr_code_url TEXT,
    qr_code_id UUID,
    qr_code_generated BOOLEAN DEFAULT false,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    UNIQUE(establishment_id, table_number)
);

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_id UUID REFERENCES tables(id) ON DELETE SET NULL,
    table_number INTEGER,
    staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'processing', 'ready', 'delivered', 'completed', 'cancelled')),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(50) DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    rating_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS qr_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_number INTEGER DEFAULT 0,
    UNIQUE(establishment_id, table_number)
);

CREATE TABLE IF NOT EXISTS qr_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_number INTEGER,
    session_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address TEXT,
    referrer TEXT
);

CREATE TABLE IF NOT EXISTS staff_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT
);

CREATE TABLE IF NOT EXISTS system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- INDEX
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE INDEX IF NOT EXISTS idx_establishments_user_id ON establishments(user_id);
CREATE INDEX IF NOT EXISTS idx_establishments_active ON establishments(is_active);
CREATE INDEX IF NOT EXISTS idx_establishments_type_id ON establishments(type_id);

CREATE INDEX IF NOT EXISTS idx_staff_establishment_id ON staff(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);

CREATE INDEX IF NOT EXISTS idx_categories_establishment_id ON categories(establishment_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_establishment_id ON products(establishment_id);

CREATE INDEX IF NOT EXISTS idx_tables_establishment_id ON tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_tables_status ON tables(status);

CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_id ON orders(table_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_staff_id ON orders(staff_id);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_qr_codes_establishment_id ON qr_codes(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_session_id ON qr_scans(session_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at);
CREATE INDEX IF NOT EXISTS idx_qr_scans_ip_created ON qr_scans(ip_address, created_at);

CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_staff_id ON staff_activity_logs(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_establishment_id ON staff_activity_logs(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_created_at ON staff_activity_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_system_settings_category ON system_settings(category);

-- ==========================================
-- FONCTIONS DE BASE
-- ==========================================

CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF user_uuid IS NULL THEN
        RETURN FALSE;
    END IF;
    RETURN EXISTS (SELECT 1 FROM users WHERE id = user_uuid AND role = 'admin');
END;
$$;

-- Bloque l'appel sauf pour : cle service_role, admin connecte, ou acces direct a la base (cron, SQL Editor)
CREATE OR REPLACE FUNCTION assert_admin()
RETURNS VOID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF COALESCE(auth.role(), '') = 'service_role'
       OR session_user NOT IN ('authenticator', 'anon', 'authenticated')
       OR is_admin_user() THEN
        RETURN;
    END IF;
    RAISE EXCEPTION 'Acces reserve aux administrateurs' USING ERRCODE = '42501';
END;
$$;

-- Bloque l'appel sauf pour le proprietaire de l'etablissement ou un admin
CREATE OR REPLACE FUNCTION assert_establishment_access(est_id UUID)
RETURNS VOID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF COALESCE(auth.role(), '') = 'service_role'
       OR session_user NOT IN ('authenticator', 'anon', 'authenticated')
       OR is_admin_user()
       OR EXISTS (SELECT 1 FROM establishments WHERE id = est_id AND auth.uid() IN (user_id, owner_id, created_by)) THEN
        RETURN;
    END IF;
    RAISE EXCEPTION 'Acces refuse a cet etablissement' USING ERRCODE = '42501';
END;
$$;

-- Vrai si l'utilisateur courant possede l'etablissement (SECURITY DEFINER : evite la recursion RLS)
CREATE OR REPLACE FUNCTION owns_establishment(est_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM establishments
        WHERE id = est_id
          AND auth.uid() IN (user_id, owner_id, created_by)
    );
$$;

-- Vrai si l'etablissement est actif et son proprietaire aussi (SECURITY DEFINER : anon ne lit pas users)
CREATE OR REPLACE FUNCTION establishment_accepts_orders(est_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM establishments e
        JOIN users u ON u.id = e.user_id
        WHERE e.id = est_id AND e.is_active AND u.is_active
    );
$$;

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION update_category_product_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE categories SET product_count = product_count + 1 WHERE id = NEW.category_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE categories SET product_count = product_count - 1 WHERE id = OLD.category_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.category_id IS DISTINCT FROM OLD.category_id THEN
        UPDATE categories SET product_count = product_count - 1 WHERE id = OLD.category_id;
        UPDATE categories SET product_count = product_count + 1 WHERE id = NEW.category_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_table_status_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.table_id IS NOT NULL THEN
        UPDATE tables SET status = 'occupied' WHERE id = NEW.table_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.status IN ('completed', 'cancelled') AND NEW.table_id IS NOT NULL THEN
        UPDATE tables SET status = 'available' WHERE id = NEW.table_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Paiement automatique quand la commande passe a "completed"
CREATE OR REPLACE FUNCTION auto_payment_on_order_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_status = 'unpaid' THEN
        NEW.payment_status := 'paid';
        NEW.payment_method := COALESCE(NEW.payment_method, 'cash');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

DROP TRIGGER IF EXISTS users_updated_at ON users;
CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS establishments_updated_at ON establishments;
CREATE TRIGGER establishments_updated_at BEFORE UPDATE ON establishments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tables_updated_at ON tables;
CREATE TRIGGER tables_updated_at BEFORE UPDATE ON tables
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS orders_updated_at ON orders;
CREATE TRIGGER orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS staff_updated_at ON staff;
CREATE TRIGGER staff_updated_at BEFORE UPDATE ON staff
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS system_settings_updated_at ON system_settings;
CREATE TRIGGER system_settings_updated_at BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS establishment_slug_trigger ON establishments;
CREATE TRIGGER establishment_slug_trigger BEFORE INSERT OR UPDATE ON establishments
    FOR EACH ROW EXECUTE FUNCTION generate_establishment_slug();

DROP TRIGGER IF EXISTS products_count_trigger ON products;
CREATE TRIGGER products_count_trigger AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION update_category_product_count();

DROP TRIGGER IF EXISTS update_table_status_trigger ON orders;
CREATE TRIGGER update_table_status_trigger AFTER INSERT OR UPDATE OF status ON orders
    FOR EACH ROW EXECUTE FUNCTION update_table_status_on_order();

DROP TRIGGER IF EXISTS trigger_auto_payment_on_completed ON orders;
CREATE TRIGGER trigger_auto_payment_on_completed BEFORE UPDATE OF status ON orders
    FOR EACH ROW
    WHEN (NEW.status = 'completed' AND OLD.status IS DISTINCT FROM 'completed')
    EXECUTE FUNCTION auto_payment_on_order_completed();

-- ==========================================
-- PROFIL UTILISATEUR (trigger sur auth.users)
-- ==========================================

-- Meme regle que pages/auth/register.vue et callback.vue :
-- compte demo de 7 jours, inactif jusqu'a activation par un admin
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, phone, role, subscription_tier, is_active, subscription_starts_at, subscription_ends_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            SPLIT_PART(NEW.email, '@', 1),
            'Utilisateur'
        ),
        NEW.raw_user_meta_data->>'phone',
        'owner',
        'demo',
        false,
        NOW(),
        NOW() + INTERVAL '7 days'
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_user_login()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.users SET last_login = NEW.last_sign_in_at WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;
CREATE TRIGGER on_auth_user_login
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    WHEN (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
    EXECUTE FUNCTION public.handle_user_login();

-- ==========================================
-- ROW LEVEL SECURITY
-- ==========================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Users
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id OR is_admin_user());
CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id OR is_admin_user());
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id OR is_admin_user());
CREATE POLICY "Admins can delete users" ON users
    FOR DELETE USING (is_admin_user());

-- Establishment types
CREATE POLICY "Establishment types are publicly viewable" ON establishment_types
    FOR SELECT USING (is_active = true OR is_admin_user());
CREATE POLICY "Admins manage establishment types" ON establishment_types
    FOR ALL USING (is_admin_user()) WITH CHECK (is_admin_user());

-- Establishments
CREATE POLICY "Public establishments are viewable by everyone" ON establishments
    FOR SELECT USING (is_active = true);
CREATE POLICY "Owners manage their establishments" ON establishments
    FOR ALL USING (auth.uid() IN (user_id, owner_id, created_by) OR is_admin_user())
    WITH CHECK (auth.uid() IN (user_id, owner_id, created_by) OR is_admin_user());

-- Staff
CREATE POLICY "Owners manage their staff" ON staff
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- Categories
CREATE POLICY "Categories are viewable by everyone" ON categories
    FOR SELECT USING (true);
CREATE POLICY "Owners manage their categories" ON categories
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- Products
CREATE POLICY "Products are viewable by everyone" ON products
    FOR SELECT USING (true);
CREATE POLICY "Owners manage their products" ON products
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- Tables
CREATE POLICY "Public can view active tables" ON tables
    FOR SELECT USING (is_active = true AND status != 'maintenance');
CREATE POLICY "Owners manage their tables" ON tables
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- Orders : creation seulement pour un etablissement actif dont le proprietaire est actif
CREATE POLICY "Order creation for active establishments only" ON orders
    FOR INSERT TO anon, authenticated
    WITH CHECK (establishment_accepts_orders(establishment_id));
-- Le client (anonyme) relit sa commande apres creation et suit son statut :
-- limite aux commandes de moins de 24h, aucune donnee client n'est stockee dans orders
CREATE POLICY "Clients read recent orders" ON orders
    FOR SELECT TO anon
    USING (created_at > NOW() - INTERVAL '24 hours');
-- Le client peut annuler sa commande tant qu'elle est en attente
CREATE POLICY "Clients cancel pending orders" ON orders
    FOR UPDATE TO anon
    USING (status = 'pending' AND created_at > NOW() - INTERVAL '24 hours')
    WITH CHECK (status = 'cancelled');
CREATE POLICY "Owners manage their orders" ON orders
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- Order items
CREATE POLICY "Order item creation" ON order_items
    FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Owners manage their order items" ON order_items
    FOR ALL USING (
        EXISTS (SELECT 1 FROM orders o WHERE o.id = order_id AND owns_establishment(o.establishment_id))
        OR is_admin_user()
    );

-- QR codes
CREATE POLICY "Owners manage their QR codes" ON qr_codes
    FOR ALL USING (owns_establishment(establishment_id) OR is_admin_user())
    WITH CHECK (owns_establishment(establishment_id) OR is_admin_user());

-- QR scans
CREATE POLICY "Anyone can record a QR scan" ON qr_scans
    FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Owners view their QR scans" ON qr_scans
    FOR SELECT USING (owns_establishment(establishment_id) OR is_admin_user());

-- Staff activity logs
CREATE POLICY "Owners view staff activity logs" ON staff_activity_logs
    FOR SELECT USING (owns_establishment(establishment_id) OR is_admin_user());

-- System settings : admins uniquement
CREATE POLICY "Admins manage system settings" ON system_settings
    FOR ALL USING (is_admin_user()) WITH CHECK (is_admin_user());

-- ==========================================
-- DONNEES INITIALES
-- ==========================================

INSERT INTO system_settings (key, value, description, category) VALUES
    ('smtp', '{"host": "", "port": "587", "username": "", "password": "", "secure": true}', 'Configuration du serveur SMTP', 'email'),
    ('maintenance_mode', 'false', 'Mode maintenance du site', 'system'),
    ('backup', '{"last_backup": null, "auto_backup": false, "frequency": "daily"}', 'Configuration des sauvegardes', 'system'),
    ('security', '{"two_factor_enabled": false, "password_expiry_days": 90, "max_login_attempts": 5}', 'Paramètres de sécurité', 'security'),
    ('cache', '{"last_cleared": null, "auto_clear": false, "frequency": "weekly"}', 'Configuration du cache', 'system'),
    ('app_info', '{"version": "1.5.2", "environment": "production", "last_deployment": null}', 'Informations sur l''application', 'system')
ON CONFLICT (key) DO NOTHING;

-- Buckets de stockage utilises par le code (settings, profil)
INSERT INTO storage.buckets (id, name, public) VALUES
    ('images', 'images', true),
    ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Authenticated users upload images" ON storage.objects;
DROP POLICY IF EXISTS "Owners update their uploads" ON storage.objects;
DROP POLICY IF EXISTS "Owners delete their uploads" ON storage.objects;
CREATE POLICY "Authenticated users upload images" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id IN ('images', 'avatars'));
CREATE POLICY "Owners update their uploads" ON storage.objects
    FOR UPDATE TO authenticated USING (bucket_id IN ('images', 'avatars') AND owner = auth.uid());
CREATE POLICY "Owners delete their uploads" ON storage.objects
    FOR DELETE TO authenticated USING (bucket_id IN ('images', 'avatars') AND owner = auth.uid());

-- ##########################################################################
-- 2. FONCTIONNALITES
-- ##########################################################################
-- KULA QR - FONCTIONNALITES (support QR, PIN staff, activites, vues, abonnements, KPI)
-- ==========================================
-- A executer apres 00_core_schema.sql
-- Assemble depuis les fichiers d'origine de bdd/ (sections dupliquees ou destructives retirees)

-- ##### qr_support_requests.sql #####
-- Check if required tables exist before creating qr_support_requests
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'establishments') THEN
        RAISE EXCEPTION 'Table establishments does not exist. Please run schema.sql first.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') THEN
        RAISE EXCEPTION 'Auth users table does not exist. Please ensure Supabase auth is set up.';
    END IF;
END $$;

-- Create qr_support_requests table
CREATE TABLE qr_support_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Request details
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    request_type TEXT NOT NULL CHECK (request_type IN ('new_qr', 'qr_replacement', 'qr_update', 'qr_deactivation', 'bulk_qr_generation', 'qr_customization', 'technical_issue')),
    table_number INTEGER,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

    -- Status tracking
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled', 'rejected')),
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,

    -- Resolution details
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    resolution_notes TEXT,

    -- Additional metadata
    attachments JSONB DEFAULT '[]', -- Array of file URLs/paths
    internal_notes TEXT,
    estimated_completion TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX idx_qr_support_requests_establishment_id ON qr_support_requests(establishment_id);
CREATE INDEX idx_qr_support_requests_requested_by ON qr_support_requests(requested_by);
CREATE INDEX idx_qr_support_requests_status ON qr_support_requests(status);
CREATE INDEX idx_qr_support_requests_priority ON qr_support_requests(priority);
CREATE INDEX idx_qr_support_requests_created_at ON qr_support_requests(created_at);
CREATE INDEX idx_qr_support_requests_assigned_to ON qr_support_requests(assigned_to);

-- Create updated_at trigger
CREATE TRIGGER qr_support_requests_updated_at
    BEFORE UPDATE ON qr_support_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create function to update resolved_at automatically
CREATE OR REPLACE FUNCTION update_qr_support_request_resolution()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('completed', 'cancelled', 'rejected') AND OLD.status NOT IN ('completed', 'cancelled', 'rejected') THEN
        NEW.resolved_at = CURRENT_TIMESTAMP;
        NEW.resolved_by = auth.uid();
    ELSIF NEW.status NOT IN ('completed', 'cancelled', 'rejected') AND OLD.status IN ('completed', 'cancelled', 'rejected') THEN
        NEW.resolved_at = NULL;
        NEW.resolved_by = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic resolution timestamp
CREATE TRIGGER qr_support_request_resolution_trigger
    BEFORE UPDATE ON qr_support_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_qr_support_request_resolution();

-- Enable RLS
ALTER TABLE qr_support_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Managers can view their own establishment's requests
CREATE POLICY "Managers can view their establishment requests" ON qr_support_requests
    FOR SELECT USING (
        establishment_id IN (
            SELECT id FROM establishments
            WHERE user_id = auth.uid() OR owner_id = auth.uid() OR created_by = auth.uid()
        ) OR requested_by = auth.uid()
    );

-- Managers can create requests for their establishments
CREATE POLICY "Managers can create support requests" ON qr_support_requests
    FOR INSERT WITH CHECK (
        establishment_id IN (
            SELECT id FROM establishments
            WHERE user_id = auth.uid() OR owner_id = auth.uid() OR created_by = auth.uid()
        ) AND requested_by = auth.uid()
    );

-- Managers can update their own requests (limited fields)
CREATE POLICY "Managers can update their own requests" ON qr_support_requests
    FOR UPDATE
    USING (requested_by = auth.uid() AND status = 'pending')
    WITH CHECK (requested_by = auth.uid() AND status IN ('pending', 'cancelled'));

-- Admins can manage all requests
CREATE POLICY "Admins can manage all QR support requests" ON qr_support_requests
    FOR ALL USING (is_admin_user());

-- Create view for support dashboard
CREATE OR REPLACE VIEW qr_support_dashboard AS
SELECT
    qsr.*,
    e.name as establishment_name,
    e.slug as establishment_slug,
    rb.full_name as requested_by_name,
    ab.full_name as assigned_to_name,
    rb2.full_name as resolved_by_name,
    CASE
        WHEN qsr.status = 'pending' AND qsr.priority = 'urgent' THEN 1
        WHEN qsr.status = 'pending' AND qsr.priority = 'high' THEN 2
        WHEN qsr.status = 'in_progress' THEN 3
        WHEN qsr.status = 'pending' AND qsr.priority = 'medium' THEN 4
        WHEN qsr.status = 'pending' AND qsr.priority = 'low' THEN 5
        ELSE 6
    END as priority_order
FROM qr_support_requests qsr
LEFT JOIN establishments e ON e.id = qsr.establishment_id
LEFT JOIN users rb ON rb.id = qsr.requested_by
LEFT JOIN users ab ON ab.id = qsr.assigned_to
LEFT JOIN users rb2 ON rb2.id = qsr.resolved_by
ORDER BY priority_order ASC, qsr.created_at DESC;

-- Create function to get support requests with user details
CREATE OR REPLACE FUNCTION get_qr_support_requests_with_users(
    establishment_filter UUID DEFAULT NULL,
    status_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    establishment_id UUID,
    requested_by UUID,
    request_type TEXT,
    table_number INTEGER,
    title TEXT,
    description TEXT,
    priority TEXT,
    status TEXT,
    assigned_to UUID,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID,
    resolution_notes TEXT,
    attachments JSONB,
    internal_notes TEXT,
    estimated_completion TIMESTAMP WITH TIME ZONE,
    establishment_name TEXT,
    establishment_slug TEXT,
    requested_by_name TEXT,
    assigned_to_name TEXT,
    resolved_by_name TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT
        qsr.id,
        qsr.created_at,
        qsr.updated_at,
        qsr.establishment_id,
        qsr.requested_by,
        qsr.request_type,
        qsr.table_number,
        qsr.title,
        qsr.description,
        qsr.priority,
        qsr.status,
        qsr.assigned_to,
        qsr.resolved_at,
        qsr.resolved_by,
        qsr.resolution_notes,
        qsr.attachments,
        qsr.internal_notes,
        qsr.estimated_completion,
        e.name as establishment_name,
        e.slug as establishment_slug,
        rb.full_name as requested_by_name,
        ab.full_name as assigned_to_name,
        rb2.full_name as resolved_by_name
    FROM qr_support_requests qsr
    LEFT JOIN establishments e ON e.id = qsr.establishment_id
    LEFT JOIN users rb ON rb.id = qsr.requested_by
    LEFT JOIN users ab ON ab.id = qsr.assigned_to
    LEFT JOIN users rb2 ON rb2.id = qsr.resolved_by
    WHERE (establishment_filter IS NULL OR qsr.establishment_id = establishment_filter)
    AND (status_filter IS NULL OR qsr.status = status_filter)
    AND (
        -- Admins can see all
        is_admin_user()
        OR
        -- Managers can see their establishment's requests
        owns_establishment(qsr.establishment_id)
        OR
        -- Users can see their own requests
        qsr.requested_by = auth.uid()
    )
    ORDER BY qsr.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$;
CREATE OR REPLACE FUNCTION get_qr_support_stats(establishment_uuid UUID DEFAULT NULL)
RETURNS TABLE (
    total_requests BIGINT,
    pending_requests BIGINT,
    in_progress_requests BIGINT,
    completed_requests BIGINT,
    avg_resolution_time INTERVAL,
    urgent_requests BIGINT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_requests,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_requests,
        COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_requests,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_requests,
        AVG(
            CASE
                WHEN status IN ('completed', 'cancelled') AND resolved_at IS NOT NULL
                THEN resolved_at - created_at
            END
        ) as avg_resolution_time,
        COUNT(
            CASE
                WHEN priority = 'urgent' AND status NOT IN ('completed', 'cancelled', 'rejected')
                THEN 1
            END
        ) as urgent_requests
    FROM qr_support_requests
    WHERE (establishment_uuid IS NULL OR establishment_id = establishment_uuid);
END;
$$;


-- ##### staff.sql (fonctions PIN) #####
-- Fonction pour générer un PIN aléatoire à 4 chiffres
CREATE OR REPLACE FUNCTION generate_random_pin()
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
BEGIN
  -- Générer un nombre aléatoire entre 1000 et 9999
  new_pin := LPAD(FLOOR(RANDOM() * 9000 + 1000)::TEXT, 4, '0');
  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour créer un membre du personnel avec un username et un PIN
CREATE OR REPLACE FUNCTION create_staff_pin(
  p_username TEXT,
  p_establishment_id UUID,
  p_role TEXT DEFAULT 'staff'
)
RETURNS JSONB AS $$
DECLARE
  new_pin VARCHAR(4);
  pin_exists BOOLEAN;
  new_id UUID;
BEGIN
  -- Vérifier que le rôle est valide
  IF p_role NOT IN ('waiter', 'kitchen', 'staff', 'manager') THEN
    RAISE EXCEPTION 'Rôle invalide. Les valeurs autorisées sont: waiter, kitchen, staff, manager';
  END IF;

  -- Générer un PIN unique pour cet établissement
  LOOP
    new_pin := generate_random_pin();
    
    -- Vérifier si le PIN existe déjà pour cet établissement
    SELECT EXISTS (
      SELECT 1 FROM staff 
      WHERE establishment_id = p_establishment_id AND pin = new_pin
    ) INTO pin_exists;
    
    EXIT WHEN NOT pin_exists;
  END LOOP;
  
  -- Insérer le nouveau membre avec PIN
  INSERT INTO staff (
    username,
    establishment_id,
    pin,
    role,
    is_active
  ) VALUES (
    p_username,
    p_establishment_id,
    new_pin,
    p_role,
    true
  ) RETURNING id INTO new_id;
  
  -- Retourner les informations
  RETURN jsonb_build_object(
    'id', new_id,
    'username', p_username,
    'pin', new_pin,
    'role', p_role
  );
END;
$$ LANGUAGE plpgsql;

-- Fonction pour régénérer un PIN
CREATE OR REPLACE FUNCTION regenerate_staff_pin(
  p_staff_id UUID
)
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
  pin_exists BOOLEAN;
  v_establishment_id UUID;
BEGIN
  -- Récupérer l'establishment_id
  SELECT establishment_id INTO v_establishment_id
  FROM staff
  WHERE id = p_staff_id;
  
  -- Générer un nouveau PIN unique
  LOOP
    new_pin := generate_random_pin();
    
    -- Vérifier si le PIN existe déjà pour cet établissement
    SELECT EXISTS (
      SELECT 1 FROM staff 
      WHERE establishment_id = v_establishment_id AND pin = new_pin
    ) INTO pin_exists;
    
    EXIT WHEN NOT pin_exists;
  END LOOP;
  
  -- Mettre à jour le PIN
  UPDATE staff
  SET pin = new_pin,
      updated_at = NOW()
  WHERE id = p_staff_id;
  
  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- ##### activity_tracking.sql #####
-- Table activities pour suivre les actions des utilisateurs
CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action_type VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'login', 'logout', etc.
  entity_type VARCHAR(50) NOT NULL, -- 'establishment', 'category', 'product', 'order', etc.
  entity_id UUID, -- ID de l'objet concerné
  details JSONB, -- Détails supplémentaires sur l'action
  ip_location VARCHAR(45), -- Pour suivre l'adresse IP (IPv4/IPv6)
  user_agent TEXT, -- Pour suivre le navigateur/appareil
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_action_type ON activities(action_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_type ON activities(entity_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_id ON activities(entity_id);
CREATE INDEX IF NOT EXISTS idx_activities_created_at ON activities(created_at);

-- Enable RLS on activities table
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Supprimer les politiques existantes si elles existent
DROP POLICY IF EXISTS "Users can view their own activities" ON activities;
DROP POLICY IF EXISTS "Admins can view all activities" ON activities;

-- Policy for activities - users can only see their own activities
CREATE POLICY "Users can view their own activities" 
ON activities FOR SELECT 
USING (auth.uid() = user_id);

-- Policy for activities - admins can see all activities
CREATE POLICY "Admins can view all activities" 
ON activities FOR SELECT 
USING (
  auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  )
);

-- Supprimer d'abord les anciennes fonctions
DROP FUNCTION IF EXISTS log_activity(uuid, varchar, varchar, uuid, jsonb, varchar, text);
DROP FUNCTION IF EXISTS log_user_activity(varchar, varchar, uuid, jsonb);

-- Recréer la fonction log_activity
CREATE OR REPLACE FUNCTION log_activity(
  p_user_id UUID,
  p_action_type VARCHAR(50),
  p_entity_type VARCHAR(50),
  p_entity_id UUID,
  p_details JSONB DEFAULT NULL,
  p_ip_location VARCHAR(45) DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_activity_id UUID;
BEGIN
  -- Vérifier que entity_type est valide
  IF p_entity_type NOT IN ('establishment', 'category', 'product', 'order', 'user', 'qr_code', 'staff') THEN
    RAISE EXCEPTION 'Type d''entité non valide';
  END IF;

  INSERT INTO activities (
    user_id,
    action_type,
    entity_type,
    entity_id,
    details,
    ip_location,
    user_agent
  ) VALUES (
    p_user_id,
    p_action_type,
    p_entity_type,
    p_entity_id,
    p_details,
    p_ip_location,
    p_user_agent
  ) RETURNING id INTO v_activity_id;
  
  RETURN v_activity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recréer la fonction log_user_activity
CREATE OR REPLACE FUNCTION log_user_activity(
  p_action_type VARCHAR(50),
  p_entity_type VARCHAR(50),
  p_entity_id UUID,
  p_details JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;
  
  RETURN log_activity(
    v_user_id,
    p_action_type,
    p_entity_type,
    p_entity_id,
    p_details,
    request.header('X-Forwarded-For'),
    request.header('User-Agent')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer les triggers existants avant de les recréer
DROP TRIGGER IF EXISTS track_user_changes ON users;
DROP TRIGGER IF EXISTS track_establishment_changes ON establishments;
DROP TRIGGER IF EXISTS track_category_changes ON categories;
DROP TRIGGER IF EXISTS track_product_changes ON products;

-- Fonction pour le trigger de suivi des modifications des utilisateurs
CREATE OR REPLACE FUNCTION track_user_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
BEGIN
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'full_name', NEW.full_name,
      'role', NEW.role,
      'subscription_tier', NEW.subscription_tier
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
      v_details := v_details || jsonb_build_object('full_name', NEW.full_name, 'previous_full_name', OLD.full_name);
    END IF;
    
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      v_details := v_details || jsonb_build_object('role', NEW.role, 'previous_role', OLD.role);
    END IF;
    
    IF NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier THEN
      v_details := v_details || jsonb_build_object('subscription_tier', NEW.subscription_tier, 'previous_subscription_tier', OLD.subscription_tier);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'full_name', OLD.full_name,
      'role', OLD.role
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END),
    v_action_type,
    'user',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des établissements
CREATE OR REPLACE FUNCTION track_establishment_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
BEGIN
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'slug', NEW.slug,
      'type_id', NEW.type_id,
      'subscription_type', NEW.subscription_type
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    IF NEW.subscription_type IS DISTINCT FROM OLD.subscription_type THEN
      v_details := v_details || jsonb_build_object('subscription_type', NEW.subscription_type, 'previous_subscription_type', OLD.subscription_type);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'slug', OLD.slug
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), NEW.created_by),
    v_action_type,
    'establishment',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des catégories
CREATE OR REPLACE FUNCTION track_category_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
  v_user_id UUID;
BEGIN
  -- Obtenir l'ID de l'utilisateur propriétaire de l'établissement
  SELECT created_by INTO v_user_id 
  FROM establishments 
  WHERE id = CASE WHEN TG_OP = 'DELETE' THEN OLD.establishment_id ELSE NEW.establishment_id END;

  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'establishment_id', NEW.establishment_id
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.order_number IS DISTINCT FROM OLD.order_number THEN
      v_details := v_details || jsonb_build_object('order_number', NEW.order_number, 'previous_order_number', OLD.order_number);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'establishment_id', OLD.establishment_id
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), v_user_id),
    v_action_type,
    'category',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des produits
CREATE OR REPLACE FUNCTION track_product_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
  v_user_id UUID;
BEGIN
  -- Obtenir l'ID de l'utilisateur propriétaire de l'établissement
  SELECT e.created_by INTO v_user_id 
  FROM establishments e
  JOIN categories c ON c.establishment_id = e.id
  WHERE c.id = CASE WHEN TG_OP = 'DELETE' THEN OLD.category_id ELSE NEW.category_id END;

  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'price', NEW.price,
      'category_id', NEW.category_id
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.price IS DISTINCT FROM OLD.price THEN
      v_details := v_details || jsonb_build_object('price', NEW.price, 'previous_price', OLD.price);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.is_available IS DISTINCT FROM OLD.is_available THEN
      v_details := v_details || jsonb_build_object('is_available', NEW.is_available, 'previous_is_available', OLD.is_available);
    END IF;
    
    IF NEW.category_id IS DISTINCT FROM OLD.category_id THEN
      v_details := v_details || jsonb_build_object('category_id', NEW.category_id, 'previous_category_id', OLD.category_id);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'price', OLD.price,
      'category_id', OLD.category_id
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), v_user_id),
    v_action_type,
    'product',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer les triggers pour chaque table
CREATE TRIGGER track_user_changes
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION track_user_changes();

CREATE TRIGGER track_establishment_changes
AFTER INSERT OR UPDATE OR DELETE ON establishments
FOR EACH ROW EXECUTE FUNCTION track_establishment_changes();

CREATE TRIGGER track_category_changes
AFTER INSERT OR UPDATE OR DELETE ON categories
FOR EACH ROW EXECUTE FUNCTION track_category_changes();

CREATE TRIGGER track_product_changes
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION track_product_changes();

-- Vue pour les activités récentes par établissement
CREATE OR REPLACE VIEW establishment_activities AS
SELECT 
  e.id AS establishment_id,
  e.name AS establishment_name,
  a.action_type,
  a.entity_type,
  a.details,
  a.created_at,
  u.full_name AS user_name
FROM 
  activities a
JOIN 
  users u ON a.user_id = u.id
JOIN 
  establishments e ON 
    (a.entity_type = 'establishment' AND a.entity_id = e.id) OR
    (a.entity_type = 'category' AND a.entity_id IN (SELECT id FROM categories WHERE establishment_id = e.id)) OR
    (a.entity_type = 'product' AND a.entity_id IN (
      SELECT p.id FROM products p 
      JOIN categories c ON p.category_id = c.id 
      WHERE c.establishment_id = e.id
    ))
ORDER BY 
  a.created_at DESC;
-- ##### views.sql #####
CREATE OR REPLACE VIEW admin_statistics AS
WITH base_stats AS (
  SELECT
    -- Statistiques des établissements
    COUNT(DISTINCT e.id) as total_establishments,
    COUNT(DISTINCT e.id) FILTER (WHERE e.created_at >= NOW() - INTERVAL '30 days') as new_establishments_30d,
    COUNT(DISTINCT e.id) FILTER (WHERE e.is_active = true) as active_establishments,
    
    -- Statistiques des utilisateurs
    COUNT(DISTINCT u.id) as total_users,
    COUNT(DISTINCT u.id) FILTER (WHERE u.created_at >= NOW() - INTERVAL '30 days') as new_users_30d,
    COUNT(DISTINCT u.id) FILTER (WHERE u.last_login >= NOW() - INTERVAL '7 days') as active_users_7d,
    COUNT(DISTINCT u.id) FILTER (WHERE u.subscription_tier != 'free') as paying_users,
    
    -- Statistiques des commandes
    COUNT(DISTINCT o.id) as total_orders,
    COUNT(DISTINCT o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '24 hours') as orders_24h,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    
    -- Statistiques des produits et catégories
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT c.id) as total_categories,
    AVG(p.price) as avg_product_price,
    
    -- Statistiques des scans QR
    COUNT(qs.id) as total_qr_scans,
    COUNT(qs.id) FILTER (WHERE qs.created_at >= NOW() - INTERVAL '24 hours') as qr_scans_24h,
    
    -- Statistiques du staff
    COUNT(DISTINCT s.id) as total_staff_members,
    COUNT(DISTINCT s.id) FILTER (WHERE s.last_login >= NOW() - INTERVAL '24 hours') as active_staff_24h
    
  FROM establishments e
  LEFT JOIN users u ON e.user_id = u.id
  LEFT JOIN categories c ON c.establishment_id = e.id
  LEFT JOIN products p ON p.category_id = c.id
  LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
  LEFT JOIN staff s ON s.establishment_id = e.id
  LEFT JOIN orders o ON o.establishment_id = e.id
)
SELECT * FROM base_stats;

-- Vue pour les statistiques de croissance mensuelle
CREATE OR REPLACE VIEW monthly_growth_stats AS
SELECT
  DATE_TRUNC('month', d)::date as month,
  COUNT(DISTINCT e.id) FILTER (WHERE e.created_at <= d) as total_establishments,
  COUNT(DISTINCT u.id) FILTER (WHERE u.created_at <= d) as total_users,
  COUNT(DISTINCT e.id) FILTER (WHERE e.created_at >= d - INTERVAL '30 days' AND e.created_at <= d) as new_establishments,
  COUNT(DISTINCT u.id) FILTER (WHERE u.created_at >= d - INTERVAL '30 days' AND u.created_at <= d) as new_users,
  COUNT(qs.id) FILTER (WHERE qs.created_at >= d - INTERVAL '30 days' AND qs.created_at <= d) as monthly_scans
FROM generate_series(
  (SELECT MIN(created_at) FROM establishments)::date,
  CURRENT_DATE,
  '1 month'::interval
) d
LEFT JOIN establishments e ON e.created_at <= d
LEFT JOIN users u ON u.created_at <= d
LEFT JOIN qr_scans qs ON qs.created_at >= d - INTERVAL '30 days' AND qs.created_at <= d
GROUP BY month
ORDER BY month;

-- Index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at);

-- Create a view for popular restaurants
CREATE OR REPLACE VIEW popular_restaurants AS
SELECT 
  e.id,
  e.name,
  COUNT(o.id) AS order_count,
  COALESCE(AVG(o.rating), 4.5) AS avg_rating
FROM 
  establishments e
LEFT JOIN 
  orders o ON e.id = o.establishment_id
WHERE 
  e.is_active = true
GROUP BY 
  e.id, e.name
ORDER BY 
  order_count DESC, avg_rating DESC;

-- Create a function to get popular restaurants
CREATE OR REPLACE FUNCTION get_popular_restaurants()
RETURNS TABLE (
  id UUID,
  name TEXT,
  orders INTEGER,
  rating NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pr.id,
    pr.name,
    pr.order_count::INTEGER AS orders,
    pr.avg_rating AS rating
  FROM 
    popular_restaurants pr
  ORDER BY 
    pr.order_count DESC, pr.avg_rating DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Create a function to get order statistics
CREATE OR REPLACE FUNCTION get_order_stats()
RETURNS TABLE (
  total_orders INTEGER,
  total_revenue NUMERIC,
  avg_order_value NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(o.id)::INTEGER AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue,
    CASE 
      WHEN COUNT(o.id) > 0 THEN COALESCE(SUM(o.total_amount) / COUNT(o.id), 0)
      ELSE 0
    END AS avg_order_value
  FROM 
    orders o;
END;
$$ LANGUAGE plpgsql;

-- Create a view for recent activity
CREATE OR REPLACE VIEW recent_activity AS
SELECT 
  a.id,
  a.action_type,
  a.entity_type,
  a.entity_id,
  a.details,
  a.created_at,
  u.full_name AS user_name,
  u.id AS user_id
FROM 
  activities a
LEFT JOIN 
  users u ON a.user_id = u.id
ORDER BY 
  a.created_at DESC;

------------------------------------------
-- Vues pour les établissements populaires
------------------------------------------
CREATE OR REPLACE VIEW popular_establishments AS
SELECT 
  e.id,
  e.name,
  e.description,
  e.image_url,
  e.type_id,
  et.name as establishment_type,
  COUNT(DISTINCT o.id) as order_count,
  COUNT(qs.id) as scan_count,
  COUNT(DISTINCT qs.created_at::date) as unique_days_scanned,
  COALESCE(AVG(o.rating), 4.5) as avg_rating,
  COUNT(DISTINCT p.id) as product_count,
  COUNT(DISTINCT c.id) as category_count,
  e.theme_settings,
  e.analytics_enabled
FROM establishments e
LEFT JOIN establishment_types et ON e.type_id = et.id
LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
LEFT JOIN orders o ON o.establishment_id = e.id
LEFT JOIN categories c ON c.establishment_id = e.id
LEFT JOIN products p ON p.establishment_id = e.id
WHERE e.is_active = true
GROUP BY e.id, e.name, e.description, e.image_url, e.type_id, et.name, e.theme_settings, e.analytics_enabled
ORDER BY order_count DESC, scan_count DESC;

------------------------------------------
-- Vue pour l'activité du staff
------------------------------------------
CREATE OR REPLACE VIEW staff_activity AS
SELECT 
  sa.id,
  sa.created_at,
  s.username as staff_name,
  s.role as staff_role,
  e.name as establishment_name,
  sa.action,
  sa.details,
  sa.ip_address,
  sa.user_agent
FROM staff_activity_logs sa
JOIN staff s ON sa.staff_id = s.id
JOIN establishments e ON sa.establishment_id = e.id
ORDER BY sa.created_at DESC;

------------------------------------------
-- Vue pour les statistiques des commandes
------------------------------------------
CREATE OR REPLACE VIEW order_statistics AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(o.id) as total_orders,
  COUNT(o.id) FILTER (WHERE o.status = 'delivered') as completed_orders,
  COUNT(o.id) FILTER (WHERE o.status = 'cancelled') as cancelled_orders,
  COALESCE(AVG(o.rating), 0) as avg_rating,
  COALESCE(SUM(o.total_amount), 0) as total_revenue,
  COALESCE(AVG(o.total_amount), 0) as avg_order_value,
  COUNT(DISTINCT o.table_number) as tables_served,
  COUNT(o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '24 hours') as orders_last_24h
FROM establishments e
LEFT JOIN orders o ON o.establishment_id = e.id
GROUP BY e.id, e.name;

------------------------------------------
-- Vue pour le suivi des QR codes
------------------------------------------
CREATE OR REPLACE VIEW qr_code_analytics AS
SELECT
  qc.id as qr_code_id,
  e.name as establishment_name,
  qc.table_number,
  COUNT(qs.id) as total_scans,
  COUNT(DISTINCT qs.created_at::date) as unique_days,
  COUNT(qs.id) FILTER (WHERE qs.created_at >= NOW() - INTERVAL '24 hours') as scans_last_24h,
  MAX(qs.created_at) as last_scan_at
FROM qr_codes qc
JOIN establishments e ON qc.establishment_id = e.id
LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
GROUP BY qc.id, e.name, qc.table_number;

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

------------------------------------------
-- STATISTIQUES SIMPLES POUR LES MANAGERS
------------------------------------------

-- Vue simple : Commandes du jour
CREATE OR REPLACE VIEW stats_today AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(o.id) as orders_today,
  COALESCE(SUM(o.total_amount), 0) as revenue_today,
  COUNT(o.id) FILTER (WHERE o.status = 'completed') as completed_today
FROM establishments e
LEFT JOIN orders o ON o.establishment_id = e.id
  AND DATE(o.created_at) = CURRENT_DATE
WHERE e.is_active = true
GROUP BY e.id, e.name;

-- Vue simple : Commandes de la semaine
CREATE OR REPLACE VIEW stats_week AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(o.id) as orders_week,
  COALESCE(SUM(o.total_amount), 0) as revenue_week,
  COUNT(o.id) FILTER (WHERE o.status = 'completed') as completed_week
FROM establishments e
LEFT JOIN orders o ON o.establishment_id = e.id
  AND o.created_at >= CURRENT_DATE - INTERVAL '7 days'
WHERE e.is_active = true
GROUP BY e.id, e.name;

-- Vue simple : Commandes du mois
CREATE OR REPLACE VIEW stats_month AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(o.id) FILTER (WHERE o.status = 'completed') as completed_month
FROM establishments e
LEFT JOIN orders o ON o.establishment_id = e.id
  AND o.created_at >= DATE_TRUNC('month', CURRENT_DATE)
WHERE e.is_active = true
GROUP BY e.id, e.name;

-- Vue simple : Produits populaires
CREATE OR REPLACE VIEW top_products AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  p.name as product_name,
  COUNT(oi.id) as sales_count,
  COALESCE(SUM(oi.subtotal), 0) as total_revenue
FROM establishments e
LEFT JOIN products p ON p.establishment_id = e.id
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id
WHERE e.is_active = true AND p.is_available = true
GROUP BY e.id, e.name, p.id, p.name
HAVING COUNT(oi.id) > 0
ORDER BY e.id, sales_count DESC;

-- Vue simple : Statut des commandes actuelles
CREATE OR REPLACE VIEW current_orders AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(o.id) FILTER (WHERE o.status = 'pending') as pending,
  COUNT(o.id) FILTER (WHERE o.status = 'confirmed') as confirmed,
  COUNT(o.id) FILTER (WHERE o.status = 'preparing') as preparing,
  COUNT(o.id) FILTER (WHERE o.status = 'ready') as ready
FROM establishments e
LEFT JOIN orders o ON o.establishment_id = e.id
WHERE e.is_active = true
GROUP BY e.id, e.name;

-- Vue simple : Scans QR du jour
CREATE OR REPLACE VIEW qr_scans_today AS
SELECT
  e.id as establishment_id,
  e.name as establishment_name,
  COUNT(qs.id) as scans_today
FROM establishments e
LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
  AND DATE(qs.created_at) = CURRENT_DATE
WHERE e.is_active = true
GROUP BY e.id, e.name;

------------------------------------------
-- FONCTIONS SIMPLES POUR LES STATISTIQUES
------------------------------------------

-- Fonction simple pour obtenir les stats d'un établissement
CREATE OR REPLACE FUNCTION get_simple_stats(establishment_uuid UUID)
RETURNS TABLE (
  orders_today BIGINT,
  revenue_today NUMERIC,
  orders_week BIGINT,
  revenue_week NUMERIC,
  orders_month BIGINT,
  revenue_month NUMERIC,
  pending_orders BIGINT,
  confirmed_orders BIGINT,
  preparing_orders BIGINT,
  ready_orders BIGINT,
  scans_today BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(st.orders_today, 0),
    COALESCE(st.revenue_today, 0),
    COALESCE(sw.orders_week, 0),
    COALESCE(sw.revenue_week, 0),
    COALESCE(sm.orders_month, 0),
    COALESCE(sm.revenue_month, 0),
    COALESCE(co.pending, 0),
    COALESCE(co.confirmed, 0),
    COALESCE(co.preparing, 0),
    COALESCE(co.ready, 0),
    COALESCE(qst.scans_today, 0)
  FROM establishments e
  LEFT JOIN stats_today st ON st.establishment_id = e.id
  LEFT JOIN stats_week sw ON sw.establishment_id = e.id
  LEFT JOIN stats_month sm ON sm.establishment_id = e.id
  LEFT JOIN current_orders co ON co.establishment_id = e.id
  LEFT JOIN qr_scans_today qst ON qst.establishment_id = e.id
  WHERE e.id = establishment_uuid;
END;
$$ LANGUAGE plpgsql;

-- Fonction simple pour les top produits d'un établissement
CREATE OR REPLACE FUNCTION get_top_products(establishment_uuid UUID, limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
  product_name TEXT,
  sales_count BIGINT,
  total_revenue NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    tp.product_name,
    tp.sales_count,
    tp.total_revenue
  FROM top_products tp
  WHERE tp.establishment_id = establishment_uuid
  ORDER BY tp.sales_count DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- ##### dashboard_views.sql #####
-- Dashboard Views for Manager Interface
-- These views provide aggregated data for the manager dashboard

-- 1. Sales Overview View
-- Provides daily, weekly, and monthly sales data
CREATE OR REPLACE VIEW sales_overview AS
SELECT
  date_trunc('day', created_at)::date AS day,
  date_trunc('week', created_at)::date AS week_start,
  date_trunc('month', created_at)::date AS month_start,
  COUNT(*) AS order_count,
  SUM(total_amount) AS total_sales,
  AVG(total_amount) AS average_order_value,
  COUNT(DISTINCT table_number) AS unique_tables
FROM orders
WHERE status != 'rejected'
GROUP BY day, week_start, month_start
ORDER BY day DESC;

-- 2. Popular Products View
-- Shows the most ordered products with their performance metrics
CREATE OR REPLACE VIEW popular_products AS
SELECT
  p.id,
  p.name,
  p.price,
  p.image_url,
  p.category_id,
  c.name AS category_name,
  COUNT(oi.id) AS order_count,
  SUM(oi.quantity) AS total_quantity,
  SUM(oi.quantity * oi.unit_price) AS total_revenue,
  p.is_available
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE o.status != 'rejected' OR o.status IS NULL
GROUP BY p.id, p.name, p.price, p.image_url, p.category_id, c.name, p.is_available
ORDER BY total_quantity DESC;

-- 3. Recent Orders View
-- Provides a simplified view of recent orders for quick access
CREATE OR REPLACE VIEW recent_orders AS
SELECT
  o.id,
  o.created_at,
  o.updated_at,
  o.status,
  o.table_number,
  o.total_amount,
  o.notes,
  o.establishment_id,
  COUNT(oi.id) AS item_count,
  ARRAY_AGG(p.name) AS product_names
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY o.id, o.created_at, o.updated_at, o.status, o.table_number, o.total_amount, o.notes, o.establishment_id
ORDER BY o.created_at DESC;

-- 4. Category Performance View
-- Shows how each category is performing
CREATE OR REPLACE VIEW category_performance AS
SELECT
  c.id,
  c.name,
  c.image_url,
  COUNT(DISTINCT o.id) AS order_count,
  COUNT(p.id) AS product_count,
  SUM(oi.quantity) AS total_items_sold,
  SUM(oi.quantity * oi.unit_price) AS total_revenue,
  AVG(p.price) AS average_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status != 'rejected'
GROUP BY c.id, c.name, c.image_url
ORDER BY total_revenue DESC NULLS LAST;

-- 5. Staff Activity View - FIXED
-- First drop the existing view
DROP VIEW IF EXISTS staff_activity;

-- Then recreate it with the correct structure
CREATE VIEW staff_activity AS
SELECT
  u.id,
  u.email,
  u.created_at AS user_created_at,
  e.id AS establishment_id,
  e.name AS establishment_name,
  COUNT(DISTINCT o.id) AS orders_processed,
  AVG(EXTRACT(EPOCH FROM (o.updated_at - o.created_at))/60) AS avg_processing_time_minutes,
  COUNT(DISTINCT CASE WHEN o.status = 'completed' THEN o.id END) AS completed_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'rejected' THEN o.id END) AS rejected_orders,
  MAX(o.updated_at) AS last_activity
FROM auth.users u
JOIN establishments e ON e.owner_id = u.id
LEFT JOIN orders o ON e.id = o.establishment_id
GROUP BY u.id, u.email, u.created_at, e.id, e.name
ORDER BY orders_processed DESC;

-- 6. Dashboard Summary View
-- Provides key metrics for the dashboard
CREATE OR REPLACE VIEW dashboard_summary AS
SELECT
  e.id AS establishment_id,
  e.name AS establishment_name,
  COUNT(DISTINCT o.id) AS total_orders,
  SUM(o.total_amount) AS total_revenue,
  COUNT(DISTINCT CASE WHEN o.created_at > NOW() - INTERVAL '24 hours' THEN o.id END) AS orders_last_24h,
  SUM(CASE WHEN o.created_at > NOW() - INTERVAL '24 hours' THEN o.total_amount ELSE 0 END) AS revenue_last_24h,
  COUNT(DISTINCT CASE WHEN o.status = 'pending' THEN o.id END) AS pending_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'preparing' THEN o.id END) AS preparing_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'ready' THEN o.id END) AS ready_orders,
  COUNT(DISTINCT p.id) AS total_products,
  COUNT(DISTINCT c.id) AS total_categories,
  AVG(o.total_amount) AS average_order_value
FROM establishments e
LEFT JOIN orders o ON e.id = o.establishment_id
LEFT JOIN products p ON e.id = p.establishment_id
LEFT JOIN categories c ON e.id = c.establishment_id
GROUP BY e.id, e.name;

-- 7. Time-based Performance View
-- Shows performance by hour of day and day of week
CREATE OR REPLACE VIEW time_performance AS
SELECT
  establishment_id,
  EXTRACT(DOW FROM created_at) AS day_of_week,
  EXTRACT(HOUR FROM created_at) AS hour_of_day,
  COUNT(*) AS order_count,
  SUM(total_amount) AS total_sales,
  AVG(total_amount) AS average_order_value
FROM orders
WHERE status != 'rejected'
GROUP BY establishment_id, day_of_week, hour_of_day
ORDER BY day_of_week, hour_of_day;

-- 8. Customer Retention View
-- Helps track returning customers (based on table numbers as proxy)
CREATE OR REPLACE VIEW customer_retention AS
SELECT
  establishment_id,
  table_number,
  COUNT(*) AS visit_count,
  MIN(created_at) AS first_visit,
  MAX(created_at) AS last_visit,
  SUM(total_amount) AS total_spent,
  AVG(total_amount) AS average_spent_per_visit
FROM orders
WHERE status != 'rejected'
GROUP BY establishment_id, table_number
ORDER BY visit_count DESC; 
-- ##### subscription_auto_block_corrected.sql #####
-- ============================================
-- SYSTÈME DE BLOCAGE AUTOMATIQUE DES ABONNEMENTS - VERSION CORRIGÉE
-- ============================================
-- Ce fichier gère le blocage automatique des utilisateurs après expiration
-- Corrections appliquées : colonnes phone au lieu d'email, types corrects, premium inclus
-- ============================================

-- 0. Supprimer les anciennes versions pour éviter les conflits
-- ============================================
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS get_expiring_subscriptions(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions_with_log() CASCADE;
DROP FUNCTION IF EXISTS check_and_block_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS get_subscription_block_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_recent_admin_notifications(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS create_admin_notification(TEXT, UUID, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS reactivate_user_subscription(UUID, TEXT, INTEGER) CASCADE;
DROP VIEW IF EXISTS subscription_stats CASCADE;

-- 1. Tables de logs et notifications
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_blocks_log (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  subscription_tier TEXT NOT NULL,
  subscription_ended_at TIMESTAMPTZ NOT NULL,
  blocked_at TIMESTAMPTZ DEFAULT NOW(),
  days_expired INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_notifications (
  id SERIAL PRIMARY KEY,
  type TEXT NOT NULL,
  user_id UUID,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error', 'success')),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Fonction utilitaire : créer notification admin
-- ============================================
CREATE OR REPLACE FUNCTION create_admin_notification(
  p_type TEXT,
  p_user_id UUID,
  p_title TEXT,
  p_message TEXT,
  p_severity TEXT DEFAULT 'info'
)
-- admin_notifications.id est un SERIAL : la fonction renvoie un entier
RETURNS INTEGER AS $$
DECLARE
  v_notification_id INTEGER;
BEGIN
  PERFORM assert_admin();
  INSERT INTO admin_notifications (type, user_id, title, message, severity)
  VALUES (p_type, p_user_id, p_title, p_message, p_severity)
  RETURNING id INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Vue des statistiques (avec qualification explicite des colonnes)
-- ============================================
CREATE OR REPLACE VIEW subscription_stats AS
SELECT 
  users.subscription_tier,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE users.is_active = true) as active_users,
  COUNT(*) FILTER (WHERE users.is_active = false) as blocked_users,
  COUNT(*) FILTER (
    WHERE users.subscription_ends_at IS NOT NULL 
    AND users.subscription_ends_at < NOW() 
    AND users.is_active = true
  ) as expired_active_users,
  COUNT(*) FILTER (
    WHERE users.subscription_ends_at IS NOT NULL 
    AND users.subscription_ends_at > NOW() 
    AND users.subscription_ends_at <= NOW() + INTERVAL '2 days'
  ) as expiring_soon
FROM users
WHERE users.subscription_tier IS NOT NULL
GROUP BY users.subscription_tier;

-- 4. Fonction : bloquer utilisateurs expirés (avec phone au lieu d'email)
-- ============================================
CREATE OR REPLACE FUNCTION auto_block_expired_subscriptions()
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expired_since INTERVAL,
  action_taken TEXT
) AS $$
BEGIN
  PERFORM assert_admin();
  RETURN QUERY
  WITH expired_users AS (
    UPDATE users
    SET 
      is_active = false,
      updated_at = NOW()
    WHERE 
      users.is_active = true
      AND users.subscription_ends_at IS NOT NULL
      AND users.subscription_ends_at < NOW()
      AND users.subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      users.id,
      users.full_name,
      users.phone,
      users.subscription_tier,
      users.subscription_ends_at
  )
  SELECT 
    eu.id::UUID,
    eu.full_name::TEXT,
    eu.phone::TEXT,
    eu.subscription_tier::TEXT,
    (NOW() - eu.subscription_ends_at)::INTERVAL as expired_since,
    'Compte bloqué automatiquement'::TEXT as action_taken
  FROM expired_users eu;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Fonction : obtenir abonnements qui expirent bientôt (avec phone)
-- ============================================
CREATE OR REPLACE FUNCTION get_expiring_subscriptions(days_before INTEGER DEFAULT 2)
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expires_at TIMESTAMPTZ,
  days_remaining INTEGER
) AS $$
BEGIN
  PERFORM assert_admin();
  RETURN QUERY
  SELECT 
    users.id::UUID,
    users.full_name::TEXT,
    users.phone::TEXT,
    users.subscription_tier::TEXT,
    users.subscription_ends_at::TIMESTAMPTZ,
    EXTRACT(DAY FROM (users.subscription_ends_at - NOW()))::INTEGER as days_remaining
  FROM users
  WHERE 
    users.is_active = true
    AND users.subscription_ends_at IS NOT NULL
    AND users.subscription_ends_at > NOW()
    AND users.subscription_ends_at <= (NOW() + (days_before || ' days')::INTERVAL)
    AND users.subscription_tier IN ('demo', 'pro', 'premium')
  ORDER BY users.subscription_ends_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Fonction : bloquer avec log (version complète)
-- ============================================
CREATE OR REPLACE FUNCTION auto_block_expired_subscriptions_with_log()
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expired_since INTERVAL,
  action_taken TEXT
) AS $$
DECLARE
  v_record RECORD;
BEGIN
  PERFORM assert_admin();
  FOR v_record IN
    UPDATE users
    SET 
      is_active = false,
      updated_at = NOW()
    WHERE 
      users.is_active = true
      AND users.subscription_ends_at IS NOT NULL
      AND users.subscription_ends_at < NOW()
      AND users.subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      users.id,
      users.full_name,
      users.phone,
      users.subscription_tier,
      users.subscription_ends_at
  LOOP
    -- Logger le blocage
    INSERT INTO subscription_blocks_log (
      user_id,
      subscription_tier,
      subscription_ended_at,
      days_expired
    ) VALUES (
      v_record.id,
      v_record.subscription_tier,
      v_record.subscription_ends_at,
      EXTRACT(DAY FROM (NOW() - v_record.subscription_ends_at))::INTEGER
    );
    
    -- Retourner les résultats
    user_id := v_record.id;
    user_name := v_record.full_name;
    phone := v_record.phone;
    subscription_tier := v_record.subscription_tier;
    expired_since := (NOW() - v_record.subscription_ends_at);
    action_taken := 'Compte bloqué et logué';
    
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Fonction principale : vérification et blocage automatique
-- ============================================
CREATE OR REPLACE FUNCTION check_and_block_expired_subscriptions()
RETURNS JSONB AS $$
DECLARE
  v_blocked_count INTEGER := 0;
  v_expiring_count INTEGER := 0;
  v_record RECORD;
  v_result JSONB;
BEGIN
  PERFORM assert_admin();
  -- Bloquer les utilisateurs expirés et créer des notifications
  FOR v_record IN
    SELECT * FROM auto_block_expired_subscriptions_with_log()
  LOOP
    v_blocked_count := v_blocked_count + 1;
    
    -- Créer une notification pour les admins
    PERFORM create_admin_notification(
      'user_blocked',
      v_record.user_id,
      'Utilisateur bloqué automatiquement',
      format('L''utilisateur %s (%s) a été bloqué car son abonnement %s a expiré depuis %s',
        v_record.user_name,
        COALESCE(v_record.phone, 'N/A'),
        v_record.subscription_tier,
        v_record.expired_since
      ),
      'warning'
    );
  END LOOP;
  
  -- Notifier les abonnements qui vont expirer dans 2 jours
  FOR v_record IN
    SELECT * FROM get_expiring_subscriptions(2)
  LOOP
    v_expiring_count := v_expiring_count + 1;
    
    PERFORM create_admin_notification(
      'subscription_expiring',
      v_record.user_id,
      'Abonnement expire bientôt',
      format('L''abonnement %s de %s (%s) expire dans %s jours',
        v_record.subscription_tier,
        v_record.user_name,
        COALESCE(v_record.phone, 'N/A'),
        v_record.days_remaining
      ),
      'info'
    );
  END LOOP;
  
  -- Retourner le résumé
  SELECT jsonb_build_object(
    'success', true,
    'blocked_users', v_blocked_count,
    'expiring_soon', v_expiring_count,
    'checked_at', NOW(),
    'message', format('%s utilisateur(s) bloqué(s), %s abonnement(s) expire(nt) bientôt', 
      v_blocked_count, v_expiring_count)
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Fonction : obtenir logs de blocage (avec types corrects)
-- ============================================
CREATE OR REPLACE FUNCTION get_subscription_block_logs(limit_count INTEGER DEFAULT 50)
RETURNS TABLE(
  log_id INTEGER,
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  subscription_ended_at TIMESTAMPTZ,
  blocked_at TIMESTAMPTZ,
  days_expired INTEGER
) AS $$
BEGIN
  PERFORM assert_admin();
  RETURN QUERY
  SELECT 
    sbl.id as log_id,
    sbl.user_id,
    COALESCE(users.full_name, 'Utilisateur inconnu')::TEXT,
    COALESCE(users.phone, 'N/A')::TEXT,
    sbl.subscription_tier,
    sbl.subscription_ended_at,
    sbl.blocked_at,
    sbl.days_expired
  FROM subscription_blocks_log sbl
  LEFT JOIN users ON users.id = sbl.user_id
  ORDER BY sbl.blocked_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Fonction : obtenir notifications récentes
-- ============================================
CREATE OR REPLACE FUNCTION get_recent_admin_notifications(limit_count INTEGER DEFAULT 20)
RETURNS TABLE(
  id INTEGER,
  type TEXT,
  user_id UUID,
  title TEXT,
  message TEXT,
  severity TEXT,
  is_read BOOLEAN,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  PERFORM assert_admin();
  RETURN QUERY
  SELECT 
    an.id,
    an.type,
    an.user_id,
    an.title,
    an.message,
    an.severity,
    an.is_read,
    an.created_at
  FROM admin_notifications an
  ORDER BY an.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Fonction : réactiver abonnement utilisateur (version corrigée)
-- ============================================
CREATE OR REPLACE FUNCTION reactivate_user_subscription(
  p_user_id UUID,
  p_new_tier TEXT DEFAULT 'demo',
  p_duration_days INTEGER DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_duration INTEGER;
  v_result JSONB;
  v_user_record RECORD;
BEGIN
  PERFORM assert_admin();
  -- Définir la durée selon le tier
  v_duration := CASE 
    WHEN p_duration_days IS NOT NULL THEN p_duration_days
    WHEN p_new_tier = 'demo' THEN 7
    WHEN p_new_tier = 'pro' THEN 30
    WHEN p_new_tier = 'premium' THEN 90
    ELSE 7
  END;
  
  -- Réactiver l'utilisateur
  UPDATE users 
  SET 
    is_active = true,
    subscription_tier = p_new_tier,
    subscription_starts_at = NOW(),
    subscription_ends_at = NOW() + (v_duration || ' days')::INTERVAL,
    updated_at = NOW()
  WHERE users.id = p_user_id
  RETURNING users.full_name, users.phone INTO v_user_record;
  
  -- Créer notification
  PERFORM create_admin_notification(
    'user_reactivated',
    p_user_id,
    'Utilisateur réactivé',
    format('L''utilisateur %s (%s) a été réactivé avec un abonnement %s de %s jours',
      COALESCE(v_user_record.full_name, 'Utilisateur'),
      COALESCE(v_user_record.phone, 'N/A'),
      p_new_tier,
      v_duration
    ),
    'success'
  );
  
  -- Retourner le résultat
  SELECT jsonb_build_object(
    'success', true,
    'user_id', p_user_id,
    'new_tier', p_new_tier,
    'duration_days', v_duration,
    'expires_at', (NOW() + (v_duration || ' days')::INTERVAL),
    'message', 'Utilisateur réactivé avec succès'
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FONCTIONS DE MIGRATION ET MISE À JOUR
-- ============================================

-- 11. Fonction : migrer tous les utilisateurs existants vers le système demo
-- ============================================
CREATE OR REPLACE FUNCTION migrate_existing_users_to_demo()
RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
  PERFORM assert_admin();
    -- Mettre à jour tous les utilisateurs sans abonnement défini
    UPDATE users 
    SET 
        subscription_tier = 'demo',
        subscription_starts_at = NOW(),
        subscription_ends_at = NOW() + INTERVAL '7 days',
        updated_at = NOW()
    WHERE subscription_tier IS NULL OR subscription_tier = '';
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    RETURN format('Migration terminée : %s utilisateur(s) migré(s) vers demo (7 jours)', v_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGERS POUR NOUVEAUX UTILISATEURS
-- ============================================

-- 12. Trigger : assigner automatiquement demo aux nouveaux utilisateurs
-- ============================================
CREATE OR REPLACE FUNCTION assign_demo_subscription()
RETURNS TRIGGER AS $$
BEGIN
    -- Si pas d'abonnement défini, assigner demo pour 7 jours
    IF NEW.subscription_tier IS NULL OR NEW.subscription_tier = '' THEN
        NEW.subscription_tier := 'demo';
        NEW.subscription_starts_at := NOW();
        NEW.subscription_ends_at := NOW() + INTERVAL '7 days';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger (seulement s'il n'existe pas)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'trigger_assign_demo_subscription'
    ) THEN
        CREATE TRIGGER trigger_assign_demo_subscription
            BEFORE INSERT ON users
            FOR EACH ROW
            EXECUTE FUNCTION assign_demo_subscription();
    END IF;
END $$;


-- ##### dashboard_kpi_functions_manual.sql #####
-- ==========================================
-- INSTRUCTIONS POUR CRÉER LES FONCTIONS KPI
-- ==========================================
-- Copiez et exécutez ce fichier dans l'interface SQL de Supabase
-- URL: https://supabase.com/dashboard/project/[votre-project]/sql

-- ==========================================
-- KULA QR - DASHBOARD KPI FUNCTIONS
-- ==========================================
-- Functions to calculate dashboard KPIs for restaurant owners

-- 1. Nombre de scans QR aujourd'hui
CREATE OR REPLACE FUNCTION get_qr_scans_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    scan_count INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT COUNT(*) INTO scan_count
    FROM qr_scans
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE;

    RETURN COALESCE(scan_count, 0);
END;
$$;

-- 2. Nombre de scans QR hier (pour calculer la croissance)
CREATE OR REPLACE FUNCTION get_qr_scans_yesterday(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    scan_count INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT COUNT(*) INTO scan_count
    FROM qr_scans
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE - INTERVAL '1 day';

    RETURN COALESCE(scan_count, 0);
END;
$$;

-- 3. Nombre de commandes via QR aujourd'hui
CREATE OR REPLACE FUNCTION get_qr_orders_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_count INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT COUNT(*) INTO order_count
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE
    AND status IN ('confirmed', 'processing', 'ready', 'completed');

    RETURN COALESCE(order_count, 0);
END;
$$;

-- 4. Valeur moyenne des commandes via QR aujourd'hui
CREATE OR REPLACE FUNCTION get_avg_qr_order_value_today(establishment_uuid UUID)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    avg_value DECIMAL(10,2);
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT COALESCE(AVG(total_amount), 0) INTO avg_value
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE
    AND status IN ('confirmed', 'processing', 'ready', 'completed')
    AND total_amount > 0;

    RETURN avg_value;
END;
$$;

-- 5. Satisfaction client (moyenne des notes)
CREATE OR REPLACE FUNCTION get_customer_satisfaction(establishment_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
    avg_rating DECIMAL(3,2);
    total_reviews INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT
        COALESCE(AVG(rating), 0)::DECIMAL(3,2),
        COUNT(*)
    INTO avg_rating, total_reviews
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND rating IS NOT NULL
    AND status = 'completed';

    result := json_build_object(
        'average_rating', avg_rating,
        'total_reviews', total_reviews
    );

    RETURN result;
END;
$$;

-- 6. Temps moyen par scan (estimation basée sur les sessions)
CREATE OR REPLACE FUNCTION get_avg_time_per_scan(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    avg_time_seconds INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    -- Pour l'instant, on retourne une estimation basée sur les données disponibles
    -- À améliorer avec un vrai tracking des sessions utilisateur
    SELECT COALESCE(AVG(session_duration_seconds), 85)::INTEGER
    INTO avg_time_seconds
    FROM (
        SELECT
            establishment_id,
            DATE(created_at) as scan_date,
            COUNT(*) as scans_per_day,
            -- Estimation en secondes : ajustable selon les données
            CASE
                WHEN COUNT(*) > 50 THEN 65  -- Jour très fréquenté = moins de temps par scan
                WHEN COUNT(*) > 20 THEN 85  -- Jour normal
                ELSE 120  -- Jour calme = plus de temps par scan
            END as session_duration_seconds
        FROM qr_scans
        WHERE establishment_id = establishment_uuid
        AND created_at >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY establishment_id, DATE(created_at)
    ) daily_stats;

    RETURN COALESCE(avg_time_seconds, 85);
END;
$$;

-- 7. Commandes totales aujourd'hui (toutes sources)
CREATE OR REPLACE FUNCTION get_total_orders_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_count INTEGER;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    SELECT COUNT(*) INTO order_count
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE;

    RETURN COALESCE(order_count, 0);
END;
$$;

-- 8. Fonction principale pour récupérer tous les KPI du dashboard
CREATE OR REPLACE FUNCTION get_restaurant_dashboard_kpis(establishment_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
    qr_scans_today INTEGER;
    qr_scans_yesterday INTEGER;
    qr_orders_today INTEGER;
    avg_qr_order_value DECIMAL(10,2);
    satisfaction_data JSON;
    avg_time_per_scan INTEGER;
    total_orders_today INTEGER;
    conversion_rate DECIMAL(5,2);
    scans_growth DECIMAL(5,2);
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
    -- Récupérer toutes les métriques
    qr_scans_today := get_qr_scans_today(establishment_uuid);
    qr_scans_yesterday := get_qr_scans_yesterday(establishment_uuid);
    qr_orders_today := get_qr_orders_today(establishment_uuid);
    avg_qr_order_value := get_avg_qr_order_value_today(establishment_uuid);
    satisfaction_data := get_customer_satisfaction(establishment_uuid);
    avg_time_per_scan := get_avg_time_per_scan(establishment_uuid);
    total_orders_today := get_total_orders_today(establishment_uuid);

    -- Calculer le taux de conversion
    conversion_rate := CASE
        WHEN qr_scans_today > 0 THEN (qr_orders_today::DECIMAL / qr_scans_today::DECIMAL) * 100
        ELSE 0
    END;

    -- Calculer la croissance des scans
    scans_growth := CASE
        WHEN qr_scans_yesterday > 0 THEN ((qr_scans_today::DECIMAL - qr_scans_yesterday::DECIMAL) / qr_scans_yesterday::DECIMAL) * 100
        ELSE 0
    END;

    -- Construire le résultat JSON
    result := json_build_object(
        'qr_scans_today', qr_scans_today,
        'conversion_rate', ROUND(conversion_rate, 1),
        'avg_qr_order_value', ROUND(avg_qr_order_value, 2),
        'customer_satisfaction', satisfaction_data,
        'avg_time_per_scan', avg_time_per_scan,
        'total_orders_today', total_orders_today,
        'scans_growth', ROUND(scans_growth, 1)
    );

    RETURN result;
END;
$$;

-- ==========================================
-- GRANT PERMISSIONS
-- ==========================================

-- Donner accès aux fonctions aux utilisateurs authentifiés
GRANT EXECUTE ON FUNCTION get_qr_scans_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_qr_scans_yesterday(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_qr_orders_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_avg_qr_order_value_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_satisfaction(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_avg_time_per_scan(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_total_orders_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_restaurant_dashboard_kpis(UUID) TO authenticated;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '🎯 DASHBOARD KPI FUNCTIONS CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Available functions:';
    RAISE NOTICE '   - get_qr_scans_today(establishment_uuid)';
    RAISE NOTICE '   - get_qr_orders_today(establishment_uuid)';
    RAISE NOTICE '   - get_avg_qr_order_value_today(establishment_uuid)';
    RAISE NOTICE '   - get_customer_satisfaction(establishment_uuid)';
    RAISE NOTICE '   - get_avg_time_per_scan(establishment_uuid)';
    RAISE NOTICE '   - get_total_orders_today(establishment_uuid)';
    RAISE NOTICE '   - get_restaurant_dashboard_kpis(establishment_uuid) [MAIN FUNCTION]';
    RAISE NOTICE '✅ Ready to use in dashboard!';
END $$;







CREATE OR REPLACE FUNCTION get_restaurant_kpis(establishment_uuid UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
  today_start TIMESTAMP;
  yesterday_start TIMESTAMP;
BEGIN
  PERFORM assert_establishment_access(establishment_uuid);
  today_start := CURRENT_DATE;
  yesterday_start := CURRENT_DATE - INTERVAL '1 day';

  SELECT json_build_object(
    -- ========== COMMANDES ==========
    'orders_count_today', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status != 'cancelled'
    ),
    
    'orders_count_yesterday', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
        AND status != 'cancelled'
    ),
    
    'orders_count_total', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status != 'cancelled'
    ),
    
    -- ========== MONTANT TOTAL ==========
    'revenue_today', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_yesterday', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_total', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_this_month', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= DATE_TRUNC('month', CURRENT_DATE)
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== PANIER MOYEN ==========
    'avg_order_value_today', (
      SELECT COALESCE(ROUND(AVG(total_amount), 0), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'avg_order_value_overall', (
      SELECT COALESCE(ROUND(AVG(total_amount), 0), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== SCANS QR ==========
    'qr_scans_today', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
    ),
    
    'qr_scans_yesterday', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
    ),
    
    'qr_scans_total', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
    ),
    
    -- ========== TAUX DE CONVERSION QR ==========
    -- 'conversion_rate', (
    --   WITH qr_sessions AS (
    --     SELECT DISTINCT session_id
    --     FROM qr_scans
    --     WHERE establishment_id = establishment_uuid
    --       AND created_at >= today_start
    --       AND session_id IS NOT NULL
    --   ),
    --   orders_from_qr AS (
    --     SELECT COUNT(DISTINCT o.id) as order_count
    --     FROM orders o
    --     INNER JOIN qr_scans qs ON o.establishment_id = qs.establishment_id
    --       AND o.table_number = qs.table_number
    --       AND o.created_at >= qs.created_at
    --       AND o.created_at <= qs.created_at + INTERVAL '30 minutes'
    --     WHERE o.establishment_id = establishment_uuid
    --       AND o.created_at >= today_start
    --       AND o.status != 'cancelled'
    --   )
    --   SELECT CASE 
    --     WHEN (SELECT COUNT(*) FROM qr_sessions) > 0
    --     THEN ROUND(((SELECT order_count FROM orders_from_qr)::DECIMAL / (SELECT COUNT(*) FROM qr_sessions) * 100), 1)
    --     ELSE 0
    --   END
    -- ),
    
    -- ========== PANIER MOYEN QR ==========
    'avg_qr_order_value', (
      SELECT COALESCE(ROUND(AVG(o.total_amount), 0), 0)
      FROM orders o
      INNER JOIN qr_scans qs ON o.establishment_id = qs.establishment_id
        AND o.table_number = qs.table_number
        AND o.created_at >= qs.created_at
        AND o.created_at <= qs.created_at + INTERVAL '30 minutes'
      WHERE o.establishment_id = establishment_uuid
        AND o.created_at >= today_start
        AND o.status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== CROISSANCE ==========
    'orders_growth', (
      SELECT CASE 
        WHEN COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) > 0
        THEN ROUND(
          ((COUNT(*) FILTER (WHERE created_at >= today_start)::DECIMAL 
          - COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start))
          / COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) * 100), 1
        )
        ELSE CASE 
          WHEN COUNT(*) FILTER (WHERE created_at >= today_start) > 0 THEN 100
          ELSE 0
        END
      END
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status != 'cancelled'
    ),
    
    'revenue_growth', (
      SELECT CASE 
        WHEN COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 0) > 0
        THEN ROUND(
          ((COALESCE(SUM(total_amount) FILTER (WHERE created_at >= today_start), 0) 
          - COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 0))
          / COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 1) * 100), 1
        )
        ELSE CASE 
          WHEN COALESCE(SUM(total_amount) FILTER (WHERE created_at >= today_start), 0) > 0 THEN 100
          ELSE 0
        END
      END
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'scans_growth', (
      SELECT CASE 
        WHEN COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) > 0
        THEN ROUND(
          ((COUNT(*) FILTER (WHERE created_at >= today_start)::DECIMAL 
          - COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start))
          / COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) * 100), 1
        )
        ELSE CASE 
          WHEN COUNT(*) FILTER (WHERE created_at >= today_start) > 0 THEN 100
          ELSE 0
        END
      END
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
    ),
    
    -- ========== STATUTS DES COMMANDES ==========
    'orders_by_status', (
      SELECT json_object_agg(status, count)
      FROM (
        SELECT status, COUNT(*) as count
        FROM orders
        WHERE establishment_id = establishment_uuid
          AND created_at >= today_start
        GROUP BY status
      ) status_counts
    ),
    
    -- ========== TOP 5 PRODUITS ==========
    'top_products', (
      SELECT json_agg(row_to_json(t))
      FROM (
        SELECT 
          p.name,
          SUM(oi.quantity) as quantity_sold,
          SUM(oi.subtotal) as revenue
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        JOIN orders o ON oi.order_id = o.id
        WHERE o.establishment_id = establishment_uuid
          AND o.created_at >= today_start
          AND o.status IN ('confirmed', 'processing', 'completed')
        GROUP BY p.id, p.name
        ORDER BY quantity_sold DESC
        LIMIT 5
      ) t
    )
    
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;
-- ##### migration_secure_order_creation.sql (fonctions, vue, trigger) #####

-- 4. Créer une fonction helper pour vérifier si un établissement peut recevoir des commandes
CREATE OR REPLACE FUNCTION can_receive_orders(establishment_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    establishment_active BOOLEAN;
    owner_active BOOLEAN;
BEGIN
    -- Vérifier le statut de l'établissement et de son propriétaire
    SELECT e.is_active, u.is_active
    INTO establishment_active, owner_active
    FROM establishments e
    INNER JOIN users u ON e.user_id = u.id
    WHERE e.id = establishment_uuid;
    
    -- Retourner true seulement si les deux sont actifs
    RETURN (establishment_active = true AND owner_active = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Ajouter un commentaire sur la fonction
COMMENT ON FUNCTION can_receive_orders(UUID) IS 
'Vérifie si un établissement peut recevoir des commandes. 
Retourne true uniquement si l''établissement ET son propriétaire sont actifs.';

-- 6. Créer une vue pour les établissements actifs disponibles pour les commandes
CREATE OR REPLACE VIEW active_establishments_for_orders AS
SELECT 
    e.id,
    e.name,
    e.slug,
    e.description,
    e.image_url,
    e.address,
    e.phone,
    e.is_active as establishment_active,
    u.is_active as owner_active,
    u.full_name as owner_name
FROM establishments e
INNER JOIN users u ON e.user_id = u.id
WHERE e.is_active = true
  AND u.is_active = true;

-- 7. Ajouter un commentaire sur la vue
COMMENT ON VIEW active_establishments_for_orders IS 
'Vue des établissements actifs avec propriétaires actifs, disponibles pour recevoir des commandes.';

-- 8. Créer un trigger pour bloquer automatiquement les commandes en cours
-- si un propriétaire est désactivé
CREATE OR REPLACE FUNCTION block_pending_orders_on_owner_deactivation()
RETURNS TRIGGER AS $$
BEGIN
    -- Si le propriétaire est désactivé
    IF NEW.is_active = false AND OLD.is_active = true THEN
        -- Annuler toutes les commandes en attente de ses établissements
        UPDATE orders o
        SET 
            status = 'cancelled',
            notes = COALESCE(notes || E'\n\n', '') || 
                    'Commande annulée automatiquement - Compte propriétaire désactivé le ' || 
                    NOW()::timestamp::text,
            updated_at = NOW()
        FROM establishments e
        WHERE o.establishment_id = e.id
          AND e.user_id = NEW.id
          AND o.status IN ('pending', 'processing')
          AND o.updated_at > NOW() - INTERVAL '24 hours'; -- Seulement les commandes récentes
        
        -- Log l'action
        RAISE NOTICE 'Commandes en attente annulées pour le propriétaire %', NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Créer le trigger
DROP TRIGGER IF EXISTS trigger_block_orders_on_owner_deactivation ON users;
CREATE TRIGGER trigger_block_orders_on_owner_deactivation
    AFTER UPDATE OF is_active ON users
    FOR EACH ROW
    WHEN (NEW.role IN ('owner', 'manager'))
    EXECUTE FUNCTION block_pending_orders_on_owner_deactivation();

-- 10. Ajouter des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_establishments_user_active 
ON establishments(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_users_active 
ON users(is_active);


-- ##########################################################################
-- 3. DURCISSEMENT SECURITE
-- ##########################################################################
-- KULA QR - DURCISSEMENT SECURITE
-- ==========================================
-- A executer apres 01_features.sql

-- ==========================================
-- USERS : un utilisateur ne peut pas modifier son role, son statut ou son abonnement
-- ==========================================
-- Les politiques RLS autorisent "update own profile" sur toute la ligne :
-- sans ce trigger, n'importe qui pourrait se passer admin ou prolonger son abonnement.
CREATE OR REPLACE FUNCTION protect_user_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- service_role, admin, trigger d'inscription (supabase_auth_admin) et acces direct : pas de restriction
    IF COALESCE(auth.role(), '') = 'service_role'
       OR session_user NOT IN ('authenticator', 'anon', 'authenticated')
       OR is_admin_user() THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' THEN
        NEW.role := 'owner';
        NEW.status := 'active';
        NEW.is_active := false;
        NEW.subscription_tier := 'demo';
        NEW.subscription_status := 'active';
        NEW.subscription_starts_at := NOW();
        NEW.subscription_ends_at := NOW() + INTERVAL '7 days';
        RETURN NEW;
    END IF;

    IF NEW.role IS DISTINCT FROM OLD.role
       OR NEW.status IS DISTINCT FROM OLD.status
       OR NEW.is_active IS DISTINCT FROM OLD.is_active
       OR NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier
       OR NEW.subscription_status IS DISTINCT FROM OLD.subscription_status
       OR NEW.subscription_starts_at IS DISTINCT FROM OLD.subscription_starts_at
       OR NEW.subscription_ends_at IS DISTINCT FROM OLD.subscription_ends_at THEN
        RAISE EXCEPTION 'Modification du role, du statut ou de l''abonnement reservee aux administrateurs'
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_user_privileged_columns ON users;
CREATE TRIGGER protect_user_privileged_columns
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION protect_user_privileged_columns();

-- ==========================================
-- ACTIVITIES : le code insere des activites depuis le navigateur
-- ==========================================
DROP POLICY IF EXISTS "Users can log their own activities" ON activities;
CREATE POLICY "Users can log their own activities" ON activities
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid() OR is_admin_user());

-- ==========================================
-- TABLES D'ADMINISTRATION SANS RLS
-- ==========================================
-- Sans RLS, ces tables etaient lisibles et modifiables avec la cle anon.
-- Le cron utilise la cle service_role, qui contourne RLS.
ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_blocks_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins manage notifications" ON admin_notifications;
CREATE POLICY "Admins manage notifications" ON admin_notifications
    FOR ALL USING (is_admin_user()) WITH CHECK (is_admin_user());

DROP POLICY IF EXISTS "Admins read block logs" ON subscription_blocks_log;
CREATE POLICY "Admins read block logs" ON subscription_blocks_log
    FOR SELECT USING (is_admin_user());

-- ==========================================
-- VUES : appliquer le RLS de l'utilisateur qui interroge
-- ==========================================
-- Par defaut une vue s'execute avec les droits de son proprietaire (postgres) et
-- contourne le RLS : current_orders, recent_orders, subscription_stats... etaient
-- lisibles par tous via l'API. Avec security_invoker, chacun ne voit que ses donnees.
DO $$
DECLARE
    v RECORD;
BEGIN
    FOR v IN SELECT viewname FROM pg_views WHERE schemaname = 'public' LOOP
        EXECUTE format('ALTER VIEW public.%I SET (security_invoker = true)', v.viewname);
    END LOOP;
END $$;

-- ==========================================
-- FONCTIONS INTERNES : pas d'appel anonyme via l'API
-- ==========================================
REVOKE EXECUTE ON FUNCTION log_activity(UUID, VARCHAR, VARCHAR, UUID, JSONB, VARCHAR, TEXT) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION log_user_activity(VARCHAR, VARCHAR, UUID, JSONB) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION create_admin_notification(TEXT, UUID, TEXT, TEXT, TEXT) FROM PUBLIC, anon;

COMMIT;
