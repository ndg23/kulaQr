-- ========================================
-- SCRIPT DE NETTOYAGE COMPLET DE LA BASE
-- ========================================
-- ATTENTION: Ce script supprime TOUT de votre base de données
-- Utilisez-le uniquement en développement ou pour repartir de zéro

-- Désactiver les contraintes de clés étrangères temporairement
SET session_replication_role = replica;

-- ========================================
-- SUPPRESSION DES POLITIQUES RLS
-- ========================================
DO $$
DECLARE
    r RECORD;
BEGIN
    -- Supprimer TOUTES les politiques existantes
    FOR r IN (
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I CASCADE', 
                      r.policyname, r.schemaname, r.tablename);
        RAISE NOTICE 'Politique supprimée: % ON %.%', r.policyname, r.schemaname, r.tablename;
    END LOOP;
END $$;

-- ========================================
-- SUPPRESSION DES TRIGGERS
-- ========================================
DO $$
DECLARE
    r RECORD;
BEGIN
    -- Supprimer TOUS les triggers existants
    FOR r IN (
        SELECT trigger_name, event_object_table 
        FROM information_schema.triggers 
        WHERE trigger_schema = 'public'
    ) LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', 
                      r.trigger_name, r.event_object_table);
        RAISE NOTICE 'Trigger supprimé: % ON %', r.trigger_name, r.event_object_table;
    END LOOP;
END $$;

-- ========================================
-- SUPPRESSION DES FONCTIONS
-- ========================================
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_category_product_count() CASCADE;
DROP FUNCTION IF EXISTS check_subscription_limits() CASCADE;
DROP FUNCTION IF EXISTS generate_establishment_slug() CASCADE;
DROP FUNCTION IF EXISTS update_last_login() CASCADE;
DROP FUNCTION IF EXISTS check_subscription_validity() CASCADE;
DROP FUNCTION IF EXISTS cleanup_related_data() CASCADE;
DROP FUNCTION IF EXISTS generate_random_pin() CASCADE;
DROP FUNCTION IF EXISTS create_staff_pin() CASCADE;
DROP FUNCTION IF EXISTS regenerate_staff_pin() CASCADE;
DROP FUNCTION IF EXISTS log_staff_activity() CASCADE;
DROP FUNCTION IF EXISTS get_popular_restaurants() CASCADE;
DROP FUNCTION IF EXISTS get_order_stats() CASCADE;
DROP FUNCTION IF EXISTS is_admin_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS insert_qr_scan(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_table_columns(TEXT) CASCADE;
DROP FUNCTION IF EXISTS toggle_table_occupancy(UUID, UUID, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS create_default_tables(UUID, INTEGER) CASCADE;

-- ========================================
-- SUPPRESSION DES VUES
-- ========================================
DROP VIEW IF EXISTS admin_statistics CASCADE;
DROP VIEW IF EXISTS monthly_growth_stats CASCADE;
DROP VIEW IF EXISTS popular_restaurants CASCADE;
DROP VIEW IF EXISTS recent_activity CASCADE;
DROP VIEW IF EXISTS qr_scan_stats CASCADE;
DROP VIEW IF EXISTS popular_establishments CASCADE;
DROP VIEW IF EXISTS staff_activity CASCADE;
DROP VIEW IF EXISTS order_statistics CASCADE;
DROP VIEW IF EXISTS qr_code_analytics CASCADE;
DROP VIEW IF EXISTS table_status_view CASCADE;
DROP VIEW IF EXISTS table_analytics CASCADE;
DROP VIEW IF EXISTS establishment_activities CASCADE;

-- ========================================
-- SUPPRESSION DES TABLES (dans l'ordre des dépendances)
-- ========================================

-- Tables avec contraintes de clés étrangères
DROP TABLE IF EXISTS qr_scans CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS staff_activity_logs CASCADE;
DROP TABLE IF EXISTS qr_codes CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS establishments CASCADE;
DROP TABLE IF EXISTS establishment_types CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS activities CASCADE;

-- ========================================
-- SUPPRESSION DES INDEX
-- ========================================
-- Les index sont automatiquement supprimés avec les tables

-- ========================================
-- SUPPRESSION DES EXTENSIONS (optionnel)
-- ========================================
-- DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
-- DROP EXTENSION IF EXISTS "pgcrypto" CASCADE;

-- ========================================
-- SUPPRESSION DES SCHEMAS PERSONNALISÉS
-- ========================================
-- DROP SCHEMA IF EXISTS custom_schema CASCADE;

-- ========================================
-- SUPPRESSION DES ROLES PERSONNALISÉS
-- ========================================
-- DROP ROLE IF EXISTS custom_role;

-- ========================================
-- SUPPRESSION DES TABLESPACES PERSONNALISÉS
-- ========================================
-- DROP TABLESPACE IF EXISTS custom_tablespace;

-- Réactiver les contraintes de clés étrangères
SET session_replication_role = DEFAULT;

-- ========================================
-- VÉRIFICATION DU NETTOYAGE
-- ========================================
DO $$
DECLARE
    table_count INTEGER;
    view_count INTEGER;
    function_count INTEGER;
    trigger_count INTEGER;
    policy_count INTEGER;
BEGIN
    -- Compter les objets restants
    SELECT COUNT(*) INTO table_count FROM information_schema.tables WHERE table_schema = 'public';
    SELECT COUNT(*) INTO view_count FROM information_schema.views WHERE table_schema = 'public';
    SELECT COUNT(*) INTO function_count FROM information_schema.routines WHERE routine_schema = 'public';
    SELECT COUNT(*) INTO trigger_count FROM information_schema.triggers WHERE trigger_schema = 'public';
    SELECT COUNT(*) INTO policy_count FROM pg_policies WHERE schemaname = 'public';
    
    RAISE NOTICE '=== RÉSULTAT DU NETTOYAGE ===';
    RAISE NOTICE 'Tables restantes: %', table_count;
    RAISE NOTICE 'Vues restantes: %', view_count;
    RAISE NOTICE 'Fonctions restantes: %', function_count;
    RAISE NOTICE 'Triggers restants: %', trigger_count;
    RAISE NOTICE 'Politiques restantes: %', policy_count;
    
    IF table_count = 0 AND view_count = 0 AND function_count = 0 AND trigger_count = 0 AND policy_count = 0 THEN
        RAISE NOTICE '✅ NETTOYAGE COMPLET RÉUSSI !';
    ELSE
        RAISE NOTICE '⚠️  Certains objets persistent encore';
    END IF;
END $$;

-- ========================================
-- MESSAGE DE FIN
-- ========================================
SELECT 'NETTOYAGE TERMINÉ - Votre base de données est maintenant vide' as status;
