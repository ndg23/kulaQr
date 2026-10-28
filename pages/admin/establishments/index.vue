<template>
  <div>
    <PageHeader title="Établissements" description="Gérez les établissements et leurs propriétaires" />

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-6 mb-6 sm:mb-10">
      <PageStatCard v-for="(stat, i) in statsDisplay" :key="stat.name" :tone="cycleTone(i)" :name="stat.name" :value="stat.value" :icon="stat.icon" />
    </div>

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
        <NuxtLink
          v-if="!item.user_id"
          :to="`/admin/establishments/${item.id}/owner`"
          class="inline-flex items-center gap-1.5 h-8 px-4 rounded-full bg-[#FFE0F0] text-[#A10054] text-xs font-bold hover:opacity-80 transition-opacity whitespace-nowrap"
        >
          <UserPlus class="w-3.5 h-3.5" />
          Assigner un marchand
        </NuxtLink>
        <NuxtLink
          v-else
          :to="`/admin/establishments/${item.id}/owner`"
          class="flex items-center gap-2 max-w-[180px] group"
          title="Changer de marchand"
        >
          <span class="h-8 w-8 rounded-full bg-[#7050FF] text-white flex items-center justify-center flex-shrink-0 text-xs font-bold">{{ getInitials(item.owner_name) }}</span>
          <span class="text-sm font-medium text-gray-700 truncate group-hover:underline">{{ item.owner_name }}</span>
        </NuxtLink>
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
</template>

<script setup lang="ts">
import { cycleTone } from '~/utils/palette'
import { ref, computed, onMounted } from 'vue'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { 
  Store, User, Users, Search, Plus, Edit, Trash2, 
  RefreshCw, X, CheckCircle, AlertTriangle, Loader2, 
  UtensilsCrossed, Coffee, Pizza, Utensils, Building, Shield, ClipboardCopy, Download, Printer,
  Hotel, Wine, CakeSlice, ArrowRightLeft, QrCode, Ban, UserPlus
} from 'lucide-vue-next'
import ActionDropdown from '~/components/admin/ActionDropdown.vue'

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
    name: 'Sans marchand',
    value: restaurants.value.filter((r: any) => !r.user_id).length.toString(),
    icon: UserPlus,
    iconBg: 'bg-pink-50',
    iconColor: 'text-pink-500'
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
    navigateTo('/admin/establishments/new')
  }
}

const editRestaurant = (restaurant: any) => navigateTo(`/admin/establishments/${restaurant.id}/edit`)

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
      label: establishment.user_id ? 'Changer de marchand' : 'Assigner un marchand',
      icon: establishment.user_id ? ArrowRightLeft : UserPlus,
      variant: establishment.user_id ? 'secondary' as const : 'primary' as const,
      callback: () => transferEstablishment(establishment)
    }
  ]
  if (!establishment.user_id) actions.unshift(actions.pop()!)

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

// Action handlers : chaque action a sa page
const manageStaff = (establishment: any) => navigateTo(`/admin/establishments/${establishment.id}/staff`)

const transferEstablishment = (establishment: any) => navigateTo(`/admin/establishments/${establishment.id}/owner`)

// Handle action from dropdown
const handleEstablishmentAction = (action: any) => {
  // Actions are handled by their callbacks
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

const manageQrCodes = (restaurant: any) => navigateTo(`/admin/establishments/${restaurant.id}/qr`)

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