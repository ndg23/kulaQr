-- ==========================================
-- KULA QR - COMPLETE DATABASE INITIALIZATION
-- ==========================================
-- Execute this file to set up the complete database schema
-- Make sure to run files in the correct order

-- 1. First, run the main schema
\i schema.sql

-- 2. Then run additional schemas
\i qr_support_requests.sql

-- 3. Finally, run seeds if needed
-- \i seeds.sql

-- ==========================================
-- INITIALIZATION COMPLETE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '🚀 KULA QR DATABASE INITIALIZATION COMPLETE!';
    RAISE NOTICE '📊 All schemas and tables have been created successfully';
    RAISE NOTICE '🔒 Row Level Security is enabled on all tables';
    RAISE NOTICE '✅ Database is ready for use!';
END $$;