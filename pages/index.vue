<template>
  <div class="min-h-screen bg-white">
    <!-- Navigation -->
    <nav class="fixed w-full bg-white/80 backdrop-blur-md z-50">
      <div class="max-w-[1200px] mx-auto px-8">
        <div class="flex justify-between h-[44px] items-center">
          <div class="flex items-center space-x-2">
            <span class="text-xl font-medium">KulaQr</span>
          </div>
          <div class="hidden md:flex items-center space-x-10">
            <NuxtLink 
              v-for="item in navItems" 
              :key="item.name"
              :to="item.to"
              class="text-sm text-gray-600 hover:text-gray-900 transition-colors"
            >
              {{ item.name }}
            </NuxtLink>
          </div>
          <NuxtLink
            to="/login"
            class="hidden md:block text-sm text-blue-500 hover:text-blue-600 transition-colors"
          >
            Connexion
          </NuxtLink>
          <button class="md:hidden">
            <Menu class="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <section class="pt-[120px] pb-[80px]">
      <div class="max-w-[980px] mx-auto px-8 text-center">
        <h1 class="text-[48px] md:text-[72px] font-semibold leading-tight text-gray-900">
          La commande au restaurant,<br/>
          <span class="text-blue-500">simplifiée.</span>
        </h1>
        <p class="mt-6 text-xl md:text-2xl text-gray-500 max-w-[600px] mx-auto">
          Transformez l'expérience de vos clients avec des QR codes intelligents
        </p>
        <div class="mt-10">
          <NuxtLink
            to="/register"
            class="inline-flex text-lg text-blue-500 hover:text-blue-600 transition-colors"
          >
            Commencer gratuitement <ArrowRight class="w-5 h-5 ml-1" />
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Preview Section -->
    <section class="py-[120px] bg-gray-50">
      <div class="max-w-[1200px] mx-auto px-8">
        <img
          src="https://images.unsplash.com/photo-1504674900247-0877df9cc836"
          alt="Dashboard Preview"
          class="rounded-2xl shadow-xl w-full"
        />
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-[120px]">
      <div class="max-w-[980px] mx-auto px-8">
        <h2 class="text-[40px] md:text-[48px] font-semibold text-center text-gray-900 mb-[60px]">
          Tout ce dont vous avez besoin
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-16">
          <div 
            v-for="feature in features" 
            :key="feature.title"
            class="text-center"
          >
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-full" :class="feature.bgColor">
              <component :is="feature.icon" class="w-8 h-8" :class="feature.iconColor" />
            </div>
            <h3 class="mt-6 text-xl font-semibold text-gray-900">
              {{ feature.title }}
            </h3>
            <p class="mt-3 text-gray-500">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="py-[120px] bg-gray-50">
      <div class="max-w-[980px] mx-auto px-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-16 text-center">
          <div v-for="stat in stats" :key="stat.value">
            <div class="text-[56px] font-semibold text-gray-900">{{ stat.value }}</div>
            <div class="mt-2 text-gray-500">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-[120px]">
      <div class="max-w-[600px] mx-auto px-8 text-center">
        <h2 class="text-[40px] font-semibold text-gray-900">
          Prêt à commencer ?
        </h2>
        <p class="mt-4 text-xl text-gray-500">
          Essayez KulaQr gratuitement pendant 14 jours
        </p>
        <div class="mt-10">
          <NuxtLink
            to="/register"
            class="inline-flex items-center px-8 py-4 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors"
          >
            Commencer maintenant
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import {
  QrCode,
  Clock,
  ChartBar,
  Menu,
  ArrowRight,
  Play,
  Shield,
  Heart,
  MessageCircle
} from 'lucide-vue-next'

const navItems = [
  { name: 'Fonctionnalités', to: '#features' },
  { name: 'Tarifs', to: '#pricing' },
  { name: 'Contact', to: '#contact' }
]

const features = [
  {
    title: 'QR Codes Personnalisés',
    description: 'Générez des QR codes uniques pour chaque table avec votre identité visuelle',
    icon: QrCode,
    bgColor: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  {
    title: 'Commandes en Temps Réel',
    description: 'Suivez et gérez vos commandes instantanément depuis votre tableau de bord',
    icon: Clock,
    bgColor: 'bg-emerald-50',
    iconColor: 'text-emerald-500'
  },
  {
    title: 'Analyses Détaillées',
    description: 'Obtenez des insights précieux sur vos ventes et le comportement client',
    icon: ChartBar,
    bgColor: 'bg-purple-50',
    iconColor: 'text-purple-500'
  }
]

const stats = [
  { value: '2000+', label: 'Restaurants' },
  { value: '1M+', label: 'Commandes traitées' },
  { value: '98%', label: 'Satisfaction client' }
]
</script>

<style>
.backdrop-blur-md {
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

/* Smooth scroll behavior */
html {
  scroll-behavior: smooth;
}
</style>