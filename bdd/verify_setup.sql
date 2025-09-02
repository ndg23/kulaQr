-- 🔍 SCRIPT DE VÉRIFICATION RAPIDE
-- À exécuter après avoir terminé toutes les étapes de reconstruction

-- 1. VÉRIFICATION DES TABLES
SELECT 
    '📊 TABLES' as section,
    tablename,
    'Créée' as status
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. VÉRIFICATION DES POLITIQUES RLS
SELECT 
    '🔒 POLITIQUES RLS' as section,
    tablename,
    policyname,
    cmd,
    'Active' as status
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3. VÉRIFICATION DES FONCTIONS
SELECT 
    '⚙️ FONCTIONS' as section,
    proname as function_name,
    'Créée' as status
FROM pg_proc 
WHERE schemaname = 'public'
ORDER BY proname;

-- 4. VÉRIFICATION DES TRIGGERS
SELECT 
    '🎯 TRIGGERS' as section,
    tgname as trigger_name,
    tgrelid::regclass as table_name,
    'Actif' as status
FROM pg_trigger 
WHERE schemaname = 'public' AND NOT tgisinternal
ORDER BY tgname;

-- 5. VÉRIFICATION DES VUES
SELECT 
    '👁️ VUES' as section,
    viewname,
    'Créée' as status
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;

-- 6. VÉRIFICATION DES DONNÉES INITIALES
SELECT 
    '🌱 DONNÉES INITIALES' as section,
    'establishment_types' as table_name,
    COUNT(*) as count,
    'Insérées' as status
FROM establishment_types
UNION ALL
SELECT 
    '🌱 DONNÉES INITIALES' as section,
    'users' as table_name,
    COUNT(*) as count,
    'Vide (normal)' as status
FROM users;

-- 7. RÉSUMÉ FINAL SIMPLIFIÉ
DO $$
DECLARE
    table_count INTEGER;
    policy_count INTEGER;
    function_count INTEGER;
    trigger_count INTEGER;
    view_count INTEGER;
BEGIN
    -- Compter les objets
    SELECT COUNT(*) INTO table_count FROM pg_tables WHERE schemaname = 'public';
    SELECT COUNT(*) INTO policy_count FROM pg_policies WHERE schemaname = 'public';
    SELECT COUNT(*) INTO function_count FROM pg_proc WHERE schemaname = 'public';
    SELECT COUNT(*) INTO trigger_count FROM pg_trigger WHERE schemaname = 'public' AND NOT tgisinternal;
    SELECT COUNT(*) INTO view_count FROM pg_views WHERE schemaname = 'public';
    
    -- Afficher le résumé
    RAISE NOTICE '';
    RAISE NOTICE '🎉 RÉSUMÉ DE LA RECONSTRUCTION';
    RAISE NOTICE '================================';
    RAISE NOTICE '📊 Tables créées: %', table_count;
    RAISE NOTICE '🔒 Politiques RLS: %', policy_count;
    RAISE NOTICE '⚙️ Fonctions: %', function_count;
    RAISE NOTICE '🎯 Triggers: %', trigger_count;
    RAISE NOTICE '👁️ Vues: %', view_count;
    RAISE NOTICE '';
    
    -- Vérifier que tout est en place
    IF table_count >= 10 AND policy_count >= 20 AND function_count >= 5 THEN
        RAISE NOTICE '✅ RECONSTRUCTION RÉUSSIE ! La base est prête pour les tests.';
    ELSE
        RAISE NOTICE '❌ RECONSTRUCTION INCOMPLÈTE. Vérifiez les étapes manquantes.';
    END IF;
    
    RAISE NOTICE '';
END $$;
