<template>
  <div class="relative">
    <!-- Cover Image -->
    <div class="h-48 w-full relative">
      <img 
        :src="data.cover_image || defaultImage" 
        alt="Restaurant cover"
        class="w-full h-full object-cover"
        @error="handleImageError"
      />
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-black opacity-60"></div>
    </div>
    
    <!-- Restaurant Info -->
    <div class="absolute bottom-0 left-0 w-full p-4 text-white">
      <h1 class="text-2xl font-bold">{{ data.name }}</h1>
      <p class="text-sm opacity-90">{{ data.description || 'Menu digital' }}</p>
      
      <div class="flex items-center mt-2 space-x-4">
        <div v-if="data.opening_hours" class="flex items-center text-xs">
          <Clock class="w-3 h-3 mr-1" />
          <span>{{ data.opening_hours }}</span>
        </div>
        
        <div v-if="data.address" class="flex items-center text-xs">
          <MapPin class="w-3 h-3 mr-1" />
          <span>{{ data.address }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Clock, MapPin } from 'lucide-vue-next'
import { ref } from 'vue'

const props = defineProps({
  data: {
    type: Object,
    required: true
  },
  defaultImage: {
    type: String,
    default: '/images/default-restaurant-cover.jpg'
  }
})

// Handle image loading error
const handleImageError = (e) => {
  e.target.src = props.defaultImage
}
</script> 