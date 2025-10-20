-- ==========================================
-- KULA QR - ANALYTICS FUNCTIONS
-- ==========================================
-- Fonctions pour les analyses et statistiques
-- Fait partie du module 04_analytics

-- ==========================================
-- DASHBOARD STATISTICS FUNCTIONS
-- ==========================================

-- Get establishment dashboard stats function
CREATE OR REPLACE FUNCTION get_establishment_dashboard_stats(
    p_establishment_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS JSONB AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := CURRENT_DATE - INTERVAL '1 day' * p_days;
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'period_days', p_days,
        'total_orders', COALESCE(SUM(CASE WHEN o.created_at >= v_start_date THEN 1 ELSE 0 END), 0),
        'total_revenue', COALESCE(SUM(CASE WHEN o.created_at >= v_start_date THEN o.total_amount ELSE 0 END), 0),
        'avg_order_value', CASE
            WHEN COUNT(CASE WHEN o.created_at >= v_start_date THEN 1 END) > 0
            THEN COALESCE(SUM(CASE WHEN o.created_at >= v_start_date THEN o.total_amount ELSE 0 END) /
                         COUNT(CASE WHEN o.created_at >= v_start_date THEN 1 END), 0)
            ELSE 0
        END,
        'completed_orders', COALESCE(SUM(CASE WHEN o.created_at >= v_start_date AND o.status = 'completed' THEN 1 ELSE 0 END), 0),
        'cancelled_orders', COALESCE(SUM(CASE WHEN o.created_at >= v_start_date AND o.status = 'cancelled' THEN 1 ELSE 0 END), 0),
        'active_tables', COUNT(DISTINCT CASE WHEN t.status = 'occupied' THEN t.id END),
        'total_tables', COUNT(DISTINCT t.id),
        'popular_products', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'name', p.name,
                    'orders_count', p.orders_count,
                    'revenue', COALESCE(SUM(oi.subtotal), 0)
                )
            )
            FROM products p
            LEFT JOIN order_items oi ON p.id = oi.product_id
            LEFT JOIN orders o2 ON oi.order_id = o2.id AND o2.status = 'completed' AND o2.created_at >= v_start_date
            WHERE p.establishment_id = p_establishment_id AND p.is_available = true
            GROUP BY p.id, p.name, p.orders_count
            ORDER BY COALESCE(SUM(oi.subtotal), 0) DESC
            LIMIT 5
        ),
        'revenue_by_day', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'date', DATE(o.created_at),
                    'revenue', SUM(o.total_amount),
                    'orders', COUNT(*)
                )
            )
            FROM orders o
            WHERE o.establishment_id = p_establishment_id
              AND o.status = 'completed'
              AND o.created_at >= v_start_date
            GROUP BY DATE(o.created_at)
            ORDER BY DATE(o.created_at)
        )
    ) INTO v_result
    FROM establishments e
    LEFT JOIN orders o ON e.id = o.establishment_id
    LEFT JOIN tables t ON e.id = t.establishment_id
    WHERE e.id = p_establishment_id;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Get product analytics function
CREATE OR REPLACE FUNCTION get_product_analytics(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    product_id UUID,
    product_name TEXT,
    category_name TEXT,
    total_orders BIGINT,
    total_quantity BIGINT,
    total_revenue DECIMAL(10,2),
    avg_quantity_per_order DECIMAL(5,2),
    popularity_rank BIGINT
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
BEGIN
    RETURN QUERY
    WITH product_stats AS (
        SELECT
            p.id,
            p.name,
            c.name as category_name,
            COUNT(DISTINCT o.id) as total_orders,
            COALESCE(SUM(oi.quantity), 0) as total_quantity,
            COALESCE(SUM(oi.subtotal), 0) as total_revenue,
            CASE
                WHEN COUNT(DISTINCT o.id) > 0 THEN COALESCE(SUM(oi.quantity)::DECIMAL / COUNT(DISTINCT o.id), 0)
                ELSE 0
            END as avg_quantity_per_order
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN order_items oi ON p.id = oi.product_id
        LEFT JOIN orders o ON oi.order_id = o.id
            AND o.status = 'completed'
            AND o.created_at >= v_start_date
            AND o.created_at <= v_end_date
        WHERE p.establishment_id = p_establishment_id
          AND p.is_available = true
        GROUP BY p.id, p.name, c.name
    )
    SELECT
        ps.id,
        ps.product_name,
        ps.category_name,
        ps.total_orders,
        ps.total_quantity,
        ps.total_revenue,
        ps.avg_quantity_per_order,
        ROW_NUMBER() OVER (ORDER BY ps.total_revenue DESC) as popularity_rank
    FROM product_stats ps
    ORDER BY ps.total_revenue DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- REVENUE ANALYTICS FUNCTIONS
-- ==========================================

-- Get revenue breakdown function
CREATE OR REPLACE FUNCTION get_revenue_breakdown(
    p_establishment_id UUID,
    p_group_by TEXT DEFAULT 'day',
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    period TIMESTAMP WITH TIME ZONE,
    orders_count BIGINT,
    total_revenue DECIMAL(10,2),
    avg_order_value DECIMAL(10,2)
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
    v_date_trunc TEXT;
BEGIN
    -- Validate group_by parameter
    IF p_group_by NOT IN ('hour', 'day', 'week', 'month') THEN
        p_group_by := 'day';
    END IF;

    v_date_trunc := 'DATE_TRUNC(''' || p_group_by || ''', created_at)';

    RETURN QUERY EXECUTE format('
        SELECT
            %s as period,
            COUNT(*) as orders_count,
            SUM(total_amount) as total_revenue,
            AVG(total_amount) as avg_order_value
        FROM orders
        WHERE establishment_id = $1
          AND status = ''completed''
          AND created_at >= $2
          AND created_at <= $3
        GROUP BY %s
        ORDER BY %s
    ', v_date_trunc, v_date_trunc, v_date_trunc)
    USING p_establishment_id, v_start_date, v_end_date;
END;
$$ LANGUAGE plpgsql;

-- Get category performance function
CREATE OR REPLACE FUNCTION get_category_performance(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    category_id UUID,
    category_name TEXT,
    products_count BIGINT,
    orders_count BIGINT,
    total_revenue DECIMAL(10,2),
    avg_order_value DECIMAL(10,2),
    revenue_percentage DECIMAL(5,2)
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
    v_total_revenue DECIMAL(10,2);
BEGIN
    -- Get total revenue for percentage calculation
    SELECT COALESCE(SUM(o.total_amount), 0) INTO v_total_revenue
    FROM orders o
    WHERE o.establishment_id = p_establishment_id
      AND o.status = 'completed'
      AND o.created_at >= v_start_date
      AND o.created_at <= v_end_date;

    RETURN QUERY
    SELECT
        c.id,
        c.name,
        COUNT(DISTINCT p.id) as products_count,
        COUNT(DISTINCT o.id) as orders_count,
        COALESCE(SUM(oi.subtotal), 0) as total_revenue,
        CASE
            WHEN COUNT(DISTINCT o.id) > 0 THEN COALESCE(SUM(oi.subtotal) / COUNT(DISTINCT o.id), 0)
            ELSE 0
        END as avg_order_value,
        CASE
            WHEN v_total_revenue > 0 THEN (COALESCE(SUM(oi.subtotal), 0) / v_total_revenue) * 100
            ELSE 0
        END as revenue_percentage
    FROM categories c
    LEFT JOIN products p ON c.id = p.category_id AND p.is_available = true
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id
        AND o.status = 'completed'
        AND o.created_at >= v_start_date
        AND o.created_at <= v_end_date
    WHERE c.establishment_id = p_establishment_id
      AND c.is_active = true
    GROUP BY c.id, c.name
    ORDER BY COALESCE(SUM(oi.subtotal), 0) DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TABLE ANALYTICS FUNCTIONS
-- ==========================================

-- Get table utilization function
CREATE OR REPLACE FUNCTION get_table_utilization(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    table_number INTEGER,
    zone_name TEXT,
    capacity INTEGER,
    total_orders BIGINT,
    total_revenue DECIMAL(10,2),
    avg_order_value DECIMAL(10,2),
    utilization_rate DECIMAL(5,2),
    avg_service_time INTERVAL
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
    v_total_days INTEGER := EXTRACT(EPOCH FROM (v_end_date - v_start_date)) / 86400;
BEGIN
    RETURN QUERY
    SELECT
        t.table_number,
        t.zone_name,
        t.capacity,
        COUNT(o.id) as total_orders,
        COALESCE(SUM(o.total_amount), 0) as total_revenue,
        CASE
            WHEN COUNT(o.id) > 0 THEN COALESCE(SUM(o.total_amount) / COUNT(o.id), 0)
            ELSE 0
        END as avg_order_value,
        CASE
            WHEN v_total_days > 0 THEN
                (COUNT(DISTINCT DATE(o.created_at))::DECIMAL / v_total_days) * 100
            ELSE 0
        END as utilization_rate,
        CASE
            WHEN COUNT(o.id) > 0 THEN
                AVG(o.updated_at - o.created_at)
            ELSE NULL
        END as avg_service_time
    FROM tables t
    LEFT JOIN orders o ON t.id = o.table_id
        AND o.status = 'completed'
        AND o.created_at >= v_start_date
        AND o.created_at <= v_end_date
    WHERE t.establishment_id = p_establishment_id
    GROUP BY t.id, t.table_number, t.zone_name, t.capacity
    ORDER BY t.table_number;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- STAFF ANALYTICS FUNCTIONS
-- ==========================================

-- Get staff performance function
CREATE OR REPLACE FUNCTION get_staff_performance(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    staff_id UUID,
    username TEXT,
    role TEXT,
    total_activities BIGINT,
    orders_created BIGINT,
    orders_updated BIGINT,
    table_changes BIGINT,
    login_count BIGINT,
    last_activity TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.username,
        s.role,
        COUNT(sal.id) as total_activities,
        COUNT(CASE WHEN sal.activity_type = 'order_created' THEN 1 END) as orders_created,
        COUNT(CASE WHEN sal.activity_type = 'order_updated' THEN 1 END) as orders_updated,
        COUNT(CASE WHEN sal.activity_type = 'table_status_changed' THEN 1 END) as table_changes,
        COUNT(CASE WHEN sal.activity_type = 'login' THEN 1 END) as login_count,
        MAX(sal.created_at) as last_activity
    FROM staff s
    LEFT JOIN staff_activity_logs sal ON s.id = sal.staff_id
        AND sal.created_at >= v_start_date
        AND sal.created_at <= v_end_date
    WHERE s.establishment_id = p_establishment_id
      AND s.is_active = true
    GROUP BY s.id, s.username, s.role
    ORDER BY COUNT(sal.id) DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- QR CODE ANALYTICS FUNCTIONS
-- ==========================================

-- Get QR code performance function
CREATE OR REPLACE FUNCTION get_qr_code_performance(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    table_number INTEGER,
    total_scans BIGINT,
    unique_sessions BIGINT,
    avg_scans_per_session DECIMAL(5,2),
    last_scan TIMESTAMP WITH TIME ZONE,
    scan_frequency TEXT
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
BEGIN
    RETURN QUERY
    SELECT
        q.table_number,
        COUNT(qs.id) as total_scans,
        COUNT(DISTINCT qs.session_id) as unique_sessions,
        CASE
            WHEN COUNT(DISTINCT qs.session_id) > 0 THEN COUNT(qs.id)::DECIMAL / COUNT(DISTINCT qs.session_id)
            ELSE 0
        END as avg_scans_per_session,
        MAX(qs.scanned_at) as last_scan,
        CASE
            WHEN COUNT(qs.id) >= 10 THEN 'high'
            WHEN COUNT(qs.id) >= 5 THEN 'medium'
            ELSE 'low'
        END as scan_frequency
    FROM qr_codes q
    LEFT JOIN qr_scans qs ON q.id = qs.qr_code_id
        AND qs.scanned_at >= v_start_date
        AND qs.scanned_at <= v_end_date
    WHERE q.establishment_id = p_establishment_id
    GROUP BY q.id, q.table_number
    ORDER BY COUNT(qs.id) DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- EXPORT FUNCTIONS
-- ==========================================

-- Export establishment data function
CREATE OR REPLACE FUNCTION export_establishment_data(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'establishment_info', (
            SELECT jsonb_build_object(
                'id', id,
                'name', name,
                'type', et.name,
                'created_at', created_at
            )
            FROM establishments e
            LEFT JOIN establishment_types et ON e.type_id = et.id
            WHERE e.id = p_establishment_id
        ),
        'summary_stats', (
            SELECT jsonb_build_object(
                'total_orders', COUNT(*),
                'total_revenue', SUM(total_amount),
                'avg_order_value', AVG(total_amount),
                'total_products', COUNT(DISTINCT p.id),
                'total_categories', COUNT(DISTINCT c.id)
            )
            FROM orders o
            CROSS JOIN (
                SELECT COUNT(*) as total_products FROM products WHERE establishment_id = p_establishment_id
            ) p
            CROSS JOIN (
                SELECT COUNT(*) as total_categories FROM categories WHERE establishment_id = p_establishment_id
            ) c
            WHERE o.establishment_id = p_establishment_id
              AND o.status = 'completed'
              AND o.created_at >= v_start_date
              AND o.created_at <= v_end_date
        ),
        'orders', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', o.id,
                    'table_number', o.table_number,
                    'status', o.status,
                    'total_amount', o.total_amount,
                    'created_at', o.created_at,
                    'items', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'product_name', p.name,
                                'quantity', oi.quantity,
                                'unit_price', oi.unit_price,
                                'subtotal', oi.subtotal
                            )
                        )
                        FROM order_items oi
                        JOIN products p ON oi.product_id = p.id
                        WHERE oi.order_id = o.id
                    )
                )
            )
            FROM orders o
            WHERE o.establishment_id = p_establishment_id
              AND o.created_at >= v_start_date
              AND o.created_at <= v_end_date
              AND o.status = 'completed'
            ORDER BY o.created_at DESC
        )
    ) INTO v_result;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ ANALYTICS FUNCTIONS CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Analytics and reporting functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/04_analytics/functions.sql