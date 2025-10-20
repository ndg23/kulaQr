<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/20 backdrop-blur-sm">
    <div class="bg-white rounded-3xl shadow-2xl max-w-lg w-full overflow-hidden animate-slide-up border border-gray-100">

      <!-- Header avec statut -->
      <div class="relative">
        <!-- Background gradient subtil -->
        <div class="absolute inset-0 bg-gradient-to-br from-blue-50 via-white to-purple-50 opacity-50"></div>

        <!-- Contenu header -->
        <div class="relative px-8 py-6 text-center">
          <!-- Icône de statut -->
          <div class="flex justify-center mb-4">
            <div :class="[
              'w-16 h-16 rounded-2xl flex items-center justify-center shadow-lg transform transition-all duration-300',
              getStatusIconBg(status)
            ]">
              <component :is="getStatusIcon(status)" class="w-8 h-8" :class="getStatusIconColor(status)" />
            </div>
          </div>

          <!-- Titre et sous-titre -->
          <h2 class="text-xl font-bold text-gray-900 mb-1">{{ getStatusTitle(status) }}</h2>
          <p class="text-sm text-gray-500">{{ establishmentName }}</p>

          <!-- Badge de statut -->
          <div class="inline-flex items-center mt-3 px-3 py-1 rounded-full text-xs font-medium"
               :class="getStatusBadgeClass(status)">
            {{ getStatusText(status) }}
          </div>
        </div>
      </div>

      <!-- Corps principal -->
      <div class="px-8 py-6">

        <!-- Ticket de commande rétro -->
        <div v-if="order && status !== 'loading'" class="mb-6">
          <div class="retro-ticket rounded-lg p-4 shadow-inner">

            <!-- En-tête du ticket -->
            <div class="ticket-header text-center mb-4 pb-2">
              <div class="ticket-dots mb-1">
                <div class="ticket-dot"></div>
                <h3 class="ticket-title">TICKET DE COMMANDE</h3>
                <div class="ticket-dot"></div>
              </div>
              <p class="ticket-number">#{{ orderNumber }}</p>
            </div>

            <!-- Détails de la commande -->
            <div class="ticket-details space-y-2 mb-4">
              <div class="flex justify-between items-center text-sm">
                <span>Établissement:</span>
                <span class="font-semibold">{{ establishmentName }}</span>
              </div>
              <div v-if="tableNumber" class="flex justify-between items-center text-sm">
                <span>Table:</span>
                <span class="font-semibold">{{ tableNumber }}</span>
              </div>
              <div class="flex justify-between items-center text-sm">
                <span>Date:</span>
                <span class="text-xs">{{ formatDateTime(new Date()) }}</span>
              </div>
            </div>

            <!-- Ligne séparatrice -->
            <div class="border-t border-dashed border-orange-300 my-3"></div>

            <!-- Liste des articles en style ticket -->
            <div class="space-y-1 mb-4">
              <div class="text-center mb-2">
                <span class="text-xs text-orange-600 font-mono uppercase tracking-wider">Articles commandés</span>
              </div>

              <div
                v-for="item in order.items"
                :key="item.id || item.name"
                class="ticket-item flex justify-between items-center py-1"
              >
                <div class="flex items-center gap-2 flex-1">
                  <span class="text-orange-800 text-sm">{{ item.name }}</span>
                  <span class="text-orange-600 text-xs">×{{ item.quantity }}</span>
                </div>
                <span class="text-orange-900 font-semibold text-sm">{{ formatPrice(item.unit_price * item.quantity) }}</span>
              </div>
            </div>

            <!-- Ligne séparatrice -->
            <div class="ticket-total border-t-2 border-dashed border-orange-300 my-3 pt-2 flex justify-between items-center">
              <span class="text-base">TOTAL</span>
              <span class="text-lg">{{ formatPrice(order.total_amount) }}</span>
            </div>

            <!-- Message de remerciement -->
            <div class="ticket-thanks text-center mt-4 pt-2">
              <p>Merci pour votre commande !</p>
            </div>
          </div>
        </div>

        <!-- Message de statut -->
        <div class="text-center mb-6">
          <p class="text-gray-600 text-sm leading-relaxed max-w-sm mx-auto">
            {{ message || defaultMessage }}
          </p>
        </div>

        <!-- Indicateur de progression (pour waiting) -->
        <div v-if="status === 'waiting'" class="mb-6">
          <div class="flex items-center justify-center gap-2 text-xs text-gray-500 mb-2">
            <div class="w-1.5 h-1.5 bg-orange-400 rounded-full animate-pulse"></div>
            <span>Mise à jour en temps réel</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-1">
            <div class="bg-gradient-to-r from-orange-400 to-orange-500 h-1 rounded-full animate-pulse w-1/3"></div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-3">
          <button
            v-if="status === 'success' || status === 'rejected'"
            @click="$emit('close')"
            class="flex-1 px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-2xl text-sm font-semibold transition-all duration-200 hover:shadow-sm"
          >
            Fermer
          </button>

          <button
            v-else-if="status === 'waiting' && cancelable"
            @click="$emit('cancel')"
            class="flex-1 px-6 py-3 bg-red-50 hover:bg-red-100 text-red-700 rounded-2xl text-sm font-semibold transition-all duration-200 hover:shadow-sm border border-red-200"
          >
            Annuler la commande
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Clock, CheckCircle, XCircle, Loader2, ChefHat } from 'lucide-vue-next'

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

const getStatusIcon = (status) => {
  switch (status) {
    case 'loading':
      return Loader2
    case 'waiting':
      return ChefHat
    case 'success':
      return CheckCircle
    case 'rejected':
      return XCircle
    default:
      return Clock
  }
}

const getStatusIconBg = (status) => {
  switch (status) {
    case 'loading':
      return 'bg-blue-100'
    case 'waiting':
      return 'bg-orange-100'
    case 'success':
      return 'bg-green-100'
    case 'rejected':
      return 'bg-red-100'
    default:
      return 'bg-gray-100'
  }
}

const getStatusIconColor = (status) => {
  switch (status) {
    case 'loading':
      return 'text-blue-600'
    case 'waiting':
      return 'text-orange-600'
    case 'success':
      return 'text-green-600'
    case 'rejected':
      return 'text-red-600'
    default:
      return 'text-gray-600'
  }
}

const getStatusBadgeClass = (status) => {
  switch (status) {
    case 'loading':
      return 'bg-blue-50 text-blue-700 border border-blue-200'
    case 'waiting':
      return 'bg-orange-50 text-orange-700 border border-orange-200'
    case 'success':
      return 'bg-green-50 text-green-700 border border-green-200'
    case 'rejected':
      return 'bg-red-50 text-red-700 border border-red-200'
    default:
      return 'bg-gray-50 text-gray-700 border border-gray-200'
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

const getStatusTitle = (status) => {
  switch (status) {
    case 'loading':
      return 'Commande en cours d\'envoi'
    case 'waiting':
      return 'Commande en préparation'
    case 'success':
      return 'Commande confirmée'
    case 'rejected':
      return 'Commande refusée'
    default:
      return 'Statut de commande'
  }
}

const defaultMessage = computed(() => {
  switch (props.status) {
    case 'loading':
      return 'Nous transmettons votre commande à l\'établissement...'
    case 'waiting':
      return 'Votre commande est en cours de préparation. Vous recevrez des notifications en temps réel.'
    case 'success':
      return 'Parfait ! Votre commande a été acceptée et est en préparation.'
    case 'rejected':
      return 'L\'établissement n\'a pas pu accepter votre commande pour le moment.'
    default:
      return 'Veuillez patienter...'
  }
})
</script>

<style scoped>
@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes gentle-pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

@keyframes shimmer {
  0% {
    background-position: -200px 0;
  }
  100% {
    background-position: calc(200px + 100%) 0;
  }
}

.animate-slide-up {
  animation: slide-up 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.animate-gentle-pulse {
  animation: gentle-pulse 2s ease-in-out infinite;
}

/* Smooth transitions */
* {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Subtle shadow improvements */
.shadow-2xl {
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
}

/* Loading animation for progress bar */
@keyframes progress-flow {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.animate-progress-flow {
  animation: progress-flow 1.5s ease-in-out infinite;
}

/* Hover effects for buttons */
button:hover {
  transform: translateY(-1px);
}

/* Focus states */
button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Retro ticket styling */
.retro-ticket {
  background: linear-gradient(135deg, #fef3c7 0%, #fed7aa 100%);
  border: 2px dashed #f97316;
  box-shadow:
    inset 0 2px 4px rgba(0, 0, 0, 0.1),
    0 4px 6px rgba(0, 0, 0, 0.1);
  position: relative;
}

.retro-ticket::before,
.retro-ticket::after {
  content: '';
  position: absolute;
  left: 16px;
  right: 16px;
  height: 8px;
  background: white;
  border-radius: 4px;
}

.retro-ticket::before {
  top: -4px;
}

.retro-ticket::after {
  bottom: -4px;
}

.ticket-header {
  border-bottom: 2px dashed #f97316;
  position: relative;
}

.ticket-dots {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 4px;
}

.ticket-dot {
  width: 12px;
  height: 12px;
  background: #f97316;
  border-radius: 50%;
  box-shadow: 0 2px 4px rgba(249, 115, 22, 0.3);
}

.ticket-title {
  font-family: 'Courier New', monospace;
  font-weight: bold;
  color: #9a3412;
  letter-spacing: 2px;
  font-size: 18px;
}

.ticket-number {
  font-family: 'Courier New', monospace;
  color: #c2410c;
  font-size: 12px;
  font-weight: bold;
}

.ticket-details {
  font-family: 'Courier New', monospace;
  color: #9a3412;
}

.ticket-item {
  border-bottom: 1px dotted #fdba74;
  padding: 4px 0;
  font-family: 'Courier New', monospace;
}

.ticket-item:last-child {
  border-bottom: none;
}

.ticket-total {
  border-top: 2px dashed #f97316;
  font-family: 'Courier New', monospace;
  font-weight: bold;
  color: #9a3412;
}

.ticket-thanks {
  border-top: 1px dashed #fdba74;
  font-family: 'Courier New', monospace;
  font-style: italic;
  color: #c2410c;
  font-size: 12px;
}
</style> 