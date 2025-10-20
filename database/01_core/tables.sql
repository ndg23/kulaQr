-- ==========================================
-- KULA QR - CORE TABLES
-- ==========================================
-- Tables principales du système
-- Fait partie du module 01_core

-- ==========================================
-- USERS & AUTHENTICATION
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

-- ==========================================
-- ESTABLISHMENTS & BUSINESS
-- ==========================================

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

-- ==========================================
-- STAFF MANAGEMENT
-- ==========================================

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

-- ==========================================
-- PRODUCTS & CATEGORIES
-- ==========================================

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

-- ==========================================
-- ORDERS & TRANSACTIONS
-- ==========================================

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_id UUID REFERENCES tables(id),
    table_number INTEGER,
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

-- ==========================================
-- QR SYSTEM
-- ==========================================

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET,
    referrer TEXT
);

-- ==========================================
-- SYSTEM TABLES
-- ==========================================

-- Tables (restaurant tables)
CREATE TABLE tables (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    type VARCHAR(20) DEFAULT 'SIMPLE' CHECK (type IN ('VIP', 'SIMPLE')),
    zone VARCHAR(100) DEFAULT 'ETAGE',
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
    description TEXT,
    qr_code_url TEXT,
    qr_code_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Contrainte unique pour éviter les doublons de numéros de table dans un établissement
    UNIQUE(establishment_id, number)
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
-- SYSTEM SETTINGS
-- ==========================================

-- System settings table
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- ACTIVITY TRACKING
-- ==========================================

-- Activities table for user action tracking
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_location VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ CORE TABLES CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Total tables created: %', (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public');
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/01_core/tables.sql