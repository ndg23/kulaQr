------------------------------------------
-- Données initiales pour les types d'établissements
------------------------------------------
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
('Hotel restaurant', 'hotel-restaurant', '🏨', 'Restaurants situés dans des hôtels');

------------------------------------------
-- Données de test (uniquement en développement)
------------------------------------------
-- Ajoutez ici vos données de test si nécessaire