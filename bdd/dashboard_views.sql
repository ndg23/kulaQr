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