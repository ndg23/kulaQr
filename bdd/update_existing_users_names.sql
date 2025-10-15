-- Script pour mettre à jour les utilisateurs existants qui n'ont pas de nom
-- ou qui ont un nom générique

-- Mettre à jour les utilisateurs qui ont 'Utilisateur' comme nom
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

-- Mettre à jour les utilisateurs qui ont un nom vide ou NULL
UPDATE public.users 
SET full_name = COALESCE(
  (SELECT raw_user_meta_data->>'full_name' FROM auth.users WHERE auth.users.id = users.id),
  (SELECT raw_user_meta_data->>'name' FROM auth.users WHERE auth.users.id = users.id),
  SPLIT_PART(
    (SELECT email FROM auth.users WHERE auth.users.id = users.id), 
    '@', 
    1
  ),
  'Utilisateur'
)
WHERE full_name IS NULL 
   OR full_name = '' 
   OR full_name = 'Utilisateur';

-- Afficher le résultat
SELECT 
  u.id,
  u.full_name,
  au.email,
  au.raw_user_meta_data->>'full_name' as metadata_full_name,
  au.raw_user_meta_data->>'name' as metadata_name
FROM public.users u
JOIN auth.users au ON au.id = u.id
WHERE u.full_name IS NOT NULL
ORDER BY u.created_at DESC
LIMIT 10;
