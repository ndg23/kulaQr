-- Table pour gérer les tables des établissements
CREATE TABLE IF NOT EXISTS tables (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    type VARCHAR(20) DEFAULT 'SIMPLE' CHECK (type IN ('VIP', 'SIMPLE')),
    zone VARCHAR(100) DEFAULT 'ETAGE',
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
    description TEXT,
    qr_code_url TEXT,
    qr_code_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte unique pour éviter les doublons de numéros de table dans un établissement
    UNIQUE(establishment_id, number)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_tables_establishment_id ON tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_tables_type ON tables(type);
CREATE INDEX IF NOT EXISTS idx_tables_number ON tables(establishment_id, number);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_tables_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_update_tables_updated_at
    BEFORE UPDATE ON tables
    FOR EACH ROW
    EXECUTE FUNCTION update_tables_updated_at();

-- RLS (Row Level Security)
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;

-- Politique pour les propriétaires d'établissement
CREATE POLICY "Establishment owners can manage their tables" ON tables
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM establishments
            WHERE id = tables.establishment_id AND user_id = auth.uid()
        )
    );

-- Politique pour les admins
CREATE POLICY "Admins can manage all tables" ON tables
    FOR ALL USING (
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- Politique pour le staff (lecture seule)
CREATE POLICY "Staff can view tables" ON tables
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM staff
            WHERE establishment_id = tables.establishment_id AND user_id = auth.uid()
        )
    );

-- Commentaires
COMMENT ON TABLE tables IS 'Tables des établissements avec QR codes uniques';
COMMENT ON COLUMN tables.number IS 'Numéro de la table (unique par établissement)';
COMMENT ON COLUMN tables.type IS 'Type de table: VIP ou SIMPLE';
COMMENT ON COLUMN tables.zone IS 'Zone de la table (ex: ETAGE, TERRASSE)';
COMMENT ON COLUMN tables.qr_code_url IS 'URL du QR code généré pour cette table';
COMMENT ON COLUMN tables.qr_code_generated IS 'Indique si un QR code a été généré pour cette table';
