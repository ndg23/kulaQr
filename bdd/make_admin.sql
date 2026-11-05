-- Promouvoir un compte existant en administrateur (par e-mail).
-- 1. Creez/connectez d'abord le compte: depuis le site (Google ou e-mail) ou Supabase >
--    Authentication > Users > Add user (vous choisissez l'e-mail et le mot de passe).
--    Le trigger on_auth_user_created cree alors la ligne public.users (role 'owner', inactive).
-- 2. Remplacez l'e-mail ndongmarvin26@gmail.com ci-dessous, puis lancez dans SQL Editor.
UPDATE public.users
SET role = 'admin', is_active = true, status = 'active', updated_at = NOW()
WHERE email = 'marvinndg242@gmail.com';

-- Controle: doit renvoyer 1 ligne avec role = admin
SELECT id, email, full_name, role, is_active, status FROM public.users WHERE role = 'admin';
