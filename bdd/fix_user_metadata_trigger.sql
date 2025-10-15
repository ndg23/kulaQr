-- Script pour corriger le trigger d'authentification
-- pour mieux gérer les métadonnées utilisateur

-- Mettre à jour la fonction handle_new_user
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
  v_email := NEW.email;
  
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
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Vérifier que le trigger existe et le recréer si nécessaire
DO $$
BEGIN
  -- Supprimer le trigger s'il existe
  DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
  
  -- Recréer le trigger
  CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
    
  RAISE NOTICE 'Trigger on_auth_user_created mis à jour avec succès';
END $$;
