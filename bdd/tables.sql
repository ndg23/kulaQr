-- Migration: Create unified tables table
-- Description: Combines best practices from both schemas into a single, comprehensive table structure

-- Drop existing table if it exists (use with caution in production)
-- DROP TABLE IF EXISTS tables CASCADE;
-- CREATE TABLE restaurant_tables (
--     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--     establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
--     table_number VARCHAR(10) NOT NULL,
--     capacity INT,
--     status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
--     qr_code_id UUID,
--     location_description TEXT,
--     section_name TEXT, -- Zone du restaurant (terrasse, salle principale, bar, etc.)
--     floor_level TEXT, -- Étage (rez-de-chaussée, étage, sous-sol)
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     created_by UUID REFERENCES auth.users(id),
--     is_active BOOLEAN DEFAULT true,
--     UNIQUE(establishment_id, table_number)
-- );
-- Create the tables table with unified schema
CREATE TABLE IF NOT EXISTS tables (
    -- Primary identification
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    
    -- Table identification (supports both numeric and alphanumeric)
    table_number VARCHAR(10) NOT NULL,
    
    -- Table characteristics
    capacity INT,
    type VARCHAR(20) DEFAULT 'SIMPLE' CHECK (type IN ('VIP', 'SIMPLE', 'STANDARD')),
    
    -- Location information
    section_name VARCHAR(100) DEFAULT 'ETAGE', -- Zone (terrasse, salle principale, bar, etc.)
    floor_level VARCHAR(50), -- Étage (rez-de-chaussée, étage, sous-sol)
    location_description TEXT,
    
    -- Status management
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
    is_active BOOLEAN DEFAULT true,
    
    -- QR Code management
    qr_code_url TEXT,
    qr_code_id UUID,
    qr_code_generated BOOLEAN DEFAULT false,
    
    -- Additional info
    description TEXT,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    UNIQUE(establishment_id, table_number)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tables_establishment_id ON tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_tables_status ON tables(status);
CREATE INDEX IF NOT EXISTS idx_tables_section_name ON tables(section_name);
CREATE INDEX IF NOT EXISTS idx_tables_is_active ON tables(is_active);
CREATE INDEX IF NOT EXISTS idx_tables_qr_code_id ON tables(qr_code_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_tables_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function before each update
DROP TRIGGER IF EXISTS trigger_update_tables_updated_at ON tables;
CREATE TRIGGER trigger_update_tables_updated_at
    BEFORE UPDATE ON tables
    FOR EACH ROW
    EXECUTE FUNCTION update_tables_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;

-- Create RLS policies

-- Policy: Allow establishment owners/managers to view their tables
CREATE POLICY "Allow establishment staff to view tables"
    ON tables
    FOR SELECT
    USING (
        establishment_id IN (
            SELECT establishment_id 
            FROM staff 
            WHERE staff.user_id = auth.uid()
            AND staff.is_active = true
        )
    );

-- Policy: Allow establishment owners/managers to insert tables
CREATE POLICY "Allow establishment managers to insert tables"
    ON tables
    FOR INSERT
    WITH CHECK (
        establishment_id IN (
            SELECT establishment_id 
            FROM staff 
            WHERE staff.user_id = auth.uid()
            AND staff.role IN ('manager', 'owner')
            AND staff.is_active = true
        )
    );

-- Policy: Allow establishment owners/managers to update tables
CREATE POLICY "Allow establishment managers to update tables"
    ON tables
    FOR UPDATE
    USING (
        establishment_id IN (
            SELECT establishment_id 
            FROM staff 
            WHERE staff.user_id = auth.uid()
            AND staff.role IN ('manager', 'owner')
            AND staff.is_active = true
        )
    );

-- Policy: Allow establishment owners/managers to delete tables
CREATE POLICY "Allow establishment managers to delete tables"
    ON tables
    FOR DELETE
    USING (
        establishment_id IN (
            SELECT establishment_id 
            FROM staff 
            WHERE staff.user_id = auth.uid()
            AND staff.role IN ('manager', 'owner')
            AND staff.is_active = true
        )
    );

-- Policy: Allow public to view active tables (for QR code scanning)
CREATE POLICY "Allow public to view active tables"
    ON tables
    FOR SELECT
    USING (is_active = true AND status != 'maintenance');

-- Add helpful comments
COMMENT ON TABLE tables IS 'Stores restaurant table information with location, status, and QR code management';
COMMENT ON COLUMN tables.table_number IS 'Unique table identifier within establishment (supports alphanumeric)';
COMMENT ON COLUMN tables.type IS 'Table type: VIP, SIMPLE, or STANDARD';
COMMENT ON COLUMN tables.section_name IS 'Section/zone of the restaurant (e.g., terrasse, salle principale, bar)';
COMMENT ON COLUMN tables.floor_level IS 'Floor level (e.g., rez-de-chaussée, étage, sous-sol)';
COMMENT ON COLUMN tables.status IS 'Current table status: available, occupied, reserved, or maintenance';
COMMENT ON COLUMN tables.qr_code_url IS 'URL to the generated QR code image';
COMMENT ON COLUMN tables.qr_code_id IS 'Reference to external QR code service if applicable';

-- Insert sample data (optional - remove in production)
/*
INSERT INTO tables (establishment_id, table_number, capacity, type, section_name, floor_level, status)
VALUES 
    ('YOUR_ESTABLISHMENT_ID', '1', 4, 'SIMPLE', 'Salle principale', 'Rez-de-chaussée', 'available'),
    ('YOUR_ESTABLISHMENT_ID', '2', 2, 'VIP', 'Terrasse', 'Rez-de-chaussée', 'available'),
    ('YOUR_ESTABLISHMENT_ID', 'A1', 6, 'STANDARD', 'Bar', 'Étage', 'occupied');
*/