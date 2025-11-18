<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/30 backdrop-blur-sm">
    <div class="bg-white rounded-3xl shadow-2xl max-w-sm w-full overflow-hidden animate-slideUp">

      <!-- Header minimaliste -->
      <div class="px-10 pt-10 pb-8">
        <div class="flex items-center justify-center mb-8">
          <div :class="[
            'w-20 h-20 rounded-full flex items-center justify-center transition-all',
            getStatusBg(status)
          ]">
            <component 
              :is="getStatusIcon(status)" 
              :class="[
                'transition-all',
                status === 'loading' ? 'w-8 h-8 animate-spin' : 'w-9 h-9',
                getStatusColor(status)
              ]" 
            />
          </div>
        </div>

        <h2 class="text-3xl font-semibold text-gray-900 text-center mb-3 tracking-tight">
          {{ getStatusTitle(status) }}
        </h2>
        <p class="text-gray-500 text-center text-base leading-relaxed">
          {{ message || defaultMessage }}
        </p>
      </div>

      <!-- Détails de commande -->
      <div v-if="order && status !== 'loading'" class="px-10 pb-8">
        <div class="bg-gray-50 rounded-2xl p-5 space-y-4">
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500">Commande</span>
            <span class="font-medium text-gray-900">#{{ orderNumber }}</span>
          </div>
          <div v-if="tableNumber" class="flex items-center justify-between">
            <span class="text-sm text-gray-500">Emplacement N°</span>
            <span class="font-medium text-gray-900">{{ tableNumber }}</span>
          </div>
          <!-- <div v-for="order   in source" class="flex items-center justify-between">
            <span class="text-sm text-gray-500">Établissement</span>
            <span class="font-medium text-gray-900">{{ establishmentName }}</span>
          </div> -->
          <div class="flex items-center justify-between pt-3 border-t border-gray-200">
            <span class="text-sm text-gray-500">Total</span>
            <span class="font-semibold text-gray-900 text-lg">{{ formatPrice(order?.total_amount) }}</span>
          </div>
        </div>
      </div>

      <!-- Barre de progression (loading states) -->
      <div v-if="['loading', 'pending', 'confirmed', 'processing'].includes(status)" class="px-10 pb-8">
        <div class="flex items-center justify-center gap-2 mb-4">
          <div :class="[
            'w-1.5 h-1.5 rounded-full animate-pulse',
            getStatusDotColor(status)
          ]"></div>
          <span class="text-xs text-gray-500 font-medium">{{ getProgressText(status) }}</span>
        </div>
        <div class="h-1.5 bg-gray-100 rounded-full overflow-hidden">
          <div 
            :class="[
              'h-full rounded-full transition-all duration-1000 ease-out',
              getStatusBarColor(status)
            ]" 
            :style="{ width: progressWidth }"
          ></div>
        </div>
      </div>

      <!-- Actions -->
      <div v-if="status !== 'loading'" class="px-10 pb-10 flex gap-3">
        <button
          v-if="['pending'].includes(status) && cancelable"
          @click="$emit('cancel')"
          class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 active:bg-gray-300 text-gray-900 rounded-full font-medium text-sm transition-all"
        >
          Annuler
        </button>

        <button
          v-if="status === 'completed'"
          @click="$emit('close')"
          class="flex-1 h-12 bg-gray-900 hover:bg-gray-800 active:bg-gray-950 text-white rounded-full font-medium text-sm transition-all"
        >
          Fermer
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue'
import { CheckCircle, Loader2, Clock, Coffee, Check } from 'lucide-vue-next'

const props = defineProps({
  isVisible: Boolean,
  status: {
    type: String,
    default: 'loading',
    validator: (v) => ['loading', 'pending', 'confirmed', 'processing', 'completed'].includes(v)
  },
  message: String,
  cancelable: Boolean,
  order: Object,
  orderNumber: String,
  tableNumber: [String, Number],
  establishmentName: String
})

defineEmits(['close', 'cancel'])

const progressWidth = ref('20%')

watch(() => props.status, (newStatus) => {
  updateProgress(newStatus)
})

onMounted(() => {
  updateProgress(props.status)
})

const updateProgress = (status) => {
  const progressMap = {
    'loading': '25%',
    'pending': '40%',
    'confirmed': '60%',
    'processing': '80%',
    'completed': '100%'
  }
  
  setTimeout(() => {
    progressWidth.value = progressMap[status] || '20%'
  }, 100)
}

const formatPrice = (price) => {
  if (!price || isNaN(price)) return '0 F CFA'
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(Number(price))
}

const getStatusIcon = (status) => {
  switch (status) {
    case 'loading': return Loader2
    case 'pending': return Clock
    case 'confirmed': return Check
    case 'processing': return Coffee
    case 'completed': return CheckCircle
    default: return Loader2
  }
}

const getStatusBg = (status) => {
  switch (status) {
    case 'loading': return 'bg-gray-100'
    case 'pending': return 'bg-yellow-50'
    case 'confirmed': return 'bg-blue-50'
    case 'processing': return 'bg-orange-50'
    case 'completed': return 'bg-green-50'
    default: return 'bg-gray-100'
  }
}

const getStatusColor = (status) => {
  switch (status) {
    case 'loading': return 'text-gray-700'
    case 'pending': return 'text-yellow-600'
    case 'confirmed': return 'text-blue-600'
    case 'processing': return 'text-orange-600'
    case 'completed': return 'text-green-600'
    default: return 'text-gray-700'
  }
}

const getStatusDotColor = (status) => {
  switch (status) {
    case 'loading': return 'bg-gray-500'
    case 'pending': return 'bg-yellow-500'
    case 'confirmed': return 'bg-blue-500'
    case 'processing': return 'bg-orange-500'
    case 'completed': return 'bg-green-500'
    default: return 'bg-gray-500'
  }
}

const getStatusBarColor = (status) => {
  switch (status) {
    case 'loading': return 'bg-gray-500'
    case 'pending': return 'bg-yellow-500'
    case 'confirmed': return 'bg-blue-500'
    case 'processing': return 'bg-orange-500'
    case 'completed': return 'bg-green-500'
    default: return 'bg-gray-500'
  }
}

const getStatusTitle = (status) => {
  switch (status) {
    case 'loading': return 'Envoi en cours...'
    case 'pending': return 'En attente...'
    case 'confirmed': return 'Confirmée'
    case 'processing': return 'En préparation...'
    case 'completed': return 'Terminée'
    default: return 'Commande'
  }
}

const getProgressText = (status) => {
  switch (status) {
    case 'loading': return 'Transmission de la commande'
    case 'pending': return 'Attente de confirmation'
    case 'confirmed': return 'Commande confirmée'
    case 'processing': return 'Préparation en cours'
    case 'completed': return 'Commande prête'
    default: return 'En cours'
  }
}

const defaultMessage = computed(() => {
  switch (props.status) {
    case 'loading': return 'Transmission de votre commande au restaurant'
    case 'pending': return 'Votre commande est en attente de confirmation'
    case 'confirmed': return 'Le restaurant a confirmé votre commande'
    case 'processing': return 'Votre commande est en cours de préparation'
    case 'completed': return 'Votre commande est prête à être servie'
    default: return 'Veuillez patienter'
  }
})
</script>

<style scoped>
/* Animations */
@keyframes spin {
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

/* Transitions */
button {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

button:active {
  transform: scale(0.97);
}

/* Backdrop */
.bg-black\/30 {
  background-color: rgba(0, 0, 0, 0.3);
  animation: fadeIn 0.25s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Modal animation */
.animate-slideUp {
  animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(16px) scale(0.96);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Focus states */
button:focus {
  outline: none;
}

button:focus-visible {
  box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.1);
}
</style>