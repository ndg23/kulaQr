<template>
  <div class="py-4 sm:py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="mb-6 sm:mb-8">
      <h1 class="text-2xl sm:text-3xl font-semibold text-gray-900 mb-2">Établissements</h1>
      <p class="text-sm sm:text-base text-gray-600">Gérez les établissements et leurs propriétaires</p>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 mb-8 sm:mb-10">
      <div v-for="stat in statsDisplay" :key="stat.name" 
        class="bg-white p-4 sm:p-6 rounded-xl sm:rounded-2xl border border-gray-100 hover:border-gray-200 transition-colors"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">{{ stat.name }}</p>
            <h3 class="text-3xl sm:text-4xl font-black text-gray-900">{{ stat.value }}</h3>
          </div>
          <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-gray-50 flex items-center justify-center">
            <component :is="stat.icon" class="w-5 h-5 sm:w-6 sm:h-6 text-gray-700" />
          </div>
        </div>
      </div>
    </div>

    <!-- Establishments List with DataTable -->
    <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
      <!-- Mobile Header - visible seulement sur mobile -->
      <div class="md:hidden px-4 py-3 bg-gray-50 border-b border-gray-100">
        <div class="flex items-center justify-between">
          <h3 class="font-semibold text-gray-900">Établissements</h3>
          <button
            @click="handleAction('add')"
            class="px-3 py-1.5 bg-black text-white text-sm font-medium rounded-lg hover:bg-gray-800 transition-colors"
          >
            Ajouter
          </button>
        </div>
      </div>
      
      <!-- Responsive table wrapper -->
      <div class="overflow-x-auto">
        <DataTable
          :items="restaurants"
          :columns="tableColumns"
          :loading="loading"
          :current-page="currentPage"
          :per-page="perPage"
          :total-items="filteredRestaurants.length"
          :show-pagination="true"
          :header-buttons="[
            { label: 'Ajouter', icon: 'Plus', variant: 'primary', action: 'add' }
          ]"
          empty-title="Aucun établissement trouvé"
          empty-description="Commencez par créer votre premier établissement"
          empty-icon="fas fa-store"
          @page-change="currentPage = $event"
          @update:per-page="perPage = $event"
          @button-click="handleAction"
          class="min-w-[800px]"
        >
      <!-- Restaurant Name Column -->
      <template #cell-name="{ item }">
        <NuxtLink 
          :to="`/admin/establishments/${item.id}`"
          class="flex items-center gap-2 sm:gap-3 max-w-[240px] sm:max-w-[280px] group"
        >
          <div class="h-9 w-9 sm:h-11 sm:w-11 rounded-xl bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform">
            <Store class="w-4 h-4 sm:w-5 sm:h-5 text-white" />
          </div>
          <div class="min-w-0 flex-1">
            <div class="font-semibold text-gray-900 text-sm sm:text-base truncate group-hover:text-orange-600 transition-colors">{{ item.name }}</div>
            <div class="text-xs sm:text-sm text-gray-500 truncate hidden sm:block">{{ item.address || 'Adresse non définie' }}</div>
          </div>
        </NuxtLink>
      </template>

      <!-- Type Column -->
      <template #cell-type_name="{ item }">
        <div class="max-w-[100px] sm:max-w-[120px]">
          <span
            class="px-2 sm:px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap"
            :class="getTypeBadgeClass(item.type_name)"
          >
            {{ formatType(item.type_name) }}
          </span>
        </div>
      </template>

      <!-- Owner Column -->
      <template #cell-owner_name="{ item }">
        <div class="flex items-center gap-2 max-w-[150px] sm:max-w-[180px]">
          <div class="h-7 w-7 sm:h-8 sm:w-8 rounded-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center flex-shrink-0">
            <span class="text-xs font-semibold text-gray-700">{{ getInitials(item.owner_name) }}</span>
          </div>
          <span class="text-xs sm:text-sm font-medium text-gray-700 truncate">{{ item.owner_name }}</span>
        </div>
      </template>

      <!-- Subscription Column -->
      <!-- <template #cell-subscription_type="{ item }">
        <div class="max-w-[100px]">
          <span
            class="px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap"
            :class="getSubscriptionBadgeClass(item.subscription_type)"
          >
            {{ getSubscriptionLabel(item.subscription_type) }}
          </span>
        </div>
      </template> -->

      <!-- Status Column -->
      <template #cell-is_active="{ item }">
        <div class="max-w-[80px] sm:max-w-[100px]">
          <span
            class="px-2 sm:px-3 py-1 rounded-full text-xs font-medium inline-flex items-center whitespace-nowrap"
            :class="item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
          >
            <div 
              class="w-1.5 h-1.5 rounded-full mr-1 sm:mr-1.5 flex-shrink-0"
              :class="item.is_active ? 'bg-green-500' : 'bg-red-500'"
            />
            <span class="hidden sm:inline">{{ item.is_active ? 'Actif' : 'Inactif' }}</span>
            <span class="sm:hidden">{{ item.is_active ? 'ON' : 'OFF' }}</span>
          </span>
        </div>
      </template>

      <!-- Currency Column -->
      <template #cell-currency="{ item }">
        <div class="max-w-[80px]">
          <span class="text-sm font-medium text-gray-700">{{ item.currency || 'XOF' }}</span>
        </div>
      </template>

      <!-- Max Categories Column -->
      <!-- <template #cell-max_categories="{ item }">
        <div class="text-center max-w-[80px]">
          <span class="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-medium whitespace-nowrap">
            {{ item.max_categories }}
          </span>
        </div>
      </template> -->

      <!-- Max Products Column -->
      <!-- <template #cell-max_products="{ item }">
        <div class="text-center max-w-[80px]">
          <span class="px-2 py-1 bg-purple-50 text-purple-700 rounded text-xs font-medium whitespace-nowrap">
            {{ item.max_products }}
          </span>
        </div>
      </template> -->

      <!-- Actions Column -->
      <template #cell-actions="{ item }">
        <div class="max-w-[100px] sm:max-w-[120px]">
          <ActionDropdown
            :actions="getEstablishmentActions(item)"
            @action="handleEstablishmentAction"
            trigger-text="Actions"
            class="text-sm"
          />
        </div>
      </template>
        </DataTable>
      </div>
    </div>
  </div>
    <!-- Restaurant Modal -->
    <RestaurantFormModal
      v-if="showRestaurantModal"
      :open="showRestaurantModal"
      :restaurant="selectedRestaurant"
      @close="closeRestaurantModal"
      @submit="handleRestaurantSubmitted"
    />

    <!-- Staff Management Modal -->
    <StaffManagementModal
      :open="showStaffModal"
      :establishment="selectedRestaurant"
      @close="showStaffModal = false"
      @success="handleModalSuccess"
    />

    <!-- Establishment Assignment Modal -->
    <EstablishmentAssignmentModal
      :open="assignmentModal.modalOpen.value"
      :mode="assignmentModal.modalOptions.value.mode"
      :establishment="assignmentModal.modalOptions.value.establishment"
      @close="assignmentModal.closeModal"
      @success="handleEstablishmentAssignmentSuccess"
    />

    <!-- QR Code Modal -->
    <TransitionRoot appear :show="showQrModal" as="template">
      <Dialog as="div" @close="closeQrModal" class="relative z-50">
        <!-- Overlay -->
        <TransitionChild
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
        </TransitionChild>

        <!-- Modal -->
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
                <div class="relative">
                  <!-- Header avec le nom du restaurant -->
                  <div class="bg-gray-50 px-6 py-4 text-center">
                    <DialogTitle as="h3" class="text-xl font-semibold text-gray-900">
                      {{ selectedRestaurant?.name }}
                    </DialogTitle>
                    <p class="mt-1 text-sm text-gray-500">
                      Scanner ce QR code pour accéder au menu
                    </p>
                  </div>
                  
                  <!-- QR Code -->
                  <div class="flex justify-center p-8 bg-white">
                    <div class="p-4 bg-white rounded-2xl shadow-sm border border-gray-100">
                      <QRCodeVue3
                        v-if="qrCodeUrl"
                        :value="qrCodeUrl"
                        :size="240"
                        level="H"
                        :margin="2"
                        class="rounded-xl overflow-hidden"
                        :dotsOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :cornersSquareOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :cornersDotOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :backgroundOptions="{ 
                          color: '#FFFFFF' 
                        }"
                      />
                    </div>
                  </div>
                  
                  <!-- URL -->
                  <div class="px-6 pb-4 text-center">
                    <p class="text-sm font-medium text-gray-700 mb-2">URL du menu</p>
                    <div class="flex items-center justify-center space-x-2">
                      <input
                        type="text"
                        readonly
                        :value="qrCodeUrl"
                        class="flex-1 px-3 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg"
                      />
                      <button
                        @click="copyToClipboard(qrCodeUrl)"
                        class="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100"
                        title="Copier l'URL"
                      >
                        <ClipboardCopy class="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                  
                  <!-- Actions -->
                  <div class="border-t border-gray-100 px-6 py-4 bg-gray-50 flex justify-between">
                    <button
                      @click="downloadQrCode"
                      class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
                    >
                      <Download class="w-4 h-4 mr-2" />
                      Télécharger
                    </button>
                    <button
                      @click="printQrCode"
                      class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-black rounded-lg hover:bg-gray-800"
                    >
                      <Printer class="w-4 h-4 mr-2" />
                      Imprimer
                    </button>
                  </div>
                  
                  <!-- Bouton de fermeture -->
                  <button
                    @click="closeQrModal"
                    class="absolute top-4 right-4 text-gray-400 hover:text-gray-500"
                  >
                    <X class="w-5 h-5" />
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { 
  Store, User, Users, Search, Plus, Edit, Trash2, 
  RefreshCw, X, CheckCircle, AlertTriangle, Loader2, 
  UtensilsCrossed, Coffee, Pizza, Utensils, Building, Shield, ClipboardCopy, Download, Printer,
  Hotel, Wine, CakeSlice, ArrowRightLeft, QrCode, Ban
} from 'lucide-vue-next'
import { 
  TransitionRoot, TransitionChild, Dialog, DialogPanel, DialogTitle, Switch 
} from '@headlessui/vue'
import QRCodeVue3 from 'qrcode-vue3'
import html2canvas from 'html2canvas'
import RestaurantFormModal from '~/components/admin/RestaurantFormModal.vue'
import ActionDropdown from '~/components/admin/ActionDropdown.vue'
import StaffManagementModal from '~/components/admin/StaffManagementModal.vue'
import EstablishmentAssignmentModal from '~/components/admin/EstablishmentAssignmentModal.vue'
import { useEstablishmentAssignment } from '~/composables/useEstablishmentAssignment'

// Supabase client
const {client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()

// State
const restaurants = ref<any[]>([])
const users = ref<any[]>([])
const loading = ref(false)
const stats = ref({
  total: 0,
  active: 0,
  subscriptions: {} as Record<string, number>
})

// Pagination
const currentPage = ref(1)
const perPage = ref(10)

// Filters
const filters = ref({
  search: '',
  type: '',
  status: ''
})

// Modal
const showRestaurantModal = ref(false)
const showStaffModal = ref(false)
const assignmentModal = useEstablishmentAssignment()
const selectedRestaurant = ref(null)

// État pour le modal QR code
const showQrModal = ref(false)
const qrCodeUrl = ref('')
const qrCodeRef = ref(null)

// Table columns for DataTable component
const tableColumns = [
  {
    key: 'name',
    label: 'Restaurant',
    sortable: true,
    width: '300px',
    minWidth: '280px',
    priority: 1 // Toujours visible
  },
  {
    key: 'type_name',
    label: 'Type',
    sortable: true,
    width: '120px',
    minWidth: '110px',
    priority: 2, // Visible à partir de SM
    responsive: 'sm'
  },
  {
    key: 'owner_name',
    label: 'Propriétaire',
    sortable: true,
    width: '180px',
    minWidth: '160px',
    priority: 3, // Visible à partir de MD
    responsive: 'md'
  },
  {
    key: 'is_active',
    label: 'Statut',
    sortable: true,
    width: '100px',
    minWidth: '90px',
    priority: 2, // Visible à partir de SM
    responsive: 'sm'
  },
  {
    key: 'created_at',
    label: 'Créé le',
    sortable: true,
    type: 'date' as const,
    width: '120px',
    minWidth: '110px',
    priority: 4, // Visible à partir de LG
    responsive: 'lg'
  },
  {
    key: 'actions',
    label: 'Actions',
    sortable: false,
    width: '120px',
    minWidth: '110px',
    priority: 1, // Toujours visible
    align: 'center'
  }
]

// Table columns
const columns = [
  {
    key: 'name',
    label: 'Restaurant',
    sortable: true,
    id: 'restaurant-col'
  },
  {
    key: 'type',
    label: 'Type',
    sortable: true,
    id: 'type-col'
  },
  {
    key: 'owner',
    label: 'Propriétaire',
    sortable: true,
    id: 'owner-col'
  },
  {
    key: 'subscription_type',
    label: 'Abonnement',
    sortable: true,
    id: 'subscription-col'
  },
  {
    key: 'is_active',
    label: 'Statut',
    sortable: true,
    id: 'status-col'
  },
  {
    key: 'created_at',
    label: 'Créé le',
    sortable: true,
    id: 'created-col',
    formatter: (date) => new Date(date).toLocaleDateString('fr-FR')
  },
  {
    key: 'updated_at',
    label: 'Mis à jour le',
    sortable: true,
    id: 'updated-col',
    formatter: (date) => new Date(date).toLocaleDateString('fr-FR')
  },
  {
    key: 'currency',
    label: 'Devise',
    sortable: true,
    id: 'currency-col'
  },
  {
    key: 'max_categories',
    label: 'Catégories',
    sortable: true,
    id: 'max-categories-col'
  },
  {
    key: 'max_products',
    label: 'Produits',
    sortable: true,
    id: 'max-products-col'
  },
  {
    key: 'actions',
    label: 'Actions',
    sortable: false,
    id: 'actions-col'
  }
]

// Options for filters
const typeOptions = ref<any[]>([])
const statusOptions = [
  { label: 'Actif', value: 'active' },
  { label: 'Inactif', value: 'inactive' }
]

// Options for subscription
const subscriptionOptions = [
  { label: 'Basic', value: 'basic' },
  { label: 'Premium', value: 'premium' },
  { label: 'Pro', value: 'pro' }
]

// Load restaurants data
const loadRestaurants = async () => {
  try {
    loading.value = true
    
    // Récupérer les restaurants
    const { data: establishmentsData, error: establishmentsError } = await supabase
      .from('establishments')
      .select('*')
      .order('created_at', { ascending: false })

    if (establishmentsError) throw establishmentsError
    
    // Récupérer les utilisateurs pour les associer aux restaurants
    const userIds = establishmentsData
      .filter(r => r.user_id)
      .map(r => r.user_id)
    
    const { data: usersData, error: usersError } = await supabase
      .from('users')
      .select('id, full_name')
      .in('id', userIds)
    
    if (usersError) throw usersError
    
    // Récupérer les types d'établissements
    const typeIds = establishmentsData
      .filter(r => r.type_id)
      .map(r => r.type_id)
    
    const { data: typesData, error: typesError } = await supabase
      .from('establishment_types')
      .select('id, name')
      .in('id', typeIds)
    
    if (typesError) throw typesError
    
    // Créer un dictionnaire pour un accès rapide
    const usersMap = {}
    usersData.forEach(u => { usersMap[u.id] = u })
    
    const typesMap = {}
    typesData.forEach(t => { typesMap[t.id] = t })
    
    // Associer les données
    restaurants.value = establishmentsData.map(restaurant => ({
      ...restaurant,
      owner_name: usersMap[restaurant.user_id]?.full_name || 'Non assigné',
      type_name: typesMap[restaurant.type_id]?.name || 'Non défini'
    }))

    // Calculer les statistiques
    const subscriptionCount = {}
    restaurants.value.forEach(r => {
      if (!subscriptionCount[r.subscription_type]) subscriptionCount[r.subscription_type] = 0
      subscriptionCount[r.subscription_type]++
    })

    stats.value = {
      total: restaurants.value.length,
      active: restaurants.value.filter(r => r.is_active).length,
      subscriptions: subscriptionCount
    }

  } catch (err) {
    console.error('Error loading restaurants:', err)
    showToast.error('Impossible de charger les restaurants', 'error')
  } finally {
    loading.value = false
  }
}

// Load users for owner selection
const loadUsers = async () => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('role', 'manager')
      .order('full_name')

    if (error) throw error
    users.value = data
  } catch (err) {
    console.error('Error loading users:', err)
  }
}

// Load establishment types
const loadEstablishmentTypes = async () => {
  try {
    const { data, error } = await supabase
      .from('establishment_types')
      .select('*')
      .order('name')

    if (error) throw error
    typeOptions.value = data.map(type => ({
      label: type.name,
      value: type.id
    }))
  } catch (err) {
    console.error('Error loading establishment types:', err)
  }
}

// Computed stats for display
const statsDisplay = computed(() => [
  { 
    name: 'Total restaurants', 
    value: stats.value.total.toString(),
    icon: Store,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500'
  },
  { 
    name: 'Restaurants actifs', 
    value: stats.value.active.toString(),
    icon: CheckCircle,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  },
  { 
    name: 'Types d\'établissements', 
    value: Object.keys(stats.value.subscriptions).length.toString(),
    icon: Utensils,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500'
  }
])

// Filtered restaurants
const filteredRestaurants = computed(() => {
  return restaurants.value.filter(restaurant => {
    const matchesSearch = !filters.value.search || 
      restaurant.name?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      restaurant.address?.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesType = !filters.value.type || restaurant.type_name === filters.value.type
    const matchesStatus = !filters.value.status || 
      (filters.value.status === 'active' && restaurant.is_active) ||
      (filters.value.status === 'inactive' && !restaurant.is_active)

    return matchesSearch && matchesType && matchesStatus
  })
})

// Pagination info
const paginationInfo = computed(() => {
  const start = (currentPage.value - 1) * perPage.value + 1
  const end = Math.min(start + perPage.value - 1, filteredRestaurants.value.length)
  return {
    showing: `${start}-${end}`,
    total: filteredRestaurants.value.length
  }
})

// Helper methods
const getTypeColor = (type: string) => {
  const colors: Record<string, string> = {
    'restaurant': 'orange',
    'cafe': 'yellow',
    'bar': 'purple',
    'fast_food': 'red',
    'hotel': 'blue'
  }
  return colors[type] || 'gray'
}

const getTypeBadgeClass = (type: string) => {
  const classes: Record<string, string> = {
    'restaurant': 'bg-orange-50 text-orange-700 border border-orange-200',
    'cafe': 'bg-amber-50 text-amber-700 border border-amber-200',
    'bar': 'bg-purple-50 text-purple-700 border border-purple-200',
    'fast_food': 'bg-red-50 text-red-700 border border-red-200',
    'hotel': 'bg-blue-50 text-blue-700 border border-blue-200'
  }
  return classes[type] || 'bg-gray-50 text-gray-700 border border-gray-200'
}

const getTypeIcon = (type: string) => {
  const icons: Record<string, any> = {
    'restaurant': Utensils,
    'cafe': Coffee,
    'bar': Wine,
    'fast_food': Pizza,
    'hotel': Hotel
  }
  return icons[type] || Store
}

const getInitials = (name: string) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return `${parts[0][0]}${parts[1][0]}`.toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const formatType = (type: string) => {
  const formats: Record<string, string> = {
    'restaurant': 'Restaurant',
    'cafe': 'Café',
    'bar': 'Bar',
    'fast_food': 'Fast Food',
    'hotel': 'Hôtel'
  }
  return formats[type] || type
}

const getSubscriptionColor = (type: string) => {
  const colors: Record<string, string> = {
    'basic': 'green',
    'premium': 'yellow',
    'pro': 'purple'
  }
  return colors[type] || 'gray'
}

const getSubscriptionBadgeClass = (type: string) => {
  const classes: Record<string, string> = {
    'basic': 'bg-green-100 text-green-800',
    'premium': 'bg-yellow-100 text-yellow-800',
    'pro': 'bg-purple-100 text-purple-800'
  }
  return classes[type] || 'bg-gray-100 text-gray-800'
}

const getSubscriptionLabel = (type: string) => {
  const labels: Record<string, string> = {
    'basic': 'Basic',
    'premium': 'Premium',
    'pro': 'Pro'
  }
  return labels[type] || type
}

// Methods
const handleAction = (action: string) => {
  if (action === 'add') {
    openRestaurantModal()
  }
}

const openRestaurantModal = (restaurant: any = null) => {
  selectedRestaurant.value = restaurant
  showRestaurantModal.value = true
}

const editRestaurant = (restaurant: any) => {
  selectedRestaurant.value = { ...restaurant }
  showRestaurantModal.value = true
}

const closeRestaurantModal = () => {
  showRestaurantModal.value = false
  selectedRestaurant.value = null
}

const handleRestaurantSubmitted = () => {
  loadRestaurants()
}

// Get establishment actions for dropdown
const getEstablishmentActions = (establishment: any) => {
  const actions = [
    {
      id: 'view',
      label: 'Voir Détails',
      icon: Shield,
      variant: 'primary' as const,
      callback: () => navigateTo(`/admin/establishments/${establishment.id}`)
    },
    {
      id: 'edit',
      label: 'Modifier',
      icon: Edit,
      variant: 'primary' as const,
      callback: () => editRestaurant(establishment)
    },
    {
      id: 'staff',
      label: 'Gérer Personnel',
      icon: Users,
      variant: 'primary' as const,
      callback: () => manageStaff(establishment)
    },
    {
      id: 'qr',
      label: 'QR Code',
      icon: QrCode,
      variant: 'secondary' as const,
      callback: () => manageQrCodes(establishment)
    },
    {
      id: 'transfer',
      label: 'Transférer Propriété',
      icon: ArrowRightLeft,
      variant: 'secondary' as const,
      callback: () => transferEstablishment(establishment)
    }
  ]

  // Add status-specific actions
  if (establishment.is_active) {
    actions.push({
      id: 'deactivate',
      label: 'Désactiver',
      icon: Ban,
      variant: 'danger' as const,
      callback: () => toggleRestaurantStatus(establishment)
    })
  } else {
    actions.push({
      id: 'activate',
      label: 'Activer',
      icon: CheckCircle,
      variant: 'primary' as const,
      callback: () => toggleRestaurantStatus(establishment)
    })
  }

  actions.push({
    id: 'delete',
    label: 'Supprimer',
    icon: Trash2,
    variant: 'danger' as const,
    callback: () => deleteRestaurant(establishment.id)
  })

  return actions
}

// Action handlers
const manageStaff = (establishment: any) => {
  selectedRestaurant.value = establishment
  showStaffModal.value = true
}

const transferEstablishment = (establishment: any) => {
  assignmentModal.transferEstablishment(establishment)
}

// Handle action from dropdown
const handleEstablishmentAction = (action: any) => {
  // Actions are handled by their callbacks
}

// Handle modal success
const handleModalSuccess = () => {
  loadRestaurants()
}

const handleEstablishmentAssignmentSuccess = () => {
  assignmentModal.onSuccess()
  loadRestaurants()
}

const deleteRestaurant = async (id: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cet établissement ?')) return

  try {
    loading.value = true
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('L\'établissement a été supprimé avec succès', 'success')
    await loadRestaurants() // Reload restaurants list
    
  } catch (error) {
    console.error('Error deleting restaurant:', error)
    showToast.error("Une erreur s'est produite lors de la suppression", 'error')
  } finally {
    loading.value = false
  }
}

// Méthodes pour les actions du menu déroulant
const manageEstablishment = (restaurant: any) => {
  // Rediriger vers la page de gestion de l'établissement
  navigateTo('/admin/establishments/manage')
}

const viewRestaurantMenu = (restaurant: any) => {
  // Rediriger vers la page du menu du restaurant
  navigateTo(`/admin/restaurants/${restaurant.id}/menu`)
}

const manageQrCodes = (restaurant: any) => {
  selectedRestaurant.value = restaurant
  // Construire l'URL du menu (à adapter selon votre structure)
  qrCodeUrl.value = `${window.location.origin}/menu/${restaurant.slug}`
  showQrModal.value = true
}

const closeQrModal = () => {
  showQrModal.value = false
  selectedRestaurant.value = null
}

// Méthode pour copier l'URL dans le presse-papier
const copyToClipboard = async (text: string) => {
  try {
    await navigator.clipboard.writeText(text)
    showToast.success('URL copiée dans le presse-papier', 'success')
  } catch (err) {
    console.error('Erreur lors de la copie :', err)
    showToast.error('Impossible de copier l\'URL', 'error')
  }
}

// Méthode pour télécharger le QR code
const downloadQrCode = async () => {
  try {
    const qrElement = document.querySelector('.qrcode-vue3') as HTMLElement
    if (!qrElement) return
    
    const canvas = await html2canvas(qrElement)
    const dataUrl = canvas.toDataURL('image/png')
    
    const link = document.createElement('a')
    link.href = dataUrl
    link.download = `qrcode-${selectedRestaurant.value?.slug || 'restaurant'}.png`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    showToast.success('QR code téléchargé', 'success')
  } catch (err) {
    console.error('Erreur lors du téléchargement :', err)
    showToast.error('Impossible de télécharger le QR code', 'error')
  }
}

// Méthode pour imprimer le QR code
const printQrCode = async () => {
  try {
    const qrElement = document.querySelector('.qrcode-vue3') as HTMLElement
    if (!qrElement) return
    
    const canvas = await html2canvas(qrElement)
    const dataUrl = canvas.toDataURL('image/png')
    
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      showToast.error('Veuillez autoriser les popups pour imprimer', 'error')
      return
    }
    
    printWindow.document.write(`
      <html>
        <head>
          <title>QR Code - ${selectedRestaurant.value?.name || 'Restaurant'}</title>
          <style>
            body {
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              height: 100vh;
              margin: 0;
              font-family: system-ui, -apple-system, sans-serif;
            }
            .container {
              text-align: center;
            }
            h1 {
              font-size: 24px;
              margin-bottom: 8px;
            }
            p {
              font-size: 14px;
              color: #666;
              margin-bottom: 24px;
            }
            img {
              max-width: 300px;
              border: 1px solid #eee;
              border-radius: 12px;
              padding: 16px;
            }
            .url {
              margin-top: 16px;
              font-size: 12px;
              color: #666;
            }
          </style>
        </head>
        <body onload="window.print(); window.close();">
          <div class="container">
            <h1>${selectedRestaurant.value?.name || 'Restaurant'}</h1>
            <p>Scannez ce QR code pour accéder au menu</p>
            <img src="${dataUrl}" alt="QR Code" />
            <div class="url">${qrCodeUrl.value}</div>
          </div>
        </body>
      </html>
    `)
    printWindow.document.close()
  } catch (err) {
    console.error('Erreur lors de l\'impression :', err)
    showToast.error('Impossible d\'imprimer le QR code', 'error')
  }
}

const toggleRestaurantStatus = async (restaurant: any) => {
  try {
    loading.value = true
    const { error } = await supabase
      .from('establishments')
      .update({ is_active: !restaurant.is_active })
      .eq('id', restaurant.id)

    if (error) throw error

    showToast.success(`Restaurant ${restaurant.is_active ? 'désactivé' : 'activé'} avec succès`, 'success')
    await loadRestaurants()
  } catch (error) {
    console.error('Error toggling restaurant status:', error)
    showToast.error("Une erreur s'est produite", 'error')
  } finally {
    loading.value = false
  }
}

// Fonction de formatage de date
const formatDate = (dateString: string, format = 'date') => {
  if (!dateString) return '-'
  
  const date = new Date(dateString)
  
  if (format === 'date') {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(date)
  } else if (format === 'time') {
    return new Intl.DateTimeFormat('fr-FR', {
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  } else if (format === 'datetime') {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  } else if (format === 'relative') {
    const now = new Date()
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000)
    
    if (diffInSeconds < 60) {
      return 'à l\'instant'
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60)
      return `il y a ${minutes} minute${minutes > 1 ? 's' : ''}`
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600)
      return `il y a ${hours} heure${hours > 1 ? 's' : ''}`
    } else if (diffInSeconds < 2592000) {
      const days = Math.floor(diffInSeconds / 86400)
      return `il y a ${days} jour${days > 1 ? 's' : ''}`
    } else {
      return new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      }).format(date)
    }
  }
  
  return dateString
}

// Initialisation
onMounted(() => {
  loadRestaurants()
  loadUsers()
  loadEstablishmentTypes()
})

definePageMeta({
  layout: 'admin'
})
</script> 