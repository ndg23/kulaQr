


-- Vue pour les statistiques administrateur
CREATE TABLE IF NOT EXISTS qr_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID REFERENCES establishments(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_agent TEXT,
  ip_address INET,
  referrer TEXT
);

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
  COUNT(o.id) as orders_month,
  COALESCE(SUM(o.total_amount), 0) as revenue_month,

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