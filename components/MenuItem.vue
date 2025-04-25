<template>
  <div
    class="bg-white py-4 px-6 border-b border-gray-100 flex items-center hover:bg-gray-50 transition-colors duration-200"
  >
    <div class="w-20 h-20 rounded-lg overflow-hidden bg-gray-100 mr-4 flex items-center justify-center">
      <img
        v-if="item.image_url"
        :src="item.image_url"
        :alt="item.name"
        class="w-full h-full object-cover"
        @error="handleImageError"
      />
      <UtensilsCrossed v-else class="w-6 h-6 text-gray-300" />
    </div>
    
    <div class="flex-grow">
      <h3 class="text-lg font-mono font-medium text-gray-800 mb-1">{{ item.name }}</h3>
      <p class="text-sm font-mono text-gray-500 mb-2 line-clamp-2">{{ item.description || '' }}</p>
      <span class="text-lg font-mono font-medium text-gray-700">{{ formatPrice(item.price) }}</span>
      
      <!-- Allergens if available -->
      <div v-if="item.allergens && item.allergens.length > 0" class="mt-1">
        <div class="flex flex-wrap gap-1">
          <span 
            v-for="allergen in item.allergens" 
            :key="allergen"
            class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full"
          >
            {{ allergen }}
          </span>
        </div>
      </div>
    </div>
    
    <button
      @click="$emit('add', item)"
      class="ml-4 bg-gray-100 text-gray-800 rounded-full w-8 h-8 flex items-center justify-center focus:outline-none hover:bg-gray-200"
    >
      <Plus class="w-4 h-4" />
    </button>
  </div>
</template>

<script setup lang="ts">
import { Plus, UtensilsCrossed } from 'lucide-vue-next'
import type { Product } from '~/types'

const props = defineProps({
  item: {
    type: Object,
    required: true
  },
  defaultImage: {
    type: String,
    default: '/images/default-product.jpg'
  }
})

defineEmits(['add'])

// Format price to EUR
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

// Handle image loading error
const handleImageError = (e) => {
  // Hide the image and show the icon instead
  e.target.style.display = 'none'
  e.target.parentElement.classList.add('icon-fallback')
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.icon-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style> 