-- ============================================
-- PATCH FINAL : Correction définitive get_subscription_block_logs
-- ============================================

-- 1. Supprimer complètement la fonction problématique
DROP FUNCTION IF EXISTS get_subscription_block_logs(INTEGER) CASCADE;

-- 2. Recréer avec une approche différente (sans JOIN problématique)
CREATE OR REPLACE FUNCTION get_subscription_block_logs_simple(limit_count INTEGER DEFAULT 50)
RETURNS TABLE(
  log_id INTEGER,
  user_id UUID,
  subscription_tier TEXT,
  subscription_ended_at TIMESTAMPTZ,
  blocked_at TIMESTAMPTZ,
  days_expired INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sbl.id as log_id,
    sbl.user_id,
    sbl.subscription_tier,
    sbl.subscription_ended_at,
    sbl.blocked_at,
    sbl.days_expired,
    sbl.created_at
  FROM subscription_blocks_log sbl
  ORDER BY sbl.blocked_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Message de confirmation
SELECT 'Fonction get_subscription_block_logs_simple créée avec succès!' as message;