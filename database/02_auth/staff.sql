-- ==========================================
-- KULA QR - STAFF MANAGEMENT
-- ==========================================
-- Gestion du personnel (avec ou sans PIN)
-- Fait partie du module 02_auth

-- ==========================================
-- STAFF TABLE
-- ==========================================

CREATE TABLE IF NOT EXISTS staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
  username VARCHAR(100) NOT NULL,
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Optionnel pour les comptes complets
  pin VARCHAR(4), -- Optionnel pour les accès PIN
  role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('manager', 'staff', 'waiter', 'kitchen')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Contraintes
  UNIQUE (establishment_id, username),
  UNIQUE (establishment_id, pin) -- Uniquement pour les PIN non NULL
);

-- ==========================================
-- STAFF POLICIES
-- ==========================================

-- Politiques de base pour la sécurité
DROP POLICY IF EXISTS "Les propriétaires et managers peuvent gérer le personnel" ON staff;
CREATE POLICY "Les propriétaires et managers peuvent gérer le personnel"
  ON staff
  FOR ALL
  USING (
    auth.uid() IN (
      SELECT created_by FROM establishments
      WHERE id = staff.establishment_id
    )
    OR
    auth.uid() IN (
      SELECT id FROM staff
      WHERE establishment_id = staff.establishment_id
      AND role = 'manager'
    )
  );

-- ==========================================
-- STAFF INDEXES
-- ==========================================

-- Création d'index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_staff_establishment ON staff(establishment_id);
CREATE INDEX IF NOT EXISTS idx_staff_role ON staff(role);
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff(is_active);

-- ==========================================
-- STAFF TRIGGERS
-- ==========================================

-- Trigger pour mettre à jour le champ updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger à la table staff
CREATE TRIGGER update_staff_updated_at
BEFORE UPDATE ON staff
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ STAFF MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '👨‍🍳 Staff table and policies ready';
END $$;