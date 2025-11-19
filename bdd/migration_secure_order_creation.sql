-- Migration: Sécuriser la création de commandes
-- Date: 2025-11-19
-- Description: Empêcher les commandes pour les établissements dont le propriétaire est bloqué

-- ============================================================
-- PROBLÈME:
-- Actuellement, la politique "Allow anonymous order creation" 
-- permet de créer des commandes même si:
-- 1. L'établissement est inactif (is_active = false)
-- 2. Le propriétaire est bloqué (users.is_active = false)
-- ============================================================

-- 1. Supprimer l'ancienne politique permissive
DROP POLICY IF EXISTS "Allow anonymous order creation" ON orders;

-- 2. Créer une nouvelle politique sécurisée
CREATE POLICY "Allow order creation for active establishments only" ON orders
    FOR INSERT 
    TO anon, authenticated
    WITH CHECK (
        -- Vérifier que l'établissement existe et est actif
        establishment_id IN (
            SELECT e.id 
            FROM establishments e
            INNER JOIN users u ON e.user_id = u.id
            WHERE e.id = establishment_id
            AND e.is_active = true  -- L'établissement doit être actif
            AND u.is_active = true  -- Le propriétaire doit être actif
        )
    );

-- 3. Ajouter un commentaire pour documentation
COMMENT ON POLICY "Allow order creation for active establishments only" ON orders IS 
'Permet la création de commandes uniquement pour les établissements actifs avec des propriétaires actifs. 
Bloque automatiquement les commandes si le propriétaire est bloqué (is_active = false).';

-- 4. Créer une fonction helper pour vérifier si un établissement peut recevoir des commandes
CREATE OR REPLACE FUNCTION can_receive_orders(establishment_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    establishment_active BOOLEAN;
    owner_active BOOLEAN;
BEGIN
    -- Vérifier le statut de l'établissement et de son propriétaire
    SELECT e.is_active, u.is_active
    INTO establishment_active, owner_active
    FROM establishments e
    INNER JOIN users u ON e.user_id = u.id
    WHERE e.id = establishment_uuid;
    
    -- Retourner true seulement si les deux sont actifs
    RETURN (establishment_active = true AND owner_active = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Ajouter un commentaire sur la fonction
COMMENT ON FUNCTION can_receive_orders(UUID) IS 
'Vérifie si un établissement peut recevoir des commandes. 
Retourne true uniquement si l''établissement ET son propriétaire sont actifs.';

-- 6. Créer une vue pour les établissements actifs disponibles pour les commandes
CREATE OR REPLACE VIEW active_establishments_for_orders AS
SELECT 
    e.id,
    e.name,
    e.slug,
    e.description,
    e.image_url,
    e.address,
    e.phone,
    e.is_active as establishment_active,
    u.is_active as owner_active,
    u.full_name as owner_name
FROM establishments e
INNER JOIN users u ON e.user_id = u.id
WHERE e.is_active = true
  AND u.is_active = true;

-- 7. Ajouter un commentaire sur la vue
COMMENT ON VIEW active_establishments_for_orders IS 
'Vue des établissements actifs avec propriétaires actifs, disponibles pour recevoir des commandes.';

-- 8. Créer un trigger pour bloquer automatiquement les commandes en cours
-- si un propriétaire est désactivé
CREATE OR REPLACE FUNCTION block_pending_orders_on_owner_deactivation()
RETURNS TRIGGER AS $$
BEGIN
    -- Si le propriétaire est désactivé
    IF NEW.is_active = false AND OLD.is_active = true THEN
        -- Annuler toutes les commandes en attente de ses établissements
        UPDATE orders o
        SET 
            status = 'cancelled',
            notes = COALESCE(notes || E'\n\n', '') || 
                    'Commande annulée automatiquement - Compte propriétaire désactivé le ' || 
                    NOW()::timestamp::text,
            updated_at = NOW()
        FROM establishments e
        WHERE o.establishment_id = e.id
          AND e.user_id = NEW.id
          AND o.status IN ('pending', 'processing')
          AND o.updated_at > NOW() - INTERVAL '24 hours'; -- Seulement les commandes récentes
        
        -- Log l'action
        RAISE NOTICE 'Commandes en attente annulées pour le propriétaire %', NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Créer le trigger
DROP TRIGGER IF EXISTS trigger_block_orders_on_owner_deactivation ON users;
CREATE TRIGGER trigger_block_orders_on_owner_deactivation
    AFTER UPDATE OF is_active ON users
    FOR EACH ROW
    WHEN (NEW.role IN ('owner', 'manager'))
    EXECUTE FUNCTION block_pending_orders_on_owner_deactivation();

-- 10. Ajouter des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_establishments_user_active 
ON establishments(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_users_active 
ON users(is_active);

-- 11. Créer une fonction pour tester la sécurité
CREATE OR REPLACE FUNCTION test_order_creation_security()
RETURNS TABLE(
    test_name TEXT,
    passed BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Test 1: Vérifier qu'un établissement actif avec propriétaire actif peut recevoir des commandes
    RETURN QUERY
    SELECT 
        'Active establishment can receive orders'::TEXT,
        EXISTS(
            SELECT 1 FROM active_establishments_for_orders LIMIT 1
        ),
        'Au moins un établissement actif doit exister'::TEXT;
    
    -- Test 2: Vérifier que la fonction can_receive_orders fonctionne
    RETURN QUERY
    SELECT 
        'Function can_receive_orders works'::TEXT,
        (SELECT can_receive_orders(id) FROM establishments WHERE is_active = true LIMIT 1),
        'La fonction doit retourner true pour un établissement actif'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- INSTRUCTIONS D'UTILISATION:
-- ============================================================
-- 
-- 1. Tester la migration:
--    SELECT * FROM test_order_creation_security();
--
-- 2. Vérifier les établissements actifs:
--    SELECT * FROM active_establishments_for_orders;
--
-- 3. Tester si un établissement peut recevoir des commandes:
--    SELECT can_receive_orders('establishment_uuid_here');
--
-- 4. Bloquer un propriétaire (cela annulera automatiquement ses commandes en cours):
--    UPDATE users SET is_active = false WHERE id = 'user_uuid_here';
--
-- ============================================================
-- ROLLBACK (si nécessaire):
-- ============================================================
-- 
-- DROP POLICY IF EXISTS "Allow order creation for active establishments only" ON orders;
-- CREATE POLICY "Allow anonymous order creation" ON orders FOR INSERT TO anon WITH CHECK (true);
-- DROP FUNCTION IF EXISTS can_receive_orders(UUID);
-- DROP VIEW IF EXISTS active_establishments_for_orders;
-- DROP TRIGGER IF EXISTS trigger_block_orders_on_owner_deactivation ON users;
-- DROP FUNCTION IF EXISTS block_pending_orders_on_owner_deactivation();
-- DROP FUNCTION IF EXISTS test_order_creation_security();
--
-- ============================================================
