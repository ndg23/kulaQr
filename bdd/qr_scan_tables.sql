-- Table to store individual QR code scans
CREATE TABLE qr_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INT,
  user_agent TEXT,
  scan_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

    -- Create index for faster queries
    CREATE INDEX idx_qr_scans_establishment ON qr_scans(establishment_id);
    CREATE INDEX idx_qr_scans_scan_time ON qr_scans(scan_time);

    -- View for QR scan statistics
    CREATE OR REPLACE VIEW qr_scan_stats AS
    WITH today_scans AS (
    SELECT 
        establishment_id,
        COUNT(*) as count
    FROM qr_scans
    WHERE DATE(scan_time) = CURRENT_DATE
    GROUP BY establishment_id
    ),
    total_scans AS (
    SELECT 
        establishment_id,
        COUNT(*) as count
    FROM qr_scans
    GROUP BY establishment_id
    ),
    conversions AS (
    SELECT
        q.establishment_id,
        (COUNT(DISTINCT o.id) * 100.0 / NULLIF(COUNT(DISTINCT q.id), 0)) as rate
    FROM qr_scans q
    LEFT JOIN orders o ON 
        o.establishment_id = q.establishment_id AND
        o.created_at > q.scan_time AND
        o.created_at <= q.scan_time + INTERVAL '30 minutes'
    GROUP BY q.establishment_id
    )
    SELECT 
    e.id as establishment_id,
    COALESCE(ts.count, 0) as total_scans,
    COALESCE(td.count, 0) as today_scans,
    ROUND(COALESCE(c.rate, 0)) as conversion_rate
    FROM establishments e
    LEFT JOIN total_scans ts ON e.id = ts.establishment_id
    LEFT JOIN today_scans td ON e.id = td.establishment_id
    LEFT JOIN conversions c ON e.id = c.establishment_id; 













    -- Create or replace the view for QR scan statistics
CREATE OR REPLACE VIEW qr_scan_stats AS
WITH today_scans AS (
  SELECT 
    establishment_id,
    COUNT(*) as count
  FROM qr_scans
  WHERE DATE(created_at) = CURRENT_DATE
  GROUP BY establishment_id
),
total_scans AS (
  SELECT 
    establishment_id,
    COUNT(*) as count
  FROM qr_scans
  GROUP BY establishment_id
),
conversions AS (
  SELECT
    q.establishment_id,
    (COUNT(DISTINCT o.id) * 100.0 / NULLIF(COUNT(DISTINCT q.id), 0)) as rate
  FROM qr_scans q
  LEFT JOIN orders o ON 
    o.establishment_id = q.establishment_id AND
    o.created_at > q.created_at AND
    o.created_at <= q.created_at + INTERVAL '30 minutes'
  GROUP BY q.establishment_id
)
SELECT 
  e.id as establishment_id,
  COALESCE(ts.count, 0) as total_scans,
  COALESCE(td.count, 0) as today_scans,
  ROUND(COALESCE(c.rate, 0)) as conversion_rate
FROM establishments e
LEFT JOIN total_scans ts ON e.id = ts.establishment_id
LEFT JOIN today_scans td ON e.id = td.establishment_id
LEFT JOIN conversions c ON e.id = c.establishment_id;





-- Fonction de secours pour l'insertion de scans QR
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

-- Fonction pour récupérer les colonnes d'une table
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