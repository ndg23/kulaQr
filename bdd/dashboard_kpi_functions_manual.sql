-- ==========================================
-- INSTRUCTIONS POUR CRÉER LES FONCTIONS KPI
-- ==========================================
-- Copiez et exécutez ce fichier dans l'interface SQL de Supabase
-- URL: https://supabase.com/dashboard/project/[votre-project]/sql

-- ==========================================
-- KULA QR - DASHBOARD KPI FUNCTIONS
-- ==========================================
-- Functions to calculate dashboard KPIs for restaurant owners

-- 1. Nombre de scans QR aujourd'hui
CREATE OR REPLACE FUNCTION get_qr_scans_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    scan_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO scan_count
    FROM qr_scans
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE;

    RETURN COALESCE(scan_count, 0);
END;
$$;

-- 2. Nombre de scans QR hier (pour calculer la croissance)
CREATE OR REPLACE FUNCTION get_qr_scans_yesterday(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    scan_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO scan_count
    FROM qr_scans
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE - INTERVAL '1 day';

    RETURN COALESCE(scan_count, 0);
END;
$$;

-- 3. Nombre de commandes via QR aujourd'hui
CREATE OR REPLACE FUNCTION get_qr_orders_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO order_count
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE
    AND status IN ('confirmed', 'processing', 'ready', 'completed');

    RETURN COALESCE(order_count, 0);
END;
$$;

-- 4. Valeur moyenne des commandes via QR aujourd'hui
CREATE OR REPLACE FUNCTION get_avg_qr_order_value_today(establishment_uuid UUID)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    avg_value DECIMAL(10,2);
BEGIN
    SELECT COALESCE(AVG(total_amount), 0) INTO avg_value
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE
    AND status IN ('confirmed', 'processing', 'ready', 'completed')
    AND total_amount > 0;

    RETURN avg_value;
END;
$$;

-- 5. Satisfaction client (moyenne des notes)
CREATE OR REPLACE FUNCTION get_customer_satisfaction(establishment_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
    avg_rating DECIMAL(3,2);
    total_reviews INTEGER;
BEGIN
    SELECT
        COALESCE(AVG(rating), 0)::DECIMAL(3,2),
        COUNT(*)
    INTO avg_rating, total_reviews
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND rating IS NOT NULL
    AND status = 'completed';

    result := json_build_object(
        'average_rating', avg_rating,
        'total_reviews', total_reviews
    );

    RETURN result;
END;
$$;

-- 6. Temps moyen par scan (estimation basée sur les sessions)
CREATE OR REPLACE FUNCTION get_avg_time_per_scan(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    avg_time_seconds INTEGER;
BEGIN
    -- Pour l'instant, on retourne une estimation basée sur les données disponibles
    -- À améliorer avec un vrai tracking des sessions utilisateur
    SELECT COALESCE(AVG(session_duration_seconds), 85)::INTEGER
    INTO avg_time_seconds
    FROM (
        SELECT
            establishment_id,
            DATE(created_at) as scan_date,
            COUNT(*) as scans_per_day,
            -- Estimation en secondes : ajustable selon les données
            CASE
                WHEN COUNT(*) > 50 THEN 65  -- Jour très fréquenté = moins de temps par scan
                WHEN COUNT(*) > 20 THEN 85  -- Jour normal
                ELSE 120  -- Jour calme = plus de temps par scan
            END as session_duration_seconds
        FROM qr_scans
        WHERE establishment_id = establishment_uuid
        AND created_at >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY establishment_id, DATE(created_at)
    ) daily_stats;

    RETURN COALESCE(avg_time_seconds, 85);
END;
$$;

-- 7. Commandes totales aujourd'hui (toutes sources)
CREATE OR REPLACE FUNCTION get_total_orders_today(establishment_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO order_count
    FROM orders
    WHERE establishment_id = establishment_uuid
    AND DATE(created_at) = CURRENT_DATE;

    RETURN COALESCE(order_count, 0);
END;
$$;

-- 8. Fonction principale pour récupérer tous les KPI du dashboard
CREATE OR REPLACE FUNCTION get_restaurant_dashboard_kpis(establishment_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
    qr_scans_today INTEGER;
    qr_scans_yesterday INTEGER;
    qr_orders_today INTEGER;
    avg_qr_order_value DECIMAL(10,2);
    satisfaction_data JSON;
    avg_time_per_scan INTEGER;
    total_orders_today INTEGER;
    conversion_rate DECIMAL(5,2);
    scans_growth DECIMAL(5,2);
BEGIN
    -- Récupérer toutes les métriques
    qr_scans_today := get_qr_scans_today(establishment_uuid);
    qr_scans_yesterday := get_qr_scans_yesterday(establishment_uuid);
    qr_orders_today := get_qr_orders_today(establishment_uuid);
    avg_qr_order_value := get_avg_qr_order_value_today(establishment_uuid);
    satisfaction_data := get_customer_satisfaction(establishment_uuid);
    avg_time_per_scan := get_avg_time_per_scan(establishment_uuid);
    total_orders_today := get_total_orders_today(establishment_uuid);

    -- Calculer le taux de conversion
    conversion_rate := CASE
        WHEN qr_scans_today > 0 THEN (qr_orders_today::DECIMAL / qr_scans_today::DECIMAL) * 100
        ELSE 0
    END;

    -- Calculer la croissance des scans
    scans_growth := CASE
        WHEN qr_scans_yesterday > 0 THEN ((qr_scans_today::DECIMAL - qr_scans_yesterday::DECIMAL) / qr_scans_yesterday::DECIMAL) * 100
        ELSE 0
    END;

    -- Construire le résultat JSON
    result := json_build_object(
        'qr_scans_today', qr_scans_today,
        'conversion_rate', ROUND(conversion_rate, 1),
        'avg_qr_order_value', ROUND(avg_qr_order_value, 2),
        'customer_satisfaction', satisfaction_data,
        'avg_time_per_scan', avg_time_per_scan,
        'total_orders_today', total_orders_today,
        'scans_growth', ROUND(scans_growth, 1)
    );

    RETURN result;
END;
$$;

-- ==========================================
-- GRANT PERMISSIONS
-- ==========================================

-- Donner accès aux fonctions aux utilisateurs authentifiés
GRANT EXECUTE ON FUNCTION get_qr_scans_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_qr_scans_yesterday(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_qr_orders_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_avg_qr_order_value_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_satisfaction(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_avg_time_per_scan(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_total_orders_today(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_restaurant_dashboard_kpis(UUID) TO authenticated;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '🎯 DASHBOARD KPI FUNCTIONS CREATED SUCCESSFULLY!';
    RAISE NOTICE '📊 Available functions:';
    RAISE NOTICE '   - get_qr_scans_today(establishment_uuid)';
    RAISE NOTICE '   - get_qr_orders_today(establishment_uuid)';
    RAISE NOTICE '   - get_avg_qr_order_value_today(establishment_uuid)';
    RAISE NOTICE '   - get_customer_satisfaction(establishment_uuid)';
    RAISE NOTICE '   - get_avg_time_per_scan(establishment_uuid)';
    RAISE NOTICE '   - get_total_orders_today(establishment_uuid)';
    RAISE NOTICE '   - get_restaurant_dashboard_kpis(establishment_uuid) [MAIN FUNCTION]';
    RAISE NOTICE '✅ Ready to use in dashboard!';
END $$;







CREATE OR REPLACE FUNCTION get_restaurant_kpis(establishment_uuid UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
  today_start TIMESTAMP;
  yesterday_start TIMESTAMP;
BEGIN
  today_start := CURRENT_DATE;
  yesterday_start := CURRENT_DATE - INTERVAL '1 day';

  SELECT json_build_object(
    -- ========== COMMANDES ==========
    'orders_count_today', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status != 'cancelled'
    ),
    
    'orders_count_yesterday', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
        AND status != 'cancelled'
    ),
    
    'orders_count_total', (
      SELECT COUNT(*)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status != 'cancelled'
    ),
    
    -- ========== MONTANT TOTAL ==========
    'revenue_today', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_yesterday', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_total', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'revenue_this_month', (
      SELECT COALESCE(SUM(total_amount), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= DATE_TRUNC('month', CURRENT_DATE)
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== PANIER MOYEN ==========
    'avg_order_value_today', (
      SELECT COALESCE(ROUND(AVG(total_amount), 0), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'avg_order_value_overall', (
      SELECT COALESCE(ROUND(AVG(total_amount), 0), 0)
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== SCANS QR ==========
    'qr_scans_today', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
        AND created_at >= today_start
    ),
    
    'qr_scans_yesterday', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
        AND created_at >= yesterday_start
        AND created_at < today_start
    ),
    
    'qr_scans_total', (
      SELECT COUNT(*)
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
    ),
    
    -- ========== TAUX DE CONVERSION QR ==========
    -- 'conversion_rate', (
    --   WITH qr_sessions AS (
    --     SELECT DISTINCT session_id
    --     FROM qr_scans
    --     WHERE establishment_id = establishment_uuid
    --       AND created_at >= today_start
    --       AND session_id IS NOT NULL
    --   ),
    --   orders_from_qr AS (
    --     SELECT COUNT(DISTINCT o.id) as order_count
    --     FROM orders o
    --     INNER JOIN qr_scans qs ON o.establishment_id = qs.establishment_id
    --       AND o.table_number = qs.table_number
    --       AND o.created_at >= qs.created_at
    --       AND o.created_at <= qs.created_at + INTERVAL '30 minutes'
    --     WHERE o.establishment_id = establishment_uuid
    --       AND o.created_at >= today_start
    --       AND o.status != 'cancelled'
    --   )
    --   SELECT CASE 
    --     WHEN (SELECT COUNT(*) FROM qr_sessions) > 0
    --     THEN ROUND(((SELECT order_count FROM orders_from_qr)::DECIMAL / (SELECT COUNT(*) FROM qr_sessions) * 100), 1)
    --     ELSE 0
    --   END
    -- ),
    
    -- ========== PANIER MOYEN QR ==========
    'avg_qr_order_value', (
      SELECT COALESCE(ROUND(AVG(o.total_amount), 0), 0)
      FROM orders o
      INNER JOIN qr_scans qs ON o.establishment_id = qs.establishment_id
        AND o.table_number = qs.table_number
        AND o.created_at >= qs.created_at
        AND o.created_at <= qs.created_at + INTERVAL '30 minutes'
      WHERE o.establishment_id = establishment_uuid
        AND o.created_at >= today_start
        AND o.status IN ('confirmed', 'processing', 'completed')
    ),
    
    -- ========== CROISSANCE ==========
    'orders_growth', (
      SELECT CASE 
        WHEN COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) > 0
        THEN ROUND(
          ((COUNT(*) FILTER (WHERE created_at >= today_start)::DECIMAL 
          - COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start))
          / COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) * 100), 1
        )
        ELSE CASE 
          WHEN COUNT(*) FILTER (WHERE created_at >= today_start) > 0 THEN 100
          ELSE 0
        END
      END
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status != 'cancelled'
    ),
    
    'revenue_growth', (
      SELECT CASE 
        WHEN COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 0) > 0
        THEN ROUND(
          ((COALESCE(SUM(total_amount) FILTER (WHERE created_at >= today_start), 0) 
          - COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 0))
          / COALESCE(SUM(total_amount) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start), 1) * 100), 1
        )
        ELSE CASE 
          WHEN COALESCE(SUM(total_amount) FILTER (WHERE created_at >= today_start), 0) > 0 THEN 100
          ELSE 0
        END
      END
      FROM orders
      WHERE establishment_id = establishment_uuid
        AND status IN ('confirmed', 'processing', 'completed')
    ),
    
    'scans_growth', (
      SELECT CASE 
        WHEN COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) > 0
        THEN ROUND(
          ((COUNT(*) FILTER (WHERE created_at >= today_start)::DECIMAL 
          - COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start))
          / COUNT(*) FILTER (WHERE created_at >= yesterday_start AND created_at < today_start) * 100), 1
        )
        ELSE CASE 
          WHEN COUNT(*) FILTER (WHERE created_at >= today_start) > 0 THEN 100
          ELSE 0
        END
      END
      FROM qr_scans
      WHERE establishment_id = establishment_uuid
    ),
    
    -- ========== STATUTS DES COMMANDES ==========
    'orders_by_status', (
      SELECT json_object_agg(status, count)
      FROM (
        SELECT status, COUNT(*) as count
        FROM orders
        WHERE establishment_id = establishment_uuid
          AND created_at >= today_start
        GROUP BY status
      ) status_counts
    ),
    
    -- ========== TOP 5 PRODUITS ==========
    'top_products', (
      SELECT json_agg(row_to_json(t))
      FROM (
        SELECT 
          p.name,
          SUM(oi.quantity) as quantity_sold,
          SUM(oi.subtotal) as revenue
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        JOIN orders o ON oi.order_id = o.id
        WHERE o.establishment_id = establishment_uuid
          AND o.created_at >= today_start
          AND o.status IN ('confirmed', 'processing', 'completed')
        GROUP BY p.id, p.name
        ORDER BY quantity_sold DESC
        LIMIT 5
      ) t
    )
    
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;