-- ==========================================
-- KULA QR - ORDERS MANAGEMENT
-- ==========================================
-- Gestion des commandes et éléments de commande
-- Fait partie du module 03_business

-- ==========================================
-- ORDERS MANAGEMENT
-- ==========================================

-- Orders table (already created in core, but business logic here)
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_id UUID REFERENCES tables(id),
    table_number INTEGER,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'completed', 'cancelled')),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(50) DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    rating_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table (already created in core, but business logic here)
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- ORDER FUNCTIONS
-- ==========================================

-- Create order function
CREATE OR REPLACE FUNCTION create_order(
    p_establishment_id UUID,
    p_table_number INTEGER,
    p_items JSONB,
    p_notes TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id UUID;
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
    v_total DECIMAL(10,2) := 0;
BEGIN
    -- Create the order
    INSERT INTO orders (
        establishment_id,
        table_number,
        status,
        notes,
        total_amount
    ) VALUES (
        p_establishment_id,
        p_table_number,
        'pending',
        p_notes,
        0
    ) RETURNING id INTO v_order_id;

    -- Add order items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INTEGER;

        -- Get product price
        SELECT price INTO v_unit_price
        FROM products
        WHERE id = v_product_id;

        IF v_unit_price IS NOT NULL THEN
            -- Insert order item
            INSERT INTO order_items (
                order_id,
                product_id,
                quantity,
                unit_price,
                subtotal,
                notes
            ) VALUES (
                v_order_id,
                v_product_id,
                v_quantity,
                v_unit_price,
                v_quantity * v_unit_price,
                v_item->>'notes'
            );

            -- Update total
            v_total := v_total + (v_quantity * v_unit_price);

            -- Update product orders_count
            UPDATE products
            SET orders_count = orders_count + 1
            WHERE id = v_product_id;
        END IF;
    END LOOP;

    -- Update order total
    UPDATE orders
    SET total_amount = v_total
    WHERE id = v_order_id;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- Update order status function
CREATE OR REPLACE FUNCTION update_order_status(p_order_id UUID, p_status VARCHAR(50))
RETURNS VOID AS $$
DECLARE
    v_old_status VARCHAR(50);
BEGIN
    -- Validate status
    IF p_status NOT IN ('pending', 'processing', 'ready', 'completed', 'cancelled') THEN
        RAISE EXCEPTION 'Invalid order status: %', p_status;
    END IF;

    -- Get current status
    SELECT status INTO v_old_status
    FROM orders
    WHERE id = p_order_id;

    -- Update status
    UPDATE orders
    SET status = p_status, updated_at = NOW()
    WHERE id = p_order_id;

    -- Log status change if needed
    -- (Could add activity logging here)
END;
$$ LANGUAGE plpgsql;

-- Get order details function
CREATE OR REPLACE FUNCTION get_order_details(p_order_id UUID)
RETURNS TABLE (
    order_id UUID,
    establishment_name TEXT,
    table_number INTEGER,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE,
    item_count BIGINT,
    items JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id as order_id,
        e.name as establishment_name,
        o.table_number,
        o.status,
        o.total_amount,
        o.created_at,
        COUNT(oi.id) as item_count,
        jsonb_agg(
            jsonb_build_object(
                'product_name', p.name,
                'quantity', oi.quantity,
                'unit_price', oi.unit_price,
                'subtotal', oi.subtotal,
                'notes', oi.notes
            )
        ) as items
    FROM orders o
    JOIN establishments e ON o.establishment_id = e.id
    LEFT JOIN order_items oi ON o.id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE o.id = p_order_id
    GROUP BY o.id, e.name, o.table_number, o.status, o.total_amount, o.created_at;
END;
$$ LANGUAGE plpgsql;

-- Get orders by establishment function
CREATE OR REPLACE FUNCTION get_establishment_orders(
    p_establishment_id UUID,
    p_status VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    table_number INTEGER,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE,
    item_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.table_number,
        o.status,
        o.total_amount,
        o.created_at,
        COUNT(oi.id) as item_count
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.establishment_id = p_establishment_id
      AND (p_status IS NULL OR o.status = p_status)
    GROUP BY o.id, o.table_number, o.status, o.total_amount, o.created_at
    ORDER BY o.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Get orders by table function
CREATE OR REPLACE FUNCTION get_table_orders(p_establishment_id UUID, p_table_number INTEGER)
RETURNS TABLE (
    id UUID,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE,
    item_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.status,
        o.total_amount,
        o.created_at,
        COUNT(oi.id) as item_count
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.establishment_id = p_establishment_id
      AND o.table_number = p_table_number
    GROUP BY o.id, o.status, o.total_amount, o.created_at
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Cancel order function
CREATE OR REPLACE FUNCTION cancel_order(p_order_id UUID, p_reason TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    UPDATE orders
    SET status = 'cancelled',
        notes = COALESCE(p_reason, notes),
        updated_at = NOW()
    WHERE id = p_order_id AND status NOT IN ('completed', 'cancelled');
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- ORDER STATISTICS FUNCTIONS
-- ==========================================

-- Get order statistics function
CREATE OR REPLACE FUNCTION get_order_statistics(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    total_orders BIGINT,
    completed_orders BIGINT,
    cancelled_orders BIGINT,
    total_revenue DECIMAL(10,2),
    average_order_value DECIMAL(10,2),
    total_items_sold BIGINT
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT o.id) as total_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'completed' THEN o.id END) as completed_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.id END) as cancelled_orders,
        COALESCE(SUM(o.total_amount), 0) as total_revenue,
        CASE
            WHEN COUNT(o.id) > 0 THEN COALESCE(SUM(o.total_amount) / COUNT(DISTINCT o.id), 0)
            ELSE 0
        END as average_order_value,
        COALESCE(SUM(oi.quantity), 0) as total_items_sold
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.establishment_id = p_establishment_id
      AND o.created_at >= v_start_date
      AND o.created_at <= v_end_date;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ ORDERS MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '📝 Order management and statistics functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/03_business/orders.sql