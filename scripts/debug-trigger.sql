-- Script pour vérifier et corriger le trigger d'assignation demo

-- 1. Vérifier si le trigger existe
SELECT 
    t.tgname AS trigger_name,
    c.relname AS table_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'trigger_assign_demo_subscription';

-- 2. Vérifier la fonction
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'assign_demo_subscription';

-- 3. Test : créer un utilisateur pour voir le comportement
-- (à exécuter manuellement si besoin)

-- 4. Si le trigger n'existe pas, l'installer
DO $$
BEGIN
    -- Supprimer l'ancien trigger s'il existe
    DROP TRIGGER IF EXISTS trigger_assign_demo_subscription ON users;
    
    -- Créer le nouveau trigger
    CREATE TRIGGER trigger_assign_demo_subscription
        BEFORE INSERT ON users
        FOR EACH ROW
        EXECUTE FUNCTION assign_demo_subscription();
        
    RAISE NOTICE 'Trigger assign_demo_subscription installé avec succès';
END $$;