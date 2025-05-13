# KulaQr

> Une solution moderne pour la digitalisation des restaurants

![Version](https://img.shields.io/badge/version-0.6.0-blue.svg)
![Nuxt Version](https://img.shields.io/badge/nuxt-3.8.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

## 📋 À propos

KulaQr est une plateforme complète de digitalisation pour les restaurants, cafés et établissements de restauration. La solution permet aux établissements de créer facilement des menus numériques accessibles via QR codes, de gérer les commandes en temps réel et d'analyser leurs performances commerciales.

## ✨ Fonctionnalités principales

### Pour les restaurateurs

- **Tableau de bord intuitif**
  - Interface inspirée de Twitter pour une prise en main rapide
  - Statistiques en temps réel sur les ventes et performances
  - Analyse des tendances par catégorie et produit

- **Gestion de menu simplifiée**
  - Création et organisation intuitive des catégories et produits
  - Personnalisation avec icônes et images
  - Modification en temps réel reflétée instantanément sur les menus clients

- **Système de commandes complet**
  - Suivi des commandes en temps réel
  - Notifications instantanées pour les nouvelles commandes
  - Gestion des statuts de commande avec feedback client

- **Personnalisation avancée**
  - QR codes personnalisables et exportables en plusieurs formats
  - Adaptation aux différents types d'établissements (restaurant, café, fast-food, etc.)
  - Options de personnalisation visuelle

### Pour les clients

- **Menu digital moderne**
  - Interface utilisateur fluide et intuitive
  - Expérience mobile optimisée
  - Affichage clair des catégories et produits
  - Fonctionnalité de recherche et filtrage

- **Commande simplifiée**
  - Système de panier intuitif
  - Personnalisation des articles
  - Paiement intégré sécurisé
  - Suivi de commande en temps réel

## 🛠️ Technologies

- **Frontend**: Nuxt.js 3.8.0, Vue.js, TailwindCSS, Headless UI
- **Backend**: Supabase (PostgreSQL, Authentication, Storage)
- **Authentification**: Email/Password, OAuth Google
- **État global**: Pinia
- **Types**: TypeScript

## 🚀 Installation

```bash
# Cloner le dépôt
git clone https://github.com/votre-organisation/kulaqr.git

# Naviguer dans le dossier
cd kulaqr

# Installer les dépendances
npm install

# Configurer les variables d'environnement
cp .env.example .env

# Lancer le serveur de développement
npm run dev
```

## 🔧 Configuration

1. Créez un projet Supabase sur [supabase.com](https://supabase.com)
2. Récupérez votre URL et clé API anonyme dans les paramètres du projet
3. Configurez les variables d'environnement dans votre fichier `.env`:

```
NUXT_PUBLIC_SUPABASE_URL=votre-url-supabase
NUXT_PUBLIC_SUPABASE_KEY=votre-cle-api-supabase
```

## 📊 Structure du projet

```
kulaqr/
├── assets/            # Ressources statiques (images, fonts)
├── components/        # Composants Vue réutilisables
├── composables/       # Composables Vue
├── layouts/           # Layouts de l'application
├── middleware/        # Middleware Nuxt
├── pages/             # Pages de l'application
├── plugins/           # Plugins Nuxt
├── public/            # Fichiers publics
├── server/            # Serveur Nitro et API
├── stores/            # Stores Pinia
├── types/             # Types TypeScript
├── utils/             # Fonctions utilitaires
├── app.vue            # Point d'entrée de l'application
├── nuxt.config.ts     # Configuration Nuxt
└── tsconfig.json      # Configuration TypeScript
```

## 📱 Captures d'écran

*[À venir]*

## 🌐 Démonstration

Visitez notre [site de démonstration](https://demo.kulaqr.com) pour tester KulaQr.

## 🔒 Authentification

KulaQr utilise Supabase Auth pour l'authentification:

- Connexion par email/mot de passe
- Connexion avec Google (OAuth)
- Gestion des sessions sécurisée
- Row Level Security (RLS) pour la protection des données

## 📈 Tableau de bord analytique

Le tableau de bord KulaQr offre aux restaurateurs:

- Vue d'ensemble des ventes quotidiennes/hebdomadaires/mensuelles
- Analyse des performances par catégorie
- Suivi des produits populaires
- Distribution horaire des commandes
- Métriques de fidélisation client

## 📱 QR Codes et menu client

- Génération de QR codes personnalisés
- Export en différents formats (PNG, SVG, PDF)
- Interface client optimisée pour mobile
- Personnalisation visuelle du menu

## 🛣️ Feuille de route

- [ ] Application mobile native pour les restaurateurs
- [ ] Intégration avec les systèmes de paiement populaires
- [ ] Système de réservation de tables
- [ ] Programme de fidélité
- [ ] API publique pour intégrations tierces

## 👥 Contribution

Les contributions sont les bienvenues! Veuillez consulter notre [guide de contribution](CONTRIBUTING.md) pour plus d'informations.

## 📄 Licence

KulaQr est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Support

Pour toute question ou assistance, contactez-nous à support@kulaqr.com.