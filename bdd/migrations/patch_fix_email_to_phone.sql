-- ============================================
-- PATCH: Correction des colonnes email → phone
-- ============================================
-- Exécutez ce fichier APRÈS subscription_auto_block.sql
-- pour corriger les erreurs de colonnes
-- ============================================

-- 0. Supprimer les anciennes fonctions
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS get_expiring_subscriptions(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions_with_log() CASCADE;
DROP FUNCTION IF EXISTS check_and_block_expired_subscriptions() CASCADE;

-- 0b. Recréer la vue subscription_stats avec qualification explicite
DROP VIEW IF EXISTS subscription_stats CASCADE;

CREATE OR REPLACE VIEW subscription_stats AS
SELECT 
  u.subscription_tier,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE u.is_active = true) as active_users,
  COUNT(*) FILTER (WHERE u.is_active = false) as blocked_users,
  COUNT(*) FILTER (
    WHERE u.subscription_ends_at IS NOT NULL 
    AND u.subscription_ends_at < NOW() 
    AND u.is_active = true
  ) as expired_active_users,
  COUNT(*) FILTER (
    WHERE u.subscription_ends_at IS NOT NULL 
    AND u.subscription_ends_at > NOW() 
    AND u.subscription_ends_at <= NOW() + INTERVAL '2 days'
  ) as expiring_soon
FROM users u
WHERE u.subscription_tier IS NOT NULL
GROUP BY u.subscription_tier;

-- 1. Corriger auto_block_expired_subscriptions
CREATE OR REPLACE FUNCTION auto_block_expired_subscriptions()
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expired_since INTERVAL,
  action_taken TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH expired_users AS (
    UPDATE users
    SET 
      is_active = false,
      updated_at = NOW()
    WHERE 
      is_active = true
      AND subscription_ends_at IS NOT NULL
      AND subscription_ends_at < NOW()
      AND subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      id,
      full_name,
      phone,
      subscription_tier,
      subscription_ends_at
  )
  SELECT 
    eu.id::UUID,
    eu.full_name::TEXT,
    eu.phone::TEXT,
    eu.subscription_tier::TEXT,
    (NOW() - eu.subscription_ends_at)::INTERVAL as expired_since,
    'Compte bloqué automatiquement'::TEXT as action_taken
  FROM expired_users eu;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Corriger get_expiring_subscriptions
CREATE OR REPLACE FUNCTION get_expiring_subscriptions(days_before INTEGER DEFAULT 2)
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expires_at TIMESTAMPTZ,
  days_remaining INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id::UUID,
    u.full_name::TEXT,
    u.phone::TEXT,
    u.subscription_tier::TEXT,
    u.subscription_ends_at::TIMESTAMPTZ,
    EXTRACT(DAY FROM (u.subscription_ends_at - NOW()))::INTEGER as days_remaining
  FROM users u
  WHERE 
    u.is_active = true
    AND u.subscription_ends_at IS NOT NULL
    AND u.subscription_ends_at > NOW()
    AND u.subscription_ends_at <= (NOW() + (days_before || ' days')::INTERVAL)
    AND u.subscription_tier IN ('demo', 'pro', 'premium')
  ORDER BY u.subscription_ends_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Corriger auto_block_expired_subscriptions_with_log
CREATE OR REPLACE FUNCTION auto_block_expired_subscriptions_with_log()
RETURNS TABLE(
  user_id UUID,
  user_name TEXT,
  phone TEXT,
  subscription_tier TEXT,
  expired_since INTERVAL,
  action_taken TEXT
) AS $$
DECLARE
  v_record RECORD;
BEGIN
  FOR v_record IN
    UPDATE users
    SET 
      is_active = false,
      updated_at = NOW()
    WHERE 
      is_active = true
      AND subscription_ends_at IS NOT NULL
      AND subscription_ends_at < NOW()
      AND subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      id,
      full_name,
      phone,
      subscription_tier,
      subscription_ends_at
  LOOP
    -- Logger le blocage
    INSERT INTO subscription_blocks_log (
      user_id,
      subscription_tier,
      subscription_ended_at,
      days_expired
    ) VALUES (
      v_record.id,
      v_record.subscription_tier,
      v_record.subscription_ends_at,
      EXTRACT(DAY FROM (NOW() - v_record.subscription_ends_at))::INTEGER
    );
    
    -- Retourner les résultats
    user_id := v_record.id;
    user_name := v_record.full_name;
    phone := v_record.phone;
    subscription_tier := v_record.subscription_tier;
    expired_since := (NOW() - v_record.subscription_ends_at);
    action_taken := 'Compte bloqué et logué';
    
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Corriger check_and_block_expired_subscriptions
CREATE OR REPLACE FUNCTION check_and_block_expired_subscriptions()
RETURNS JSONB AS $$
DECLARE
  v_blocked_count INTEGER := 0;
  v_expiring_count INTEGER := 0;
  v_record RECORD;
  v_result JSONB;
BEGIN
  -- Bloquer les utilisateurs expirés et créer des notifications
  FOR v_record IN
    SELECT * FROM auto_block_expired_subscriptions_with_log()
  LOOP
    v_blocked_count := v_blocked_count + 1;
    
    -- Créer une notification pour les admins
    PERFORM create_admin_notification(
      'user_blocked',
      v_record.user_id,
      'Utilisateur bloqué automatiquement',
      format('L''utilisateur %s (%s) a été bloqué car son abonnement %s a expiré depuis %s',
        v_record.user_name,
        COALESCE(v_record.phone, 'N/A'),
        v_record.subscription_tier,
        v_record.expired_since
      ),
      'warning'
    );
  END LOOP;
  
  -- Notifier les abonnements qui vont expirer dans 2 jours
  FOR v_record IN
    SELECT * FROM get_expiring_subscriptions(2)
  LOOP
    v_expiring_count := v_expiring_count + 1;
    
    PERFORM create_admin_notification(
      'subscription_expiring',
      v_record.user_id,
      'Abonnement expire bientôt',
      format('L''abonnement %s de %s (%s) expire dans %s jours',
        v_record.subscription_tier,
        v_record.user_name,
        COALESCE(v_record.phone, 'N/A'),
        v_record.days_remaining
      ),
      'info'
    );
  END LOOP;
  
  -- Retourner le résumé
  SELECT jsonb_build_object(
    'success', true,
    'blocked_users', v_blocked_count,
    'expiring_soon', v_expiring_count,
    'checked_at', NOW(),
    'message', format('%s utilisateur(s) bloqué(s), %s abonnement(s) expire(nt) bientôt', 
      v_blocked_count, v_expiring_count)
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Afficher confirmation
SELECT 
  '✅ Patch appliqué avec succès!' as message,
  NOW() as patched_at;
