-- Migration rapide pour mettre à jour les utilisateurs existants
-- Exécuter ce script APRÈS avoir installé subscription_auto_block.sql

BEGIN;

-- 1. Mettre à jour les utilisateurs avec subscription_tier = 'free' vers 'demo'
UPDATE users
SET 
  subscription_tier = 'demo',
  subscription_ends_at = NOW() + INTERVAL '7 days',
  updated_at = NOW()
WHERE 
  subscription_tier = 'free'
  OR subscription_tier IS NULL;

-- 2. Afficher le résultat
DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO updated_count
  FROM users
  WHERE subscription_tier = 'demo';
  
  RAISE NOTICE '✅ % utilisateur(s) mis à jour avec subscription_tier = demo', updated_count;
END $$;

-- 3. Vérifier qu'aucun utilisateur n'a subscription_tier NULL
DO $$
DECLARE
  null_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO null_count
  FROM users
  WHERE subscription_tier IS NULL;
  
  IF null_count > 0 THEN
    RAISE WARNING '⚠️  % utilisateur(s) ont toujours subscription_tier NULL', null_count;
  ELSE
    RAISE NOTICE '✅ Tous les utilisateurs ont un subscription_tier défini';
  END IF;
END $$;

-- 4. Afficher les statistiques
SELECT 
  subscription_tier,
  COUNT(*) as nombre_utilisateurs,
  COUNT(*) FILTER (WHERE is_active = true) as actifs,
  COUNT(*) FILTER (WHERE is_active = false) as inactifs,
  COUNT(*) FILTER (WHERE subscription_ends_at < NOW()) as expires
FROM users
GROUP BY subscription_tier
ORDER BY subscription_tier;

COMMIT;

-- Afficher un message de confirmation
SELECT 
  '🎉 Migration terminée avec succès!' as message,
  NOW() as executed_at;
