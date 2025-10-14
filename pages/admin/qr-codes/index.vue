<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">QR Codes</h1>
      <p class="text-lg text-gray-600">Aperçu des QR codes de vos établissements</p>
    </div>

    <!-- Establishment Selector -->
    <div class="mb-8">
      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <h2 class="text-xl font-semibold mb-4">Sélectionner un établissement</h2>
            <select 
          v-model="selectedEstablishment" 
          class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200 text-lg"
          @change="loadEstablishmentData"
            >
              <option value="">Sélectionnez un établissement</option>
              <option 
            v-for="establishment in establishments" 
            :key="establishment.id" 
            :value="establishment.id"
          >
            {{ establishment.name }}
              </option>
            </select>
            </div>
          </div>
          
    <!-- QR Code Preview -->
    <div v-if="selectedEstablishment && establishmentData" class="flex flex-col items-center">
      <div class="bg-white rounded-3xl border border-gray-200 p-8 shadow-lg mb-6">
        <QrCodeCard
          ref="qrCodeCardRef"
          :restaurant-name="establishmentData.name"
          :menu-link="menuLink"
          :restaurant-id="establishmentData.id"
        />
      </div>
      
      <!-- Download Button - Twitter Style -->
                <button 
        @click="downloadQrCode"
        :disabled="!qrCodeCardRef?.qrCodeImage"
        class="flex items-center gap-3 px-6 py-3 bg-black text-white rounded-full hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 font-semibold text-base shadow-sm hover:shadow-md active:scale-95"
      >
        <Download class="w-5 h-5" />
        <span>Télécharger le QR code</span>
                </button>
              </div>
              
    <!-- Empty State -->
    <div v-else class="text-center py-16">
      <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <QrCode class="w-12 h-12 text-gray-400" />
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun établissement sélectionné</h3>
      <p class="text-gray-600">Sélectionnez un établissement pour voir son QR code</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { QrCode, Download } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

// State
const establishments = ref<any[]>([])
const selectedEstablishment = ref('')
const establishmentData = ref<any>(null)
const qrCodeCardRef = ref<any>(null)

// Computed
const menuLink = computed(() => {
  if (!establishmentData.value) return ''
  return `${window.location.origin}/menu/${establishmentData.value.id}`
})

// Load establishments
const loadEstablishments = async () => {
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name, slug')
      .order('name')
    
    if (error) throw error
    establishments.value = data || []
  } catch (error) {
    console.error('Error loading establishments:', error)
  }
}

// Load establishment data
const loadEstablishmentData = async () => {
  if (!selectedEstablishment.value) {
    establishmentData.value = null
    return
  }
  
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', selectedEstablishment.value)
      .single()
    
    if (error) throw error
    establishmentData.value = data
  } catch (error) {
    console.error('Error loading establishment data:', error)
  }
}

// Download QR code
const downloadQrCode = async () => {
  try {
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non généré')
      return
    }
    
    // Créer un canvas temporaire pour composer l'image complète
    const tempCanvas = document.createElement('canvas')
    const ctx = tempCanvas.getContext('2d')
    if (!ctx) {
      showToast.error('Erreur', 'Impossible de créer le contexte canvas')
      return
    }
    
    // Dimensions de la carte QR (basées sur le composant QrCodeCard)
    const width = 460
    const height = 600
    
    // Configurer la taille du canvas (avec une résolution x2 pour meilleure qualité)
    tempCanvas.width = width * 2
    tempCanvas.height = height * 2
    ctx.scale(2, 2) // Augmenter la résolution
    
    // Remplir le fond
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)
    
    // Créer une image à partir du QR code
      const qrImage = new Image()
    
    // Attendre que l'image QR soit chargée avant de continuer
    await new Promise((resolve, reject) => {
      qrImage.onload = resolve
      qrImage.onerror = reject
      qrImage.src = qrCodeCardRef.value.qrCodeImage
    })
    
    // 1. Dessiner l'arrière-plan et la bordure du conteneur
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)
    
    // 2. Dessiner les éléments d'en-tête (nom du restaurant + "Menu")
    ctx.font = '600 28px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#1d1d1f'
    ctx.textAlign = 'center'
    ctx.fillText(establishmentData.value?.name || 'Restaurant', width/2, 60)
    
    ctx.font = '400 15px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#86868b'
    ctx.fillText('Menu', width/2, 85)
    
    // 3. Dessiner le conteneur du QR code (bordure orange)
    const qrContainerWidth = 300
    const qrContainerHeight = 300
    const qrContainerX = (width - qrContainerWidth) / 2
    const qrContainerY = 120
    
    // Bordure orange
    ctx.strokeStyle = '#ff6b35'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.roundRect(qrContainerX, qrContainerY, qrContainerWidth, qrContainerHeight, 24)
    ctx.stroke()
    
    // 4. Dessiner l'image QR à l'intérieur du conteneur
    const qrSize = 280
    const qrX = (width - qrSize) / 2
    const qrY = qrContainerY + (qrContainerHeight - qrSize) / 2
    ctx.drawImage(qrImage, qrX, qrY, qrSize, qrSize)
    
    // 5. Dessiner les textes en dessous du QR code
    ctx.font = '600 22px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#ff6b35'
    ctx.fillText('Scannez pour voir le menu', width/2, qrContainerY + qrContainerHeight + 40)
    
    ctx.font = '400 15px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#86868b'
    ctx.fillText('Pointez votre caméra vers le QR code', width/2, qrContainerY + qrContainerHeight + 70)
    
    // 6. Dessiner les features (Rapide, Sans contact)
    // Indicateurs ✓
    const featureY = qrContainerY + qrContainerHeight + 110
    
    // Premier indicateur
    ctx.beginPath()
    ctx.arc(width/2 - 50, featureY, 10, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    ctx.fillStyle = '#FFFFFF'
    ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    ctx.fillText('✓', width/2 - 50, featureY + 4)
    
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Rapide', width/2 - 20, featureY + 4)
    
    // Deuxième indicateur
    ctx.beginPath()
    ctx.arc(width/2 + 40, featureY, 10, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    ctx.fillStyle = '#FFFFFF'
    ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    ctx.fillText('✓', width/2 + 40, featureY + 4)
    
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Sans contact', width/2 + 90, featureY + 4)
    
    // 7. Dessiner la ligne de séparation (divider)
    const dividerY = featureY + 40
    const gradient = ctx.createLinearGradient(0, dividerY, width, dividerY)
    gradient.addColorStop(0, 'rgba(255,255,255,0)')
    gradient.addColorStop(0.5, '#d2d2d7')
    gradient.addColorStop(1, 'rgba(255,255,255,0)')
    
    ctx.strokeStyle = gradient
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(width * 0.1, dividerY)
    ctx.lineTo(width * 0.9, dividerY)
    ctx.stroke()
    
    // 8. Dessiner le footer
    const footerY = dividerY + 40
    
    // Point orange
    ctx.beginPath()
    ctx.arc(width/2 - 40, footerY, 3, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    // Texte "Par Kula Qr"
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Par Kula Qr', width/2 + 10, footerY + 4)
    
    // Télécharger l'image générée
    const dataURL = tempCanvas.toDataURL('image/png')
    const link = document.createElement('a')
    link.download = `menu-${establishmentData.value?.name || 'restaurant'}-${new Date().toISOString().split('T')[0]}.png`
    link.href = dataURL
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    showToast.success('Téléchargé', 'Carte QR téléchargée avec succès')
    
  } catch (error) {
    console.error('Erreur de téléchargement:', error)
    // Fallback au téléchargement direct du QR code
    downloadQrCodeFallback()
  }
}

// Fallback function
const downloadQrCodeFallback = () => {
  try {
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non généré')
    return
  }
  
    const link = document.createElement('a')
    link.href = qrCodeCardRef.value.qrCodeImage
    link.download = `qr-code-${establishmentData.value.name.toLowerCase().replace(/\s+/g, '-')}.png`
    
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
    showToast.success('Succès', 'QR code téléchargé avec succès')
  } catch (error) {
    console.error('Error downloading QR code:', error)
    showToast.error('Erreur', 'Impossible de télécharger le QR code')
  }
}

// Initialize
onMounted(() => {
  loadEstablishments()
})

definePageMeta({
  layout: 'admin'
})
</script>