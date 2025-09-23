<template>
  <div class="min-h-screen bg-[#F5F5F7] relative">
    <PatternBackground :opacity="0.8" :duration="60" />
    <div class="relative z-50">
      <!-- Navigation Bar -->
      <Navbar />

      <!-- Hero Section with Logo Focus - Now with white design -->
      <!-- Hero Section -->
      <section class="w-full min-h-[80vh] relative flex items-center justify-center bg-white overflow-hidden pt-16">
        <!-- Subtle gradient background -->
        <div class="absolute inset-0 bg-gradient-to-br from-gray-50 to-white opacity-80"></div>
        
        <div class="relative w-full max-w-6xl mx-auto px-4 md:px-6 py-12 md:py-20">
          <div class="flex flex-col md:flex-row items-center gap-8 md:gap-16">
            <!-- Text Content -->
            <div class="w-full md:w-1/2 order-2 md:order-1 text-center md:text-left">
              <span class="inline-block px-4 py-2 bg-black/5 rounded-full text-sm md:text-base font-medium tracking-wide text-gray-800">
                MENU QR CODE NOUVELLE GÉNÉRATION
              </span>
              <h1 class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight text-gray-900 mt-6">
                Votre menu,<br />
                <span class="relative">
                  en un <span class="bg-black text-white px-3 py-1 rounded-lg">scan</span>
                  <span class="absolute -bottom-2 left-0 w-full h-1 bg-kula-500"></span>
                </span>
              </h1>
              <p class="text-xl md:text-2xl font-light text-gray-600 mt-8 max-w-xl">
                Créez votre menu QR code personnalisé et offrez une expérience client exceptionnelle.
              </p>
              <div class="flex flex-col sm:flex-row items-center sm:items-start justify-center md:justify-start gap-6 mt-10">
                <NuxtLink 
                  to="/auth/register"
                  class="group w-full sm:w-auto px-8 sm:px-10 py-4 sm:py-5 bg-black text-white rounded-full text-lg sm:text-xl font-medium transition-all duration-300 hover:-shadow-2xl hover:scale-105 flex items-center justify-center"
                >
                  <span>Commencer maintenant</span>
                  <ArrowRight class="w-5 h-5 ml-2 transition-transform group-hover:translate-x-2" />
                </NuxtLink>
              </div>
            </div>
            
            <!-- Image -->
            <div class="w-full md:w-1/2 order-1 md:order-2">
              <div class="relative">
                <div class="absolute inset-0 bg-gradient-to-tr from-kula-500/20 to-transparent rounded-3xl transform rotate-6 scale-95"></div>
                <div class="w-full aspect-square md:w-[600px] md:h-[600px] bg-white rounded-3xl -shadow-2xl overflow-hidden transform -rotate-3 transition-transform hover:rotate-0 duration-500">
                  <img 
                    src="~/assets/images/flyer1.png" 
                    alt="Restaurant QR Menu Demo" 
                    class="w-full h-full object-cover"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Features Section - Apple-inspired design -->
      <section id="features" class="w-full py-24 md:py-32 bg-white text-black overflow-hidden">
        <div class="max-w-6xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-20">
            <span class="inline-block px-4 py-2 bg-black/5 rounded-full text-sm font-medium tracking-wide text-gray-800 mb-4">
              FONCTIONNALITÉS
            </span>
            <h2 class="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight text-gray-900">
              Menu QR Code.
              <span class="relative">
                Simplifié
                <span class="absolute -bottom-2 left-0 w-full h-1 bg-kula-500"></span>
              </span>
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
                  <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center -shadow-md">
                    <Check class="w-5 h-5" />
                  </span>
                  <span class="text-base sm:text-lg text-gray-700">Design responsive nouvelle génération</span>
                </li>
                <li class="flex items-center space-x-4">
                  <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center -shadow-md">
                    <Check class="w-5 h-5" />
                  </span>
                  <span class="text-base sm:text-lg text-gray-700">QR code avec intégration visuelle personnalisée</span>
                </li>
                <li class="flex items-center space-x-4">
                  <span class="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center -shadow-md">
                    <Check class="w-5 h-5" />
                  </span>
                  <span class="text-base sm:text-lg text-gray-700">Mises à jour instantanées sans rechargement</span>
                </li>
              </ul>
            </div>
            <div class="relative aspect-square order-1 md:order-2">
              <!-- Apple-style product display with -shadow effect -->
              <div class="absolute inset-0 bg-gradient-to-br from-gray-200 to-gray-100 rounded-3xl transform rotate-6 scale-95"></div>
              <img 
                src="~/assets/images/scan.png"
                alt="QR Code Demo"
                class="relative w-full h-full object--cover rounded-3xl -shadow-2xl- -transform -rotate-3"
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

      <!-- Stats Section with enhanced visual impact -->
      <section class="w-full py-24 md:py-32 bg-gradient-to-br from-gray-50 to-white">
        <div class="max-w-6xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-20">
            <span class="inline-block px-4 py-2 bg-black/5 rounded-full text-sm font-medium tracking-wide text-gray-800 mb-4">
              IMPACT
            </span>
            <h2 class="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight text-gray-900">
              Chiffres clés
            </h2>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
            <div class="group bg-white p-8 rounded-2xl -shadow-lg hover:-shadow-2xl transition-all duration-300">
              <span class="block text-7xl md:text-8xl font-bold text-gray-900 mb-4 group-hover:scale-110 transition-transform duration-300">
                50+
              </span>
              <span class="text-xl text-gray-500">Restaurants</span>
            </div>
            
            <div class="group bg-white p-8 rounded-2xl -shadow-lg hover:-shadow-2xl transition-all duration-300">
              <span class="block text-7xl md:text-8xl font-bold text-gray-900 mb-4 group-hover:scale-110 transition-transform duration-300">
                1K+
              </span>
              <span class="text-xl text-gray-500">Scans par jour</span>
            </div>
            
            <div class="group bg-white p-8 rounded-2xl -shadow-lg hover:-shadow-2xl transition-all duration-300">
              <span class="block text-7xl md:text-8xl font-bold text-gray-900 mb-4 group-hover:scale-110 transition-transform duration-300">
                15%
              </span>
              <span class="text-xl text-gray-500">Gain de temps moyen</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Testimonials Section -->
      <section id="testimonials" class="w-full py-24 md:py-32 bg-white">
        <div class="max-w-6xl mx-auto px-4 sm:px-6">
          <div class="text-center mb-20">
            <span class="inline-block px-4 py-2 bg-black/5 rounded-full text-sm font-medium tracking-wide text-gray-800 mb-4">
              TÉMOIGNAGES
            </span>
            <h2 class="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight text-gray-900">
              Ils nous font 
              <span class="relative">
                confiance
                <span class="absolute -bottom-2 left-0 w-full h-1 bg-kula-500"></span>
              </span>
            </h2>
          </div>

          <!-- Testimonials Grid -->
          <div class="grid grid-cols-1 gap-12">
            <div v-for="testimonial in testimonials" :key="testimonial.name" 
              class="group relative grid md:grid-cols-2 gap-8 items-center bg-gray-50 rounded-3xl p-8 md:p-12 overflow-hidden hover:bg-gray-100 transition-all duration-500"
            >
              <!-- Image Section -->
              <div class="relative aspect-[4/3] rounded-2xl overflow-hidden">
                <img 
                  :src="testimonial.image" 
                  :alt="testimonial.name"
                  class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
              </div>

              <!-- Content Section -->
              <div class="space-y-6">
                <!-- Quote icon -->
                <div class="w-12 h-12 bg-black/5 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6 text-gray-500" fill="none" viewBox="0 0 24 24">
                    <path stroke="currentColor" stroke-linecap="round" stroke-width="2" 
                      d="M7 16.8V9.2h4l-4-4v4-4h4m6 11.6V9.2h4l-4-4v4-4h4"
                    />
                  </svg>
                </div>

                <!-- Testimonial content -->
                <p class="text-gray-600 text-xl md:text-2xl font-light leading-relaxed">
                  {{ testimonial.text }}
                </p>

                <!-- Author -->
                <div class="flex items-center gap-4">
                  <div>
                    <h4 class="text-xl font-semibold text-gray-900">{{ testimonial.name }}</h4>
                    <p class="text-base text-gray-500">{{ testimonial.role }}</p>
                  </div>
                </div>

                <!-- Rating -->
                <div class="flex items-center gap-1">
                  <Star v-for="i in 5" :key="i" class="w-5 h-5 text-yellow-400 fill-current" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- CTA Section -->
      <section id="pricing" class="w-full py-24 md:py-32 bg-white text-center relative overflow-hidden">
        <!-- Background elements -->
        <div class="absolute inset-0 pointer-events-none hidden md:block">
          <!-- Icons -->
          <div class="absolute w-32 h-32 border-2 border-gray-100 rounded-2xl -top-10 -right-10 opacity-20 overflow-hidden">
            <div class="absolute inset-0 flex items-center justify-center">
              <QrCode class="w-22 h-22 text-orange-500" />
            </div>
          </div>
          
          <!-- Restaurant icon -->
          <div class="absolute w-24 h-24 border-2 border-gray-100 rounded-2xl bottom-20 -left-12 opacity-15 overflow-hidden rotate-12">
            <div class="absolute inset-0 flex items-center justify-center">
              <UtensilsCrossed class="w-22 h-12 text-orange-500" />
            </div>
          </div>

          <!-- Mobile device with menu -->
          <div class="absolute w-20 h-32 border-2 border-gray-100 rounded-2xl top-1/3 right-20 opacity-20">
            <div class="absolute top-2 left-1/2 -translate-x-1/2 w-8 h-1 bg-gray-200 rounded-full"></div>
            <div class="absolute inset-0 flex items-center justify-center mt-6">
              <Menu class="w-22 h-22 text-orange-500" />
            </div>
          </div>

          <!-- Clock icon -->
          <div class="absolute w-16 h-16 border-2 border-gray-100 rounded-2xl top-40 left-20 opacity-15 rotate-6">
            <div class="absolute inset-0 flex items-center justify-center">
              <Clock class="w-22 h-22 text-orange-500" />
            </div>
          </div>

          <!-- Stats icon -->
          <div class="absolute w-20 h-20 border-2 border-gray-100 rounded-2xl bottom-40 right-40 opacity-20 -rotate-12">
            <div class="absolute inset-0 flex items-center justify-center">
              <BarChart2 class="w-22 h-22 text-orange-500" />
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="max-w-6xl mx-auto px-4 sm:px-6 relative">
          <div class="bg-white/80 backdrop-blur-sm rounded-3xl p-8 md:p-12 border border-gray-100 -shadow-sm">
            <h2 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
              Prêt à digitaliser votre menu ?
            </h2>
            <p class="text-lg md:text-xl text-gray-500 mb-12 max-w-2xl mx-auto">
              Rejoignez les restaurants qui ont déjà adopté KulaQr pour moderniser leur service
            </p>
            <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
              <NuxtLink 
                to="/auth/register"
                class="w-full sm:w-auto px-8 py-4 bg-black text-white rounded-full text-lg font-medium hover:opacity-90 transition-all -shadow-lg hover:-shadow-xl hover:scale-[1.02] flex items-center justify-center group"
              >
                <span>Commencer gratuitement</span>
                <ArrowRight class="w-5 h-5 ml-2 transition-transform group-hover:translate-x-1" />
              </NuxtLink>
              <a 
                href="#pricing"
                class="w-full sm:w-auto px-8 py-4 bg-gray-100 text-gray-900 rounded-full text-lg font-medium hover:bg-gray-200 transition-all"
              >
                Découvrir nos tarifs
              </a>
            </div>
          </div>
        </div>
      </section>
      
      <!-- Footer - Minimal Apple-style design -->
      <footer id="contact" class="w-full bg-white py-12 md:py-16 border-t border-gray-100">
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
  Linkedin,
  Menu,
  BarChart2
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
    image: 'https://images.pexels.com/photos/3814446/pexels-photo-3814446.jpeg',
    text: "KulaQr a transformé notre service. Les clients adorent scanner le QR code et notre équipe gagne un temps précieux. Le support est excellent !"
  },
  {
    name: 'Marie Martin',
    role: 'Café des Arts',
    image: 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg',
    text: "Une solution intuitive qui nous a permis de moderniser notre établissement. Les mises à jour du menu sont instantanées et les statistiques très utiles."
  },
  {
    name: 'Pierre Dubois',
    role: 'Bistrot du Coin',
    image: 'https://images.pexels.com/photos/2544829/pexels-photo-2544829.jpeg',
    text: "Depuis que nous utilisons KulaQr, nos clients sont plus satisfaits et nos serveurs plus efficaces. Un vrai plus pour notre restaurant !"
  }
]
</script>

<style scoped>
html {
  scroll-behavior: smooth;
}

/* Smooth scrolling for anchor links */
a[href^="#"] {
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

/* Supprimer les animations précédentes */
.absolute {
  animation: none;
}

@keyframes float {
  0% { transform: translate(0, 0) rotate(var(--rotation, 0deg)); }
  50% { transform: translate(-10px, 10px) rotate(calc(var(--rotation, 0deg) + 5deg)); }
  100% { transform: translate(0, 0) rotate(var(--rotation, 0deg)); }
}

.pattern-grid {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Cpath fill='%23000000' d='M8 21H4a1 1 0 0 1-1-1v-4a1 1 0 0 0-2 0v4a3 3 0 0 0 3 3h4a1 1 0 0 0 0-2m14-6a1 1 0 0 0-1 1v4a1 1 0 0 1-1 1h-4a1 1 0 0 0 0 2h4a3 3 0 0 0 3-3v-4a1 1 0 0 0-1-1M20 1h-4a1 1 0 0 0 0 2h4a1 1 0 0 1 1 1v4a1 1 0 0 0 2 0V4a3 3 0 0 0-3-3M2 9a1 1 0 0 0 1-1V4a1 1 0 0 1 1-1h4a1 1 0 0 0 0-2H4a3 3 0 0 0-3 3v4a1 1 0 0 0 1 1m8-4H6a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1M9 9H7V7h2Zm5 2h4a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1m1-4h2v2h-2Zm-5 6H6a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1m-1 4H7v-2h2Zm5-1a1 1 0 0 0 1-1a1 1 0 0 0 0-2h-1a1 1 0 0 0-1 1v1a1 1 0 0 0 1 1m4-3a1 1 0 0 0-1 1v3a1 1 0 0 0 0 2h1a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1m-4 4a1 1 0 1 0 1 1a1 1 0 0 0-1-1'/%3E%3C/svg%3E");
  background-repeat: repeat;
  background-size: 48px 48px;
  transform: rotate(0deg);
  animation: patternFloat 60s linear infinite;
}

@keyframes patternFloat {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 48px 48px;
  }
}

/* Enhanced gradient animations */
.bg-gradient-to-br {
  background-size: 200% 200%;
  animation: gradientAnimation 8s ease infinite;
}

@keyframes gradientAnimation {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* New styles for enhanced hover effects */
.group:hover .group-hover\:scale-110 {
  transform: scale(1.1);
}

.group:hover .group-hover\:translate-x-2 {
  transform: translateX(0.5rem);
}
</style>
