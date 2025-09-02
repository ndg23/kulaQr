-- 🔍 SCRIPT DE VÉRIFICATION SIMPLIFIÉ
-- À exécuter après avoir terminé toutes les étapes de reconstruction

-- 1. VÉRIFICATION DES TABLES
SELECT '📊 VÉRIFICATION DES TABLES' as info;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- 2. VÉRIFICATION DES POLITIQUES RLS
SELECT '🔒 VÉRIFICATION DES POLITIQUES RLS' as info;
SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;

-- 3. VÉRIFICATION DES FONCTIONS
SELECT '⚙️ VÉRIFICATION DES FONCTIONS' as info;
SELECT proname as function_name FROM pg_proc WHERE schemaname = 'public' ORDER BY proname;

-- 4. VÉRIFICATION DES TRIGGERS
SELECT '🎯 VÉRIFICATION DES TRIGGERS' as info;
SELECT tgname as trigger_name, tgrelid::regclass as table_name FROM pg_trigger WHERE schemaname = 'public' AND NOT tgisinternal ORDER BY tgname;

-- 5. VÉRIFICATION DES VUES
SELECT '👁️ VÉRIFICATION DES VUES' as info;
SELECT viewname FROM pg_views WHERE schemaname = 'public' ORDER BY viewname;

-- 6. VÉRIFICATION DES DONNÉES INITIALES
SELECT '🌱 VÉRIFICATION DES DONNÉES INITIALES' as info;
SELECT 'establishment_types' as table_name, COUNT(*) as count FROM establishment_types
UNION ALL
SELECT 'users' as table_name, COUNT(*) as count FROM users;

-- 7. MESSAGE DE CONFIRMATION
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 VÉRIFICATION TERMINÉE !';
    RAISE NOTICE '📋 Vérifiez les résultats ci-dessus pour vous assurer que tout est en place.';
    RAISE NOTICE '';
END $$;
