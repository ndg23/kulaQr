<template>
  <button
    @click="$emit('click')"
    class="w-full text-left hover:bg-gray-50 active:bg-gray-100 transition-all duration-200 border-b border-gray-300 last:border-b-0"
  >
    <div class="px-4 py-4 flex items-center gap-3">
      <!-- Category Image/Icon - Apple Style -->
      <div 
        class="relative w-16 h-16 rounded-2xl overflow-hidden bg-gradient-to-br from-gray-100 to-gray-50 flex-shrink-0 flex items-center justify-center ring-1 ring-gray-200/50"
        :class="{ 'ring-2 ring-blue-500/30': isActive }"
      >
        <img 
          v-if="category.image_url && !imageError" 
          :src="category.image_url" 
          :alt="category.name" 
          class="w-full h-full object-cover"
          @error="handleImageError"
        />
        <component 
          v-else
          :is="getCategoryIcon(category.icon)" 
          class="w-10 h-10 transition-colors"
          :class="isActive ? 'text-blue-500' : 'text-gray-500'"
          :stroke-width="2"
        />
      </div>
      
      <!-- Category Info - Twitter/X Style -->
      <div class="flex-1 min-w-0">
        <div class="flex items-baseline gap-2">
          <h3 
            class="text-2xl font-mono transition-colors truncate"
            :class="isActive ? 'text-blue-500' : 'text-black -800'"
          >
            {{ category.name }}
          </h3>
          <!-- Item Count Badge -->
          <span 
            v-if="itemCount !== undefined"
            class="text-lg text-gray-500 font-medium"
            :class="isActive 
              ? ' text-blue-500' 
              : 'b text-gray-600'"
          >
            ({{ itemCount }})
          </span>
        </div>
        
        <!-- Optional Description -->
        <p 
          v-if="category.description" 
          class="text-sm text-gray-500 mt-0.5 line-clamp-1"
        >
          {{ category.description }}
        </p>
      </div>
      
      <!-- Chevron Indicator - Minimal -->
      <div class="flex-shrink-0">
        <ChevronDown 
          class="w-5 h-5 transition-all duration-200"
          :class="isActive 
            ? 'transform rotate-180 text-red-500' 
            : 'text-gray-400'"
          :stroke-width="2"
        />
      </div>
    </div>

    <!-- Active Indicator Bar - iOS Style -->
    <div 
      v-if="isActive"
      class="h-0.3 bg-gradient-to-r from-red-500 to-red-400 transition-all duration-300"
    ></div>
  </button>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { 
  ChevronDown, 
  Coffee, 
  UtensilsCrossed, 
  Pizza, 
  Wine, 
  IceCream2 as IceCream,
  Salad, 
  Sandwich,
  Soup,
  Cookie,
  CakeSlice,
  Fish,
  Beef,
  Drumstick
} from 'lucide-vue-next'

interface Props {
  category: {
    id?: string
    name: string
    image_url?: string
    icon?: string
    description?: string
  }
  isActive?: boolean
  itemCount?: number
  defaultImage?: string
}

const props = withDefaults(defineProps<Props>(), {
  isActive: false,
  defaultImage: '/images/default-category.jpg'
})

defineEmits(['click'])

// Image error state
const imageError = ref(false)

// Extended category icons map - More options
const categoryIcons = {
  'coffee': Coffee,
  'utensils': UtensilsCrossed,
  'pizza': Pizza,
  'wine': Wine,
  'ice-cream': IceCream,
  'salad': Salad,
  'sandwich': Sandwich,
  'soup': Soup,
  'cookie': Cookie,
  'cake': CakeSlice,
  'fish': Fish,
  'beef': Beef,
  'drumstick': Drumstick,
  'dessert': CakeSlice,
  'beverage': Coffee,
  'appetizer': Salad,
  'main': UtensilsCrossed,
  'default': UtensilsCrossed
}

// Get the appropriate icon component
const getCategoryIcon = (iconName?: string) => {
  if (!iconName) return categoryIcons.default
  return categoryIcons[iconName.toLowerCase()] || categoryIcons.default
}

// Handle image loading error
const handleImageError = () => {
  imageError.value = true
}
</script>

<style scoped>
/* Smooth gradient animation for active state */
@keyframes shimmer {
  0% {
    background-position: -200% center;
  }
  100% {
    background-position: 200% center;
  }
}

button:active .ring-blue-500\/30 {
  animation: pulse 0.4s ease-out;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.8;
  }
}
</style>