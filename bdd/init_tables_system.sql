-- ==========================================
-- SCRIPT D'INITIALISATION DU SYSTÈME DE TABLES
-- ==========================================
-- Ce script crée toutes les tables nécessaires pour le système de gestion des tables avec QR codes

-- ==========================================
-- 1. TABLE DES TABLES D'ÉTABLISSEMENT
-- ==========================================
CREATE TABLE IF NOT EXISTS tables (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    type VARCHAR(20) DEFAULT 'SIMPLE' CHECK (type IN ('VIP', 'SIMPLE')),
    zone VARCHAR(100) DEFAULT 'ETAGE',
    description TEXT,
    qr_code_url TEXT,
    qr_code_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte unique pour éviter les doublons de numéros de table dans un établissement
    UNIQUE(establishment_id, number)
);

-- ==========================================
-- 2. TABLE DES QR CODES DES TABLES
-- ==========================================
CREATE TABLE IF NOT EXISTS table_qr_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    qr_code_url TEXT NOT NULL,
    qr_code_data TEXT, -- Données du QR code (image base64)
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un QR code par table
    UNIQUE(table_id)
);

-- ==========================================
-- 3. TABLE DES SCANS DE QR CODES
-- ==========================================
CREATE TABLE IF NOT EXISTS table_qr_scans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    user_agent TEXT,
    ip_address INET,
    referrer TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 4. TABLE DES COMMANDES (MISE À JOUR)
-- ==========================================
-- Ajouter les colonnes table_id si elles n'existent pas
DO $$ 
BEGIN
    -- Ajouter table_id si n'existe pas
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'orders' AND column_name = 'table_id') THEN
        ALTER TABLE orders ADD COLUMN table_id UUID REFERENCES tables(id);
    END IF;
    
    -- Ajouter table_number si n'existe pas
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'orders' AND column_name = 'table_number') THEN
        ALTER TABLE orders ADD COLUMN table_number INTEGER;
    END IF;
END $$;

-- ==========================================
-- INDEX POUR AMÉLIORER LES PERFORMANCES
-- ==========================================

-- Index pour la table tables
CREATE INDEX IF NOT EXISTS idx_tables_establishment_id ON tables(establishment_id);
CREATE INDEX IF NOT EXISTS idx_tables_type ON tables(type);
CREATE INDEX IF NOT EXISTS idx_tables_number ON tables(establishment_id, number);
CREATE INDEX IF NOT EXISTS idx_tables_qr_generated ON tables(qr_code_generated);

-- Index pour la table table_qr_codes
CREATE INDEX IF NOT EXISTS idx_table_qr_codes_table_id ON table_qr_codes(table_id);
CREATE INDEX IF NOT EXISTS idx_table_qr_codes_qr_code_url ON table_qr_codes(qr_code_url);
CREATE INDEX IF NOT EXISTS idx_table_qr_codes_is_active ON table_qr_codes(is_active);

-- Index pour la table table_qr_scans
CREATE INDEX IF NOT EXISTS idx_table_qr_scans_table_id ON table_qr_scans(table_id);
CREATE INDEX IF NOT EXISTS idx_table_qr_scans_establishment_id ON table_qr_scans(establishment_id);
CREATE INDEX IF NOT EXISTS idx_table_qr_scans_created_at ON table_qr_scans(created_at);

-- Index pour la table orders (si les colonnes existent)
CREATE INDEX IF NOT EXISTS idx_orders_table_id ON orders(table_id);
CREATE INDEX IF NOT EXISTS idx_orders_table_number ON orders(table_number);

-- ==========================================
-- FONCTIONS ET TRIGGERS
-- ==========================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour tables
CREATE TRIGGER trigger_update_tables_updated_at
    BEFORE UPDATE ON tables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Trigger pour table_qr_codes
CREATE TRIGGER trigger_update_table_qr_codes_updated_at
    BEFORE UPDATE ON table_qr_codes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Fonction pour mettre à jour le statut de la table lors des commandes
CREATE OR REPLACE FUNCTION update_table_status_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.table_id IS NOT NULL THEN
        -- Marquer la table comme occupée
        UPDATE tables
        SET updated_at = NOW()
        WHERE id = NEW.table_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND NEW.table_id IS NOT NULL THEN
        -- Marquer la table comme disponible
        UPDATE tables
        SET updated_at = NOW()
        WHERE id = NEW.table_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour les commandes
CREATE TRIGGER trigger_update_table_status_on_order
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_table_status_on_order();

-- ==========================================
-- RLS (ROW LEVEL SECURITY)
-- ==========================================

-- RLS pour tables
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

-- RLS pour table_qr_codes
ALTER TABLE table_qr_codes ENABLE ROW LEVEL SECURITY;

-- Politique pour les propriétaires d'établissement
CREATE POLICY "Establishment owners can manage their table QR codes" ON table_qr_codes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tables t
            JOIN establishments e ON t.establishment_id = e.id
            WHERE t.id = table_qr_codes.table_id AND e.user_id = auth.uid()
        )
    );

-- Politique pour les admins
CREATE POLICY "Admins can manage all table QR codes" ON table_qr_codes
    FOR ALL USING (
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- Politique pour le staff (lecture seule)
CREATE POLICY "Staff can view table QR codes" ON table_qr_codes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tables t
            JOIN staff s ON t.establishment_id = s.establishment_id
            WHERE t.id = table_qr_codes.table_id AND s.user_id = auth.uid()
        )
    );

-- RLS pour table_qr_scans
ALTER TABLE table_qr_scans ENABLE ROW LEVEL SECURITY;

-- Politique pour les propriétaires d'établissement
CREATE POLICY "Establishment owners can view their table scans" ON table_qr_scans
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM establishments
            WHERE id = table_qr_scans.establishment_id AND user_id = auth.uid()
        )
    );

-- Politique pour les admins
CREATE POLICY "Admins can view all table scans" ON table_qr_scans
    FOR SELECT USING (
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- Politique pour le staff
CREATE POLICY "Staff can view their establishment table scans" ON table_qr_scans
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM staff
            WHERE establishment_id = table_qr_scans.establishment_id AND user_id = auth.uid()
        )
    );

-- Politique pour insérer les scans (tout le monde peut scanner)
CREATE POLICY "Anyone can insert table scans" ON table_qr_scans
    FOR INSERT WITH CHECK (true);

-- ==========================================
-- COMMENTAIRES
-- ==========================================

COMMENT ON TABLE tables IS 'Tables des établissements avec QR codes uniques';
COMMENT ON COLUMN tables.number IS 'Numéro de la table (unique par établissement)';
COMMENT ON COLUMN tables.type IS 'Type de table: VIP ou SIMPLE';
COMMENT ON COLUMN tables.zone IS 'Zone de la table (ex: ETAGE, TERRASSE)';
COMMENT ON COLUMN tables.qr_code_url IS 'URL du QR code généré pour cette table';
COMMENT ON COLUMN tables.qr_code_generated IS 'Indique si un QR code a été généré pour cette table';

COMMENT ON TABLE table_qr_codes IS 'QR codes générés pour chaque table';
COMMENT ON COLUMN table_qr_codes.qr_code_url IS 'URL complète du QR code';
COMMENT ON COLUMN table_qr_codes.qr_code_data IS 'Données du QR code (image base64)';
COMMENT ON COLUMN table_qr_codes.is_active IS 'Indique si le QR code est actif';

COMMENT ON TABLE table_qr_scans IS 'Historique des scans de QR codes des tables';
COMMENT ON COLUMN table_qr_scans.user_agent IS 'User agent du navigateur qui a scanné';
COMMENT ON COLUMN table_qr_scans.ip_address IS 'Adresse IP du scanner';
COMMENT ON COLUMN table_qr_scans.referrer IS 'Page de référence du scan';

-- ==========================================
-- DONNÉES DE TEST (OPTIONNEL)
-- ==========================================

-- Insérer des tables d'exemple pour un établissement de test
-- (Décommentez si vous voulez des données de test)
/*
INSERT INTO tables (establishment_id, number, type, zone, description) 
SELECT 
    e.id,
    generate_series(1, 10),
    CASE WHEN random() > 0.8 THEN 'VIP' ELSE 'SIMPLE' END,
    CASE 
        WHEN random() > 0.7 THEN 'TERRASSE'
        WHEN random() > 0.4 THEN 'REZ_DE_CHAUSSEE'
        ELSE 'ETAGE'
    END,
    'Table ' || generate_series(1, 10)
FROM establishments e 
WHERE e.name ILIKE '%test%' OR e.name ILIKE '%demo%'
LIMIT 1;
*/

-- ==========================================
-- VUES UTILES
-- ==========================================

-- Vue pour les statistiques des tables
CREATE OR REPLACE VIEW table_statistics AS
SELECT 
    e.id as establishment_id,
    e.name as establishment_name,
    COUNT(t.id) as total_tables,
    COUNT(CASE WHEN t.type = 'VIP' THEN 1 END) as vip_tables,
    COUNT(CASE WHEN t.qr_code_generated = true THEN 1 END) as tables_with_qr,
    COUNT(CASE WHEN t.qr_code_generated = false THEN 1 END) as tables_without_qr,
    ROUND(
        COUNT(CASE WHEN t.qr_code_generated = true THEN 1 END) * 100.0 / COUNT(t.id), 
        2
    ) as qr_generation_percentage
FROM establishments e
LEFT JOIN tables t ON e.id = t.establishment_id
GROUP BY e.id, e.name;

-- Vue pour les scans récents
CREATE OR REPLACE VIEW recent_table_scans AS
SELECT 
    t.id as table_id,
    t.number as table_number,
    e.name as establishment_name,
    ts.created_at as scan_time,
    ts.user_agent,
    ts.ip_address
FROM table_qr_scans ts
JOIN tables t ON ts.table_id = t.id
JOIN establishments e ON t.establishment_id = e.id
WHERE ts.created_at >= NOW() - INTERVAL '24 hours'
ORDER BY ts.created_at DESC;

-- ==========================================
-- FIN DU SCRIPT
-- ==========================================

-- Message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Système de tables initialisé avec succès !';
    RAISE NOTICE 'Tables créées: tables, table_qr_codes, table_qr_scans';
    RAISE NOTICE 'Vues créées: table_statistics, recent_table_scans';
    RAISE NOTICE 'RLS activé pour toutes les tables';
    RAISE NOTICE 'Triggers configurés pour la mise à jour automatique';
END $$;
