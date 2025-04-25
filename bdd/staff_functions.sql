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