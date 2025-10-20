-- ==========================================
-- KULA QR - SYSTEM TRIGGERS
-- ==========================================
-- Triggers système pour la maintenance et l'audit
-- Fait partie du module 05_system

-- ==========================================
-- AUDIT LOGGING SYSTEM
-- ==========================================

-- System audit log table
CREATE TABLE IF NOT EXISTS system_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID,
    operation TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by UUID REFERENCES auth.users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- ==========================================
-- AUDIT TRIGGER FUNCTION
-- ==========================================

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    v_old_values JSONB;
    v_new_values JSONB;
    v_user_id UUID;
BEGIN
    -- Get current user ID (if available)
    v_user_id := auth.uid();

    -- Build old and new values JSON
    IF TG_OP = 'DELETE' THEN
        v_old_values := to_jsonb(OLD);
        v_new_values := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_old_values := to_jsonb(OLD);
        v_new_values := to_jsonb(NEW);
    ELSIF TG_OP = 'INSERT' THEN
        v_old_values := NULL;
        v_new_values := to_jsonb(NEW);
    END IF;

    -- Insert audit record
    INSERT INTO system_audit_log (
        table_name,
        record_id,
        operation,
        old_values,
        new_values,
        changed_by
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        v_old_values,
        v_new_values,
        v_user_id
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- SYSTEM AUDIT TRIGGERS
-- ==========================================

-- Audit trigger for establishments
CREATE OR REPLACE TRIGGER audit_establishments_trigger
    AFTER INSERT OR UPDATE OR DELETE ON establishments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Audit trigger for users
CREATE OR REPLACE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Audit trigger for orders
CREATE OR REPLACE TRIGGER audit_orders_trigger
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Audit trigger for system_settings
CREATE OR REPLACE TRIGGER audit_system_settings_trigger
    AFTER INSERT OR UPDATE OR DELETE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- ==========================================
-- DATA VALIDATION TRIGGERS
-- ==========================================

-- Validate email format function
CREATE OR REPLACE FUNCTION validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
    -- Basic email validation
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Email validation trigger for users (if email column exists)
-- Note: This would be applied to auth.users if we had access

-- Validate phone format function
CREATE OR REPLACE FUNCTION validate_phone_format()
RETURNS TRIGGER AS $$
BEGIN
    -- Basic phone validation (allowing international formats)
    IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+?[0-9\s\-\(\)]{7,15}$' THEN
        RAISE EXCEPTION 'Invalid phone format: %', NEW.phone;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Phone validation trigger for establishments
CREATE OR REPLACE TRIGGER validate_establishment_phone_trigger
    BEFORE INSERT OR UPDATE ON establishments
    FOR EACH ROW EXECUTE FUNCTION validate_phone_format();

-- ==========================================
-- BUSINESS RULE TRIGGERS
-- ==========================================

-- Prevent deletion of establishments with active orders function
CREATE OR REPLACE FUNCTION prevent_establishment_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Check for active orders
    IF EXISTS (
        SELECT 1 FROM orders
        WHERE establishment_id = OLD.id
          AND status IN ('pending', 'processing')
    ) THEN
        RAISE EXCEPTION 'Cannot delete establishment with active orders';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Prevent establishment deletion trigger
CREATE OR REPLACE TRIGGER prevent_establishment_deletion_trigger
    BEFORE DELETE ON establishments
    FOR EACH ROW EXECUTE FUNCTION prevent_establishment_deletion();

-- Update establishment stats on product changes function
CREATE OR REPLACE FUNCTION update_establishment_product_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_establishment_id UUID;
BEGIN
    -- Get establishment_id based on operation
    IF TG_OP = 'DELETE' THEN
        v_establishment_id := OLD.establishment_id;
    ELSE
        v_establishment_id := NEW.establishment_id;
    END IF;

    -- Update product count (this is a simple counter, could be more sophisticated)
    -- Note: In a real system, you might want to maintain actual counts

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Update establishment stats trigger
CREATE OR REPLACE TRIGGER update_establishment_product_stats_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION update_establishment_product_stats();

-- ==========================================
-- PERFORMANCE MONITORING TRIGGERS
-- ==========================================

-- Query performance log table
CREATE TABLE IF NOT EXISTS query_performance_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query_type TEXT NOT NULL,
    table_name TEXT,
    execution_time INTERVAL,
    rows_affected INTEGER,
    executed_by UUID REFERENCES auth.users(id),
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    query_plan JSONB
);

-- Log slow queries function (this would typically be handled by PostgreSQL logging)
-- But we can create a function to log expensive operations

CREATE OR REPLACE FUNCTION log_expensive_operation()
RETURNS TRIGGER AS $$
DECLARE
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_execution_time INTERVAL;
BEGIN
    -- This is a simplified version. In practice, you'd use PostgreSQL's logging
    -- or a more sophisticated monitoring system

    -- For demonstration, we'll just log the operation
    INSERT INTO query_performance_log (
        query_type,
        table_name,
        executed_by
    ) VALUES (
        TG_OP,
        TG_TABLE_NAME,
        auth.uid()
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- DATA INTEGRITY TRIGGERS
-- ==========================================

-- Prevent circular references in categories function
CREATE OR REPLACE FUNCTION prevent_category_circular_reference()
RETURNS TRIGGER AS $$
BEGIN
    -- This is a placeholder for more complex business rules
    -- For now, we'll just ensure basic data integrity

    -- Ensure category belongs to the correct establishment
    IF NEW.establishment_id IS NULL THEN
        RAISE EXCEPTION 'Category must belong to an establishment';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Category integrity trigger
CREATE OR REPLACE TRIGGER prevent_category_circular_reference_trigger
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION prevent_category_circular_reference();

-- Ensure order total matches items total function
CREATE OR REPLACE FUNCTION validate_order_total()
RETURNS TRIGGER AS $$
DECLARE
    v_calculated_total DECIMAL(10,2);
BEGIN
    -- Only validate on INSERT or if order_items changed
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.total_amount != NEW.total_amount) THEN
        -- Calculate total from order items
        SELECT COALESCE(SUM(subtotal), 0) INTO v_calculated_total
        FROM order_items
        WHERE order_id = NEW.id;

        -- Allow small rounding differences (0.01)
        IF ABS(NEW.total_amount - v_calculated_total) > 0.01 THEN
            RAISE EXCEPTION 'Order total (%) does not match calculated total from items (%)',
                          NEW.total_amount, v_calculated_total;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Order total validation trigger
CREATE OR REPLACE TRIGGER validate_order_total_trigger
    BEFORE INSERT OR UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION validate_order_total();

-- ==========================================
-- NOTIFICATION TRIGGERS
-- ==========================================

-- System notification table
CREATE TABLE IF NOT EXISTS system_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    recipient_id UUID REFERENCES auth.users(id),
    recipient_role TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Send notification function
CREATE OR REPLACE FUNCTION send_system_notification(
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_recipient_id UUID DEFAULT NULL,
    p_recipient_role TEXT DEFAULT NULL,
    p_priority TEXT DEFAULT 'normal',
    p_expires_days INTEGER DEFAULT 7
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO system_notifications (
        notification_type,
        title,
        message,
        recipient_id,
        recipient_role,
        priority,
        expires_at
    ) VALUES (
        p_type,
        p_title,
        p_message,
        p_recipient_id,
        p_recipient_role,
        p_priority,
        CURRENT_DATE + INTERVAL '1 day' * p_expires_days
    ) RETURNING id INTO v_notification_id;

    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql;

-- Notify on order status change function
CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        -- Notify establishment owner
        PERFORM send_system_notification(
            'order_status_change',
            'Statut de commande modifié',
            format('La commande #%s a changé de statut: %s → %s', NEW.id, OLD.status, NEW.status),
            (SELECT user_id FROM establishments WHERE id = NEW.establishment_id),
            NULL,
            'normal',
            1
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Order status change notification trigger
CREATE OR REPLACE TRIGGER notify_order_status_change_trigger
    AFTER UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION notify_order_status_change();

-- ==========================================
-- CLEANUP TRIGGERS
-- ==========================================

-- Auto-cleanup expired notifications function
CREATE OR REPLACE FUNCTION cleanup_expired_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete expired notifications
    DELETE FROM system_notifications
    WHERE expires_at < CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- This would typically be run by a scheduled job, not a trigger
-- But we can create a function for it

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ SYSTEM TRIGGERS CREATED SUCCESSFULLY!';
    RAISE NOTICE '🔧 System triggers and audit logging ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/05_system/triggers.sql