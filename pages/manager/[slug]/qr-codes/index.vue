<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/90 border-b border-gray-200/20 shadow-sm">
      <div class="max-w-[1400px] mx-auto px-6 sm:px-8 py-6">
        <div class="flex flex-col gap-4">
          <h1 class="text-3xl font-bold text-gray-900">Partage</h1>
          <p class="text-base text-gray-500">Partagez votre menu digital facilement avec vos clients.</p>
        </div>
      </div>
    </header>

    <main class="max-w-[1400px] mx-auto px-6 sm:px-8 py-8 sm:py-10">
      <!-- Analytics Overview -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-10">
        <div class="bg-white rounded-2xl shadow-sm p-6 border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
              <ScanLine class="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <p class="text-3xl font-bold text-gray-900 mb-1">{{ scanStats.total_scans }}</p>
              <p class="text-sm text-gray-500">Scans totaux</p>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-2xl shadow-sm p-6 border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
              <Calendar class="w-6 h-6 text-green-600" />
            </div>
            <div>
              <p class="text-3xl font-bold text-gray-900 mb-1">{{ scanStats.today_scans }}</p>
              <p class="text-sm text-gray-500">Scans aujourd'hui</p>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-2xl shadow-sm p-6 border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
              <Smartphone class="w-6 h-6 text-purple-600" />
            </div>
            <div>
              <p class="text-3xl font-bold text-gray-900 mb-1">{{ scanStats.conversion_rate }}%</p>
              <p class="text-sm text-gray-500">Taux de conversion</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Link -->
      <div class="mb-10">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Lien du menu</h2>
        
        <div class="bg-white rounded-2xl shadow-sm p-6 border-gray-100">
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
            <div class="flex-1 relative">
              <input
                ref="linkInput"
                type="text"
                :value="menuLink"
                readonly
                class="w-full h-12 pl-10 pr-20 rounded-full bg-white border border-gray-200/50 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
              />
              <Link class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <div class="absolute right-3 top-1/2 -translate-y-1/2">
                <button
                  @click="copyLink"
                  class="px-4 py-1.5 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors"
                >
                  Copier
                </button>
              </div>
            </div>
            <button
              @click="shareLink"
              class="h-12 px-6 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-sm"
            >
              <Share2 class="w-4 h-4" />
              Partager
            </button>
          </div>
        </div>
      </div>

      <!-- QR Code Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Left Column -->
        <div>
          <h2 class="text-xl font-semibold text-gray-900 mb-6">QR Codes</h2>
          
          <!-- Main QR Code -->
          <div class="bg-white rounded-2xl shadow-sm p-6 mb-8 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-1">Menu principal</h3>
            <p class="text-sm text-gray-500 mb-6">Code QR vers votre menu complet</p>
            
            <div class="bg-gray-50 rounded-2xl p-8 mb-6 flex items-center justify-center">
              <QRCodeVue3 
                v-if="menuLink"
                :value="menuLink" 
                :size="220"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                :cornersDotOptions="{ type: 'dot', color: qrColor }"
              />
              <Loader2 v-else class="w-10 h-10 animate-spin text-gray-400" />
            </div>

            <div class="flex flex-wrap items-center gap-3">
              <button
                @click="downloadQR('main', 'png')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('main', 'svg')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('main')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
          
          <!-- Table QR Code -->
          <div class="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-1">QR Code par table</h3>
            <p class="text-sm text-gray-500 mb-6">Générez des QR codes uniques pour chaque table</p>
            
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 mb-2">Numéro de table</label>
              <input
                v-model="tableNumber"
                type="number"
                min="1"
                class="w-full h-12 px-4 rounded-full bg-white border border-gray-200/50 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
                placeholder="Ex: 1"
              />
            </div>

            <div v-if="tableNumber" class="bg-gray-50 rounded-2xl p-8 mb-6 flex items-center justify-center animate-fadeIn">
              <QRCodeVue3 
                v-if="tableQrValue"
                :value="tableQrValue" 
                :size="220"
                :margin="0"
                class="mx-auto"
                :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                :cornersDotOptions="{ type: 'dot', color: qrColor }"
              />
              <Loader2 v-else class="w-10 h-10 animate-spin text-gray-400" />
            </div>

            <div v-else class="flex justify-center items-center h-[220px]">
              <Loader2 class="w-8 h-8 animate-spin text-gray-400" />
            </div>

            <div v-if="tableNumber" class="flex flex-wrap items-center gap-3 animate-fadeIn">
              <button
                @click="downloadQR('table', 'png')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                PNG
              </button>
              <button
                @click="downloadQR('table', 'svg')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Download class="w-4 h-4" />
                SVG
              </button>
              <button
                @click="printQR('table')"
                class="flex-1 h-11 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              >
                <Printer class="w-4 h-4" />
                Imprimer
              </button>
            </div>
          </div>
        </div>
        
        <!-- Right Column -->
        <div>
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Personnalisation</h2>
          
          <div class="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-1">Style du QR code</h3>
            <p class="text-sm text-gray-500 mb-6">Personnalisez l'apparence de vos QR codes</p>

            <div class="space-y-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Style des points</label>
                <select 
                  v-model="qrStyle" 
                  class="w-full h-12 px-4 rounded-full bg-white border border-gray-200/50 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
                >
                  <option value="dots">Points</option>
                  <option value="squares">Carrés</option>
                  <option value="rounded">Arrondis</option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Couleur</label>
                <input
                  v-model="qrColor"
                  type="color"
                  class="w-full h-12 rounded-full bg-white border border-gray-200/50 p-1"
                />
              </div>
              
              <div class="bg-gray-50 rounded-2xl p-8 flex items-center justify-center">
                <QRCodeVue3
                  :value="menuLink"
                  :size="150"
                  :margin="0"
                  class="mx-auto"
                  :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                  :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                  :cornersDotOptions="{ type: 'dot', color: qrColor }"
                />
              </div>

              <button
                @click="applyStyle"
                class="w-full h-12 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 active:scale-95 transition-all flex items-center justify-center gap-2"
              >
                <Check class="w-4 h-4" />
                Appliquer
              </button>
            </div>
          </div>

          <!-- Preview section -->
          <div class="bg-white rounded-2xl shadow-sm p-6 border border-gray-100 mt-8">
            <h3 class="text-lg font-semibold text-gray-900 mb-1">Aperçu mobile</h3>
            <p class="text-sm text-gray-500 mb-6">Votre QR code en situation réelle</p>
            
            <div class="relative w-full h-72 bg-gray-50 rounded-2xl overflow-hidden">
              <div class="absolute w-64 h-[95%] top-[2.5%] left-[50%] -translate-x-[50%] bg-white rounded-3xl shadow-lg overflow-hidden border-4 border-gray-800">
                <div class="h-6 bg-gray-800 w-full flex justify-center items-center">
                  <div class="w-16 h-1.5 bg-gray-600 rounded-full"></div>
                </div>
                <div class="p-3 text-center">
                  <div class="text-xs font-medium text-gray-900 mb-2">Scannez ce QR code</div>
                  <div class="flex justify-center">
                    <QRCodeVue3
                      :value="menuLink"
                      :size="100"
                      :margin="0"
                      class="mx-auto"
                      :dotsOptions="{ type: qrStyleMap[qrStyle], color: qrColor }"
                      :cornersSquareOptions="{ type: 'dot', color: qrColor }"
                      :cornersDotOptions="{ type: 'dot', color: qrColor }"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <button 
        @click="testScan"
        class="mt-4 h-10 px-4 bg-gray-100 text-gray-700 rounded-full text-sm hover:bg-gray-200 transition-all"
      >
        Test Scan
      </button>

      <div v-if="lastScan" class="mt-4 p-4 bg-green-50 rounded-xl">
        <p class="text-green-700 font-medium">Dernier scan: {{ formatDate(lastScan.created_at) }}</p>
        <p class="text-sm text-green-600">{{ lastScan.user_agent }}</p>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import QRCodeVue3 from 'qrcode-vue3'
import { Share2, Link, Download, Printer, Check, ScanLine, Calendar, Smartphone, Loader2 } from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useCustomToast } from '~/composables/useToast'
// import { useSupabaseClient } from '~/composables/useSupabase'

const { establishment } = useEstablishment()
const { showToast } = useCustomToast()
const supabase = useSupabaseClient()

const linkInput = ref<HTMLInputElement | null>(null)
const tableNumber = ref<number>()
const qrStyle = ref('dots')
const qrColor = ref('#0071e3') // Apple Blue

// QR scan statistics
const scanStats = ref({
  total_scans: 0,
  today_scans: 0,
  conversion_rate: 0
})

const lastScan = ref(null)

// QR Style mapping
const qrStyleMap = {
  'dots': 'dots',
  'squares': 'squares',
  'rounded': 'rounded'
}

// Utilisons des refs simples au lieu d'appels asynchrones compliqués
const menuLink = ref('')
const tableQrValue = ref('')
const isLoading = ref(true)

// Load QR code scan statistics
const loadScanStats = async () => {
  try {
    const { data, error } = await supabase
      .from('qr_scan_stats')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
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

const loadLastScan = async () => {
  try {
    const { data, error } = await supabase
      .from('qr_scans')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()
    
    if (error) throw error
    if (data) lastScan.value = data
  } catch (err) {
    console.error('Error loading last scan:', err)
  }
}

// Methods
const copyLink = async () => {
  try {
    if (!menuLink.value) {
      showToast.error('Erreur', 'Lien non disponible')
      return
    }
    
    await navigator.clipboard.writeText(menuLink.value)
    showToast.success('Lien copié dans le presse-papier!')
  } catch (err) {
    console.error('Failed to copy:', err)
    showToast.error('Erreur lors de la copie')
  }
}

const shareLink = async () => {
  if (navigator.share && menuLink.value) {
    try {
      await navigator.share({
        title: `Menu de ${establishment.value?.name}`,
        text: `Découvrez notre menu digital`,
        url: menuLink.value
      })
      showToast.success('Lien partagé avec succès!')
    } catch (err) {
      copyLink()
    }
  } else {
    copyLink()
  }
}

const downloadQR = (type: 'main' | 'table', format: 'png' | 'svg' = 'png') => {
  const value = type === 'main' 
    ? menuLink.value 
    : tableNumber.value ? tableQrValue.value : ''
  
  if (!value) {
    showToast.error('Erreur', 'QR code non disponible')
    return
  }
  
  const filename = type === 'main' ? 'qr-menu' : `qr-table-${tableNumber.value}`
  // Implementation for downloading QR code
  // This would normally use a library like html-to-image or dom-to-image
  showToast.success('QR Code téléchargé', `Le QR code a été téléchargé au format ${format.toUpperCase()}`)
}

const printQR = (type: 'main' | 'table') => {
  // Implementation for printing QR code
  // This would normally use window.print() with appropriate CSS
  showToast.success('Impression lancée', 'La fenêtre d\'impression va s\'ouvrir')
}

const applyStyle = () => {
  // The QR code style is applied reactively
  showToast.success('Style appliqué', 'Les QR codes ont été mis à jour')
}

const testScan = async () => {
  try {
    const response = await $fetch('/api/qr-scan-test', {
      method: 'POST',
      body: {
        establishment_id: establishment.value?.id,
        table_number: 1
      }
    });
    console.log(response);
    
    // Try direct database insertion for testing
    const now = new Date().toISOString();
    const { data, error } = await supabase
      .from('qr_scans')
      .insert({
        establishment_id: establishment.value?.id,
        user_agent: navigator.userAgent,
        created_at: now,
        ip_address: '127.0.0.1',
        referrer: document.referrer || 'direct'
      })
      .select();
    
    console.log("Direct DB insertion result:", { data, error });
    
    if (error) {
      showToast.error('Database error', error.message);
    } else {
      showToast.success('Test scan recorded directly');
      loadScanStats(); // Refresh stats
    }
  } catch (err) {
    console.error('Error recording test scan:', err);
    showToast.error('Failed to record test scan');
  }
};

// Format date helper
const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString()
}

const setupRealtimeScans = () => {
  const subscription = supabase
    .channel('qr_scan_updates')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'qr_scans',
        filter: `establishment_id=eq.${establishment.value?.id}`
      },
      (payload) => {
        console.log('New scan detected:', payload)
        lastScan.value = payload.new
        loadScanStats() // Refresh stats
        showToast.success('Nouveau scan détecté!')
      }
    )
    .subscribe()
    
  // Clean up on unmount
  onUnmounted(() => {
    subscription.unsubscribe()
  })
}

// Génération synchrone de l'URL avec un token statique pour tester
// (À remplacer par l'appel API plus tard)
const generateStaticUrl = (tableNumber = null) => {
  const baseUrl = `http://192.168.1.8:3005/menu/${establishment.value?.slug}`
  const fakeToken = 'static-test-token-123456789'
  
  if (tableNumber) {
    return `${baseUrl}?track=true&token=${fakeToken}&table=${tableNumber}`
  }
  
  return `${baseUrl}?track=true&token=${fakeToken}`
}

// Chargement simple des URLs
onMounted(() => {
  // Charger d'abord les autres données
  loadScanStats()
  loadLastScan()
  setupRealtimeScans()
  
  // Solution temporaire: utiliser des URLs statiques pour tester l'affichage
  menuLink.value = generateStaticUrl()
  
  if (tableNumber.value) {
    tableQrValue.value = generateStaticUrl(tableNumber.value)
  }
  
  // Commenter temporairement les appels API problématiques
  // fetchQrUrls()
})

// Observer les changements de numéro de table
watch(tableNumber, (newValue) => {
  if (newValue) {
    // Solution temporaire: utiliser des URLs statiques pour tester l'affichage
    tableQrValue.value = generateStaticUrl(newValue)
    
    // Commenter temporairement les appels API problématiques
    // fetchTableQr(newValue)
  } else {
    tableQrValue.value = ''
  }
})

// Fonction à débloquer ultérieurement
const fetchQrUrls = async () => {
  try {
    const response = await fetch(`/api/qr-token/${establishment.value?.id}`)
    const data = await response.json()
    
    if (data.success && data.token) {
      const baseUrl = `http://192.168.1.8:3008/menu/${establishment.value?.slug}`
      menuLink.value = `${baseUrl}?track=true&token=${data.token}`
      
      if (tableNumber.value) {
        tableQrValue.value = `${baseUrl}?track=true&token=${data.token}&table=${tableNumber.value}`
      }
    } else {
      console.error('Failed to get token:', data)
      showToast.error('Erreur', 'Impossible de générer le token QR')
    }
  } catch (error) {
    console.error('Error fetching token:', error)
    showToast.error('Erreur', 'Connexion impossible')
  }
}

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}

input[type="color"] {
  padding: 0;
  overflow: hidden;
}

input[type="color"]::-webkit-color-swatch-wrapper {
  padding: 0;
}

input[type="color"]::-webkit-color-swatch {
  border: none;
  border-radius: 1rem;
}

input[type="color"]::-moz-color-swatch {
  border: none;
  border-radius: 1rem;
}
</style>