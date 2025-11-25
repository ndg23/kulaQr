# 🚀 Guide de Démarrage Rapide - Système d'Abonnements

## ⚡ Installation en 5 minutes

### 1️⃣ Générer la clé secrète

```bash
node scripts/generate-cron-secret.js
```

✅ La clé sera générée et copiée dans votre presse-papier !

### 2️⃣ Configurer les variables d'environnement

```bash
# Copier le template
cp .env.example .env

# Éditer et coller votre CRON_SECRET
nano .env
```

### 3️⃣ Installer les fonctions SQL

```bash
# Via psql
psql $DATABASE_URL < bdd/subscription_auto_block.sql

# Ou via Supabase Dashboard
# SQL Editor → Coller le contenu → Run
```

### 4️⃣ Migrer les utilisateurs existants

```bash
psql $DATABASE_URL < bdd/migrations/migration_update_subscriptions_to_demo.sql
```

### 5️⃣ Tester

```bash
# Test des fonctions SQL
node scripts/test-subscription-system.js

# Test de l'API locale
npm run dev
curl -X POST http://localhost:3000/api/cron/check-subscriptions \
  -H "Authorization: Bearer $(grep CRON_SECRET .env | cut -d '=' -f2)"
```

## ☁️ Déploiement Vercel

### 1. Configurer les variables

**Via CLI:**
```bash
vercel env add CRON_SECRET
# Coller la valeur générée
# Sélectionner: Production, Preview, Development
```

**Ou via Dashboard:**
- Settings → Environment Variables → Add
- Name: `CRON_SECRET`
- Value: `votre-clé-générée`
- ✅ Production, Preview, Development

### 2. Déployer

```bash
vercel --prod
```

### 3. Vérifier le cron

- Dashboard Vercel → Projet → Cron Jobs
- Devrait afficher: `check-subscriptions` à `0 2 * * *`

## 🎯 Utilisation

### Dashboard Admin

Accédez à : `https://your-domain.com/admin/subscriptions`

**Fonctionnalités :**
- 📊 Statistiques en temps réel
- ⚠️ Liste des abonnements expirant bientôt
- 📋 Historique des blocages
- ⚡ Réactivation manuelle
- 🔄 Vérification manuelle

### Nouveau utilisateur

1. User s'inscrit → `subscription_tier: 'demo'`, `is_active: false`
2. Admin active le compte → Période de 7 jours commence
3. Après 7 jours → Blocage automatique

### Prolonger un abonnement

**Via Dashboard:**
1. Admin/Subscriptions → Utilisateur expirant
2. Cliquer "Prolonger"
3. Choisir: Demo (7j), Pro (30j), Premium (90j)
4. Valider

**Via SQL:**
```sql
SELECT * FROM reactivate_user_subscription(
  'user-uuid',
  'pro',
  30
);
```

## 🔍 Vérifications

### Fonctions SQL installées ?

```sql
\df check_and_block_expired_subscriptions
\df get_expiring_subscriptions
\df reactivate_user_subscription
```

### Tables créées ?

```sql
\dt subscription_blocks_log
\dt admin_notifications
```

### Variables configurées ?

```bash
# Local
grep CRON_SECRET .env

# Vercel
vercel env ls
```

### Cron actif ?

```bash
# Vercel Dashboard → Logs
# Devrait montrer exécution quotidienne à 2h UTC
```

## 📚 Commandes Utiles

```bash
# Générer nouvelle clé
node scripts/generate-cron-secret.js

# Tester le système
node scripts/test-subscription-system.js

# Déclencher manuellement (local)
curl -X POST http://localhost:3000/api/cron/check-subscriptions \
  -H "Authorization: Bearer YOUR_SECRET"

# Déclencher manuellement (prod)
curl -X POST https://your-domain.com/api/cron/check-subscriptions \
  -H "Authorization: Bearer YOUR_SECRET"

# Voir les stats
curl https://your-domain.com/api/admin/subscriptions/stats

# Logs Vercel
vercel logs --follow
```

## 🐛 Problèmes Courants

| Erreur | Solution |
|--------|----------|
| `CRON_SECRET not set` | Générer et configurer la clé |
| `Unauthorized` | Vérifier la clé dans les headers |
| `Database error` | Installer les fonctions SQL |
| `Function not found` | Exécuter subscription_auto_block.sql |
| Cron ne s'exécute pas | Vérifier vercel.json et redéployer |

## 📖 Documentation Complète

- 📘 [Guide Complet](./SUBSCRIPTION_MANAGEMENT.md)
- 🔐 [Configuration Variables](./ENVIRONMENT_SETUP.md)

## ✅ Checklist de Validation

- [ ] `CRON_SECRET` généré et configuré
- [ ] Fonctions SQL installées
- [ ] Migration des users effectuée
- [ ] Tests locaux passés
- [ ] Variables Vercel configurées
- [ ] Déploiement effectué
- [ ] Dashboard accessible
- [ ] Premier cron exécuté (attendre 2h UTC ou tester manuellement)

**Tout est vert ? Vous êtes prêt ! 🎉**
