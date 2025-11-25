-- ============================================
-- SYSTÈME DE BLOCAGE AUTOMATIQUE DES ABONNEMENTS - VERSION CORRIGÉE
-- ============================================
-- Ce fichier gère le blocage automatique des utilisateurs après expiration
-- Corrections appliquées : colonnes phone au lieu d'email, types corrects, premium inclus
-- ============================================

-- 0. Supprimer les anciennes versions pour éviter les conflits
-- ============================================
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS get_expiring_subscriptions(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS auto_block_expired_subscriptions_with_log() CASCADE;
DROP FUNCTION IF EXISTS check_and_block_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS get_subscription_block_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_recent_admin_notifications(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS create_admin_notification(TEXT, UUID, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS reactivate_user_subscription(UUID, TEXT, INTEGER) CASCADE;
DROP VIEW IF EXISTS subscription_stats CASCADE;

-- 1. Tables de logs et notifications
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_blocks_log (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  subscription_tier TEXT NOT NULL,
  subscription_ended_at TIMESTAMPTZ NOT NULL,
  blocked_at TIMESTAMPTZ DEFAULT NOW(),
  days_expired INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_notifications (
  id SERIAL PRIMARY KEY,
  type TEXT NOT NULL,
  user_id UUID,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error', 'success')),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Fonction utilitaire : créer notification admin
-- ============================================
CREATE OR REPLACE FUNCTION create_admin_notification(
  p_type TEXT,
  p_user_id UUID,
  p_title TEXT,
  p_message TEXT,
  p_severity TEXT DEFAULT 'info'
)
RETURNS UUID AS $$
DECLARE
  v_notification_id UUID;
BEGIN
  INSERT INTO admin_notifications (type, user_id, title, message, severity)
  VALUES (p_type, p_user_id, p_title, p_message, p_severity)
  RETURNING id INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Vue des statistiques (avec qualification explicite des colonnes)
-- ============================================
CREATE OR REPLACE VIEW subscription_stats AS
SELECT 
  users.subscription_tier,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE users.is_active = true) as active_users,
  COUNT(*) FILTER (WHERE users.is_active = false) as blocked_users,
  COUNT(*) FILTER (
    WHERE users.subscription_ends_at IS NOT NULL 
    AND users.subscription_ends_at < NOW() 
    AND users.is_active = true
  ) as expired_active_users,
  COUNT(*) FILTER (
    WHERE users.subscription_ends_at IS NOT NULL 
    AND users.subscription_ends_at > NOW() 
    AND users.subscription_ends_at <= NOW() + INTERVAL '2 days'
  ) as expiring_soon
FROM users
WHERE users.subscription_tier IS NOT NULL
GROUP BY users.subscription_tier;

-- 4. Fonction : bloquer utilisateurs expirés (avec phone au lieu d'email)
-- ============================================
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
      users.is_active = true
      AND users.subscription_ends_at IS NOT NULL
      AND users.subscription_ends_at < NOW()
      AND users.subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      users.id,
      users.full_name,
      users.phone,
      users.subscription_tier,
      users.subscription_ends_at
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

-- 5. Fonction : obtenir abonnements qui expirent bientôt (avec phone)
-- ============================================
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
    users.id::UUID,
    users.full_name::TEXT,
    users.phone::TEXT,
    users.subscription_tier::TEXT,
    users.subscription_ends_at::TIMESTAMPTZ,
    EXTRACT(DAY FROM (users.subscription_ends_at - NOW()))::INTEGER as days_remaining
  FROM users
  WHERE 
    users.is_active = true
    AND users.subscription_ends_at IS NOT NULL
    AND users.subscription_ends_at > NOW()
    AND users.subscription_ends_at <= (NOW() + (days_before || ' days')::INTERVAL)
    AND users.subscription_tier IN ('demo', 'pro', 'premium')
  ORDER BY users.subscription_ends_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Fonction : bloquer avec log (version complète)
-- ============================================
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
      users.is_active = true
      AND users.subscription_ends_at IS NOT NULL
      AND users.subscription_ends_at < NOW()
      AND users.subscription_tier IN ('demo', 'pro', 'premium')
    RETURNING 
      users.id,
      users.full_name,
      users.phone,
      users.subscription_tier,
      users.subscription_ends_at
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

-- 7. Fonction principale : vérification et blocage automatique
-- ============================================
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

-- 8. Fonction : obtenir logs de blocage (avec types corrects)
-- ============================================
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

-- 9. Fonction : obtenir notifications récentes
-- ============================================
CREATE OR REPLACE FUNCTION get_recent_admin_notifications(limit_count INTEGER DEFAULT 20)
RETURNS TABLE(
  id INTEGER,
  type TEXT,
  user_id UUID,
  title TEXT,
  message TEXT,
  severity TEXT,
  is_read BOOLEAN,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    an.id,
    an.type,
    an.user_id,
    an.title,
    an.message,
    an.severity,
    an.is_read,
    an.created_at
  FROM admin_notifications an
  ORDER BY an.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Fonction : réactiver abonnement utilisateur (version corrigée)
-- ============================================
CREATE OR REPLACE FUNCTION reactivate_user_subscription(
  p_user_id UUID,
  p_new_tier TEXT DEFAULT 'demo',
  p_duration_days INTEGER DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_duration INTEGER;
  v_result JSONB;
  v_user_record RECORD;
BEGIN
  -- Définir la durée selon le tier
  v_duration := CASE 
    WHEN p_duration_days IS NOT NULL THEN p_duration_days
    WHEN p_new_tier = 'demo' THEN 7
    WHEN p_new_tier = 'pro' THEN 30
    WHEN p_new_tier = 'premium' THEN 90
    ELSE 7
  END;
  
  -- Réactiver l'utilisateur
  UPDATE users 
  SET 
    is_active = true,
    subscription_tier = p_new_tier,
    subscription_starts_at = NOW(),
    subscription_ends_at = NOW() + (v_duration || ' days')::INTERVAL,
    updated_at = NOW()
  WHERE users.id = p_user_id
  RETURNING users.full_name, users.phone INTO v_user_record;
  
  -- Créer notification
  PERFORM create_admin_notification(
    'user_reactivated',
    p_user_id,
    'Utilisateur réactivé',
    format('L''utilisateur %s (%s) a été réactivé avec un abonnement %s de %s jours',
      COALESCE(v_user_record.full_name, 'Utilisateur'),
      COALESCE(v_user_record.phone, 'N/A'),
      p_new_tier,
      v_duration
    ),
    'success'
  );
  
  -- Retourner le résultat
  SELECT jsonb_build_object(
    'success', true,
    'user_id', p_user_id,
    'new_tier', p_new_tier,
    'duration_days', v_duration,
    'expires_at', (NOW() + (v_duration || ' days')::INTERVAL),
    'message', 'Utilisateur réactivé avec succès'
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FONCTIONS DE MIGRATION ET MISE À JOUR
-- ============================================

-- 11. Fonction : migrer tous les utilisateurs existants vers le système demo
-- ============================================
CREATE OR REPLACE FUNCTION migrate_existing_users_to_demo()
RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Mettre à jour tous les utilisateurs sans abonnement défini
    UPDATE users 
    SET 
        subscription_tier = 'demo',
        subscription_starts_at = NOW(),
        subscription_ends_at = NOW() + INTERVAL '7 days',
        updated_at = NOW()
    WHERE subscription_tier IS NULL OR subscription_tier = '';
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    RETURN format('Migration terminée : %s utilisateur(s) migré(s) vers demo (7 jours)', v_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGERS POUR NOUVEAUX UTILISATEURS
-- ============================================

-- 12. Trigger : assigner automatiquement demo aux nouveaux utilisateurs
-- ============================================
CREATE OR REPLACE FUNCTION assign_demo_subscription()
RETURNS TRIGGER AS $$
BEGIN
    -- Si pas d'abonnement défini, assigner demo pour 7 jours
    IF NEW.subscription_tier IS NULL OR NEW.subscription_tier = '' THEN
        NEW.subscription_tier := 'demo';
        NEW.subscription_starts_at := NOW();
        NEW.subscription_ends_at := NOW() + INTERVAL '7 days';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger (seulement s'il n'existe pas)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'trigger_assign_demo_subscription'
    ) THEN
        CREATE TRIGGER trigger_assign_demo_subscription
            BEFORE INSERT ON users
            FOR EACH ROW
            EXECUTE FUNCTION assign_demo_subscription();
    END IF;
END $$;

-- ============================================
-- CONFIRMATION ET TESTS
-- ============================================

-- Afficher les informations de création
SELECT 
  '✅ Système de blocage automatique installé avec succès!' as message,
  '🔧 Version corrigée avec phone au lieu d''email' as details,
  '📊 Support pour demo (7j), pro (30j), premium (90j)' as tiers,
  NOW() as installed_at;

-- Tester les fonctions principales
SELECT 
  'Fonctions principales créées:' as status,
  EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'check_and_block_expired_subscriptions') as check_function,
  EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'get_expiring_subscriptions') as expiring_function,
  EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'reactivate_user_subscription') as reactivate_function,
  EXISTS(SELECT 1 FROM information_schema.views WHERE table_name = 'subscription_stats') as stats_view;