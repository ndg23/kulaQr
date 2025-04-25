<template>
  <div class="w-full text-black">
    <!-- Hero Section with Logo Focus - Now with white design -->
    <!-- Hero Section -->
<section class="w-full min-h-[500px] md:h-[56.25vw] relative flex items-center justify-center bg-white overflow-hidden" style="max-height: 100vh;">
  <!-- Subtle background pattern -->
  <div class="absolute inset-0 bg-gray-50 opacity-30 pattern-grid-lg"></div>
  
  <div class="relative w-full max-w-6xl mx-auto px-0 md:px-6 py-0 md:py-12 z-10">
    <!-- Réorganisation du contenu pour mobile -->
    <div class="flex flex-col md:flex-row items-center gap-0 md:gap-8">
      <!-- Image en premier sur mobile -->
      <div class="w-full md:w-1/2 order-1 md:order-2 mb-8 md:mb-0">
        <div class="relative">
          <div class="w-full h-[60vh] md:w-[500px] md:h-[500px] bg-gray-100 md:rounded-3xl shadow-xl- flex items-center justify-center overflow-hidden">
            <img 
              src="~/assets/images/flyer1.png" 
              alt="Restaurant logo" 
              class="w-full h-full object-cover object-center"
            />
          </div>
        </div>
      </div>
      
      <!-- Texte en dessous sur mobile -->
      <div class="w-full md:w-1/2 order-2 md:order-1 px-4 md:px-0 text-center md:text-left">
        <span class="text-base md:text-lg font-medium tracking-wide text-gray-500">LA SOLUTION DE MENU DIGITAL</span>
        <h1 class="text-3xl sm:text-4xl md:text-5xl lg:text-7xl font-bold tracking-tight text-gray-900 mt-4">
          Votre menu,<br />en un <span class="bg-kula-500 text-white px-2">scan</span>.
        </h1>
        <p class="text-lg md:text-xl lg:text-2xl font-light text-gray-600 mt-6">
          Créez votre menu QR code personnalisé et offrez une expérience moderne à vos clients. Simple, rapide et efficace.
        </p>
        <div class="flex flex-col sm:flex-row items-center sm:items-start justify-center md:justify-start gap-4 sm:gap-6 pt-8">
          <NuxtLink 
            to="/auth/register"
            class="w-full sm:w-auto px-8 sm:px-10 py-3 sm:py-4 bg-black text-white rounded-full text-lg sm:text-xl font-medium hover:opacity-90 transition-all shadow-lg hover:shadow-xl hover:scale-105 flex items-center justify-center"
          >
            <span>Commencer maintenant</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</section>

    <!-- Features Section - Apple-inspired design -->
    <section class="w-full py-24 md:py-16 bg-white text-black overflow-hidden">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Apple-style section header -->
        <div class="text-center mb-16 md:mb-24">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">Fonctionnalités</span>
          <h2 class="mt-4 text-4xl sm:text-5xl md:text-6xl font-extrabold tracking-tight text-gray-900">
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
              src="~/assets/images/scan.png"
              alt="QR Code Demo"
              class="relative w-full h-full object--cover rounded-3xl shadow-2xl- -transform -rotate-3"
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

    <!-- CTA Section - Clean Apple-style design -->
    <section class="w-full py-32 md:py-40 bg-white text-black">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 text-center">
        <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase mb-8 block">Commencez maintenant</span>
        <h2 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900 mb-6">
          Prêt à transformer <br/>votre expérience client ?
        </h2>
        <p class="text-lg md:text-xl text-gray-500 mb-12 max-w-2xl mx-auto">
          Rejoignez les milliers de restaurants qui ont déjà adopté KulaQr pour digitaliser leur menu et améliorer leur service
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
          <NuxtLink 
            to="/auth/register"
            class="w-full sm:w-auto px-8 py-4 bg-black text-white rounded-full text-lg font-medium hover:opacity-90 transition-all shadow-lg hover:shadow-xl hover:scale-[1.02] flex items-center justify-center"
          >
            <span>Commencer gratuitement</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
          <a 
            href="#pricing"
            class="w-full sm:w-auto px-8 py-4 bg-gray-100 text-gray-900 rounded-full text-lg font-medium hover:bg-gray-200 transition-all"
          >
            Découvrir nos tarifs
          </a>
        </div>
      </div>
    </section>
    
    <!-- Footer - Minimal Apple-style design -->
    <footer class="w-full bg-white py-12 md:py-16 border-t border-gray-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <!-- Main Footer Content -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
          <!-- Brand Column -->
          <div class="col-span-2 md:col-span-1">
            <div class="flex items-center mb-6">
              <div class="w-10 h-10 bg-black rounded-full flex items-center justify-center mr-3">
                <span class="text-white text-sm font-medium">KQ</span>
              </div>
              <span class="text-black text-lg font-medium">KulaQr</span>
            </div>
            <p class="text-gray-500 text-sm leading-relaxed">
              La solution intelligente de menu QR code qui transforme l'expérience client.
            </p>
          </div>
          
         
          
          <!-- Company -->
          <div>
            <h3 class="text-sm font-medium text-gray-900 mb-4">Entreprise</h3>
            <ul class="space-y-3">
              <li><a href="/about" class="text-sm text-gray-500 hover:text-black transition-colors">À propos</a></li>
              <li><a href="/contact" class="text-sm text-gray-500 hover:text-black transition-colors">Contact</a></li>
            </ul>
          </div>
          
          <!-- Contact -->
          <div>
            <h3 class="text-sm font-medium text-gray-900 mb-4">Contact</h3>
            <ul class="space-y-3">
              <li class="text-sm text-gray-500">hello@kulaqr.com</li>
              <li class="text-sm text-gray-500">+221 77 749 39 10</li>
              <li class="text-sm text-gray-500">Dakar, Senegal</li>
            </ul>
          </div>
        </div>
        
        <!-- Footer Bottom -->
        <div class="pt-8 border-t border-gray-100 flex flex-col md:flex-row justify-between items-center gap-4">
          <div class="flex items-center gap-6">
            <a href="#" class="text-gray-400 hover:text-black">
              <Twitter class="w-5 h-5" />
            </a>
            <a href="#" class="text-gray-400 hover:text-black">
              <Instagram class="w-5 h-5" />
            </a>
            <a href="#" class="text-gray-400 hover:text-black">
              <Linkedin class="w-5 h-5" />
            </a>
          </div>
          
          <div class="flex flex-wrap justify-center gap-6">
            <a href="/legal/mentions-legales" class="text-xs text-gray-500 hover:text-black">Mentions légales</a>
            <a href="/legal/privacy" class="text-xs text-gray-500 hover:text-black">Confidentialité</a>
            <a href="/legal/terms" class="text-xs text-gray-500 hover:text-black">CGU</a>
            <span class="text-xs text-gray-500">© 2024 KulaQr</span>
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
  UtensilsCrossed,
  Twitter,
  Instagram,
  Linkedin
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
  background-image: linear-gradient(to right, rgba(233, 16, 16, 0.05) 1px, transparent 1px),
                   linear-gradient(to bottom, rgba(223, 28, 28, 0.05) 1px, transparent 1px);
  background-size: 40px 40px;
}
</style>