<template>
  <div>
    <PageHeader title="Partage" description="Partagez votre menu digital avec vos clients via des liens ou QR codes personnalisés." />

    <main>
      <!-- Lien principal -->
      <div class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden mb-8">
        <div class="p-6">
          <h2 class="text-xl font-extrabold text-gray-900 mb-1">Lien principal</h2>
          <p class="text-gray-500 mb-6">Le lien direct vers votre menu digital</p>
          
          <div class="flex items-center gap-4">
            <div class="flex-1 relative">
              <input
                ref="linkInput"
                type="text"
                :value="menuLink"
                readonly
                class="w-full h-12 pl-10 pr-24 rounded-full bg-gray-50 border border-gray-200 text-gray-900"
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
              class="h-12 px-6 bg-gray-900 text-white rounded-full font-bold hover:bg-gray-800 active:scale-95 transition-all flex items-center gap-2"
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
        <div class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-extrabold text-gray-900 mb-1">QR Code Principal</h3>
            <p class="text-gray-500 mb-6">Code QR vers votre menu complet</p>
            
            <div class="bg-white rounded-3xl border border-gray-200 p-6 mb-6">
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
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('main', 'svg')"
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('main')"
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>

        <!-- QR Code par Table -->
        <div class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-extrabold text-gray-900 mb-1">QR Code par Table</h3>
            <p class="text-gray-500 mb-4">Générez des QR codes uniques pour chaque table</p>
            
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Numéro de table</label>
              <input
                v-model="tableNumber"
                type="number"
                min="1"
                class="w-full h-12 px-5 rounded-full bg-gray-50 border border-gray-200 text-gray-900"
                placeholder="Ex: 1"
              />
            </div>

            <div v-if="tableNumber" class="bg-white rounded-3xl border border-gray-200 p-6 mb-6">
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
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('table', 'svg')"
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('table')"
                class="flex-1 h-12 bg-gray-100 hover:bg-gray-200 text-gray-900 rounded-full font-bold transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>

        <!-- Personnalisation -->
        <div class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden">
          <div class="p-6">
            <h3 class="text-lg font-extrabold text-gray-900 mb-1">Personnalisation</h3>
            <p class="text-gray-500 mb-6">Personnalisez l'apparence de vos QR codes</p>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Style des points</label>
                <select v-model="qrStyle" class="w-full h-12 px-5 rounded-full bg-gray-50 border border-gray-200">
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
                  class="w-full h-12 px-5 rounded-full bg-gray-50 border border-gray-200"
                />
              </div>

              <button
                @click="applyStyle"
                class="w-full h-12 bg-gray-900 text-white rounded-full font-bold hover:bg-gray-800 active:scale-95 transition-all flex items-center justify-center gap-2"
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
  return `${menuLink.value}?q=${table}`
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
