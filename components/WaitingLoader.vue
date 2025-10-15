<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center bg-black/30 backdrop-blur-sm transition-all duration-300">
    <div class="bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 animate-fade-up overflow-hidden">
      
      <!-- Header du ticket -->
      <div class="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-6 text-center">
        <h2 class="text-2xl font-bold font-mono">TICKET DE COMMANDE</h2>
        <p class="text-blue-100 text-sm mt-1">{{ establishmentName }}</p>
      </div>

      <!-- Contenu du ticket -->
      <div class="p-6">
        <!-- Informations de la commande -->
        <div v-if="order" class="space-y-4 mb-6">
          <!-- Numéro de commande -->
          <div class="flex justify-between items-center py-2 border-b border-gray-100">
            <span class="text-sm font-medium text-gray-600">Commande #</span>
            <span class="font-mono text-sm font-bold text-gray-900">{{ orderNumber }}</span>
          </div>

          <!-- Table -->
          <div v-if="tableNumber" class="flex justify-between items-center py-2 border-b border-gray-100">
            <span class="text-sm font-medium text-gray-600">Table</span>
            <span class="font-mono text-sm font-bold text-gray-900">{{ tableNumber }}</span>
          </div>

          <!-- Date/Heure -->
          <div class="flex justify-between items-center py-2 border-b border-gray-100">
            <span class="text-sm font-medium text-gray-600">Date</span>
            <span class="font-mono text-sm text-gray-900">{{ formatDateTime(new Date()) }}</span>
          </div>

          <!-- Articles -->
          <div class="space-y-2">
            <h3 class="text-sm font-semibold text-gray-900 border-b border-gray-100 pb-2">Articles</h3>
            <div 
              v-for="item in order.items" 
              :key="item.id"
              class="flex justify-between items-center py-1"
            >
              <div class="flex-1">
                <span class="text-sm text-gray-900">{{ item.name }}</span>
                <span class="text-xs text-gray-500 ml-2">x{{ item.quantity }}</span>
              </div>
              <span class="font-mono text-sm font-medium text-gray-900">
                {{ formatPrice(item.unit_price * item.quantity) }}
              </span>
            </div>
          </div>

          <!-- Total -->
          <div class="border-t border-gray-200 pt-3">
            <div class="flex justify-between items-center">
              <span class="text-lg font-semibold text-gray-900">Total</span>
              <span class="font-mono text-lg font-bold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
            </div>
          </div>
        </div>

        <!-- Statut et message -->
        <div class="text-center py-4">
          <div class="mb-4">
            <!-- Animation de statut -->
            <div v-if="status === 'loading'" class="flex justify-center mb-3">
              <div class="relative w-12 h-12">
                <div class="absolute inset-0 rounded-full border-2 border-gray-200"></div>
                <div class="absolute inset-0 rounded-full border-2 border-t-blue-500 border-r-transparent border-b-transparent border-l-transparent animate-spin"></div>
              </div>
            </div>
            
            <div v-else-if="status === 'waiting'" class="flex justify-center mb-3">
              <div class="relative w-12 h-12">
                <div class="absolute inset-0 rounded-full border-2 border-orange-200"></div>
                <div class="absolute inset-0 rounded-full border-2 border-t-orange-500 border-r-transparent border-b-transparent border-l-transparent animate-spin"></div>
              </div>
            </div>
            
            <div v-else-if="status === 'success'" class="flex justify-center mb-3">
              <div class="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
            </div>
            
            <div v-else-if="status === 'rejected'" class="flex justify-center mb-3">
              <div class="w-12 h-12 bg-red-500 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </div>
            </div>

            <!-- Badge de statut -->
            <div class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                 :class="getStatusBadgeClass(status)">
              {{ getStatusText(status) }}
            </div>
          </div>

          <p class="text-gray-600 text-sm leading-relaxed">
            {{ message || defaultMessage }}
          </p>
        </div>

        <!-- Actions -->
        <div class="flex gap-3 mt-6">
          <button 
            v-if="status === 'success' || status === 'rejected'" 
            @click="$emit('close')"
            class="flex-1 px-4 py-3 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-xl text-sm font-medium transition-colors duration-200"
          >
            Fermer
          </button>
          
          <button 
            v-else-if="status === 'waiting' && cancelable" 
            @click="$emit('cancel')"
            class="flex-1 px-4 py-3 bg-red-100 hover:bg-red-200 text-red-700 rounded-xl text-sm font-medium transition-colors duration-200"
          >
            Annuler
          </button>
        </div>
      </div>

      <!-- Footer du ticket avec loader de statut -->
      <div v-if="status === 'waiting'" class="bg-gray-50 px-6 py-3 border-t border-gray-100">
        <div class="flex items-center justify-center gap-2 text-xs text-gray-500">
          <div class="w-2 h-2 bg-orange-500 rounded-full animate-pulse"></div>
          <span>Mise à jour du statut en temps réel...</span>
        </div>
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
  },
  order: {
    type: Object,
    default: null
  },
  orderNumber: {
    type: String,
    default: ''
  },
  tableNumber: {
    type: [String, Number],
    default: null
  },
  establishmentName: {
    type: String,
    default: 'Restaurant'
  }
})

defineEmits(['close', 'cancel'])

// Fonctions utilitaires
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

const formatDateTime = (date) => {
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const getStatusBadgeClass = (status) => {
  switch (status) {
    case 'loading':
      return 'bg-blue-100 text-blue-700'
    case 'waiting':
      return 'bg-orange-100 text-orange-700'
    case 'success':
      return 'bg-green-100 text-green-700'
    case 'rejected':
      return 'bg-red-100 text-red-700'
    default:
      return 'bg-gray-100 text-gray-700'
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 'loading':
      return 'Envoi en cours'
    case 'waiting':
      return 'En préparation'
    case 'success':
      return 'Confirmée'
    case 'rejected':
      return 'Refusée'
    default:
      return 'En cours'
  }
}

const defaultMessage = computed(() => {
  switch (props.status) {
    case 'loading':
      return 'Nous envoyons votre commande au restaurant...'
    case 'waiting':
      return 'Votre commande est en cours de préparation. Vous serez notifié en temps réel des changements de statut.'
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
</style> 