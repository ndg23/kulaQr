<template>
  <button
    @click="$emit('click')"
    class="w-full text-left py-5 px-6 cursor-pointer flex items-center transition-colors duration-300 border-b border-gray-200"
    :class="{ 'bg-gray-50': isActive, 'bg-white': !isActive }"
  >
    <div class="flex items-center">
      <div class="w-10 h-10 mr-3 rounded-lg overflow-hidden bg-gray-100 flex-shrink-0 flex items-center justify-center">
        <img 
          v-if="category.image_url" 
          :src="category.image_url" 
          :alt="category.name" 
          class="w-full h-full object-cover"
          @error="handleImageError"
        />
        <component 
          v-else
          :is="getCategoryIcon(category.icon)" 
          class="w-5 h-5 text-gray-500" 
        />
      </div>
      <span class="text-lg font-mono font-medium text-gray-800">{{ category.name }}</span>
    </div>
    
    <div class="ml-auto text-gray-400">
      <ChevronDown 
        class="w-6 h-6 transition-transform" 
        :class="{ 'transform rotate-180': isActive }"
      />
    </div>
  </button>
</template>

<script setup lang="ts">
import { 
  ChevronDown, 
  Coffee, 
  UtensilsCrossed, 
  Pizza, 
  Wine, 
  IceCream, 
  Salad, 
  Sandwich
} from 'lucide-vue-next'
import type { Category } from '~/types'

const props = defineProps({
  category: {
    type: Object,
    required: true
  },
  isActive: {
    type: Boolean,
    default: false
  },
  defaultImage: {
    type: String,
    default: '/images/default-category.jpg'
  }
})

defineEmits(['click'])

// Map of category icons
const categoryIcons = {
  'coffee': Coffee,
  'utensils': UtensilsCrossed,
  'pizza': Pizza,
  'wine': Wine,
  'ice-cream': IceCream,
  'salad': Salad,
  'sandwich': Sandwich,
  'default': UtensilsCrossed
}

// Get the appropriate icon component
const getCategoryIcon = (iconName) => {
  return categoryIcons[iconName] || categoryIcons.default
}

// Handle image loading error
const handleImageError = (e) => {
  // Hide the image and show the icon instead
  e.target.style.display = 'none'
  e.target.parentElement.classList.add('icon-fallback')
}
</script>

<style scoped>
.icon-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style> 