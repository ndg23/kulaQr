<template>
  <div class="min-h-screen bg-white flex items-center justify-center p-4">
    <div class="max-w-sm w-full text-center">
      <!-- Broken QR Icon -->
      <div class="relative inline-flex items-center justify-center mb-6">
        <!-- Background Circle - Apple Style -->
        <div class="w-24 h-24 bg-gray-100 rounded-3xl flex items-center justify-center relative overflow-hidden">
          <QrCode class="w-12 h-12 text-gray-400" :stroke-width="2" />
          
          <!-- Broken Effect - Diagonal Line -->
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="w-32 h-0.5 bg-red-500 rotate-45 opacity-80"></div>
          </div>
          
          <!-- Alert Badge -->
          <div class="absolute -top-1 -right-1 w-8 h-8 bg-red-500 rounded-full flex items-center justify-center shadow-lg">
            <AlertCircle class="w-5 h-5 text-white" :stroke-width="2.5" />
          </div>
        </div>
      </div>

      <!-- Title - Twitter Bold Style -->
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900 mb-3 tracking-tight">
        {{ title }}
      </h1>

      <!-- Message - Apple Subtle Style -->
      <p class="text-base text-gray-600 mb-8 leading-relaxed px-4">
        {{ message }}
      </p>

      <!-- Action Buttons -->
      <div class="space-y-3 px-4">
        <!-- Primary Button - Apple/Twitter Hybrid -->
        <button
          @click="handleRescan"
          class="w-full bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3.5 px-6 rounded-full transition-all duration-200 active:scale-95 shadow-sm hover:shadow-md flex items-center justify-center gap-2"
        >
          <RefreshCw class="w-5 h-5" :stroke-width="2" />
          <span>{{ buttonText }}</span>
        </button>

        <!-- Secondary Button - Subtle -->
        <button
          @click="handleGoBack"
          class="w-full bg-gray-100 hover:bg-gray-200 text-gray-900 font-medium py-3.5 px-6 rounded-full transition-all duration-200 active:scale-95"
        >
          Retour
        </button>
      </div>

      <!-- Help Text - Twitter Style -->
      <div class="mt-8 pt-8 border-t border-gray-200">
        <p class="text-sm text-gray-500">
          Besoin d'aide ? 
          <button 
            @click="handleContactSupport"
            class="text-blue-500 hover:text-blue-600 font-medium ml-1 transition-colors"
          >
            Contactez le support
          </button>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { QrCode, RefreshCw, AlertCircle } from 'lucide-vue-next'

// Props
interface Props {
  title?: string
  message?: string
  buttonText?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: 'QR Code invalide',
  message: "Le code QR scanné n'est pas valide ou a expiré. Veuillez scanner à nouveau.",
  buttonText: 'Scanner à nouveau'
})

// Emits
const emit = defineEmits(['rescan', 'go-back', 'contact-support'])

// Methods
const handleRescan = () => {
  emit('rescan')
}

const handleGoBack = () => {
  emit('go-back')
}

const handleContactSupport = () => {
  emit('contact-support')
}
</script>

<style scoped>
/* Optional: Add smooth animations */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>