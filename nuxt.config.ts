// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],

  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase'
  ],

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
  googleSignIn: {
    clientId: process.env.GOOGLE_CLIENT_ID,
    scope: 'email profile',
    prompt: 'consent',
    access_type: 'offline',
    redirect_uri: 'http://localhost:3001/auth/callback'
  },
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_KEY,
    redirect: false
  },

  compatibilityDate: '2025-04-20'
})