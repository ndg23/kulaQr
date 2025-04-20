<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-lg shadow-xl w-full max-w-md">
      <div class="p-6">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold font-mono text-gray-900">Récapitulatif</h2>
          <button 
            @click="$emit('close')"
            class="text-gray-400 hover:text-gray-500"
          >
            <Icon name="x" size="24" />
          </button>
        </div>

        <div class="space-y-4">
          <div class="border-b pb-4">
            <div class="flex justify-between text-sm font-medium text-gray-900">
              <span class="font-mono">Numéro de commande</span>
              <span class="font-mono">{{ order._id }}</span>
            </div>
            <div class="flex justify-between text-sm font-medium text-gray-900 mt-2">
              <span class="font-mono">Statut</span>
              <span 
                class="font-mono"
                :class="{
                  'text-yellow-500': order.status === 'pending',
                  'text-green-500': order.status === 'completed',
                  'text-red-500': order.status === 'cancelled'
                }"
              >
                {{ formatStatus(order.status) }}
              </span>
            </div>
          </div>

          <div class="space-y-2">
            <h3 class="text-lg font-medium font-mono text-gray-900">Articles</h3>
            <div 
              v-for="product in order.products" 
              :key="product.productId"
              class="flex justify-between text-sm text-gray-500 font-mono"
            >
              <span>{{ product.name }} x{{ product.quantity }}</span>
              <span>€{{ (product.price * product.quantity).toFixed(2) }}</span>
            </div>
          </div>

          <div class="border-t pt-4">
            <div class="flex justify-between text-lg font-medium text-gray-900 font-mono">
              <span>Total</span>
              <span>€{{ order.totalAmount.toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { OrderData } from '~/types'

defineProps<{
  order: OrderData
}>()

defineEmits<{
  (e: 'close'): void
}>()

const formatStatus = (status: string) => {
  const statusMap = {
    pending: 'En attente',
    processing: 'En préparation',
    completed: 'Terminée',
    cancelled: 'Annulée'
  }
  return statusMap[status as keyof typeof statusMap] || status
}
</script> 