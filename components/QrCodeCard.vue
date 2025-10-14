<template>
      <div class="bg-white rounded-[32px] px-10 py-12 pb-15 max-w-[460px] w-full  text-center">
        <!-- Header -->
        <div class="mb-10">
          <div class="text-[28px] font-semibold text-gray-900 mb-1.5 tracking-tight">
            {{ restaurantName }}
          </div>
          <div class="text-[15px] text-gray-500 font-normal tracking-tight">
            Menu
          </div>
        </div>
        
        <!-- QR Section -->
        <div class="mx-auto mb-9">
          <div class=" mx-auto w-fit p-3 rounded-3xl border-2 border-orange-200">
            <div class="bg-white inline-block rounded-xl p-1">
              <!-- QR Code dynamique -->
              <img 
                v-if="qrCodeImage" 
                :src="qrCodeImage" 
                alt="QR Code Menu"
                class="block w-[280px] h-[280px]"
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
        <div class="text-orange-500 text-[22px] font-semibold mb-2 tracking-tight">
          Scannez pour voir le menu
        </div>
        <div class="text-gray-500 text-[15px] leading-relaxed font-normal tracking-tight mb-8">
          Pointez votre caméra vers le QR code
        </div>
        
        <!-- Features -->
        <div class="flex justify-center gap-6 mb-8">
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
        </div>
        
        <!-- Divider -->
        <div class="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent mb-6"></div>
        
        <!-- Footer -->
        <div class="flex items-center justify-center gap-1.5 text-[13px] text-gray-500 font-normal">
          <div class="w-1.5 h-1.5 bg-orange-500 rounded-full"></div>
          <span>Par Kula Qr</span>
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
    }
  })
  
  // État du QR code
  const qrCodeImage = ref('')
  const isGenerating = ref(false)
  
  // Générer le QR code
  const generateQrCode = async () => {
    if (!props.menuLink) return
    
    isGenerating.value = true
    try {
      const qrCodeDataUrl = await QRCode.toDataURL(props.menuLink, {
        width: 512,
        margin: 2,
        color: {
          dark: '#1d1d1f',
          light: '#FFFFFF'
        },
        errorCorrectionLevel: 'M'
      })
      
      qrCodeImage.value = qrCodeDataUrl
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
    
    .shadow-\[0_8px_32px_rgba\(0,0,0,0\.08\)\] {
      box-shadow: none !important;
    }
    
    .shadow-\[0_4px_24px_rgba\(255,107,53,0\.12\),0_0_0_1px_rgba\(255,107,53,0\.08\)\] {
      box-shadow: 0 0 0 1px #ff6b35 !important;
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