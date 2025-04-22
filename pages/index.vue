<template>
  <div class="w-full bg-black text-white">
    <!-- Hero Section with QR Code Focus -->
    <section class="w-full h-[56.25vw] relative flex items-center justify-center bg-black overflow-hidden" style="max-height: 100vh;">
      <div class="absolute inset-0">
        <img 
          src="https://images.unsplash.com/photo-1552566626-52f8b828add9"
          alt="Restaurant ambiance"
          class="w-full h-full object-cover opacity-20"
        />
      </div>
      <div class="relative max-w-6xl mx-auto px-6 z-10 flex flex-col md:flex-row items-center gap-8">
        <!-- Text Content -->
        <div class="text-left text-white space-y-6 md:w-1/2">
          <span class="text-lg font-medium tracking-wide">LA SOLUTION DE MENU DIGITAL</span>
          <h1 class="text-5xl md:text-7xl font-bold tracking-tight">
            Votre menu,<br />en un <span class="text-white bg-black px-2">scan</span>.
          </h1>
          <p class="text-xl md:text-2xl font-light text-gray-300">
            Créez votre menu QR code personnalisé et offrez une expérience moderne à vos clients. Simple, rapide et efficace.
          </p>
          <div class="flex flex-col sm:flex-row items-start gap-6 pt-8">
            <NuxtLink 
              to="/auth/register"
              class="px-8 py-3 bg-white text-black rounded-full text-lg font-medium hover:opacity-90 transition-opacity"
            >
              Commencer gratuitement
            </NuxtLink>
            <a 
              href="#demo"
              class="px-8 py-3 text-white rounded-full text-lg font-medium hover:underline flex items-center"
            >
              <span>Voir la démo</span>
              <ArrowRight class="w-5 h-5 ml-2" />
            </a>
          </div>
        </div>
        
        <!-- QR Code Visualization -->
        <div class="md:w-1/2 flex justify-center items-center">
          <div class="relative">
            <!-- Stylized QR Code -->
            <div class="w-64 h-64 md:w-80 md:h-80 bg-white rounded-3xl p-6 rotate-3 shadow-2xl">
              <div class="w-full h-full grid grid-cols-4 grid-rows-4 gap-2">
                <!-- QR Code Pattern Elements - Stylized -->
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-transparent"></div>
                <div class="col-span-1 row-span-1 bg-black rounded-xl"></div>
              </div>
              
              <!-- Logo Overlay in Center of QR Code -->
              <div class="absolute inset-0 flex items-center justify-center">
                <div class="w-16 h-16 bg-black rounded-2xl flex items-center justify-center">
                  <span class="text-white text-2xl font-bold">KQ</span>
                </div>
              </div>
              
              <!-- Text under QR -->
              <div class="absolute -bottom-12 left-0 right-0 text-center text-white text-lg font-medium">
                Menu Digital
              </div>
            </div>
            
            <!-- Phone Outline showing QR scanning -->
            <div class="absolute -bottom-16 -right-16 w-40 h-64 border-2 border-white/30 rounded-3xl transform -rotate-12 flex items-center justify-center">
              <div class="w-32 h-56 bg-black/70 rounded-2xl border border-white/20">
                <div class="w-full h-full flex items-center justify-center">
                  <QrCode class="w-16 h-16 text-white opacity-70" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="w-full py-24 bg-white text-black">
      <div class="max-w-6xl mx-auto px-6">
        <div class="grid md:grid-cols-2 gap-16 items-center">
          <div class="space-y-8">
            <h2 class="text-4xl md:text-5xl font-semibold tracking-tight">
              Menu QR Code.
              <br />
              <span class="text-gray-500">Simplifié.</span>
            </h2>
            <p class="text-xl text-gray-600 leading-relaxed font-light">
              Créez un menu digital professionnel en quelques clics. Personnalisez votre QR code et offrez une expérience moderne à vos clients.
            </p>
            <ul class="space-y-5 pt-4">
              <li class="flex items-center space-x-4">
                <span class="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-lg">Menu digital responsive</span>
              </li>
              <li class="flex items-center space-x-4">
                <span class="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-lg">QR code personnalisé</span>
              </li>
              <li class="flex items-center space-x-4">
                <span class="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-lg">Mise à jour en temps réel</span>
              </li>
            </ul>
          </div>
          <div class="relative aspect-[16/9]">
            <img 
              src="https://images.unsplash.com/photo-1533777857889-4be7c70b33f7"
              alt="QR Code Demo"
              class="w-full h-full object-cover rounded-2xl shadow-lg"
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="w-full py-24 bg-black text-white">
      <div class="max-w-6xl mx-auto px-6">
        <div class="text-center space-y-6 mb-16">
          <h2 class="text-4xl md:text-5xl font-semibold">Chiffres clés</h2>
          <p class="text-xl text-gray-400 font-light">Des restaurants qui nous font confiance</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
          <div class="text-center space-y-3">
            <div class="text-5xl font-bold">2K+</div>
            <div class="text-gray-400 font-light">Restaurants</div>
          </div>
          <div class="text-center space-y-3">
            <div class="text-5xl font-bold">50K+</div>
            <div class="text-gray-400 font-light">Scans par jour</div>
          </div>
          <div class="text-center space-y-3">
            <div class="text-5xl font-bold">100K+</div>
            <div class="text-gray-400 font-light">Plats servis</div>
          </div>
          <div class="text-center space-y-3">
            <div class="text-5xl font-bold">4.9</div>
            <div class="text-gray-400 font-light">Note moyenne</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Testimonials Section -->
    <section class="w-full py-24 bg-gray-100 text-black">
      <div class="max-w-6xl mx-auto px-6">
        <div class="text-center space-y-6 mb-16">
          <h2 class="text-4xl md:text-5xl font-semibold">Ils nous font confiance</h2>
          <p class="text-xl text-gray-500 font-light">Découvrez ce que nos clients disent de nous</p>
        </div>
        <div class="grid md:grid-cols-3 gap-8">
          <div v-for="testimonial in testimonials" :key="testimonial.name" 
            class="bg-white p-8 rounded-2xl space-y-6"
          >
            <div class="flex items-center space-x-4">
              <img 
                :src="testimonial.image" 
                :alt="testimonial.name"
                class="w-14 h-14 rounded-full object-cover"
              />
              <div>
                <h3 class="font-medium text-lg">{{ testimonial.name }}</h3>
                <p class="text-gray-500">{{ testimonial.role }}</p>
              </div>
            </div>
            <p class="text-gray-600 leading-relaxed">{{ testimonial.text }}</p>
            <div class="flex text-yellow-500">
              <Star v-for="i in 5" :key="i" class="w-5 h-5" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="w-full py-24 bg-black text-white aspect-[16/9] flex items-center justify-center" style="max-height: 80vh;">
      <div class="text-center space-y-8 max-w-3xl px-6">
        <h2 class="text-4xl md:text-6xl font-semibold">Prêt à commencer ?</h2>
        <p class="text-xl text-gray-400 font-light">
          Rejoignez les milliers de restaurants qui utilisent déjà KulaQr pour digitaliser leur menu
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-6 pt-6">
          <NuxtLink 
            to="/auth/register"
            class="px-8 py-3 bg-white text-black rounded-full text-lg font-medium hover:opacity-90 transition-opacity"
          >
            Créer mon menu QR
          </NuxtLink>
          <a 
            href="#demo"
            class="px-8 py-3 text-white rounded-full text-lg font-medium hover:underline"
          >
            Voir la démo
          </a>
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
  Check,
  Star
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

const testimonials = [
  {
    name: 'Jean Dupont',
    role: 'Restaurant Le Gourmet',
    image: 'https://images.unsplash.com/photo-1600565193348-f74bd3c7ccdf',
    text: 'KulaQr a révolutionné la gestion de notre menu. Nos clients adorent pouvoir scanner et commander facilement.'
  },
  {
    name: 'Marie Martin',
    role: 'Café des Arts',
    image: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8',
    text: 'Une solution simple et efficace qui nous fait gagner du temps. Le support client est excellent.'
  },
  {
    name: 'Pierre Dubois',
    role: 'Bistrot du Coin',
    image: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b',
    text: 'Interface intuitive et design moderne. Nos clients sont ravis et nos ventes ont augmenté.'
  }
]
</script>

<style scoped>
html {
  scroll-behavior: smooth;
}

/* Apple-style typography and spacing */
h1, h2, h3, h4, h5, h6 {
  font-family: SF Pro Display, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

body {
  font-family: SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}
</style>