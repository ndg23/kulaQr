-- Table activities pour suivre les actions des utilisateurs
CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action_type VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'login', 'logout', etc.
  entity_type VARCHAR(50) NOT NULL, -- 'establishment', 'category', 'product', 'order', etc.
  entity_id UUID, -- ID de l'objet concerné
  details JSONB, -- Détails supplémentaires sur l'action
  ip_location VARCHAR(45), -- Pour suivre l'adresse IP (IPv4/IPv6)
  user_agent TEXT, -- Pour suivre le navigateur/appareil
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_action_type ON activities(action_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_type ON activities(entity_type);
CREATE INDEX IF NOT EXISTS idx_activities_entity_id ON activities(entity_id);
CREATE INDEX IF NOT EXISTS idx_activities_created_at ON activities(created_at);

-- Enable RLS on activities table
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Supprimer les politiques existantes si elles existent
DROP POLICY IF EXISTS "Users can view their own activities" ON activities;
DROP POLICY IF EXISTS "Admins can view all activities" ON activities;

-- Policy for activities - users can only see their own activities
CREATE POLICY "Users can view their own activities" 
ON activities FOR SELECT 
USING (auth.uid() = user_id);

-- Policy for activities - admins can see all activities
CREATE POLICY "Admins can view all activities" 
ON activities FOR SELECT 
USING (
  auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  )
);

-- Supprimer d'abord les anciennes fonctions
DROP FUNCTION IF EXISTS log_activity(uuid, varchar, varchar, uuid, jsonb, varchar, text);
DROP FUNCTION IF EXISTS log_user_activity(varchar, varchar, uuid, jsonb);

-- Recréer la fonction log_activity
CREATE OR REPLACE FUNCTION log_activity(
  p_user_id UUID,
  p_action_type VARCHAR(50),
  p_entity_type VARCHAR(50),
  p_entity_id UUID,
  p_details JSONB DEFAULT NULL,
  p_ip_location VARCHAR(45) DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_activity_id UUID;
BEGIN
  -- Vérifier que entity_type est valide
  IF p_entity_type NOT IN ('establishment', 'category', 'product', 'order', 'user', 'qr_code', 'staff') THEN
    RAISE EXCEPTION 'Type d''entité non valide';
  END IF;

  INSERT INTO activities (
    user_id,
    action_type,
    entity_type,
    entity_id,
    details,
    ip_location,
    user_agent
  ) VALUES (
    p_user_id,
    p_action_type,
    p_entity_type,
    p_entity_id,
    p_details,
    p_ip_location,
    p_user_agent
  ) RETURNING id INTO v_activity_id;
  
  RETURN v_activity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recréer la fonction log_user_activity
CREATE OR REPLACE FUNCTION log_user_activity(
  p_action_type VARCHAR(50),
  p_entity_type VARCHAR(50),
  p_entity_id UUID,
  p_details JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;
  
  RETURN log_activity(
    v_user_id,
    p_action_type,
    p_entity_type,
    p_entity_id,
    p_details,
    request.header('X-Forwarded-For'),
    request.header('User-Agent')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer les triggers existants avant de les recréer
DROP TRIGGER IF EXISTS track_user_changes ON users;
DROP TRIGGER IF EXISTS track_establishment_changes ON establishments;
DROP TRIGGER IF EXISTS track_category_changes ON categories;
DROP TRIGGER IF EXISTS track_product_changes ON products;

-- Fonction pour le trigger de suivi des modifications des utilisateurs
CREATE OR REPLACE FUNCTION track_user_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
BEGIN
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'full_name', NEW.full_name,
      'role', NEW.role,
      'subscription_tier', NEW.subscription_tier
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
      v_details := v_details || jsonb_build_object('full_name', NEW.full_name, 'previous_full_name', OLD.full_name);
    END IF;
    
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      v_details := v_details || jsonb_build_object('role', NEW.role, 'previous_role', OLD.role);
    END IF;
    
    IF NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier THEN
      v_details := v_details || jsonb_build_object('subscription_tier', NEW.subscription_tier, 'previous_subscription_tier', OLD.subscription_tier);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'full_name', OLD.full_name,
      'role', OLD.role
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END),
    v_action_type,
    'user',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des établissements
CREATE OR REPLACE FUNCTION track_establishment_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
BEGIN
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'slug', NEW.slug,
      'type_id', NEW.type_id,
      'subscription_type', NEW.subscription_type
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    IF NEW.subscription_type IS DISTINCT FROM OLD.subscription_type THEN
      v_details := v_details || jsonb_build_object('subscription_type', NEW.subscription_type, 'previous_subscription_type', OLD.subscription_type);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'slug', OLD.slug
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), NEW.created_by),
    v_action_type,
    'establishment',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des catégories
CREATE OR REPLACE FUNCTION track_category_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
  v_user_id UUID;
BEGIN
  -- Obtenir l'ID de l'utilisateur propriétaire de l'établissement
  SELECT created_by INTO v_user_id 
  FROM establishments 
  WHERE id = CASE WHEN TG_OP = 'DELETE' THEN OLD.establishment_id ELSE NEW.establishment_id END;

  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'establishment_id', NEW.establishment_id
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.order_number IS DISTINCT FROM OLD.order_number THEN
      v_details := v_details || jsonb_build_object('order_number', NEW.order_number, 'previous_order_number', OLD.order_number);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'establishment_id', OLD.establishment_id
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), v_user_id),
    v_action_type,
    'category',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour le trigger de suivi des modifications des produits
CREATE OR REPLACE FUNCTION track_product_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action_type VARCHAR(50);
  v_user_id UUID;
BEGIN
  -- Obtenir l'ID de l'utilisateur propriétaire de l'établissement
  SELECT e.created_by INTO v_user_id 
  FROM establishments e
  JOIN categories c ON c.establishment_id = e.id
  WHERE c.id = CASE WHEN TG_OP = 'DELETE' THEN OLD.category_id ELSE NEW.category_id END;

  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'create';
    v_details := jsonb_build_object(
      'name', NEW.name,
      'price', NEW.price,
      'category_id', NEW.category_id
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'update';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.name IS DISTINCT FROM OLD.name THEN
      v_details := v_details || jsonb_build_object('name', NEW.name, 'previous_name', OLD.name);
    END IF;
    
    IF NEW.description IS DISTINCT FROM OLD.description THEN
      v_details := v_details || jsonb_build_object('description', NEW.description, 'previous_description', OLD.description);
    END IF;
    
    IF NEW.price IS DISTINCT FROM OLD.price THEN
      v_details := v_details || jsonb_build_object('price', NEW.price, 'previous_price', OLD.price);
    END IF;
    
    IF NEW.image_url IS DISTINCT FROM OLD.image_url THEN
      v_details := v_details || jsonb_build_object('image_url', NEW.image_url, 'previous_image_url', OLD.image_url);
    END IF;
    
    IF NEW.is_available IS DISTINCT FROM OLD.is_available THEN
      v_details := v_details || jsonb_build_object('is_available', NEW.is_available, 'previous_is_available', OLD.is_available);
    END IF;
    
    IF NEW.category_id IS DISTINCT FROM OLD.category_id THEN
      v_details := v_details || jsonb_build_object('category_id', NEW.category_id, 'previous_category_id', OLD.category_id);
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'delete';
    v_details := jsonb_build_object(
      'name', OLD.name,
      'price', OLD.price,
      'category_id', OLD.category_id
    );
  END IF;
  
  -- Enregistrer l'activité
  PERFORM log_activity(
    COALESCE(auth.uid(), v_user_id),
    v_action_type,
    'product',
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    v_details,
    NULL,
    NULL
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer les triggers pour chaque table
CREATE TRIGGER track_user_changes
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION track_user_changes();

CREATE TRIGGER track_establishment_changes
AFTER INSERT OR UPDATE OR DELETE ON establishments
FOR EACH ROW EXECUTE FUNCTION track_establishment_changes();

CREATE TRIGGER track_category_changes
AFTER INSERT OR UPDATE OR DELETE ON categories
FOR EACH ROW EXECUTE FUNCTION track_category_changes();

CREATE TRIGGER track_product_changes
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION track_product_changes();

-- Vue pour les activités récentes par établissement
CREATE OR REPLACE VIEW establishment_activities AS
SELECT 
  e.id AS establishment_id,
  e.name AS establishment_name,
  a.action_type,
  a.entity_type,
  a.details,
  a.created_at,
  u.full_name AS user_name
FROM 
  activities a
JOIN 
  users u ON a.user_id = u.id
JOIN 
  establishments e ON 
    (a.entity_type = 'establishment' AND a.entity_id = e.id) OR
    (a.entity_type = 'category' AND a.entity_id IN (SELECT id FROM categories WHERE establishment_id = e.id)) OR
    (a.entity_type = 'product' AND a.entity_id IN (
      SELECT p.id FROM products p 
      JOIN categories c ON p.category_id = c.id 
      WHERE c.establishment_id = e.id
    ))
ORDER BY 
  a.created_at DESC;