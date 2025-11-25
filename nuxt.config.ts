// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  ssr: false, // Mode SPA - tout rendu côté client
  modules: [
    '@nuxt/ui',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
    '@nuxtjs/seo'
  ],

  app: {
    head: {
      title: 'Kula Qr - Catalogues Digitaux pour tous vos établissements',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Viens découvrir mon établissement avec des catalogues digitaux QR code. Solution moderne, sans contact et écologique pour tous types de commerces.' },
        { name: 'keywords', content: 'QR code, catalogue digital, établissement, commerce, sans contact, menu électronique, commande en ligne, boutique, salon, bar, restaurant' },
        { name: 'author', content: 'Kula Qr' },
        { name: 'robots', content: 'index, follow' },
        { property: 'og:type', content: 'website' },
        { property: 'og:site_name', content: 'Kula Qr' },
        { property: 'og:locale', content: 'fr_FR' },
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:site', content: '@kulaqr' }
        
      ],
      link: [
        { rel: 'canonical', href: 'https://kula-qr.vercel.app' },
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
  },

  // Configuration SEO
  site: {
    url: 'https://kula-qr.vercel.app',
    name: 'Kula Qr',
    description: 'Transformez votre établissement avec des catalogues digitaux QR code. Solution moderne, sans contact et écologique pour tous types de commerces.',
    defaultLocale: 'fr'
  },
colorMode: {
    classSuffix: '',    // facultatif, pour ne pas ajouter de suffixe de classe
    preference: 'light', // force le mode clair par défaut
    fallback: 'light',   // si navigateur ne supporte pas
    storageKey: 'nuxt-color-mode', // facultatif, clé pour localStorage
    globalName: '__NUXT_COLOR_MODE__',
    overrideSystem: true // IMPORTANT : ignore la préférence du système
  },
  // Configuration du sitemap
  sitemap: {
    hostname: 'https://kula-qr.vercel.app',
    gzip: true,
    routes: async () => {
      // Routes statiques
      const staticRoutes = [
        '/',
        '/about',
        '/contact',
        '/legal',
        '/legal/cgu',
        '/legal/mentions-legales',
        '/legal/privacy',
        '/legal/terms'
      ]
      
      // Routes dynamiques pour les commerces
      // Note: En production, vous devriez récupérer ces données depuis votre base de données
      const commerceRoutes = [
        '/commerce',
        '/menu'
      ]
      
      return [...staticRoutes, ...commerceRoutes]
    }
  },

  // Configuration robots.txt
  robots: {
    UserAgent: '*',
    Allow: '/',
    Disallow: ['/admin', '/manager', '/staff', '/api'],
    Sitemap: 'https://kula-qr.vercel.app/sitemap.xml'
  },
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_KEY,
    redirect: false,
    cookieOptions: {
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7 // 7 jours
    },
    clientOptions: {
      auth: {
        detectSessionInUrl: true,
        persistSession: true,
        autoRefreshToken: true,
        flowType: 'pkce'
      }
    }
  },
 
  compatibilityDate: '2025-04-23',
  tailwindcss: {
    cssPath: '~/assets/css/main.css',
    configPath: 'tailwind.config.js',
    exposeConfig: false,
    viewer: true,
  },
  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {},
    },
  },
  vite: {
    optimizeDeps: {
      include: [
        '@heroicons/vue/24/outline',
        '@headlessui/vue'
      ]
    }
  },
  // Configuration runtime
  runtimeConfig: {
    // Variables serveur privées
    supabaseServiceKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
    cronSecret: process.env.CRON_SECRET,
    
    // Variables publiques
    public: {
      qrSecretKey: process.env.QR_SECRET_KEY,
      baseURL: process.env.BASE_URL,
      siteUrl: process.env.SITE_URL || 'https://kulaqr.vercel.app',
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseKey: process.env.SUPABASE_KEY
    }
  }
})