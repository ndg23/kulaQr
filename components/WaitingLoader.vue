<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/40 backdrop-blur-sm">
    <div class="bg-white rounded-t-[2rem] sm:rounded-[2rem] shadow-2xl max-w-sm w-full overflow-hidden animate-slideUp pb-[env(safe-area-inset-bottom)]">
      <div class="px-8 pt-8 pb-6 text-center">
        <span :class="['w-20 h-20 mx-auto rounded-full flex items-center justify-center', getStatusBg(status)]">
          <component :is="getStatusIcon(status)" :class="[status === 'loading' ? 'w-8 h-8 animate-spin' : 'w-9 h-9', getStatusColor(status)]" :stroke-width="2.75" />
        </span>
        <h2 class="mt-5 text-3xl font-black text-gray-900 tracking-tight">{{ getStatusTitle(status) }}</h2>
        <p class="mt-2 text-gray-500 text-base font-medium leading-relaxed">{{ message || defaultMessage }}</p>
      </div>

      <div v-if="order && status !== 'loading'" class="px-8 pb-5">
        <div class="rounded-[2rem] bg-gray-100 p-4 space-y-2">
          <div class="flex items-center justify-between">
            <span class="text-sm font-semibold text-gray-500">Commande</span>
            <span class="font-black text-gray-900">#{{ orderNumber }}</span>
          </div>
          <div v-if="tableNumber" class="flex items-center justify-between">
            <span class="text-sm font-semibold text-gray-500">Table</span>
            <span class="font-black text-gray-900">{{ tableNumber }}</span>
          </div>
        </div>
        <div class="mt-2 flex items-center justify-between rounded-full bg-[#FB6A00] px-5 h-14">
          <span class="text-sm font-extrabold text-black">Total</span>
          <span class="text-xl font-black text-black tabular-nums">{{ formatPrice(order?.total_amount) }}</span>
        </div>
      </div>

      <div v-if="['loading', 'pending', 'confirmed', 'processing'].includes(status)" class="px-8 pb-6">
        <div class="flex items-center justify-center gap-2 mb-3">
          <span class="w-1.5 h-1.5 rounded-full bg-[#FB6A00] animate-pulse"></span>
          <span class="text-xs text-gray-500 font-extrabold">{{ getProgressText(status) }}</span>
        </div>
        <div class="h-2 bg-gray-100 rounded-full overflow-hidden">
          <div class="h-full rounded-full bg-[#FB6A00] transition-all duration-1000 ease-out" :style="{ width: progressWidth }"></div>
        </div>
      </div>

      <div v-if="status !== 'loading'" class="px-8 pb-8 flex gap-3">
        <button v-if="['pending'].includes(status) && cancelable" type="button" class="flex-1 h-14 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-900 font-extrabold text-sm" @click="$emit('cancel')">Annuler</button>
        <button v-if="status === 'completed'" type="button" class="flex-1 h-14 rounded-full bg-black text-white font-black uppercase text-sm" @click="$emit('close')">Fermer</button>
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
    case 'pending': return 'bg-[#FFECD8]'
    case 'confirmed': return 'bg-black'
    case 'processing': return 'bg-[#FFECD8]'
    case 'completed': return 'bg-[#FB6A00]'
    default: return 'bg-gray-100'
  }
}

const getStatusColor = (status) => {
  switch (status) {
    case 'loading': return 'text-gray-700'
    case 'pending': return 'text-[#C54E00]'
    case 'confirmed': return 'text-white'
    case 'processing': return 'text-[#C54E00]'
    case 'completed': return 'text-black'
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