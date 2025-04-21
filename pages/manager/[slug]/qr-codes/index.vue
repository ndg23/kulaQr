<template>
  <div class="max-w-3xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">QR Code du menu</h1>
      <p class="mt-1 text-sm text-gray-500">Affichez et partagez le QR code de votre menu digital</p>
    </div>

    <!-- QR Code Card -->
    <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
      <div class="p-8">
        <!-- QR Code Display -->
        <div class="max-w-xs mx-auto">
          <div class="aspect-square w-full bg-white p-4 rounded-2xl border-2 border-gray-100">
            <QRCodeVue3
              v-if="menuUrl"
              :value="menuUrl"
              :size="250"
              level="M"
              class="mx-auto"
            />
          </div>
          
          <div class="mt-6 text-center">
            <p class="text-sm text-gray-500 mb-2">Scannez pour accéder au menu</p>
            <p v-if="menuUrl" class="text-xs text-gray-400 break-all">{{ menuUrl }}</p>
          </div>
        </div>

        <!-- Actions -->
        <div class="mt-8 flex items-center justify-center space-x-4">
          <button 
            @click="downloadQR"
            class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
          >
            <Download class="w-4 h-4 mr-1.5" />
            Télécharger
          </button>
          <button 
            @click="printQR"
            class="inline-flex items-center px-4 py-2 bg-white text-gray-700 rounded-full text-sm font-medium border border-gray-200 hover:bg-gray-50 transition-colors"
          >
            <Printer class="w-4 h-4 mr-1.5" />
            Imprimer
          </button>
        </div>
      </div>
    </div>

    <!-- Tips -->
    <div class="mt-8 grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="bg-blue-50 rounded-xl p-4">
        <div class="flex items-start">
          <Info class="w-5 h-5 text-blue-500 mt-0.5" />
          <div class="ml-3">
            <h3 class="text-sm font-medium text-blue-900">Conseil d'utilisation</h3>
            <p class="mt-1 text-sm text-blue-700">
              Imprimez le QR code et placez-le sur vos tables ou à l'entrée de votre établissement.
            </p>
          </div>
        </div>
      </div>
      <div class="bg-green-50 rounded-xl p-4">
        <div class="flex items-start">
          <Smartphone class="w-5 h-5 text-green-500 mt-0.5" />
          <div class="ml-3">
            <h3 class="text-sm font-medium text-green-900">Accès facile</h3>
            <p class="mt-1 text-sm text-green-700">
              Vos clients peuvent scanner le code avec leur smartphone pour accéder directement au menu.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import QRCodeVue3 from 'qrcode-vue3'
import {
  Download, Printer, Info, Smartphone
} from 'lucide-vue-next'
import { useToast } from '~/composables/useToast'

const toast = useToast()
const route = useRoute()
const slug = route.params.slug

// Computed
const menuUrl = computed(() => {
  if (process.client) {
    return `${window.location.origin}/menu/${slug}`
  }
  return ''
})

// Methods
const downloadQR = () => {
  const canvas = document.querySelector('canvas')
  if (canvas) {
    const link = document.createElement('a')
    link.download = `menu-qr-code.png`
    link.href = canvas.toDataURL('image/png')
    link.click()
    toast.success('QR Code téléchargé', 'Le QR code a été téléchargé')
  }
}

const printQR = () => {
  const printWindow = window.open('', '', 'width=800,height=600')
  if (printWindow) {
    const canvas = document.querySelector('canvas')
    if (canvas) {
      printWindow.document.write(`
        <html>
          <head>
            <title>QR Code Menu</title>
            <style>
              body { 
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                height: 100vh;
                margin: 0;
              }
              img { max-width: 300px; }
              p { 
                font-family: system-ui, sans-serif;
                text-align: center;
                color: #666;
              }
            </style>
          </head>
          <body>
            <img src="${canvas.toDataURL()}" />
            <p>Scannez pour accéder au menu</p>
            <p style="font-size: 12px;">${menuUrl.value}</p>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.focus()
      printWindow.print()
      printWindow.close()
      toast.success('Impression lancée', 'Le QR code est en cours d\'impression')
    }
  }
}

definePageMeta({
  layout: 'manager'
})
</script> 