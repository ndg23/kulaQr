-- Fix for the popular_restaurants view to handle missing orders table
CREATE OR REPLACE FUNCTION get_popular_restaurants()
RETURNS TABLE (
  id UUID,
  name TEXT,
  orders INTEGER,
  rating NUMERIC
) AS $$
BEGIN
  -- Check if orders table exists
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'orders') THEN
    RETURN QUERY
    SELECT 
      e.id,
      e.name,
      COUNT(o.id)::INTEGER AS orders,
      COALESCE(AVG(o.rating), 4.5) AS rating
    FROM 
      establishments e
    LEFT JOIN 
      orders o ON e.id = o.establishment_id
    WHERE 
      e.is_active = true
    GROUP BY 
      e.id, e.name
    ORDER BY 
      orders DESC, rating DESC
    LIMIT 10;
  ELSE
    -- Fallback if orders table doesn't exist
    RETURN QUERY
    SELECT 
      e.id,
      e.name,
      0::INTEGER AS orders,
      4.5 AS rating
    FROM 
      establishments e
    WHERE 
      e.is_active = true
    ORDER BY 
      e.created_at DESC
    LIMIT 10;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Fix for the get_order_stats function to handle missing orders table
CREATE OR REPLACE FUNCTION get_order_stats()
RETURNS TABLE (
  total_orders INTEGER,
  total_revenue NUMERIC,
  avg_order_value NUMERIC
) AS $$
BEGIN
  -- Check if orders table exists
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'orders') THEN
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
  ELSE
    -- Fallback if orders table doesn't exist
    RETURN QUERY
    SELECT 
      0::INTEGER AS total_orders,
      0::NUMERIC AS total_revenue,
      0::NUMERIC AS avg_order_value;
  END IF;
END;
$$ LANGUAGE plpgsql; 