-- Fonction pour créer automatiquement un utilisateur dans la table users
-- lors de l'inscription via OAuth ou email/password
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_full_name TEXT;
  v_email TEXT;
BEGIN
  -- Extraire le nom complet des métadonnées (priorité: full_name, puis name, puis email)
  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    SPLIT_PART(NEW.email, '@', 1), -- Utiliser la partie avant @ de l'email
    'Utilisateur'
  );
  
  -- Extraire l'email
  
  -- Insérer l'utilisateur dans la table public.users
  INSERT INTO public.users (
    id,
    full_name,
    role,
    subscription_tier,
    is_active,
    subscription_ends_at,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    v_full_name,
    'owner', -- Rôle par défaut
    'free', -- Tier gratuit par défaut
    true, -- Actif par défaut
    NOW() + INTERVAL '90 days', -- 90 jours d'essai gratuit
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Éviter les erreurs si l'utilisateur existe déjà
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer le trigger s'il existe déjà
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Créer le trigger qui s'exécute après chaque insertion dans auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Fonction pour mettre à jour le last_login lors de la connexion
CREATE OR REPLACE FUNCTION public.handle_user_login()
RETURNS TRIGGER AS $$
BEGIN
  -- Mettre à jour last_login uniquement si c'est un événement de connexion
  IF NEW.last_sign_in_at IS DISTINCT FROM OLD.last_sign_in_at THEN
    UPDATE public.users
    SET last_login = NEW.last_sign_in_at
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer le trigger s'il existe déjà
DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;

-- Créer le trigger pour suivre les connexions
CREATE TRIGGER on_auth_user_login
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  WHEN (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
  EXECUTE FUNCTION public.handle_user_login();

-- Accorder les permissions nécessaires
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;