-- ==========================================
-- KULA QR - SAMPLE DATA
-- ==========================================
-- Données d'exemple pour les tests et démonstrations
-- Fait partie du module 06_data

-- ==========================================
-- SAMPLE ESTABLISHMENTS
-- ==========================================

-- Insert sample establishments
INSERT INTO establishments (
    name,
    slug,
    description,
    address,
    phone,
    opening_hours,
    type_id,
    currency,
    subscription_type,
    is_active
) VALUES
(
    'Le Jardin Gourmand',
    'le-jardin-gourmand',
    'Restaurant français traditionnel avec une touche moderne',
    '15 Rue de la Paix, Dakar',
    '+221 78 383 55 97',
    'Lundi-Vendredi: 12h-14h30, 19h-22h | Samedi: 12h-15h, 19h-23h | Dimanche: 12h-15h, 19h-22h',
    (SELECT id FROM establishment_types WHERE slug = 'restaurant'),
    'XOF',
    'premium',
    true
),
(
    'Café Central',
    'cafe-central',
    'Café cosy au cœur de Dakar avec wifi gratuit',
    '25 Avenue Léopold Sédar Senghor, Dakar',
    '+221 78 373 90 55',
    'Lundi-Dimanche: 7h-20h',
    (SELECT id FROM establishment_types WHERE slug = 'cafe'),
    'XOF',
    'basic',
    true
),
(
    'Pizzeria Bella Italia',
    'pizzeria-bella-italia',
    'Authentique cuisine italienne depuis 1995',
    '8 Rue Félix Faure, Dakar',
    '+221 78 383 55 97',
    'Lundi-Dimanche: 11h-23h',
    (SELECT id FROM establishment_types WHERE slug = 'pizzeria'),
    'XOF',
    'basic',
    true
)
ON CONFLICT (slug) DO NOTHING;

-- ==========================================
-- SAMPLE CATEGORIES
-- ==========================================

-- Insert sample categories for each establishment
INSERT INTO categories (establishment_id, name, description, order_number, is_active) VALUES
-- Le Jardin Gourmand categories
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 'Entrées', 'Nos délicieuses entrées', 1, true),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 'Plats principaux', 'Spécialités de la maison', 2, true),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 'Desserts', 'Douceurs sucrées', 3, true),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 'Boissons', 'Vins et boissons', 4, true),

-- Café Central categories
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 'Cafés', 'Notre sélection de cafés', 1, true),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 'Thés', 'Thés et infusions', 2, true),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 'Pâtisseries', 'Gâteaux et viennoiseries', 3, true),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 'Salades', 'Salades fraîches', 4, true),

-- Pizzeria Bella Italia categories
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 'Pizzas classiques', 'Nos pizzas traditionnelles', 1, true),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 'Pizzas spéciales', 'Créations du chef', 2, true),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 'Pâtes', 'Pâtes fraîches maison', 3, true),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 'Desserts', 'Tiramisu et cannoli', 4, true)
ON CONFLICT (establishment_id, name) DO NOTHING;

-- ==========================================
-- SAMPLE PRODUCTS
-- ==========================================

-- Insert sample products for Le Jardin Gourmand
INSERT INTO products (category_id, establishment_id, name, description, price, is_available, order_number) VALUES
-- Entrées
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Entrées'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Foie gras mi-cuit', 'Foie gras de canard mi-cuit avec chutney de figues', 8500, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Entrées'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Escargots à la bourguignonne', 'Escargots de Bourgogne au beurre persillé', 6500, true, 2),

-- Plats principaux
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Plats principaux'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Boeuf bourguignon', 'Boeuf braisé au vin rouge avec légumes', 12500, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Plats principaux'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Saumon grillé', 'Saumon frais grillé avec sauce hollandaise', 11500, true, 2),

-- Desserts
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Desserts'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Crème brûlée', 'Crème vanille avec caramel croquant', 4500, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Desserts'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Tarte Tatin', 'Tarte aux pommes caramélisées', 4800, true, 2),

-- Boissons
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Boissons'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Vin rouge Bordeaux', 'Château Margaux 2015', 25000, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Boissons'),
 (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'),
 'Jus d''orange frais', 'Pressé minute', 2500, true, 2)
ON CONFLICT (category_id, name) DO NOTHING;

-- Insert sample products for Café Central
INSERT INTO products (category_id, establishment_id, name, description, price, is_available, order_number) VALUES
-- Cafés
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Cafés'),
 (SELECT id FROM establishments WHERE slug = 'cafe-central'),
 'Expresso', 'Café expresso traditionnel', 1500, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Cafés'),
 (SELECT id FROM establishments WHERE slug = 'cafe-central'),
 'Cappuccino', 'Café au lait avec mousse de lait', 2000, true, 2),

-- Pâtisseries
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Pâtisseries'),
 (SELECT id FROM establishments WHERE slug = 'cafe-central'),
 'Croissant au beurre', 'Croissant pur beurre croustillant', 1200, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Pâtisseries'),
 (SELECT id FROM establishments WHERE slug = 'cafe-central'),
 'Pain au chocolat', 'Viennoiserie au chocolat', 1300, true, 2)
ON CONFLICT (category_id, name) DO NOTHING;

-- Insert sample products for Pizzeria Bella Italia
INSERT INTO products (category_id, establishment_id, name, description, price, is_available, order_number) VALUES
-- Pizzas classiques
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Pizzas classiques'),
 (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'),
 'Margherita', 'Tomate, mozzarella, basilic frais', 7500, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Pizzas classiques'),
 (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'),
 'Quattro Stagioni', 'Tomate, mozzarella, jambon, champignons, artichauts, olives', 9500, true, 2),

-- Pizzas spéciales
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Pizzas spéciales'),
 (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'),
 'Calzone', 'Pizza pliée farcie au jambon et fromage', 8500, true, 1),

-- Pâtes
((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Pâtes'),
 (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'),
 'Spaghetti Carbonara', 'Spaghetti à la crème, lardons, parmesan', 6800, true, 1),

((SELECT id FROM categories WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Pâtes'),
 (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'),
 'Lasagne Bolognaise', 'Lasagne à la bolognaise maison', 7200, true, 2)
ON CONFLICT (category_id, name) DO NOTHING;

-- ==========================================
-- SAMPLE TABLES
-- ==========================================

-- Insert sample tables for each establishment
INSERT INTO tables (establishment_id, table_number, zone_name, capacity, status) VALUES
-- Le Jardin Gourmand tables
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 1, 'Salle principale', 4, 'available'),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 2, 'Salle principale', 4, 'available'),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 3, 'Salle principale', 2, 'available'),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 4, 'Terrasse', 6, 'available'),
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 5, 'Terrasse', 4, 'available'),

-- Café Central tables
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 1, 'Intérieur', 2, 'available'),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 2, 'Intérieur', 4, 'available'),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 3, 'Terrasse', 6, 'available'),

-- Pizzeria Bella Italia tables
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 1, 'Salle principale', 4, 'available'),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 2, 'Salle principale', 4, 'available'),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 3, 'Salle principale', 6, 'available'),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 4, 'Privé', 8, 'available')
ON CONFLICT (establishment_id, table_number) DO NOTHING;

-- ==========================================
-- SAMPLE ORDERS
-- ==========================================

-- Insert sample completed orders
INSERT INTO orders (establishment_id, table_number, status, total_amount, payment_status, created_at, updated_at) VALUES
((SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand'), 1, 'completed', 17000, 'paid', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
((SELECT id FROM establishments WHERE slug = 'cafe-central'), 2, 'completed', 3500, 'paid', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
((SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia'), 3, 'completed', 14200, 'paid', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours')
ON CONFLICT DO NOTHING;

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
-- Order 1 items (Le Jardin Gourmand)
((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND table_number = 1 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Foie gras mi-cuit'),
 1, 8500, 8500),

((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND table_number = 1 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'le-jardin-gourmand') AND name = 'Boeuf bourguignon'),
 1, 12500, 12500),

-- Order 2 items (Café Central)
((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND table_number = 2 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Cappuccino'),
 1, 2000, 2000),

((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND table_number = 2 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'cafe-central') AND name = 'Croissant au beurre'),
 1, 1200, 1200),

-- Order 3 items (Pizzeria Bella Italia)
((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND table_number = 3 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Margherita'),
 1, 7500, 7500),

((SELECT id FROM orders WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND table_number = 3 LIMIT 1),
 (SELECT id FROM products WHERE establishment_id = (SELECT id FROM establishments WHERE slug = 'pizzeria-bella-italia') AND name = 'Spaghetti Carbonara'),
 1, 6700, 6700)
ON CONFLICT DO NOTHING;

-- ==========================================
-- UPDATE COUNTERS
-- ==========================================

-- Update product orders_count
UPDATE products
SET orders_count = (
    SELECT COUNT(*)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    WHERE oi.product_id = products.id AND o.status = 'completed'
);

-- Update category product_count
UPDATE categories
SET product_count = (
    SELECT COUNT(*)
    FROM products p
    WHERE p.category_id = categories.id AND p.is_available = true
);

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '✅ SAMPLE DATA CREATED SUCCESSFULLY!';
    RAISE NOTICE '🏪 Sample establishments: %', (SELECT COUNT(*) FROM establishments WHERE slug IN ('le-jardin-gourmand', 'cafe-central', 'pizzeria-bella-italia'));
    RAISE NOTICE '🍽️ Sample products: %', (SELECT COUNT(*) FROM products WHERE establishment_id IN (SELECT id FROM establishments WHERE slug IN ('le-jardin-gourmand', 'cafe-central', 'pizzeria-bella-italia')));
    RAISE NOTICE '📝 Sample orders: %', (SELECT COUNT(*) FROM orders WHERE establishment_id IN (SELECT id FROM establishments WHERE slug IN ('le-jardin-gourmand', 'cafe-central', 'pizzeria-bella-italia')));
END $$;</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/06_data/sample_data.sql