<template>
  <div class="p-6 lg:p-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center justify-between mb-2">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Gestion des commandes</h1>
          <p class="text-gray-600 mt-1">Gérer et suivre toutes les commandes de la plateforme</p>
        </div>
        <button
          @click="loadOrders"
          :disabled="loading"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
          <RefreshCw class="w-5 h-5" :class="{ 'animate-spin': loading }" />
        </button>
      </div>
    </div>

    <!-- Filters and Stats -->
    <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
      <button
        v-for="status in orderStatuses"
        :key="status.value"
        @click="activeStatus = status.value"
        class="p-4 rounded-xl border-2 transition-all"
        :class="[
          activeStatus === status.value
            ? 'border-blue-500 bg-blue-50'
            : 'border-gray-200 hover:border-gray-300 bg-white'
        ]"
      >
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-gray-600">{{ status.label }}</span>
          <component :is="status.icon" class="w-5 h-5" :class="status.color" />
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ getStatusCount(status.value) }}</p>
      </button>
    </div>

    <!-- Search and Filters -->
    <div class="bg-white rounded-2xl border border-gray-200 p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="md:col-span-2">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher par ID, table, établissement..."
              class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
            />
          </div>
        </div>
        
        <div>
          <select
            v-model="filterEstablishment"
            class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
          >
            <option value="">Tous les établissements</option>
            <option v-for="est in establishments" :key="est.id" :value="est.id">
              {{ est.name }}
            </option>
          </select>
        </div>

        <div>
          <select
            v-model="filterPaymentStatus"
            class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
          >
            <option value="">Tous les paiements</option>
            <option value="unpaid">Non payé</option>
            <option value="paid">Payé</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-20">
      <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
      <p class="text-gray-500">Chargement des commandes...</p>
    </div>

    <!-- Orders Table -->
    <div v-else-if="filteredOrders.length > 0" class="bg-white rounded-2xl border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                ID
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Établissement
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Table
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Statut
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Montant
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Paiement
              </th>
              <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Date
              </th>
              <th class="px-6 py-4 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr
              v-for="order in paginatedOrders"
              :key="order.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-mono text-gray-900">
                  #{{ order.id.slice(0, 8) }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <Store class="w-4 h-4 text-gray-400" />
                  <span class="text-sm text-gray-900">{{ order.establishment_name }}</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm text-gray-900">Table {{ order.table_number }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold"
                  :class="getStatusBadgeClass(order.status)"
                >
                  {{ getStatusLabel(order.status) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-semibold text-gray-900">
                  {{ formatPrice(order.total_amount) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium"
                  :class="{
                    'bg-green-50 text-green-700 border border-green-200': order.payment_status === 'paid',
                    'bg-red-50 text-red-700 border border-red-200': order.payment_status === 'unpaid'
                  }"
                >
                  {{ order.payment_status === 'paid' ? 'Payé' : 'Non payé' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900">{{ formatDate(order.created_at) }}</div>
                <div class="text-xs text-gray-500">{{ formatTime(order.created_at) }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right">
                <NuxtLink
                  :to="`/admin/orders/${order.id}`"
                  class="inline-flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
                >
                  <Eye class="w-4 h-4" />
                  Voir
                </NuxtLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="border-t border-gray-200 px-6 py-4">
        <div class="flex items-center justify-between">
          <p class="text-sm text-gray-600">
            Affichage de {{ (currentPage - 1) * itemsPerPage + 1 }} à
            {{ Math.min(currentPage * itemsPerPage, filteredOrders.length) }}
            sur {{ filteredOrders.length }} commandes
          </p>
          <div class="flex items-center gap-2">
            <button
              @click="currentPage--"
              :disabled="currentPage === 1"
              class="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeft class="w-5 h-5" />
            </button>
            <span class="text-sm font-medium text-gray-700">
              Page {{ currentPage }} sur {{ totalPages }}
            </span>
            <button
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              class="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronRight class="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="bg-white rounded-2xl border border-gray-200 p-12 text-center">
      <ShoppingBag class="w-16 h-16 text-gray-300 mx-auto mb-4" />
      <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucune commande trouvée</h3>
      <p class="text-gray-600">
        {{ searchQuery || filterEstablishment || filterPaymentStatus 
          ? 'Essayez de modifier vos filtres de recherche.' 
          : 'Les commandes apparaîtront ici une fois qu\'elles seront créées.' 
        }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import {
  RefreshCw,
  Search,
  Eye,
  Store,
  Loader2,
  ShoppingBag,
  ChevronLeft,
  ChevronRight,
  Clock,
  CheckCircle,
  XCircle,
  Package,
  Truck
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

// State
const loading = ref(true)
const orders = ref<any[]>([])
const establishments = ref<any[]>([])
const activeStatus = ref('all')
const searchQuery = ref('')
const filterEstablishment = ref('')
const filterPaymentStatus = ref('')
const currentPage = ref(1)
const itemsPerPage = 20

// Order statuses
const orderStatuses = [
  { value: 'all', label: 'Toutes', icon: ShoppingBag, color: 'text-gray-500' },
  { value: 'pending', label: 'En attente', icon: Clock, color: 'text-yellow-500' },
  { value: 'processing', label: 'En cours', icon: Package, color: 'text-blue-500' },
  { value: 'ready', label: 'Prêtes', icon: Truck, color: 'text-purple-500' },
  { value: 'completed', label: 'Terminées', icon: CheckCircle, color: 'text-green-500' }
]

// Load orders
const loadOrders = async () => {
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        establishments (
          name
        ),
        order_items (
          id,
          quantity,
          unit_price,
          products (
            name
          )
        )
      `)
      .order('created_at', { ascending: false })

    if (error) throw error
    
    orders.value = data.map(order => ({
      ...order,
      establishment_name: order.establishments?.name || 'Établissement inconnu'
    }))
    
  } catch (err) {
    console.error('Error loading orders:', err)
    showToast.error('Erreur lors du chargement des commandes')
  } finally {
    loading.value = false
  }
}

// Load establishments for filter
const loadEstablishments = async () => {
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name')
      .order('name')

    if (error) throw error
    
    establishments.value = data || []
    
  } catch (err) {
    console.error('Error loading establishments:', err)
  }
}

// Filtered orders
const filteredOrders = computed(() => {
  let filtered = orders.value

  // Filter by status
  if (activeStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === activeStatus.value)
  }

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order =>
      order.id.toLowerCase().includes(query) ||
      order.establishment_name.toLowerCase().includes(query) ||
      order.table_number?.toString().includes(query)
    )
  }

  // Filter by establishment
  if (filterEstablishment.value) {
    filtered = filtered.filter(order => order.establishment_id === filterEstablishment.value)
  }

  // Filter by payment status
  if (filterPaymentStatus.value) {
    filtered = filtered.filter(order => order.payment_status === filterPaymentStatus.value)
  }

  return filtered
})

// Paginated orders
const paginatedOrders = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredOrders.value.slice(start, end)
})

// Total pages
const totalPages = computed(() => {
  return Math.ceil(filteredOrders.value.length / itemsPerPage)
})

// Get status count
const getStatusCount = (status: string) => {
  if (status === 'all') return orders.value.length
  return orders.value.filter(order => order.status === status).length
}

// Get status badge class
const getStatusBadgeClass = (status: string) => {
  const classes: Record<string, string> = {
    pending: 'bg-yellow-50 text-yellow-700 border border-yellow-200',
    processing: 'bg-blue-50 text-blue-700 border border-blue-200',
    ready: 'bg-purple-50 text-purple-700 border border-purple-200',
    completed: 'bg-green-50 text-green-700 border border-green-200',
    cancelled: 'bg-red-50 text-red-700 border border-red-200'
  }
  return classes[status] || 'bg-gray-50 text-gray-700 border border-gray-200'
}

// Get status label
const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'En attente',
    processing: 'En cours',
    ready: 'Prêt',
    completed: 'Terminé',
    cancelled: 'Annulé'
  }
  return labels[status] || status
}

// Format price
const formatPrice = (amount: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0
  }).format(amount)
}

// Format date
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Format time
const formatTime = (dateString: string) => {
  return new Date(dateString).toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Reset pagination when filters change
watch([searchQuery, filterEstablishment, filterPaymentStatus, activeStatus], () => {
  currentPage.value = 1
})

// Load data on mount
onMounted(() => {
  loadOrders()
  loadEstablishments()
})

definePageMeta({
  layout: 'admin',
})
</script>
