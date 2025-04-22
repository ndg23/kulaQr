<template>
  <div class="min-h-screen bg-white">
    <!-- Navigation -->
    <nav class="fixed w-full bg-white/80 backdrop-blur-xl shadow-sm z-50 border-b border-gray-100">
      <div class="max-w-[1200px] mx-auto">
        <div class="flex justify-between h-[64px] items-center px- lg:px-">
          <NuxtLink to="/" class="flex items-center space-x-">
           <img src="~/assets/icon/logo.png" class="w-[100px] h-[100px] text-white" />
            <span class="text-3xl font-logo">Kula QR</span>
          </NuxtLink>
          
          <div class="hidden md:flex items-center space-x-8">
            <NuxtLink 
              v-for="item in navItems" 
              :key="item.name"
              :to="item.to"
              class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
            >
              {{ item.name }}
            </NuxtLink>
            <NuxtLink
              to="/auth/login"
              class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
            >
              Connexion
            </NuxtLink>
            <NuxtLink
              to="/auth/register"
              class="inline-flex items-center px-4 py-2 bg-gray-900 text-white rounded-lg hover:bg-gray-800 transition-colors text-sm font-medium"
            >
              Démarrer gratuitement
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <!-- Hero Section Repensée -->
    <section class="min-h-screen flex flex-col justify-center relative pt-[64px]">
      <div class="max-w-[1200px] mx-auto px-6 py-24">
        <!-- Hero Content -->
        <div class="grid grid-cols-12 gap-8">
          <!-- Left Content - Span 6 colonnes -->
          <div class="col-span-12 lg:col-span-6 flex flex-col justify-center">
            <h1 class="text-size-mobile lg:text-size-hero font-bold leading-[1.1] mb-8">
              Menu digital pour
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-blue-400">
                restaurants modernes
              </span>
            </h1>
            <p class="text-2xl text-gray-600 mb-12">
              La solution tout-en-un pour digitaliser votre restaurant et augmenter vos ventes de <span class="font-medium text-gray-900">+35%</span>
            </p>
            
            <!-- CTA Buttons -->
            <div class="flex flex-col sm:flex-row gap-4 mb-16">
              <NuxtLink
                to="/auth/register"
                class="px-8 py-4 bg-gray-900 text-white rounded-xl text-lg font-medium hover:bg-gray-800 transition-colors"
              >
                Essayer gratuitement
              </NuxtLink>
              <a 
                href="#demo"
                class="px-8 py-4 bg-gray-50 text-gray-900 rounded-xl text-lg font-medium hover:bg-gray-100 transition-colors"
              >
                Voir la démo
              </a>
            </div>

            <!-- Trust Badges -->
            <div class="grid grid-cols-3 gap-8 py-8 border-t border-gray-100">
              <div>
                <div class="text-3xl font-semibold text-gray-900">2000+</div>
                <div class="text-gray-500">Restaurants</div>
              </div>
              <div>
                <div class="text-3xl font-semibold text-gray-900">1M+</div>
                <div class="text-gray-500">Commandes</div>
              </div>
              <div>
                <div class="text-3xl font-semibold text-gray-900">98%</div>
                <div class="text-gray-500">Satisfaction</div>
              </div>
            </div>
          </div>

          <!-- Right Content - Span 6 colonnes -->
          <div class="col-span-12 lg:col-span-6">
            <div class="aspect-[4/3] rounded-3xl overflow-hidden bg-gray-100">
              <img
                src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
                alt="Restaurant Experience"
                class="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section Repensée -->
    <section class="py-32 bg-gray-50">
      <div class="max-w-[1200px] mx-auto px-6">
        <!-- Section Header -->
        <div class="max-w-3xl mx-auto text-center mb-24">
          <h2 class="text-4xl lg:text-5xl font-semibold mb-6">
            Une expérience client révolutionnaire
          </h2>
          <p class="text-xl text-gray-600">
            Découvrez comment KulaQr transforme la gestion de votre restaurant
          </p>
        </div>

        <!-- Features Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-24">
          <!-- Feature 1 -->
          <div class="space-y-24">
            <div>
              <div class="aspect-[16/9] rounded-3xl overflow-hidden bg-gray-100 mb-8">
                <img
                  src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
                  alt="QR Code Feature"
                  class="w-full h-full object-cover"
                />
              </div>
              <h3 class="text-2xl font-semibold mb-4">QR Codes intelligents</h3>
              <p class="text-gray-600">Générez des QR codes uniques pour chaque table avec votre identité visuelle</p>
            </div>
            <div>
              <div class="aspect-[16/9] rounded-3xl overflow-hidden bg-gray-100 mb-8">
                <img
                  src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
                  alt="Orders Feature"
                  class="w-full h-full object-cover"
                />
              </div>
              <h3 class="text-2xl font-semibold mb-4">Commandes en temps réel</h3>
              <p class="text-gray-600">Suivez et gérez vos commandes instantanément depuis votre tableau de bord</p>
            </div>
          </div>

          <!-- Feature 2 -->
          <div class="space-y-24 lg:mt-48">
            <div>
              <div class="aspect-[16/9] rounded-3xl overflow-hidden bg-gray-100 mb-8">
                <img
                  src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
                  alt="Analytics Feature"
                  class="w-full h-full object-cover"
                />
              </div>
              <h3 class="text-2xl font-semibold mb-4">Analyses détaillées</h3>
              <p class="text-gray-600">Suivez vos performances et optimisez votre menu en temps réel</p>
            </div>
            <div>
              <div class="aspect-[16/9] rounded-3xl overflow-hidden bg-gray-100 mb-8">
                <img
                  src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
                  alt="Security Feature"
                  class="w-full h-full object-cover"
                />
              </div>
              <h3 class="text-2xl font-semibold mb-4">Sécurité avancée</h3>
              <p class="text-gray-600">Protection des données et des paiements avec les dernières technologies</p>
            </div>
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
    <section class="relative py-[120px] overflow-hidden">
      <!-- Motif de fond -->
      <div class="absolute inset-0">
        <div class="absolute inset-0 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:16px_16px] opacity-20" />
        <div class="absolute inset-0 bg-gradient-to-b from-transparent via-gray-50/50 to-gray-50/80" />
      </div>

      <!-- Cercles décoratifs -->
      <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-blue-500/5 rounded-full blur-3xl" />
      <div class="absolute bottom-0 right-1/4 w-[400px] h-[400px] bg-purple-500/5 rounded-full blur-3xl" />
      
      <div class="relative max-w-[600px] mx-auto px-8 text-center">
        <span class="inline-block text-blue-600 font-medium mb-4">
          Prêt à digitaliser votre restaurant ?
        </span>
        <h2 class="text-[40px] md:text-[48px] font-semibold text-gray-900 leading-tight">
          Commencez votre essai gratuit
        </h2>
        <p class="mt-6 text-xl text-gray-600">
          Rejoignez plus de 2000 restaurants qui font confiance à KulaQr. Essai gratuit de 14 jours, sans carte bancaire.
        </p>
        <div class="mt-12 space-y-4">
          <NuxtLink
            to="/auth/register"
            class="inline-flex items-center px-8 py-4 bg-gray-900 text-white rounded-xl hover:bg-gray-800 transition-all transform hover:scale-105 text-lg font-medium"
          >
            Commencer maintenant
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
          <div class="flex items-center justify-center space-x-2 text-sm text-gray-500">
            <Shield class="w-4 h-4" />
            <span>Aucune carte bancaire requise</span>
          </div>
        </div>

        <!-- Trust Metrics -->
        <div class="mt-16 grid grid-cols-3 gap-8 border-t border-gray-100 pt-16">
          <div>
            <div class="font-semibold text-2xl text-gray-900">14 jours</div>
            <div class="mt-1 text-gray-500">d'essai gratuit</div>
          </div>
          <div>
            <div class="font-semibold text-2xl text-gray-900">5 minutes</div>
            <div class="mt-1 text-gray-500">de configuration</div>
          </div>
          <div>
            <div class="font-semibold text-2xl text-gray-900">24/7</div>
            <div class="mt-1 text-gray-500">support client</div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import {
  QrCode,
  ArrowRight,
  Play,
  TrendingUp,
  Users,
  Clock,
  ChartBar,
  Shield,
  Check
} from 'lucide-vue-next'

const navItems = [
  { name: 'Fonctionnalités', to: '#features' },
  { name: 'Tarifs', to: '#pricing' },
  { name: 'Contact', to: '#contact' }
]

const features = [
  {
    title: 'QR Codes Intelligents',
    description: 'Générez des QR codes uniques pour chaque table avec votre identité visuelle',
    icon: QrCode,
    bgColor: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  {
    title: 'Commandes en Direct',
    description: 'Suivez et gérez vos commandes instantanément depuis votre tableau de bord',
    icon: Clock,
    bgColor: 'bg-emerald-50',
    iconColor: 'text-emerald-500'
  },
  {
    title: 'Sécurité Avancée',
    description: 'Protection des données et des paiements avec les dernières technologies',
    icon: Shield,
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

<style scoped>
.backdrop-blur-xl {
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

/* Utilisation des classes Tailwind pour le responsive */
@screen sm {
  .text-size-mobile {
    @apply text-5xl;
  }
  .text-size-hero {
    @apply text-6xl;
  }
}

@screen lg {
  .text-size-mobile {
    @apply text-[64px];
  }
  .text-size-hero {
    @apply text-[80px];
  }
}
</style>