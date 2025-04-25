-- Create a simplified orders table for display purposes
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create a simplified order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add orders_count column to products table if it doesn't exist
ALTER TABLE products ADD COLUMN IF NOT EXISTS orders_count INTEGER DEFAULT 0;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_orders_establishment_id ON orders(establishment_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Create RLS policies for orders
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Establishments can view their own orders"
  ON orders FOR SELECT
  USING (establishment_id IN (
    SELECT id FROM establishments 
    WHERE user_id = auth.uid()
  ));

CREATE POLICY "Establishments can insert their own orders"
  ON orders FOR INSERT
  WITH CHECK (establishment_id IN (
    SELECT id FROM establishments 
    WHERE user_id = auth.uid()
  ));

-- Create RLS policies for order_items
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view order items for their establishments"
  ON order_items FOR SELECT
  USING (order_id IN (
    SELECT id FROM orders
    WHERE establishment_id IN (
      SELECT id FROM establishments
      WHERE user_id = auth.uid()
    )
  ));

-- Create a function to generate sample orders for display
CREATE OR REPLACE FUNCTION generate_sample_orders(establishment_id UUID, num_orders INTEGER DEFAULT 10)
RETURNS VOID AS $$
DECLARE
  product_record RECORD;
  order_id UUID;
  product_count INTEGER;
  random_table INTEGER;
  random_status TEXT;
  statuses TEXT[] := ARRAY['pending', 'preparing', 'completed'];
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
      random_status := statuses[floor(random() * 3) + 1];
      
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

-- Create a simple view for dashboard stats
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT
  establishment_id,
  COUNT(*) AS total_orders,
  SUM(total_amount) AS total_revenue,
  AVG(total_amount) AS avg_order_value,
  COUNT(DISTINCT table_number) AS tables_served,
  EXTRACT(HOUR FROM created_at) AS hour_of_day
FROM
  orders
WHERE
  created_at >= CURRENT_DATE
GROUP BY
  establishment_id,
  EXTRACT(HOUR FROM created_at); 