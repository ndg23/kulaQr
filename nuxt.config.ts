// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],

  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase'
  ],
  routeRules: {
    '/staff': { ssr: true },
    '/staff/**': { ssr: true }
  },
  app: {
    head: {
      title: 'Menu QR Code Generator',
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
    redirect: false
  },

  compatibilityDate: '2025-04-23',

  // Ajouter des redirections pour les anciennes URLs
  nitro: {
    routeRules: {
      '/waiter': { redirect: '/staff' },
      '/waiter/**': { redirect: '/staff/**' }
    }
  }
})