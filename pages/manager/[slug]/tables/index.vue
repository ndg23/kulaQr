<template>
  <div>
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Emplacements</h1>
      <p class="text-lg text-gray-600">Gérez les emplacements de votre établissement</p>
    </div>

   
    <!-- Actions Bar -->
    <div class="bg-white rounded-2xl border border-gray-200 p-6 mb-8">
      <div class="flex gap-4 items-start sm:items-center justify-between flex-wrap p-3 md:p-0">
        <div class="flex items-center gap-4">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher un emplacement..."
              class="pl-10 pr-4 py-3 w-full sm:w-80 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
            />
          </div>
        </div>
        
        <div class="flex gap-3 flex-wrap">
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
            Nouvel emplacement
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
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun emplacement trouvé</h3>
      <p class="text-gray-600 mb-6">
        {{ searchQuery ? 'Aucun emplacement ne correspond à votre recherche' : 'Commencez par créer votre premier emplacement' }}
      </p>
      <button
        v-if="!searchQuery"
        @click="openTableModal"
        class="px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-colors"
      >
        Créer un emplacement  
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
              <h3 class="text-xl font-bold text-gray-900 mb-1">N° : {{ table.table_number || table.number }}</h3>
              <div class="flex items-center gap-2">
                <span :class="[
                  table.type === 'VIP' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700',
                  'px-2 py-1 rounded-lg text-xs font-medium'
                ]">
                  {{ table.type || 'STANDARD' }}
                </span>
                <!-- <span class="text-sm text-gray-500">{{ table.section_name || table.zone }}</span>
                <span v-if="table.floor_level" class="text-sm text-gray-500">• {{ table.floor_level }}</span> -->
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
          <strong v-if="table.location_description || table.section_name || table.floor_level">📍 Localisation:</strong>
          <span v-if="table.location_description">{{ table.location_description }}</span>
          <span v-else-if="table.section_name || table.floor_level">
            {{ table.section_name || 'Section non spécifiée' }}
            {{ table.floor_level ? `• ${table.floor_level}` : '' }}
          </span>
          <span v-else>{{ table.description || 'Aucune description fournie pour cette table.' }}</span>
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
             Menu
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
import { encodeTableHashids } from '~/utils/secure-encoding'
// import jsPDF from 'jspdf'

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


// Computed
const filteredTables = computed(() => {
  if (!searchQuery.value) return tables.value
  
  return tables.value.filter(table => 
    String(table.table_number ?? table.number ?? '').includes(searchQuery.value) ||
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
      .order('created_at', { ascending: false })

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
 return navigateTo(`${table.qr_code_url}`, { external: true })
  // showToast.success('Ouverture', 'Menu ouvert dans un nouvel onglet')
}

// Chaque action a sa page
const openTableModal = () => navigateTo(`/manager/${establishment.value?.id}/tables/new`)

const editTable = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/edit`)

const generateQrCode = async (table: any) => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    // Encoder le numéro de table pour le cacher
    const encodedTableNumber = encodeTableHashids(parseInt(table.table_number ?? table.number, 10), establishment.value.id)
    
    // Générer l'URL du menu pour cette table spécifique avec le numéro encodé
    const tableMenuUrl = `${window.location.origin}/qr/${establishment.value.id}?q=${encodedTableNumber}`
    
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
    
    showToast.success('QR Code généré', `QR code généré pour la table ${table.table_number ?? table.number}`)
  } catch (err) {
    console.error('Error generating QR code:', err)
    showToast.error('Erreur', 'Impossible de générer le QR code')
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


const downloadQrCodes = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/qr`)

const showQrCodeCard = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/qr`)

// Initialize
onMounted(async () => {
  await fetchEstablishmentByUserId()
  if (establishment.value) {
    loadTables()
  }
})
</script>
