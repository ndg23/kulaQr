// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  modules: [
    '@nuxt/ui',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
    '@nuxtjs/seo'
  ],

  app: {
    head: {
      title: 'Kula Qr - Menu Digital pour vos commerces',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Transformez votre commerce avec des menus digitaux QR code. Solution moderne, sans contact et écologique pour les commerces.' },
        { name: 'keywords', content: 'QR code, menu digital, commerce, sans contact, menu électronique, commande en ligne' },
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
        { rel: 'icon', type: 'image/x-icon', href: '/logo.ico' }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
  },

  // Configuration SEO
  site: {
    url: 'https://kula-qr.vercel.app',
    name: 'Kula Qr',
    description: 'Transformez votre établissement avec des menus digitaux QR code. Solution moderne, sans contact et écologique.',
    defaultLocale: 'fr'
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
    Disallow: ['/admin', '/manager', '/staff'],
    Sitemap: 'https://kula-qr.vercel.app/sitemap.xml'
  },
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_KEY,
    redirect: false,
    cookieOptions: {
      secure: false,
      sameSite: 'lax'
    },
    clientOptions: {
      auth: {
        detectSessionInUrl: false,
        persistSession: false
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
  // Ajouter des redirections pour les anciennes URLs
  public: {
    qrSecretKey: process.env.QR_SECRET_KEY,
    baseURL: process.env.BASE_URL
  }
})