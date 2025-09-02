<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header moderne et épuré -->
    <header class="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100 px-6 py-4">
      <div class="max-w-2xl mx-auto">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center">
              <QrCode class="w-4 h-4 text-white" />
            </div>
            <h1 class="text-lg font-semibold text-gray-900">QR Code Menu</h1>
          </div>
          <div class="flex items-center gap-2 px-3 py-1.5 bg-green-50 rounded-full">
            <div class="w-2 h-2 rounded-full bg-green-500"></div>
            <span class="text-sm font-medium text-green-700">En ligne</span>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-2xl mx-auto px-6 py-8">
      <!-- Carte QR moderne -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <!-- QR Code Card -->
        <div 
          ref="qrCard"
          class="aspect-[4/3] relative bg-gradient-to-br from-gray-50 to-white p-8 flex flex-col items-center justify-center"
        >
          <!-- Logo et nom -->
          <div class="absolute top-6 left-6 right-6 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-sm">
                <UtensilsCrossed class="w-5 h-5 text-white" />
              </div>
              <div>
                <span class="text-lg font-semibold text-gray-900">{{ establishment?.name || 'Restaurant' }}</span>
                <p class="text-sm text-gray-500">Menu Digital</p>
              </div>
            </div>
          </div>

          <!-- QR Code centré -->
          <div class="w-64 h-64 p-4 bg-white rounded-2xl shadow-lg border border-gray-100">
            <img 
              v-if="menuQrGenerated" 
              :src="menuQrImage" 
              alt="QR Code Menu"
              class="w-full h-full" 
            />
            <div v-else class="w-full h-full animate-pulse bg-gray-100 rounded-xl flex items-center justify-center">
              <QrCode class="w-12 h-12 text-gray-300" />
            </div>
          </div>

          <!-- Call to action -->
          <div class="absolute bottom-6 left-6 right-6 text-center">
            <p class="text-base font-medium text-gray-900 mb-2">Scannez pour voir notre menu</p>
            <p class="text-sm text-gray-500 font-mono bg-gray-50 px-3 py-2 rounded-lg border border-gray-200">{{ menuLink }}</p>
          </div>
        </div>

        <!-- Actions modernes -->
        <div class="border-t border-gray-100 p-6">
          <div class="grid grid-cols-2 gap-3">
            <button 
              @click="copyLink" 
              class="flex items-center justify-center gap-2 py-3 px-4 bg-gray-50 hover:bg-gray-100 rounded-xl text-gray-700 text-sm font-medium transition-all duration-200 hover:scale-[1.02] active:scale-[0.98]"
            >
              <Clipboard class="w-4 h-4" />
              Copier le lien
            </button>
            <button 
              @click="downloadQrCode()" 
              class="flex items-center justify-center gap-2 py-3 px-4 bg-blue-500 hover:bg-blue-600 rounded-xl text-white text-sm font-medium transition-all duration-200 hover:scale-[1.02] active:scale-[0.98] shadow-sm"
            >
              <Download class="w-4 h-4" />
              Télécharger
            </button>
          </div>
        </div>
      </div>

      <!-- Stats modernes -->
      <div class="mt-8 space-y-4">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Statistiques</h2>
        <div class="grid grid-cols-3 gap-4">
          <div class="bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.total_scans }}</div>
            <div class="text-sm text-gray-500 mt-1">Total scans</div>
          </div>
          <div class="bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.today_scans }}</div>
            <div class="text-sm text-gray-500 mt-1">Aujourd'hui</div>
          </div>
          <div class="bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.conversion_rate }}%</div>
            <div class="text-sm text-gray-500 mt-1">Conversion</div>
          </div>
        </div>

        <!-- Dernier scan -->
        <div v-if="lastScan" class="bg-white p-5 rounded-xl border border-gray-100 shadow-sm">
          <div class="flex items-center gap-4">
            <div class="relative">
              <div class="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center">
                <Smartphone class="w-5 h-5 text-blue-500" />
              </div>
              <div class="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
            <div class="flex-1">
              <div class="text-sm font-medium text-gray-900">Dernier scan</div>
              <div class="text-sm text-gray-500">
                {{ formatTimeAgo(lastScan.created_at) }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import QRCode from 'qrcode'
import { Share2, Download, Smartphone, QrCode, Clipboard, MessageSquare, UtensilsCrossed } from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseClient } from '#imports'

// Récupérer le slug de l'URL
const route = useRoute()
const slug = route.params.slug as string

// États
const menuQrImage = ref('')
const menuQrGenerated = ref(false)
const menuLink = ref('')
const qrColor = ref('#000000')
const { establishment } = useEstablishment()
const {showToast} = useCustomToast()
const scanStats = ref({
  total_scans: 0,
  today_scans: 0,
  conversion_rate: 0
})
const lastScan = ref<any>(null)
const supabase = useSupabaseClient()

// Générer l'URL du menu
const generateStaticUrl = () => {
  const baseUrl = useRuntimeConfig().public.baseURL || window.location.origin
  return `${baseUrl}/menu/${slug}`
}

// Générer le QR code
const generateQrCode = async () => {
  if (!menuLink.value) return
  
  try {
    const qrCodeDataUrl = await QRCode.toDataURL(menuLink.value, {
      width: 512,
      margin: 1,
      color: {
        dark: qrColor.value,
        light: '#FFFFFF'
      }
    })
    
    menuQrImage.value = qrCodeDataUrl
    menuQrGenerated.value = true
  } catch (err) {
    console.error('QR code generation error:', err)
    showToast.error('Erreur', 'Impossible de générer le QR code')
  }
}

// Copier le lien du menu
const copyLink = async () => {
  try {
    await navigator.clipboard.writeText(menuLink.value)
    showToast.success('Copié', 'Lien copié dans le presse-papier')
  } catch (err) {
    console.error('Copy error:', err)
    showToast.error('Erreur', 'Impossible de copier le lien')
  }
}

// Télécharger le QR code
const downloadQrCode = () => {
  const link = document.createElement('a')
  link.download = `menu-${establishment.value?.name || 'restaurant'}.png`
  link.href = menuQrImage.value
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  showToast.success('Téléchargé', 'QR code téléchargé avec succès')
}

// Charger les statistiques avec la vue qr_scan_stats
const loadScanStats = async () => {
  try {
    if (!establishment.value?.id) return
    
    const { data, error } = await supabase
      .from('qr_scan_stats')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .single()
    
    if (error) throw error
    
    if (data) {
      scanStats.value = {
        total_scans: (data as any).total_scans || 0,
        today_scans: (data as any).today_scans || 0,
        conversion_rate: (data as any).conversion_rate || 0
      }
    }
  } catch (err) {
    console.error('Error loading scan stats:', err)
  }
}

// Charger le dernier scan
const loadLastScan = async () => {
  try {
    if (!establishment.value?.id) return
    
    const { data, error } = await supabase
      .from('qr_scans')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()
    
    if (error && error.code !== 'PGRST116') throw error
    
    if (data) {
      lastScan.value = data
    }
  } catch (err) {
    console.error('Error loading last scan:', err as Error)
  }
}

// Formater le temps écoulé
const formatTimeAgo = (dateString: string) => {
  const date = new Date(dateString)
  const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000)
  
  let interval = seconds / 31536000
  if (interval > 1) return `il y a ${Math.floor(interval)} an${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 2592000
  if (interval > 1) return `il y a ${Math.floor(interval)} mois`
  
  interval = seconds / 86400
  if (interval > 1) return `il y a ${Math.floor(interval)} jour${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 3600
  if (interval > 1) return `il y a ${Math.floor(interval)} heure${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 60
  if (interval > 1) return `il y a ${Math.floor(interval)} minute${Math.floor(interval) > 1 ? 's' : ''}`
  
  return `il y a ${Math.floor(seconds)} seconde${Math.floor(seconds) > 1 ? 's' : ''}`
}

// Configurer l'écoute des scans en temps réel
let subscription: any;
const setupRealtimeScans = () => {
  if (!establishment.value?.id) return
  
  // Annuler l'abonnement existant
  if (subscription) {
    subscription.unsubscribe()
  }
  
  subscription = supabase
    .channel('qr-scans')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'qr_scans',
        filter: `establishment_id=eq.${establishment.value.id}`
      },
      (payload) => {
        console.log('Nouveau scan détecté:', payload)
        
        // Mettre à jour les statistiques
        scanStats.value.total_scans++
        scanStats.value.today_scans++
        lastScan.value = payload.new
        
        // Montrer une notification
        showToast.success('Nouveau scan', 'Quelqu\'un a scanné votre QR code')
      }
    )
    .subscribe()
  
  // Nettoyage lors du démontage du composant
  onUnmounted(() => {
    if (subscription) subscription.unsubscribe()
  })
}

// Partager sur les réseaux sociaux
const shareToService = async (platform: string) => {
  try {
    // Version simplifiée du partage
    const text = `Découvrez notre menu digital : ${menuLink.value}`
    
    if (navigator.share) {
      await navigator.share({
        title: `Menu de ${establishment.value?.name || 'restaurant'}`,
        text: text,
        url: menuLink.value
      })
      showToast.success('Partagé', `Contenu partagé avec succès`)
    } else {
      // Fallback: copier le texte
      await navigator.clipboard.writeText(text)
      showToast.success('Copié', `Texte pour ${platform} copié`)
    }
  } catch (err) {
    console.error('Error sharing:', err)
    if (err.name !== 'AbortError') {
      showToast.error('Erreur', 'Impossible de partager le contenu')
    }
  }
}

// Initialisation
onMounted(async () => {
  menuLink.value = generateStaticUrl()
  await Promise.all([
    loadScanStats(),
    loadLastScan(),
    generateQrCode()
  ])
  setupRealtimeScans()
})

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
/* Design moderne et épuré inspiré de Twitter 2024 */

/* Transitions fluides */
button {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

button:hover {
  transform: translateY(-1px);
}

button:active {
  transform: translateY(0) scale(0.98);
}

/* Aspect ratio moderne */
.aspect-4\/3 {
  aspect-ratio: 4/3;
}

/* Ombres subtiles et modernes */
.rounded-2xl {
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
}

.rounded-xl {
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

/* Animation du QR code */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

img {
  animation: fadeIn 0.3s ease-out;
}

/* Gradient subtil pour le fond */
.bg-gradient-to-br {
  background: linear-gradient(135deg, #f9fafb 0%, #ffffff 100%);
}

/* Hover effects pour les cartes */
.bg-white:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: all 0.2s ease;
}

/* Focus states pour l'accessibilité */
button:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Responsive design */
@media (max-width: 640px) {
  .grid-cols-3 {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .w-64 {
    width: 12rem;
  }
  
  .h-64 {
    height: 12rem;
  }
}
</style>