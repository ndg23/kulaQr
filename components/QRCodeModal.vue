<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 w-full max-w-md">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold">QR Code du Menu</h2>
        <button @click="$emit('close')" class="text-gray-500">
          <span class="sr-only">Fermer</span>
          ✕
        </button>
      </div>

      <div class="text-center">
        <div class="bg-white p-4 inline-block rounded-lg shadow-md">
          <img :src="qrCodeUrl" alt="QR Code" class="w-64 h-64" />
        </div>
        
        <div class="mt-4 space-y-3">
          <button 
            @click="downloadQR"
            class="w-full bg-blue-500 text-white px-4 py-2 rounded-md"
          >
            Télécharger
          </button>
          <button 
            @click="printQR"
            class="w-full border border-gray-300 px-4 py-2 rounded-md"
          >
            Imprimer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import QRCode from 'qrcode'

const props = defineProps<{
  restaurantId: string
}>()

const emit = defineEmits<{
  (e: 'close'): void
}>()

const qrCodeUrl = ref('')

onMounted(async () => {
  const menuUrl = `${window.location.origin}/menu/${props.restaurantId}`
  qrCodeUrl.value = await QRCode.toDataURL(menuUrl, {
    width: 512,
    margin: 2,
    color: {
      dark: '#000000',
      light: '#ffffff'
    }
  })
})

const downloadQR = () => {
  const link = document.createElement('a')
  link.download = `menu-qr-${props.restaurantId}.png`
  link.href = qrCodeUrl.value
  link.click()
}

const printQR = () => {
  const printWindow = window.open('', '_blank')
  if (printWindow) {
    printWindow.document.write(`
      <html>
        <head>
          <title>Menu QR Code</title>
          <style>
            body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            img { max-width: 100%; height: auto; }
          </style>
        </head>
        <body>
          <img src="${qrCodeUrl.value}" onload="window.print();window.close()" />
        </body>
      </html>
    `)
  }
}
</script> 