# 📚 Documentation KulaQr

## 📑 Index des Guides

### 🚀 Démarrage

- **[Guide de Démarrage Rapide](./QUICK_START.md)** - Installation en 5 minutes
- **[Configuration des Variables](./ENVIRONMENT_SETUP.md)** - Guide complet pour .env et CRON_SECRET

### 🔧 Fonctionnalités

- **[Gestion des Abonnements](./SUBSCRIPTION_MANAGEMENT.md)** - Système complet de blocage automatique

## 🎯 Par Cas d'Usage

### Je débute le projet

1. **Lire** : [QUICK_START.md](./QUICK_START.md)
2. **Configurer** : [ENVIRONMENT_SETUP.md](./ENVIRONMENT_SETUP.md)
3. **Déployer** : Suivre les étapes du Quick Start

### Je configure les variables d'environnement

**Lire** : [ENVIRONMENT_SETUP.md](./ENVIRONMENT_SETUP.md)

**TL;DR :**
```bash
node scripts/generate-cron-secret.js
# Copier la clé dans .env
```

### Je veux comprendre le système d'abonnements

**Lire** : [SUBSCRIPTION_MANAGEMENT.md](./SUBSCRIPTION_MANAGEMENT.md)

**Architecture :**
- 7 jours demo (par défaut)
- 30 jours pro
- 90 jours premium
- Blocage automatique quotidien à 2h UTC
- Notifications admin

### J'ai une erreur

**Consulter** :
- Section "Dépannage" dans [SUBSCRIPTION_MANAGEMENT.md](./SUBSCRIPTION_MANAGEMENT.md)
- Section "Problèmes Courants" dans [QUICK_START.md](./QUICK_START.md)

## 🛠️ Scripts Utiles

```bash
# Générer CRON_SECRET
node scripts/generate-cron-secret.js

# Tester le système
node scripts/test-subscription-system.js

# Installer le système (si psql disponible)
./scripts/install-subscription-system.sh
```

## 📊 Fichiers SQL

```
bdd/
├── subscription_auto_block.sql           # Fonctions principales
└── migrations/
    └── migration_update_subscriptions_to_demo.sql  # Migration users existants
```

## 🔑 Variables Requises

| Variable | Description | Où le trouver |
|----------|-------------|---------------|
| `SUPABASE_URL` | URL de votre projet | Supabase Dashboard |
| `SUPABASE_KEY` | Clé publique anon | Supabase → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Clé admin | Supabase → Settings → API |
| `CRON_SECRET` | Sécurité cron job | Générer avec le script |

## 📖 Ressources Externes

- [Supabase Documentation](https://supabase.com/docs)
- [Vercel Cron Jobs](https://vercel.com/docs/cron-jobs)
- [Nuxt 3 Documentation](https://nuxt.com/docs)

## 🤝 Contribution

Pour contribuer à la documentation :

1. Créer une branche : `git checkout -b docs/nouvelle-feature`
2. Éditer les fichiers markdown
3. Commit : `git commit -m "docs: description"`
4. Push : `git push origin docs/nouvelle-feature`
5. Créer une Pull Request

## 📝 Format des Docs

- **Titre H1** : Un seul par fichier
- **Emojis** : Pour la clarté visuelle
- **Code blocks** : Toujours spécifier le langage
- **Sections** : Bien structurées avec H2, H3
- **Exemples** : Concrets et testables

## 🔄 Mise à Jour

**Dernière mise à jour** : 25 novembre 2025

**Version du système** : 1.0.0

**Auteurs** : Équipe KulaQr
