-- ==========================================
-- KULA QR - CORE FUNCTIONS
-- ==========================================
-- Fonctions utilitaires principales
-- Fait partie du module 01_core

-- ==========================================
-- AUTHENTICATION FUNCTIONS
-- ==========================================

-- Admin user check function
CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Vérification rapide pour éviter des requêtes inutiles
    IF user_uuid IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = user_uuid AND role = 'admin'
    );
END;
$$;

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generate establishment slug function
CREATE OR REPLACE FUNCTION generate_establishment_slug()
RETURNS TRIGGER AS $$
DECLARE
    base_slug TEXT;
    new_slug TEXT;
    counter INTEGER := 1;
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        base_slug := LOWER(REGEXP_REPLACE(NEW.name, '[^\w\s-]', '', 'g'));
        base_slug := REGEXP_REPLACE(base_slug, '\s+', '-', 'g');
        new_slug := base_slug;

        WHILE EXISTS (SELECT 1 FROM establishments WHERE slug = new_slug AND id != NEW.id) LOOP
            new_slug := base_slug || '-' || counter;
            counter := counter + 1;
        END LOOP;

        NEW.slug := new_slug;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update product count function
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

-- Update table status on order function
CREATE OR REPLACE FUNCTION update_table_status_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.table_id IS NOT NULL THEN
        UPDATE tables
        SET status = 'occupied'
        WHERE id = NEW.table_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND NEW.table_id IS NOT NULL THEN
        UPDATE tables
        SET status = 'available'
        WHERE id = NEW.table_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- STAFF MANAGEMENT FUNCTIONS
-- ==========================================

-- Generate random PIN function
CREATE OR REPLACE FUNCTION generate_random_pin()
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
BEGIN
  -- Generate random number between 1000 and 9999
  new_pin := LPAD(FLOOR(RANDOM() * 9000 + 1000)::TEXT, 4, '0');
  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- Create staff with PIN function
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
  -- Validate role
  IF p_role NOT IN ('waiter', 'kitchen', 'staff', 'manager') THEN
    RAISE EXCEPTION 'Invalid role. Allowed values are: waiter, kitchen, staff, manager';
  END IF;

  -- Generate unique PIN for this establishment
  LOOP
    new_pin := generate_random_pin();

    -- Check if PIN already exists for this establishment
    SELECT EXISTS (
      SELECT 1 FROM staff
      WHERE establishment_id = p_establishment_id AND pin = new_pin
    ) INTO pin_exists;

    EXIT WHEN NOT pin_exists;
  END LOOP;

  -- Insert new staff member with PIN
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

  -- Return staff information
  RETURN jsonb_build_object(
    'id', new_id,
    'username', p_username,
    'pin', new_pin,
    'role', p_role
  );
END;
$$ LANGUAGE plpgsql;

-- Regenerate staff PIN function
CREATE OR REPLACE FUNCTION regenerate_staff_pin(
  p_staff_id UUID
)
RETURNS VARCHAR(4) AS $$
DECLARE
  new_pin VARCHAR(4);
  pin_exists BOOLEAN;
  v_establishment_id UUID;
BEGIN
  -- Get establishment_id
  SELECT establishment_id INTO v_establishment_id
  FROM staff
  WHERE id = p_staff_id;

  -- Generate new unique PIN
  LOOP
    new_pin := generate_random_pin();

    -- Check if PIN already exists for this establishment
    SELECT EXISTS (
      SELECT 1 FROM staff
      WHERE establishment_id = v_establishment_id AND pin = new_pin
    ) INTO pin_exists;

    EXIT WHEN NOT pin_exists;
  END LOOP;

  -- Update PIN
  UPDATE staff
  SET pin = new_pin,
      updated_at = NOW()
  WHERE id = p_staff_id;

  RETURN new_pin;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- SAMPLE DATA FUNCTIONS
-- ==========================================

-- Generate sample orders function
CREATE OR REPLACE FUNCTION generate_sample_orders(establishment_id UUID, num_orders INTEGER DEFAULT 10)
RETURNS VOID AS $$
DECLARE
    product_record RECORD;
    order_id UUID;
    product_count INTEGER;
    random_table INTEGER;
    random_status TEXT;
    statuses TEXT[] := ARRAY['pending', 'processing', 'ready', 'completed'];
BEGIN
    -- Get count of products for this establishment
    SELECT COUNT(*) INTO product_count
    FROM products
    WHERE establishment_id = generate_sample_orders.establishment_id;

    -- Only proceed if there are products
    IF product_count > 0 THEN
        -- Create sample orders
        FOR i IN 1..num_orders LOOP
            -- Random table number between 1 and 20
            random_table := floor(random() * 20) + 1;

            -- Random status
            random_status := statuses[floor(random() * 4) + 1];

            -- Insert order
            INSERT INTO orders (establishment_id, table_number, status, created_at)
            VALUES (
                generate_sample_orders.establishment_id,
                random_table,
                random_status,
                NOW() - (random() * INTERVAL '24 hours')
            )
            RETURNING id INTO order_id;

            -- Add 1-5 random products to this order
            FOR j IN 1..floor(random() * 5) + 1 LOOP
                -- Get a random product
                SELECT * INTO product_record
                FROM products
                WHERE establishment_id = generate_sample_orders.establishment_id
                ORDER BY RANDOM()
                LIMIT 1;

                -- Add product to order
                IF product_record.id IS NOT NULL THEN
                    INSERT INTO order_items (
                        order_id,
                        product_id,
                        quantity,
                        unit_price,
                        subtotal
                    )
                    VALUES (
                        order_id,
                        product_record.id,
                        floor(random() * 3) + 1,  -- Quantity 1-3
                        product_record.price,
                        (floor(random() * 3) + 1) * product_record.price  -- quantity * price
                    );

                    -- Update order total
                    UPDATE orders
                    SET total_amount = total_amount + ((floor(random() * 3) + 1) * product_record.price)
                    WHERE id = order_id;

                    -- Update product orders_count
                    UPDATE products
                    SET orders_count = orders_count + 1
                    WHERE id = product_record.id;
                END IF;
            END LOOP;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- QR CODE FUNCTIONS
-- ==========================================

-- Insert QR scan fallback function
CREATE OR REPLACE FUNCTION insert_qr_scan(est_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  INSERT INTO qr_scans (
    establishment_id,
    user_agent,
    created_at,
    ip_address,
    referrer
  ) VALUES (
    est_id,
    'rpc-fallback',
    NOW(),
    '0.0.0.0',
    'rpc-fallback'
  );

  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get table columns function
CREATE OR REPLACE FUNCTION get_table_columns(table_name TEXT)
RETURNS JSONB AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(jsonb_build_object(
      'column_name', column_name,
      'data_type', data_type,
      'is_nullable', is_nullable
    ))
    FROM information_schema.columns
    WHERE table_name = $1
  );
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ CORE FUNCTIONS CREATED SUCCESSFULLY!';
    RAISE NOTICE '🛠️ Total functions created: %', (SELECT COUNT(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public'));
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/01_core/functions.sql