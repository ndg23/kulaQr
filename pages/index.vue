<template>
  <div class="min-h-screen bg-white">
    <!-- Navigation style Apple -->
    <nav class="fixed w-full bg-white/80 backdrop-blur-xl z-50">
      <div class="max-w-[1400px] mx-auto">
        <div class="flex justify-between h-[48px] items-center px-6 lg:px-8">
          <div class="flex items-center space-x-2">
            <span class="text-xl font-semibold">KulaQr</span>
          </div>
          <div class="hidden md:flex items-center space-x-8">
            <NuxtLink 
              v-for="item in navItems" 
              :key="item.name"
              :to="item.to"
              class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
            >
              {{ item.name }}
            </NuxtLink>
          </div>
          <div class="flex items-center space-x-4">
            <NuxtLink
              to="/login"
              class="hidden md:block text-sm text-blue-500 hover:text-blue-600 transition-colors"
            >
              Connexion
            </NuxtLink>
            <button 
              class="md:hidden text-gray-500 hover:text-gray-700"
              @click="mobileMenu = true"
            >
              <Menu class="w-6 h-6" />
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Mobile Menu -->
    <TransitionRoot :show="mobileMenu" as="template">
      <Dialog as="div" class="relative z-50" @close="mobileMenu = false">
        <TransitionChild
          enter="transition-opacity duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="transition-opacity duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30" />
        </TransitionChild>

        <div class="fixed inset-0 z-50 flex">
          <TransitionChild
            enter="transition-transform duration-300"
            enter-from="-translate-x-full"
            enter-to="translate-x-0"
            leave="transition-transform duration-200"
            leave-from="translate-x-0"
            leave-to="-translate-x-full"
          >
            <DialogPanel class="relative flex w-full max-w-xs flex-col overflow-y-auto bg-white pb-12 shadow-xl">
              <!-- Mobile menu content -->
              <div class="px-4 pt-5 pb-2 flex">
                <button
                  type="button"
                  class="-m-2 inline-flex items-center justify-center rounded-md p-2 text-gray-400"
                  @click="mobileMenu = false"
                >
                  <span class="sr-only">Close menu</span>
                  <X class="h-6 w-6" />
                </button>
              </div>

              <div class="space-y-6 px-4 py-6">
                <div class="flow-root">
                  <NuxtLink
                    v-for="item in navItems"
                    :key="item.name"
                    :to="item.to"
                    class="-m-2 block p-2 font-medium text-gray-900"
                    @click="mobileMenu = false"
                  >
                    {{ item.name }}
                  </NuxtLink>
                </div>
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Hero Section style Apple -->
    <section class="relative pt-[88px] overflow-hidden">
      <div class="max-w-[1400px] mx-auto">
        <div class="text-center px-6 lg:px-8">
          <h1 class="text-[40px] sm:text-[56px] lg:text-[80px] font-semibold tracking-tight text-gray-900 leading-[1.1]">
            Menu digital.<br class="hidden sm:block" />
            <span class="bg-gradient-to-r from-blue-600 via-blue-500 to-blue-400 text-transparent bg-clip-text">
              Commande simplifiée.
            </span>
          </h1>
          <p class="mt-6 text-xl sm:text-2xl text-gray-500 max-w-[600px] mx-auto font-light">
            Transformez l'expérience de vos clients avec des QR codes intelligents
          </p>
          <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <NuxtLink
              to="/register"
              class="w-full sm:w-auto inline-flex items-center justify-center px-8 py-4 bg-gray-900 text-white rounded-full hover:bg-gray-800 transition-all"
            >
              Démarrer gratuitement
              <ArrowRight class="w-5 h-5 ml-2" />
            </NuxtLink>
            <a 
              href="#demo"
              class="w-full sm:w-auto inline-flex items-center justify-center px-8 py-4 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <Play class="w-5 h-5 mr-2" />
              Voir la démo
            </a>
          </div>
        </div>

        <!-- Image Hero avec effet parallaxe -->
        <div class="mt-16 sm:mt-24 relative">
          <div class="aspect-[16/9] max-w-[1200px] mx-auto overflow-hidden rounded-t-[2.5rem] shadow-2xl">
            <img
              src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
              alt="Restaurant Experience"
              class="w-full h-full object-cover"
            />
          </div>
          <!-- Éléments flottants -->
          <div class="absolute top-1/4 -right-4 sm:right-8 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg p-4 floating">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center">
                <Check class="w-5 h-5 text-green-500" />
              </div>
              <div class="text-sm">
                <div class="font-medium">Nouvelle commande</div>
                <div class="text-gray-500">Table 12 • 89,50€</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section style Apple -->
    <section class="py-24 sm:py-32">
      <div class="max-w-[980px] mx-auto px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-x-8 gap-y-16">
          <div 
            v-for="feature in features" 
            :key="feature.title"
            class="relative"
          >
            <div class="mb-6">
              <div 
                class="w-12 h-12 rounded-[20px] flex items-center justify-center"
                :class="feature.bgColor"
              >
                <component :is="feature.icon" class="w-6 h-6" :class="feature.iconColor" />
              </div>
            </div>
            <h3 class="text-xl font-semibold text-gray-900">
              {{ feature.title }}
            </h3>
            <p class="mt-3 text-base text-gray-500 leading-relaxed">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Nouvelle section Caractéristiques -->
    <section class="py-[120px] bg-gray-50">
      <div class="max-w-[980px] mx-auto px-8">
        <div class="text-center max-w-[800px] mx-auto mb-20">
          <h2 class="text-[48px] font-bold text-gray-900 leading-tight">
            Une solution complète pour votre établissement
          </h2>
          <p class="mt-6 text-xl text-gray-500">
            Tout ce dont vous avez besoin pour digitaliser votre restaurant et augmenter vos revenus
          </p>
        </div>
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
  MessageCircle,
  Check,
  X
} from 'lucide-vue-next'
import { ref } from 'vue'
import { Dialog, DialogPanel, TransitionChild, TransitionRoot } from '@headlessui/vue'

const mobileMenu = ref(false)

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

/* Animations subtiles */
@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(6deg); }
  50% { transform: translateY(-10px) rotate(6deg); }
}

.floating {
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { 
    transform: translateY(0) rotate(2deg);
    filter: drop-shadow(0 20px 30px rgba(0,0,0,0.15));
  }
  50% { 
    transform: translateY(-20px) rotate(2deg);
    filter: drop-shadow(0 40px 40px rgba(0,0,0,0.15));
  }
}

/* Optimisations mobiles */
@media (max-width: 640px) {
  .floating {
    transform: scale(0.8);
  }
}
</style>