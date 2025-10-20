-- ==========================================
-- KULA QR - USERS MANAGEMENT
-- ==========================================
-- Gestion des utilisateurs et authentification
-- Fait partie du module 02_auth

-- ==========================================
-- USERS TABLE
-- ==========================================

-- Users table (already created in core, but policies here)
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    full_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'owner',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    subscription_tier TEXT DEFAULT 'free',
    subscription_ends_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- AUTHENTICATION FUNCTIONS
-- ==========================================

-- Handle new user creation function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_full_name TEXT;
  v_email TEXT;
BEGIN
  -- Extract full name from metadata (priority: full_name, then name, then email)
  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    SPLIT_PART(NEW.email, '@', 1), -- Use part before @ from email
    'Utilisateur'
  );

  -- Extract email
  v_email := NEW.email;

  -- Insert user into public.users table
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
    'owner', -- Default role
    'free', -- Free tier by default
    true, -- Active by default
    NOW() + INTERVAL '7 days', -- 90 days free trial
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Handle user login tracking function
CREATE OR REPLACE FUNCTION public.handle_user_login()
RETURNS TRIGGER AS $$
BEGIN
  -- Update last_login only if it's a login event
  IF NEW.last_sign_in_at IS DISTINCT FROM OLD.last_sign_in_at THEN
    UPDATE public.users
    SET last_login = NEW.last_sign_in_at
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- USER MANAGEMENT FUNCTIONS
-- ==========================================

-- Update existing users names function
CREATE OR REPLACE FUNCTION update_existing_users_names()
RETURNS VOID AS $$
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

  -- Update users with empty or NULL names
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
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- ROW LEVEL SECURITY POLICIES
-- ==========================================

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow user registration" ON users
    FOR INSERT WITH CHECK (true);

-- Admin policies (override all others)
CREATE POLICY "Admins can manage everything - users" ON users
    FOR ALL USING (is_admin_user());

-- ==========================================
-- PERMISSIONS
-- ==========================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ USERS MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '👥 Users table and authentication functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/02_auth/users.sql