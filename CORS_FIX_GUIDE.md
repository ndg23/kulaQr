# Guide de résolution des erreurs CORS - KulaQr

## 🔍 Problème
Erreurs CORS lors de la connexion avec Supabase

## ✅ Solutions appliquées

### 1. Configuration Nuxt.config.ts
Les modifications suivantes ont été apportées :

```typescript
supabase: {
  url: process.env.SUPABASE_URL,
  key: process.env.SUPABASE_KEY,
  redirect: false,
  cookieOptions: {
    secure: process.env.NODE_ENV === 'production', // true en prod, false en dev
    sameSite: 'lax',
    maxAge: 60 * 60 * 24 * 7 // 7 jours
  },
  clientOptions: {
    auth: {
      detectSessionInUrl: true,      // ✅ Activé (était false)
      persistSession: true,            // ✅ Activé (était false)
      autoRefreshToken: true,          // ✅ Activé
      flowType: 'pkce'                 // ✅ Ajouté pour plus de sécurité
    }
  }
}
```

### Changements clés :
- ✅ `persistSession: true` - Permet de persister la session
- ✅ `detectSessionInUrl: true` - Détecte la session dans l'URL (callbacks OAuth)
- ✅ `autoRefreshToken: true` - Rafraîchit automatiquement le token
- ✅ `flowType: 'pkce'` - Utilise PKCE pour plus de sécurité
- ✅ `secure: process.env.NODE_ENV === 'production'` - Cookies sécurisés en production uniquement

## 🔧 Configuration Supabase Dashboard

Pour éviter les erreurs CORS, vous devez configurer les URLs autorisées dans votre projet Supabase :

### Étapes :

1. **Accéder au Dashboard Supabase**
   - Allez sur https://supabase.com
   - Ouvrez votre projet

2. **Configurer les URLs autorisées**
   - Dans le menu latéral : **Authentication** → **URL Configuration**
   - Ajoutez les URLs suivantes :

   **Site URL (Production):**
   ```
   https://kula-qr.vercel.app
   ```

   **Redirect URLs (Plusieurs lignes):**
   ```
   http://localhost:3000/**
   http://localhost:3000/auth/callback
   http://127.0.0.1:3000/**
   http://127.0.0.1:3000/auth/callback
   https://kula-qr.vercel.app/**
   https://kula-qr.vercel.app/auth/callback
   https://*.vercel.app/**
   ```

3. **Configuration des domaines CORS**
   - Dans **Settings** → **API**
   - Section **CORS Origins**
   - Ajoutez :
   ```
   http://localhost:3000
   http://127.0.0.1:3000
   https://kula-qr.vercel.app
   https://*.vercel.app
   ```

4. **Sauvegarder les changements**
   - Cliquez sur **Save**
   - Attendez quelques secondes pour que les changements prennent effet

## 🔄 Après la configuration

### 1. Redémarrer le serveur de développement
```bash
# Arrêter le serveur (Ctrl+C)
# Relancer
npm run dev
# ou
pnpm dev
```

### 2. Vider le cache du navigateur
- Ouvrir les **DevTools** (F12)
- Clic droit sur le bouton **Refresh**
- Sélectionner **Empty Cache and Hard Reload**

### 3. Tester la connexion
- Essayer de se connecter
- Vérifier la console du navigateur (F12)
- Il ne devrait plus y avoir d'erreurs CORS

## 🐛 Si le problème persiste

### Vérifier les variables d'environnement

```bash
# Vérifier le fichier .env
cat .env
```

Le fichier doit contenir :
```env
SUPABASE_URL="https://vgeqqbkfowwkouvjnvgv.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
BASE_URL="/"
```

### Vérifier dans la console du navigateur

Ouvrir **DevTools (F12)** → **Console** et chercher :
- ❌ Erreurs CORS : `Access to fetch has been blocked by CORS policy`
- ❌ Erreurs 401 : `Unauthorized`
- ❌ Erreurs de réseau

### Vérifier dans l'onglet Network

**DevTools (F12)** → **Network** :
1. Tenter une connexion
2. Chercher la requête vers Supabase
3. Vérifier les **Headers** :
   - `Origin` doit correspondre à votre domaine
   - `Access-Control-Allow-Origin` doit être présent dans la réponse

## 📝 Erreurs courantes et solutions

### Erreur : "persistSession requires a secure context"
**Solution :** Déjà corrigée avec `secure: process.env.NODE_ENV === 'production'`

### Erreur : "Failed to fetch"
**Solution :** 
- Vérifier que Supabase est accessible
- Vérifier la connexion internet
- Vérifier l'URL Supabase dans `.env`

### Erreur : "Invalid API key"
**Solution :**
- Vérifier que la clé dans `.env` est correcte
- Régénérer une nouvelle clé si nécessaire dans Supabase Dashboard

### Erreur : "User not found" après connexion
**Solution :**
- Vérifier que la table `users` existe
- Vérifier les RLS (Row Level Security) policies

## 🔐 Sécurité

### En Production :
- ✅ Utilisez HTTPS uniquement
- ✅ Activez `secure: true` pour les cookies
- ✅ Limitez les CORS aux domaines nécessaires
- ✅ Utilisez des variables d'environnement pour les clés

### En Développement :
- ✅ `secure: false` pour localhost
- ✅ CORS ouvert pour localhost:3000
- ✅ Utilisez `.env` local (jamais commit dans git)

## 📞 Support

Si le problème persiste après ces étapes :
- Vérifier les logs Supabase dans le Dashboard
- Contacter le support Supabase
- Vérifier la documentation : https://supabase.com/docs/guides/auth

---

**Date de mise à jour :** 24 novembre 2025
**Version :** 1.0
