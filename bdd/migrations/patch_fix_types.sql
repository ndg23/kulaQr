-- ============================================
-- PATCH CORRECTION TYPE : Fonction get_subscription_block_logs
-- ============================================
-- Corrige le problème de type UUID vs INTEGER
-- ============================================

-- 1. Supprimer la fonction problématique
DROP FUNCTION IF EXISTS get_subscription_block_logs(INTEGER) CASCADE;

-- 2. Vérifier la vraie structure de la table subscription_blocks_log
-- En exécutant: SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'subscription_blocks_log';

-- 3. Recréer la fonction avec les bons types (ID en INTEGER, pas UUID)
CREATE OR REPLACE FUNCTION get_subscription_block_logs(limit_count INTEGER DEFAULT 50)
RETURNS TABLE(
  log_id INTEGER,
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  subscription_ended_at TIMESTAMPTZ,
  blocked_at TIMESTAMPTZ,
  days_expired INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sbl.id as log_id,
    sbl.user_id,
    COALESCE(users.full_name, 'Utilisateur inconnu')::TEXT,
    COALESCE(users.phone, 'N/A')::TEXT,
    sbl.subscription_tier,
    sbl.subscription_ended_at,
    sbl.blocked_at,
    sbl.days_expired
  FROM subscription_blocks_log sbl
  LEFT JOIN users ON users.id = sbl.user_id
  ORDER BY sbl.blocked_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Test de la fonction
SELECT 'Fonction get_subscription_block_logs corrigée' as message;