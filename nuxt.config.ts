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
      title: 'Kula Qr - Menu Digital pour Restaurants',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Transformez votre restaurant avec des menus digitaux QR code. Solution moderne, sans contact et écologique pour les restaurants.' },
        { name: 'keywords', content: 'QR code, menu digital, restaurant, sans contact, menu électronique, commande en ligne' },
        { name: 'author', content: 'Kula Qr' },
        { name: 'robots', content: 'index, follow' },
        { property: 'og:type', content: 'website' },
        { property: 'og:site_name', content: 'Kula Qr' },
        { property: 'og:locale', content: 'fr_FR' },
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:site', content: '@kulaqr' }
      ],
      link: [
        { rel: 'canonical', href: 'https://kulaqr.com' },
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
  },

  // Configuration SEO
  site: {
    url: 'https://kulaqr.com',
    name: 'Kula Qr',
    description: 'Transformez votre établissement avec des menus digitaux QR code. Solution moderne, sans contact et écologique.',
    defaultLocale: 'fr'
  },

  // Configuration du sitemap
  sitemap: {
    hostname: 'https://kulaqr.com',
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
      
      // Routes dynamiques pour les restaurants
      // Note: En production, vous devriez récupérer ces données depuis votre base de données
      const restaurantRoutes = [
        '/restaurant',
        '/menu'
      ]
      
      return [...staticRoutes, ...restaurantRoutes]
    }
  },

  // Configuration robots.txt
  robots: {
    UserAgent: '*',
    Allow: '/',
    Disallow: ['/admin', '/manager', '/staff', '/auth'],
    Sitemap: 'https://kulaqr.com/sitemap.xml'
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