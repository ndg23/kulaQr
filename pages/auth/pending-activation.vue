<template>
  <div class="min-h-screen flex items-center justify-center p-6 bg-white">
    <div class="w-full max-w-lg">
      <!-- Minimalist Success Card -->
      <div class="text-center space-y-10">
        <!-- Success Checkmark with Subtle Animation -->
        <div class="inline-flex items-center justify-center">
          <div class="relative">
            <!-- Pulse rings -->
            <div class="absolute inset-0 w-20 h-20 bg-green-500 rounded-full opacity-20 animate-ping-slow"></div>
            <div class="absolute inset-0 w-20 h-20 bg-green-500 rounded-full opacity-10 animate-ping-slower"></div>
            
            <!-- Main checkmark -->
            <div class="relative w-20 h-20 bg-green-500 rounded-full flex items-center justify-center animate-scale-in shadow-lg shadow-green-500/20">
              <svg class="w-11 h-11 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                <path 
                  stroke-linecap="round" 
                  stroke-linejoin="round" 
                  d="M5 13l4 4L19 7"
                  class="animate-draw-check"
                />
              </svg>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="space-y-10">
          <!-- Title -->
          <div class="space-y-4">
            <h1 class="text-5xl font-bold text-gray-900 tracking-tight">
              Compte créé
            </h1>
            <p class="text-xl text-gray-500 font-light">
              Votre compte est en attente d'activation
            </p>
          </div>

          <!-- Elegant Divider -->
          <div class="flex items-center justify-center gap-2">
            <div class="w-1 h-1 bg-gray-300 rounded-full"></div>
            <div class="w-1 h-1 bg-gray-300 rounded-full"></div>
            <div class="w-1 h-1 bg-gray-300 rounded-full"></div>
          </div>

          <!-- Main Message -->
          <div class="max-w-md mx-auto">
            <p v-if="userName || userEmail" class="text-lg text-gray-600 leading-relaxed font-light mb-4">
              <span v-if="userName" class="block font-medium text-gray-900 mb-2">Bonjour {{ userName }},</span>
              <span v-if="userEmail" class="block text-base text-gray-500 mb-3">{{ userEmail }}</span>
            </p>
            <p class="text-lg text-gray-600 leading-relaxed font-light">
              Notre équipe examine votre demande. Vous recevrez une  confirmation dans les <span class="font-medium text-gray-900">24 heures</span>.
            </p>
          </div>

          <!-- Actions -->
          <div class="max-w-sm mx-auto space-y-3 pt-4">
            <a
              href="tel:+221783835597"
              class="block w-full px-6 py-4 bg-black text-white rounded-full font-medium hover:bg-gray-900 transition-all duration-200 hover:shadow-lg hover:shadow-gray-900/10 hover:scale-[1.02] active:scale-[0.98]"
            >
              Nous contacter
            </a>
            
            <NuxtLink
              to="/auth/login"
              class="block w-full px-6 py-4 bg-white text-gray-700 rounded-full font-medium border-2 border-gray-200 hover:border-gray-300 hover:bg-gray-50 transition-all duration-200"
            >
              Retour à la connexion
            </NuxtLink>
          </div>
        </div>

        <!-- Subtle Footer Info -->
        <div class="pt-8">
          <p class="text-sm text-gray-400 font-light">
            Support : <a href="tel:+221783835597" class="text-gray-600 hover:text-gray-900 transition-colors">+221 78 383 55 97</a>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
})

const route = useRoute()

// Récupérer les paramètres de l'URL
const userName = computed(() => route.query.name as string || '')
const userEmail = computed(() => route.query.email as string || '')
</script>

<style scoped>
@keyframes scale-in {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes draw-check {
  0% {
    stroke-dasharray: 0, 100;
  }
  100% {
    stroke-dasharray: 100, 0;
  }
}

@keyframes ping-slow {
  0% {
    transform: scale(1);
    opacity: 0.2;
  }
  50% {
    opacity: 0.1;
  }
  100% {
    transform: scale(1.4);
    opacity: 0;
  }
}

@keyframes ping-slower {
  0% {
    transform: scale(1);
    opacity: 0.1;
  }
  50% {
    opacity: 0.05;
  }
  100% {
    transform: scale(1.6);
    opacity: 0;
  }
}

.animate-scale-in {
  animation: scale-in 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.animate-draw-check {
  stroke-dasharray: 100;
  animation: draw-check 0.5s ease-out 0.25s forwards;
}

.animate-ping-slow {
  animation: ping-slow 2s cubic-bezier(0, 0, 0.2, 1) infinite;
}

.animate-ping-slower {
  animation: ping-slower 2s cubic-bezier(0, 0, 0.2, 1) infinite 0.5s;
}
</style>