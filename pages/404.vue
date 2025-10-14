<template>
  <div class="min-h-screen bg-white flex items-center justify-center">
    <div class="text-center px-4">
      <!-- 404 Icon -->
      <div class="mb-8">
        <div class="w-24 h-24 mx-auto rounded-full bg-gray-100 flex items-center justify-center">
          <AlertTriangle class="w-12 h-12 text-gray-400" />
        </div>
      </div>
      
      <!-- Error Message -->
      <div class="mb-8">
        <h1 class="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <h2 class="text-2xl font-semibold text-gray-700 mb-2">Page non trouvée</h2>
        <p class="text-gray-500 max-w-md mx-auto">
          Désolé, la page que vous recherchez n'existe pas ou a été déplacée.
        </p>
      </div>
      
      <!-- Actions -->
      <div class="space-y-4">
        <button
          @click="goBack"
          class="inline-flex items-center gap-2 px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 transition-all duration-200"
        >
          <ArrowLeft class="w-4 h-4" />
          Retour
        </button>
        
        <div class="text-center">
          <NuxtLink
            to="/"
            class="inline-flex items-center gap-2 px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-all duration-200"
          >
            <Home class="w-4 h-4" />
            Accueil
          </NuxtLink>
        </div>
      </div>
      
      <!-- Additional Help -->
      <div class="mt-12 text-sm text-gray-400">
        <p>Si vous pensez qu'il s'agit d'une erreur, contactez le support.</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { AlertTriangle, ArrowLeft, Home } from 'lucide-vue-next'

// Go back to previous page
const goBack = () => {
  if (process.client) {
    if (window.history.length > 1) {
      window.history.back()
    } else {
      navigateTo('/')
    }
  }
}

// Set page meta
definePageMeta({
  layout: false
})
</script>
