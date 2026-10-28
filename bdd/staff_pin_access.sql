-- Connexion du personnel par PIN et prise de commandes, sans compte Supabase.
-- Le personnel utilise la clé publique : la table staff n'est pas lisible (RLS) et les commandes ne sont pas
-- modifiables en direct. Ces fonctions SECURITY DEFINER sont donc le seul point d'entrée.
-- Relançable sans risque. À exécuter dans l'éditeur SQL de Supabase.
BEGIN;

-- Sessions du personnel : jeton aléatoire, durée limitée, accessible uniquement par les fonctions ci-dessous
CREATE TABLE IF NOT EXISTS staff_sessions (
    token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (NOW() + INTERVAL '12 hours')
);
CREATE INDEX IF NOT EXISTS idx_staff_sessions_staff ON staff_sessions(staff_id);
ALTER TABLE staff_sessions ENABLE ROW LEVEL SECURITY; -- aucune policy : lecture et écriture réservées aux fonctions

-- Connexion : identifiant + PIN -> jeton de session
CREATE OR REPLACE FUNCTION public.staff_pin_login(p_username TEXT, p_pin TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_staff staff%ROWTYPE;
    v_token UUID;
BEGIN
    SELECT s.* INTO v_staff
    FROM staff s
    JOIN establishments e ON e.id = s.establishment_id
    WHERE lower(s.username) = lower(trim(p_username))
      AND s.pin = trim(p_pin)
      AND s.is_active = TRUE
      AND COALESCE(e.is_active, TRUE) = TRUE
    LIMIT 1;

    IF NOT FOUND THEN
        PERFORM pg_sleep(0.5); -- freine les essais en rafale
        RETURN NULL;
    END IF;

    DELETE FROM staff_sessions WHERE expires_at < NOW(); -- ménage
    INSERT INTO staff_sessions (staff_id) VALUES (v_staff.id) RETURNING token INTO v_token;
    UPDATE staff SET last_login = NOW() WHERE id = v_staff.id;

    RETURN json_build_object(
        'token', v_token,
        'staff_id', v_staff.id,
        'username', v_staff.username,
        'full_name', v_staff.full_name,
        'role', v_staff.role,
        'establishment_id', v_staff.establishment_id
    );
END;
$$;

-- Vérifie un jeton et renvoie le membre du personnel (NULL si expiré, inconnu ou compte désactivé)
CREATE OR REPLACE FUNCTION public.staff_session_info(p_token UUID)
RETURNS JSON
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT json_build_object(
        'id', s.id,
        'username', s.username,
        'full_name', s.full_name,
        'role', s.role,
        'establishment_id', s.establishment_id
    )
    FROM staff_sessions ss
    JOIN staff s ON s.id = ss.staff_id
    WHERE ss.token = p_token
      AND ss.expires_at > NOW()
      AND s.is_active = TRUE;
$$;

-- Déconnexion
CREATE OR REPLACE FUNCTION public.staff_logout(p_token UUID)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    DELETE FROM staff_sessions WHERE token = p_token;
$$;

-- Changement de statut d'une commande de SON établissement.
-- Transitions permises : pending -> confirmed -> processing -> completed, et annulation avant la fin.
-- Renvoie FALSE si la commande a déjà changé de statut (course entre deux membres du personnel).
CREATE OR REPLACE FUNCTION public.staff_set_order_status(p_token UUID, p_order_id UUID, p_status TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_staff_id UUID;
    v_est_id UUID;
    v_expected TEXT[];
    v_rows INTEGER;
BEGIN
    SELECT s.id, s.establishment_id INTO v_staff_id, v_est_id
    FROM staff_sessions ss
    JOIN staff s ON s.id = ss.staff_id
    WHERE ss.token = p_token AND ss.expires_at > NOW() AND s.is_active = TRUE;

    IF v_staff_id IS NULL THEN
        RAISE EXCEPTION 'Session du personnel invalide ou expirée' USING ERRCODE = '28000';
    END IF;

    v_expected := CASE p_status
        WHEN 'confirmed'  THEN ARRAY['pending']
        WHEN 'processing' THEN ARRAY['confirmed']
        WHEN 'completed'  THEN ARRAY['processing']
        WHEN 'cancelled'  THEN ARRAY['pending', 'confirmed', 'processing']
        ELSE NULL
    END;

    IF v_expected IS NULL THEN
        RAISE EXCEPTION 'Statut non autorisé : %', p_status USING ERRCODE = '22023';
    END IF;

    UPDATE orders
    SET status = p_status,
        staff_id = CASE WHEN p_status IN ('confirmed', 'processing') THEN v_staff_id ELSE staff_id END,
        updated_at = NOW()
    WHERE id = p_order_id
      AND establishment_id = v_est_id
      AND status = ANY (v_expected);

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows > 0;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.staff_pin_login(TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.staff_session_info(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.staff_logout(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.staff_set_order_status(UUID, UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.staff_pin_login(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.staff_session_info(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.staff_logout(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.staff_set_order_status(UUID, UUID, TEXT) TO anon, authenticated;

COMMIT;
