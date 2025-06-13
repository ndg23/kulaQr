<template>
  <div class="min-h-screen bg-white">
    <!-- Header simplifié -->
    <header class="sticky top-0 z-50 bg-white border-b border-gray-100 px-6 py-4">
      <div class="max-w-2xl mx-auto">
        <div class="flex items-center gap-6">
          <h1 class="text-xl font-bold text-gray-900">Menu QR Code</h1>
          <div class="flex items-center gap-2 px-3 py-1 bg-gray-50 rounded-full">
            <div class="w-2 h-2 rounded-full bg-green-500"></div>
            <span class="text-sm text-gray-600">En ligne</span>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-2xl mx-auto px-6 py-12">
      <!-- Carte QR simplifiée -->
      <div class="bg-white rounded-2xl overflow-hidden">
        <!-- QR Code Card -->
        <div 
          ref="qrCard"
          class="aspect-[4/3] relative bg-white p-12 flex flex-col items-center justify-center"
        >
          <!-- Logo et nom -->
          <div class="absolute top-8 left-8 right-8 flex items-center justify-between">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-green-600 flex items-center justify-center">
                <UtensilsCrossed class="w-6 h-6 text-white" />
              </div>
              <div>
                <span class="text-xl font-bold text-gray-900">{{ establishment.value?.name }}</span>
                <p class="text-sm text-gray-500 mt-0.5">Menu Digital</p>
              </div>
            </div>
          </div>

          <!-- QR Code -->
          <div class="w-72 h-72 p-6 bg-white rounded-3xl shadow-[0_0_60px_-15px_rgba(0,0,0,0.1)]">
            <img 
              v-if="menuQrGenerated" 
              :src="menuQrImage" 
              alt="QR Code Menu"
              class="w-full h-full" 
            />
            <div v-else class="w-full h-full animate-pulse bg-gray-50 rounded-2xl"></div>
          </div>

          <!-- Call to action -->
          <div class="absolute bottom-8 left-8 right-8">
            <p class="text-base font-medium text-gray-900 text-center">Scannez pour voir notre menu</p>
            <p class="text-sm text-gray-500 mt-2 text-center">{{ menuLink }}</p>
          </div>
        </div>

        <!-- Actions -->
        <div class="border-t border-gray-50 p-6 flex gap-4">
          <button 
            @click="copyLink" 
            class="flex-1 py-3 px-6 bg-gray-50 hover:bg-gray-100 rounded-xl text-gray-700 text-sm font-medium flex items-center justify-center gap-2 transition-colors"
          >
            <Clipboard class="w-4 h-4" />
            Copier le lien
          </button>
          <button 
            @click="downloadQrCode()" 
            class="flex-1 py-3 px-6 bg-green-600 hover:bg-green-700 rounded-xl text-white text-sm font-medium flex items-center justify-center gap-2 transition-colors"
          >
            <Download class="w-4 h-4" />
            Télécharger
          </button>
        </div>
      </div>

      <!-- Stats simplifiées -->
      <div class="mt-12 space-y-6">
        <div class="grid grid-cols-3 gap-6">
          <div class="bg-white p-6 rounded-2xl">
            <div class="text-3xl font-bold text-gray-900">{{ scanStats.total_scans }}</div>
            <div class="text-sm text-gray-500 mt-2">Total scans</div>
          </div>
          <div class="bg-white p-6 rounded-2xl">
            <div class="text-3xl font-bold text-gray-900">{{ scanStats.today_scans }}</div>
            <div class="text-sm text-gray-500 mt-2">Aujourd'hui</div>
          </div>
          <div class="bg-white p-6 rounded-2xl">
            <div class="text-3xl font-bold text-gray-900">{{ scanStats.conversion_rate }}%</div>
            <div class="text-sm text-gray-500 mt-2">Conversion</div>
          </div>
        </div>

        <!-- Dernier scan -->
        <div v-if="lastScan" class="bg-white p-6 rounded-2xl">
          <div class="flex items-center gap-4">
            <div class="relative">
              <div class="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center">
                <Smartphone class="w-5 h-5 text-gray-400" />
              </div>
              <div class="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
            <div>
              <span class="text-base font-medium text-gray-900">Dernier scan</span>
              <p class="text-sm text-gray-500 mt-0.5">
                {{ formatTimeAgo(lastScan.created_at) }}
              </p>
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

// États
const menuQrImage = ref('')
const menuQrGenerated = ref(false)
const menuLink = ref('')
const qrColor = ref('#000000')
const establishment = useEstablishment()
const {showToast} = useCustomToast()
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
const formatTimeAgo = (dateString: string) => {
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
/* Styles améliorés */
button {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

button:active {
  transform: scale(0.98);
}

.aspect-4\/3 {
  aspect-ratio: 4/3;
}

/* Ombre douce pour les cartes */
.rounded-2xl {
  box-shadow: 0 0 40px -15px rgba(0,0,0,0.05);
}
</style>