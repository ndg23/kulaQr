<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">QR Codes</h1>
      <p class="text-lg text-gray-600">Personnalisez et imprimez les QR codes de vos établissements</p>
    </div>

    <!-- QR Code Generator -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Left Panel: Settings -->
      <div class="lg:col-span-1">
        <div class="bg-white rounded-[2rem] border border-gray-100 p-6 sticky top-8">
          <h2 class="text-xl font-semibold mb-6">Paramètres</h2>
          
          <!-- Restaurant Selection -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Établissement</label>
            <select 
              v-model="selectedRestaurant" 
              class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200"
              @change="generateQrCode"
            >
              <option value="">Sélectionnez un établissement</option>
              <option 
                v-for="restaurant in restaurants" 
                :key="restaurant.id" 
                :value="restaurant.id"
              >
                {{ restaurant.name }}
              </option>
            </select>
          </div>
          
          <!-- QR Code Size -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Taille du QR code</label>
            <div class="flex items-center">
              <input 
                v-model="qrSize" 
                type="range" 
                min="100" 
                max="500" 
                step="10" 
                class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                @input="generateQrCode"
              />
              <span class="ml-3 text-sm text-gray-600">{{ qrSize }}px</span>
            </div>
          </div>
          
          <!-- QR Code Colors -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Couleur du QR code</label>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs text-gray-500 mb-1">Couleur principale</label>
                <div class="flex items-center">
                  <input 
                    v-model="qrColor" 
                    type="color" 
                    class="w-10 h-10 rounded border border-gray-200 cursor-pointer"
                    @change="generateQrCode"
                  />
                  <span class="ml-2 text-sm text-gray-600">{{ qrColor }}</span>
                </div>
              </div>
              <div>
                <label class="block text-xs text-gray-500 mb-1">Arrière-plan</label>
                <div class="flex items-center">
                  <input 
                    v-model="qrBackground" 
                    type="color" 
                    class="w-10 h-10 rounded border border-gray-200 cursor-pointer"
                    @change="generateQrCode"
                  />
                  <span class="ml-2 text-sm text-gray-600">{{ qrBackground }}</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- QR Code Style -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Style du QR code</label>
            <div class="grid grid-cols-3 gap-2">
              <button 
                v-for="style in qrStyles" 
                :key="style.name"
                @click="qrStyle = style.value; generateQrCode()"
                class="p-2 border rounded-lg transition-all"
                :class="qrStyle === style.value ? 'border-blue-500 bg-blue-50' : 'border-gray-200 hover:bg-gray-50'"
              >
                <img :src="style.preview" :alt="style.name" class="w-full h-auto" />
                <span class="block text-xs text-center mt-1">{{ style.name }}</span>
              </button>
            </div>
          </div>
          
          <!-- Include Logo -->
          <div class="mb-6">
            <div class="flex items-center justify-between">
              <label class="text-sm font-medium text-gray-700">Inclure le logo</label>
              <label class="relative inline-flex items-center cursor-pointer">
                <input 
                  v-model="includeLogo" 
                  type="checkbox" 
                  class="sr-only peer"
                  @change="generateQrCode"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
              </label>
            </div>
            
            <div v-if="includeLogo" class="mt-3">
              <label class="block text-xs text-gray-500 mb-1">Logo personnalisé (optionnel)</label>
              <div class="flex items-center">
                <input 
                  type="file" 
                  accept="image/*" 
                  class="hidden" 
                  ref="logoInput"
                  @change="handleLogoUpload"
                />
                <button 
                  @click="$refs.logoInput.click()"
                  class="px-3 py-2 text-sm border border-gray-200 rounded-lg hover:bg-gray-50"
                >
                  <Upload class="w-4 h-4 inline-block mr-1" />
                  Choisir un logo
                </button>
                <button 
                  v-if="customLogo"
                  @click="resetLogo"
                  class="ml-2 p-2 text-red-500 hover:bg-red-50 rounded-lg"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
              <div v-if="customLogo" class="mt-2">
                <img :src="customLogo" alt="Logo" class="h-10 border rounded p-1" />
              </div>
            </div>
          </div>
          
          <!-- Custom Text -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">Texte personnalisé</label>
            <input 
              v-model="customText" 
              type="text" 
              placeholder="Scannez-moi pour voir le menu"
              class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200"
              @input="generateQrCode"
            />
          </div>
          
          <!-- Actions -->
          <div class="flex flex-col space-y-3">
            <button 
              @click="printQrCode"
              class="px-6 py-4 text-base font-semibold bg-blue-500 text-white rounded-2xl hover:bg-blue-600 transition-colors flex items-center justify-center"
              :disabled="!qrCodeUrl || loading"
            >
              <Printer v-if="!loading" class="w-5 h-5 mr-2" />
              <Loader2 v-else class="w-5 h-5 mr-2 animate-spin" />
              {{ loading ? 'Génération...' : 'Imprimer le QR code' }}
            </button>
            
            <button 
              @click="downloadQrCode"
              class="px-6 py-4 text-base font-semibold border border-gray-300 bg-white text-gray-700 rounded-2xl hover:bg-gray-50 transition-colors flex items-center justify-center"
              :disabled="!qrCodeUrl || loading"
            >
              <Download class="w-5 h-5 mr-2" />
              Télécharger
            </button>
          </div>
        </div>
      </div>
      
      <!-- Right Panel: Preview -->
      <div class="lg:col-span-2">
        <div class="bg-white rounded-[2rem] border border-gray-100 p-6 h-full">
          <h2 class="text-xl font-semibold mb-6">Aperçu</h2>
          
          <div v-if="!selectedRestaurant" class="flex flex-col items-center justify-center h-[500px] text-center">
            <QrCode class="w-16 h-16 text-gray-300 mb-4" />
            <p class="text-gray-500 max-w-md">
              Sélectionnez un établissement pour générer un QR code personnalisé
            </p>
          </div>
          
          <div v-else-if="loading" class="flex flex-col items-center justify-center h-[500px]">
            <Loader2 class="w-12 h-12 text-blue-500 animate-spin mb-4" />
            <p class="text-gray-500">Génération du QR code...</p>
          </div>
          
          <div v-else class="flex flex-col items-center">
            <div class="bg-white p-8 rounded-xl border border-gray-200 shadow-sm mb-6 qr-preview">
              <div class="text-center mb-4">
                <h3 class="text-xl font-bold text-gray-900">{{ getSelectedRestaurantName }}</h3>
                <p v-if="getSelectedRestaurantAddress" class="text-gray-500 mt-1">
                  {{ getSelectedRestaurantAddress }}
                </p>
              </div>
              
              <div class="bg-white p-4 rounded-lg inline-block mx-auto">
                <img 
                  v-if="qrCodeUrl" 
                  :src="qrCodeUrl" 
                  :alt="getSelectedRestaurantName" 
                  class="max-w-full h-auto"
                />
              </div>
              
              <p v-if="customText" class="text-center mt-4 text-gray-700">
                {{ customText }}
              </p>
            </div>
            
            <div class="w-full max-w-md">
              <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl mb-6">
                <div class="flex-1 truncate mr-4">
                  <p class="text-sm text-gray-500">URL du menu:</p>
                  <p class="text-sm font-medium text-gray-900 truncate">{{ menuUrl }}</p>
                </div>
                <button 
                  @click="copyToClipboard(menuUrl)"
                  class="p-2 text-blue-500 hover:bg-blue-50 rounded-lg"
                  title="Copier l'URL"
                >
                  <Clipboard class="w-5 h-5" />
                </button>
              </div>
              
              <div class="bg-blue-50 rounded-xl p-4">
                <h3 class="text-sm font-medium text-blue-800 mb-2 flex items-center">
                  <Info class="w-4 h-4 mr-1" />
                  Conseils d'utilisation
                </h3>
                <ul class="text-xs text-blue-700 space-y-1 list-disc pl-4">
                  <li>Imprimez le QR code sur du papier de qualité pour une meilleure lisibilité</li>
                  <li>Placez le QR code à un endroit visible et accessible pour vos clients</li>
                  <li>Testez le QR code avant de l'imprimer en grande quantité</li>
                  <li>Considérez l'ajout d'instructions simples à côté du QR code</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  QrCode, 
  Printer, 
  Download, 
  Clipboard, 
  Upload, 
  Trash2, 
  Info, 
  Loader2 
} from 'lucide-vue-next'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'
import QRCode from 'qrcode'

const supabase = useSupabaseClient()
const { showToast } = useCustomToast()

// State
const restaurants = ref([])
const selectedRestaurant = ref('')
const qrSize = ref(300)
const qrColor = ref('#000000')
const qrBackground = ref('#FFFFFF')
const qrStyle = ref('squares')
const includeLogo = ref(false)
const customLogo = ref(null)
const customText = ref('Scannez pour voir notre menu')
const qrCodeUrl = ref('')
const loading = ref(false)
const logoInput = ref(null)

// QR Code style options
const qrStyles = [
  { 
    name: 'Classique', 
    value: 'squares', 
    preview: '/img/qr-style-classic.png' 
  },
  { 
    name: 'Arrondi', 
    value: 'dots', 
    preview: '/img/qr-style-rounded.png' 
  },
  { 
    name: 'Élégant', 
    value: 'classy', 
    preview: '/img/qr-style-elegant.png' 
  }
]

// Computed
const getSelectedRestaurantName = computed(() => {
  const restaurant = restaurants.value.find(r => r.id === selectedRestaurant.value)
  return restaurant ? restaurant.name : ''
})

const getSelectedRestaurantAddress = computed(() => {
  const restaurant = restaurants.value.find(r => r.id === selectedRestaurant.value)
  return restaurant ? restaurant.address : ''
})

const menuUrl = computed(() => {
  if (!selectedRestaurant.value) return ''
  
  const restaurant = restaurants.value.find(r => r.id === selectedRestaurant.value)
  if (!restaurant) return ''
  
  // Use custom QR prefix if available, otherwise use slug
  const identifier = restaurant.qr_prefix || restaurant.slug
  return `${window.location.origin}/menu/${identifier}`
})

// Methods
const fetchRestaurants = async () => {
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name, slug, address, qr_prefix')
      .order('name')
    
    if (error) throw error
    
    restaurants.value = data || []
  } catch (err) {
    console.error('Error fetching restaurants:', err)
    showToast.error('Erreur lors du chargement des établissements', 'error')
  }
}

const generateQrCode = async () => {
  if (!selectedRestaurant.value) {
    qrCodeUrl.value = ''
    return
  }
  
  try {
    loading.value = true
    
    // QR Code options
    const options = {
      width: qrSize.value,
      margin: 1,
      color: {
        dark: qrColor.value,
        light: qrBackground.value
      }
    }
    
    // Add style options based on selected style
    if (qrStyle.value === 'dots') {
      options.dots = { type: 'dots', color: qrColor.value }
      options.corners = { type: 'dot', color: qrColor.value }
    } else if (qrStyle.value === 'classy') {
      options.dots = { type: 'classy', color: qrColor.value }
      options.corners = { type: 'classy', color: qrColor.value }
    }
    
    // Generate QR code
    const url = await QRCode.toDataURL(menuUrl.value, options)
    
    // If logo should be included, add it to the QR code
    if (includeLogo.value) {
      const logo = customLogo.value || '/img/logo-small.png'
      
      // Create canvas to combine QR code and logo
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      
      // Set canvas size
      canvas.width = qrSize.value
      canvas.height = qrSize.value
      
      // Draw QR code
      const qrImage = new Image()
      qrImage.src = url
      
      await new Promise((resolve) => {
        qrImage.onload = () => {
          ctx.drawImage(qrImage, 0, 0, canvas.width, canvas.height)
          resolve()
        }
      })
      
      // Draw logo in center
      const logoImage = new Image()
      logoImage.src = logo
      
      await new Promise((resolve) => {
        logoImage.onload = () => {
          // Calculate logo size (25% of QR code)
          const logoSize = qrSize.value * 0.25
          const logoX = (canvas.width - logoSize) / 2
          const logoY = (canvas.height - logoSize) / 2
          
          // Draw white background for logo
          ctx.fillStyle = 'white'
          ctx.fillRect(logoX - 5, logoY - 5, logoSize + 10, logoSize + 10)
          
          // Draw logo
          ctx.drawImage(logoImage, logoX, logoY, logoSize, logoSize)
          resolve()
        }
      })
      
      // Convert canvas to data URL
      qrCodeUrl.value = canvas.toDataURL('image/png')
    } else {
      qrCodeUrl.value = url
    }
  } catch (err) {
    console.error('Error generating QR code:', err)
    showToast.error('Erreur lors de la génération du QR code', 'error')
  } finally {
    loading.value = false
  }
}

const handleLogoUpload = (event) => {
  const file = event.target.files[0]
  if (!file) return
  
  if (!file.type.startsWith('image/')) {
    showToast.error('Veuillez sélectionner une image', 'error')
    return
  }
  
  const reader = new FileReader()
  reader.onload = (e) => {
    customLogo.value = e.target.result
    generateQrCode()
  }
  reader.readAsDataURL(file)
}

const resetLogo = () => {
  customLogo.value = null
  if (logoInput.value) {
    logoInput.value.value = ''
  }
  generateQrCode()
}

const printQrCode = () => {
  if (!qrCodeUrl.value) return
  
  const printWindow = window.open('', '_blank')
  if (!printWindow) {
    showToast.error('Veuillez autoriser les popups pour imprimer', 'error')
    return
  }
  
  const restaurant = restaurants.value.find(r => r.id === selectedRestaurant.value)
  
  
  
}

const downloadQrCode = () => {
  if (!qrCodeUrl.value) return
  
  const restaurant = restaurants.value.find(r => r.id === selectedRestaurant.value)
  const filename = `qrcode-${restaurant?.slug || 'restaurant'}.png`
  
  const link = document.createElement('a')
  link.href = qrCodeUrl.value
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
  showToast.success('QR code téléchargé avec succès', 'success')
}

const copyToClipboard = (text) => {
  navigator.clipboard.writeText(text)
    .then(() => {
      showToast.success('URL copiée dans le presse-papier', 'success')
    })
    .catch(() => {
      showToast.error('Impossible de copier l\'URL', 'error')
    })
}

// Watch for changes to regenerate QR code
watch(selectedRestaurant, generateQrCode)

// Initialize
onMounted(() => {
  fetchRestaurants()
})

definePageMeta({
  layout: 'admin'
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.qr-preview {
  transition: all 0.3s ease;
}
</style> 