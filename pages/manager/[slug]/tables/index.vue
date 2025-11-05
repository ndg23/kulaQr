<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Espaces</h1>
      <p class="text-lg text-gray-600">Gérez les espaces de votre établissement</p>
    </div>

    <!-- Stats Cards -->
    <!-- <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Total Espaces</p>
            <p class="text-2xl font-bold text-gray-900">{{ tables.length }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
            <Table class="w-6 h-6 text-blue-500" />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Espaces VIP</p>
            <p class="text-2xl font-bold text-purple-600">{{ vipTables }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
            <Users class="w-6 h-6 text-purple-500" />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">QR Codes Générés</p>
            <p class="text-2xl font-bold text-green-600">{{ qrCodesGenerated }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
            <QrCode class="w-6 h-6 text-green-500" />
          </div>
        </div>
      </div>
    </div> -->

    <!-- Actions Bar -->
    <div class="bg-white rounded-2xl border border-gray-200 p-6 mb-8">
      <div class="flex gap-4 items-start sm:items-center justify-between flex-wrap">
        <div class="flex items-center gap-4">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher une table..."
              class="pl-10 pr-4 py-3 w-full sm:w-80 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
            />
          </div>
        </div>
        
        <div class="flex gap-3">
          <button
            @click="refreshData"
            :disabled="loading"
            class="px-4 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 disabled:opacity-50 transition-colors flex items-center gap-2"
          >
            <RefreshCw :class="{ 'animate-spin': loading }" class="w-4 h-4" />
            Actualiser
          </button>
          
          <button
            @click="openTableModal"
            class="px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-colors flex items-center gap-2"
          >
            <Plus class="w-4 h-4" />
            Nouveau Lieu
          </button>
        </div>
      </div>
    </div>

    <!-- Tables Grid -->
    <div v-if="loading" class="flex justify-center py-12">
 <div class="w-16 h-16 relative">
          <div class="w-16 h-16 bg-gray-100 rounded-full animate-pulse"></div>
          <Loader2 class="w-8 h-8 text-gray-400 animate-spin absolute inset-0 m-auto" />
        </div>
          </div>

    <div v-else-if="filteredTables.length === 0" class="text-center py-16">
      <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <Table class="w-12 h-12 text-gray-400" />
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun lieu trouvé</h3>
      <p class="text-gray-600 mb-6">
        {{ searchQuery ? 'Aucun lieu ne correspond à votre recherche' : 'Commencez par créer votre premier lieu' }}
      </p>
      <button
        v-if="!searchQuery"
        @click="openTableModal"
        class="px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-colors"
      >
        Créer un lieu
      </button>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3  gap-6">
      <div
        v-for="table in filteredTables"
        :key="table.id"
        class="group bg-white rounded-3xl border border-gray-100 p-6 hover:shadow-lg- hover:border-red-200 transition-all duration-300 hover:-translate-y-0.5"
      >
        <!-- Table Header -->
        <div class="flex items-center justify-between mb-5 flex-wrap">
          <div class="flex items-center gap-4 mt-2 lg:mt-0">
          
            <div>
              <h3 class="text-xl font-bold text-gray-900 mb-1">Numéro {{ table.number }}</h3>
              <div class="flex items-center gap-2">
                <span :class="[
                  table.type === 'VIP' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700',
                  'px-2 py-1 rounded-lg text-xs font-medium'
                ]">
                  {{ table.type }}
                </span>
                <span class="text-sm text-gray-500">{{ table.zone }}</span>
              </div>
            </div>
          </div>
          
          <div class="flex items-center gap-2">
            <span :class="[
              table.qr_code_generated ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-gray-50 text-gray-600 border-gray-200',
              'px-3 py-1.5 rounded-full text-xs font-medium border'
            ]">
              {{ table.qr_code_generated ? 'QR Prêt' : 'Pas de QR' }}
            </span>
          </div>
        </div>

        <!-- Table Info -->
                       <QrCode v-if="table.qr_code_url" 

                class="block w-[200px] h-[200px] object-contain mx-auto mb-4 text-[#f919000]"
              />
              <QrCode v-else class="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-500 text-sm mb-6 leading-relaxed h-16 overflow-hidden">
          {{ table.description || 'Aucune description fournie pour cette table.' }}
        </p>


        <!-- Actions -->
        <div class="flex gap-2 flex-wrap">
          <button
            @click="editTable(table)"
            class="flex-1 px-4 py-2.5 bg-gray-50 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-100 transition-colors border border-gray-200"
          >
            Modifier
          </button>
          <button
            v-if="!table.qr_code_generated"
            @click="generateQrCode(table)"
            class="flex-1 px-4 py-2.5 bg-blue-50 text-blue-700 rounded-xl text-sm font-medium hover:bg-blue-100 transition-colors border border-blue-200"
          >
            Générer QR
          </button>
          <button
            v-else
            @click="viewMenuTable(table)"
            class="flex-1 px-4 py-2.5 bg-emerald-50 text-emerald-700 rounded-xl text-sm font-medium hover:bg-emerald-100 transition-colors border border-emerald-200 flex items-center justify-center gap-1.5"
          >
            <ArrowRight class="w-4 h-4" />
            Voir le menu
          </button>
          <button
            v-if="table.qr_code_generated"
              @click="showQrCodeCard(table)"
            class="px-4 py-2.5 bg-orange-50 text-orange-700 rounded-xl text-sm font-medium hover:bg-orange-100 transition-colors border border-orange-200 flex items-center justify-center gap-1.5"
            title="Imprimer QR Code Card"
          >
            <QrCode class="w-4 h-4" />
          </button>
          <button
            @click="deleteTable(table.id)"
            class="px-4 py-2.5 bg-red-50 text-red-700 rounded-xl text-sm font-medium hover:bg-red-100 transition-colors border border-red-200"
            title="Supprimer la table"
          >
            <Trash2 class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>

    <!-- Table Modal -->
    <UModal v-model="showTableModal" size="lg" :show-buttons="false" >
      <div class="p-6">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-xl font-semibold text-gray-900">
            {{ editingTable ? 'Modifier la table' : 'Nouvelle table' }}
          </h2>
          <button
            @click="closeTableModal"
            class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <form @submit.prevent="saveTable" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FloatLabelInput
              id="table-number"
              v-model="tableForm.number"
              label="Numéro du lieu"
              type="number"
              required
              placeholder="Ex: 1, 2, 3..."
            />

            <FloatLabelSelect
              id="table-type"
              v-model="tableForm.type"
              label="Type"
              required
            >
              <option value="SIMPLE">SIMPLE</option>
              <option value="VIP">VIP</option>
            </FloatLabelSelect>
          </div>

          <FloatLabelSelect
            id="table-zone"
            v-model="tableForm.zone"
            label="Precisez la zone"
            required
          >
            <option value="ETAGE">ETAGE</option>
            <option value="TERRASSE">TERRASSE</option>
            <option value="REZ_DE_CHAUSSEE">REZ DE CHAUSSEE</option>
          </FloatLabelSelect>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea
              v-model="tableForm.description"
              rows="3"
              class="w-full px-4 py-3 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
              placeholder="Description de la table..."
            />
          </div>

          <div class="flex gap-3 pt-4 d-none-">
            <button
              type="button"
              @click="closeTableModal"
              class="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 transition-colors"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="loading"
              class="flex-1 px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 disabled:opacity-50 transition-colors"
            >
              {{ editingTable ? 'Modifier' : 'Créer' }}
            </button>
          </div>
        </form>
      </div>
    </UModal>

    <!-- QR Code Modal -->
    <UModal v-model="showQrModal"  :show-buttons="false">
      <div class="">
        <div class="flex items-center justify-between mb-2">
          
          <button
            @click="showQrModal = false"
            class="p-2 rounded-full border border-gray-300 hover:bg-gray-100 transition-colors"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <div class="flex justify-center-" ref="qrCard">
          <QrCodeCard
            v-if="selectedTableForQr"
            ref="qrCodeCardRef"
            :table-number="selectedTableForQr.number"
            :restaurant-name="establishment?.name || 'Menu'"
            :menu-link="selectedTableForQr.qr_code_url"
            :restaurant-id="establishment?.id"
          />
        </div>

        <div class="flex gap-3 max-w-md mx-auto mt-2">
          <button
            @click="downloadQrCode(selectedTableForQr)"
            class="flex-1 px-6 py-3 bg-blue-50 text-blue-700 rounded-2xl font-semibold hover:bg-blue-100 transition-colors flex items-center justify-center gap-2"
          >
            <Download class="w-4 h-4" />
            Télécharger
          </button>
          <button
            @click="showQrCodeCard(selectedTableForQr)"
            class="flex-1 px-6 py-3 bg-orange-50 text-orange-700 rounded-2xl font-semibold hover:bg-orange-100 transition-colors flex items-center justify-center gap-2"
          >
            <QrCode class="w-4 h-4" />
            Imprimer
          </button>
        </div>
      </div>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Table, Users, CheckCircle, ShoppingCart, Plus, Search, 
  RefreshCw, Loader2, Trash2, X, QrCode, Download, Eye, View, ArrowRight 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'
import QrCodeCard from '~/components/QrCodeCard.vue'
import { encodeTableHashids } from '~/utils/secure-encoding'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const { establishment, fetchEstablishmentByUserId } = useEstablishment()
definePageMeta({
  layout: 'manager'
})
// State
const loading = ref(false)
const tables = ref<any[]>([])
const searchQuery = ref('')
const showTableModal = ref(false)
const editingTable = ref<any>(null)
const showQrModal = ref(false)
const selectedTableForQr = ref<any>(null)
const qrCodeCardRef = ref()
const qrCard= ref()

// Form
const tableForm = ref({
  number: '',
  type: 'SIMPLE',
  zone: 'ETAGE',
  description: ''
})

// Computed
const filteredTables = computed(() => {
  if (!searchQuery.value) return tables.value
  
  return tables.value.filter(table => 
    table.number.toString().includes(searchQuery.value) ||
    (table.zone && table.zone.toLowerCase().includes(searchQuery.value.toLowerCase()))
  )
})

const vipTables = computed(() => 
  tables.value.filter(table => table.type === 'VIP').length
)

const qrCodesGenerated = computed(() => 
  tables.value.filter(table => table.qr_code_generated).length
)

// Load tables
const loadTables = async () => {
  if (!establishment.value) return
  
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('tables')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('number', { ascending: true })

    if (error) throw error
    
    tables.value = data || []
  } catch (err) {
    console.error('Error loading tables:', err)
    showToast.error('Erreur', 'Impossible de charger les tables')
  } finally {
    loading.value = false
  }
}

const viewMenuTable = (table: any) => {
  navigateTo(`/qr/${establishment.value?.id}?table=${table.number}`)
  showToast.success('Ouverture', 'Menu ouvert dans un nouvel onglet')
}

// Table actions
const openTableModal = () => {
  editingTable.value = null
  tableForm.value = {
    number: '',
    type: 'SIMPLE',
    zone: 'ETAGE',
    description: ''
  }
  showTableModal.value = true
}

const editTable = (table: any) => {
  editingTable.value = table
  tableForm.value = {
    number: table.number,
    type: table.type || 'SIMPLE',
    zone: table.zone || 'ETAGE',
    description: table.description || ''
  }
  showTableModal.value = true
}

const closeTableModal = () => {
  showTableModal.value = false
  editingTable.value = null
  tableForm.value = {
    number: '',
    type: 'SIMPLE',
    zone: 'ETAGE',
    description: ''
  }
}

const generateQrCode = async (table: any) => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    // Encoder le numéro de table pour le cacher
    const encodedTableNumber = encodeTableHashids(table.number, establishment.value.id)
    
    // Générer l'URL du menu pour cette table spécifique avec le numéro encodé
    const tableMenuUrl = `${window.location.origin}/qr/${establishment.value.id}?table=${encodedTableNumber}`
    
    // Mettre à jour la table avec l'URL du QR code
    const { error } = await supabase
      .from('tables')
      .update({
        qr_code_url: tableMenuUrl,
        qr_code_generated: true
      })
      .eq('id', table.id)

    if (error) throw error

    // Mettre à jour les données locales
    const index = tables.value.findIndex(t => t.id === table.id)
    if (index !== -1) {
      tables.value[index].qr_code_url = tableMenuUrl
      tables.value[index].qr_code_generated = true
    }
    
    showToast.success('QR Code généré', `QR code généré pour la table ${table.number}`)
  } catch (err) {
    console.error('Error generating QR code:', err)
    showToast.error('Erreur', 'Impossible de générer le QR code')
  } finally {
    loading.value = false
  }
}

const saveTable = async () => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    const tableData = {
      number: parseInt(tableForm.value.number),
      type: tableForm.value.type,
      zone: tableForm.value.zone,
      description: tableForm.value.description,
      qr_code_url: editingTable.value ? editingTable.value.qr_code_url : null,
      establishment_id: establishment.value.id
    }

    if (editingTable.value) {
      // Update existing table
      const { error } = await supabase
        .from('tables')
        .update(tableData)
        .eq('id', editingTable.value.id)

      if (error) throw error

      // Update local data
      const index = tables.value.findIndex(t => t.id === editingTable.value.id)
      if (index !== -1) {
        tables.value[index] = { ...tables.value[index], ...tableData }
      }
      
      showToast.success('Table modifiée', 'La table a été modifiée avec succès')
    } else {
      // Create new table
      const { data, error } = await supabase
        .from('tables')
        .insert(tableData)
        .select()
        .single()

      if (error) throw error

      tables.value.push(data)
      generateQrCode(data)
      showToast.success('Table créée', 'La table a été créée avec succès')
    }

    closeTableModal()
  } catch (err) {
    console.error('Error saving table:', err)
    showToast.error('Erreur', 'Impossible de sauvegarder la table')
  } finally {
    loading.value = false
  }
}

const deleteTable = async (tableId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette table ?')) return
  
  try {
    const { error } = await supabase
      .from('tables')
      .delete()
      .eq('id', tableId)

    if (error) throw error
    
    tables.value = tables.value.filter(t => t.id !== tableId)
    showToast.success('Table supprimée', 'La table a été supprimée avec succès')
  } catch (err) {
    console.error('Error deleting table:', err)
    showToast.error('Erreur', 'Impossible de supprimer la table')
  }
}


const downloadQrCodes = (table: any) => {
  if (!table.qr_code_url) {
    showToast.error('Erreur', 'Aucun QR code disponible pour cette table')
    return
  }
  
  // Ouvrir l'URL dans un nouvel onglet pour téléchargement/impression
  window.open(table.qr_code_url, '_blank')
  showToast.success('Ouverture', 'QR code ouvert dans un nouvel onglet')
}

const downloadQrCode = async (table: any) => {
  try {
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non généré')
      return
    }
    
    // Créer un canvas temporaire pour composer l'image complète
    const tempCanvas = document.createElement('canvas')
    const ctx = tempCanvas.getContext('2d')
    
    // Obtenir les dimensions de la carte QR
    const qrCardElement = qrCard.value
    const width = qrCardElement.offsetWidth
    const height = qrCardElement.offsetHeight
    
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
    
    // Recréer la structure de la carte QR avec les textes et l'image QR
    
    // 1. Dessiner l'arrière-plan et la bordure du conteneur
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)
    
    // 2. Dessiner les éléments d'en-tête (nom du restaurant + "Menu")
    ctx.font = '600 28px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#1d1d1f'
    ctx.textAlign = 'center'
    ctx.fillText(establishment.value?.name || '--', width/2, 60)
    
    ctx.font = '600 15px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#86868b'

    ctx.fillText(`N° ${table.number}`, width/2, 80)

    // 3. Dessiner le conteneur du QR code (bordure orange)
    const qrContainerWidth = 300
    const qrContainerHeight = 300
    const qrContainerX = (width - qrContainerWidth) / 2
    const qrContainerY = 100
    
    // Bordure orange
    // ctx.strokeStyle = '#ff6b35'
    // ctx.lineWidth = 2
    // ctx.beginPath()
    // ctx.roundRect(qrContainerX, qrContainerY, qrContainerWidth, qrContainerHeight, 24)
    // ctx.stroke()
    
    // 4. Dessiner l'image QR à l'intérieur du conteneur
    const qrSize = 280
    const qrX = (width - qrSize) / 2
    const qrY = qrContainerY + (qrContainerHeight - qrSize) / 2
    ctx.drawImage(qrImage, qrX, qrY, qrSize, qrSize)
    
    // 5. Dessiner les textes en dessous du QR code
    ctx.font = '500 22px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#f91919'
    ctx.fillText('Scannez pour commander', width/2, qrContainerY + qrContainerHeight + 40)
    
    ctx.font = '400 14px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#000000'
    ctx.fillText('Pointez votre caméra vers le QR code', width/2, qrContainerY + qrContainerHeight + 70)
    
    // 6. Dessiner les features (Rapide, Sans contact)
    // Indicateurs ✓
    const featureY = qrContainerY + qrContainerHeight + 80
    
    // Premier indicateur
    // ctx.beginPath()
    // ctx.arc(width/2 - 50, featureY, 10, 0, Math.PI * 2)
    // ctx.fillStyle = '#ff6b35'
    // ctx.fill()
    
    // ctx.fillStyle = '#FFFFFF'
    // ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    // ctx.fillText('✓', width/2 - 50, featureY + 4)
    
    // ctx.fillStyle = '#86868b'
    // ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    // ctx.fillText('Rapide', width/2 - 20, featureY + 4)
    
    // // Deuxième indicateur
    // ctx.beginPath()
    // ctx.arc(width/2 + 40, featureY, 10, 0, Math.PI * 2)
    // ctx.fillStyle = '#ff6b35'
    // ctx.fill()
    
    // ctx.fillStyle = '#FFFFFF'
    // ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    // ctx.fillText('✓', width/2 + 40, featureY + 4)
    
    // ctx.fillStyle = '#86868b'
    // ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    // ctx.fillText('Sans contact', width/2 + 90, featureY + 4)
    
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
    ctx.fillStyle = '#f91919'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Par Kula Qr', width/2 + 10, footerY + 4)
    
    // Télécharger l'image générée
    const dataURL = tempCanvas.toDataURL('image/png')
    const link = document.createElement('a')
    link.download = `qr-code-${table.number}-de-${establishment.value?.name || ''}-${new Date().toISOString().split('T')[0]}.png`
    link.href = dataURL
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    showToast.success('Téléchargé', 'Carte QR téléchargée avec succès')
    
  } catch (error) {
    console.error('Erreur de téléchargement:', error)
    // Fallback au téléchargement direct du QR code
    // downloadQrCodeFallback()
  }
}

const refreshData = () => {
  loadTables()
}

const showQrCodeCard = (table: any) => {
  selectedTableForQr.value = table
  showQrModal.value = true
}



// Initialize
onMounted(async () => {
  await fetchEstablishmentByUserId()
  if (establishment.value) {
    loadTables()
  }
})
</script>
