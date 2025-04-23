<template>
  <div class="w-full bg-black text-white">
    <!-- Hero Section with Logo Focus -->
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
              class="px-10 py-4 bg-white text-black rounded-full text-xl font-medium hover:opacity-90 transition-all shadow-lg hover:shadow-xl hover:scale-105 flex items-center"
            >
              <span>Commencer maintenant</span>
              <ArrowRight class="w-5 h-5 ml-2" />
            </NuxtLink>
            <a 
              href="#demo"
              class="px-8 py-3 text-white rounded-full text-lg font-medium hover:underline flex items-center"
            >
              <Play class="w-5 h-5 mr-2" />
              <span>Voir la démo</span>
            </a>
          </div>
        </div>
        
        <!-- Logo Visualization -->
        <div class="md:w-1/2 flex justify-center items-center">
          <div class="relative">
            <!-- Company Logo in Apple-style presentation -->
            <div class="w-64 h-64 md:w-80 md:h-80 bg-white/10 rounded-3xl shadow-2xl flex items-center justify-center overflow-hidden">
              <!-- Replace with your actual logo -->
              <img src="~/assets/icon/logo.png" alt="Restaurant logo" class="w-full h-full object-cover" />

            </div>
            
            <!-- Phone Outline showing QR scanning -->
            <div class="absolute -bottom-16 -right-16 w-40 h-64 border-2 border-white/30 rounded-3xl transform -rotate-12 flex items-center justify-center">
              <div class="w-32 h-56 bg-black/70 rounded-2xl border border-white/20">
                <div class="w-full h-full flex items-center justify-center">
                  <QrCode class="w-16 h-16 text-white opacity-70" />
                </div>
              </div>
            </div>
            
            <!-- Floating element to add visual interest -->
            <div class="absolute -top-12 -left-12 w-24 h-24 bg-white/10 backdrop-blur-lg rounded-full flex items-center justify-center">
              <QrCode class="w-10 h-10 text-white" />
            </div>
          </div>
        </div>
      </div>
      
      <!-- Impactful CTA Bar -->
      <div class="absolute bottom-0 left-0 right-0 bg-white/10 backdrop-blur-md py-4">
        <div class="max-w-6xl mx-auto px-6 flex flex-col md:flex-row items-center justify-between">
          <div class="flex items-center gap-8 mb-4 md:mb-0">
            <div class="flex items-center gap-2">
              <Users class="w-6 h-6 text-white" />
              <span class="text-lg text-white/90">+2000 Restaurants</span>
            </div>
            <div class="flex items-center gap-2">
              <Star class="w-6 h-6 text-white" />
              <span class="text-lg text-white/90">4.9/5 Satisfaction</span>
            </div>
          </div>
          <NuxtLink 
            to="/auth/register"
            class="px-8 py-3 bg-white text-black rounded-full text-lg font-medium hover:bg-white/90 transition-colors inline-flex items-center"
          >
            <span>Essai gratuit 14 jours</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
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
            class="px-10 py-4 bg-white text-black rounded-full text-xl font-medium hover:scale-105 transition-transform shadow-lg flex items-center"
          >
            <span>Créer mon menu QR</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
          <a 
            href="#pricing"
            class="px-8 py-3 border border-white/30 text-white rounded-full text-lg font-medium hover:bg-white/10 transition-colors"
          >
            Voir nos tarifs
          </a>
        </div>
      </div>
    </section>
    
    <!-- Footer Section -->
    <footer class="w-full bg-black border-t border-white/10 pt-16 pb-8">
      <div class="max-w-6xl mx-auto px-6">
        <!-- Footer Main Content -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
          <!-- Brand Column -->
          <div class="space-y-6">
            <div class="flex items-center">
              <!-- Logo placeholder - replace with your actual logo -->
              <div class="w-10 h-10 bg-white rounded-lg flex items-center justify-center mr-3">
                <span class="text-black text-xl font-bold">KQ</span>
              </div>
              <span class="text-white text-xl font-medium">KulaQr</span>
            </div>
            <p class="text-gray-400 text-sm">
              La solution intelligente de menu QR code pour les restaurants modernes.
            </p>
            <div class="flex space-x-4">
              <!-- Social Media Icons -->
              <a href="#" class="w-10 h-10 rounded-full border border-white/20 flex items-center justify-center hover:bg-white/10 transition-colors">
                <span class="text-white text-sm">FB</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full border border-white/20 flex items-center justify-center hover:bg-white/10 transition-colors">
                <span class="text-white text-sm">IG</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full border border-white/20 flex items-center justify-center hover:bg-white/10 transition-colors">
                <span class="text-white text-sm">TW</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full border border-white/20 flex items-center justify-center hover:bg-white/10 transition-colors">
                <span class="text-white text-sm">IN</span>
              </a>
            </div>
          </div>
          
          <!-- Navigation Columns -->
          <div class="space-y-4">
            <h3 class="text-white text-lg font-medium">Produit</h3>
            <ul class="space-y-3">
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Fonctionnalités</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Tarifs</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Témoignages</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Guide d'utilisation</a></li>
            </ul>
          </div>
          
          <div class="space-y-4">
            <h3 class="text-white text-lg font-medium">Ressources</h3>
            <ul class="space-y-3">
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Blog</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Documentation</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Centre d'aide</a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors">Partenaires</a></li>
            </ul>
          </div>
          
          <div class="space-y-4">
            <h3 class="text-white text-lg font-medium">Contact</h3>
            <ul class="space-y-3">
              <li class="text-gray-400">hello@kulaqr.com</li>
              <li class="text-gray-400">+33 1 23 45 67 89</li>
              <li class="text-gray-400">14 Rue de la Paix, 75002 Paris</li>
            </ul>
            <NuxtLink 
              to="/contact"
              class="inline-block px-5 py-2 bg-white/10 text-white rounded-full text-sm font-medium hover:bg-white/20 transition-colors"
            >
              Contactez-nous
            </NuxtLink>
          </div>
        </div>
        
        <!-- Footer Bottom -->
        <div class="border-t border-white/10 pt-8 flex flex-col md:flex-row justify-between items-center">
          <div class="text-gray-500 text-sm mb-4 md:mb-0">
            © 2025 KulaQr. Tous droits réservés.
          </div>
          <div class="flex space-x-6">
            <a href="#" class="text-gray-500 text-sm hover:text-white transition-colors">Politique de confidentialité</a>
            <a href="#" class="text-gray-500 text-sm hover:text-white transition-colors">Conditions d'utilisation</a>
            <a href="#" class="text-gray-500 text-sm hover:text-white transition-colors">Mentions légales</a>
          </div>
        </div>
      </div>
    </footer>
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