-- Orders and related tables

-- Table for orders
-- CREATE TABLE IF NOT EXISTS orders (
--   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--   establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
--   user_id UUID REFERENCES users(id) ON DELETE SET NULL,
--   table_number INTEGER,
--   status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'
--   total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
--   payment_status VARCHAR(50) DEFAULT 'unpaid', -- 'unpaid', 'paid'
--   payment_method VARCHAR(50),
--   notes TEXT,
--   rating INTEGER CHECK (rating >= 1 AND rating <= 5),
--   rating_comment TEXT,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- -- Table for order items
-- CREATE TABLE IF NOT EXISTS order_items (
--   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--   order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
--   product_id UUID REFERENCES products(id) ON DELETE SET NULL,
--   quantity INTEGER NOT NULL DEFAULT 1,
--   unit_price DECIMAL(10, 2) NOT NULL,
--   notes TEXT,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- -- Indexes for better performance
-- CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
-- CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
-- CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
-- CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
-- CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Function to update order total amount
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders
  SET total_amount = (
    SELECT COALESCE(SUM(unit_price * quantity), 0)
    FROM order_items
    WHERE order_id = NEW.order_id
  )
  WHERE id = NEW.order_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update order total when items change
CREATE TRIGGER update_order_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

-- Function to log order activity
CREATE OR REPLACE FUNCTION log_order_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_user_activity(
      'create',
      'order',
      NEW.id,
      jsonb_build_object(
        'establishment_id', NEW.establishment_id,
        'total_amount', NEW.total_amount,
        'status', NEW.status
      )
    );
  ELSIF TG_OP = 'UPDATE' THEN
    -- Only log if important fields changed
    IF NEW.status != OLD.status OR NEW.payment_status != OLD.payment_status THEN
      PERFORM log_user_activity(
        'update',
        'order',
        NEW.id,
        jsonb_build_object(
          'establishment_id', NEW.establishment_id,
          'status', NEW.status,
          'payment_status', NEW.payment_status,
          'previous_status', OLD.status,
          'previous_payment_status', OLD.payment_status
        )
      );
    END IF;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for order activity logging
CREATE TRIGGER log_order_activity_trigger
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION log_order_activity();

-- Row level security for orders
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policies for orders
CREATE POLICY orders_select_policy ON orders
  FOR SELECT
  USING (
    user_id = auth.uid() OR
    establishment_id IN (
      SELECT id FROM establishments WHERE user_id = auth.uid()
    ) OR
    auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
  );

CREATE POLICY orders_insert_policy ON orders
  FOR INSERT
  WITH CHECK (true);  -- Anyone can create an order

CREATE POLICY orders_update_policy ON orders
  FOR UPDATE
  USING (
    user_id = auth.uid() OR
    establishment_id IN (
      SELECT id FROM establishments WHERE user_id = auth.uid()
    ) OR
    auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
  );

-- Policies for order items
CREATE POLICY order_items_select_policy ON order_items
  FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders WHERE 
        user_id = auth.uid() OR
        establishment_id IN (
          SELECT id FROM establishments WHERE user_id = auth.uid()
        ) OR
        auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
    )
  );

CREATE POLICY order_items_insert_policy ON order_items
  FOR INSERT
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders WHERE 
        user_id = auth.uid() OR
        establishment_id IN (
          SELECT id FROM establishments WHERE user_id = auth.uid()
        ) OR
        auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
    )
  );

CREATE POLICY order_items_update_policy ON order_items
  FOR UPDATE
  USING (
    order_id IN (
      SELECT id FROM orders WHERE 
        user_id = auth.uid() OR
        establishment_id IN (
          SELECT id FROM establishments WHERE user_id = auth.uid()
        ) OR
        auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
    )
  ); 