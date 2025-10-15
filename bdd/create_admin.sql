-- Script pour créer le premier administrateur
-- À exécuter directement dans Supabase SQL Editor

-- 1. Créer l'utilisateur dans auth.users (via Supabase Dashboard > Authentication > Users)
-- OU utiliser l'API admin pour créer l'utilisateur

-- 2. Insérer l'utilisateur dans la table users avec le rôle admin
INSERT INTO users (
  id,
  full_name,
  role,
  status,
  created_at,
  updated_at
) VALUES (
  'ee8e7274-4176-4a5e-82c9-7316f395d171', -- Remplacer par l'ID de l'utilisateur créé dans auth.users
  'Administrateur Principal',
  'admin',
  'active',
  NOW(),
  NOW()
);

-- 3. Vérifier que l'utilisateur a été créé
SELECT id, full_name, role, status FROM users WHERE role = 'admin';

-- 4. Optionnel : Créer un établissement de test pour l'admin
INSERT INTO establishments (
  id,
  name,
  email,
  phone,
  address,
  user_id,
  is_active,
  subscription_type,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Restaurant Admin',
  'admin@kulqr.com',
  '+221 77 749 39 10',
  'Dakar, Sénégal',
  'ee8e7274-4176-4a5e-82c9-7316f395d171', -- Même ID que ci-dessus
  true,
  'premium',
  NOW(),
  NOW()
);
