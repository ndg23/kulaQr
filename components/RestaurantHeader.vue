<template>
  <div class="relative overflow-hidden">
    <!-- Cover Image with Parallax Effect -->
    <div class="h-64 w-full relative">
      <img 
        :src="data.cover_image || defaultImage" 
        alt="Restaurant cover"
        class="w-full h-full object-cover scale-105"
        @error="handleImageError"
      />
      <!-- Refined gradient overlay -->
      <div class="absolute inset-0 bg-gradient-to-b from-black/20 via-black/40 to-black/90"></div>
    </div>
    
    <!-- Restaurant Info - Card Style -->
    <div class="absolute bottom-0 left-0 right-0 px-5 pb-6">
      <!-- Welcome Label -->
      <div class="inline-block mb-2">
        <span class="text-white/70 text-sm font-medium tracking-wide">Vous êtes chez</span>
      </div>
      
      <!-- Restaurant Name -->
      <h1 class="text-white text-4xl font-bold tracking-tight leading-tight mb-3">
        {{ data.name || 'Restaurant' }}
      </h1>

      <!-- Description -->
      <p class="text-white/90 text-base leading-relaxed mb-4 max-w-md">
        {{ data.description || 'Bienvenue' }}
      </p>
      
      <!-- Info Pills -->
      <div class="flex flex-wrap gap-2">
        <div 
          v-if="data.opening_hours" 
          class="flex items-center bg-white/15 backdrop-blur-md rounded-full px-3 py-2"
        >
          <Clock class="w-4 h-4 mr-2 text-white" :stroke-width="2.5" />
          <span class="text-white text-sm font-medium">{{ data.opening_hours }}</span>
        </div>
        
        <div 
          v-if="data.address" 
          class="flex items-center bg-white/15 backdrop-blur-md rounded-full px-3 py-2"
        >
          <MapPin class="w-4 h-4 mr-2 text-white" :stroke-width="2.5" />
          <span class="text-white text-sm font-medium">{{ data.address }}</span>
        </div>
      </div>
    </div>

    <!-- Optional: Status Indicator -->
    <div class="absolute top-4 right-4">
      <div class="bg-white/20 backdrop-blur-xl rounded-full px-4 py-2 border border-white/30">
        <div class="flex items-center">
          <div class="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></div>
          <span class="text-white text-xs font-semibold">Ouvert</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Clock, MapPin } from 'lucide-vue-next'

const props = defineProps({
  data: {
    type: Object,
    required: true
  },
  defaultImage: {
    type: String,
    default: '/images/pexels.jpg'
  }
})

const handleImageError = (e: Event) => {
  const target = e.target as HTMLImageElement
  target.src = props.defaultImage
}
</script>

<style scoped>
/* Optional: Add smooth animation on mount */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.absolute.bottom-0 {
  animation: fadeInUp 0.6s ease-out;
}
</style>