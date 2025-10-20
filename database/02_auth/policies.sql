-- ==========================================
-- KULA QR - ROW LEVEL SECURITY POLICIES
-- ==========================================
-- Politiques de sécurité pour toutes les tables
-- Fait partie du module 02_auth

-- ==========================================
-- ENABLE RLS ON ALL TABLES
-- ==========================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
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
ALTER TABLE establishment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- USERS POLICIES
-- ==========================================

CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow user registration" ON users
    FOR INSERT WITH CHECK (true);

-- ==========================================
-- ESTABLISHMENTS POLICIES
-- ==========================================

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

-- ==========================================
-- STAFF POLICIES
-- ==========================================

-- Staff viewable by establishment owners
CREATE POLICY "Staff viewable by establishment owners" ON staff
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM establishments
            WHERE id = staff.establishment_id AND user_id = auth.uid()
        ) OR is_admin_user()
    );

-- Unified staff management policy
CREATE POLICY "Staff unified policy" ON staff
    FOR ALL USING (
        -- Establishment owners can manage their staff
        EXISTS (
            SELECT 1 FROM establishments
            WHERE id = staff.establishment_id AND user_id = auth.uid()
        ) OR
        -- Admins can manage everything
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- ==========================================
-- CATEGORIES POLICIES
-- ==========================================

CREATE POLICY "Categories are viewable by everyone" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Categories manageable by establishment owners" ON categories
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = categories.establishment_id
        ) OR is_admin_user()
    );

-- ==========================================
-- PRODUCTS POLICIES
-- ==========================================

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

-- ==========================================
-- TABLES POLICIES
-- ==========================================

CREATE POLICY "Tables viewable by establishment staff" ON tables
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = tables.establishment_id
        ) OR
        auth.uid() IN (
            SELECT id FROM staff WHERE establishment_id = tables.establishment_id
        ) OR
        is_admin_user()
    );

CREATE POLICY "Tables manageable by establishment owners" ON tables
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = tables.establishment_id
        ) OR is_admin_user()
    );

-- ==========================================
-- ORDERS POLICIES
-- ==========================================

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

-- ==========================================
-- ORDER ITEMS POLICIES
-- ==========================================

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

-- ==========================================
-- QR CODES POLICIES
-- ==========================================

CREATE POLICY "QR codes manageable by establishment owners" ON qr_codes
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = qr_codes.establishment_id
        ) OR is_admin_user()
    );

-- ==========================================
-- QR SCANS POLICIES
-- ==========================================

CREATE POLICY "QR scans viewable by establishment owners" ON qr_scans
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = qr_scans.establishment_id
        ) OR is_admin_user()
    );

CREATE POLICY "Allow anonymous QR scan tracking" ON qr_scans
    FOR INSERT WITH CHECK (true);

-- ==========================================
-- STAFF ACTIVITY LOGS POLICIES
-- ==========================================

CREATE POLICY "Activity logs viewable by establishment owners" ON staff_activity_logs
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = staff_activity_logs.establishment_id
        ) OR is_admin_user()
    );

-- ==========================================
-- ESTABLISHMENT TYPES POLICIES
-- ==========================================

CREATE POLICY "Establishment types are publicly viewable" ON establishment_types
    FOR SELECT USING (is_active = true);

-- ==========================================
-- ACTIVITIES POLICIES
-- ==========================================

CREATE POLICY "Users can view their own activities" ON activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all activities" ON activities
    FOR SELECT USING (
        auth.uid() IN (
            SELECT id FROM users WHERE role = 'admin'
        )
    );

-- ==========================================
-- SYSTEM SETTINGS POLICIES
-- ==========================================

CREATE POLICY "Admins can manage system settings" ON system_settings
    FOR ALL USING (is_admin_user());

CREATE POLICY "System settings are viewable by authenticated users" ON system_settings
    FOR SELECT USING (auth.role() = 'authenticated');

-- ==========================================
-- ADMIN OVERRIDE POLICIES
-- ==========================================

-- Admin policies (override all others)
CREATE POLICY "Admins can manage everything - establishments" ON establishments
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - categories" ON categories
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - products" ON products
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - tables" ON tables
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - orders" ON orders
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - qr_codes" ON qr_codes
    FOR ALL USING (is_admin_user());

CREATE POLICY "Admins can manage everything - establishment_types" ON establishment_types
    FOR ALL USING (is_admin_user());

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ ROW LEVEL SECURITY POLICIES CREATED SUCCESSFULLY!';
    RAISE NOTICE '🛡️ All tables secured with RLS policies';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/02_auth/policies.sql