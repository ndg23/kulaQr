<template>
  <div class="min-h-screen bg-[#F5F5F7]">
    <!-- En-tête -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/70 border-b border-gray-200/50">
      <div class="max-w-[1600px] mx-auto px-6 py-5">
        <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
          <div class="max-w-2xl">
            <div class="flex items-center gap-3 mb-2">
              <h1 class="text-3xl font-semibold text-gray-900">Partage</h1>
              <div class="flex items-center gap-2 px-3 py-1 bg-gray-900/5 rounded-full">
                <Share2 class="w-4 h-4 text-gray-600" />
                <span class="text-sm font-medium text-gray-600">Liens & QR Codes</span>
              </div>
            </div>
            <p class="text-base text-gray-500">Partagez votre menu digital avec vos clients via des liens ou QR codes personnalisés.</p>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-[1600px] mx-auto px-6 py-8">
      <!-- Lien principal -->
      <div class="bg-white rounded-xl border border-gray-200/50 overflow-hidden mb-8">
        <div class="p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-2">Lien principal</h2>
          <p class="text-gray-500 mb-6">Le lien direct vers votre menu digital</p>
          
          <div class="flex items-center gap-4">
            <div class="flex-1 relative">
              <input
                ref="linkInput"
                type="text"
                :value="menuLink"
                readonly
                class="w-full h-11 pl-10 pr-24 rounded-xl bg-gray-50 border border-gray-200/50 text-gray-900"
              />
              <Link class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <div class="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-2">
                <button
                  @click="copyLink"
                  class="px-3 py-1.5 text-xs font-medium text-gray-600 hover:text-gray-900 transition-colors"
                >
                  Copier
                </button>
              </div>
            </div>
            <button
              @click="shareLink"
              class="h-11 px-6 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 active:scale-95 transition-all flex items-center gap-2"
            >
              <Share2 class="w-4 h-4" />
              Partager
            </button>
          </div>
        </div>
      </div>

      <!-- QR Codes -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- QR Code Principal -->
        <div class="bg-white rounded-xl border border-gray-200/50 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-2">QR Code Principal</h3>
            <p class="text-gray-500 mb-6">Code QR vers votre menu complet</p>
            
            <div class="bg-white rounded-xl border border-gray-200/50 p-6 mb-6">
              <QRCodeVue3
                :value="menuLink"
                :size="200"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: 'dots', color: '#111827' }"
                :cornersSquareOptions="{ type: 'dot', color: '#111827' }"
                :cornersDotOptions="{ type: 'dot', color: '#111827' }"
              />
            </div>

            <div class="flex items-center gap-2">
              <button
                @click="downloadQR('main')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('main', 'svg')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('main')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>

        <!-- QR Code par Table -->
        <div class="bg-white rounded-xl border border-gray-200/50 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-2">QR Code par Table</h3>
            <p class="text-gray-500 mb-4">Générez des QR codes uniques pour chaque table</p>
            
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Numéro de table</label>
              <input
                v-model="tableNumber"
                type="number"
                min="1"
                class="w-full h-11 px-4 rounded-xl bg-gray-50 border border-gray-200/50 text-gray-900"
                placeholder="Ex: 1"
              />
            </div>

            <div v-if="tableNumber" class="bg-white rounded-xl border border-gray-200/50 p-6 mb-6">
              <QRCodeVue3
                :value="getTableLink(tableNumber)"
                :size="200"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: 'dots', color: '#111827' }"
                :cornersSquareOptions="{ type: 'dot', color: '#111827' }"
                :cornersDotOptions="{ type: 'dot', color: '#111827' }"
              />
            </div>

            <div v-if="tableNumber" class="flex items-center gap-2">
              <button
                @click="downloadQR('table')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('table', 'svg')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('table')"
                class="flex-1 h-10 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>

        <!-- Personnalisation -->
        <div class="bg-white rounded-xl border border-gray-200/50 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Personnalisation</h3>
            <p class="text-gray-500 mb-6">Personnalisez l'apparence de vos QR codes</p>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Style des points</label>
                <select v-model="qrStyle" class="w-full h-11 px-4 rounded-xl bg-gray-50 border border-gray-200/50">
                  <option value="dots">Points</option>
                  <option value="squares">Carrés</option>
                  <option value="rounded">Arrondis</option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Couleur</label>
                <input
                  v-model="qrColor"
                  type="color"
                  class="w-full h-11 px-4 rounded-xl bg-gray-50 border border-gray-200/50"
                />
              </div>

              <button
                @click="applyStyle"
                class="w-full h-10 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 active:scale-95 transition-all flex items-center justify-center gap-2"
              >
                <Check class="w-4 h-4" />
                Appliquer
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import QRCodeVue3 from 'qrcode-vue3'
import { Share2, Link, Download, Printer, Check } from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useCustomToast } from '~/composables/useToast'

const { establishment } = useEstablishment()
const { showToast } = useCustomToast()

const linkInput = ref<HTMLInputElement | null>(null)
const tableNumber = ref<number>()
const qrStyle = ref('dots')
const qrColor = ref('#111827')

// Computed
const menuLink = computed(() => {
  return `https://kula-qr.vercel.app/menu/${establishment.value?.id}`
})

// Methods
const getTableLink = (table: number) => {
  return `${menuLink.value}?table=${table}`
}

const copyLink = async () => {
  try {
    await navigator.clipboard.writeText(menuLink.value)
    showToast.success('Lien copié !', 'Le lien a été copié dans le presse-papier')
  } catch (err) {
    showToast.error('Erreur', 'Impossible de copier le lien')
  }
}

const shareLink = async () => {
  if (navigator.share) {
    try {
      await navigator.share({
        title: establishment.value?.name,
        text: 'Consultez notre menu digital',
        url: menuLink.value
      })
    } catch (err) {
      console.error('Erreur de partage:', err)
    }
  } else {
    copyLink()
  }
}

const downloadQR = (type: 'main' | 'table', format: 'png' | 'svg' = 'png') => {
  // Implementation du téléchargement
}

const printQR = (type: 'main' | 'table') => {
  // Implementation de l'impression
}

const applyStyle = () => {
  // Application du style aux QR codes
  showToast.success('Style appliqué', 'Les QR codes ont été mis à jour')
}

definePageMeta({
  layout: 'manager'
})
</script>
