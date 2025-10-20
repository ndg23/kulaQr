-- ==========================================
-- KULA QR - DATABASE INDEXES
-- ==========================================
-- Index de performance pour optimiser les requêtes
-- Fait partie du module 01_core

-- ==========================================
-- USERS INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_subscription_tier ON users(subscription_tier);
CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login);

-- ==========================================
-- ESTABLISHMENTS INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_establishments_user_id ON establishments(user_id);
CREATE INDEX IF NOT EXISTS idx_establishments_slug ON establishments(slug);
CREATE INDEX IF NOT EXISTS idx_establishments_active ON establishments(is_active);
CREATE INDEX IF NOT EXISTS idx_establishments_type_id ON establishments(type_id);
CREATE INDEX IF NOT EXISTS idx_establishments_subscription_type ON establishments(subscription_type);
CREATE INDEX IF NOT EXISTS idx_establishments_created_at ON establishments(created_at);

-- ==========================================
-- STAFF INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_staff_establishment_id ON staff(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);
CREATE INDEX IF NOT EXISTS idx_staff_role ON staff(role);
CREATE INDEX IF NOT EXISTS idx_staff_last_login ON staff(last_login);

-- ==========================================
-- CATEGORIES INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_categories_establishment_id ON categories(establishment_id);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_order_number ON categories(order_number);

-- ==========================================
-- PRODUCTS INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_establishment_id ON products(establishment_id);
CREATE INDEX IF NOT EXISTS idx_products_available ON products(is_available);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_order_number ON products(order_number);
CREATE INDEX IF NOT EXISTS idx_products_orders_count ON products(orders_count);

-- ==========================================
-- TABLES INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_tables_establishment_id ON tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_tables_type ON tables(type);
CREATE INDEX IF NOT EXISTS idx_tables_status ON tables(status);
CREATE INDEX IF NOT EXISTS idx_tables_zone ON tables(zone);
CREATE INDEX IF NOT EXISTS idx_tables_number ON tables(establishment_id, number);
CREATE INDEX IF NOT EXISTS idx_tables_qr_generated ON tables(qr_code_generated);

-- ==========================================
-- ORDERS INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_id ON orders(table_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_number ON orders(table_number);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_updated_at ON orders(updated_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_total_amount ON orders(total_amount);

-- ==========================================
-- ORDER ITEMS INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_quantity ON order_items(quantity);

-- ==========================================
-- QR SYSTEM INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_qr_codes_establishment_id ON qr_codes(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_codes_table_number ON qr_codes(table_number);

CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at);
CREATE INDEX IF NOT EXISTS idx_qr_scans_ip_address ON qr_scans(ip_address);

-- ==========================================
-- ACTIVITY TRACKING INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_staff_id ON staff_activity_logs(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_establishment_id ON staff_activity_logs(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_created_at ON staff_activity_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_action ON staff_activity_logs(action);

CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_action_type ON activities(action_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_type ON activities(entity_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_id ON activities(entity_id);
CREATE INDEX IF NOT EXISTS idx_activities_created_at ON activities(created_at);

-- ==========================================
-- SYSTEM INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_system_settings_key ON system_settings(key);
CREATE INDEX IF NOT EXISTS idx_system_settings_category ON system_settings(category);
CREATE INDEX IF NOT EXISTS idx_system_settings_created_at ON system_settings(created_at);

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ DATABASE INDEXES CREATED SUCCESSFULLY!';
    RAISE NOTICE '🔍 Total indexes created: %', (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public');
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/01_core/indexes.sql