<template>
  <div class="w-full text-black">
    <!-- Hero Section with Logo Focus - Now with white design -->
    <section class="w-full min-h-[500px] md:h-[56.25vw] relative flex items-center justify-center bg-white overflow-hidden" style="max-height: 100vh;">
      <!-- Subtle background pattern -->
      <div class="absolute inset-0 bg-gray-50 opacity-30 pattern-grid-lg"></div>
      
      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 py-12 md:py-0 z-10 flex flex-col md:flex-row items-center gap-8">
        <!-- Text Content -->
        <div class="text-center md:text-left text-black space-y-4 md:space-y-6 md:w-1/2">
          <span class="text-base md:text-lg font-medium tracking-wide text-gray-500">LA SOLUTION DE MENU DIGITAL</span>
          <h1 class="text-3xl sm:text-4xl md:text-5xl lg:text-7xl font-bold tracking-tight text-gray-900">
            Votre menu,<br />en un <span class="bg-black text-white px-2">scan</span>.
          </h1>
          <p class="text-lg md:text-xl lg:text-2xl font-light text-gray-600">
            Créez votre menu QR code personnalisé et offrez une expérience moderne à vos clients. Simple, rapide et efficace.
          </p>
          <div class="flex flex-col sm:flex-row items-center sm:items-start justify-center md:justify-start gap-4 sm:gap-6 pt-6 md:pt-8">
            <NuxtLink 
              to="/auth/register"
              class="w-full sm:w-auto px-8 sm:px-10 py-3 sm:py-4 bg-black text-white rounded-full text-lg sm:text-xl font-medium hover:opacity-90 transition-all shadow-lg hover:shadow-xl hover:scale-105 flex items-center justify-center"
            >
              <span>Commencer maintenant</span>
              <ArrowRight class="w-5 h-5 ml-2" />
            </NuxtLink>
            <a 
              href="#demo"
              class="w-full sm:w-auto px-6 sm:px-8 py-3 text-gray-800 rounded-full text-lg font-medium hover:text-black hover:underline flex items-center justify-center"
            >
              <Play class="w-5 h-5 mr-2" />
              <span>Voir la démo</span>
            </a>
          </div>
        </div>
        
        <!-- Logo Visualization -->
        <div class="md:w-1/2 flex justify-center items-center mt-12 md:mt-0">
          <div class="relative">
            <!-- Company Logo in Apple-style presentation -->
            <div class="w-48 h-48 sm:w-64 sm:h-64 md:w-72 md:h-72 lg:w-80 lg:h-80 bg-gray-100 rounded-3xl shadow-xl flex items-center justify-center overflow-hidden">
              <!-- Replace with your actual logo -->
              <img src="~/assets/icon/logo.png" alt="Restaurant logo" class="w-full h-full object-cover" />
            </div>
            
            <!-- Phone Outline showing QR scanning - more Apple-like -->
            <div class="absolute -bottom-12 sm:-bottom-16 -right-12 sm:-right-16 w-32 sm:w-40 h-48 sm:h-64 border-2 border-gray-200 rounded-3xl transform -rotate-12 flex items-center justify-center bg-white/80 backdrop-blur-sm shadow-lg">
              <div class="w-24 sm:w-32 h-40 sm:h-56 bg-gray-50 rounded-2xl border border-gray-100">
                <div class="w-full h-full flex items-center justify-center">
                  <QrCode class="w-12 sm:w-16 h-12 sm:h-16 text-gray-800 opacity-90" />
                </div>
              </div>
            </div>
            
            <!-- Floating element to add visual interest -->
            <div class="absolute -top-8 sm:-top-12 -left-8 sm:-left-12 w-16 sm:w-24 h-16 sm:h-24 bg-black rounded-full flex items-center justify-center shadow-lg">
              <QrCode class="w-8 sm:w-10 h-8 sm:h-10 text-white" />
            </div>
          </div>
        </div>
      </div>
      
      <!-- Impactful CTA Bar -->
      <div class="absolute bottom-0 left-0 right-0 bg-black py-4">
        <div class="max-w-6xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between">
          <div class="flex flex-wrap justify-center md:justify-start items-center gap-4 sm:gap-8 mb-4 md:mb-0">
            <div class="flex items-center gap-2">
              <Users class="w-5 sm:w-6 h-5 sm:h-6 text-white" />
              <span class="text-base sm:text-lg text-white/90">+2000 Restaurants</span>
            </div>
            <div class="flex items-center gap-2">
              <Star class="w-5 sm:w-6 h-5 sm:h-6 text-white" />
              <span class="text-base sm:text-lg text-white/90">4.9/5 Satisfaction</span>
            </div>
          </div>
          <NuxtLink 
            to="/auth/register"
            class="w-full md:w-auto px-6 sm:px-8 py-2 sm:py-3 bg-white text-black rounded-full text-base sm:text-lg font-medium hover:bg-gray-100 transition-colors inline-flex items-center justify-center"
          >
            <span>Essai gratuit 14 jours</span>
            <ArrowRight class="w-4 sm:w-5 h-4 sm:h-5 ml-2" />
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Features Section - Apple-inspired design -->
    <section class="w-full py-24 md:py-32 bg-white text-black overflow-hidden">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Apple-style section header -->
        <div class="text-center mb-16 md:mb-24">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">Fonctionnalités</span>
          <h2 class="mt-4 text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900">
            Menu QR Code.
            <span class="bg-clip-text text-transparent bg-gradient-to-r from-gray-900 to-gray-500">Simplifié.</span>
          </h2>
        </div>
        
        <!-- Main feature highlight with Apple-style visual hierarchy -->
        <div class="grid md:grid-cols-2 gap-16 md:gap-20 items-center mb-24">
          <div class="space-y-6 md:space-y-8 order-2 md:order-1">
            <h3 class="text-3xl sm:text-4xl font-semibold tracking-tight text-gray-900">
              Un design épuré,<br/>une expérience fluide
            </h3>
            <p class="text-lg sm:text-xl text-gray-500 leading-relaxed">
              Créez un menu digital professionnel en quelques clics. Notre plateforme s'adapte parfaitement à tous les appareils pour une expérience utilisateur optimale.
            </p>
            <ul class="space-y-5 sm:space-y-6 pt-2">
              <li class="flex items-center space-x-4">
                <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center shadow-md">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-base sm:text-lg text-gray-700">Design responsive nouvelle génération</span>
              </li>
              <li class="flex items-center space-x-4">
                <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center shadow-md">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-base sm:text-lg text-gray-700">QR code avec intégration visuelle personnalisée</span>
              </li>
              <li class="flex items-center space-x-4">
                <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center shadow-md">
                  <Check class="w-5 h-5" />
                </span>
                <span class="text-base sm:text-lg text-gray-700">Mises à jour instantanées sans rechargement</span>
              </li>
            </ul>
          </div>
          <div class="relative aspect-square order-1 md:order-2">
            <!-- Apple-style product display with shadow effect -->
            <div class="absolute inset-0 bg-gradient-to-br from-gray-200 to-gray-100 rounded-3xl transform rotate-6 scale-95"></div>
            <img 
              src="https://images.unsplash.com/photo-1533777857889-4be7c70b33f7"
              alt="QR Code Demo"
              class="relative w-full h-full object-cover rounded-3xl shadow-2xl transform -rotate-3"
            />
          </div>
        </div>
        
        <!-- Three feature columns - Apple style with clean icons -->
        <div class="grid md:grid-cols-3 gap-8 lg:gap-12">
          <!-- Feature 1 -->
          <div class="flex flex-col items-center md:items-start text-center md:text-left">
            <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-6">
              <QrCode class="w-8 h-8 text-black" />
            </div>
            <h3 class="text-2xl font-semibold mb-3">QR Codes Intelligents</h3>
            <p class="text-gray-500">Des QR codes uniques avec votre identité visuelle qui s'adaptent à votre environnement et vos tables.</p>
          </div>
          
          <!-- Feature 2 -->
          <div class="flex flex-col items-center md:items-start text-center md:text-left">
            <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-6">
              <TrendingUp class="w-8 h-8 text-black" />
            </div>
            <h3 class="text-2xl font-semibold mb-3">Analyse en temps réel</h3>
            <p class="text-gray-500">Suivez les performances de votre menu et analysez les plats les plus populaires pour optimiser votre carte.</p>
          </div>
          
          <!-- Feature 3 -->
          <div class="flex flex-col items-center md:items-start text-center md:text-left">
            <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-6">
              <Shield class="w-8 h-8 text-black" />
            </div>
            <h3 class="text-2xl font-semibold mb-3">Sécurité maximale</h3>
            <p class="text-gray-500">Protection des données et des transactions avec les dernières technologies de chiffrement avancées.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats Section - Apple-style clean, impactful stats -->
    <section class="w-full py-24 md:py-32 bg-gray-50 text-black">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Apple-style section header -->
        <div class="text-center space-y-4 mb-20">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">Impact</span>
          <h2 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900">
            Chiffres clés
          </h2>
          <p class="max-w-2xl mx-auto text-gray-500 text-lg">Des résultats concrets qui transforment l'expérience client</p>
        </div>
        
        <!-- Stats with large numbers - Apple style -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-8 md:gap-6">
          <!-- Stat 1 -->
          <div class="flex flex-col items-center text-center">
            <span class="text-6xl md:text-7xl lg:text-8xl font-bold text-gray-900 mb-4">2K+</span>
            <span class="text-lg text-gray-500">Restaurants</span>
          </div>
          
          <!-- Stat 2 -->
          <div class="flex flex-col items-center text-center">
            <span class="text-6xl md:text-7xl lg:text-8xl font-bold text-gray-900 mb-4">50K+</span>
            <span class="text-lg text-gray-500">Scans quotidiens</span>
          </div>
          
          <!-- Stat 3 -->
          <div class="flex flex-col items-center text-center">
            <span class="text-6xl md:text-7xl lg:text-8xl font-bold text-gray-900 mb-4">100K+</span>
            <span class="text-lg text-gray-500">Plats servis</span>
          </div>
          
          <!-- Stat 4 -->
          <div class="flex flex-col items-center text-center">
            <span class="text-6xl md:text-7xl lg:text-8xl font-bold text-gray-900 mb-4">4.9</span>
            <span class="text-lg text-gray-500">Note client</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Testimonials Section - Apple-inspired clean design -->
    <section class="w-full py-24 md:py-32 bg-white text-black overflow-hidden">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Apple-style section header -->
        <div class="text-center space-y-4 mb-20">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">Témoignages</span>
          <h2 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900">
            Ce qu'ils en disent
          </h2>
        </div>
        
        <!-- Testimonials with Apple-style card design -->
        <div class="grid sm:grid-cols-3 gap-8 md:gap-12">
          <div v-for="testimonial in testimonials" :key="testimonial.name" 
            class="bg-gray-50 p-8 sm:p-10 rounded-3xl space-y-6 transform transition-all duration-300 hover:shadow-xl"
          >
            <div class="flex items-center space-x-4">
              <img 
                :src="testimonial.image" 
                :alt="testimonial.name"
                class="w-14 h-14 rounded-full object-cover"
              />
              <div>
                <h3 class="font-semibold text-lg text-gray-900">{{ testimonial.name }}</h3>
                <p class="text-gray-500">{{ testimonial.role }}</p>
              </div>
            </div>
            <p class="text-gray-600 leading-relaxed text-lg">{{ testimonial.text }}</p>
            <div class="flex text-black">
              <Star v-for="i in 5" :key="i" class="w-5 h-5" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Video Demo Section - New Apple-style video showcase -->
    <section id="demo" class="w-full py-24 md:py-32 bg-gray-900 text-white overflow-hidden">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Apple-style section header -->
        <div class="text-center space-y-4 mb-16">
          <span class="text-sm font-semibold tracking-widest text-gray-400 uppercase">Démonstration</span>
          <h2 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-white">
            Voyez KulaQr en action
          </h2>
        </div>
        
        <!-- Apple-style video container -->
        <div class="relative aspect-video rounded-3xl overflow-hidden shadow-2xl mx-auto">
          <!-- This would be replaced with your video player component -->
          <div class="absolute inset-0 bg-gradient-to-br from-blue-500/20 to-purple-500/20 backdrop-blur-sm flex items-center justify-center">
            <div class="w-20 h-20 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center cursor-pointer hover:bg-white/30 transition-all">
              <Play class="w-8 h-8 text-white ml-1" />
            </div>
          </div>
          <img 
            src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
            alt="Restaurant demo"
            class="w-full h-full object-cover"
          />
        </div>
      </div>
    </section>

    <!-- CTA Section - Apple-style with strong contrast -->
    <section class="w-full py-32 md:py-40 bg-black text-white">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 text-center">
        <h2 class="text-5xl sm:text-6xl md:text-7xl font-bold leading-tight mb-8">
          Prêt à transformer <br/>votre expérience client ?
        </h2>
        <p class="text-xl md:text-2xl text-gray-400 mb-12 max-w-3xl mx-auto">
          Rejoignez les milliers de restaurants qui ont déjà adopté KulaQr pour digitaliser leur menu
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-6">
          <NuxtLink 
            to="/auth/register"
            class="w-full sm:w-auto px-10 py-5 bg-white text-black rounded-full text-xl font-medium hover:scale-105 transition-transform flex items-center justify-center"
          >
            <span>Commencer gratuitement</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
          <a 
            href="#pricing"
            class="w-full sm:w-auto px-8 py-5 bg-transparent border border-white/30 text-white rounded-full text-lg font-medium hover:bg-white/10 transition-colors"
          >
            Découvrir nos tarifs
          </a>
        </div>
      </div>
    </section>
    
    <!-- Footer Section - Apple-style modern footer -->
    <footer class="w-full bg-white pt-20 pb-8 border-t border-gray-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Footer Main Content -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-12 lg:gap-16 mb-20">
          <!-- Brand Column -->
          <div class="space-y-6">
            <div class="flex items-center">
              <!-- Logo placeholder -->
              <div class="w-12 h-12 bg-black rounded-full flex items-center justify-center mr-3">
                <span class="text-white text-xl font-bold">KQ</span>
              </div>
              <span class="text-black text-xl font-semibold">KulaQr</span>
            </div>
            <p class="text-gray-500 text-base leading-relaxed">
              La solution intelligente de menu QR code qui transforme l'expérience client dans votre établissement.
            </p>
            <div class="flex space-x-4">
              <!-- Social Media Icons - Apple style -->
              <a href="#" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <span class="text-gray-700 text-sm">FB</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <span class="text-gray-700 text-sm">IG</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <span class="text-gray-700 text-sm">TW</span>
              </a>
              <a href="#" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <span class="text-gray-700 text-sm">IN</span>
              </a>
            </div>
          </div>
          
          <!-- Navigation Columns - Apple style clean footer links -->
          <div class="space-y-6">
            <h3 class="text-black text-lg font-semibold">Produit</h3>
            <ul class="space-y-4">
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Fonctionnalités</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Tarifs</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Témoignages</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Guide d'utilisateur</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Nouveautés</a></li>
            </ul>
          </div>
          
          <div class="space-y-6">
            <h3 class="text-black text-lg font-semibold">Ressources</h3>
            <ul class="space-y-4">
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Blog</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Documentation</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Centre d'aide</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Développeurs</a></li>
              <li><a href="#" class="text-gray-500 hover:text-black transition-colors">Partenaires</a></li>
            </ul>
          </div>
          
          <div class="space-y-6">
            <h3 class="text-black text-lg font-semibold">Contact</h3>
            <ul class="space-y-4">
              <li class="flex items-center">
                <div class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center mr-3">
                  <span class="text-gray-700 text-xs">@</span>
                </div>
                <span class="text-gray-500">hello@kulaqr.com</span>
              </li>
              <li class="flex items-center">
                <div class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center mr-3">
                  <span class="text-gray-700 text-xs">T</span>
                </div>
                <span class="text-gray-500">+33 1 23 45 67 89</span>
              </li>
              <li class="flex items-center">
                <div class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center mr-3">
                  <span class="text-gray-700 text-xs">P</span>
                </div>
                <span class="text-gray-500">14 Rue de la Paix, 75002 Paris</span>
              </li>
            </ul>
            <NuxtLink 
              to="/contact"
              class="inline-flex items-center px-6 py-3 bg-gray-100 text-gray-800 rounded-full text-sm font-medium hover:bg-gray-200 transition-colors"
            >
              Nous contacter
              <ArrowRight class="w-4 h-4 ml-2" />
            </NuxtLink>
          </div>
        </div>
        
        <!-- Footer Bottom - Apple style clean legal links -->
        <div class="border-t border-gray-100 pt-8 flex flex-col sm:flex-row justify-between items-center">
          <div class="text-gray-400 mb-4 sm:mb-0 text-sm">
            © 2025 KulaQr. Tous droits réservés.
          </div>
          <div class="flex flex-wrap justify-center gap-6 text-sm">
            <NuxtLink to="/legal#mentions-legales" class="text-gray-400 hover:text-black transition-colors">Mentions légales</NuxtLink>
            <NuxtLink to="/legal#cgu" class="text-gray-400 hover:text-black transition-colors">Conditions d'utilisation</NuxtLink>
            <NuxtLink to="/legal#privacy" class="text-gray-400 hover:text-black transition-colors">Politique de confidentialité</NuxtLink>
            <NuxtLink to="/legal#cookies" class="text-gray-400 hover:text-black transition-colors">Gestion des cookies</NuxtLink>
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
  Star,
  Building2,
  UtensilsCrossed
} from 'lucide-vue-next'

const navItems = [
  { name: 'Fonctionnalités', to: '#features' },
  { name: 'Tarifs', to: '#pricing' },
  { name: 'Contact', to: '#contact' }
]

const testimonials = [
  {
    name: 'Jean Dupont',
    role: 'Restaurant Le Gourmet',
    image: 'https://images.unsplash.com/photo-1600565193348-f74bd3c7ccdf',
    text: "KulaQr a révolutionné notre façon de présenter nos menus. Nos clients sont plus satisfaits et nous avons vu notre chiffre d'affaires augmenter de 15%."
  },
  {
    name: 'Marie Martin',
    role: 'Café des Arts',
    image: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8',
    text: "Une solution simple et rapide à mettre en place. Le support client est réactif et l'interface est très intuitive. Je recommande vivement."
  },
  {
    name: 'Pierre Dubois',
    role: 'Bistrot du Coin',
    image: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b',
    text: "Après avoir essayé plusieurs solutions, KulaQr est la seule qui répond parfaitement à nos besoins avec un design élégant et personnalisable."
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
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Add subtle pattern background for hero section */
.pattern-grid-lg {
  background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
                   linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
  background-size: 40px 40px;
}
</style>