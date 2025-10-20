-- ==========================================
-- KULA QR - TABLES SYSTEM MANAGEMENT
-- ==========================================
-- Gestion des tables et zones dans les établissements
-- Fait partie du module 03_business

-- ==========================================
-- TABLES SYSTEM
-- ==========================================

-- Tables table (already created in core, but business logic here)
CREATE TABLE IF NOT EXISTS tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    table_number INTEGER NOT NULL,
    zone_name VARCHAR(100),
    capacity INTEGER DEFAULT 4,
    status VARCHAR(50) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
    qr_code_url TEXT,
    qr_code_data TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(establishment_id, table_number)
);

-- Table zones table
CREATE TABLE IF NOT EXISTS table_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7), -- Hex color code
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(establishment_id, name)
);

-- ==========================================
-- TABLE MANAGEMENT FUNCTIONS
-- ==========================================

-- Create table function
CREATE OR REPLACE FUNCTION create_table(
    p_establishment_id UUID,
    p_table_number INTEGER,
    p_zone_name VARCHAR(100) DEFAULT NULL,
    p_capacity INTEGER DEFAULT 4
)
RETURNS UUID AS $$
DECLARE
    v_table_id UUID;
    v_qr_code_data TEXT;
BEGIN
    -- Generate QR code data
    v_qr_code_data := generate_qr_code_data(p_establishment_id, p_table_number);

    -- Create table
    INSERT INTO tables (
        establishment_id,
        table_number,
        zone_name,
        capacity,
        qr_code_data
    ) VALUES (
        p_establishment_id,
        p_table_number,
        p_zone_name,
        p_capacity,
        v_qr_code_data
    ) RETURNING id INTO v_table_id;

    RETURN v_table_id;
END;
$$ LANGUAGE plpgsql;

-- Update table status function
CREATE OR REPLACE FUNCTION update_table_status(
    p_establishment_id UUID,
    p_table_number INTEGER,
    p_status VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
    -- Validate status
    IF p_status NOT IN ('available', 'occupied', 'reserved', 'maintenance') THEN
        RAISE EXCEPTION 'Invalid table status: %', p_status;
    END IF;

    UPDATE tables
    SET status = p_status, updated_at = NOW()
    WHERE establishment_id = p_establishment_id
      AND table_number = p_table_number;
END;
$$ LANGUAGE plpgsql;

-- Get establishment tables function
CREATE OR REPLACE FUNCTION get_establishment_tables(p_establishment_id UUID)
RETURNS TABLE (
    id UUID,
    table_number INTEGER,
    zone_name VARCHAR(100),
    capacity INTEGER,
    status VARCHAR(50),
    qr_code_url TEXT,
    current_order_id UUID,
    last_order_time TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.table_number,
        t.zone_name,
        t.capacity,
        t.status,
        t.qr_code_url,
        o.id as current_order_id,
        o.created_at as last_order_time
    FROM tables t
    LEFT JOIN orders o ON t.id = o.table_id
        AND o.status IN ('pending', 'processing')
        AND o.created_at = (
            SELECT MAX(created_at)
            FROM orders
            WHERE table_id = t.id
              AND status IN ('pending', 'processing')
        )
    WHERE t.establishment_id = p_establishment_id
    ORDER BY t.table_number;
END;
$$ LANGUAGE plpgsql;

-- Get table details function
CREATE OR REPLACE FUNCTION get_table_details(p_establishment_id UUID, p_table_number INTEGER)
RETURNS TABLE (
    id UUID,
    table_number INTEGER,
    zone_name VARCHAR(100),
    capacity INTEGER,
    status VARCHAR(50),
    qr_code_url TEXT,
    qr_code_data TEXT,
    current_order JSONB,
    recent_orders JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.table_number,
        t.zone_name,
        t.capacity,
        t.status,
        t.qr_code_url,
        t.qr_code_data,
        CASE
            WHEN o.id IS NOT NULL THEN
                jsonb_build_object(
                    'id', o.id,
                    'status', o.status,
                    'total_amount', o.total_amount,
                    'created_at', o.created_at,
                    'item_count', (
                        SELECT COUNT(*)
                        FROM order_items oi
                        WHERE oi.order_id = o.id
                    )
                )
            ELSE NULL
        END as current_order,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', ro.id,
                    'status', ro.status,
                    'total_amount', ro.total_amount,
                    'created_at', ro.created_at
                )
            )
            FROM (
                SELECT *
                FROM orders
                WHERE table_id = t.id
                  AND status IN ('completed', 'cancelled')
                ORDER BY created_at DESC
                LIMIT 5
            ) ro
        ) as recent_orders
    FROM tables t
    LEFT JOIN orders o ON t.id = o.table_id
        AND o.status IN ('pending', 'processing')
    WHERE t.establishment_id = p_establishment_id
      AND t.table_number = p_table_number;
END;
$$ LANGUAGE plpgsql;

-- Bulk create tables function
CREATE OR REPLACE FUNCTION bulk_create_tables(
    p_establishment_id UUID,
    p_table_numbers INTEGER[],
    p_zone_name VARCHAR(100) DEFAULT NULL,
    p_capacity INTEGER DEFAULT 4
)
RETURNS INTEGER AS $$
DECLARE
    v_table_number INTEGER;
    v_created_count INTEGER := 0;
BEGIN
    FOREACH v_table_number IN ARRAY p_table_numbers
    LOOP
        -- Check if table already exists
        IF NOT EXISTS (
            SELECT 1 FROM tables
            WHERE establishment_id = p_establishment_id
              AND table_number = v_table_number
        ) THEN
            PERFORM create_table(p_establishment_id, v_table_number, p_zone_name, p_capacity);
            v_created_count := v_created_count + 1;
        END IF;
    END LOOP;

    RETURN v_created_count;
END;
$$ LANGUAGE plpgsql;

-- Delete table function
CREATE OR REPLACE FUNCTION delete_table(p_establishment_id UUID, p_table_number INTEGER)
RETURNS VOID AS $$
DECLARE
    v_table_id UUID;
BEGIN
    -- Get table ID
    SELECT id INTO v_table_id
    FROM tables
    WHERE establishment_id = p_establishment_id
      AND table_number = p_table_number;

    IF v_table_id IS NULL THEN
        RAISE EXCEPTION 'Table not found';
    END IF;

    -- Check for active orders
    IF EXISTS (
        SELECT 1 FROM orders
        WHERE table_id = v_table_id
          AND status IN ('pending', 'processing')
    ) THEN
        RAISE EXCEPTION 'Cannot delete table with active orders';
    END IF;

    -- Delete table
    DELETE FROM tables WHERE id = v_table_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- ZONE MANAGEMENT FUNCTIONS
-- ==========================================

-- Create table zone function
CREATE OR REPLACE FUNCTION create_table_zone(
    p_establishment_id UUID,
    p_name VARCHAR(100),
    p_description TEXT DEFAULT NULL,
    p_color VARCHAR(7) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_zone_id UUID;
BEGIN
    INSERT INTO table_zones (
        establishment_id,
        name,
        description,
        color
    ) VALUES (
        p_establishment_id,
        p_name,
        p_description,
        p_color
    ) RETURNING id INTO v_zone_id;

    RETURN v_zone_id;
END;
$$ LANGUAGE plpgsql;

-- Get establishment zones function
CREATE OR REPLACE FUNCTION get_establishment_zones(p_establishment_id UUID)
RETURNS TABLE (
    id UUID,
    name VARCHAR(100),
    description TEXT,
    color VARCHAR(7),
    table_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tz.id,
        tz.name,
        tz.description,
        tz.color,
        COUNT(t.id) as table_count
    FROM table_zones tz
    LEFT JOIN tables t ON tz.establishment_id = t.establishment_id
        AND tz.name = t.zone_name
    WHERE tz.establishment_id = p_establishment_id
    GROUP BY tz.id, tz.name, tz.description, tz.color
    ORDER BY tz.name;
END;
$$ LANGUAGE plpgsql;

-- Update table zone function
CREATE OR REPLACE FUNCTION update_table_zone(
    p_zone_id UUID,
    p_name VARCHAR(100),
    p_description TEXT,
    p_color VARCHAR(7)
)
RETURNS VOID AS $$
BEGIN
    UPDATE table_zones
    SET name = p_name,
        description = p_description,
        color = p_color
    WHERE id = p_zone_id;
END;
$$ LANGUAGE plpgsql;

-- Delete table zone function
CREATE OR REPLACE FUNCTION delete_table_zone(p_zone_id UUID)
RETURNS VOID AS $$
DECLARE
    v_establishment_id UUID;
    v_zone_name VARCHAR(100);
BEGIN
    -- Get zone info
    SELECT establishment_id, name INTO v_establishment_id, v_zone_name
    FROM table_zones
    WHERE id = p_zone_id;

    IF v_zone_name IS NULL THEN
        RAISE EXCEPTION 'Zone not found';
    END IF;

    -- Check if zone has tables
    IF EXISTS (
        SELECT 1 FROM tables
        WHERE establishment_id = v_establishment_id
          AND zone_name = v_zone_name
    ) THEN
        RAISE EXCEPTION 'Cannot delete zone that contains tables';
    END IF;

    -- Delete zone
    DELETE FROM table_zones WHERE id = p_zone_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TABLE STATISTICS FUNCTIONS
-- ==========================================

-- Get table utilization statistics function
CREATE OR REPLACE FUNCTION get_table_utilization_stats(
    p_establishment_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    table_number INTEGER,
    total_orders BIGINT,
    total_revenue DECIMAL(10,2),
    average_order_value DECIMAL(10,2),
    utilization_rate DECIMAL(5,2)
) AS $$
DECLARE
    v_start_date TIMESTAMP WITH TIME ZONE := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end_date TIMESTAMP WITH TIME ZONE := COALESCE(p_end_date, CURRENT_DATE);
    v_total_days INTEGER := EXTRACT(EPOCH FROM (v_end_date - v_start_date)) / 86400;
BEGIN
    RETURN QUERY
    SELECT
        t.table_number,
        COUNT(o.id) as total_orders,
        COALESCE(SUM(o.total_amount), 0) as total_revenue,
        CASE
            WHEN COUNT(o.id) > 0 THEN COALESCE(SUM(o.total_amount) / COUNT(o.id), 0)
            ELSE 0
        END as average_order_value,
        CASE
            WHEN v_total_days > 0 THEN
                (COUNT(DISTINCT DATE(o.created_at))::DECIMAL / v_total_days) * 100
            ELSE 0
        END as utilization_rate
    FROM tables t
    LEFT JOIN orders o ON t.id = o.table_id
        AND o.created_at >= v_start_date
        AND o.created_at <= v_end_date
        AND o.status = 'completed'
    WHERE t.establishment_id = p_establishment_id
    GROUP BY t.id, t.table_number
    ORDER BY t.table_number;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ TABLES SYSTEM MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '📝 Table and zone management functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/03_business/tables_system.sql