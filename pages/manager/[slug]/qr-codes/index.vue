<template>
  <div class="min-h-screen bg-white">
    <!-- Header ultra-minimaliste -->
    <header class="sticky top-0 z-50 bg-white border-b border-gray-100 px-6 py-4">
      <div class="max-w-3xl mx-auto">
        <h1 class="text-xl font-semibold text-gray-900">QR Code</h1>
      </div>
    </header>

    <main class="max-w-3xl mx-auto px-6 py-8">
      <!-- Carte QR simplifiée et centrée -->
      <div class="mb-12 flex flex-col items-center">
        <!-- QR Code avec design minimaliste -->
        <div class="mb-8 p-6 bg-white rounded-3xl shadow-sm border border-gray-100 max-w-xs w-full">
          <div class="flex flex-col items-center">
            <!-- QR Code -->
            <div class="mb-6 p-4 bg-white rounded-2xl">
              <img 
                v-if="menuQrGenerated" 
                :src="menuQrImage" 
                alt="QR Code" 
                class="w-48 h-48" 
              />
              <div v-else class="w-48 h-48 flex items-center justify-center bg-gray-50 rounded-lg">
                <div class="animate-pulse bg-gray-200 w-32 h-32"></div>
              </div>
            </div>
            
            <!-- Texte explicatif simple -->
            <p class="text-sm text-gray-500 text-center mb-4">
              Scannez ce code avec l'appareil photo de votre téléphone
            </p>
            
            <!-- URL -->
            <div class="text-xs px-3 py-1.5 bg-gray-100 rounded-full text-gray-600 mb-6">
              {{ menuLink.replace('https://', '') }}
            </div>
            
            <!-- Actions -->
            <div class="flex gap-2 w-full">
              <button 
                @click="copyLink" 
                class="flex-1 py-2.5 px-4 bg-gray-100 hover:bg-gray-200 rounded-full text-gray-800 text-sm flex items-center justify-center gap-1.5 transition-colors"
              >
                <Clipboard class="w-4 h-4" />
                <span>Copier</span>
              </button>
              <button 
                @click="downloadQrCode('menu')" 
                class="flex-1 py-2.5 px-4 bg-blue-500 hover:bg-blue-600 rounded-full text-white text-sm flex items-center justify-center gap-1.5 transition-colors"
              >
                <Download class="w-4 h-4" />
                <span>Télécharger</span>
              </button>
            </div>
          </div>
        </div>
        
        <!-- Statistiques simplifiées -->
        <div class="w-full max-w-xs">
          <div class="mb-2 flex items-center justify-between">
            <h2 class="text-sm font-medium text-gray-700">Statistiques</h2>
            <div class="flex items-center">
              <div class="w-2 h-2 rounded-full bg-green-500 mr-1.5"></div>
              <span class="text-xs text-gray-500">Mis à jour en temps réel</span>
            </div>
          </div>
          
          <div class="grid grid-cols-3 gap-3">
            <div class="bg-white p-3 rounded-2xl shadow-sm border border-gray-100">
              <p class="text-2xl font-medium text-gray-900 mb-1">{{ scanStats.total_scans }}</p>
              <p class="text-xs text-gray-500">Total</p>
            </div>
            <div class="bg-white p-3 rounded-2xl shadow-sm border border-gray-100">
              <p class="text-2xl font-medium text-gray-900 mb-1">{{ scanStats.today_scans }}</p>
              <p class="text-xs text-gray-500">Aujourd'hui</p>
            </div>
            <div class="bg-white p-3 rounded-2xl shadow-sm border border-gray-100">
              <p class="text-2xl font-medium text-gray-900 mb-1">{{ scanStats.conversion_rate }}%</p>
              <p class="text-xs text-gray-500">Conversion</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Partage simplifié -->
      <div class="mb-8">
        <div class="mb-4 flex items-center justify-between">
          <h2 class="text-base font-medium text-gray-900">Partage</h2>
        </div>
        
        <div class="grid grid-cols-4 gap-3">
          <button 
            v-for="platform in ['Instagram', 'Facebook', 'Twitter', 'Messages']" 
            :key="platform"
            @click="shareToService(platform.toLowerCase())"
            class="flex flex-col items-center p-3 rounded-2xl bg-white border border-gray-100 shadow-sm hover:shadow-md transition-shadow"
          >
            <div 
              class="w-10 h-10 rounded-full mb-2 flex items-center justify-center"
              :class="{
                'bg-gradient-to-br from-purple-500 to-pink-500': platform === 'Instagram',
                'bg-blue-600': platform === 'Facebook',
                'bg-blue-400': platform === 'Twitter',
                'bg-green-500': platform === 'Messages'
              }"
            >
              <img 
                v-if="['Instagram', 'Facebook', 'Twitter'].includes(platform)"
                :src="`/images/social/${platform.toLowerCase()}.svg`" 
                :alt="platform"
                class="h-5 w-5 invert"
              />
              <MessageSquare v-else class="h-5 w-5 text-white" />
            </div>
            <span class="text-xs text-gray-800">{{ platform }}</span>
          </button>
        </div>
      </div>
      
      <!-- Dernière activité -->
      <div v-if="lastScan" class="flex items-center justify-between p-3 bg-white rounded-2xl shadow-sm border border-gray-100">
        <div class="flex items-center gap-3">
          <div class="relative">
            <Smartphone class="w-5 h-5 text-gray-600" />
            <div class="absolute -top-1 -right-1 w-2 h-2 bg-green-500 rounded-full"></div>
          </div>
          <span class="text-sm text-gray-700">Dernier scan {{ formatTimeAgo(lastScan.created_at) }}</span>
        </div>
        <span class="text-xs px-2 py-1 bg-gray-100 rounded-full text-gray-600">Activité</span>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import QRCode from 'qrcode'
import { Share2, Download, Smartphone, QrCode, Clipboard, MessageSquare } from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useToast } from '~/composables/useToast'
import { useSupabaseClient } from '#imports'

// États
const menuQrImage = ref('')
const menuQrGenerated = ref(false)
const menuLink = ref('')
const qrColor = ref('#000000')
const establishment = useEstablishment()
const showToast = useToast()
const scanStats = ref({
  total_scans: 0,
  today_scans: 0,
  conversion_rate: 0
})
const lastScan = ref(null)
const supabase = useSupabaseClient()

// Générer l'URL du menu
const generateStaticUrl = () => {
  const baseUrl = useRuntimeConfig().public.baseURL
  return `${baseUrl}/menu/${establishment.value?.slug || ''}`
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

// Charger les statistiques
const loadScanStats = async () => {
  try {
    if (!establishment.value?.id) return
    
    const { data, error } = await supabase
      .rpc('get_establishment_scan_stats', { establishment_id: establishment.value.id })
    
    if (error) throw error
    
    if (data) {
      scanStats.value = {
        total_scans: data.total_scans || 0,
        today_scans: data.today_scans || 0,
        conversion_rate: data.conversion_rate || 0
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
    console.error('Error loading last scan:', err)
  }
}

// Formater le temps écoulé
const formatTimeAgo = (dateString) => {
  const date = new Date(dateString)
  const seconds = Math.floor((new Date() - date) / 1000)
  
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
let subscription;
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
const shareToService = async (platform) => {
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
/* Styles minimalistes */
button {
  transition: background-color 0.2s, transform 0.1s;
}

button:active {
  transform: scale(0.98);
}
</style>