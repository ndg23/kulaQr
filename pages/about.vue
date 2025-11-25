
<template>
  <div class="w-full">
    <!-- Hero Section -->
    <section class="w-full pt-32 pb-24 md:pt-40 md:pb-32 bg-white">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="max-w-3xl mx-auto text-center">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase mb-8 block">Notre Histoire</span>
          <h1 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900 mb-8">
            Nous révolutionnons <br/>l'expérience restaurant
          </h1>
          <p class="text-xl text-gray-500 leading-relaxed">
            KulaQr est né d'une vision simple : rendre les menus plus accessibles, plus dynamiques et plus intelligents pour tous.
          </p>
        </div>
      </div>
    </section>

    <!-- Stats Grid -->
    <section class="w-full py-24 bg-gray-50">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-12">
          <div class="text-center">
            <div class="text-5xl md:text-6xl font-semibold text-gray-900 mb-3">2021</div>
            <p class="text-sm text-gray-500">Année de création</p>
          </div>
          <div class="text-center">
            <div class="text-5xl md:text-6xl font-semibold text-gray-900 mb-3">5+</div>
            <p class="text-sm text-gray-500">Pays desservis</p>
          </div>
          <div class="text-center">
            <div class="text-5xl md:text-6xl font-semibold text-gray-900 mb-3">10+</div>
            <p class="text-sm text-gray-500">Employés passionnés</p>
          </div>
          <div class="text-center">
            <div class="text-5xl md:text-6xl font-semibold text-gray-900 mb-3">2K+</div>
            <p class="text-sm text-gray-500">Etablissements satisfaits</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Mission Section -->
    <section class="w-full py-24 md:py-32 bg-white overflow-hidden">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="grid md:grid-cols-2 gap-12 md:gap-20 items-center">
          <div class="relative aspect-square">
            <div class="absolute inset-0 bg-gradient-to-br from-gray-100 to-gray-200 rounded-3xl transform rotate-6"></div>
            <img 
              src="~/assets/images/flyer.png" 
              alt="Notre équipe"
              class="relative w-full h-full object-cover rounded-3xl shadow-xl transform -rotate-3"
            />
          </div>
          <div class="space-y-8">
            <h2 class="text-3xl md:text-4xl font-semibold text-gray-900">Notre mission</h2>
            <p class="text-xl text-gray-500 leading-relaxed">
              Nous croyons que la technologie doit simplifier la vie, pas la compliquer. C'est pourquoi nous avons créé une solution qui permet aux restaurants de se digitaliser sans effort, tout en offrant une expérience client exceptionnelle.
            </p>
            <ul class="space-y-4">
              <li class="flex items-center space-x-4">
                <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
                  <Check class="w-4 h-4 text-white" />
                </div>
                <span class="text-lg text-gray-700">Interface intuitive et moderne</span>
              </li>
              <li class="flex items-center space-x-4">
                <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
                  <Check class="w-4 h-4 text-white" />
                </div>
                <span class="text-lg text-gray-700">Support client 24/7</span>
              </li>
              <li class="flex items-center space-x-4">
                <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
                  <Check class="w-4 h-4 text-white" />
                </div>
                <span class="text-lg text-gray-700">Innovation continue</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </section>

   

    <!-- Values Section -->
    <section class="w-full py-24 md:py-32 bg-white">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="text-center mb-16">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">Nos valeurs</span>
          <h2 class="mt-4 text-4xl font-semibold text-gray-900">Ce qui nous guide</h2>
        </div>
        
        <div class="grid md:grid-cols-3 gap-12">
          <div class="text-center">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Heart class="w-8 h-8 text-gray-900" />
            </div>
            <h3 class="text-xl font-medium text-gray-900 mb-4">Passion</h3>
            <p class="text-gray-500">Nous aimons ce que nous faisons et cela se reflète dans chaque aspect de notre produit.</p>
          </div>
          
          <div class="text-center">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Lightbulb class="w-8 h-8 text-gray-900" />
            </div>
            <h3 class="text-xl font-medium text-gray-900 mb-4">Innovation</h3>
            <p class="text-gray-500">Nous repoussons constamment les limites pour créer des solutions toujours plus intelligentes.</p>
          </div>
          
          <div class="text-center">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Users class="w-8 h-8 text-gray-900" />
            </div>
            <h3 class="text-xl font-medium text-gray-900 mb-4">Collaboration</h3>
            <p class="text-gray-500">Le succès de nos clients est notre succès. Nous grandissons ensemble.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="w-full py-24 md:py-32 bg-gray-900 text-white">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 text-center">
        <h2 class="text-4xl md:text-5xl font-semibold mb-8">Rejoignez l'aventure KulaQr</h2>
        <p class="text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
          Découvrez comment nous pouvons transformer ensemble l'expérience de vos clients.
        </p>
        <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
          <NuxtLink 
            to="/contact"
            class="w-full sm:w-auto px-8 py-4 bg-white text-black rounded-full text-lg font-medium hover:opacity-90 transition-all flex items-center justify-center"
          >
            <span>Contactez-nous</span>
            <ArrowRight class="w-5 h-5 ml-2" />
          </NuxtLink>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { useSeo } from '~/composables/useSeo'
import { 
  Check, 
  ArrowRight, 
  Linkedin, 
  Twitter,
  Heart,
  Lightbulb,
  Users
} from 'lucide-vue-next'

const team = [
  {
    name: 'Thomas Martin',
    role: 'CEO & Co-fondateur',
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    linkedin: '#',
    twitter: '#'
  },
  {
    name: 'Sophie Bernard',
    role: 'CTO',
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    linkedin: '#',
    twitter: '#'
  },
  {
    name: 'Lucas Dubois',
    role: 'Head of Design',
    image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
    linkedin: '#',
    twitter: '#'
  }
]

// Configuration SEO pour la page À propos
const { setAboutMeta } = useSeo()
setAboutMeta()
</script>

<style scoped>
/* Apple-style typography */
h1, h2, h3, h4, h5, h6 {
  font-family: SF Pro Display, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

body {
  font-family: SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style> 