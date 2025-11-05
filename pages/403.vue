<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <!-- Error Icon -->
      <div class="text-center">
        <div class="mx-auto w-24 h-24 bg-red-100 rounded-full flex items-center justify-center">
          <svg class="w-12 h-12 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>

        <!-- Error Code -->
        <h1 class="mt-6 text-6xl font-bold text-gray-900">403</h1>

        <!-- Error Title -->
        <h2 class="mt-4 text-2xl font-bold text-gray-900">Accès refusé</h2>

        <!-- Error Message -->
        <p class="mt-2 text-sm text-gray-600">
          {{ error?.message || 'Données utilisateur non trouvées' }}
        </p>

        <!-- Additional Info -->
        <div class="mt-6 p-4 bg-red-50 rounded-lg border border-red-200">
          <div class="flex items-center">
            <svg class="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
            </svg>
            <div class="text-sm text-red-800">
              <p class="font-medium">Erreur d'authentification</p>
              <p class="mt-1">Vous n'avez pas les permissions nécessaires pour accéder à cette page.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="space-y-4">
        <!-- Retry Button -->
        <button
          @click="handleRetry"
          class="w-full flex justify-center items-center px-4 py-3 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Réessayer
        </button>

        <!-- Go Home Button -->
        <NuxtLink
          to="/"
          class="w-full flex justify-center items-center px-4 py-3 bg-gray-100 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          Retour à l'accueil
        </NuxtLink>

        <!-- Login Button (if not authenticated) -->
        <NuxtLink
          v-if="!isAuthenticated"
          to="/auth/login"
          class="w-full flex justify-center items-center px-4 py-3 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
          </svg>
          Se connecter
        </NuxtLink>

        <!-- Contact Support -->
        <div class="text-center">
          <p class="text-sm text-gray-500">
            Besoin d'aide ?
            <a href="mailto:support@kulaqr.com" class="text-blue-600 hover:text-blue-500 font-medium">
              Contactez le support
            </a>
          </p>
        </div>
      </div>

      <!-- Error Details (for developers) -->
      <details class="mt-8 text-xs text-gray-500" v-if="error?.stack">
        <summary class="cursor-pointer hover:text-gray-700">Détails techniques</summary>
        <pre class="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto">{{ error.stack }}</pre>
      </details>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useAuth } from '~/composables/useAuth'

const props = defineProps({
  error: {
    type: Object,
    default: null
  }
})

// SEO Meta
useHead({
  title: '403 - Accès refusé',
  meta: [
    {
      name: 'description',
      content: 'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.'
    },
    {
      name: 'robots',
      content: 'noindex, nofollow'
    }
  ]
})

// Check if user is authenticated
const isAuthenticated = computed(() => {
  try {
    // Check if we have a user session
    const { user } = useAuth()
    return !!user.value
  } catch {
    return false
  }
})

// Handle retry action
const handleRetry = () => {
  // Clear error and retry the last action
  if (process.client) {
    window.location.reload()
  }
}

// Handle error clearing
const clearError = () => {
  // Clear the error state
  if (props.error) {
    // You can implement error clearing logic here
    console.log('Clearing error:', props.error)
  }
}

// Watch for error changes
watch(() => props.error, (newError) => {
  if (newError) {
    console.error('403 Error:', newError)
  }
})
</script>

<style scoped>
/* Custom animations for the error page */
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

.error-icon {
  animation: shake 0.5s ease-in-out;
}

/* Responsive design */
@media (max-width: 640px) {
  .max-w-md {
    margin: 0 1rem;
  }
}

/* Focus states for accessibility */
button:focus,
a:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Hover effects */
button:hover {
  transform: translateY(-1px);
}

a:hover {
  transform: translateY(-1px);
}

/* Error details styling */
details {
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
}

details summary {
  padding: 0.75rem;
  cursor: pointer;
  user-select: none;
}

details pre {
  white-space: pre-wrap;
  word-break: break-all;
}
</style>