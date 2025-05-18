<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center bg-black/30 backdrop-blur-sm transition-all duration-300">
    <div class="bg-white/90 backdrop-blur-xl p-8 rounded-3xl max-w-md w-full mx-4 shadow-xl animate-fade-up border border-white/20">
      <div class="flex flex-col items-center text-center">
        
        <!-- Loader de style Apple pour le chargement -->
        <div v-if="status === 'loading'" class="mb-6">
          <div class="relative w-20 h-20">
            <!-- Cercle statique -->
            <div class="absolute inset-0 rounded-full border-[3px] border-gray-100"></div>
            <!-- Cercle animé -->
            <div class="absolute inset-0 rounded-full border-[3px] border-t-blue-500 border-r-transparent border-b-transparent border-l-transparent animate-spin-slow"></div>
            <!-- Point central pulsant -->
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="w-3 h-3 bg-blue-500 rounded-full animate-pulse-subtle"></div>
            </div>
          </div>
        </div>
        
        <!-- Animation d'attente -->
        <div v-else-if="status === 'waiting'" class="mb-6">
          <div class="relative w-20 h-20">
            <svg class="w-full h-full" viewBox="0 0 100 100">
              <!-- Cercle de fond -->
              <circle cx="50" cy="50" r="46" fill="none" stroke="#f3f4f6" stroke-width="4" />
              
              <!-- Cercles animés -->
              <circle cx="50" cy="50" r="46" fill="none" stroke="#3b82f6" stroke-width="4" stroke-linecap="round"
                stroke-dasharray="16 303" class="animate-dash-around origin-center" />
              
              <circle cx="50" cy="50" r="46" fill="none" stroke="#60a5fa" stroke-width="4" stroke-linecap="round"
                stroke-dasharray="16 303" stroke-dashoffset="60" class="animate-dash-around origin-center" opacity="0.6" />
              
              <circle cx="50" cy="50" r="46" fill="none" stroke="#93c5fd" stroke-width="4" stroke-linecap="round"
                stroke-dasharray="16 303" stroke-dashoffset="120" class="animate-dash-around origin-center" opacity="0.4" />
              
              <!-- Centre -->
              <circle cx="50" cy="50" r="4" fill="#3b82f6" class="animate-pulse-subtle" />
            </svg>
          </div>
        </div>
        
        <!-- Animation de succès -->
        <div v-else-if="status === 'success'" class="mb-6">
          <div class="relative w-20 h-20">
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="w-20 h-20 bg-gradient-to-br from-green-400 to-green-500 rounded-full flex items-center justify-center animate-scale-in">
                <svg class="w-10 h-10 text-white transform animate-check" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Animation de rejet/erreur -->
        <div v-else-if="status === 'rejected'" class="mb-6">
          <div class="relative w-20 h-20">
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="w-20 h-20 bg-gradient-to-br from-red-400 to-red-500 rounded-full flex items-center justify-center animate-scale-in">
                <svg class="w-10 h-10 text-white transform animate-cross" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <h3 class="text-xl font-semibold text-gray-900 mt-2 tracking-tight">
          {{ title }}
        </h3>
        
        <p class="text-gray-500 mt-2 max-w-xs text-md leading-relaxed">
          {{ message || defaultMessage }}
        </p>

        <!-- Bouton pour fermer (uniquement sur les états complétés) -->
        <button 
          v-if="status === 'success' || status === 'rejected'" 
          @click="$emit('close')"
          class="mt-6 px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-2xl text-sm font-medium transition-colors duration-200"
        >
          Fermer
        </button>
        
        <!-- Annulation possible pendant l'attente -->
        <button 
          v-else-if="status === 'waiting' && cancelable" 
          @click="$emit('cancel')"
          class="mt-6 text-sm text-gray-500 hover:text-gray-700 transition-colors"
        >
          Annuler
        </button>
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
  message: {
    type: String,
    default: null
  },
  titleOverride: {
    type: String,
    default: null
  },
  cancelable: {
    type: Boolean,
    default: false
  }
})

defineEmits(['close', 'cancel'])

// Calculer dynamiquement le titre en fonction du statut
const title = computed(() => {
  if (props.titleOverride) return props.titleOverride
  
  switch (props.status) {
    case 'loading':
      return 'Envoi en cours'
    case 'waiting':
      return 'Traitement en cours'
    case 'success':
      return 'Commande confirmée'
    case 'rejected':
      return 'Commande refusée'
    default:
      return 'Traitement en cours'
  }
})

const defaultMessage = computed(() => {
  switch (props.status) {
    case 'loading':
      return 'Nous envoyons votre commande au restaurant...'
    case 'waiting':
      return 'Votre commande est en cours de préparation. Merci de patienter un instant.'
    case 'success':
      return 'Votre commande a été acceptée ! Vous serez notifié lorsqu\'elle sera prête.'
    case 'rejected':
      return 'Le restaurant n\'a pas pu accepter votre commande. Veuillez réessayer ou contacter l\'établissement.'
    default:
      return 'Veuillez patienter...'
  }
})
</script>

<style scoped>
@keyframes fade-up {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-up {
  animation: fade-up 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes pulse-subtle {
  0% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.7; transform: scale(0.95); }
  100% { opacity: 1; transform: scale(1); }
}

.animate-pulse-subtle {
  animation: pulse-subtle 1.5s infinite;
}

@keyframes spin-slow {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin-slow {
  animation: spin-slow 1.2s linear infinite;
}

@keyframes scale-in {
  from { transform: scale(0.8); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.animate-scale-in {
  animation: scale-in 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

@keyframes check {
  from { stroke-dashoffset: 30; stroke-dasharray: 30; }
  to { stroke-dashoffset: 0; stroke-dasharray: 30; }
}

.animate-check {
  animation: check 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s forwards;
  stroke-dashoffset: 30;
  stroke-dasharray: 30;
  opacity: 0;
  animation-fill-mode: forwards;
}

@keyframes cross {
  from { stroke-dashoffset: 60; stroke-dasharray: 60; }
  to { stroke-dashoffset: 0; stroke-dasharray: 60; }
}

.animate-cross {
  animation: cross 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s forwards;
  stroke-dashoffset: 60;
  stroke-dasharray: 60;
  opacity: 0;
  animation-fill-mode: forwards;
}

@keyframes dash-around {
  to { transform: rotate(1turn); }
}

.animate-dash-around {
  animation: dash-around 2s linear infinite;
}
</style> 