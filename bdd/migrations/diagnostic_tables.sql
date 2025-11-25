-- ============================================
-- DIAGNOSTIC : Vérifier la structure des tables
-- ============================================

-- 1. Vérifier la structure de subscription_blocks_log
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'subscription_blocks_log'
ORDER BY ordinal_position;

-- 2. Vérifier si la table existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'subscription_blocks_log'
) as table_exists;

-- 3. Compter les lignes dans la table (si elle existe)
SELECT COUNT(*) as row_count 
FROM subscription_blocks_log;