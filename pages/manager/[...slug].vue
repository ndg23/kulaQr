<template>
  <div class="min-h-screen bg-white flex items-center justify-center">
    <div class="text-center px-4 max-w-md mx-auto">
      <!-- 404 Icon -->
      <div class="mb-8">
        <div class="w-20 h-20 mx-auto rounded-full bg-gray-100 flex items-center justify-center">
          <AlertTriangle class="w-10 h-10 text-gray-400" />
        </div>
      </div>
      
      <!-- Error Message -->
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">404</h1>
        <h2 class="text-xl font-semibold text-gray-700 mb-2">Page manager non trouvée</h2>
        <p class="text-gray-500 text-sm">
          Cette page de gestion n'existe pas ou a été déplacée.
        </p>
      </div>
      
      <!-- Current Path -->
      <div class="mb-8 p-4 bg-gray-50 rounded-2xl">
        <p class="text-xs text-gray-400 mb-1">Chemin demandé :</p>
        <p class="text-sm font-mono text-gray-600 break-all">{{ $route.path }}</p>
      </div>
      
      <!-- Actions -->
      <div class="space-y-3">
        <button
          @click="goBack"
          class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 transition-all duration-200 flex items-center justify-center gap-2"
        >
          <ArrowLeft class="w-4 h-4" />
          Retour
        </button>
        
        <NuxtLink
          to="/"
          class="w-full inline-flex items-center justify-center gap-2 px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-all duration-200"
        >
          <Home class="w-4 h-4" />
          Accueil
        </NuxtLink>
      </div>
      
      <!-- Quick Links -->
      <div class="mt-8 pt-6 border-t border-gray-100">
        <p class="text-xs text-gray-400 mb-3">Pages disponibles :</p>
        <div class="flex flex-wrap gap-2 justify-center">
          <NuxtLink
            to="/admin"
            class="px-3 py-1 text-xs bg-gray-100 text-gray-600 rounded-full hover:bg-gray-200 transition-colors"
          >
            Admin
          </NuxtLink>
          <NuxtLink
            to="/staff"
            class="px-3 py-1 text-xs bg-gray-100 text-gray-600 rounded-full hover:bg-gray-200 transition-colors"
          >
            Staff
          </NuxtLink>
        </div>
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
  layout: 'manager'
})
</script>
