<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="bg-white p-6 rounded-2xl max-w-md w-full mx-4 shadow-xl animate-zoom-in">
      <div class="flex flex-col items-center text-center">
        
        <!-- Spinner pour le chargement -->
        <div v-if="status === 'loading'" class="mb-4">
          <div class="w-16 h-16 border-4 border-blue-400 border-t-transparent rounded-full animate-spin"></div>
        </div>
        
        <!-- Animation d'attente -->
        <div v-else-if="status === 'waiting'" class="mb-4">
          <div class="w-16 h-16 relative flex items-center justify-center">
            <div class="absolute inset-0 border-4 border-blue-200 rounded-full"></div>
            <div class="w-3 h-3 bg-blue-500 rounded-full animate-pulse"></div>
          </div>
        </div>
        
        <!-- Animation de succès -->
        <div v-else-if="status === 'success'" class="mb-4">
          <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center">
            <svg class="w-10 h-10 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
          </div>
        </div>
        
        <!-- Animation de rejet/erreur -->
        <div v-else-if="status === 'rejected'" class="mb-4">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center">
            <svg class="w-10 h-10 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </div>
        </div>
        
        <h3 class="text-lg font-semibold text-gray-900 mt-2">
          {{ title }}
        </h3>
        
        <p class="text-gray-600 mt-2">
          {{ statusMessage || defaultMessage }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false
  },
  status: {
    type: String,
    default: 'loading',
    validator: (value) => ['loading', 'waiting', 'success', 'rejected'].includes(value)
  },
  statusMessage: {
    type: String,
    default: ''
  }
})

const title = computed(() => {
  switch (props.status) {
    case 'loading':
      return 'Envoi de la commande...'
    case 'waiting':
      return 'En attente de confirmation'
    case 'success':
      return 'Commande confirmée !'
    case 'rejected':
      return 'Commande annulée'
    default:
      return 'Traitement en cours'
  }
})

const defaultMessage = computed(() => {
  switch (props.status) {
    case 'loading':
      return 'Nous envoyons votre commande au restaurant...'
    case 'waiting':
      return 'Le restaurant est en train de traiter votre commande.'
    case 'success':
      return 'Votre commande a été acceptée !'
    case 'rejected':
      return 'Votre commande a été refusée par le restaurant.'
    default:
      return 'Veuillez patienter...'
  }
})
</script>

<style scoped>
@keyframes zoom-in {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.animate-zoom-in {
  animation: zoom-in 0.2s ease-out;
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.6; transform: scale(0.8); }
}

.animate-pulse {
  animation: pulse 1.5s infinite;
}
</style> 