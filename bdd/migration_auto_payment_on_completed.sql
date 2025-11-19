-- Migration: Auto-paiement lors de la completion d'une commande
-- Date: 2025-11-19
-- Description: Change automatiquement le statut de paiement à "paid" 
--              lorsqu'une commande passe au statut "completed"

-- ============================================================
-- LOGIQUE:
-- Lorsqu'une commande est marquée comme "completed":
-- 1. Si payment_status = 'unpaid' → change vers 'paid'
-- 2. Si payment_method est NULL → définir par défaut 'cash'
-- 3. Enregistrer l'heure du paiement
-- ============================================================

-- Fonction trigger pour auto-paiement
CREATE OR REPLACE FUNCTION auto_payment_on_order_completed()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier si le statut change vers 'completed'
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        
        -- Si la commande n'est pas encore payée, la marquer comme payée
        IF NEW.payment_status = 'unpaid' THEN
            NEW.payment_status := 'paid';
            
            -- Si aucune méthode de paiement n'est définie, utiliser 'cash' par défaut
            IF NEW.payment_method IS NULL THEN
                NEW.payment_method := 'cash';
            END IF;
            
            -- Log de l'action dans les notes (optionnel)
            IF NEW.notes IS NULL OR NEW.notes = '' THEN
                NEW.notes := 'Paiement automatique enregistré lors de la complétion de la commande.';
            ELSE
                NEW.notes := NEW.notes || E'\n\nPaiement automatique enregistré lors de la complétion de la commande.';
            END IF;
            
            -- Log pour le débogage
            RAISE NOTICE 'Auto-paiement: Commande % marquée comme payée (méthode: %)', 
                NEW.id, COALESCE(NEW.payment_method, 'cash');
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trigger_auto_payment_on_completed ON orders;
CREATE TRIGGER trigger_auto_payment_on_completed
    BEFORE UPDATE OF status ON orders
    FOR EACH ROW
    WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
    EXECUTE FUNCTION auto_payment_on_order_completed();

-- Ajouter un commentaire sur le trigger
COMMENT ON TRIGGER trigger_auto_payment_on_completed ON orders IS 
'Marque automatiquement une commande comme payée (paid) lorsqu''elle passe au statut completed.
Si aucune méthode de paiement n''est définie, utilise "cash" par défaut.';

-- ============================================================
-- FONCTION HELPER: Vérifier si une commande sera auto-payée
-- ============================================================
CREATE OR REPLACE FUNCTION will_auto_pay_on_completion(order_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    order_record RECORD;
BEGIN
    SELECT status, payment_status
    INTO order_record
    FROM orders
    WHERE id = order_id;
    
    -- Retourne true si la commande n'est pas completed et unpaid
    RETURN (order_record.status != 'completed' AND order_record.payment_status = 'unpaid');
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION will_auto_pay_on_completion(UUID) IS 
'Vérifie si une commande sera automatiquement marquée comme payée lors de sa complétion.';

-- ============================================================
-- FONCTION: Batch update pour les commandes existantes
-- ============================================================
-- Cette fonction peut être utilisée pour mettre à jour rétroactivement
-- les commandes déjà complétées mais marquées comme non payées
CREATE OR REPLACE FUNCTION fix_completed_unpaid_orders()
RETURNS TABLE(
    order_id UUID,
    previous_payment_status VARCHAR(50),
    new_payment_status VARCHAR(50),
    payment_method VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    UPDATE orders
    SET 
        payment_status = 'paid',
        payment_method = COALESCE(payment_method, 'cash'),
        notes = COALESCE(notes || E'\n\n', '') || 
                'Paiement corrigé automatiquement - commande complétée le ' || 
                updated_at::timestamp::text,
        updated_at = NOW()
    WHERE status = 'completed'
      AND payment_status = 'unpaid'
    RETURNING 
        id as order_id,
        'unpaid'::VARCHAR(50) as previous_payment_status,
        payment_status as new_payment_status,
        payment_method;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fix_completed_unpaid_orders() IS 
'Met à jour rétroactivement toutes les commandes complétées mais non payées.
À utiliser une seule fois après l''installation du trigger.';

-- ============================================================
-- VUE: Statistiques de paiement
-- ============================================================
CREATE OR REPLACE VIEW order_payment_stats AS
SELECT 
    status,
    payment_status,
    COUNT(*) as count,
    SUM(total_amount) as total_amount,
    AVG(total_amount) as avg_amount,
    payment_method
FROM orders
GROUP BY status, payment_status, payment_method
ORDER BY status, payment_status;

COMMENT ON VIEW order_payment_stats IS 
'Statistiques des commandes par statut et statut de paiement.';

-- ============================================================
-- FONCTION DE TEST
-- ============================================================
CREATE OR REPLACE FUNCTION test_auto_payment_trigger()
RETURNS TABLE(
    test_name TEXT,
    passed BOOLEAN,
    message TEXT
) AS $$
DECLARE
    test_order_id UUID;
    test_establishment_id UUID;
BEGIN
    -- Obtenir un établissement actif pour les tests
    SELECT id INTO test_establishment_id
    FROM establishments
    WHERE is_active = true
    LIMIT 1;
    
    IF test_establishment_id IS NULL THEN
        RETURN QUERY SELECT 
            'Setup test'::TEXT,
            false,
            'Aucun établissement actif trouvé pour les tests'::TEXT;
        RETURN;
    END IF;
    
    -- Test 1: Créer une commande non payée
    INSERT INTO orders (establishment_id, table_number, status, payment_status, total_amount)
    VALUES (test_establishment_id, 99, 'pending', 'unpaid', 1000)
    RETURNING id INTO test_order_id;
    
    RETURN QUERY SELECT 
        'Test 1: Create unpaid order'::TEXT,
        EXISTS(SELECT 1 FROM orders WHERE id = test_order_id AND payment_status = 'unpaid'),
        'Commande créée avec payment_status = unpaid'::TEXT;
    
    -- Test 2: Marquer comme completed (devrait auto-payer)
    UPDATE orders 
    SET status = 'completed'
    WHERE id = test_order_id;
    
    RETURN QUERY SELECT 
        'Test 2: Auto-payment on completion'::TEXT,
        EXISTS(SELECT 1 FROM orders WHERE id = test_order_id AND payment_status = 'paid'),
        'Commande auto-payée lors du passage à completed'::TEXT;
    
    -- Test 3: Vérifier la méthode de paiement par défaut
    RETURN QUERY SELECT 
        'Test 3: Default payment method'::TEXT,
        EXISTS(SELECT 1 FROM orders WHERE id = test_order_id AND payment_method = 'cash'),
        'Méthode de paiement définie à "cash" par défaut'::TEXT;
    
    -- Nettoyage
    DELETE FROM orders WHERE id = test_order_id;
    
    RETURN QUERY SELECT 
        'Cleanup'::TEXT,
        NOT EXISTS(SELECT 1 FROM orders WHERE id = test_order_id),
        'Commande de test supprimée'::TEXT;
        
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION test_auto_payment_trigger() IS 
'Teste le trigger d''auto-paiement. Crée une commande, la complète, et vérifie l''auto-paiement.';

-- ============================================================
-- INSTRUCTIONS D'UTILISATION
-- ============================================================
-- 
-- 1. Tester le trigger:
--    SELECT * FROM test_auto_payment_trigger();
--
-- 2. Corriger les commandes existantes (une seule fois):
--    SELECT * FROM fix_completed_unpaid_orders();
--
-- 3. Voir les statistiques de paiement:
--    SELECT * FROM order_payment_stats;
--
-- 4. Vérifier si une commande sera auto-payée:
--    SELECT will_auto_pay_on_completion('order-uuid-here');
--
-- 5. Exemple d'utilisation manuelle:
--    UPDATE orders SET status = 'completed' WHERE id = 'xxx';
--    -- Le paiement sera automatiquement marqué comme 'paid'
--
-- ============================================================
-- ROLLBACK (si nécessaire)
-- ============================================================
-- 
-- DROP TRIGGER IF EXISTS trigger_auto_payment_on_completed ON orders;
-- DROP FUNCTION IF EXISTS auto_payment_on_order_completed();
-- DROP FUNCTION IF EXISTS will_auto_pay_on_completion(UUID);
-- DROP FUNCTION IF EXISTS fix_completed_unpaid_orders();
-- DROP FUNCTION IF EXISTS test_auto_payment_trigger();
-- DROP VIEW IF EXISTS order_payment_stats;
--
-- ============================================================

-- Message de succès
DO $$
BEGIN
    RAISE NOTICE '✅ Migration appliquée avec succès!';
    RAISE NOTICE '📋 Exécutez: SELECT * FROM test_auto_payment_trigger(); pour tester';
    RAISE NOTICE '🔧 Exécutez: SELECT * FROM fix_completed_unpaid_orders(); pour corriger les anciennes commandes';
END $$;
