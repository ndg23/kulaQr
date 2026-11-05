<template>
  <div class="px-4 py-2">
    <div class="rounded-[2rem] bg-gray-100 p-3 pr-4 flex items-center gap-3" :class="disabled ? 'opacity-60' : ''">
      <div class="relative w-20 h-20 flex-shrink-0 rounded-3xl overflow-hidden bg-white flex items-center justify-center">
        <img
          v-if="item.image_url"
          :src="item.image_url"
          :alt="item.name"
          class="w-full h-full object-cover"
          loading="lazy"
          @error="handleImageError"
        />
        <UtensilsCrossed v-else class="w-7 h-7 text-gray-300" />
      </div>

      <div class="min-w-0 flex-1">
        <h3 class="text-base font-black text-gray-900 leading-tight break-words">{{ item.name }}</h3>
        <p v-if="item.description" class="text-xs font-medium text-gray-500 mt-0.5 line-clamp-2">{{ item.description }}</p>
        <div v-if="item.allergens && item.allergens.length" class="mt-1 flex flex-wrap gap-1">
          <span v-for="allergen in item.allergens" :key="allergen" class="px-2 h-5 inline-flex items-center rounded-full bg-white text-gray-600 text-[10px] font-extrabold">{{ allergen }}</span>
        </div>
        <span class="mt-1 block text-lg font-black text-[#FB6A00] tabular-nums">{{ formatPrice(item.price) }}</span>
      </div>

      <div class="relative flex-shrink-0">
        <button
          type="button"
          :disabled="disabled"
          :aria-label="`Ajouter ${item.name}`"
          class="w-12 h-12 rounded-full flex items-center justify-center active:scale-[0.92] transition-all"
          :class="disabled ? 'bg-gray-200 text-gray-400 cursor-not-allowed' : 'bg-black text-white'"
          @click="$emit('add', item)"
        >
          <Plus class="w-6 h-6" :stroke-width="3" />
        </button>
        <span
          v-if="quantity > 0"
          class="absolute -top-1.5 -right-1.5 min-w-[22px] h-[22px] px-1.5 rounded-full bg-[#FB6A00] text-black text-xs font-black flex items-center justify-center pointer-events-none"
        >{{ quantity }}</span>
      </div>
    </div>
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
  disabled: {
    type: Boolean,
    default: false
  },
  /** Quantité déjà au panier (pastille orange) */
  quantity: {
    type: Number,
    default: 0
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