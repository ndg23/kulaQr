<template>
      <div class="bg-white rounded-[32px]  w-full  text-center">
        <!-- Header -->
        <div class="mb-1">
          <div class="text-[28px] font-bold text-gray-900 mb-1.5 tracking-tight">
            {{ restaurantName }}
          </div>
          <div class="text-[16px] text-black -500 font-black tracking-tight">
            {{Number.isNaN(Number(tableNumber)) ? '' : `N° ${tableNumber}`}}
          </div>
        </div>
        
        <!-- QR Section -->
        <div class="mx-auto mb-2">
          <div class=" mx-auto w-fit p-3 rounded-s3xl- border-s2-- ---border-orange-200">
            <div class="bg-white inline-block rounded-3xl p-1">
              <!-- QR Code dynamique -->
              <img
                v-if="qrCodeImage"
                :src="qrCodeImage"
                alt="QR Code Menu"
                class="block w-[300px] h-[300px] object-contain"
              />
              <div v-else class="w-[280px] h-[280px] flex items-center justify-center">
                <div class="text-center">
                  <div class="w-16 h-16 bg-gray-100 rounded-xl flex items-center justify-center mb-4">
                    <svg class="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M3 11h8V3H3v8zm2-6h4v4H5V5zm8-2v8h8V3h-8zm6 6h-4V5h4v4zM3 21h8v-8H3v8zm2-6h4v4H5v-4zm13-2h-2v2h2v-2zm-4 0h-2v2h2v-2zm-4 0h-2v2h2v-2zm-4 0H5v2h2v-2zm8-4h-2v2h2v-2zm-4 0h-2v2h2v-2zm-4 0H5v2h2v-2z"/>
              </svg>
                  </div>
                  <p class="text-sm text-gray-500">Génération...</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Scan Text -->
        <h3 class="text-orange-500 text-[22px] font-semibold mb-2 track-ing-tight">
          Scannez pour commander
        </h3>
        <h4 class="text-gray-500 text-[15px] leading-relaxed font-normal tracki-ng-tight mb-8">
          Pointez votre caméra vers le QR code
        </h4>
        
        <!-- Features -->
        <!-- <div class="flex justify-center gap-6 mb-8">
          <div class="flex items-center gap-2 text-gray-500 text-[13px]">
            <div class="w-5 h-5 bg-orange-500 rounded-full flex items-center justify-center text-white text-xs">
              ✓
            </div>
            <span>Rapide</span>
          </div>
          <div class="flex items-center gap-2 text-gray-500 text-[13px]">
            <div class="w-5 h-5 bg-orange-500 rounded-full flex items-center justify-center text-white text-xs">
              ✓
            </div>
            <span>Sans contact</span>
          </div>
        </div> -->
        
        <!-- Divider -->
        <div class="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent mb-6"></div>
        
        <!-- Footer -->
        <div class="flex items-center justify-center gap-1.5 text-[13px] text-gray-500 font-normal">
          <span>Propulsé par</span>
          <span class="font-bold text-gray-900">KulaQR</span>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, watch } from 'vue'
  import QRCode from 'qrcode'
  
  const props = defineProps({
    restaurantName: {
      type: String,
      default: 'Menu'
    },
    menuLink: {
      type: String,
      default: ''
    },
    restaurantId: {
      type: String,
      default: ''
    },
    tableNumber: {
      type: [String, Number],
      default: ''
    }
  })
  
  // État du QR code
  const qrCodeImage = ref('')
const isGenerating = ref(false)

const roundImageCorners = (dataUrl, radius = 40) => {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      
      canvas.width = img.width
      canvas.height = img.height
      
      // Créer un chemin avec coins arrondis
      ctx.beginPath()
      ctx.moveTo(radius, 0)
      ctx.lineTo(canvas.width - radius, 0)
      ctx.quadraticCurveTo(canvas.width, 0, canvas.width, radius)
      ctx.lineTo(canvas.width, canvas.height - radius)
      ctx.quadraticCurveTo(canvas.width, canvas.height, canvas.width - radius, canvas.height)
      ctx.lineTo(radius, canvas.height)
      ctx.quadraticCurveTo(0, canvas.height, 0, canvas.height - radius)
      ctx.lineTo(0, radius)
      ctx.quadraticCurveTo(0, 0, radius, 0)
      ctx.closePath()
      ctx.clip()
      
      // Dessiner l'image
      ctx.drawImage(img, 0, 0)
      
      resolve(canvas.toDataURL('image/png'))
    }
    img.src = dataUrl
  })
}  
// Générer le QR code avec tracking
const generateQrCode = async () => {
  if (!props.menuLink) return

  isGenerating.value = true
  try {
    // Ajouter le paramètre de tracking à l'URL
    const trackingUrl = new URL(props.menuLink)
    trackingUrl.searchParams.set('scan', 'true')
    
    const qrCodeDataUrl = await QRCode.toDataURL(trackingUrl.toString(), {
      width: 512,
      margin: 2,
      color: {
        dark: '#FFFFFF',
        light: '#f91919'
      },
      errorCorrectionLevel: 'M'
    })

    // Arrondir les coins de l'image QR code
    qrCodeImage.value = await roundImageCorners(qrCodeDataUrl, 40)
    
  } catch (err) {
    console.error('QR code generation error:', err)
  } finally {
    isGenerating.value = false
  }
}
  
  // Exposer l'image du QR code pour le téléchargement
  defineExpose({
    qrCodeImage,
    generateQrCode
  })
  
  // Générer le QR code au montage et quand le lien change
  onMounted(() => {
    generateQrCode()
  })
  
  watch(() => props.menuLink, () => {
    generateQrCode()
  })
  </script>
  
  <style scoped>
  /* Custom styles for the gradient border effect */
  .before\:content-\[\'\'\]::before {
    content: '';
  }
  
  /* Ensure proper masking for the gradient border */
  [class*="before:"]:before {
    mask-composite: exclude;
    -webkit-mask-composite: xor;
    -webkit-mask: 
      linear-gradient(#fff 0 0) content-box, 
      linear-gradient(#fff 0 0);
    mask: 
      linear-gradient(#fff 0 0) content-box, 
      linear-gradient(#fff 0 0);
  }
  
  /* Optimisations pour l'impression */
  @media print {
    .bg-gradient-to-b {
      background: white !important;
    }
  }
  
  /* Animation pour le QR code */
  img {
    transition: opacity 0.3s ease;
  }
  
  img:hover {
    opacity: 0.9;
  }
  </style>