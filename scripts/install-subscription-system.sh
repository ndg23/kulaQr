#!/bin/bash

# Script d'installation du système de gestion des abonnements
# Usage: ./install-subscription-system.sh

echo "============================================"
echo "🚀 Installation du Système d'Abonnements"
echo "============================================"
echo ""

# Vérifier si les variables d'environnement sont configurées
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo "❌ Erreur: Variables d'environnement manquantes"
    echo "   Assurez-vous que SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont définies"
    exit 1
fi

echo "✅ Variables d'environnement détectées"
echo ""

# Demander confirmation
read -p "⚠️  Cette installation va créer des tables et fonctions dans votre base de données. Continuer? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Installation annulée"
    exit 1
fi

echo ""
echo "📊 Installation en cours..."
echo ""

# Exécuter le fichier SQL
echo "1️⃣  Création des fonctions SQL..."
psql "$DATABASE_URL" < bdd/subscription_auto_block.sql

if [ $? -eq 0 ]; then
    echo "   ✅ Fonctions SQL créées avec succès"
else
    echo "   ❌ Erreur lors de la création des fonctions SQL"
    exit 1
fi

echo ""
echo "2️⃣  Mise à jour des utilisateurs existants..."

# Script SQL pour mettre à jour les utilisateurs existants
psql "$DATABASE_URL" <<SQL
-- Mettre à jour les utilisateurs existants sans subscription_tier
UPDATE users
SET 
  subscription_tier = 'demo',
  subscription_ends_at = NOW() + INTERVAL '7 days'
WHERE 
  subscription_tier IS NULL 
  OR subscription_tier = 'free';

-- Afficher le nombre d'utilisateurs mis à jour
SELECT COUNT(*) as updated_users FROM users WHERE subscription_tier = 'demo';
SQL

echo "   ✅ Utilisateurs existants mis à jour"

echo ""
echo "3️⃣  Vérification de l'installation..."

# Vérifier que les fonctions existent
psql "$DATABASE_URL" <<SQL
\df check_and_block_expired_subscriptions
\df get_expiring_subscriptions
\df reactivate_user_subscription
SQL

echo ""
echo "============================================"
echo "✅ INSTALLATION TERMINÉE AVEC SUCCÈS"
echo "============================================"
echo ""
echo "📝 Prochaines étapes:"
echo ""
echo "1. Vérifier le fichier vercel.json pour le cron job"
echo "2. Configurer la variable CRON_SECRET dans .env"
echo "3. Accéder au dashboard: /admin/subscriptions"
echo "4. Tester manuellement: curl -X POST https://your-domain.com/api/cron/check-subscriptions"
echo ""
echo "📖 Documentation complète: docs/SUBSCRIPTION_MANAGEMENT.md"
echo ""
