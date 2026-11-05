<template>
  <div class="relative overflow-hidden rounded-b-[2rem]">
    <div class="h-64 w-full relative">
      <img
        :src="data.cover_image || defaultImage"
        alt="Couverture de l'établissement"
        class="w-full h-full object-cover"
        @error="handleImageError"
      />
      <div class="absolute inset-0 bg-gradient-to-b from-black/10 via-black/40 to-black/85"></div>
    </div>

    <!-- Logo en haut à droite -->
    <div class="absolute top-4 right-4">
      <div class="w-14 h-14 rounded-full bg-white p-1 shadow-lg">
        <img
          v-if="data.image_url"
          :src="data.image_url"
          alt="Logo"
          class="w-full h-full rounded-full object-cover"
          @error="handleLogoError"
        />
        <div v-else class="w-full h-full rounded-full bg-[#FB6A00] flex items-center justify-center fallback-icon">
          <span class="text-xl font-black text-black">{{ (data.name || 'K').charAt(0).toUpperCase() }}</span>
        </div>
      </div>
    </div>

    <!-- Nom, description, infos en pilules -->
    <div class="absolute bottom-0 left-0 right-0 px-5 pb-6">
      <span class="inline-flex items-center h-7 px-3 rounded-full bg-[#FB6A00] text-black text-xs font-black mb-2">Bienvenue chez</span>
      <h1 class="text-white text-4xl font-black tracking-tight leading-tight mb-2 break-words">{{ data.name || 'Établissement' }}</h1>
      <p v-if="data.description" class="text-white/90 text-sm font-medium leading-relaxed mb-3 max-w-md line-clamp-2">{{ data.description }}</p>

      <div class="flex flex-wrap gap-2">
        <span v-if="data.opening_hours" class="inline-flex items-center gap-2 h-9 px-4 rounded-full bg-white text-black text-xs font-extrabold">
          <Clock class="w-4 h-4" :stroke-width="2.5" />
          {{ data.opening_hours }}
        </span>
        <button
          v-if="data.address"
          type="button"
          class="inline-flex items-center gap-2 h-9 px-4 rounded-full bg-white text-black text-xs font-extrabold active:scale-[0.96] transition-all max-w-full"
          @click="openGoogleMaps"
        >
          <MapPin class="w-4 h-4 flex-shrink-0" :stroke-width="2.5" />
          <span class="truncate">{{ data.address }}</span>
        </button>
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