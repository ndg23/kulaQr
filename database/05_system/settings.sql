-- ==========================================
-- KULA QR - SYSTEM SETTINGS
-- ==========================================
-- Paramètres système et configurations
-- Fait partie du module 05_system

-- ==========================================
-- SYSTEM SETTINGS TABLE
-- ==========================================

-- System settings table (already created in core, but data here)
CREATE TABLE IF NOT EXISTS system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- DEFAULT SYSTEM SETTINGS
-- ==========================================

-- Insert default system settings
INSERT INTO system_settings (key, value, description, is_public) VALUES
('app_name', '"Kula QR"', 'Application name', true),
('app_version', '"1.0.0"', 'Current application version', true),
('max_free_establishments', '1', 'Maximum establishments for free accounts', true),
('max_free_products', '20', 'Maximum products for free accounts', true),
('max_free_categories', '5', 'Maximum categories for free accounts', true),
('subscription_prices', '{
  "basic": {"price": 5000, "currency": "XOF", "features": ["unlimited_products", "unlimited_categories", "qr_codes", "basic_analytics"]},
  "premium": {"price": 15000, "currency": "XOF", "features": ["all_basic_features", "advanced_analytics", "custom_domain", "priority_support"]},
  "enterprise": {"price": 50000, "currency": "XOF", "features": ["all_premium_features", "white_label", "api_access", "dedicated_support"]}
}', 'Subscription pricing and features', true),
('qr_code_expiry', '3600', 'QR code validity in seconds (1 hour)', false),
('session_timeout', '28800', 'User session timeout in seconds (8 hours)', false),
('max_login_attempts', '5', 'Maximum login attempts before lockout', false),
('lockout_duration', '900', 'Account lockout duration in seconds (15 minutes)', false),
('backup_frequency', 'daily', 'Database backup frequency', false),
('log_retention_days', '90', 'Log retention period in days', false),
('email_notifications', 'true', 'Enable email notifications', false),
('sms_notifications', 'false', 'Enable SMS notifications', false),
('maintenance_mode', 'false', 'System maintenance mode', true),
('maintenance_message', '"Service temporairement indisponible pour maintenance"', 'Maintenance mode message', true),
('support_email', '"support@kulacr.com"', 'Support email address', true),
('support_phone', '""', 'Support phone number', true),
('currency_symbol', '"FCFA"', 'Default currency symbol', true),
('timezone', '"Africa/Dakar"', 'Default timezone', true),
('language', '"fr"', 'Default language', true),
('date_format', '"DD/MM/YYYY"', 'Default date format', true),
('time_format', '"HH:mm"', 'Default time format', true),
('max_file_upload_size', '5242880', 'Maximum file upload size in bytes (5MB)', false),
('allowed_file_types', '["image/jpeg", "image/png", "image/webp"]', 'Allowed file types for uploads', false),
('image_max_width', '1920', 'Maximum image width in pixels', false),
('image_max_height', '1080', 'Maximum image height in pixels', false),
('cache_ttl', '3600', 'Cache time-to-live in seconds', false),
('rate_limit_requests', '100', 'Rate limit requests per minute', false),
('rate_limit_window', '60', 'Rate limit window in seconds', false),
('analytics_retention_days', '365', 'Analytics data retention in days', false),
('gdpr_compliance', 'true', 'GDPR compliance enabled', false),
('data_export_days', '30', 'Data export processing time in days', true),
('api_rate_limit', '1000', 'API rate limit per hour', false),
('webhook_timeout', '30', 'Webhook timeout in seconds', false),
('feature_flags', '{
  "new_ui": true,
  "advanced_analytics": false,
  "multi_language": false,
  "social_login": false,
  "payment_integration": true
}', 'Feature flags for enabling/disabling features', false)
ON CONFLICT (key) DO NOTHING;

-- ==========================================
-- SYSTEM SETTINGS FUNCTIONS
-- ==========================================

-- Get system setting function
CREATE OR REPLACE FUNCTION get_system_setting(p_key TEXT)
RETURNS JSONB AS $$
BEGIN
    RETURN (SELECT value FROM system_settings WHERE key = p_key);
END;
$$ LANGUAGE plpgsql;

-- Set system setting function
CREATE OR REPLACE FUNCTION set_system_setting(p_key TEXT, p_value JSONB, p_description TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO system_settings (key, value, description)
    VALUES (p_key, p_value, p_description)
    ON CONFLICT (key) DO UPDATE SET
        value = EXCLUDED.value,
        description = COALESCE(EXCLUDED.description, system_settings.description),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Get public settings function
CREATE OR REPLACE FUNCTION get_public_settings()
RETURNS JSONB AS $$
DECLARE
    v_result JSONB := '{}';
    v_setting RECORD;
BEGIN
    FOR v_setting IN SELECT key, value FROM system_settings WHERE is_public = true
    LOOP
        v_result := v_result || jsonb_build_object(v_setting.key, v_setting.value);
    END LOOP;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Update system setting function
CREATE OR REPLACE FUNCTION update_system_setting(p_key TEXT, p_value JSONB)
RETURNS VOID AS $$
BEGIN
    UPDATE system_settings
    SET value = p_value, updated_at = NOW()
    WHERE key = p_key;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'System setting % not found', p_key;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- CONFIGURATION MANAGEMENT FUNCTIONS
-- ==========================================

-- Get configuration by category function
CREATE OR REPLACE FUNCTION get_config_by_category(p_category TEXT)
RETURNS TABLE (
    key TEXT,
    value JSONB,
    description TEXT,
    is_public BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.key,
        s.value,
        s.description,
        s.is_public
    FROM system_settings s
    WHERE s.key LIKE p_category || '.%'
       OR s.key = p_category
    ORDER BY s.key;
END;
$$ LANGUAGE plpgsql;

-- Bulk update settings function
CREATE OR REPLACE FUNCTION bulk_update_settings(p_settings JSONB)
RETURNS VOID AS $$
DECLARE
    v_key TEXT;
    v_value JSONB;
BEGIN
    FOR v_key, v_value IN SELECT * FROM jsonb_object_keys(p_settings)
    LOOP
        PERFORM set_system_setting(v_key, p_settings->v_key);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- SYSTEM HEALTH FUNCTIONS
-- ==========================================

-- Get system health status function
CREATE OR REPLACE FUNCTION get_system_health()
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_db_size TEXT;
    v_active_connections INTEGER;
    v_total_users INTEGER;
    v_total_establishments INTEGER;
    v_total_orders INTEGER;
BEGIN
    -- Get database size
    SELECT pg_size_pretty(pg_database_size(current_database())) INTO v_db_size;

    -- Get active connections
    SELECT COUNT(*) INTO v_active_connections
    FROM pg_stat_activity
    WHERE state = 'active';

    -- Get system stats
    SELECT
        COUNT(DISTINCT u.id) as users,
        COUNT(DISTINCT e.id) as establishments,
        COUNT(DISTINCT o.id) as orders
    INTO v_total_users, v_total_establishments, v_total_orders
    FROM users u
    CROSS JOIN establishments e
    CROSS JOIN orders o;

    v_result := jsonb_build_object(
        'status', 'healthy',
        'timestamp', NOW(),
        'database', jsonb_build_object(
            'size', v_db_size,
            'active_connections', v_active_connections
        ),
        'stats', jsonb_build_object(
            'total_users', v_total_users,
            'total_establishments', v_total_establishments,
            'total_orders', v_total_orders
        ),
        'maintenance_mode', get_system_setting('maintenance_mode'),
        'version', get_system_setting('app_version')
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- MAINTENANCE FUNCTIONS
-- ==========================================

-- Enable maintenance mode function
CREATE OR REPLACE FUNCTION enable_maintenance_mode(p_message TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    PERFORM set_system_setting('maintenance_mode', 'true');
    IF p_message IS NOT NULL THEN
        PERFORM set_system_setting('maintenance_message', to_jsonb(p_message));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Disable maintenance mode function
CREATE OR REPLACE FUNCTION disable_maintenance_mode()
RETURNS VOID AS $$
BEGIN
    PERFORM set_system_setting('maintenance_mode', 'false');
END;
$$ LANGUAGE plpgsql;

-- Clean old logs function
CREATE OR REPLACE FUNCTION clean_old_logs(p_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    -- Delete old staff activity logs
    DELETE FROM staff_activity_logs
    WHERE created_at < CURRENT_DATE - INTERVAL '1 day' * p_days;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    -- Log the cleanup
    INSERT INTO staff_activity_logs (staff_id, establishment_id, activity_type, details)
    VALUES (NULL, NULL, 'system_cleanup', jsonb_build_object('deleted_logs', v_deleted_count, 'days', p_days));

    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- BACKUP AND RECOVERY FUNCTIONS
-- ==========================================

-- Create backup metadata function
CREATE OR REPLACE FUNCTION create_backup_metadata(p_backup_type TEXT, p_size_bytes BIGINT DEFAULT NULL)
RETURNS UUID AS $$
DECLARE
    v_backup_id UUID;
BEGIN
    INSERT INTO system_settings (key, value, description)
    VALUES (
        'backup_' || gen_random_uuid()::TEXT,
        jsonb_build_object(
            'type', p_backup_type,
            'created_at', NOW(),
            'size_bytes', p_size_bytes,
            'status', 'completed'
        ),
        'Database backup metadata'
    ) RETURNING id INTO v_backup_id;

    RETURN v_backup_id;
END;
$$ LANGUAGE plpgsql;

-- Get backup history function
CREATE OR REPLACE FUNCTION get_backup_history(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
    backup_id UUID,
    backup_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    size_bytes BIGINT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        (s.value->>'type')::TEXT as backup_type,
        (s.value->>'created_at')::TIMESTAMP WITH TIME ZONE as created_at,
        (s.value->>'size_bytes')::BIGINT as size_bytes,
        (s.value->>'status')::TEXT as status
    FROM system_settings s
    WHERE s.key LIKE 'backup_%'
    ORDER BY s.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ SYSTEM SETTINGS CREATED SUCCESSFULLY!';
    RAISE NOTICE '⚙️ System configuration and settings ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/05_system/settings.sql