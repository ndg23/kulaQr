<template>
  <div v-if="show" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-2xl max-w-md w-full p-6">
      <div class="text-center">
        <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Clock class="w-8 h-8 text-blue-600" />
        </div>
        
        <h3 class="text-xl font-bold text-gray-900 mb-2">
          Continuer votre commande
        </h3>
        
        <p class="text-gray-600 mb-6">
          Vous aviez {{ sessionInfo?.totalItems }} article{{ sessionInfo?.totalItems > 1 ? 's' : '' }} 
          dans votre panier {{ sessionInfo?.timeAgo }}.
          {{ sessionInfo?.tableNumber ? `Table ${sessionInfo.tableNumber}.` : '' }}
        </p>
        
        <div class="space-y-3">
          <button
            @click="continueOrder"
            class="w-full py-3 bg-blue-500 text-white rounded-xl font-semibold hover:bg-blue-600 transition-colors"
          >
            Continuer la commande
          </button>
          
          <button
            @click="startNew"
            class="w-full py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
          >
            Commencer une nouvelle commande
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Clock } from 'lucide-vue-next'

const props = defineProps<{
  show: boolean
  sessionInfo: any
}>()

const emit = defineEmits<{
  continue: []
  startNew: []
}>()

const continueOrder = () => {
  emit('continue')
}

const startNew = () => {
  emit('startNew')
}
</script>
