-- Prise de commande par le personnel connecté avec son PIN (écran « Nouvelle commande » de /staff/vendre).
-- Comme staff_set_order_status, c'est une fonction SECURITY DEFINER : le personnel n'a pas de compte Supabase,
-- la fonction vérifie le jeton de session, reprend les prix dans la table products (jamais ceux envoyés par le
-- navigateur) et ne touche qu'à l'établissement du membre du personnel.
-- Prérequis : bdd/staff_pin_access.sql. Relançable sans risque. À exécuter dans l'éditeur SQL de Supabase.
BEGIN;

CREATE OR REPLACE FUNCTION public.staff_create_order(
    p_token UUID,
    p_table_id UUID,
    p_notes TEXT,
    p_items JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_staff_id UUID;
    v_est_id UUID;
    v_order_id UUID;
    v_item JSONB;
    v_product products%ROWTYPE;
    v_qty INTEGER;
    v_total NUMERIC := 0;
    v_table_number INTEGER;
BEGIN
    SELECT s.id, s.establishment_id INTO v_staff_id, v_est_id
    FROM staff_sessions ss
    JOIN staff s ON s.id = ss.staff_id
    WHERE ss.token = p_token AND ss.expires_at > NOW() AND s.is_active = TRUE;

    IF v_staff_id IS NULL THEN
        RAISE EXCEPTION 'Session du personnel invalide ou expirée' USING ERRCODE = '28000';
    END IF;

    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'La commande est vide' USING ERRCODE = '22023';
    END IF;

    IF p_table_id IS NOT NULL THEN
        SELECT NULLIF(regexp_replace(t.table_number::text, '\D', '', 'g'), '')::INTEGER
        INTO v_table_number
        FROM tables t
        WHERE t.id = p_table_id AND t.establishment_id = v_est_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Table inconnue' USING ERRCODE = '22023';
        END IF;
    END IF;

    INSERT INTO orders (establishment_id, table_id, table_number, status, total_amount, notes, staff_id)
    VALUES (v_est_id, p_table_id, v_table_number, 'confirmed', 0, NULLIF(trim(p_notes), ''), v_staff_id)
    RETURNING id INTO v_order_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_qty := COALESCE((v_item->>'quantity')::INTEGER, 0);
        IF v_qty < 1 OR v_qty > 99 THEN
            RAISE EXCEPTION 'Quantité invalide' USING ERRCODE = '22023';
        END IF;

        SELECT * INTO v_product
        FROM products
        WHERE id = (v_item->>'product_id')::UUID
          AND establishment_id = v_est_id
          AND COALESCE(is_available, TRUE) = TRUE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Produit indisponible' USING ERRCODE = '22023';
        END IF;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
        VALUES (v_order_id, v_product.id, v_qty, v_product.price, v_qty * v_product.price);

        v_total := v_total + v_qty * v_product.price;
    END LOOP;

    UPDATE orders SET total_amount = v_total, updated_at = NOW() WHERE id = v_order_id;

    RETURN json_build_object('id', v_order_id, 'total_amount', v_total, 'table_number', v_table_number);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.staff_create_order(UUID, UUID, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.staff_create_order(UUID, UUID, TEXT, JSONB) TO anon, authenticated;

COMMIT;
