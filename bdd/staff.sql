-- Table pour le personnel (avec ou sans PIN)
CREATE TABLE IF NOT EXISTS staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  username VARCHAR(100) NOT NULL,
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Optionnel pour les comptes complets
  pin VARCHAR(4), -- Optionnel pour les accès PIN
  role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('manager', 'staff', 'waiter', 'kitchen')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Contraintes
  UNIQUE (establishment_id, username),
  UNIQUE (establishment_id, pin) -- Uniquement pour les PIN non NULL
);

-- Fonction pour générer un PIN aléatoire à 4 chiffres
CREATE OR REPLACE FUNCTION generate_random_pin()
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
BEGIN
  -- Générer un nombre aléatoire entre 1000 et 9999
  new_pin := LPAD(FLOOR(RANDOM() * 9000 + 1000)::TEXT, 4, '0');
  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour créer un membre du personnel avec un username et un PIN
CREATE OR REPLACE FUNCTION create_staff_pin(
  p_username TEXT,
  p_establishment_id UUID,
  p_role TEXT DEFAULT 'staff'
)
RETURNS JSONB AS $$
DECLARE
  new_pin VARCHAR(4);
  pin_exists BOOLEAN;
  new_id UUID;
BEGIN
  -- Vérifier que le rôle est valide
  IF p_role NOT IN ('waiter', 'kitchen', 'staff', 'manager') THEN
    RAISE EXCEPTION 'Rôle invalide. Les valeurs autorisées sont: waiter, kitchen, staff, manager';
  END IF;

  -- Générer un PIN unique pour cet établissement
  LOOP
    new_pin := generate_random_pin();
    
    -- Vérifier si le PIN existe déjà pour cet établissement
    SELECT EXISTS (
      SELECT 1 FROM staff 
      WHERE establishment_id = p_establishment_id AND pin = new_pin
    ) INTO pin_exists;
    
    EXIT WHEN NOT pin_exists;
  END LOOP;
  
  -- Insérer le nouveau membre avec PIN
  INSERT INTO staff (
    username,
    establishment_id,
    pin,
    role,
    is_active
  ) VALUES (
    p_username,
    p_establishment_id,
    new_pin,
    p_role,
    true
  ) RETURNING id INTO new_id;
  
  -- Retourner les informations
  RETURN jsonb_build_object(
    'id', new_id,
    'username', p_username,
    'pin', new_pin,
    'role', p_role
  );
END;
$$ LANGUAGE plpgsql;

-- Fonction pour régénérer un PIN
CREATE OR REPLACE FUNCTION regenerate_staff_pin(
  p_staff_id UUID
)
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
  pin_exists BOOLEAN;
  v_establishment_id UUID;
BEGIN
  -- Récupérer l'establishment_id
  SELECT establishment_id INTO v_establishment_id
  FROM staff
  WHERE id = p_staff_id;
  
  -- Générer un nouveau PIN unique
  LOOP
    new_pin := generate_random_pin();
    
    -- Vérifier si le PIN existe déjà pour cet établissement
    SELECT EXISTS (
      SELECT 1 FROM staff 
      WHERE establishment_id = v_establishment_id AND pin = new_pin
    ) INTO pin_exists;
    
    EXIT WHEN NOT pin_exists;
  END LOOP;
  
  -- Mettre à jour le PIN
  UPDATE staff
  SET pin = new_pin,
      updated_at = NOW()
  WHERE id = p_staff_id;
  
  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- Politiques de base pour la sécurité
DROP POLICY IF EXISTS "Les propriétaires et managers peuvent gérer le personnel" ON staff;
CREATE POLICY "Les propriétaires et managers peuvent gérer le personnel"
  ON staff
  FOR ALL
  USING (
    auth.uid() IN (
      SELECT created_by FROM establishments 
      WHERE id = staff.establishment_id
    )
    OR
    auth.uid() IN (
      SELECT id FROM staff 
      WHERE establishment_id = staff.establishment_id 
      AND role = 'manager'
    )
  );

-- Création d'index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_staff_establishment ON staff(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_role ON staff(role);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);

-- Trigger pour mettre à jour le champ updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger à la table staff
CREATE TRIGGER update_staff_updated_at
BEFORE UPDATE ON staff
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();