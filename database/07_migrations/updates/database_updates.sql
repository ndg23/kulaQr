-- ==========================================
-- KULA QR - DATABASE UPDATES
-- ==========================================
-- Mises à jour et évolutions de la base de données
-- Fait partie du module 07_migrations/updates

-- ==========================================
-- UPDATE 001: ADD NEW FEATURES
-- ==========================================
-- Ajoute de nouvelles fonctionnalités à la base de données

-- Add new columns to establishments table
ALTER TABLE establishments
ADD COLUMN IF NOT EXISTS website_url TEXT,
ADD COLUMN IF NOT EXISTS social_media JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS business_hours JSONB DEFAULT '{}';

-- Add new columns to products table
ALTER TABLE products
ADD COLUMN IF NOT EXISTS preparation_time INTEGER, -- in minutes
ADD COLUMN IF NOT EXISTS spicy_level INTEGER CHECK (spicy_level >= 0 AND spicy_level <= 5),
ADD COLUMN IF NOT EXISTS is_vegetarian BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS is_vegan BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS nutritional_info JSONB DEFAULT '{}';

-- Add new columns to orders table
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS customer_name TEXT,
ADD COLUMN IF NOT EXISTS customer_phone TEXT,
ADD COLUMN IF NOT EXISTS special_instructions TEXT,
ADD COLUMN IF NOT EXISTS estimated_ready_time TIMESTAMP WITH TIME ZONE;

-- ==========================================
-- UPDATE 002: CREATE NEW TABLES
-- ==========================================

-- Create customer feedback table
CREATE TABLE IF NOT EXISTS customer_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    response TEXT,
    response_date TIMESTAMP WITH TIME ZONE,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create promotions table
CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount')),
    discount_value DECIMAL(10,2) NOT NULL,
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    applicable_to TEXT[] DEFAULT ARRAY['all'], -- 'all', 'categories', 'products'
    applicable_ids UUID[], -- category or product IDs
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    current_stock INTEGER NOT NULL DEFAULT 0,
    min_stock_level INTEGER DEFAULT 0,
    max_stock_level INTEGER,
    unit TEXT DEFAULT 'pieces',
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(establishment_id, product_id)
);

-- ==========================================
-- UPDATE 003: ADD NEW INDEXES
-- ==========================================
-- Améliore les performances avec de nouveaux index

CREATE INDEX IF NOT EXISTS idx_orders_establishment_created ON orders(establishment_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status_created ON orders(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_products_establishment_available ON products(establishment_id, is_available) WHERE is_available = true;
CREATE INDEX IF NOT EXISTS idx_products_category_order ON products(category_id, order_number);
CREATE INDEX IF NOT EXISTS idx_qr_scans_code_scanned ON qr_scans(qr_code_id, scanned_at DESC);
CREATE INDEX IF NOT EXISTS idx_staff_establishment_role ON staff(establishment_id, role);
CREATE INDEX IF NOT EXISTS idx_tables_establishment_status ON tables(establishment_id, status);

-- ==========================================
-- UPDATE 004: ADD NEW FUNCTIONS
-- ==========================================

-- Function to apply promotions
CREATE OR REPLACE FUNCTION apply_promotion(
    p_order_id UUID,
    p_promotion_id UUID
)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    v_promotion RECORD;
    v_order_total DECIMAL(10,2);
    v_discount DECIMAL(10,2) := 0;
    v_applicable_total DECIMAL(10,2) := 0;
BEGIN
    -- Get promotion details
    SELECT * INTO v_promotion FROM promotions WHERE id = p_promotion_id AND is_active = true;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Promotion not found or inactive';
    END IF;

    -- Check if promotion is still valid
    IF v_promotion.valid_until IS NOT NULL AND v_promotion.valid_until < NOW() THEN
        RAISE EXCEPTION 'Promotion has expired';
    END IF;

    IF v_promotion.valid_from IS NOT NULL AND v_promotion.valid_from > NOW() THEN
        RAISE EXCEPTION 'Promotion has not started yet';
    END IF;

    -- Check usage limit
    IF v_promotion.usage_limit IS NOT NULL AND v_promotion.usage_count >= v_promotion.usage_limit THEN
        RAISE EXCEPTION 'Promotion usage limit exceeded';
    END IF;

    -- Calculate applicable total
    SELECT SUM(oi.subtotal) INTO v_applicable_total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    WHERE oi.order_id = p_order_id
      AND (v_promotion.applicable_to = ARRAY['all']
           OR (v_promotion.applicable_to = ARRAY['categories'] AND p.category_id = ANY(v_promotion.applicable_ids))
           OR (v_promotion.applicable_to = ARRAY['products'] AND p.id = ANY(v_promotion.applicable_ids)));

    -- Calculate discount
    IF v_promotion.discount_type = 'percentage' THEN
        v_discount := v_applicable_total * (v_promotion.discount_value / 100);
    ELSE
        v_discount := LEAST(v_promotion.discount_value, v_applicable_total);
    END IF;

    -- Update promotion usage
    UPDATE promotions SET usage_count = usage_count + 1 WHERE id = p_promotion_id;

    RETURN v_discount;
END;
$$ LANGUAGE plpgsql;

-- Function to check product availability based on inventory
CREATE OR REPLACE FUNCTION check_inventory_availability(p_product_id UUID, p_quantity INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_stock INTEGER;
BEGIN
    SELECT current_stock INTO v_current_stock
    FROM inventory
    WHERE product_id = p_product_id;

    -- If no inventory record, assume unlimited stock
    IF v_current_stock IS NULL THEN
        RETURN TRUE;
    END IF;

    RETURN v_current_stock >= p_quantity;
END;
$$ LANGUAGE plpgsql;

-- Function to update inventory after order
CREATE OR REPLACE FUNCTION update_inventory_after_order(p_order_id UUID)
RETURNS VOID AS $$
DECLARE
    v_item RECORD;
BEGIN
    FOR v_item IN SELECT product_id, quantity FROM order_items WHERE order_id = p_order_id
    LOOP
        UPDATE inventory
        SET current_stock = GREATEST(0, current_stock - v_item.quantity),
            last_updated = NOW()
        WHERE product_id = v_item.product_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- UPDATE 005: UPDATE EXISTING DATA
-- ==========================================

-- Update existing establishments with default business hours
UPDATE establishments
SET business_hours = '{
  "monday": {"open": "09:00", "close": "18:00", "closed": false},
  "tuesday": {"open": "09:00", "close": "18:00", "closed": false},
  "wednesday": {"open": "09:00", "close": "18:00", "closed": false},
  "thursday": {"open": "09:00", "close": "18:00", "closed": false},
  "friday": {"open": "09:00", "close": "18:00", "closed": false},
  "saturday": {"open": "09:00", "close": "17:00", "closed": false},
  "sunday": {"open": "10:00", "close": "16:00", "closed": false}
}'::jsonb
WHERE business_hours = '{}'::jsonb OR business_hours IS NULL;

-- Update existing products with default values
UPDATE products
SET preparation_time = 15
WHERE preparation_time IS NULL;

UPDATE products
SET is_vegetarian = FALSE, is_vegan = FALSE
WHERE is_vegetarian IS NULL OR is_vegan IS NULL;

-- ==========================================
-- UPDATE 006: ADD NEW POLICIES
-- ==========================================

-- RLS policies for new tables
ALTER TABLE customer_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- Customer feedback policies
CREATE POLICY "Users can view feedback for their establishments" ON customer_feedback
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = customer_feedback.establishment_id
        ) OR is_admin_user()
    );

CREATE POLICY "Customers can insert feedback" ON customer_feedback
    FOR INSERT WITH CHECK (true);

-- Promotions policies
CREATE POLICY "Establishment owners can manage their promotions" ON promotions
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = promotions.establishment_id
        ) OR is_admin_user()
    );

-- Inventory policies
CREATE POLICY "Establishment staff can view inventory" ON inventory
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = inventory.establishment_id
        ) OR
        auth.uid() IN (
            SELECT id FROM staff WHERE establishment_id = inventory.establishment_id
        ) OR is_admin_user()
    );

CREATE POLICY "Establishment owners can manage inventory" ON inventory
    FOR ALL USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = inventory.establishment_id
        ) OR is_admin_user()
    );

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ DATABASE UPDATES APPLIED SUCCESSFULLY!';
    RAISE NOTICE '🚀 New features and improvements have been added';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/07_migrations/updates/database_updates.sql