-- Lecture des commandes par le personnel connecté avec son PIN, articles compris.
-- Problème : le personnel n'a pas de compte Supabase (il utilise la clé publique) et aucune règle ne lui permet
-- de lire order_items. Les commandes s'affichaient donc sans leurs articles (total et notes seulement).
-- Cette fonction SECURITY DEFINER vérifie le jeton de session et ne renvoie que les commandes de SON établissement,
-- dans la même forme que la requête qu'utilisait l'écran (tables, staff, items, products).
-- Prérequis : bdd/staff_pin_access.sql. Relançable sans risque. À exécuter dans l'éditeur SQL de Supabase.
BEGIN;

CREATE OR REPLACE FUNCTION public.staff_list_orders(p_token UUID, p_limit INTEGER DEFAULT 150)
RETURNS JSON
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_est_id UUID;
BEGIN
    SELECT s.establishment_id INTO v_est_id
    FROM staff_sessions ss
    JOIN staff s ON s.id = ss.staff_id
    WHERE ss.token = p_token AND ss.expires_at > NOW() AND s.is_active = TRUE;

    IF v_est_id IS NULL THEN
        RAISE EXCEPTION 'Session du personnel invalide ou expirée' USING ERRCODE = '28000';
    END IF;

    RETURN COALESCE((
        SELECT json_agg(q.row_json ORDER BY q.created_at DESC)
        FROM (
            SELECT
                o.created_at,
                to_jsonb(o) || jsonb_build_object(
                    'tables', (
                        SELECT jsonb_build_object(
                            'id', t.id, 'table_number', t.table_number, 'type', t.type,
                            'section_name', t.section_name, 'floor_level', t.floor_level,
                            'capacity', t.capacity, 'location_description', t.location_description)
                        FROM tables t WHERE t.id = o.table_id
                    ),
                    'staff', (
                        SELECT jsonb_build_object('id', st.id, 'username', st.username)
                        FROM staff st WHERE st.id = o.staff_id
                    ),
                    'items', COALESCE((
                        SELECT jsonb_agg(jsonb_build_object(
                            'id', oi.id, 'quantity', oi.quantity, 'unit_price', oi.unit_price, 'notes', oi.notes,
                            'products', jsonb_build_object('id', p.id, 'name', p.name, 'description', p.description, 'price', p.price)
                        ) ORDER BY oi.created_at)
                        FROM order_items oi
                        LEFT JOIN products p ON p.id = oi.product_id
                        WHERE oi.order_id = o.id
                    ), '[]'::jsonb)
                ) AS row_json
            FROM orders o
            WHERE o.establishment_id = v_est_id
            ORDER BY o.created_at DESC
            LIMIT LEAST(GREATEST(COALESCE(p_limit, 150), 1), 300)
        ) q
    ), '[]'::json);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.staff_list_orders(UUID, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.staff_list_orders(UUID, INTEGER) TO anon, authenticated;

COMMIT;
