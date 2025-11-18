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
        <span class="text-white text-sm font-mono tracking-wide">Bienvenue chez</span>
      </div>
      
      <!-- Restaurant Name -->
      <h1 class="text-white text-4xl font-bold tracking-tight leading-tight mb-3">
        {{ data.name || 'Etablissement' }}
      </h1>

      <!-- Description -->
      <p class="text-white/90 text-base leading-relaxed mb-4 max-w-md">
        {{ data.description }}

        
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
          class="flex underline items-center bg-white/15 backdrop-blur-md rounded-full px-3 py-2 cursor-pointer hover:bg-white/25 transition-all duration-200 active:scale-95"
          @click="openGoogleMaps"
        >
          <MapPin class="w-4 h-4 mr-2 text-white" :stroke-width="2.5" />
          <span class="text-white text-sm font-medium">{{ data.address }}</span>
        </div>
      </div>
    </div>

    <!-- Logo in top right -->
    <div class="absolute top-4 right-4">
      <div class="bg-white backdrop-blur-xl rounded-xl p-1 border border-white">
        <img
          v-if="data.image_url"
          :src="data.image_url"
          alt="Restaurant logo"
          class="w-10 h-10 rounded-xl object-cover"
          @error="handleLogoError"
        />
        <div v-else class="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center fallback-icon">
          <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
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

const handleLogoError = (e: Event) => {
  const target = e.target as HTMLImageElement
  target.style.display = 'none'
  // Show fallback icon
  const fallbackIcon = target.parentElement?.querySelector('.fallback-icon') as HTMLElement
  if (fallbackIcon) {
    fallbackIcon.style.display = 'flex'
  }
}

// Open Google Maps with coordinates
const openGoogleMaps = () => {
  const { latitude, longitude, address } = props.data
  
  // If we have coordinates, use them for precise location
  if (latitude && longitude) {
    // Google Maps URL with coordinates
    const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`
    window.open(mapsUrl, '_blank')
  } else if (address) {
    // Fallback to address search if no coordinates
    const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`
    window.open(mapsUrl, '_blank')
  }
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

/* Hide fallback icon by default */
.fallback-icon {
  display: none;
}
</style>