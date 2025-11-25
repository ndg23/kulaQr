# 🔐 Configuration des Variables d'Environnement

## 📋 Variables Requises

### 1. CRON_SECRET

**Pourquoi ?** Sécurise l'endpoint `/api/cron/check-subscriptions` pour éviter les appels non autorisés.

**Comment générer ?**

```bash
# Méthode 1: Node.js (recommandée)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Méthode 2: OpenSSL
openssl rand -hex 32

# Méthode 3: Online
# Visitez https://www.random.org/strings/
```

**Exemple de résultat :**
```
a7f3c9e2b1d4f8a6c3e7b9d2f4a8c6e3b7d9f2a4c8e6b3d7f9a2c4e8b6d3f7a9
```

## ⚙️ Configuration en Local

### 1. Créer le fichier .env

```bash
cp .env.example .env
```

### 2. Générer la clé CRON_SECRET

```bash
# Générer et copier dans le presse-papier (macOS)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))" | pbcopy

# Ou simplement afficher
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3. Éditer .env

```bash
# Ouvrir avec votre éditeur
nano .env
# ou
code .env
```

### 4. Coller les valeurs

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=eyJhbGc...votre-anon-key
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...votre-service-key
CRON_SECRET=a7f3c9e2b1d4f8a6c3e7b9d2f4a8c6e3
```

## ☁️ Configuration sur Vercel

### Via l'interface web

1. **Aller dans votre projet Vercel**
2. **Settings** → **Environment Variables**
3. **Add New**

Pour chaque variable :

| Variable | Valeur | Environnements |
|----------|--------|----------------|
| `CRON_SECRET` | `votre-clé-générée` | Production, Preview, Development ✅ |
| `SUPABASE_URL` | `https://...` | Production, Preview, Development ✅ |
| `SUPABASE_KEY` | `eyJhbGc...` | Production, Preview, Development ✅ |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGc...` | Production ✅ |

### Via CLI

```bash
# Se connecter à Vercel
vercel login

# Lier le projet
vercel link

# Ajouter les variables
vercel env add CRON_SECRET
# Coller la valeur quand demandé
# Sélectionner: Production, Preview, Development

vercel env add SUPABASE_URL
vercel env add SUPABASE_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY
```

## 🧪 Tester la Configuration

### 1. En local

```bash
# Démarrer le serveur
npm run dev

# Tester l'endpoint (dans un autre terminal)
curl -X POST http://localhost:3000/api/cron/check-subscriptions \
  -H "Authorization: Bearer $(grep CRON_SECRET .env | cut -d '=' -f2)"
```

### 2. En production

```bash
# Remplacer YOUR_DOMAIN et YOUR_SECRET
curl -X POST https://YOUR_DOMAIN.vercel.app/api/cron/check-subscriptions \
  -H "Authorization: Bearer YOUR_SECRET"
```

**Réponse attendue (succès) :**
```json
{
  "success": true,
  "timestamp": "2025-11-25T...",
  "result": {
    "success": true,
    "blocked_users": 0,
    "expiring_soon": 2,
    "message": "0 utilisateur(s) bloqué(s), 2 abonnement(s) expire(nt) bientôt"
  }
}
```

**Réponse attendue (erreur d'auth) :**
```json
{
  "statusCode": 401,
  "statusMessage": "Unauthorized - Invalid cron secret"
}
```

## 🔄 Vercel Cron Job

### Vérifier que le cron est actif

1. **Vercel Dashboard** → **Votre Projet** → **Cron Jobs**
2. Vous devriez voir : `check-subscriptions` - `0 2 * * *` (tous les jours à 2h)

### Configuration dans vercel.json

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

**Note:** Vercel ajoute automatiquement l'en-tête `Authorization` avec votre `CRON_SECRET` !

## 🐛 Dépannage

### ❌ Erreur: "CRON_SECRET not set"

**Solution:**
```bash
# Vérifier que la variable existe
grep CRON_SECRET .env

# Si vide, régénérer
echo "CRON_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")" >> .env
```

### ❌ Erreur: "Unauthorized"

**Causes possibles:**
1. Mauvaise clé dans la requête
2. Variable pas configurée sur Vercel
3. Déploiement pas à jour

**Solution:**
```bash
# Vérifier la variable sur Vercel
vercel env ls

# Redéployer
vercel --prod
```

### ❌ Erreur: "Database error"

**Causes possibles:**
1. Fonctions SQL pas créées
2. Mauvaise URL Supabase
3. Permissions insuffisantes

**Solution:**
```bash
# Exécuter le SQL
psql $DATABASE_URL < bdd/subscription_auto_block.sql

# Vérifier les fonctions
psql $DATABASE_URL -c "\df check_and_block_expired_subscriptions"
```

## 📚 Ressources

- [Vercel Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)
- [Vercel Cron Jobs](https://vercel.com/docs/cron-jobs)
- [Node.js Crypto](https://nodejs.org/api/crypto.html)

## 🔒 Bonnes Pratiques

1. ✅ **Ne jamais** commiter le fichier `.env`
2. ✅ **Toujours** utiliser des clés différentes pour dev/staging/prod
3. ✅ **Régénérer** les clés si elles sont exposées
4. ✅ **Documenter** dans `.env.example`
5. ✅ **Tester** en local avant de déployer
