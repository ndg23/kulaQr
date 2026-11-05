-- Commande d'un client qui a scanné le QR code d'une table.
-- Avant : le navigateur écrivait lui-même la commande, avec les prix et le total qu'il choisissait.
-- Maintenant : la base reprend les prix dans la table products, refuse les produits d'un autre établissement ou
-- indisponibles, plafonne les quantités et limite les commandes en rafale sur une même table.
-- Relançable sans risque. À exécuter dans l'éditeur SQL de Supabase.
BEGIN;

CREATE OR REPLACE FUNCTION public.create_customer_order(
    p_establishment_id UUID,
    p_table_number TEXT,
    p_notes TEXT,
    p_items JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_table_id UUID;
    v_table_number TEXT;
    v_order_id UUID;
    v_item JSONB;
    v_product products%ROWTYPE;
    v_qty INTEGER;
    v_total NUMERIC := 0;
    v_lines INTEGER;
BEGIN
    IF NOT establishment_accepts_orders(p_establishment_id) THEN
        RAISE EXCEPTION 'Cet établissement n''accepte pas de commandes pour le moment' USING ERRCODE = '22023';
    END IF;

    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' THEN
        RAISE EXCEPTION 'La commande est vide' USING ERRCODE = '22023';
    END IF;
    v_lines := jsonb_array_length(p_items);
    IF v_lines < 1 OR v_lines > 40 THEN
        RAISE EXCEPTION 'Nombre d''articles invalide' USING ERRCODE = '22023';
    END IF;

    -- La table doit exister dans cet établissement (un QR modifié ne peut pas viser une autre table)
    IF p_table_number IS NOT NULL AND trim(p_table_number) <> '' THEN
        SELECT t.id, t.table_number INTO v_table_id, v_table_number
        FROM tables t
        WHERE t.establishment_id = p_establishment_id
          AND t.table_number = trim(p_table_number)
          AND COALESCE(t.is_active, TRUE) = TRUE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Table inconnue' USING ERRCODE = '22023';
        END IF;

        -- Frein anti-rafale : trois commandes en attente en cinq minutes sur la même table, pas plus
        IF (SELECT COUNT(*) FROM orders
            WHERE table_id = v_table_id AND status = 'pending' AND created_at > NOW() - INTERVAL '5 minutes') >= 3 THEN
            RAISE EXCEPTION 'Trop de commandes en attente sur cette table, patientez un instant' USING ERRCODE = '22023';
        END IF;
    END IF;

    INSERT INTO orders (establishment_id, table_id, table_number, status, total_amount, notes)
    VALUES (
        p_establishment_id,
        v_table_id,
        NULLIF(regexp_replace(COALESCE(v_table_number, ''), '\D', '', 'g'), '')::INTEGER,
        'pending',
        0,
        left(NULLIF(trim(p_notes), ''), 1000)
    )
    RETURNING id INTO v_order_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_qty := COALESCE((v_item->>'quantity')::INTEGER, 0);
        IF v_qty < 1 OR v_qty > 20 THEN
            RAISE EXCEPTION 'Quantité invalide' USING ERRCODE = '22023';
        END IF;

        SELECT * INTO v_product
        FROM products
        WHERE id = (v_item->>'product_id')::UUID
          AND establishment_id = p_establishment_id
          AND COALESCE(is_available, TRUE) = TRUE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Un produit n''est plus disponible' USING ERRCODE = '22023';
        END IF;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal, notes)
        VALUES (v_order_id, v_product.id, v_qty, v_product.price, v_qty * v_product.price,
                left(NULLIF(trim(v_item->>'notes'), ''), 200));

        v_total := v_total + v_qty * v_product.price;
    END LOOP;

    UPDATE orders SET total_amount = v_total, updated_at = NOW() WHERE id = v_order_id;

    RETURN json_build_object('id', v_order_id, 'total_amount', v_total, 'table_number', v_table_number, 'table_id', v_table_id);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_customer_order(UUID, TEXT, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_customer_order(UUID, TEXT, TEXT, JSONB) TO anon, authenticated;

COMMIT;

-- ÉTAPE 2 : À EXÉCUTER SEULEMENT APRÈS le déploiement du nouveau menu client (qui appelle cette fonction).
-- Elle ferme l'écriture directe : plus personne ne peut insérer une commande ou des lignes avec ses propres prix.
-- Les commandes passent alors uniquement par create_customer_order (clients), staff_create_order (personnel)
-- et les politiques « Owners manage … » (gérants).
--
-- BEGIN;
-- DROP POLICY IF EXISTS "Order creation for active establishments only" ON orders;
-- DROP POLICY IF EXISTS "Order item creation" ON order_items;
-- COMMIT;
