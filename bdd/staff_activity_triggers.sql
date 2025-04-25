 -- Fonction pour suivre les modifications du personnel
 -- Fonction pour suivre les modifications du personnel

-- Table pour suivre les activités du personnel
CREATE TABLE IF NOT EXISTS staff_activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  details JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_staff_id ON staff_activity_logs(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_establishment_id ON staff_activity_logs(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_created_at ON staff_activity_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_staff_activity_logs_action ON staff_activity_logs(action);

-- Fonction pour enregistrer automatiquement l'establishment_id
CREATE OR REPLACE FUNCTION set_staff_activity_establishment_id()
RETURNS TRIGGER AS $$
BEGIN
  -- Si l'establishment_id n'est pas défini, le récupérer depuis la table staff
  IF NEW.establishment_id IS NULL THEN
    SELECT establishment_id INTO NEW.establishment_id
    FROM staff
    WHERE id = NEW.staff_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour définir automatiquement l'establishment_id
CREATE TRIGGER set_staff_activity_establishment_id_trigger
BEFORE INSERT ON staff_activity_logs
FOR EACH ROW
EXECUTE FUNCTION set_staff_activity_establishment_id(); 





CREATE OR REPLACE FUNCTION track_staff_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action TEXT;
BEGIN
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action := 'staff_created';
    v_details := jsonb_build_object(
      'username', NEW.username,
      'role', NEW.role,
      'is_active', NEW.is_active
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_action := 'staff_updated';
    v_details := jsonb_build_object();
    
    -- Capturer uniquement les champs qui ont changé
    IF NEW.username IS DISTINCT FROM OLD.username THEN
      v_details := v_details || jsonb_build_object('username', NEW.username, 'previous_username', OLD.username);
    END IF;
    
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      v_details := v_details || jsonb_build_object('role', NEW.role, 'previous_role', OLD.role);
    END IF;
    
    IF NEW.pin IS DISTINCT FROM OLD.pin THEN
      v_details := v_details || jsonb_build_object('pin_changed', TRUE);
    END IF;
    
    IF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
      v_details := v_details || jsonb_build_object('is_active', NEW.is_active, 'previous_is_active', OLD.is_active);
      
      -- Action spécifique pour l'activation/désactivation
      IF NEW.is_active = TRUE AND OLD.is_active = FALSE THEN
        v_action := 'staff_activated';
      ELSIF NEW.is_active = FALSE AND OLD.is_active = TRUE THEN
        v_action := 'staff_deactivated';
      END IF;
    END IF;
    
    -- Si aucun champ pertinent n'a changé, ne pas enregistrer d'activité
    IF v_details = '{}'::JSONB THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action := 'staff_deleted';
    v_details := jsonb_build_object(
      'username', OLD.username,
      'role', OLD.role
    );
  END IF;
  
  -- Enregistrer l'activité
  INSERT INTO staff_activity_logs (
    staff_id,
    establishment_id,
    action,
    details
  ) VALUES (
    CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
    CASE WHEN TG_OP = 'DELETE' THEN OLD.establishment_id ELSE NEW.establishment_id END,
    v_action,
    v_details
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour suivre les modifications du personnel
CREATE TRIGGER track_staff_changes
AFTER INSERT OR UPDATE OR DELETE ON staff
FOR EACH ROW EXECUTE FUNCTION track_staff_changes();

-- Fonction pour suivre les activités de commande du personnel
CREATE OR REPLACE FUNCTION track_staff_order_activity()
RETURNS TRIGGER AS $$
DECLARE
  v_details JSONB;
  v_action TEXT;
  v_staff_id UUID;
BEGIN
  -- Récupérer l'ID du staff qui a effectué l'action
  v_staff_id := NEW.updated_by;
  
  -- Si pas de staff_id, sortir
  IF v_staff_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Déterminer le type d'action
  IF TG_OP = 'INSERT' THEN
    v_action := 'order_created';
    v_details := jsonb_build_object(
      'order_id', NEW.id,
      'table_number', NEW.table_number,
      'total_amount', NEW.total_amount
    );
  ELSIF TG_OP = 'UPDATE' THEN
    v_details := jsonb_build_object(
      'order_id', NEW.id,
      'table_number', NEW.table_number
    );
    
    -- Déterminer l'action en fonction du changement de statut
    IF NEW.status IS DISTINCT FROM OLD.status THEN
      v_details := v_details || jsonb_build_object('status', NEW.status, 'previous_status', OLD.status);
      
      CASE NEW.status
        WHEN 'preparing' THEN v_action := 'order_sent_to_kitchen';
        WHEN 'ready' THEN v_action := 'order_marked_ready';
        WHEN 'delivered' THEN v_action := 'order_delivered';
        WHEN 'completed' THEN v_action := 'order_completed';
        WHEN 'cancelled' THEN v_action := 'order_cancelled';
        ELSE v_action := 'order_updated';
      END CASE;
    ELSE
      v_action := 'order_updated';
    END IF;
  END IF;
  
  -- Enregistrer l'activité
  INSERT INTO staff_activity_logs (
    staff_id,
    establishment_id,
    action,
    details
  ) VALUES (
    v_staff_id,
    NEW.establishment_id,
    v_action,
    v_details
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour suivre les activités de commande du personnel
CREATE TRIGGER track_staff_order_activity
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION track_staff_order_activity();

-- Fonction pour suivre les connexions et déconnexions du personnel
CREATE OR REPLACE FUNCTION log_staff_session_activity()
RETURNS TRIGGER AS $$
BEGIN
  -- Enregistrer l'activité de connexion
  INSERT INTO staff_activity_logs (
    staff_id,
    establishment_id,
    action,
    details,
    user_agent
  ) VALUES (
    NEW.staff_id,
    NEW.establishment_id,
    'login',
    jsonb_build_object(
      'method', 'pin',
      'success', TRUE
    ),
    NEW.user_agent
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Table pour stocker les sessions du personnel
CREATE TABLE IF NOT EXISTS staff_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  user_agent TEXT,
  ip_address INET,
  is_active BOOLEAN DEFAULT TRUE,
  last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger pour enregistrer les connexions du personnel
CREATE TRIGGER log_staff_session_activity
AFTER INSERT ON staff_sessions
FOR EACH ROW EXECUTE FUNCTION log_staff_session_activity();

-- Fonction pour mettre à jour la dernière activité d'une session
CREATE OR REPLACE FUNCTION update_staff_session_activity(
  p_staff_id UUID,
  p_action TEXT DEFAULT 'session_activity',
  p_details JSONB DEFAULT '{}'::JSONB
)
RETURNS VOID AS $$
BEGIN
  -- Mettre à jour la dernière activité de la session
  UPDATE staff_sessions
  SET last_activity = NOW()
  WHERE staff_id = p_staff_id AND is_active = TRUE;
  
  -- Enregistrer l'activité si nécessaire
  IF p_action != 'session_activity' THEN
    INSERT INTO staff_activity_logs (
      staff_id,
      action,
      details
    ) VALUES (
      p_staff_id,
      p_action,
      p_details
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour fermer une session et enregistrer la déconnexion
CREATE OR REPLACE FUNCTION close_staff_session(
  p_staff_id UUID,
  p_reason TEXT DEFAULT 'manual_logout'
)
RETURNS VOID AS $$
DECLARE
  v_establishment_id UUID;
BEGIN
  -- Récupérer l'establishment_id
  SELECT establishment_id INTO v_establishment_id
  FROM staff
  WHERE id = p_staff_id;
  
  -- Marquer la session comme inactive
  UPDATE staff_sessions
  SET is_active = FALSE
  WHERE staff_id = p_staff_id AND is_active = TRUE;
  
  -- Enregistrer l'activité de déconnexion
  INSERT INTO staff_activity_logs (
    staff_id,
    establishment_id,
    action,
    details
  ) VALUES (
    p_staff_id,
    v_establishment_id,
    'logout',
    jsonb_build_object(
      'reason', p_reason
    )
  );
END;
$$ LANGUAGE plpgsql;