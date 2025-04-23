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
  LEFT JOIN products p ON p.category_id IN (SELECT id FROM categories WHERE establishment_id = e.id)
  LEFT JOIN categories c ON c.establishment_id = e.id
  LEFT JOIN qr_scans qs ON qs.establishment_id = e.id
),
type_counts AS (
  SELECT 
    et.name,
    COUNT(e.id) as count
  FROM establishment_types et
  LEFT JOIN establishments e ON e.type_id = et.id
  GROUP BY et.name
),
subscription_counts AS (
  SELECT 
    COALESCE(subscription_type, 'free') as type,
    COUNT(*) as count
  FROM establishments
  GROUP BY subscription_type
),
type_stats AS (
  SELECT jsonb_object_agg(name, count) as establishments_by_type
  FROM type_counts
),
sub_stats AS (
  SELECT jsonb_object_agg(type, count) as subscriptions_distribution
  FROM subscription_counts
)
SELECT 
  bs.*,
  ts.establishments_by_type,
  ss.subscriptions_distribution,
  -- Calcul des KPIs
  ROUND((bs.active_establishments::float / NULLIF(bs.total_establishments, 0) * 100)::numeric, 1) as active_rate,
  ROUND((bs.active_users_7d::float / NULLIF(bs.total_users, 0) * 100)::numeric, 1) as user_engagement_rate,
  ROUND((bs.new_users_30d::float / NULLIF(bs.total_users, 0) * 100)::numeric, 1) as user_growth_rate
FROM base_stats bs
CROSS JOIN type_stats ts
CROSS JOIN sub_stats ss;

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