-- Table des paramètres système
CREATE TABLE system_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(100) NOT NULL UNIQUE,
  value JSONB NOT NULL,
  description TEXT,
  category VARCHAR(50) NOT NULL,
  is_encrypted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour accélérer les recherches par clé
CREATE INDEX idx_system_settings_key ON system_settings(key);
CREATE INDEX idx_system_settings_category ON system_settings(category);

-- Fonction pour mettre à jour le timestamp updated_at
CREATE OR REPLACE FUNCTION update_system_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour le timestamp
CREATE TRIGGER update_system_settings_timestamp
BEFORE UPDATE ON system_settings
FOR EACH ROW
EXECUTE FUNCTION update_system_settings_timestamp();

-- Insertion des paramètres par défaut
INSERT INTO system_settings (key, value, description, category) VALUES
('smtp', '{"host": "", "port": "587", "username": "", "password": "", "secure": true}', 'Configuration du serveur SMTP', 'email'),
('maintenance_mode', 'false', 'Mode maintenance du site', 'system'),
('backup', '{"last_backup": null, "auto_backup": false, "frequency": "daily"}', 'Configuration des sauvegardes', 'system'),
('security', '{"two_factor_enabled": false, "password_expiry_days": 90, "max_login_attempts": 5}', 'Paramètres de sécurité', 'security'),
('cache', '{"last_cleared": null, "auto_clear": false, "frequency": "weekly"}', 'Configuration du cache', 'system'),
('app_info', '{"version": "1.5.2", "environment": "production", "last_deployment": null}', 'Informations sur l\'application', 'system'); 