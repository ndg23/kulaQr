-- ============================================
-- PATCH CORRECTION : Supprimer subscription_starts_at
-- ============================================

-- 1. Recréer la fonction reactivate_user_subscription sans subscription_starts_at
DROP FUNCTION IF EXISTS reactivate_user_subscription(UUID, TEXT, INTEGER) CASCADE;

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
  
  -- Réactiver l'utilisateur (sans subscription_starts_at)
  UPDATE users 
  SET 
    is_active = true,
    subscription_tier = p_new_tier,
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

-- 2. Recréer le trigger sans subscription_starts_at
DROP FUNCTION IF EXISTS assign_demo_subscription() CASCADE;

CREATE OR REPLACE FUNCTION assign_demo_subscription()
RETURNS TRIGGER AS $$
BEGIN
    -- Si pas d'abonnement défini, assigner demo pour 7 jours
    IF NEW.subscription_tier IS NULL OR NEW.subscription_tier = '' THEN
        NEW.subscription_tier := 'demo';
        NEW.subscription_ends_at := NOW() + INTERVAL '7 days';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recréer le trigger
DROP TRIGGER IF EXISTS trigger_assign_demo_subscription ON users;
CREATE TRIGGER trigger_assign_demo_subscription
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION assign_demo_subscription();

-- Confirmation
SELECT 'Patch appliqué: subscription_starts_at supprimé' as message;