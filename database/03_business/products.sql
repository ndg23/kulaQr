-- ==========================================
-- KULA QR - PRODUCTS MANAGEMENT
-- ==========================================
-- Gestion des produits et catégories
-- Fait partie du module 03_business

-- ==========================================
-- CATEGORIES MANAGEMENT
-- ==========================================

-- Categories table (already created in core, but business logic here)
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    order_number INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    product_count INTEGER DEFAULT 0,
    UNIQUE(establishment_id, name)
);

-- ==========================================
-- PRODUCTS MANAGEMENT
-- ==========================================

-- Products table (already created in core, but business logic here)
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    order_number INTEGER NOT NULL DEFAULT 0,
    orders_count INTEGER DEFAULT 0,
    allergens TEXT[],
    UNIQUE(category_id, name)
);

-- ==========================================
-- PRODUCT FUNCTIONS
-- ==========================================

-- Get products by category function
CREATE OR REPLACE FUNCTION get_products_by_category(p_category_id UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    price DECIMAL(10,2),
    image_url TEXT,
    is_available BOOLEAN,
    order_number INTEGER,
    allergens TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.is_available,
        p.order_number,
        p.allergens
    FROM products p
    WHERE p.category_id = p_category_id AND p.is_available = true
    ORDER BY p.order_number, p.name;
END;
$$ LANGUAGE plpgsql;

-- Get all products by establishment function
CREATE OR REPLACE FUNCTION get_establishment_products(p_establishment_id UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    price DECIMAL(10,2),
    image_url TEXT,
    is_available BOOLEAN,
    category_name TEXT,
    category_id UUID,
    order_number INTEGER,
    allergens TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.is_available,
        c.name as category_name,
        c.id as category_id,
        p.order_number,
        p.allergens
    FROM products p
    JOIN categories c ON p.category_id = c.id
    WHERE p.establishment_id = p_establishment_id AND c.is_active = true
    ORDER BY c.order_number, c.name, p.order_number, p.name;
END;
$$ LANGUAGE plpgsql;

-- Get categories by establishment function
CREATE OR REPLACE FUNCTION get_establishment_categories(p_establishment_id UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    image_url TEXT,
    order_number INTEGER,
    product_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.name,
        c.description,
        c.image_url,
        c.order_number,
        COUNT(p.id) as product_count
    FROM categories c
    LEFT JOIN products p ON c.id = p.category_id AND p.is_available = true
    WHERE c.establishment_id = p_establishment_id AND c.is_active = true
    GROUP BY c.id, c.name, c.description, c.image_url, c.order_number
    ORDER BY c.order_number, c.name;
END;
$$ LANGUAGE plpgsql;

-- Update product availability function
CREATE OR REPLACE FUNCTION update_product_availability(p_product_id UUID, p_available BOOLEAN)
RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET is_available = p_available, updated_at = NOW()
    WHERE id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Bulk update product prices function
CREATE OR REPLACE FUNCTION bulk_update_prices(p_establishment_id UUID, p_percentage DECIMAL)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE products
    SET price = price * (1 + p_percentage / 100),
        updated_at = NOW()
    WHERE establishment_id = p_establishment_id;

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- CATEGORY FUNCTIONS
-- ==========================================

-- Reorder categories function
CREATE OR REPLACE FUNCTION reorder_categories(p_establishment_id UUID, p_category_orders JSONB)
RETURNS VOID AS $$
DECLARE
    category_record RECORD;
BEGIN
    FOR category_record IN SELECT * FROM jsonb_object_keys(p_category_orders) AS category_id
    LOOP
        UPDATE categories
        SET order_number = (p_category_orders->>category_record.category_id)::INTEGER,
            updated_at = NOW()
        WHERE id = category_record.category_id::UUID
          AND establishment_id = p_establishment_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Reorder products function
CREATE OR REPLACE FUNCTION reorder_products(p_category_id UUID, p_product_orders JSONB)
RETURNS VOID AS $$
DECLARE
    product_record RECORD;
BEGIN
    FOR product_record IN SELECT * FROM jsonb_object_keys(p_product_orders) AS product_id
    LOOP
        UPDATE products
        SET order_number = (p_product_orders->>product_record.product_id)::INTEGER,
            updated_at = NOW()
        WHERE id = product_record.product_id::UUID
          AND category_id = p_category_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- SEARCH FUNCTIONS
-- ==========================================

-- Search products function
CREATE OR REPLACE FUNCTION search_products(p_establishment_id UUID, p_query TEXT)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    price DECIMAL(10,2),
    image_url TEXT,
    category_name TEXT,
    is_available BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        c.name as category_name,
        p.is_available
    FROM products p
    JOIN categories c ON p.category_id = c.id
    WHERE p.establishment_id = p_establishment_id
      AND c.is_active = true
      AND p.is_available = true
      AND (LOWER(p.name) LIKE LOWER('%' || p_query || '%')
           OR LOWER(p.description) LIKE LOWER('%' || p_query || '%')
           OR LOWER(c.name) LIKE LOWER('%' || p_query || '%'))
    ORDER BY p.name;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ PRODUCTS MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '🍽️ Product and category management functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/03_business/products.sql