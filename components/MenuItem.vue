<template>
  <div
    class="bg-white py-4 px-6 border-b border-gray-100 flex items-center hover:bg-gray-50 transition-colors duration-200"
  >
    <img
      :src="item.imageUrl || '/api/placeholder/80/80'"
      :alt="item.name"
      class="w-20 h-20 object-cover rounded-lg mr-4"
    />
    <div class="flex-grow">
      <h3 class="text-lg font-mono font-medium text-gray-800 mb-1">{{ item.name }}</h3>
      <p class="text-sm font-mono text-gray-500 mb-2 line-clamp-2">{{ item.description }}</p>
      <span class="text-lg font-mono font-medium text-gray-700">€{{ item.price.toFixed(2) }}</span>
    </div>
    <button
      @click="$emit('add', item)"
      class="ml-4 bg-gray-100 text-gray-800 rounded-full w-8 h-8 flex items-center justify-center focus:outline-none hover:bg-gray-200"
    >
      <Icon name="plus" size="18" />
    </button>
  </div>
</template>

<script setup lang="ts">
import type { Product } from '~/types'

defineProps<{
  item: Product
}>()

defineEmits<{
  (e: 'add', item: Product): void
}>()

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(price)
}
</script> 