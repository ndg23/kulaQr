-- ==========================================
-- KULA QR - ESTABLISHMENTS MANAGEMENT
-- ==========================================
-- Gestion des établissements et types d'établissements
-- Fait partie du module 03_business

-- ==========================================
-- ESTABLISHMENT TYPES
-- ==========================================

-- Establishment types table (already created in core, but data here)
-- Types d'établissements
CREATE TABLE IF NOT EXISTS establishment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT,
    description TEXT,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Establishment types data
INSERT INTO establishment_types (name, slug, icon, description) VALUES
('Restaurant', 'restaurant', '🍽️', 'Établissements de restauration traditionnelle'),
('Café', 'cafe', '☕', 'Cafés et salons de thé'),
('Bar', 'bar', '🍺', 'Bars et pubs'),
('Fast Food', 'fast-food', '🍔', 'Restauration rapide'),
('Bistrot', 'bistrot', '🥂', 'Petits restaurants à l''ambiance conviviale'),
('Brasserie', 'brasserie', '🍻', 'Établissements servant des plats traditionnels et des bières'),
('Pizzeria', 'pizzeria', '🍕', 'Restaurants spécialisés dans les pizzas'),
('Traiteur', 'traiteur', '🥡', 'Services de restauration à emporter ou pour événements'),
('Boulangerie', 'bakery', '🥖', 'Commerces proposant du pain et des pâtisseries'),
('Pâtisserie', 'pastry-shop', '🧁', 'Commerces spécialisés dans les gâteaux et pâtisseries'),
('Salon de glaces', 'ice-cream-parlor', '🍦', 'Établissements proposant des glaces et sorbets'),
('Restaurant gastronomique', 'fine-dining', '👨‍🍳', 'Restaurants haut de gamme avec cuisine raffinée'),
('Food truck', 'food-truck', '🚚', 'Camions de restauration mobile'),
('Snack', 'snack', '🥪', 'Petits établissements proposant des en-cas rapides'),
('Crêperie', 'creperie', '🥞', 'Restaurants spécialisés dans les crêpes et galettes'),
('Restaurant asiatique', 'asian-restaurant', '🥢', 'Restaurants proposant des spécialités asiatiques'),
('Restaurant italien', 'italian-restaurant', '🍝', 'Restaurants de cuisine italienne'),
('Restaurant français', 'french-restaurant', '🐓', 'Restaurants de cuisine française traditionnelle'),
('Restaurant mexicain', 'mexican-restaurant', '🌮', 'Restaurants proposant des spécialités mexicaines'),
('Restaurant indien', 'indian-restaurant', '🍛', 'Restaurants de cuisine indienne'),
('Sushi bar', 'sushi-bar', '🍣', 'Établissements spécialisés dans les sushis'),
('Steakhouse', 'steakhouse', '🥩', 'Restaurants spécialisés dans les grillades de viande'),
('Brunch café', 'brunch-cafe', '🍳', 'Cafés proposant des formules brunch'),
('Salon de thé', 'tea-room', '🫖', 'Établissements spécialisés dans les thés'),
('Rôtisserie', 'rotisserie', '🍗', 'Commerces spécialisés dans les viandes rôties'),
('Buffet', 'buffet', '🍱', 'Restaurants proposant des formules buffet à volonté'),
('Épicerie fine', 'gourmet-store', '🧀', 'Commerces proposant des produits alimentaires de qualité'),
('Cave à vin', 'wine-cellar', '🍷', 'Établissements spécialisés dans les vins'),
('Discothèque', 'nightclub', '💃', 'Établissements de danse avec service de boissons'),
('Bowling', 'bowling', '🎳', 'Centres de bowling avec service de restauration'),
('Karaoké', 'karaoke', '🎤', 'Bars proposant des activités de karaoké'),
('Pub', 'pub', '🍻', 'Établissements de style britannique servant boissons et repas'),
('Lounge bar', 'lounge-bar', '🍸', 'Bars à l''ambiance feutrée avec cocktails'),
('Club privé', 'private-club', '🎭', 'Clubs réservés aux membres'),
('Hotel restaurant', 'hotel-restaurant', '🏨', 'Restaurants situés dans des hôtels')
ON CONFLICT (slug) DO NOTHING;

-- ==========================================
-- ESTABLISHMENTS MANAGEMENT
-- ==========================================

-- Establishments table (already created in core, but business logic here)
-- Establishments table
CREATE TABLE IF NOT EXISTS establishments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    address TEXT,
    phone TEXT,
    opening_hours TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_by UUID REFERENCES auth.users(id),
    owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    type_id UUID REFERENCES establishment_types(id),
    is_active BOOLEAN DEFAULT TRUE,
    currency TEXT DEFAULT 'XOF',
    subscription_type TEXT DEFAULT 'basic',
    max_categories INTEGER DEFAULT 5,
    max_products INTEGER DEFAULT 20,
    custom_domain TEXT,
    theme_settings JSONB DEFAULT '{}',
    analytics_enabled BOOLEAN DEFAULT FALSE,
    qr_prefix TEXT
);

-- ==========================================
-- ESTABLISHMENT FUNCTIONS
-- ==========================================

-- Get establishment by slug function
CREATE OR REPLACE FUNCTION get_establishment_by_slug(p_slug TEXT)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    image_url TEXT,
    address TEXT,
    phone TEXT,
    opening_hours TEXT,
    currency TEXT,
    theme_settings JSONB,
    type_name TEXT,
    type_icon TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.name,
        e.description,
        e.image_url,
        e.address,
        e.phone,
        e.opening_hours,
        e.currency,
        e.theme_settings,
        et.name as type_name,
        et.icon as type_icon
    FROM establishments e
    LEFT JOIN establishment_types et ON e.type_id = et.id
    WHERE e.slug = p_slug AND e.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Get establishments by user function
CREATE OR REPLACE FUNCTION get_user_establishments(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    slug TEXT,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN,
    subscription_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.name,
        e.slug,
        e.description,
        e.image_url,
        e.is_active,
        e.subscription_type,
        e.created_at
    FROM establishments e
    WHERE e.user_id = p_user_id OR e.owner_id = p_user_id OR e.created_by = p_user_id
    ORDER BY e.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Update establishment stats function
CREATE OR REPLACE FUNCTION update_establishment_stats(p_establishment_id UUID)
RETURNS VOID AS $$
BEGIN
    -- Update categories count
    UPDATE establishments
    SET max_categories = (SELECT COUNT(*) FROM categories WHERE establishment_id = p_establishment_id)
    WHERE id = p_establishment_id;

    -- Update products count
    UPDATE establishments
    SET max_products = (SELECT COUNT(*) FROM products WHERE establishment_id = p_establishment_id)
    WHERE id = p_establishment_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ ESTABLISHMENTS MANAGEMENT CREATED SUCCESSFULLY!';
    RAISE NOTICE '🏪 Establishment types: %', (SELECT COUNT(*) FROM establishment_types);
    RAISE NOTICE '📊 Establishment management functions ready';
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/03_business/establishments.sql