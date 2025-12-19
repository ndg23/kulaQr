<template>
  <div class="space-y-4">
    <!-- Filters Bar -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 p-4 bg-white rounded-xl border border-gray-200">
      <div class="flex flex-col sm:flex-row sm:items-center gap-3">
        <div class="relative">
          <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher un établissement..."
            class="pl-10 pr-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent w-full sm:w-64"
          />
        </div>
        
        <select
          v-model="selectedType"
          class="px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="">Tous les types</option>
          <option value="restaurant">Restaurant</option>
          <option value="cafe">Café</option>
          <option value="bar">Bar</option>
          <option value="hotel">Hôtel</option>
          <option value="fast_food">Fast Food</option>
          <option value="bakery">Boulangerie</option>
          <option value="food_truck">Food Truck</option>
          <option value="other">Autre</option>
        </select>

        <select
          v-model="selectedStatus"
          class="px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="">Tous les statuts</option>
          <option value="active">Actifs</option>
          <option value="inactive">Inactifs</option>
        </select>
      </div>

      <div class="flex items-center gap-2">
        <span class="text-sm text-gray-600">{{ filteredEstablishments.length }} établissement(s)</span>
        <button
          @click="refreshEstablishments"
          class="p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
          title="Actualiser"
        >
          <RefreshCw class="w-4 h-4" />
        </button>
        <button
          @click="createEstablishment"
          class="px-3 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors flex items-center gap-2"
        >
          <Plus class="w-4 h-4" />
          Nouveau
        </button>
      </div>
    </div>

    <!-- Establishments List -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div class="divide-y divide-gray-200">
        <div
          v-for="establishment in paginatedEstablishments"
          :key="establishment.id"
          class="p-4 hover:bg-gray-50 transition-colors"
        >
          <div class="flex items-center justify-between">
            <!-- Establishment Info -->
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 bg-gradient-to-br from-orange-500 to-red-600 rounded-xl flex items-center justify-center text-white font-semibold">
                <Store class="w-6 h-6" />
              </div>
              
              <div>
                <div class="flex items-center gap-2">
                  <h3 class="font-semibold text-gray-900">{{ establishment.name }}</h3>
                  <span :class="getTypeBadgeClass(establishment.establishment_type)" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium">
                    {{ getTypeLabel(establishment.establishment_type) }}
                  </span>
                  <span :class="getStatusBadgeClass(establishment.is_active)" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium">
                    {{ establishment.is_active ? 'Actif' : 'Inactif' }}
                  </span>
                </div>
                
                <div class="flex items-center gap-4 mt-1 text-sm text-gray-600">
                  <span class="flex items-center gap-1">
                    <MapPin class="w-3 h-3" />
                    {{ establishment.address }}
                  </span>
                  
                  <span v-if="establishment.users" class="flex items-center gap-1">
                    <Crown class="w-3 h-3" />
                    {{ establishment.users.full_name }}
                  </span>
                  
                  <span v-if="establishment.phone" class="flex items-center gap-1">
                    <Phone class="w-3 h-3" />
                    {{ establishment.phone }}
                  </span>
                  
                  <span v-if="establishment.qr_enabled" class="flex items-center gap-1 text-green-600">
                    <QrCode class="w-3 h-3" />
                    QR Activé
                  </span>
                </div>
              </div>
            </div>

            <!-- Actions Dropdown -->
            <ActionDropdown
              :actions="getEstablishmentActions(establishment)"
              @action="handleEstablishmentAction"
            />
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="filteredEstablishments.length === 0" class="p-8 text-center">
          <Store class="w-12 h-12 mx-auto text-gray-300 mb-3" />
          <p class="text-gray-500">Aucun établissement trouvé</p>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="border-t border-gray-200 px-4 py-3 flex items-center justify-between">
        <div class="text-sm text-gray-700">
          Page {{ currentPage }} sur {{ totalPages }}
        </div>
        <div class="flex items-center gap-2">
          <button
            @click="currentPage--"
            :disabled="currentPage === 1"
            class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Précédent
          </button>
          <button
            @click="currentPage++"
            :disabled="currentPage === totalPages"
            class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <EstablishmentFormModal
      :open="showEstablishmentModal"
      :mode="modalMode"
      :establishment="selectedEstablishment"
      @close="showEstablishmentModal = false"
      @success="handleModalSuccess"
    />

    <StaffManagementModal
      :open="showStaffModal"
      :establishment="selectedEstablishment"
      @close="showStaffModal = false"
      @success="handleModalSuccess"
    />

    <EstablishmentAssignmentModal
      :open="assignmentModal.modalOpen.value"
      :mode="assignmentModal.modalOptions.value.mode"
      :establishment="assignmentModal.modalOptions.value.establishment"
      @close="assignmentModal.closeModal"
      @success="handleEstablishmentAssignmentSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Search, RefreshCw, Store, Plus, Edit, Users, 
  ArrowRightLeft, QrCode, Ban, CheckCircle, 
  Trash2, MapPin, Crown, Phone
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import EstablishmentAssignmentModal from '~/components/admin/EstablishmentAssignmentModal.vue'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

const loading = ref(false)
const establishments = ref<any[]>([])
const searchQuery = ref('')
const selectedType = ref('')
const selectedStatus = ref('')
const currentPage = ref(1)
const itemsPerPage = 10

// Modals
const showEstablishmentModal = ref(false)
const showStaffModal = ref(false)
import { useEstablishmentAssignment } from '~/composables/useEstablishmentAssignment'
const assignmentModal = useEstablishmentAssignment()
const selectedEstablishment = ref<any>(null)
const modalMode = ref<'create' | 'edit'>('create')

// Computed
const filteredEstablishments = computed(() => {
  let filtered = establishments.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(est => 
      est.name?.toLowerCase().includes(query) ||
      est.address?.toLowerCase().includes(query) ||
      est.users?.full_name?.toLowerCase().includes(query)
    )
  }

  if (selectedType.value) {
    filtered = filtered.filter(est => est.establishment_type === selectedType.value)
  }

  if (selectedStatus.value) {
    const isActive = selectedStatus.value === 'active'
    filtered = filtered.filter(est => est.is_active === isActive)
  }

  return filtered
})

const totalPages = computed(() => Math.ceil(filteredEstablishments.value.length / itemsPerPage))

const paginatedEstablishments = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredEstablishments.value.slice(start, end)
})

// Load establishments
const loadEstablishments = async () => {
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('establishments')
      .select(`
        *,
        users (
          id,
          full_name,
          email
        )
      `)
      .order('created_at', { ascending: false })

    if (error) throw error
    establishments.value = data || []
  } catch (err) {
    console.error('Error loading establishments:', err)
    showToast.error('Erreur lors du chargement des établissements')
  } finally {
    loading.value = false
  }
}

// Get establishment actions
const getEstablishmentActions = (establishment: any) => {
  const actions = [
    {
      id: 'edit',
      label: 'Modifier',
      icon: Edit,
      variant: 'primary' as const,
      callback: () => editEstablishment(establishment)
    },
    {
      id: 'staff',
      label: 'Gérer Personnel',
      icon: Users,
      variant: 'primary' as const,
      callback: () => manageStaff(establishment)
    },
    {
      id: 'transfer',
      label: 'Transférer Propriété',
      icon: ArrowRightLeft,
      variant: 'secondary' as const,
      callback: () => transferEstablishment(establishment)
    },
    {
      id: 'qr',
      label: establishment.qr_enabled ? 'Désactiver QR' : 'Activer QR',
      icon: QrCode,
      variant: 'secondary' as const,
      callback: () => toggleQR(establishment)
    }
  ]

  // Add status-specific actions
  if (establishment.is_active) {
    actions.push({
      id: 'deactivate',
      label: 'Désactiver',
      icon: Ban,
      variant: 'danger' as const,
      callback: () => deactivateEstablishment(establishment)
    })
  } else {
    actions.push({
      id: 'activate',
      label: 'Activer',
      icon: CheckCircle,
      variant: 'primary' as const,
      callback: () => activateEstablishment(establishment)
    })
  }

  actions.push({
    id: 'delete',
    label: 'Supprimer',
    icon: Trash2,
    variant: 'danger' as const,
    callback: () => deleteEstablishment(establishment)
  })

  return actions
}

// Action handlers
const createEstablishment = () => {
  selectedEstablishment.value = null
  modalMode.value = 'create'
  showEstablishmentModal.value = true
}

const editEstablishment = (establishment: any) => {
  selectedEstablishment.value = establishment
  modalMode.value = 'edit'
  showEstablishmentModal.value = true
}

const manageStaff = (establishment: any) => {
  selectedEstablishment.value = establishment
  showStaffModal.value = true
}

const transferEstablishment = (establishment: any) => {
  assignmentModal.transferEstablishment(establishment)
}

const toggleQR = async (establishment: any) => {
  try {
    const newQrStatus = !establishment.qr_enabled
    
    const { error } = await supabase
      .from('establishments')
      .update({ qr_enabled: newQrStatus })
      .eq('id', establishment.id)

    if (error) throw error

    showToast.success(`QR Code ${newQrStatus ? 'activé' : 'désactivé'} avec succès`)
    await loadEstablishments()
  } catch (err) {
    console.error('Error toggling QR:', err)
    showToast.error('Erreur lors de la modification du QR')
  }
}

const activateEstablishment = async (establishment: any) => {
  try {
    const { error } = await supabase
      .from('establishments')
      .update({ is_active: true })
      .eq('id', establishment.id)

    if (error) throw error

    showToast.success('Établissement activé avec succès')
    await loadEstablishments()
  } catch (err) {
    console.error('Error activating establishment:', err)
    showToast.error('Erreur lors de l\'activation')
  }
}

const deactivateEstablishment = async (establishment: any) => {
  if (!confirm(`Désactiver l'établissement ${establishment.name} ?`)) return

  try {
    const { error } = await supabase
      .from('establishments')
      .update({ is_active: false })
      .eq('id', establishment.id)

    if (error) throw error

    showToast.success('Établissement désactivé avec succès')
    await loadEstablishments()
  } catch (err) {
    console.error('Error deactivating establishment:', err)
    showToast.error('Erreur lors de la désactivation')
  }
}

const deleteEstablishment = async (establishment: any) => {
  if (!confirm(`Supprimer définitivement l'établissement ${establishment.name} ?\nCette action est irréversible.`)) return

  try {
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', establishment.id)

    if (error) throw error

    showToast.success('Établissement supprimé avec succès')
    await loadEstablishments()
  } catch (err) {
    console.error('Error deleting establishment:', err)
    showToast.error('Erreur lors de la suppression')
  }
}

// Handle action from dropdown
const handleEstablishmentAction = (action: any) => {
  // Actions are handled by their callbacks
}

// Handle modal success
const handleModalSuccess = () => {
  loadEstablishments()
}

const handleEstablishmentAssignmentSuccess = () => {
  assignmentModal.onSuccess()
  loadEstablishments()
}

// Refresh establishments
const refreshEstablishments = () => {
  loadEstablishments()
}

// Helper functions
const getTypeLabel = (type: string) => {
  const typeMap = {
    restaurant: 'Restaurant',
    cafe: 'Café',
    bar: 'Bar',
    hotel: 'Hôtel',
    fast_food: 'Fast Food',
    bakery: 'Boulangerie',
    food_truck: 'Food Truck',
    other: 'Autre'
  }
  return typeMap[type] || type
}

const getTypeBadgeClass = (type: string) => {
  const classMap = {
    restaurant: 'bg-orange-100 text-orange-800',
    cafe: 'bg-amber-100 text-amber-800',
    bar: 'bg-purple-100 text-purple-800',
    hotel: 'bg-blue-100 text-blue-800',
    fast_food: 'bg-red-100 text-red-800',
    bakery: 'bg-yellow-100 text-yellow-800',
    food_truck: 'bg-green-100 text-green-800',
    other: 'bg-gray-100 text-gray-800'
  }
  return classMap[type] || 'bg-gray-100 text-gray-800'
}

const getStatusBadgeClass = (isActive: boolean) => {
  return isActive 
    ? 'bg-green-100 text-green-800' 
    : 'bg-red-100 text-red-800'
}

// Load data on mount
onMounted(() => {
  loadEstablishments()
})
</script>