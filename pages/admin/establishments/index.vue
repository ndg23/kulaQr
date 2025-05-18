<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">Etablissements</h1>
      <p class="text-lg text-gray-600">Gérez les établissements</p>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
      <div v-for="stat in statsDisplay" :key="stat.name" 
        class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all -hover:scale-[1.02] -hover:shadow-lg"
      >
        <div class="flex items-center space-x-6">
          <div class="w-16 h-16 rounded-2xl flex items-center justify-center"
            :class="stat.iconBg"
          >
            <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
          </div>
          <div>
            <p class="text-base text-gray-500 mb-1">{{ stat.name }}</p>
            <h3 class="text-3xl font-bold text-gray-900">{{ stat.value }}</h3>
          </div>
        </div>
      </div>
    </div>

    <!-- Restaurants List -->
    <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden">
      <!-- Header with Search and Add -->
      <div class="p-6 border-b border-gray-100">
        <div class="flex items-center justify-between">
          <div class="relative flex-1 max-w-lg">
            <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="filters.search"
              type="search"
              placeholder="Rechercher un etablissement..."
              class="w-full h-12 pl-12 pr-4 rounded-2xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
            />
          </div>
          <button
            class="px-6 py-4 text-base font-semibold border border-gray-300 bg-sky-600 text-white hover:bg-sky-700 rounded-2xl focus:outline-none focus:ring-2 focus:ring-gray-200 dark:focus:ring-gray-700 transition-all"
            @click="openRestaurantModal"
          >
            Ajouter un etablissement
          </button>
        </div>
      </div>

      <!-- Filters -->
      <div class="p-4 bg-gray-50 border-b border-gray-100">
        <div class="flex gap-4">
          <USelect
            v-model="filters.type"
            :options="typeOptions"
            placeholder="Tous les types"
            class="w-48"
          />
          <USelect
            v-model="filters.status"
            :options="statusOptions"
            placeholder="Tous les statuts"
            class="w-48"
          />
        </div>
      </div>

      <!-- Table -->
      <UTable
        :rows="filteredRestaurants"
        :columns="columns"
        :loading="loading"
        :empty-state="{ icon: 'i-lucide-utensils', label: 'Aucun restaurant trouvé' }"
        hover
      >
        <!-- Restaurant Column -->
        <template #name-data="{ row }">
          <div class="flex items-center space-x-3">
            <div class="h-10 w-10 rounded-full bg-gray-100 flex items-center justify-center">
              <Store class="w-5 h-5 text-gray-500" />
            </div>
            <div>
              <div class="font-medium text-gray-900">{{ row.name }}</div>
              <div class="text-sm text-gray-500">{{ row.address }}</div>
            </div>
          </div>
        </template>

        <!-- Type Column -->
        <template #type-data="{ row }">
          <UBadge
            :color="getTypeColor(row.type_name)"
            variant="subtle"
            size="sm"
          >
            {{ formatType(row.type_name) }}
          </UBadge>
        </template>

        <!-- Owner Column -->
        <template #owner-data="{ row }">
          <div class="flex items-center space-x-2">
            <div class="h-6 w-6 rounded-full bg-gray-100 flex items-center justify-center">
              <User class="w-3 h-3 text-gray-500" />
            </div>
            <span>{{ row.owner_name }}</span>
          </div>
        </template>

        <!-- Subscription Column -->
        <template #subscription_type-data="{ row }">
          <UBadge
            :color="getSubscriptionColor(row.subscription_type)"
            variant="subtle"
            size="sm"
          >
            {{ getSubscriptionLabel(row.subscription_type) }}
          </UBadge>
        </template>

        <!-- Status Column -->
        <template #is_active-data="{ row }">
          <UBadge
            :color="row.is_active ? 'green' : 'red'"
            variant="subtle"
            size="sm"
          >
            <div class="flex items-center">
              <div class="w-1.5 h-1.5 rounded-full mr-1.5"
                :class="row.is_active ? 'bg-green-500' : 'bg-red-500'"
              />
              {{ row.is_active ? 'Actif' : 'Inactif' }}
            </div>
          </UBadge>
        </template>

        <!-- Created At Column -->
        <template #created_at-data="{ row }">
          <div class="flex flex-col">
            <span class="text-sm font-medium text-gray-900">
              {{ formatDate(row.created_at, 'date') }}
            </span>
            <span class="text-xs text-gray-500">
              {{ formatDate(row.created_at, 'time') }}
            </span>
          </div>
        </template>

        <!-- Updated At Column -->
        <template #updated_at-data="{ row }">
          <div class="flex flex-col">
            <span class="text-sm font-medium text-gray-900">
              {{ formatDate(row.updated_at, 'date') }}
            </span>
            <span class="text-xs text-gray-500">
              {{ formatDate(row.updated_at, 'time') }}
            </span>
          </div>
        </template>

        <!-- Currency Column -->
        <template #currency-data="{ row }">
          <UBadge
            color="blue"
            variant="subtle"
            size="sm"
          >
            {{ row.currency }}
          </UBadge>
        </template>

        <!-- Max Categories/Products Column -->
        <template #max_categories-data="{ row }">
          <div class="text-center">
            <span class="text-sm font-medium text-gray-900">{{ row.max_categories }}</span>
          </div>
        </template>

        <template #max_products-data="{ row }">
          <div class="text-center">
            <span class="text-sm font-medium text-gray-900">{{ row.max_products }}</span>
          </div>
        </template>

        <!-- Actions Column -->
        <template #actions-data="{ row }">
          <UDropdown
            :items="[
              [
                {
                  label: 'Modifier',
                  icon: 'i-heroicons-pencil-square',
                  click: () => editRestaurant(row)
                },
                {
                  label: 'Voir le menu',
                  icon: 'i-heroicons-eye',
                  click: () => viewRestaurantMenu(row)
                },
                {
                  label: 'QR Codes',
                  icon: 'i-heroicons-qr-code',
                  click: () => manageQrCodes(row)
                }
              ],
              [
                {
                  label: row.is_active ? 'Désactiver' : 'Activer',
                  icon: row.is_active ? 'i-heroicons-lock-closed' : 'i-heroicons-lock-open',
                  click: () => toggleRestaurantStatus(row)
                },
                {
                  label: 'Supprimer',
                  icon: 'i-heroicons-trash',
                  click: () => deleteRestaurant(row.id),
                  color: 'red'
                }
              ]
            ]"
          >
            <UButton
              color="gray"
              variant="ghost"
              icon="i-heroicons-ellipsis-horizontal"
            />
          </UDropdown>
        </template>
      </UTable>

      <!-- Pagination -->
      <div class="p-4 border-t border-gray-100">
        <div class="flex items-center justify-between">
          <p class="text-sm text-gray-500">
            Affichage de {{ paginationInfo.showing }} sur {{ paginationInfo.total }} restaurants
          </p>
          <UPagination
            v-model="currentPage"
            :total="filteredRestaurants.length"
            :per-page="perPage"
            size="sm"
          />
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { 
  Store, User, Users, Search, Plus, Edit, Trash2, 
  RefreshCw, X, CheckCircle, AlertTriangle, Loader2, 
  UtensilsCrossed, Coffee, Pizza, Utensils, Building, Shield, ClipboardCopy, Download, Printer
} from 'lucide-vue-next'
import { 
  TransitionRoot, TransitionChild, Dialog, DialogPanel, DialogTitle, Switch 
} from '@headlessui/vue'
import QRCodeVue3 from 'qrcode-vue3'
import html2canvas from 'html2canvas'
import RestaurantFormModal from '~/components/admin/RestaurantFormModal.vue'

// Supabase client
const {client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()

// State
const restaurants = ref([])
const users = ref([])
const loading = ref(false)
const stats = ref({
  total: 0,
  active: 0,
  subscriptions: {}
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
const selectedRestaurant = ref(null)

// État pour le modal QR code
const showQrModal = ref(false)
const qrCodeUrl = ref('')
const qrCodeRef = ref(null)

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
const typeOptions = ref([])
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
const getTypeColor = (type) => {
  const colors = {
    'restaurant': 'orange',
    'cafe': 'yellow',
    'bar': 'purple',
    'fast_food': 'red',
    'hotel': 'blue'
  }
  return colors[type] || 'gray'
}

const formatType = (type) => {
  const formats = {
    'restaurant': 'Restaurant',
    'cafe': 'Café',
    'bar': 'Bar',
    'fast_food': 'Fast Food',
    'hotel': 'Hôtel'
  }
  return formats[type] || type
}

const getSubscriptionColor = (type) => {
  const colors = {
    'basic': 'green',
    'premium': 'yellow',
    'pro': 'purple'
  }
  return colors[type] || 'gray'
}

const getSubscriptionLabel = (type) => {
  const labels = {
    'basic': 'Basic',
    'premium': 'Premium',
    'pro': 'Pro'
  }
  return labels[type] || type
}

// Methods
const openRestaurantModal = (restaurant = null) => {
  selectedRestaurant.value = restaurant
  showRestaurantModal.value = true
}

const editRestaurant = (restaurant) => {
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

const deleteRestaurant = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ?')) return

  try {
    loading.value = true
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('Le restaurant a été supprimé avec succès', 'success')
    await loadRestaurants() // Reload restaurants list
    
  } catch (error) {
    console.error('Error deleting restaurant:', error)
    showToast.error("Une erreur s'est produite lors de la suppression", 'error')
  } finally {
    loading.value = false
  }
}

// Méthodes pour les actions du menu déroulant
const viewRestaurantMenu = (restaurant) => {
  // Rediriger vers la page du menu du restaurant
  navigateTo(`/admin/restaurants/${restaurant.id}/menu`)
}

const manageQrCodes = (restaurant) => {
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
const copyToClipboard = async (text) => {
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
    const qrElement = document.querySelector('.qrcode-vue3')
    if (!qrElement) return
    
    const canvas = await html2canvas(qrElement)
    const dataUrl = canvas.toDataURL('image/png')
    
    const link = document.createElement('a')
    link.href = dataUrl
    link.download = `qrcode-${selectedRestaurant.value.slug}.png`
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
    const qrElement = document.querySelector('.qrcode-vue3')
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
          <title>QR Code - ${selectedRestaurant.value.name}</title>
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
            <h1>${selectedRestaurant.value.name}</h1>
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

const toggleRestaurantStatus = async (restaurant) => {
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
const formatDate = (dateString, format = 'date') => {
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
    const diffInSeconds = Math.floor((now - date) / 1000)
    
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