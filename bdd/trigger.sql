-- Trigger pour mettre à jour le nombre de produits dans une catégorie
CREATE OR REPLACE FUNCTION update_category_product_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE categories 
    SET product_count = product_count + 1
    WHERE id = NEW.category_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE categories 
    SET product_count = product_count - 1
    WHERE id = OLD.category_id;
  ELSIF TG_OP = 'UPDATE' AND NEW.category_id != OLD.category_id THEN
    UPDATE categories 
    SET product_count = product_count - 1
    WHERE id = OLD.category_id;
    UPDATE categories 
    SET product_count = product_count + 1
    WHERE id = NEW.category_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_count_trigger
AFTER INSERT OR DELETE OR UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_category_product_count();

-- Trigger pour vérifier les limites d'abonnement
CREATE OR REPLACE FUNCTION check_subscription_limits()
RETURNS TRIGGER AS $$
DECLARE
  establishment_record establishments%ROWTYPE;
  current_count INTEGER;
BEGIN
  -- Récupérer l'établissement
  IF TG_TABLE_NAME = 'products' THEN
    SELECT e.* INTO establishment_record
    FROM establishments e
    JOIN categories c ON c.establishment_id = e.id
    WHERE c.id = NEW.category_id;
    
    SELECT COUNT(*) INTO current_count
    FROM products p
    JOIN categories c ON c.id = p.category_id
    WHERE c.establishment_id = establishment_record.id;
    
    IF current_count >= establishment_record.max_products THEN
      RAISE EXCEPTION 'Limite de produits atteinte pour votre abonnement';
    END IF;
  ELSIF TG_TABLE_NAME = 'categories' THEN
    SELECT * INTO establishment_record
    FROM establishments
    WHERE id = NEW.establishment_id;
    
    SELECT COUNT(*) INTO current_count
    FROM categories
    WHERE establishment_id = NEW.establishment_id;
    
    IF current_count >= establishment_record.max_categories THEN
      RAISE EXCEPTION 'Limite de catégories atteinte pour votre abonnement';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_product_limits
BEFORE INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION check_subscription_limits();

CREATE TRIGGER check_category_limits
BEFORE INSERT ON categories
FOR EACH ROW
EXECUTE FUNCTION check_subscription_limits();

-- Trigger pour générer automatiquement le slug d'établissement
CREATE OR REPLACE FUNCTION generate_establishment_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL THEN
    NEW.slug := LOWER(REGEXP_REPLACE(NEW.name, '[^a-zA-Z0-9]', '-', 'g'));
    -- Ajouter un suffixe unique si nécessaire
    WHILE EXISTS (SELECT 1 FROM establishments WHERE slug = NEW.slug AND id != NEW.id) LOOP
      NEW.slug := NEW.slug || '-' || FLOOR(RANDOM() * 1000)::TEXT;
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER establishment_slug_trigger
BEFORE INSERT OR UPDATE ON establishments
FOR EACH ROW
EXECUTE FUNCTION generate_establishment_slug();

-- Trigger pour mettre à jour la date de dernière connexion
CREATE OR REPLACE FUNCTION update_last_login()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE restaurant_users
  SET last_login = NOW()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_last_login_trigger
AFTER INSERT OR UPDATE ON auth.users
FOR EACH ROW
EXECUTE FUNCTION update_last_login();

-- Trigger pour vérifier la validité de l'abonnement
CREATE OR REPLACE FUNCTION check_subscription_validity()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.subscription_ends_at < NOW() THEN
    NEW.subscription_tier := 'free';
    -- Mettre à jour les limites de l'établissement
    UPDATE establishments
    SET subscription_type = 'basic',
        max_categories = 5,
        max_products = 20,
        analytics_enabled = FALSE
    WHERE user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER subscription_validity_trigger
BEFORE UPDATE ON restaurant_users
FOR EACH ROW
EXECUTE FUNCTION check_subscription_validity();

-- Trigger pour maintenir la cohérence des données lors de la suppression
CREATE OR REPLACE FUNCTION cleanup_related_data()
RETURNS TRIGGER AS $$
BEGIN
  -- Nettoyer les données liées à l'établissement
  IF TG_TABLE_NAME = 'establishments' THEN
    DELETE FROM qr_codes WHERE establishment_id = OLD.id;
    -- Autres nettoyages si nécessaire
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER establishment_cleanup_trigger
BEFORE DELETE ON establishments
FOR EACH ROW
EXECUTE FUNCTION cleanup_related_data();