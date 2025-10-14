<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Tables</h1>
      <p class="text-lg text-gray-600">Gérez les tables de votre établissement</p>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
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
            <p class="text-sm font-medium text-gray-600">Occupées</p>
            <p class="text-2xl font-bold text-orange-600">{{ occupiedTables }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center">
            <Users class="w-6 h-6 text-orange-500" />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Disponibles</p>
            <p class="text-2xl font-bold text-green-600">{{ availableTables }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
            <CheckCircle class="w-6 h-6 text-green-500" />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Commandes Actives</p>
            <p class="text-2xl font-bold text-purple-600">{{ activeOrders }}</p>
          </div>
          <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
            <ShoppingCart class="w-6 h-6 text-purple-500" />
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
              getTableStatusColor(table.status).bg,
              'w-12 h-12 rounded-2xl flex items-center justify-center'
            ]">
              <Table class="w-6 h-6" :class="getTableStatusColor(table.status).text" />
            </div>
            <div>
              <h3 class="text-lg font-bold text-gray-900">Table {{ table.number }}</h3>
              <p class="text-sm text-gray-500">{{ table.capacity }} places</p>
            </div>
          </div>
          
          <div class="flex items-center gap-2">
            <span :class="[
              getTableStatusColor(table.status).badge,
              'px-3 py-1 rounded-full text-xs font-semibold'
            ]">
              {{ getTableStatusText(table.status) }}
            </span>
          </div>
        </div>

        <!-- Table Info -->
        <div class="space-y-2 mb-4">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Zone:</span>
            <span class="font-medium">{{ table.zone || 'Non définie' }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">QR Code:</span>
            <span class="font-medium">{{ table.qr_code_generated ? 'Généré' : 'Non généré' }}</span>
          </div>
          <div v-if="table.current_order" class="flex justify-between text-sm">
            <span class="text-gray-500">Commande:</span>
            <span class="font-medium text-orange-600">#{{ table.current_order }}</span>
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
            @click="generateQrCode(table)"
            class="flex-1 px-3 py-2 bg-blue-100 text-blue-700 rounded-xl text-sm font-medium hover:bg-blue-200 transition-colors"
          >
            QR Code
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
              <label class="block text-sm font-medium text-gray-700 mb-2">Capacité</label>
              <input
                v-model="tableForm.capacity"
                type="number"
                required
                class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                placeholder="Ex: 2, 4, 6..."
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Zone</label>
            <input
              v-model="tableForm.zone"
              type="text"
              class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
              placeholder="Ex: Terrasse, Intérieur, VIP..."
            />
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

          <div class="flex items-center gap-4">
            <label class="flex items-center gap-2">
              <input
                v-model="tableForm.is_active"
                type="checkbox"
                class="w-4 h-4 text-black border-gray-300 rounded focus:ring-black"
              />
              <span class="text-sm font-medium text-gray-700">Table active</span>
            </label>
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
  RefreshCw, Loader2, Trash2, X 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const { establishment, fetchEstablishmentFromRoute } = useEstablishment()

// State
const loading = ref(false)
const tables = ref<any[]>([])
const searchQuery = ref('')
const showTableModal = ref(false)
const editingTable = ref<any>(null)

// Form
const tableForm = ref({
  number: '',
  capacity: '',
  zone: '',
  description: '',
  is_active: true
})

// Computed
const filteredTables = computed(() => {
  if (!searchQuery.value) return tables.value
  
  return tables.value.filter(table => 
    table.number.toString().includes(searchQuery.value) ||
    (table.zone && table.zone.toLowerCase().includes(searchQuery.value.toLowerCase()))
  )
})

const occupiedTables = computed(() => 
  tables.value.filter(table => table.status === 'occupied').length
)

const availableTables = computed(() => 
  tables.value.filter(table => table.status === 'available').length
)

const activeOrders = computed(() => 
  tables.value.filter(table => table.current_order).length
)

// Load tables
const loadTables = async () => {
  if (!establishment.value) return
  
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('tables')
      .select(`
        *,
        orders!current_order_id(
          id,
          status,
          total_amount
        )
      `)
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
    capacity: '',
    zone: '',
    description: '',
    is_active: true
  }
  showTableModal.value = true
}

const editTable = (table: any) => {
  editingTable.value = table
  tableForm.value = {
    number: table.number,
    capacity: table.capacity,
    zone: table.zone || '',
    description: table.description || '',
    is_active: table.is_active
  }
  showTableModal.value = true
}

const closeTableModal = () => {
  showTableModal.value = false
  editingTable.value = null
  tableForm.value = {
    number: '',
    capacity: '',
    zone: '',
    description: '',
    is_active: true
  }
}

const saveTable = async () => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    const tableData = {
      number: parseInt(tableForm.value.number),
      capacity: parseInt(tableForm.value.capacity),
      zone: tableForm.value.zone,
      description: tableForm.value.description,
      is_active: tableForm.value.is_active,
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

const generateQrCode = (table: any) => {
  showToast.info('Fonctionnalité à venir', 'La génération de QR code par table sera disponible prochainement')
}

const refreshData = () => {
  loadTables()
}

// Utility functions
const getTableStatusColor = (status: string) => {
  switch (status) {
    case 'occupied':
      return {
        bg: 'bg-orange-50',
        text: 'text-orange-500',
        badge: 'bg-orange-100 text-orange-700'
      }
    case 'reserved':
      return {
        bg: 'bg-yellow-50',
        text: 'text-yellow-500',
        badge: 'bg-yellow-100 text-yellow-700'
      }
    case 'maintenance':
      return {
        bg: 'bg-red-50',
        text: 'text-red-500',
        badge: 'bg-red-100 text-red-700'
      }
    default:
      return {
        bg: 'bg-green-50',
        text: 'text-green-500',
        badge: 'bg-green-100 text-green-700'
      }
  }
}

const getTableStatusText = (status: string) => {
  switch (status) {
    case 'occupied': return 'Occupée'
    case 'reserved': return 'Réservée'
    case 'maintenance': return 'Maintenance'
    default: return 'Disponible'
  }
}

// Initialize
onMounted(async () => {
  await fetchEstablishmentFromRoute()
  if (establishment.value) {
    loadTables()
  }
})
</script>
