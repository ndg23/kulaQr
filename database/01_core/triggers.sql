-- ==========================================
-- KULA QR - CORE TRIGGERS
-- ==========================================
-- Triggers automatiques pour maintenir la cohérence des données
-- Fait partie du module 01_core

-- ==========================================
-- TIMESTAMP TRIGGERS
-- ==========================================

-- Users updated_at trigger
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Establishments updated_at trigger
CREATE TRIGGER establishments_updated_at
    BEFORE UPDATE ON establishments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Tables updated_at trigger
CREATE TRIGGER tables_updated_at
    BEFORE UPDATE ON tables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Orders updated_at trigger
CREATE TRIGGER orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Staff updated_at trigger
CREATE TRIGGER staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ==========================================
-- BUSINESS LOGIC TRIGGERS
-- ==========================================

-- Establishment slug generation trigger
CREATE TRIGGER establishment_slug_trigger
    BEFORE INSERT OR UPDATE ON establishments
    FOR EACH ROW
    EXECUTE FUNCTION generate_establishment_slug();

-- Product count update trigger
CREATE TRIGGER products_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_category_product_count();

-- Table status update trigger
CREATE TRIGGER update_table_status_trigger
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_table_status_on_order();

-- ==========================================
-- AUTHENTICATION TRIGGERS
-- ==========================================

-- Handle new user creation trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Handle user login tracking trigger
CREATE TRIGGER on_auth_user_login
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    WHEN (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
    EXECUTE FUNCTION public.handle_user_login();

-- ==========================================
-- ACTIVITY TRACKING TRIGGERS
-- ==========================================

-- Track user changes trigger
CREATE TRIGGER track_user_changes
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION track_user_changes();

-- Track establishment changes trigger
CREATE TRIGGER track_establishment_changes
    AFTER INSERT OR UPDATE OR DELETE ON establishments
    FOR EACH ROW EXECUTE FUNCTION track_establishment_changes();

-- Track category changes trigger
CREATE TRIGGER track_category_changes
    AFTER INSERT OR UPDATE OR DELETE ON categories
    FOR EACH ROW EXECUTE FUNCTION track_category_changes();

-- Track product changes trigger
CREATE TRIGGER track_product_changes
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION track_product_changes();

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ CORE TRIGGERS CREATED SUCCESSFULLY!';
    RAISE NOTICE '⚡ Total triggers created: %', (SELECT COUNT(*) FROM pg_trigger WHERE tgname NOT LIKE 'pg_%');
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/01_core/triggers.sql