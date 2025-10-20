# 🗄️ Base de Données KulaQR

Structure organisée des fichiers SQL pour le système de gestion de restaurant KulaQR.

## ⚠️ Corrections Récentes

**Octobre 2025** - Grandes corrections appliquées :
- ✅ **Élimination des duplications** : Fonctions répétées supprimées
- ✅ **Centralisation** : Toutes les fonctions utilitaires dans `01_core/functions.sql`
- ✅ **Nettoyage** : Modules spécialisés ne contiennent que leurs responsabilités
- 📖 **[Voir les détails](./DUPLICATIONS_FIX.md)**

## 📁 Structure des Dossiers

```
database/
├── README.md                    # 📖 Cette documentation
├── schema.sql                  # 🏗️ Schéma principal complet
├── 01_core/                    # ⚙️ Noyau de l'application
│   ├── tables.sql              # 📋 Tables principales
│   ├── indexes.sql             # 🔍 Index de performance
│   ├── functions.sql           # 🛠️ Fonctions utilitaires
│   └── triggers.sql            # ⚡ Triggers automatiques
├── 02_auth/                    # 🔐 Authentification & Utilisateurs
│   ├── users.sql               # 👥 Gestion des utilisateurs
│   ├── staff.sql               # 👨‍🍳 Gestion du personnel
│   └── policies.sql            # 🛡️ Politiques RLS
├── 03_business/                # 💼 Logique Métier
│   ├── establishments.sql      # 🏪 Établissements
│   ├── products.sql            # 🍽️ Produits et catégories
│   ├── orders.sql              # 📝 Commandes
│   └── tables_system.sql       # 🪑 Système de tables
├── 04_analytics/               # 📊 Analyses & Statistiques
│   ├── views.sql               # 👁️ Vues principales
│   ├── dashboard_views.sql     # 📈 Vues du dashboard
│   ├── qr_analytics.sql        # 📱 Analyses QR
│   └── activity_tracking.sql   # 📋 Suivi des activités
├── 05_system/                  # ⚙️ Configuration Système
│   ├── settings.sql            # 🔧 Paramètres système
│   └── maintenance.sql         # 🔧 Scripts de maintenance
├── 06_data/                    # 🌱 Données & Seeds
│   ├── seeds.sql               # 🌱 Données initiales
│   ├── establishment_types.sql # 🏷️ Types d'établissements
│   └── sample_data.sql         # 🧪 Données de test
└── 07_migrations/              # 🚀 Scripts de Migration
    ├── create_admin.sql        # 👑 Création administrateur
    ├── fixes/                  # 🐛 Corrections
    │   ├── fix_staff_policies.sql
    │   ├── fix_user_metadata_trigger.sql
    │   └── update_existing_users_names.sql
    └── updates/                # ⬆️ Mises à jour futures
```

## 🚀 Ordre d'Exécution

Pour initialiser une nouvelle base de données, exécutez les fichiers dans cet ordre :

### 1. Installation Initiale
```sql
-- Schéma principal (contient tout)
schema.sql
```

### 2. Données de Base
```sql
-- Types d'établissements
06_data/establishment_types.sql

-- Données initiales
06_data/seeds.sql
```

### 3. Configuration Système
```sql
-- Paramètres système
05_system/settings.sql
```

### 4. Création Administrateur
```sql
-- Premier administrateur
07_migrations/create_admin.sql
```

## 📋 Description des Modules

### 01_core/ - Noyau de l'Application
- **`tables.sql`** : Tables principales (users, establishments, products, orders, etc.)
- **`indexes.sql`** : Index de performance pour optimiser les requêtes
- **`functions.sql`** : Fonctions utilitaires (génération de slugs, formatage, etc.)
- **`triggers.sql`** : Triggers automatiques (updated_at, génération de données)

### 02_auth/ - Authentification & Utilisateurs
- **`users.sql`** : Gestion des utilisateurs et profils
- **`staff.sql`** : Système de personnel avec PIN
- **`policies.sql`** : Politiques Row Level Security (RLS)

### 03_business/ - Logique Métier
- **`establishments.sql`** : Gestion des établissements
- **`products.sql`** : Produits et catégories
- **`orders.sql`** : Système de commandes
- **`tables_system.sql`** : Gestion des tables physiques et QR codes

### 04_analytics/ - Analyses & Statistiques
- **`views.sql`** : Vues pour statistiques générales
- **`dashboard_views.sql`** : Vues spécifiques au tableau de bord manager
- **`qr_analytics.sql`** : Analyses des scans QR
- **`activity_tracking.sql`** : Suivi des activités utilisateurs

### 05_system/ - Configuration Système
- **`settings.sql`** : Paramètres système configurables
- **`maintenance.sql`** : Scripts de maintenance et nettoyage

### 06_data/ - Données & Seeds
- **`seeds.sql`** : Données initiales et fonctions de génération
- **`establishment_types.sql`** : Types d'établissements prédéfinis
- **`sample_data.sql`** : Données de test pour développement

### 07_migrations/ - Scripts de Migration
- **`create_admin.sql`** : Création du premier administrateur
- **`fixes/`** : Corrections de bugs et problèmes
- **`updates/`** : Mises à jour futures et évolutions

## 🔧 Scripts Utiles

### Corrections Appliquées
- **fix_staff_policies.sql** : Correction récursion infinie dans les politiques RLS du staff
- **fix_user_metadata_trigger.sql** : Amélioration du trigger d'authentification
- **update_existing_users_names.sql** : Mise à jour des noms d'utilisateurs existants

### Fonctions Importantes
- `is_admin_user()` : Vérification des droits administrateur
- `generate_establishment_slug()` : Génération automatique de slugs
- `get_simple_stats()` : Statistiques simplifiées pour managers
- `log_activity()` : Suivi des activités utilisateurs

## 📊 Vues Principales

### Statistiques Manager
- `stats_today` : Commandes du jour
- `stats_week` : Commandes de la semaine
- `stats_month` : Commandes du mois
- `top_products` : Produits populaires

### Analyses Globales
- `admin_statistics` : Statistiques administrateur
- `popular_establishments` : Établissements populaires
- `qr_scan_stats` : Statistiques des scans QR

## 🔒 Sécurité

- **Row Level Security (RLS)** activé sur toutes les tables
- **Politiques d'accès** basées sur les rôles (admin, owner, staff)
- **Authentification automatique** via Supabase Auth
- **Logs d'activité** pour audit et traçabilité

## 🚀 Déploiement

### Environnements
- **Development** : Utiliser `sample_data.sql` pour des données de test
- **Production** : Exécuter uniquement les scripts essentiels

### Migration
1. Sauvegarder la base existante
2. Exécuter les nouveaux scripts dans l'ordre
3. Vérifier l'intégrité des données
4. Tester les fonctionnalités critiques

## 📞 Support

Pour toute question concernant la structure de la base de données :
- Vérifier d'abord ce README
- Consulter les commentaires dans les fichiers SQL
- Créer une issue pour les améliorations proposées

---

**Dernière mise à jour :** Octobre 2025
**Version :** 1.0.0</content>
<parameter name="filePath">/Users/macbookpro/Desktop/Ndong/kulaQr/database/README.md