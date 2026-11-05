<template>
  <div class="min-h-dvh bg-white">
    <Navbar />

    <main>
      <!-- ========================= Hero ========================= -->
      <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 sm:pt-28 pb-10">
        <div class="grid lg:grid-cols-2 gap-10 lg:gap-14 items-center">
          <div>
            <span class="inline-flex items-center gap-2 h-9 px-4 rounded-full bg-gray-100 text-sm font-extrabold text-gray-900">
              <span class="w-2 h-2 rounded-full bg-[#FB6A00] animate-pulse"></span>
              Menu digital · sans application
            </span>
            <h1 class="mt-5 text-5xl sm:text-6xl lg:text-7xl font-black tracking-tight text-gray-900 leading-[1.02]">
              Scannez.<br />Commandez.<br />
              <span class="inline-block mt-1 px-4 rounded-[1.25rem] bg-[#FB6A00] text-black">Servez.</span>
            </h1>
            <p class="mt-6 text-xl text-gray-600 font-medium leading-relaxed max-w-lg">
              Un QR code sur chaque table. Vos clients ouvrent le menu, commandent, et votre équipe reçoit la commande en direct.
            </p>
            <div class="mt-8 flex flex-col sm:flex-row gap-3">
              <NuxtLink
                to="/auth/register"
                class="group inline-flex items-center justify-center gap-2 h-14 px-8 rounded-full bg-black text-white text-lg font-black active:scale-[0.97] transition-all"
              >
                Démarrer gratuitement
                <ArrowRight class="w-5 h-5 transition-transform group-hover:translate-x-1" :stroke-width="3" />
              </NuxtLink>
              <a
                href="#steps"
                class="inline-flex items-center justify-center h-14 px-8 rounded-full bg-gray-100 text-gray-900 text-lg font-extrabold hover:bg-gray-200 active:scale-[0.97] transition-all"
              >Voir comment ça marche</a>
            </div>
            <ul class="mt-8 flex flex-wrap gap-2">
              <li v-for="chip in chips" :key="chip" class="inline-flex items-center gap-2 h-9 px-4 rounded-full bg-white border border-gray-200 text-sm font-extrabold text-gray-900">
                <Check class="w-4 h-4 text-[#FB6A00]" :stroke-width="3.5" />
                {{ chip }}
              </li>
            </ul>
          </div>

          <!-- La grande carte orange avec un aperçu du menu client -->
          <div class="rounded-[2rem] bg-[#FB6A00] p-6 sm:p-10 flex justify-center">
            <div class="w-full max-w-[19rem] rounded-[2.5rem] bg-white p-3 shadow-2xl shadow-black/20" aria-hidden="true">
              <div class="rounded-[2rem] bg-white overflow-hidden">
                <div class="flex items-center justify-between px-4 pt-4">
                  <span class="inline-flex items-center h-8 px-4 rounded-full bg-black text-white text-xs font-black">Table 7</span>
                  <span class="inline-flex items-center h-8 px-3 rounded-full bg-gray-100 text-[11px] font-extrabold text-gray-900">Chez Awa</span>
                </div>
                <div class="flex gap-1.5 px-4 py-3 overflow-hidden">
                  <span class="h-8 px-3 rounded-full bg-black text-white text-[11px] font-extrabold inline-flex items-center">Tout</span>
                  <span class="h-8 px-3 rounded-full bg-gray-100 text-gray-900 text-[11px] font-extrabold inline-flex items-center">Plats</span>
                  <span class="h-8 px-3 rounded-full bg-gray-100 text-gray-900 text-[11px] font-extrabold inline-flex items-center">Boissons</span>
                </div>
                <div class="px-3 space-y-2 pb-3">
                  <div v-for="demo in demoItems" :key="demo.name" class="rounded-3xl bg-gray-100 p-2.5 flex items-center gap-2.5">
                    <span class="w-12 h-12 rounded-2xl bg-white flex items-center justify-center text-lg font-black text-[#FB6A00]">{{ demo.name.charAt(0) }}</span>
                    <span class="min-w-0 flex-1 leading-tight">
                      <span class="block text-[13px] font-black text-gray-900 truncate">{{ demo.name }}</span>
                      <span class="mt-1 inline-flex items-center h-5 px-2 rounded-full bg-[#FB6A00] text-black text-[10px] font-black">{{ demo.price }}</span>
                    </span>
                    <span class="w-9 h-9 rounded-full bg-black text-white flex items-center justify-center text-lg font-black">+</span>
                  </div>
                </div>
                <div class="px-3 pb-3">
                  <div class="h-14 rounded-full bg-black text-white pl-4 pr-1.5 flex items-center gap-2">
                    <span class="flex-1 leading-tight">
                      <span class="block text-[11px] font-black">3 articles</span>
                      <span class="block text-[9px] font-semibold opacity-70">2× Poulet braisé, 1× Bissap</span>
                    </span>
                    <span class="text-sm font-black tabular-nums">13 500 F</span>
                    <span class="w-10 h-10 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><ShoppingBag class="w-4 h-4" :stroke-width="3" /></span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- ========================= Fonctionnalités ========================= -->
      <section id="features" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
        <div class="max-w-2xl">
          <h2 class="text-4xl sm:text-5xl font-black tracking-tight text-gray-900">Tout ce qu'il faut.</h2>
          <p class="mt-3 text-xl text-gray-500 font-medium">Rien de plus, rien de moins.</p>
        </div>

        <div class="mt-10 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <article v-for="f in features" :key="f.title" class="rounded-[2rem] bg-gray-100 p-6 sm:p-7">
            <span class="w-14 h-14 rounded-full bg-[#FB6A00] text-black flex items-center justify-center">
              <component :is="f.icon" class="w-7 h-7" :stroke-width="2.5" />
            </span>
            <h3 class="mt-5 text-xl font-black text-gray-900">{{ f.title }}</h3>
            <p class="mt-2 text-base font-medium text-gray-600 leading-relaxed">{{ f.text }}</p>
          </article>
        </div>
      </section>

      <!-- ========================= 3 étapes ========================= -->
      <section id="steps" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16">
        <div class="rounded-[2rem] bg-black text-white p-6 sm:p-12">
          <h2 class="text-4xl sm:text-5xl font-black tracking-tight">3 étapes.</h2>
          <p class="mt-3 text-xl text-white/70 font-medium">C'est rapide.</p>

          <div class="mt-10 grid md:grid-cols-3 gap-4">
            <article v-for="(step, i) in steps" :key="step.title" class="rounded-[2rem] bg-white/10 p-6">
              <span class="w-12 h-12 rounded-full bg-[#FB6A00] text-black flex items-center justify-center text-xl font-black">{{ i + 1 }}</span>
              <h3 class="mt-5 text-2xl font-black">{{ step.title }}</h3>
              <p class="mt-2 text-base font-medium text-white/75 leading-relaxed">{{ step.text }}</p>
            </article>
          </div>
        </div>
      </section>

      <!-- ========================= Toute l'équipe ========================= -->
      <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
        <div class="max-w-2xl">
          <h2 class="text-4xl sm:text-5xl font-black tracking-tight text-gray-900">Pour toute l'équipe.</h2>
          <p class="mt-3 text-xl text-gray-500 font-medium">Chacun voit ce dont il a besoin, rien de plus.</p>
        </div>

        <div class="mt-10 grid lg:grid-cols-3 gap-4">
          <!-- Le personnel : un aperçu de l'écran de travail -->
          <article class="rounded-[2rem] bg-gray-100 p-6 flex flex-col">
            <p class="text-xs font-extrabold uppercase tracking-wide text-gray-500">Le personnel</p>
            <h3 class="mt-1 text-2xl font-black text-gray-900">Une file, un bouton</h3>
            <p class="mt-2 text-base font-medium text-gray-600">Les commandes arrivent toutes seules, la plus ancienne en premier. Un appui fait avancer la commande.</p>
            <div class="mt-5 rounded-[1.75rem] bg-white p-4" aria-hidden="true">
              <div class="flex items-center justify-between">
                <span class="inline-flex items-center h-9 px-4 rounded-full bg-black text-white text-sm font-black">Table 4</span>
                <span class="inline-flex items-center gap-1.5 h-8 px-3 rounded-full bg-[#FB6A00] text-black text-xs font-black tabular-nums"><Clock class="w-3.5 h-3.5" :stroke-width="3" /> 12 min</span>
              </div>
              <p class="mt-3 text-sm font-bold text-gray-900">2× Poulet braisé</p>
              <p class="text-sm font-bold text-gray-900">1× Jus de bissap</p>
              <span class="mt-3 flex items-center justify-center h-11 rounded-full bg-black text-white text-xs font-black uppercase tracking-wide">Lancer la préparation</span>
            </div>
          </article>

          <article class="rounded-[2rem] bg-gray-100 p-6 flex flex-col">
            <p class="text-xs font-extrabold uppercase tracking-wide text-gray-500">Le gérant</p>
            <h3 class="mt-1 text-2xl font-black text-gray-900">Tout le restaurant, en un lieu</h3>
            <p class="mt-2 text-base font-medium text-gray-600">Menu, catégories, tables et QR codes, équipe et codes PIN, commandes. Les chiffres du jour en une grande carte.</p>
            <div class="mt-5 rounded-[1.75rem] bg-[#FB6A00] p-5 text-black" aria-hidden="true">
              <p class="text-xs font-extrabold">Aujourd'hui</p>
              <p class="text-4xl font-black tracking-tight tabular-nums">128 500 F</p>
              <div class="mt-3 flex flex-wrap gap-1.5">
                <span class="h-7 px-3 rounded-full bg-white/85 text-[11px] font-extrabold inline-flex items-center">34 commandes</span>
                <span class="h-7 px-3 rounded-full bg-white/85 text-[11px] font-extrabold inline-flex items-center">212 scans</span>
              </div>
            </div>
          </article>

          <article class="rounded-[2rem] bg-gray-100 p-6 flex flex-col">
            <p class="text-xs font-extrabold uppercase tracking-wide text-gray-500">Le client</p>
            <h3 class="mt-1 text-2xl font-black text-gray-900">Il scanne, il suit sa commande</h3>
            <p class="mt-2 text-base font-medium text-gray-600">Pas d'application ni de compte. Il voit l'avancement : en attente, en préparation, prête.</p>
            <div class="mt-5 rounded-[1.75rem] bg-white p-5 text-center" aria-hidden="true">
              <span class="w-14 h-14 mx-auto rounded-full bg-[#FFECD8] text-[#C54E00] flex items-center justify-center"><Clock class="w-7 h-7" :stroke-width="2.75" /></span>
              <p class="mt-3 text-xl font-black text-gray-900">En préparation…</p>
              <div class="mt-3 h-2 rounded-full bg-gray-100 overflow-hidden"><div class="h-full w-3/4 rounded-full bg-[#FB6A00]"></div></div>
            </div>
          </article>
        </div>
      </section>

      <!-- ========================= Appel à l'action ========================= -->
      <section id="pricing" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 sm:pb-24">
        <div class="rounded-[2rem] bg-[#FB6A00] text-black p-8 sm:p-14 text-center">
          <h2 class="text-5xl sm:text-6xl lg:text-7xl font-black tracking-tight leading-[1.02]">Commencez<br />maintenant.</h2>
          <p class="mt-5 text-xl sm:text-2xl font-bold text-black/80">Gratuit. Sans carte bancaire.</p>
          <NuxtLink
            to="/auth/register"
            class="group mt-8 inline-flex items-center gap-2 h-16 px-10 rounded-full bg-black text-white text-xl font-black active:scale-[0.97] transition-all"
          >
            Démarrer
            <ArrowRight class="w-6 h-6 transition-transform group-hover:translate-x-1" :stroke-width="3" />
          </NuxtLink>
        </div>
      </section>
    </main>

    <!-- ========================= Pied de page ========================= -->
    <footer id="contact" class="border-t border-gray-100">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
        <div class="grid md:grid-cols-12 gap-10">
          <div class="md:col-span-5">
            <p class="text-3xl font-black text-gray-900">Kula <span class="text-[#FB6A00]">QR</span></p>
            <p class="mt-3 text-base font-medium text-gray-500 max-w-sm">Menu digital simple et efficace pour restaurants modernes.</p>
            <a
              href="mailto:ndgallogho@gmail.com"
              class="mt-5 inline-flex items-center gap-2 h-11 px-5 rounded-full bg-gray-100 text-sm font-extrabold text-gray-900 hover:bg-gray-200 active:scale-[0.97] transition-all"
            >
              ndgallogho@gmail.com
              <ArrowRight class="w-4 h-4" :stroke-width="3" />
            </a>
          </div>

          <div class="md:col-span-7 grid grid-cols-3 gap-6">
            <div>
              <h3 class="text-sm font-black text-gray-900 mb-3">Produit</h3>
              <ul class="space-y-2 text-sm font-semibold">
                <li><a href="#features" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">Fonctionnalités</a></li>
                <li><a href="#steps" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">Comment ça marche</a></li>
                <li><a href="#pricing" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">Tarifs</a></li>
              </ul>
            </div>
            <div>
              <h3 class="text-sm font-black text-gray-900 mb-3">Entreprise</h3>
              <ul class="space-y-2 text-sm font-semibold">
                <li><a href="/contact" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">Contact</a></li>
              </ul>
            </div>
            <div>
              <h3 class="text-sm font-black text-gray-900 mb-3">Légal</h3>
              <ul class="space-y-2 text-sm font-semibold">
                <li><a href="/legal/privacy" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">Confidentialité</a></li>
                <li><a href="/legal/cgu" class="text-gray-600 hover:text-gray-900 hover:underline decoration-[#FB6A00] decoration-2 underline-offset-4">CGU</a></li>
              </ul>
            </div>
          </div>
        </div>

        <p class="mt-12 pt-6 border-t border-gray-100 text-sm font-semibold text-gray-500">© 2025 Kula QR — Dakar, Sénégal</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { useSeo, useAutoScroll } from '~/composables/useSeo'
import { useStructuredData } from '~/composables/useStructuredData'
import {
  QrCode,
  ArrowRight,
  Zap,
  Users,
  Printer,
  BarChart3,
  Smartphone,
  Check,
  Clock,
  ShoppingBag
} from 'lucide-vue-next'

// Ce que dit le produit, et rien d'autre : tout ce qui est listé existe dans l'application
const chips = ['Aucune application', 'Tous les smartphones', 'Mise à jour instantanée']

const demoItems = [
  { name: 'Poulet braisé', price: '5 000 F' },
  { name: 'Jus de bissap', price: '3 500 F' }
]

const features = [
  { icon: QrCode, title: 'Un QR code par table', text: 'Chaque table a son code. Un scan et le menu s’ouvre, la table est déjà connue.' },
  { icon: Zap, title: 'Commandes en direct', text: 'La commande arrive chez le personnel dès qu’elle est envoyée, avec un son et un clignotement.' },
  { icon: Smartphone, title: 'Menu toujours à jour', text: 'Changez un prix, ajoutez un plat, masquez un produit épuisé : c’est visible tout de suite.' },
  { icon: Users, title: 'Espace du personnel', text: 'Chaque membre se connecte avec son PIN. Serveur, cuisine ou gérant voient la file qui les concerne.' },
  { icon: Printer, title: 'Tickets imprimables', text: 'Un ticket au format 80 mm, en police à chasse fixe, pour la cuisine ou le comptoir.' },
  { icon: BarChart3, title: 'Chiffres clairs', text: 'Ventes du jour, commandes, scans de vos QR codes : l’essentiel sur une seule carte.' }
]

const steps = [
  { title: 'Créez', text: 'Ajoutez vos catégories, vos produits et vos prix. Quelques minutes suffisent.' },
  { title: 'Générez', text: 'Créez vos tables et leurs QR codes personnalisés. Imprimez-les ou affichez-les.' },
  { title: 'Lancez', text: 'Vos clients scannent et commandent. Votre équipe reçoit tout en temps réel.' }
]

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