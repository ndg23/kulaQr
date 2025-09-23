-- ==========================================
-- KULA QR - SEED DATA
-- ==========================================
-- Initial data for the database
-- Execute after schema.sql

-- ==========================================
-- ESTABLISHMENT TYPES
-- ==========================================

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
-- UTILITY FUNCTIONS
-- ==========================================

-- Function to generate sample data for testing
CREATE OR REPLACE FUNCTION generate_sample_orders(establishment_id UUID, num_orders INTEGER DEFAULT 10)
RETURNS VOID AS $$
DECLARE
    product_record RECORD;
    order_id UUID;
    product_count INTEGER;
    random_table INTEGER;
    random_status TEXT;
    statuses TEXT[] := ARRAY['pending', 'preparing', 'completed'];
BEGIN
    -- Get count of products for this establishment
    SELECT COUNT(*) INTO product_count 
    FROM products 
    WHERE establishment_id = generate_sample_orders.establishment_id;
    
    -- Only proceed if there are products
    IF product_count > 0 THEN
        -- Create sample orders
        FOR i IN 1..num_orders LOOP
            -- Random table number between 1 and 20
            random_table := floor(random() * 20) + 1;
            
            -- Random status
            random_status := statuses[floor(random() * 3) + 1];
            
            -- Insert order
            INSERT INTO orders (establishment_id, table_number, status, created_at)
            VALUES (
                generate_sample_orders.establishment_id, 
                random_table, 
                random_status,
                NOW() - (random() * INTERVAL '24 hours')
            )
            RETURNING id INTO order_id;
            
            -- Add 1-5 random products to this order
            FOR j IN 1..floor(random() * 5) + 1 LOOP
                -- Get a random product
                SELECT * INTO product_record
                FROM products
                WHERE establishment_id = generate_sample_orders.establishment_id
                ORDER BY RANDOM()
                LIMIT 1;
                
                -- Add product to order
                IF product_record.id IS NOT NULL THEN
                    INSERT INTO order_items (
                        order_id, 
                        product_id, 
                        quantity, 
                        unit_price, 
                        subtotal
                    )
                    VALUES (
                        order_id,
                        product_record.id,
                        floor(random() * 3) + 1,  -- Quantity 1-3
                        product_record.price,
                        (floor(random() * 3) + 1) * product_record.price  -- quantity * price
                    );
                    
                    -- Update order total
                    UPDATE orders
                    SET total_amount = total_amount + ((floor(random() * 3) + 1) * product_record.price)
                    WHERE id = order_id;
                    
                    -- Update product orders_count
                    UPDATE products
                    SET orders_count = orders_count + 1
                    WHERE id = product_record.id;
                END IF;
            END LOOP;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION MESSAGE
-- ==========================================

DO $$
BEGIN
    RAISE NOTICE '🌱 SEED DATA INSERTED SUCCESSFULLY!';
    RAISE NOTICE '📋 Establishment types: %', (SELECT COUNT(*) FROM establishment_types);
    RAISE NOTICE '🔧 Utility functions created';
    RAISE NOTICE '✅ Database ready for use!';
END $$;