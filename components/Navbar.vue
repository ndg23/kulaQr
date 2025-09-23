<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-xl border-b border-gray-100/50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <div class="flex items-center">
          <NuxtLink to="/" class="flex items-center space-x-2 group">
            <div class="w-8 h-8 bg-black rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform duration-200">
              <span class="text-white text-sm font-bold">KQ</span>
            </div>
            <span class="text-xl font-semibold text-gray-900 group-hover:text-gray-700 transition-colors">
              KulaQr
            </span>
          </NuxtLink>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-8">
          <a href="#features" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Fonctionnalités
          </a>
          <a href="#pricing" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Tarifs
          </a>
          <a href="#testimonials" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Témoignages
          </a>
          <a href="#contact" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Contact
          </a>
        </div>

        <!-- Desktop CTA Buttons -->
        <div class="hidden md:flex items-center space-x-4">
          <NuxtLink 
            to="/auth/login" 
            class="text-gray-600 hover:text-gray-900 transition-colors font-medium"
          >
            Se connecter
          </NuxtLink>
          <NuxtLink 
            to="/auth/register"
            class="bg-black text-white px-6 py-2 rounded-full font-medium hover:bg-gray-800 transition-colors shadow-sm hover:shadow-md"
          >
            Commencer
          </NuxtLink>
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden">
          <button 
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="text-gray-600 hover:text-gray-900 transition-colors p-2"
          >
            <svg v-if="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
            <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile Navigation Menu -->
      <div v-if="mobileMenuOpen" class="md:hidden border-t border-gray-100 bg-white/95 backdrop-blur-xl">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <a href="#features" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Fonctionnalités
          </a>
          <a href="#pricing" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Tarifs
          </a>
          <a href="#testimonials" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Témoignages
          </a>
          <a href="#contact" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Contact
          </a>
          <div class="border-t border-gray-100 pt-4 mt-4">
            <NuxtLink 
              to="/auth/login" 
              @click="mobileMenuOpen = false"
              class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
            >
              Se connecter
            </NuxtLink>
            <NuxtLink 
              to="/auth/register"
              @click="mobileMenuOpen = false"
              class="block mx-3 mt-2 bg-black text-white px-4 py-2 rounded-full font-medium hover:bg-gray-800 transition-colors text-center"
            >
              Commencer
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
// Mobile menu state
const mobileMenuOpen = ref(false)

// Close mobile menu when clicking outside
onMounted(() => {
  const handleClickOutside = (event: Event) => {
    const target = event.target as HTMLElement
    if (mobileMenuOpen.value && !target.closest('nav')) {
      mobileMenuOpen.value = false
    }
  }
  
  document.addEventListener('click', handleClickOutside)
  
  onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside)
  })
})
</script>

<style scoped>
/* Smooth scrolling for anchor links */
a[href^="#"] {
  scroll-behavior: smooth;
}
</style>
