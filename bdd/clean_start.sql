-- 🗑️ SCRIPT DE NETTOYAGE COMPLET - REMETTRE TOUT À ZÉRO
-- ⚠️ ATTENTION : Ce script supprime TOUT et remet la base à zéro
-- À exécuter dans Supabase SQL Editor

-- 1. DÉSACTIVER RLS SUR TOUTES LES TABLES
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS products DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_codes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS qr_scans DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff_activity_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS establishment_types DISABLE ROW LEVEL SECURITY;

-- 2. SUPPRIMER TOUTES LES POLITIQUES RLS
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- 3. SUPPRIMER TOUS LES TRIGGERS
DROP TRIGGER IF EXISTS establishment_slug_insert_trigger ON establishments;
DROP TRIGGER IF EXISTS establishment_slug_update_trigger ON establishments;
DROP TRIGGER IF EXISTS user_last_login_trigger ON users;
DROP TRIGGER IF EXISTS product_count_trigger ON products;
DROP TRIGGER IF EXISTS subscription_limit_trigger ON establishments;
DROP TRIGGER IF EXISTS cleanup_related_data_trigger ON establishments;
DROP TRIGGER IF EXISTS log_auth_events ON auth.audit_log_entries;

-- 4. SUPPRIMER TOUTES LES FONCTIONS CUSTOM
DROP FUNCTION IF EXISTS generate_establishment_slug() CASCADE;
DROP FUNCTION IF EXISTS update_product_count() CASCADE;
DROP FUNCTION IF EXISTS check_subscription_limit() CASCADE;
DROP FUNCTION IF EXISTS cleanup_related_data() CASCADE;
DROP FUNCTION IF EXISTS user_last_login() CASCADE;
DROP FUNCTION IF EXISTS is_admin_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS log_auth_event() CASCADE;

-- 5. SUPPRIMER TOUTES LES VUES
DROP VIEW IF EXISTS recent_activity CASCADE;
DROP VIEW IF EXISTS popular_establishments CASCADE;
DROP VIEW IF EXISTS staff_activity CASCADE;
DROP VIEW IF EXISTS order_statistics CASCADE;
DROP VIEW IF EXISTS qr_code_analytics CASCADE;

-- 6. SUPPRIMER TOUTES LES TABLES (dans l'ordre des dépendances)
DROP TABLE IF EXISTS staff_activity_logs CASCADE;
DROP TABLE IF EXISTS qr_scans CASCADE;
DROP TABLE IF EXISTS qr_codes CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS establishments CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS establishment_types CASCADE;

-- 7. SUPPRIMER LES TYPES CUSTOM
DROP TYPE IF EXISTS subscription_tier CASCADE;
DROP TYPE IF EXISTS subscription_type CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS staff_role CASCADE;

-- 8. VÉRIFICATION SIMPLE - La base devrait être vide
SELECT 'Vérification des tables restantes' as info;
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- 9. MESSAGE DE CONFIRMATION
DO $$
BEGIN
    RAISE NOTICE '🎉 NETTOYAGE TERMINÉ ! La base de données est maintenant vide.';
    RAISE NOTICE '📋 Prochaine étape : Exécuter schema1.sql pour recréer la structure.';
END $$;
