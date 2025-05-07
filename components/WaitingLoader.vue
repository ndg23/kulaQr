<template>
  <div 
    v-if="isVisible"
    class="fixed inset-0 bg-white bg-opacity-90 backdrop-blur-sm z-[60] flex flex-col items-center justify-center"
  >
    <div class="bg-white p-8 rounded-2xl shadow-lg max-w-sm w-full mx-4 text-center space-y-4">
      <div class="w-16 h-16 mx-auto relative">
        <LoaderCircle 
          v-if="status === 'loading' || status === 'waiting'"
          class="w-full h-full text-gray-200 animate-spin" 
        />
        <CheckCircle 
          v-if="status === 'success'"
          class="absolute inset-0 w-full h-full text-green-500 animate-scale-in" 
        />
        <XCircle 
          v-if="status === 'rejected'"
          class="absolute inset-0 w-full h-full text-red-500 animate-scale-in" 
        />
      </div>
      
      <div class="space-y-2">
        <h3 class="text-lg font-medium text-gray-900">
          {{ statusMessages[status] }}
        </h3>
        <p class="text-gray-500 text-sm">
          {{ subMessages[status] }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { LoaderCircle, CheckCircle, XCircle } from 'lucide-vue-next'

const props = defineProps<{
  isVisible: boolean
  status?: 'loading' | 'waiting' | 'success' | 'rejected'
}>()

const statusMessages = {
  loading: 'Envoi de votre commande...',
  waiting: 'En attente de confirmation...',
  success: 'Commande confirmée !',
  rejected: 'Commande refusée'
}

const subMessages = {
  loading: 'Veuillez patienter pendant que nous traitons votre commande',
  waiting: 'Le restaurant examine votre commande',
  success: 'Votre commande a été acceptée et est en cours de préparation',
  rejected: 'Votre commande a été refusée par le restaurant'
}
</script>

<style scoped>
.animate-scale-in {
  animation: scale-in 0.3s ease-out forwards;
}

@keyframes scale-in {
  from { transform: scale(0.5); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
</style> 