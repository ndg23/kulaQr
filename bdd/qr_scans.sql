-- Table pour suivre les scans de QR codes
CREATE TABLE IF NOT EXISTS qr_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  qr_code_id UUID REFERENCES qr_codes(id) ON DELETE SET NULL,
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  table_number INTEGER,
  user_agent TEXT,
  referrer TEXT,
  ip_address INET,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_qr_scans_qr_code_id ON qr_scans(qr_code_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_establishment_id ON qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON qr_scans(created_at); 