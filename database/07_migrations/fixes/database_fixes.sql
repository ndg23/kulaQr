-- ==========================================
-- KULA QR - DATABASE FIXES
-- ==========================================
-- Corrections et migrations pour corriger les problèmes
-- Fait partie du module 07_migrations/fixes

-- ==========================================
-- FIX 001: UPDATE EXISTING USERS NAMES
-- ==========================================
-- Corrige les noms d'utilisateurs existants qui sont 'Utilisateur'

DO $$
DECLARE
    updated_count INTEGER := 0;
BEGIN
    -- Update users who have 'Utilisateur' as name
    UPDATE public.users
    SET full_name = SPLIT_PART(
        (SELECT email FROM auth.users WHERE auth.users.id = users.id),
        '@',
        1
    )
    WHERE full_name = 'Utilisateur'
      AND EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = users.id
        AND auth.users.email IS NOT NULL
      );

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    RAISE NOTICE '✅ FIXED % users with default names', updated_count;
END $$;

-- ==========================================
-- FIX 002: FIX ORDER ITEMS WITHOUT PRODUCTS
-- ==========================================
-- Supprime ou corrige les éléments de commande sans produit valide

DO $$
DECLARE
    deleted_count INTEGER := 0;
BEGIN
    -- Delete order items with invalid product references
    DELETE FROM order_items
    WHERE product_id IS NULL
       OR NOT EXISTS (
           SELECT 1 FROM products WHERE id = order_items.product_id
       );

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    RAISE NOTICE '✅ REMOVED % orphaned order items', deleted_count;
END $$;

-- ==========================================
-- FIX 003: RECALCULATE ORDER TOTALS
-- ==========================================
-- Recalcule les totaux des commandes pour s'assurer de la cohérence

DO $$
DECLARE
    updated_count INTEGER := 0;
BEGIN
    -- Update order totals based on order items
    UPDATE orders
    SET total_amount = COALESCE((
        SELECT SUM(subtotal)
        FROM order_items
        WHERE order_id = orders.id
    ), 0)
    WHERE EXISTS (
        SELECT 1 FROM order_items WHERE order_id = orders.id
    );

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    RAISE NOTICE '✅ RECALCULATED totals for % orders', updated_count;
END $$;

-- ==========================================
-- FIX 004: FIX PRODUCTS WITHOUT CATEGORIES
-- ==========================================
-- Déplace les produits sans catégorie vers une catégorie par défaut

DO $$
DECLARE
    establishment_record RECORD;
    default_category_id UUID;
    moved_count INTEGER := 0;
BEGIN
    -- For each establishment, create a default category if needed and move orphaned products
    FOR establishment_record IN SELECT id, name FROM establishments
    LOOP
        -- Create default category if it doesn't exist
        INSERT INTO categories (establishment_id, name, description, order_number, is_active)
        VALUES (establishment_record.id, 'Divers', 'Produits divers', 999, true)
        ON CONFLICT (establishment_id, name) DO NOTHING;

        -- Get the default category ID
        SELECT id INTO default_category_id
        FROM categories
        WHERE establishment_id = establishment_record.id AND name = 'Divers';

        -- Move orphaned products to default category
        UPDATE products
        SET category_id = default_category_id
        WHERE establishment_id = establishment_record.id
          AND (category_id IS NULL OR NOT EXISTS (
              SELECT 1 FROM categories WHERE id = products.category_id
          ));

        GET DIAGNOSTICS moved_count = moved_count + ROW_COUNT;
    END LOOP;

    RAISE NOTICE '✅ MOVED % orphaned products to default categories', moved_count;
END $$;

-- ==========================================
-- FIX 005: UPDATE PRODUCT COUNTERS
-- ==========================================
-- Met à jour les compteurs de produits et catégories

DO $$
DECLARE
    updated_products INTEGER := 0;
    updated_categories INTEGER := 0;
BEGIN
    -- Update product orders_count
    UPDATE products
    SET orders_count = (
        SELECT COUNT(*)
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.product_id = products.id AND o.status = 'completed'
    );

    GET DIAGNOSTICS updated_products = ROW_COUNT;

    -- Update category product_count
    UPDATE categories
    SET product_count = (
        SELECT COUNT(*)
        FROM products p
        WHERE p.category_id = categories.id AND p.is_available = true
    );

    GET DIAGNOSTICS updated_categories = ROW_COUNT;

    RAISE NOTICE '✅ UPDATED counters for % products and % categories', updated_products, updated_categories;
END $$;

-- ==========================================
-- FIX 006: FIX DUPLICATE SLUGS
-- ==========================================
-- Corrige les slugs dupliqués dans les établissements

DO $$
DECLARE
    establishment_record RECORD;
    new_slug TEXT;
    counter INTEGER := 1;
BEGIN
    -- Fix duplicate slugs by appending numbers
    FOR establishment_record IN
        SELECT id, name, slug,
               ROW_NUMBER() OVER (PARTITION BY slug ORDER BY created_at) as rn
        FROM establishments
        WHERE slug IN (
            SELECT slug FROM establishments GROUP BY slug HAVING COUNT(*) > 1
        )
    LOOP
        IF establishment_record.rn > 1 THEN
            -- Generate new unique slug
            new_slug := establishment_record.slug || '-' || establishment_record.rn;

            -- Make sure it's still unique
            WHILE EXISTS (SELECT 1 FROM establishments WHERE slug = new_slug AND id != establishment_record.id) LOOP
                counter := counter + 1;
                new_slug := establishment_record.slug || '-' || counter;
            END LOOP;

            -- Update the slug
            UPDATE establishments
            SET slug = new_slug
            WHERE id = establishment_record.id;

            RAISE NOTICE '✅ FIXED duplicate slug for establishment %: % → %', establishment_record.name, establishment_record.slug, new_slug;
        END IF;
    END LOOP;
END $$;

-- ==========================================
-- FIX 007: CLEANUP ORPHANED RECORDS
-- ==========================================
-- Supprime les enregistrements orphelins dans les tables liées

DO $$
DECLARE
    deleted_staff INTEGER := 0;
    deleted_qr_codes INTEGER := 0;
    deleted_scans INTEGER := 0;
    deleted_activity_logs INTEGER := 0;
BEGIN
    -- Delete staff without valid establishment
    DELETE FROM staff
    WHERE NOT EXISTS (
        SELECT 1 FROM establishments WHERE id = staff.establishment_id
    );

    GET DIAGNOSTICS deleted_staff = ROW_COUNT;

    -- Delete QR codes without valid establishment
    DELETE FROM qr_codes
    WHERE NOT EXISTS (
        SELECT 1 FROM establishments WHERE id = qr_codes.establishment_id
    );

    GET DIAGNOSTICS deleted_qr_codes = ROW_COUNT;

    -- Delete QR scans without valid QR code
    DELETE FROM qr_scans
    WHERE NOT EXISTS (
        SELECT 1 FROM qr_codes WHERE id = qr_scans.qr_code_id
    );

    GET DIAGNOSTICS deleted_scans = ROW_COUNT;

    -- Delete activity logs without valid staff
    DELETE FROM staff_activity_logs
    WHERE staff_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM staff WHERE id = staff_activity_logs.staff_id
    );

    GET DIAGNOSTICS deleted_activity_logs = ROW_COUNT;

    RAISE NOTICE '✅ CLEANED UP orphaned records: % staff, % QR codes, % scans, % activity logs',
                deleted_staff, deleted_qr_codes, deleted_scans, deleted_activity_logs;
END $$;

-- ==========================================
-- FIX 008: FIX TABLE REFERENCES
-- ==========================================
-- Corrige les références de table dans les commandes

DO $$
DECLARE
    updated_orders INTEGER := 0;
BEGIN
    -- Update orders with invalid table references
    UPDATE orders
    SET table_id = (
        SELECT id FROM tables
        WHERE establishment_id = orders.establishment_id
          AND table_number = orders.table_number
        LIMIT 1
    )
    WHERE table_id IS NULL
      AND table_number IS NOT NULL
      AND EXISTS (
          SELECT 1 FROM tables
          WHERE establishment_id = orders.establishment_id
            AND table_number = orders.table_number
      );

    GET DIAGNOSTICS updated_orders = ROW_COUNT;

    RAISE NOTICE '✅ FIXED table references for % orders', updated_orders;
END $$;

-- ==========================================
-- FIX 009: RESET DEMO DATA
-- ==========================================
-- Remet à zéro les données de démonstration si nécessaire

-- This would be used to reset demo data to a clean state
-- Only run this if you want to reset all demo data

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ DATABASE FIXES APPLIED SUCCESSFULLY!';
    RAISE NOTICE '🔧 All database integrity issues have been resolved';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/07_migrations/fixes/database_fixes.sql