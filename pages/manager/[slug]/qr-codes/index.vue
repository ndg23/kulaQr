<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">QR Codes</h1>
      <p class="mt-1 text-sm text-gray-500">Générez et personnalisez vos QR codes pour chaque table</p>
    </div>

    <!-- QR Code Generator -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Preview Panel -->
      <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Aperçu</h2>
        </div>
        <div class="p-6">
          <div class="aspect-square max-w-sm mx-auto bg-white rounded-xl shadow-sm border-2 border-gray-100 p-8">
            <div class="flex flex-col items-center">
              <span class="text-2xl font-bold text-gray-900">{{ establishment?.name }}</span>
              <span class="mt-2 text-sm text-gray-500">Table {{ selectedTable }}</span>
              
              <div class="mt-8 w-full max-w-[240px]" ref="qrCodeRef">
                <QRCodeVue3
                  :value="qrCodeUrl"
                  :size="240"
                  :margin="0"
                  :dotsOptions="{ type: 'dots', color: qrCodeColor }"
                  :backgroundOptions="{ color: '#FFFFFF' }"
                  :cornersSquareOptions="{ type: 'dot', color: qrCodeColor }"
                  :cornersDotOptions="{ type: 'dot', color: qrCodeColor }"
                />
              </div>

              <div class="mt-8 text-center">
                <p class="text-sm text-gray-500">Scannez pour accéder au menu</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Settings Panel -->
      <div class="space-y-6">
        <!-- Table Number -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900">Numéro de table</h3>
          </div>
          <div class="p-6">
            <div class="relative group">
              <input
                v-model="selectedTable"
                type="number"
                min="1"
                required
                class="peer w-full h-16 px-5 pt-4 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
                placeholder=" "
              />
              <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
                Numéro de table
              </label>
            </div>
          </div>
        </div>

        <!-- Color Picker -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900">Couleur</h3>
          </div>
          <div class="p-6">
            <div class="grid grid-cols-6 gap-3">
              <button
                v-for="color in colors"
                :key="color"
                @click="qrCodeColor = color"
                class="aspect-square rounded-xl transition-transform hover:scale-110 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                :class="[
                  qrCodeColor === color ? 'ring-2 ring-offset-2 ring-blue-500' : ''
                ]"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
        </div>

        <!-- Download Options -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900">Télécharger</h3>
          </div>
          <div class="p-6 space-y-4">
            <button
              @click="downloadQR('png')"
              class="w-full flex items-center justify-center px-4 py-3 rounded-xl bg-gray-50 border-2 border-gray-100 text-gray-700 font-medium hover:bg-gray-100 transition-colors"
            >
              <Download class="w-5 h-5 mr-2" />
              PNG
            </button>
            <button
              @click="downloadQR('svg')"
              class="w-full flex items-center justify-center px-4 py-3 rounded-xl bg-gray-50 border-2 border-gray-100 text-gray-700 font-medium hover:bg-gray-100 transition-colors"
            >
              <Download class="w-5 h-5 mr-2" />
              SVG
            </button>
            <button
              @click="downloadQR('pdf')"
              class="w-full flex items-center justify-center px-4 py-3 rounded-xl bg-gray-50 border-2 border-gray-100 text-gray-700 font-medium hover:bg-gray-100 transition-colors"
            >
              <Download class="w-5 h-5 mr-2" />
              PDF
            </button>
          </div>
        </div>

        <!-- Print Button -->
        <button
          @click="printQR"
          class="w-full flex items-center justify-center px-4 py-3 rounded-xl bg-blue-500 text-white font-medium hover:bg-blue-600 transition-colors"
        >
          <Printer class="w-5 h-5 mr-2" />
          Imprimer
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import QRCodeVue3 from 'qrcode-vue3'
import { Download, Printer } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'
import html2canvas from 'html2canvas'
import jsPDF from 'jspdf'

definePageMeta({
  layout: 'manager'
})

const route = useRoute()
const slug = route.params.slug as string
const { client: supabase } = useSupabaseWrapper()
const toast = useToast()

const establishment = ref<any>(null)
const selectedTable = ref(1)
const qrCodeRef = ref<HTMLElement>()
const qrCodeColor = ref('#000000')

const colors = [
  '#000000', // Black
  '#2563EB', // Blue
  '#059669', // Green
  '#DC2626', // Red
  '#7C3AED', // Purple
  '#EA580C', // Orange
]

const qrCodeUrl = computed(() => {
  return `${window.location.origin}/menu/${slug}?table=${selectedTable.value}`
})

// Load establishment data
const loadEstablishment = async () => {
  const { data, error } = await supabase
    .from('establishments')
    .select()
    .eq('id', slug)
    .single()

  if (error) {
    toast.error('Erreur', 'Impossible de charger les données')
    return
  }

  establishment.value = data
}

// Download functions
const downloadQR = async (format: 'png' | 'svg' | 'pdf') => {
  if (!qrCodeRef.value) return

  try {
    const canvas = await html2canvas(qrCodeRef.value)
    
    switch (format) {
      case 'png':
        const pngUrl = canvas.toDataURL('image/png')
        downloadFile(pngUrl, `qr-code-table-${selectedTable.value}.png`)
        break
      
      case 'pdf':
        const pdf = new jsPDF()
        const imgData = canvas.toDataURL('image/png')
        pdf.addImage(imgData, 'PNG', 10, 10, 190, 190)
        pdf.save(`qr-code-table-${selectedTable.value}.pdf`)
        break
      
      case 'svg':
        // Implement SVG download
        break
    }

    toast.success('Succès', 'QR Code téléchargé')
  } catch (error) {
    toast.error('Erreur', 'Impossible de télécharger le QR Code')
  }
}

const downloadFile = (url: string, filename: string) => {
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const printQR = () => {
  window.print()
}

onMounted(loadEstablishment)
</script>

<style>
@media print {
  body * {
    visibility: hidden;
  }
  #qr-code-container, #qr-code-container * {
    visibility: visible;
  }
  #qr-code-container {
    position: absolute;
    left: 0;
    top: 0;
  }
}
</style> 