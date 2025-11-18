<template>
  <div class="min-h-screen bg-white">
    <div class="relative">
      <!-- Navigation Bar -->
      <Navbar />

      <!-- Hero Section - Ultra minimal -->
      <section class="w-full min-h-[90vh] relative flex items-center justify-center pt-20 pb-32">
        <div class="relative w-full max-w-6xl mx-auto px-6 md:px-8 text-center">
          <!-- Main headline -->
          <h1 class="text-6xl sm:text-7xl md:text-8xl lg:text-9xl font-bold tracking-tight text-gray-900 leading-[1.05] mb-10">
            Menu digital.<br />
            <span class="text-orange-500">Simple.</span>
          </h1>
          
          <!-- Subheadline -->
          <p class="text-2xl sm:text-3xl md:text-4xl text-gray-500 font-light max-w-4xl mx-auto mb-16 leading-relaxed">
            QR code. Scan. Commande.<br class="hidden sm:block" />
            C'est tout.
          </p>
          
          <!-- CTA Button -->
          <div class="flex flex-col sm:flex-row items-center justify-center gap-6 mb-20">
            <NuxtLink 
              to="/auth/register"
              class="group px-12 py-6 bg-gray-900 text-white rounded-full text-xl font-semibold transition-all duration-200 hover:bg-gray-800 flex items-center justify-center"
            >
              <span>Démarrer gratuitement</span>
              <ArrowRight class="w-5 h-5 ml-2 transition-transform group-hover:translate-x-1" />
            </NuxtLink>
          </div>
          
          <!-- Social proof - minimalist -->
          <div class="flex items-center justify-center gap-16 text-gray-400 text-sm">
            <div class="text-center">
              <div class="text-4xl font-bold text-gray-900 mb-1">50+</div>
              <div>Restaurants</div>
            </div>
            <div class="text-center">
              <div class="text-4xl font-bold text-gray-900 mb-1">1K+</div>
              <div>Scans/mois</div>
            </div>
            <div class="text-center">
              <div class="text-4xl font-bold text-gray-900 mb-1">15%</div>
              <div>+ Efficacité</div>
            </div>
          </div>
        </div>
      </section>

      <!-- Features Section - Clean cards -->
      <section id="features" class="w-full py-32 md:py-40 bg-gray-50-">
        <div class="max-w-7xl mx-auto px-6 md:px-8">
          <!-- Section header -->
          <div class="text-center mb-32">
            <h2 class="text-5xl sm:text-6xl md:text-7xl font-bold text-gray-900 mb-8">
              Tout ce qu'il faut
            </h2>
            <p class="text-2xl text-gray-500 max-w-2xl mx-auto">
              Rien de plus, rien de moins
            </p>
          </div>
          
          <!-- Hero Feature with Image -->
          <div class="grid md:grid-cols-2 gap-16 lg:gap-24 items-center mb-32">
            <!-- Image -->
            <div class="relative order-2 md:order-1">
              <div class="relative rounded-2xl overflow-hidden border border-gray-200 --shadow-lg">
                <img 
                  src="~/assets/images/scan.png"
                  alt="Menu QR Code Demo"
                  class="w-full h-auto"
                />
              </div>
            </div>
            
            <!-- Content -->
            <div class="order-1 md:order-2">
              <h3 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-8 leading-tight">
                Scan.<br />Commande.<br />Fini.
              </h3>
              <p class="text-xl text-gray-600 leading-relaxed mb-10">
                Un QR code sur la table. Votre client scanne. Le menu s'ouvre. Il commande. Simple.
              </p>
              <ul class="space-y-5">
                <li class="flex items-center gap-4">
                  <div class="w-2 h-2 rounded-full bg-gray-900"></div>
                  <span class="text-lg text-gray-700">Interface rapide</span>
                </li>
                <li class="flex items-center gap-4">
                  <div class="w-2 h-2 rounded-full bg-gray-900"></div>
                  <span class="text-lg text-gray-700">Aucune app requise</span>
                </li>
                <li class="flex items-center gap-4">
                  <div class="w-2 h-2 rounded-full bg-gray-900"></div>
                  <span class="text-lg text-gray-700">Tous smartphones</span>
                </li>
              </ul>
            </div>
          </div>
          
          <!-- Feature cards - 3 columns minimal -->
          <div class="grid md:grid-cols-3 gap-8 bg-white">
            <!-- Feature 1 -->
            <div class="bg-white border border-gray-200 rounded-2xl p-12 text-center hover:border-gray-900 transition-all duration-200">
              <div class=" -bg-gray-900 rounded-xl flex items-center justify-center mb-8">
                <QrCode class="w-14 h-14 text-gray-900 md:text-3xl  " />
              </div>
              <h3 class="text-2xl font-bold text-gray-900 mb-4">QR Code</h3>
              <p class="text-gray-600 leading-relaxed">
                Un code par table. Scan instantané. Menu accessible.
              </p>
            </div>
            
            <!-- Feature 2 -->
            <div class="bg-white border border-gray-200 rounded-2xl p-12 text-center hover:border-gray-900 transition-all duration-200">
              <div class=" -bg-gray-900 rounded-xl flex items-center justify-center mb-8">
                <TrendingUp class="w-14 h-14 text-gray-900 md:text-3xl  " />
              </div>
              <h3 class="text-2xl font-bold text-gray-900 mb-4">Temps réel</h3>
              <p class="text-gray-600 leading-relaxed">
                Changez prix et produits. Mise à jour instantanée.
              </p>
            </div>
            
            <!-- Feature 3 -->
            <div class="bg-white border border-gray-200 rounded-2xl p-12 text-center hover:border-gray-900 transition-all duration-200">
              <div class=" rounded-xl flex items-center justify-center mb-8">
                <Shield class="w-14 h-14 text-gray-900 md:text-3xl  " />
              </div>
              <h3 class="text-2xl font-black text-gray-900 mb-4">Analytics</h3>
              <p class="text-gray-600 leading-relaxed">
                Suivez vos ventes. Optimisez votre menu. Données claires.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- How it works - Ultra simple -->
      <section class="w-full py-32 md:py-40 bg-white">
        <div class="max-w-7xl mx-auto px-6 md:px-8">
          <div class="text-center mb-32">
            <h2 class="text-5xl sm:text-6xl md:text-7xl font-bold text-gray-900 mb-8">
              3 étapes
            </h2>
            <p class="text-2xl text-gray-500 max-w-2xl mx-auto">
              C'est rapide
            </p>
          </div>
          
          <!-- Steps - Minimal version -->
          <div class="space-y-32">
            <!-- Step 1 -->
            <div class="grid md:grid-cols-2 gap-16 items-center">
              <div class="order-2 md:order-1">
                <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-900 rounded-xl mb-8">
                  <span class="text-3xl font-bold text-white">1</span>
                </div>
                <h3 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
                  Créez
                </h3>
                <p class="text-xl text-gray-600 leading-relaxed">
                  Ajoutez produits et prix. Interface simple. Quelques minutes suffisent.
                </p>
              </div>
              <div class="order-1 md:order-2">
                <div class="relative rounded-2xl overflow-hidden border border-gray-200 --shadow-lg">
                  <img 
                    src="~/assets/images/flyer1.png"
                    alt="Créer votre menu"
                    class="w-full h-auto"
                  />
                </div>
              </div>
            </div>
            
            <!-- Step 2 -->
            <div class="grid md:grid-cols-2 gap-16 items-center">
              <div>
                <div class="relative rounded-2xl overflow-hidden border border-gray-200 --shadow-lg">
                  <img 
                    src="~/assets/images/scan.png"
                    alt="Générer QR codes"
                    class="w-full h-auto"
                  />
                </div>
              </div>
              <div>
                <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-900 rounded-xl mb-8">
                  <span class="text-3xl font-bold text-white">2</span>
                </div>
                <h3 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
                  Générez
                </h3>
                <p class="text-xl text-gray-600 leading-relaxed">
                  QR codes personnalisés. Un par table. Imprimez ou affichez.
                </p>
              </div>
            </div>
            
            <!-- Step 3 -->
            <div class="grid md:grid-cols-2 gap-16 items-center">
              <div class="order-2 md:order-1">
                <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-900 rounded-xl mb-8">
                  <span class="text-3xl font-bold text-white">3</span>
                </div>
                <h3 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
                  Lancez
                </h3>
                <p class="text-xl text-gray-600 leading-relaxed">
                  Vos clients scannent. Commandent. Vous recevez. En temps réel.
                </p>
              </div>
              <div class="order-1 md:order-2">
                <div class="relative rounded-2xl overflow-hidden border border-gray-200 bg-gray-50 p-16">
                  <div class="aspect-square flex items-center justify-center">
                    <div class="text-center">
                      <div class="w-24 h-24 bg-gray-900 rounded-full flex items-center justify-center mx-auto mb-6">
                        <svg class="w-12 h-12 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                        </svg>
                      </div>
                      <p class="text-2xl font-bold text-gray-900">Menu actif</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Testimonial Section - Single clean -->
      <section class="w-full py-32 md:py-40 bg-gray-900 text-white">
        <div class="max-w-4xl mx-auto px-6 md:px-8 text-center">
          <p class="text-3xl sm:text-4xl md:text-5xl font-light leading-relaxed mb-16">
            "Nos clients adorent. Notre équipe gagne du temps. Simple et efficace."
          </p>
          
          <div class="flex items-center justify-center gap-5">
            <div class="w-16 h-16 rounded-full bg-orange-500"></div>
            <div class="text-left">
              <div class="text-xl font-semibold">Aminata Diallo</div>
              <div class="text-gray-400">Le Teranga, Dakar</div>
            </div>
          </div>
        </div>
      </section>

      <!-- CTA Section - Bold and clean -->
      <section id="pricing" class="w-full py-32 md:py-40 bg-orange-500 text-white text-center">
        <div class="max-w-4xl mx-auto px-6 md:px-8">
          <h2 class="text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-bold mb-10 leading-tight">
            Commencez<br />maintenant
          </h2>
          <p class="text-2xl sm:text-3xl font-light mb-16 opacity-90">
            Gratuit. Sans carte bancaire.
          </p>
          <NuxtLink
            to="/auth/register"
            class="group inline-flex items-center px-12 py-6 bg-white text-gray-900 rounded-full text-xl font-bold hover:bg-gray-100 transition-all duration-200"
          >
            <span>Démarrer</span>
            <ArrowRight class="w-6 h-6 ml-3 transition-transform group-hover:translate-x-1" />
          </NuxtLink>
        </div>
      </section>
      
      <!-- Footer - Ultra minimal -->
          <!-- Footer - Ultra clean and modern -->
      <footer id="contact" class="w-full bg-white border-t border-gray-200 py-16">
        <div class="max-w-7xl mx-auto px-6 md:px-8">
          <!-- Main footer content -->
          <div class="grid grid-cols-1 md:grid-cols-12 gap-12 mb-12">
            <!-- Brand - Takes more space -->
            <div class="md:col-span-5">
              <div class="text-3xl font-bold mb-3 text-gray-900">
                KulaQr
              </div>
              <p class="text-gray-500 text-base mb-6 max-w-sm">
                Menu digital simple et efficace pour restaurants modernes.
              </p>
              <a 
                href="mailto:ndgallogho@gmail.com" 
                class="inline-flex items-center text-gray-900 hover:text-orange-500 transition-colors font-medium"
              >
                ndgallogho@gmail.com
                <ArrowRight class="w-4 h-4 ml-2" />
              </a>
            </div>

            <!-- Links - Compact columns -->
            <div class="md:col-span-7 grid grid-cols-3 gap-8">
              <!-- Product -->
              <div>
                <h3 class="font-semibold mb-4 text-sm text-gray-900">Produit</h3>
                <ul class="space-y-2.5 text-sm">
                  <li><a href="#features" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Fonctionnalités</a></li>
                  <li><a href="#pricing" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Tarifs</a></li>
                </ul>
              </div>

              <!-- Company -->
              <div>
                <h3 class="font-semibold mb-4 text-sm text-gray-900">Entreprise</h3>
                <ul class="space-y-2.5 text-sm">
                  <li><a href="/contact" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Contact</a></li>
                </ul>
              </div>

              <!-- Legal -->
              <div>
                <h3 class="font-semibold mb-4 text-sm text-gray-900">Légal</h3>
                <ul class="space-y-2.5 text-sm">
                  <!-- <li><a href="/legal/mentions-legales" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Mentions légales</a></li> -->
                  <li><a href="/legal/privacy" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Confidentialité</a></li>
                  <li><a href="/legal/terms" class="text-gray-600 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">CGU</a></li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Footer bottom -->
          <div class="pt-8 border-t border-gray-200 flex flex-col md:flex-row justify-between items-center gap-4">
            <p class="text-sm text-gray-500">© 2025 KulaQr — Dakar, Sénégal</p>
            <div class="flex items-center gap-6">
              <a href="#" class="text-sm text-gray-500 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Twitter</a>
              <a href="#" class="text-sm text-gray-500 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">LinkedIn</a>
              <a href="#" class="text-sm text-gray-500 hover:text-gray-900 hover:underline decoration-red-500 transition-colors">Instagram</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useSeo, useAutoScroll } from '~/composables/useSeo'
import { useStructuredData } from '~/composables/useStructuredData'
import {
  QrCode,
  ArrowRight,
  TrendingUp,
  Shield
} from 'lucide-vue-next'

// Configuration SEO pour la page d'accueil
const { setHomeMeta } = useSeo()
setHomeMeta()

// Données structurées pour la page d'accueil
const { generateWebSiteSchema, generateOrganizationSchema } = useStructuredData()

useHead({
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify(generateWebSiteSchema())
    },
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify(generateOrganizationSchema())
    }
  ]
})
</script>

<style scoped>
/* Typography optimization */
h1, h2, h3, h4, h5, h6 {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
  letter-spacing: -0.03em;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}
</style>