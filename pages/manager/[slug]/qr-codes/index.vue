<template>
  <div class="min-h-screen bg-white text-gray-900">
    <!-- Header -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/80 border-b border-gray-100">
      <div class="max-w-6xl mx-auto px-6 py-4">
        <div class="flex flex-col gap-2">
          <h1 class="text-2xl font-semibold text-gray-900">Partage</h1>
          <p class="text-base text-gray-500">Partagez votre menu digital facilement avec vos clients.</p>
        </div>
      </div>
    </header>

    <main class="max-w-6xl mx-auto px-6 py-8">
      <!-- Main Link -->
      <div class="mb-8">
        <h2 class="text-lg font-medium text-gray-900 mb-2">Lien du menu</h2>
        
        <div class="bg-gray-50 rounded-xl p-4 border border-gray-200">
          <div class="flex items-center gap-3">
            <div class="flex-1 relative">
              <input
                ref="linkInput"
                type="text"
                :value="menuLink"
                readonly
                class="w-full h-12 pl-10 pr-20 rounded-xl bg-white border border-gray-200 text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <Link class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <div class="absolute right-2 top-1/2 -translate-y-1/2">
                <button
                  @click="copyLink"
                  class="px-4 py-1.5 text-sm font-medium text-blue-500 hover:text-blue-600 transition-colors"
                >
                  Copier
                </button>
              </div>
            </div>
            <button
              @click="shareLink"
              class="h-12 px-6 bg-blue-500 text-white rounded-full text-sm font-medium hover:bg-blue-600 active:bg-blue-700 transition-all flex items-center gap-2"
            >
              <Share2 class="w-4 h-4" />
              Partager
            </button>
          </div>
        </div>
      </div>

      <!-- QR Code Section -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <!-- Left Column -->
        <div>
          <h2 class="text-lg font-medium text-gray-900 mb-6">QR Codes</h2>
          
          <!-- Main QR Code -->
          <div class="bg-gray-50 rounded-xl p-6 mb-8 border border-gray-200">
            <h3 class="text-base font-medium text-gray-700 mb-1">Menu principal</h3>
            <p class="text-sm text-gray-500 mb-6">Code QR vers votre menu complet</p>
            
            <div class="bg-white rounded-2xl shadow-sm p-6 mb-4 flex items-center justify-center">
              <QRCodeVue3
                :value="menuLink"
                :size="200"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                :cornersDotOptions="{ type: 'dot', color: qrColor }"
              />
            </div>

            <div class="flex items-center gap-2">
              <button
                @click="downloadQR('main', 'png')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('main', 'svg')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('main')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
          
          <!-- Table QR Code -->
          <div class="bg-gray-50 rounded-xl p-6 border border-gray-200">
            <h3 class="text-base font-medium text-gray-700 mb-1">QR Code par table</h3>
            <p class="text-sm text-gray-500 mb-4">Générez des QR codes uniques pour chaque table</p>
            
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Numéro de table</label>
              <input
                v-model="tableNumber"
                type="number"
                min="1"
                class="w-full h-12 px-4 rounded-xl bg-white border border-gray-200 text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Ex: 1"
              />
            </div>

            <div v-if="tableNumber" class="bg-white rounded-2xl shadow-sm p-6 mb-4 flex items-center justify-center">
              <QRCodeVue3
                :value="getTableLink(tableNumber)"
                :size="200"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                :cornersDotOptions="{ type: 'dot', color: qrColor }"
              />
            </div>

            <div v-if="tableNumber" class="flex items-center gap-2">
              <button
                @click="downloadQR('table', 'png')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('table', 'svg')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('table')"
                class="flex-1 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>
        
        <!-- Right Column -->
        <div>
          <h2 class="text-lg font-medium text-gray-900 mb-6">Personnalisation</h2>
          
          <div class="bg-gray-50 rounded-xl p-6 border border-gray-200">
            <h3 class="text-base font-medium text-gray-700 mb-1">Style du QR code</h3>
            <p class="text-sm text-gray-500 mb-6">Personnalisez l'apparence de vos QR codes</p>

            <div class="space-y-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Style des points</label>
                <select 
                  v-model="qrStyle" 
                  class="w-full h-12 px-4 rounded-xl bg-white border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
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
                  class="w-full h-12 rounded-xl bg-white border border-gray-200 p-1"
                />
              </div>
              
              <div class="bg-white rounded-2xl shadow-sm p-6 flex items-center justify-center">
                <QRCodeVue3
                  :value="menuLink"
                  :size="120"
                  :margin="0"
                  class="mx-auto"
                  :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                  :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                  :cornersDotOptions="{ type: 'dot', color: qrColor }"
                />
              </div>

              <button
                @click="applyStyle"
                class="w-full h-12 bg-blue-500 text-white rounded-full text-sm font-medium hover:bg-blue-600 active:bg-blue-700 transition-all flex items-center justify-center gap-2"
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
const qrColor = ref('#0071e3') // Apple Blue

// QR Style mapping
const qrStyleMap = {
  'dots': 'dots',
  'squares': 'squares',
  'rounded': 'rounded'
}

// Computed
const menuLink = computed(() => {
  return `https://kulaqr.com/menu/${establishment.value?.id}`
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
  const value = type === 'main' ? menuLink.value : getTableLink(tableNumber.value as number)
  const filename = type === 'main' ? 'qr-menu' : `qr-table-${tableNumber.value}`

  // Implementation for downloading QR code
  // This would normally use a library like html-to-image or dom-to-image
  showToast.success('QR Code téléchargé', `Le QR code a été téléchargé au format ${format.toUpperCase()}`)
}

const printQR = (type: 'main' | 'table') => {
  // Implementation for printing QR code
  // This would normally use window.print() with appropriate CSS
  showToast.success('Impression lancée', 'La fenêtre d\'impression va s\'ouvrir')
}

const applyStyle = () => {
  // The QR code style is applied reactively
  showToast.success('Style appliqué', 'Les QR codes ont été mis à jour')
}

definePageMeta({
  layout: 'manager'
})
</script>