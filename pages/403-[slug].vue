<template>
  <div class="min-h-screen bg-[#FFFBFB] relative overflow-hidden flex items-center justify-center">
    <PatternBackground :opacity="0.8" :duration="60" />

    <div class="relative z-50 max-w-md mx-auto px-4 text-center">
      <!-- 403 Icon -->
      <div class="w-24 h-24 mx-auto mb-8 bg-red-100 rounded-full flex items-center justify-center">
        <svg class="w-12 h-12 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
      </div>

      <!-- Error Code -->
      <h1 class="text-6xl font-bold text-gray-900 mb-4">403</h1>

      <!-- Error Title -->
      <h2 class="text-2xl font-semibold text-gray-800 mb-4">
        Accès refusé
      </h2>

      <!-- Error Message -->
      <p class="text-gray-600 mb-8 leading-relaxed">
        Vous n'avez pas les permissions nécessaires pour accéder à cette ressource.
        <span class="block mt-2 text-sm text-gray-500">
          Ressource: <code class="bg-gray-100 px-2 py-1 rounded text-xs">{{ decodedSlug }}</code>
        </span>
      </p>

      <!-- Actions -->
      <div class="space-y-4">
        <!-- Login Button -->
        <NuxtLink
          to="/auth/login"
          class="inline-flex items-center justify-center w-full px-6 py-3 bg-black text-white rounded-full font-medium hover:bg-gray-800 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-gray-200 focus:ring-offset-2"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Se connecter
        </NuxtLink>

        <!-- Back to Home -->
        <NuxtLink
          to="/"
          class="inline-flex items-center justify-center w-full px-6 py-3 bg-white border border-gray-200 text-gray-700 rounded-full font-medium hover:bg-gray-50 hover:border-gray-300 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-gray-200 focus:ring-offset-2"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          Retour à l'accueil
        </NuxtLink>
      </div>

      <!-- Help Text -->
      <div class="mt-8 pt-6 border-t border-gray-200">
        <p class="text-sm text-gray-500">
          Besoin d'aide ?
          <NuxtLink to="/contact" class="text-kula-600 hover:text-kula-700 font-medium">
            Contactez-nous
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Get the dynamic slug from the route
const route = useRoute()
const slug = route.params.slug as string

// Decode the slug for display
const decodedSlug = computed(() => {
  try {
    return decodeURIComponent(slug)
  } catch {
    return slug
  }
})

// Set page meta
useHead({
  title: 'Accès refusé - Kula Qr',
  meta: [
    {
      name: 'description',
      content: 'Vous n\'avez pas les permissions nécessaires pour accéder à cette ressource.'
    },
    {
      name: 'robots',
      content: 'noindex, nofollow'
    }
  ]
})
</script>

<style scoped>
/* Ensure proper centering and spacing */
.min-h-screen {
  min-height: 100vh;
}

/* Code styling */
code {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
}
</style>