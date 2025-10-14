// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  modules: [
    '@nuxt/ui',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase'
   

  ],

  app: {
    head: {
      title: 'Kula Qr',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Générateur de QR codes pour menus de restaurants' }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
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