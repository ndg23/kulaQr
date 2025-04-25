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
    
    -- Statistiques des produits
    COUNT(DISTINCT p.id) as total_products,
    AVG(p.price) as avg_product_price,
    
    -- Statistiques des catégories
    COUNT(DISTINCT c.id) as total_categories,
    
    -- Statistiques des scans QR
    COUNT(qs.id) as total_qr_scans,
    COUNT(qs.id) FILTER (WHERE qs.created_at >= NOW() - INTERVAL '24 hours') as qr_scans_24h
    
  FROM establishments e
  LEFT JOIN users u ON e.user_id = u.id
  LEFT JOIN products p ON p.category_id = c.id
  LEFT JOIN categories c ON c.establishment_id = e.id
  LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
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
  COUNT(qs.id) as scan_count,
  COUNT(DISTINCT qs.created_at::date) as unique_days_scanned
FROM establishments e
LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
WHERE e.is_active = true
GROUP BY e.id, e.name, e.description
ORDER BY scan_count DESC; 