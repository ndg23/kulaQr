-- ==========================================
-- KULA QR - ANALYTICS VIEWS
-- ==========================================
-- Vues pour les analyses et rapports
-- Fait partie du module 04_analytics

-- ==========================================
-- DASHBOARD VIEWS
-- ==========================================

-- Daily orders view
CREATE OR REPLACE VIEW daily_orders AS
SELECT
    DATE(created_at) as order_date,
    establishment_id,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_orders,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders
FROM orders
GROUP BY DATE(created_at), establishment_id;

-- Product performance view
CREATE OR REPLACE VIEW product_performance AS
SELECT
    p.id,
    p.name,
    p.establishment_id,
    c.name as category_name,
    p.price,
    p.orders_count,
    p.is_available,
    COALESCE(SUM(oi.quantity), 0) as total_quantity_sold,
    COALESCE(SUM(oi.subtotal), 0) as total_revenue,
    CASE
        WHEN p.orders_count > 0 THEN COALESCE(SUM(oi.subtotal) / p.orders_count, 0)
        ELSE 0
    END as avg_order_contribution
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'completed'
GROUP BY p.id, p.name, p.establishment_id, c.name, p.price, p.orders_count, p.is_available;

-- Table utilization view
CREATE OR REPLACE VIEW table_utilization AS
SELECT
    t.id,
    t.establishment_id,
    t.table_number,
    t.zone_name,
    t.capacity,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders,
    AVG(EXTRACT(EPOCH FROM (o.updated_at - o.created_at))/60) as avg_order_duration_minutes,
    MAX(o.created_at) as last_order_time
FROM tables t
LEFT JOIN orders o ON t.id = o.table_id
GROUP BY t.id, t.establishment_id, t.table_number, t.zone_name, t.capacity;

-- Establishment overview view
CREATE OR REPLACE VIEW establishment_overview AS
SELECT
    e.id,
    e.name,
    e.slug,
    e.is_active,
    e.subscription_type,
    e.created_at,
    COUNT(DISTINCT c.id) as categories_count,
    COUNT(DISTINCT p.id) as products_count,
    COUNT(DISTINCT t.id) as tables_count,
    COUNT(DISTINCT o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COUNT(DISTINCT CASE WHEN o.created_at >= CURRENT_DATE - INTERVAL '30 days' THEN o.id END) as orders_last_30_days,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value
FROM establishments e
LEFT JOIN categories c ON e.id = c.establishment_id AND c.is_active = true
LEFT JOIN products p ON e.id = p.establishment_id AND p.is_available = true
LEFT JOIN tables t ON e.id = t.establishment_id
LEFT JOIN orders o ON e.id = o.establishment_id AND o.status = 'completed'
GROUP BY e.id, e.name, e.slug, e.is_active, e.subscription_type, e.created_at;

-- ==========================================
-- QR CODE ANALYTICS VIEWS
-- ==========================================

-- QR scan summary view
CREATE OR REPLACE VIEW qr_scan_summary AS
SELECT
    q.establishment_id,
    q.table_number,
    COUNT(qs.id) as total_scans,
    COUNT(DISTINCT qs.session_id) as unique_sessions,
    MAX(qs.scanned_at) as last_scan,
    AVG(EXTRACT(EPOCH FROM (qs.scanned_at - LAG(qs.scanned_at) OVER (PARTITION BY qs.qr_code_id ORDER BY qs.scanned_at)))/60) as avg_time_between_scans
FROM qr_codes q
LEFT JOIN qr_scans qs ON q.id = qs.qr_code_id
GROUP BY q.id, q.establishment_id, q.table_number;

-- Popular products view
CREATE OR REPLACE VIEW popular_products AS
SELECT
    p.id,
    p.name,
    p.establishment_id,
    c.name as category_name,
    p.price,
    p.orders_count,
    RANK() OVER (PARTITION BY p.establishment_id ORDER BY p.orders_count DESC) as popularity_rank,
    PERCENT_RANK() OVER (PARTITION BY p.establishment_id ORDER BY p.orders_count DESC) as popularity_percentile
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.is_available = true;

-- ==========================================
-- STAFF PERFORMANCE VIEWS
-- ==========================================

-- Staff activity summary view
CREATE OR REPLACE VIEW staff_activity_summary AS
SELECT
    s.id,
    s.username,
    s.establishment_id,
    s.role,
    COUNT(sal.id) as total_activities,
    MAX(sal.created_at) as last_activity,
    COUNT(CASE WHEN sal.activity_type = 'login' THEN 1 END) as login_count,
    COUNT(CASE WHEN sal.activity_type = 'order_created' THEN 1 END) as orders_created,
    COUNT(CASE WHEN sal.activity_type = 'order_updated' THEN 1 END) as orders_updated,
    COUNT(CASE WHEN sal.activity_type = 'table_status_changed' THEN 1 END) as table_changes
FROM staff s
LEFT JOIN staff_activity_logs sal ON s.id = sal.staff_id
GROUP BY s.id, s.username, s.establishment_id, s.role;

-- ==========================================
-- REVENUE ANALYTICS VIEWS
-- ==========================================

-- Revenue by category view
CREATE OR REPLACE VIEW revenue_by_category AS
SELECT
    c.establishment_id,
    c.name as category_name,
    COUNT(DISTINCT p.id) as products_count,
    COUNT(oi.id) as items_sold,
    COALESCE(SUM(oi.subtotal), 0) as total_revenue,
    COALESCE(AVG(oi.unit_price), 0) as avg_item_price,
    CASE
        WHEN COUNT(oi.id) > 0 THEN COALESCE(SUM(oi.subtotal) / COUNT(oi.id), 0)
        ELSE 0
    END as avg_item_revenue
FROM categories c
LEFT JOIN products p ON c.id = p.category_id AND p.is_available = true
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'completed'
GROUP BY c.id, c.establishment_id, c.name;

-- Revenue by time period view
CREATE OR REPLACE VIEW revenue_by_time_period AS
SELECT
    establishment_id,
    DATE_TRUNC('hour', created_at) as hour_period,
    DATE_TRUNC('day', created_at) as day_period,
    DATE_TRUNC('week', created_at) as week_period,
    DATE_TRUNC('month', created_at) as month_period,
    COUNT(*) as orders_count,
    SUM(total_amount) as revenue,
    AVG(total_amount) as avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY establishment_id, DATE_TRUNC('hour', created_at), DATE_TRUNC('day', created_at), DATE_TRUNC('week', created_at), DATE_TRUNC('month', created_at);

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ ANALYTICS VIEWS CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Dashboard and analytics views ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/04_analytics/views.sql