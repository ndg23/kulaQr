# 🔐 Système de Gestion Automatique des Abonnements

## 📋 Vue d'ensemble

Ce système gère automatiquement les abonnements des utilisateurs avec blocage automatique après expiration de la période d'essai ou de l'abonnement payant.

## 🎯 Fonctionnalités

### 1. Types d'abonnements
- **Demo** : 7 jours d'essai gratuit (par défaut à l'inscription)
- **Pro** : 30 jours d'accès payant
- **Premium** : 90 jours d'accès payant

### 2. Blocage automatique
- ✅ Vérification quotidienne automatique (2h du matin UTC)
- ✅ Blocage des comptes expirés
- ✅ Notifications aux administrateurs
- ✅ Logs de tous les blocages

### 3. Système de notifications
- ⚠️ Alerte 2 jours avant expiration
- 🚫 Notification lors du blocage automatique
- 📧 Email aux administrateurs (à configurer)

## 🗂️ Architecture

### Fichiers SQL
```
bdd/subscription_auto_block.sql
```
Contient :
- Fonctions PostgreSQL pour la gestion automatique
- Triggers pour les nouveaux utilisateurs
- Vues pour les statistiques
- Tables de logs et notifications

### API Routes
```
server/api/
├── cron/
│   └── check-subscriptions.post.ts    # Endpoint pour le cron job
└── admin/
    └── subscriptions/
        ├── stats.get.ts                # Statistiques
        └── reactivate.post.ts          # Réactivation manuelle
```

### Pages Admin
```
pages/admin/subscriptions/index.vue     # Dashboard de gestion
```

### Utilitaires
```
server/utils/check-subscriptions.ts     # Fonctions helper
```

## 🚀 Installation

### 1. Exécuter les migrations SQL

```bash
# Se connecter à votre base de données Supabase
psql -h your-db-host -U postgres -d your-database

# Exécuter le fichier SQL
\i bdd/subscription_auto_block.sql
```

Ou via l'interface Supabase :
1. Ouvrir SQL Editor
2. Copier le contenu de `subscription_auto_block.sql`
3. Exécuter

### 2. Configurer les variables d'environnement

```env
# .env
SUPABASE_URL=your-supabase-url
SUPABASE_SERVICE_ROLE_KEY=your-service-key
CRON_SECRET=your-secret-key-for-cron
```

### 3. Configurer Vercel Cron (si déployé sur Vercel)

Le fichier `vercel.json` est déjà configuré :
```json
{
  "crons": [
    {
      "path": "/api/cron/check-subscriptions",
      "schedule": "0 2 * * *"
    }
  ]
}
```

### 4. Alternative : Cron job manuel

Si vous n'utilisez pas Vercel, configurez un cron job système :

```bash
# Ajouter au crontab
0 2 * * * curl -X POST https://your-domain.com/api/cron/check-subscriptions \
  -H "Authorization: Bearer your-cron-secret"
```

## 📊 Utilisation

### Dashboard Admin

Accédez à `/admin/subscriptions` pour :
- 📈 Voir les statistiques en temps réel
- ⚠️ Liste des abonnements expirant bientôt
- 📋 Historique des blocages
- ⚡ Réactiver manuellement des utilisateurs
- 🔄 Déclencher une vérification manuelle

### Fonctions SQL disponibles

#### 1. Vérification et blocage automatique
```sql
-- Exécuter la vérification complète
SELECT * FROM check_and_block_expired_subscriptions();
```

#### 2. Voir les utilisateurs qui vont expirer
```sql
-- Dans les 7 prochains jours
SELECT * FROM get_expiring_subscriptions(7);

-- Dans les 2 prochains jours
SELECT * FROM get_expiring_subscriptions(2);
```

#### 3. Réactiver un utilisateur
```sql
-- Réactiver avec abonnement pro pour 30 jours
SELECT * FROM reactivate_user_subscription(
  'user-uuid',
  'pro',
  30
);

-- Réactiver avec abonnement demo pour 7 jours
SELECT * FROM reactivate_user_subscription(
  'user-uuid',
  'demo',
  7
);
```

#### 4. Statistiques
```sql
-- Vue des statistiques par type d'abonnement
SELECT * FROM subscription_stats;
```

### API Endpoints

#### 1. Vérification manuelle (Admin)
```bash
POST /api/cron/check-subscriptions
Authorization: Bearer {CRON_SECRET}
```

#### 2. Récupérer les statistiques
```bash
GET /api/admin/subscriptions/stats
# Authentification admin requise
```

#### 3. Réactiver un utilisateur
```bash
POST /api/admin/subscriptions/reactivate
Content-Type: application/json

{
  "userId": "uuid",
  "subscriptionTier": "pro",
  "durationDays": 30
}
```

## 📝 Workflow Automatique

### Quotidiennement à 2h du matin (UTC)

1. **Vérification** : Le cron job s'exécute
2. **Détection** : Identification des abonnements expirés
3. **Blocage** : Mise à jour `is_active = false`
4. **Log** : Enregistrement dans `subscription_blocks_log`
5. **Notification** : Création de notifications admin
6. **Alerte** : Détection des abonnements expirant bientôt

### Lors de l'inscription

1. Création du compte avec `is_active = false`
2. `subscription_tier = 'demo'` par défaut
3. `subscription_ends_at = NOW() + 7 days`
4. L'admin doit activer manuellement le compte

### Activation par l'admin

1. Admin active le compte : `is_active = true`
2. L'utilisateur peut se connecter
3. Période de 7 jours commence
4. Après 7 jours, blocage automatique si pas prolongé

## 🔔 Notifications

### Table `admin_notifications`

Les administrateurs reçoivent des notifications pour :
- 🚫 Utilisateurs bloqués automatiquement
- ⚠️ Abonnements expirant dans 2 jours

### Récupérer les notifications non lues
```typescript
const notifications = await getAdminNotifications(true)
```

### Marquer comme lue
```typescript
await markNotificationAsRead(notificationId)
```

## 📈 Logs et Traçabilité

### Table `subscription_blocks_log`

Chaque blocage est enregistré avec :
- Utilisateur concerné
- Date de blocage
- Type d'abonnement
- Jours d'expiration
- Date de réactivation (si applicable)
- Admin qui a réactivé

## 🛠️ Maintenance

### Vérifier le bon fonctionnement

```bash
# Tester la vérification manuelle
curl -X POST https://your-domain.com/api/cron/check-subscriptions \
  -H "Authorization: Bearer your-cron-secret"

# Vérifier les logs Vercel
vercel logs --follow

# Ou consulter le dashboard admin
https://your-domain.com/admin/subscriptions
```

### Nettoyer les vieux logs (optionnel)

```sql
-- Supprimer les logs de plus de 6 mois
DELETE FROM subscription_blocks_log
WHERE blocked_at < NOW() - INTERVAL '6 months';

-- Archiver les notifications lues de plus de 3 mois
DELETE FROM admin_notifications
WHERE is_read = true
AND created_at < NOW() - INTERVAL '3 months';
```

## ⚙️ Configuration

### Modifier les durées par défaut

Dans le fichier SQL (`subscription_auto_block.sql`) :

```sql
-- Changer la durée demo (actuellement 7 jours)
IF NEW.subscription_tier = 'demo' AND NEW.subscription_ends_at IS NULL THEN
  NEW.subscription_ends_at := NOW() + INTERVAL '14 days'; -- Passer à 14 jours
END IF;

-- Changer la durée pro (actuellement 30 jours)
IF NEW.subscription_tier = 'pro' AND NEW.subscription_ends_at IS NULL THEN
  NEW.subscription_ends_at := NOW() + INTERVAL '60 days'; -- Passer à 60 jours
END IF;
```

### Modifier l'heure du cron

Dans `vercel.json` :
```json
{
  "crons": [
    {
      "path": "/api/cron/check-subscriptions",
      "schedule": "0 8 * * *"  // 8h du matin au lieu de 2h
    }
  ]
}
```

## 🐛 Dépannage

### Le cron ne s'exécute pas
1. Vérifier que `vercel.json` est à la racine
2. Vérifier les logs Vercel
3. Tester l'endpoint manuellement avec curl

### Les utilisateurs ne sont pas bloqués
1. Vérifier que la fonction SQL existe : `\df check_and_block_expired_subscriptions`
2. Vérifier les dates d'expiration dans la table users
3. Exécuter manuellement la fonction en SQL

### Erreurs de permissions
1. Vérifier que les fonctions sont `SECURITY DEFINER`
2. Vérifier les RLS policies sur les tables
3. Utiliser la clé `service_role` pour les opérations admin

## 📚 Ressources

- [Documentation Supabase Cron](https://supabase.com/docs/guides/database/cron)
- [Documentation Vercel Cron](https://vercel.com/docs/cron-jobs)
- [PostgreSQL Functions](https://www.postgresql.org/docs/current/sql-createfunction.html)

## 🎯 TODO / Améliorations futures

- [ ] Envoi d'emails automatiques aux utilisateurs
- [ ] SMS de notification 1 jour avant expiration
- [ ] Dashboard analytics détaillé
- [ ] Export des données en CSV
- [ ] Webhooks pour intégrations tierces
- [ ] Mode "grâce" de 3 jours après expiration
- [ ] Renouvellement automatique avec paiement

## 📧 Support

Pour toute question ou problème, contactez l'équipe technique.
