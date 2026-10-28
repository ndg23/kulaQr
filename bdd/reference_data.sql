-- Données de référence seules (types d'établissement + catégories par défaut).
-- Relançable sans risque ; à exécuter dans l'éditeur SQL de Supabase si la migration complète est déjà appliquée.
BEGIN;

-- ==========================================
-- DONNÉES DE RÉFÉRENCE (nécessaires à l'inscription)
-- ==========================================
-- Types d'établissement : la liste déroulante de /auth/register lit cette table.
-- Sans ligne active, personne ne peut s'inscrire.
INSERT INTO establishment_types (name, slug, icon, description, is_active) VALUES
    ('Restaurant',     'restaurant',  'utensils',    'Restaurant avec service à table', TRUE),
    ('Café',           'cafe',        'coffee',      'Café et salon de thé',            TRUE),
    ('Bar & Lounge',   'bar',         'wine',        'Bar, lounge et boîte de nuit',    TRUE),
    ('Fast-food',      'fast-food',   'sandwich',    'Restauration rapide',             TRUE),
    ('Boulangerie',    'boulangerie', 'croissant',   'Boulangerie et pâtisserie',       TRUE),
    ('Hôtel',          'hotel',       'bed',         'Hôtel et résidence',              TRUE)
ON CONFLICT (slug) DO NOTHING;

-- Catégories proposées par défaut à chaque nouvel établissement, selon son type.
-- Modifiables par un admin ; copiées dans `categories` à la création de l'établissement.
CREATE TABLE IF NOT EXISTS establishment_type_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_id UUID NOT NULL REFERENCES establishment_types(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    order_number INTEGER NOT NULL DEFAULT 0,
    UNIQUE (type_id, name)
);

ALTER TABLE establishment_type_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Type categories are viewable by everyone" ON establishment_type_categories;
CREATE POLICY "Type categories are viewable by everyone" ON establishment_type_categories
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins manage type categories" ON establishment_type_categories;
CREATE POLICY "Admins manage type categories" ON establishment_type_categories
    FOR ALL USING (is_admin_user()) WITH CHECK (is_admin_user());

INSERT INTO establishment_type_categories (type_id, name, order_number)
SELECT t.id, c.name, c.ord
FROM (VALUES
    ('restaurant',  'Entrées',      0), ('restaurant',  'Plats',        1), ('restaurant',  'Desserts',     2), ('restaurant',  'Boissons',     3),
    ('cafe',        'Cafés',        0), ('cafe',        'Thés',         1), ('cafe',        'Pâtisseries',  2), ('cafe',        'Boissons fraîches', 3),
    ('bar',         'Cocktails',    0), ('bar',         'Bières',       1), ('bar',         'Vins',         2), ('bar',         'Softs',        3), ('bar', 'À grignoter', 4),
    ('fast-food',   'Burgers',      0), ('fast-food',   'Sandwichs',    1), ('fast-food',   'Accompagnements', 2), ('fast-food', 'Boissons',  3),
    ('boulangerie', 'Pains',        0), ('boulangerie', 'Viennoiseries',1), ('boulangerie', 'Pâtisseries',  2), ('boulangerie', 'Boissons',     3),
    ('hotel',       'Petit-déjeuner', 0), ('hotel',     'Room service', 1), ('hotel',       'Restaurant',   2), ('hotel',       'Bar',          3)
) AS c(slug, name, ord)
JOIN establishment_types t ON t.slug = c.slug
ON CONFLICT (type_id, name) DO NOTHING;

-- À la création d'un établissement, on lui copie les catégories de son type.
-- SECURITY DEFINER : l'inscription se fait avant que le profil soit activé (pas de droits d'écriture sur categories).
CREATE OR REPLACE FUNCTION public.seed_default_categories()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_type_id UUID := COALESCE(NEW.type_id, NEW.establishment_type_id);
BEGIN
    IF v_type_id IS NULL THEN
        RETURN NEW;
    END IF;

    INSERT INTO categories (establishment_id, name, description, order_number, is_active)
    SELECT NEW.id, name, description, order_number, TRUE
    FROM establishment_type_categories
    WHERE type_id = v_type_id
    ON CONFLICT (establishment_id, name) DO NOTHING;

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.seed_default_categories() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_seed_default_categories ON establishments;
CREATE TRIGGER trg_seed_default_categories
    AFTER INSERT ON establishments
    FOR EACH ROW EXECUTE FUNCTION public.seed_default_categories();

COMMIT;
