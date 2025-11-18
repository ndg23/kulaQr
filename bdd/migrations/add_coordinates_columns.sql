-- Migration: Add/Update latitude and longitude columns
-- Date: 2025-11-17
-- Description: Modify latitude and longitude columns to use appropriate numeric types

-- Drop existing columns if they are TEXT type
ALTER TABLE establishments 
DROP COLUMN IF EXISTS latitude CASCADE,
DROP COLUMN IF EXISTS longitude CASCADE;

-- Add latitude and longitude as DECIMAL for precise coordinates
ALTER TABLE establishments 
ADD COLUMN latitude DECIMAL(10, 8),
ADD COLUMN longitude DECIMAL(11, 8);

-- Create indexes for geospatial queries (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_establishments_coordinates 
ON establishments(latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Add comment for documentation
COMMENT ON COLUMN establishments.latitude IS 'Latitude coordinate (decimal degrees, -90 to 90)';
COMMENT ON COLUMN establishments.longitude IS 'Longitude coordinate (decimal degrees, -180 to 180)';

-- Add constraints to ensure valid coordinate ranges
ALTER TABLE establishments 
ADD CONSTRAINT latitude_range CHECK (latitude >= -90 AND latitude <= 90),
ADD CONSTRAINT longitude_range CHECK (longitude >= -180 AND longitude <= 180);

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Latitude and longitude columns updated successfully!';
    RAISE NOTICE '📍 Coordinates can now store precise decimal values';
END $$;
