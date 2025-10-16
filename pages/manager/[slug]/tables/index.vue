<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Tables</h1>
      <p class="text-lg text-gray-600">Gérez les tables de votre établissement</p>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Total Tables</p>
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
            <p class="text-sm font-medium text-gray-600">Tables VIP</p>
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
    </div>

    <!-- Actions Bar -->
    <div class="bg-white rounded-2xl border border-gray-200 p-6 mb-8">
      <div class="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
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
            Nouvelle Table
          </button>
        </div>
      </div>
    </div>

    <!-- Tables Grid -->
    <div v-if="loading" class="flex justify-center py-12">
      <Loader2 class="w-8 h-8 animate-spin text-gray-400" />
    </div>

    <div v-else-if="filteredTables.length === 0" class="text-center py-16">
      <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <Table class="w-12 h-12 text-gray-400" />
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune table trouvée</h3>
      <p class="text-gray-600 mb-6">
        {{ searchQuery ? 'Aucune table ne correspond à votre recherche' : 'Commencez par créer votre première table' }}
      </p>
      <button
        v-if="!searchQuery"
        @click="openTableModal"
        class="px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 transition-colors"
      >
        Créer une table
      </button>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div
        v-for="table in filteredTables"
        :key="table.id"
        class="bg-white rounded-2xl border border-gray-200 p-6 hover:shadow-lg transition-all duration-200"
      >
        <!-- Table Header -->
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <div :class="[
              table.type === 'VIP' ? 'bg-purple-50' : 'bg-blue-50',
              'w-12 h-12 rounded-2xl flex items-center justify-center'
            ]">
              <Table class="w-6 h-6" :class="table.type === 'VIP' ? 'text-purple-500' : 'text-blue-500'" />
            </div>
            <div>
              <h3 class="text-lg font-bold text-gray-900">Table {{ table.number }}</h3>
              <p class="text-sm text-gray-500">{{ table.type }} • {{ table.zone }}</p>
            </div>
          </div>
          
          <div class="flex items-center gap-2">
            <span :class="[
              table.qr_code_generated ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700',
              'px-3 py-1 rounded-full text-xs font-semibold'
            ]">
              {{ table.qr_code_generated ? 'QR Généré' : 'Pas de QR' }}
            </span>
          </div>
        </div>

        <!-- Table Info -->
        <div class="space-y-2 mb-4">
          <div v-if="table.description" class="text-sm text-gray-600">
            {{ table.description }}
          </div>
          <div v-if="table.qr_code_url" class="text-xs text-blue-600 font-mono bg-blue-50 p-2 rounded">
            {{ table.qr_code_url }}
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-2">
          <button
            @click="editTable(table)"
            class="flex-1 px-3 py-2 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-200 transition-colors"
          >
            Modifier
          </button>
          <button
            v-if="!table.qr_code_generated"
            @click="generateQrCode(table)"
            class="flex-1 px-3 py-2 bg-blue-100 text-blue-700 rounded-xl text-sm font-medium hover:bg-blue-200 transition-colors"
          >
            Générer QR
          </button>
          <button
            v-else
            @click="downloadQrCode(table)"
            class="flex-1 px-3 py-2 bg-green-100 text-green-700 rounded-xl text-sm font-medium hover:bg-green-200 transition-colors flex items-center justify-center gap-1"
          >
            <Download class="w-4 h-4" />
            Télécharger
          </button>
          <button
            @click="deleteTable(table.id)"
            class="px-3 py-2 bg-red-100 text-red-700 rounded-xl text-sm font-medium hover:bg-red-200 transition-colors"
          >
            <Trash2 class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>

    <!-- Table Modal -->
    <UModal v-model="showTableModal" size="lg">
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

        <form @submit.prevent="saveTable" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Numéro de table</label>
              <input
                v-model="tableForm.number"
                type="number"
                required
                class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                placeholder="Ex: 1, 2, 3..."
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Type</label>
              <select
                v-model="tableForm.type"
                class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
              >
                <option value="SIMPLE">SIMPLE</option>
                <option value="VIP">VIP</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Zone</label>
            <select
              v-model="tableForm.zone"
              class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
            >
              <option value="ETAGE">ETAGE</option>
              <option value="TERRASSE">TERRASSE</option>
              <option value="REZ_DE_CHAUSSEE">REZ DE CHAUSSEE</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea
              v-model="tableForm.description"
              rows="3"
              class="w-full px-4 py-3 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
              placeholder="Description de la table..."
            />
          </div>

          <div class="flex gap-3 pt-4">
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Table, Users, CheckCircle, ShoppingCart, Plus, Search, 
  RefreshCw, Loader2, Trash2, X, QrCode, Download 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'

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

const saveTable = async () => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    const tableData = {
      number: parseInt(tableForm.value.number),
      type: tableForm.value.type,
      zone: tableForm.value.zone,
      description: tableForm.value.description,
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

const generateQrCode = async (table: any) => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    // Générer l'URL du menu pour cette table spécifique
    const tableMenuUrl = `${window.location.origin}/menu/${establishment.value.id}?table=${table.number}`
    
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

const downloadQrCode = (table: any) => {
  if (!table.qr_code_url) {
    showToast.error('Erreur', 'Aucun QR code disponible pour cette table')
    return
  }
  
  // Ouvrir l'URL dans un nouvel onglet pour téléchargement/impression
  window.open(table.qr_code_url, '_blank')
  showToast.success('Ouverture', 'QR code ouvert dans un nouvel onglet')
}

const refreshData = () => {
  loadTables()
}

// Initialize
onMounted(async () => {
  await fetchEstablishmentByUserId()
  if (establishment.value) {
    loadTables()
  }
})
</script>
