<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
      <CustomToast />

      <!-- Scroll to Top Button -->
      <button
        v-if="showScrollTop"
        @click="scrollToTop"
        class="fixed bottom-6 right-6 z-50 w-12 h-12 bg-white border border-gray-200 rounded-full shadow-lg hover:shadow-xl text-gray-700 hover:text-gray-900 transition-all duration-300 ease-in-out focus:outline-none focus:ring-2 focus:ring-gray-200 focus:ring-offset-2 flex items-center justify-center group"
        aria-label="Remonter en haut de la page"
      >
        <svg
          class="w-5 h-5 transition-transform duration-300 ease-in-out group-hover:-translate-y-0.5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 10l7-7m0 0l7 7m-7-7v18"
          />
        </svg>
      </button>
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// Configuration globale de l'application

// Scroll to top functionality
const showScrollTop = ref(false)

// Show/hide scroll to top button based on scroll position
const handleScroll = () => {
  showScrollTop.value = window.scrollY > 300
}

// Scroll to top function
const scrollToTop = () => {
  window.scrollTo({
    top: 0,
    behavior: 'smooth'
  })
}

// Add scroll event listener
onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

// Remove scroll event listener
onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>
<style scoped>
@font-face {
  font-family: 'Arial Rounded MT Bold';
  src: url('~/assets/fonts/ArialRoundedMTBold.ttf') format('truetype');
  font-weight: bold;
  font-style: normal;
}

.font-logo {
  font-family: 'Arial Rounded MT Bold', system-ui, -apple-system, sans-serif;
}

</style>
