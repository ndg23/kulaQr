<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="border-b border-gray-100 py-6">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 flex justify-between items-center">
        <div class="flex items-center">
          <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center mr-4">
            <Clock class="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Commandes</h1>
            <p class="text-sm text-gray-500">{{ (establishment as any)?.name || 'Restaurant' }}</p>
          </div>
        </div>
        <div class="flex items-center gap-3">
            <div class="flex items-center gap-2">
            <div class="w-2 h-2 rounded-full" :class="connectionStatus === 'connected' ? 'bg-green-500' : 'bg-red-500'"></div>
            <span class="text-sm text-gray-500">{{ connectionStatusText }}</span>
          </div>
          <button @click="refreshOrders" 
                  class="p-2 rounded-full hover:bg-gray-100 transition-colors"
                  :class="{ 'animate-spin': isRefreshing }">
            <RefreshCw class="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="max-w-5xl mx-auto px-4 py-8 sm:px-6">
      <!-- Search and Filters -->
      <div class="mb-8">
        <div class="flex flex-col sm:flex-row gap-4">
          <!-- Search -->
          <div class="flex-1">
            <div class="relative">
              <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input 
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
                class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              />
          </div>
        </div>
        
          <!-- Status Filters -->
          <div class="flex gap-2">
          <button 
            v-for="status in statusFilters" 
            :key="status.value"
            @click="filterStatus = status.value"
              class="px-4 py-3 rounded-xl text-sm font-medium transition-colors"
            :class="filterStatus === status.value 
              ? 'bg-blue-500 text-white' 
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
            >
              {{ status.label }}
              <span class="ml-2 px-2 py-0.5 rounded-full text-xs"
                    :class="filterStatus === status.value ? 'bg-white/20' : 'bg-gray-300'">
                {{ orders.filter(order => status.value === 'all' ? true : order.status === status.value).length }}
            </span>
          </button>
          </div>
        </div>
      </div>
      
      <!-- Loading State -->
      <div v-if="isLoading" class="flex justify-center py-12">
        <svg class="animate-spin h-10 w-10 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      </div>
      
      <!-- Error State -->
      <div v-else-if="loadError" class="text-center py-12">
        <AlertTriangle class="w-12 h-12 text-red-500 mx-auto mb-4" />
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Erreur de chargement</h3>
        <p class="text-gray-600 mb-6">Impossible de charger les commandes</p>
        <button @click="loadOrders" 
                class="px-6 py-3 bg-blue-500 text-white rounded-xl font-medium hover:bg-blue-600 transition-colors">
          Réessayer
        </button>
      </div>
      
      <!-- Empty State -->
      <div v-else-if="filteredOrders.length === 0" class="text-center py-12">
        <ClipboardList class="w-12 h-12 text-gray-300 mx-auto mb-4" />
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-gray-500">
          {{ searchQuery ? 'Aucune commande trouvée pour cette recherche' : 'Aucune commande en cours' }}
        </p>
      </div>
      
      <!-- Orders List -->
      <div v-else class="space-y-6">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white border border-gray-100 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
          @click="viewOrderDetails(order)"
        >
          <!-- Order Header -->
          <div class="px-6 py-5 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-gray-50 rounded-xl flex items-center justify-center">
                  <span class="text-lg font-bold text-gray-700">{{ order.table_number }}</span>
                </div>
                <div>
                  <h3 class="text-lg font-semibold text-gray-900">Commande #{{ order.orderNumber || order.id.slice(-6) }}</h3>
                  <p class="text-sm text-gray-500">{{ formatDateTime(order.created_at) }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <span class="px-3 py-1 rounded-full text-sm font-medium"
                      :class="getStatusColor(order.status).badge">
                  {{ translateStatus(order.status) }}
                </span>
                <span class="text-lg font-bold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
              </div>
            </div>
          </div>
          
          <!-- Order Items Preview -->
          <div class="px-6 py-5">
            <div class="space-y-3">
              <div 
                v-for="(item, index) in order.items.slice(0, 3)" 
                :key="index"
                class="flex items-center justify-between"
              >
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center">
                    <span class="text-sm font-medium text-gray-600">{{ item.quantity }}×</span>
                  </div>
                  <span class="text-gray-700">{{ item.name }}</span>
                </div>
                <span class="text-sm font-medium text-gray-600">{{ formatPrice(item.unit_price * item.quantity) }}</span>
                </div>
              
              <div v-if="order.items.length > 3" class="text-sm text-gray-500 pl-11">
                +{{ order.items.length - 3 }} autre{{ order.items.length - 3 > 1 ? 's' : '' }}
              </div>
            </div>
          </div>
          
          <!-- Action Button -->
          <div class="px-6 py-4 bg-gray-50 border-t border-gray-100">
              <button 
                v-if="order.status === 'pending'" 
              @click.stop="updateOrderStatus(order.id, 'processing')"
              class="w-full py-3 bg-blue-500 text-white rounded-xl font-medium hover:bg-blue-600 transition-colors"
              >
              Commencer le traitement
              </button>
              
              <button 
              v-else-if="order.status === 'processing'"
              @click.stop="updateOrderStatus(order.id, 'completed')"
              class="w-full py-3 bg-green-500 text-white rounded-xl font-medium hover:bg-green-600 transition-colors"
            >
              Marquer comme terminé
              </button>
              
            <div v-else class="flex items-center justify-center py-3">
              <div class="flex items-center gap-2 px-4 py-2 bg-green-100 rounded-xl">
                <CheckCircle class="w-4 h-4 text-green-600" />
                <span class="text-sm font-medium text-green-700">Commande terminée</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { 
  Clock, 
  Search,
  RefreshCw,
  AlertTriangle, 
  ClipboardList, 
  CheckCircle
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { useEstablishment } from '~/composables/useEstablishment'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const { establishment, fetchEstablishmentByUserId } = useEstablishment()

// State
const orders = ref<any[]>([])
const isLoading = ref(true)
const loadError = ref(false)
const isRefreshing = ref(false)
const searchQuery = ref('')
const filterStatus = ref('all')
const connectionStatus = ref<'connected' | 'disconnected'>('disconnected')

// Computed
const connectionStatusText = computed(() => 
  connectionStatus.value === 'connected' ? 'En ligne' : 'Hors ligne'
)

const statusFilters = [
  { value: 'all', label: 'Toutes' },
  { value: 'pending', label: 'En attente' },
  { value: 'processing', label: 'En traitement' },
  { value: 'completed', label: 'Terminé' }
]

const filteredOrders = computed(() => {
  let filtered = orders.value

  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === filterStatus.value)
  }
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => 
      order.orderNumber?.toLowerCase().includes(query) ||
      order.table_number?.toString().includes(query) ||
      order.items.some((item: any) => item.name.toLowerCase().includes(query))
    )
  }

  return filtered
})

// Methods
const loadOrders = async () => {
  isLoading.value = true
  loadError.value = false
  
  try {
    if (!establishment.value) {
      await loadEstablishment()
    }
    
    if (!establishment.value) {
      throw new Error('Aucun établissement trouvé')
    }
    
    const { data, error } = await supabase
      .from('orders')
      .select(`
        id,
        table_number,
        status,
        total_amount,
        payment_status,
        notes,
        created_at,
        updated_at,
        items:order_items(
          id,
          quantity,
          unit_price,
          notes,
          products(
            id,
            name,
            description,
            price
          )
        )
      `)
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(50)
    
    if (error) throw error
    
    orders.value = data.map((order, index) => ({
      ...order,
      orderNumber: String(index + 1).padStart(3, '0'),
      items: order.items.map((item: any) => ({
        ...item,
        name: item.products?.name || 'Produit inconnu',
        productId: item.products?.id
      }))
    }))
    
    connectionStatus.value = 'connected'
    
    console.log('✅ Commandes chargées:', orders.value.length)
  } catch (error) {
    console.error('Error loading orders:', error)
    showToast.error('Erreur', 'Impossible de charger les commandes')
    loadError.value = true
  } finally {
    isLoading.value = false
  }
}

const loadEstablishment = async () => {
  try {
    await fetchEstablishmentByUserId()
  } catch (error) {
    console.error('Error loading establishment:', error)
  }
}

const refreshOrders = async () => {
  isRefreshing.value = true
  await loadOrders()
  isRefreshing.value = false
}

const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)
    
    if (error) throw error
    
    const orderIndex = orders.value.findIndex(order => order.id === orderId)
    if (orderIndex !== -1) {
      orders.value[orderIndex].status = newStatus
    }
    
    showToast.success('Succès', `Commande mise à jour`)
    
    console.log(`✅ Statut mis à jour: ${orderId} → ${newStatus}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour')
  }
}

const viewOrderDetails = (order: any) => {
  navigateTo(`/staff/order-detail/${order.id}`)
}

// Utility functions
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    maximumFractionDigits: 0
  }).format(price)
}

const formatDateTime = (dateString: string) => {
  if (!dateString) return '---'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return '---'
  return new Intl.DateTimeFormat('fr-FR', {
    day: 'numeric',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const translateStatus = (status: string) => {
  const translations: any = {
    'pending': 'En attente',
    'processing': 'En traitement',
    'completed': 'Terminé'
  }
  
  return translations[status] || 'Inconnu'
}

const getStatusColor = (status: string) => {
  const colors: any = {
    'pending': {
      badge: 'bg-yellow-100 text-yellow-800'
    },
    'processing': {
      badge: 'bg-blue-100 text-blue-800'
    },
    'completed': {
      badge: 'bg-green-100 text-green-800'
    }
  }
  
  return colors[status] || colors.pending
}

// Realtime subscription
let subscription: any = null

const setupRealtimeConnection = () => {
  if (!establishment.value?.id) return
  
  if (subscription) {
    subscription.unsubscribe()
  }
  
  subscription = supabase
    .channel(`orders-${establishment.value.id}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${establishment.value.id}`
      },
      (payload) => {
        console.log('🔄 Mise à jour en temps réel:', payload)
        loadOrders()
      }
    )
    .subscribe((status) => {
      connectionStatus.value = status === 'SUBSCRIBED' ? 'connected' : 'disconnected'
    })
}

// Lifecycle
onMounted(async () => {
  await loadEstablishment()
  await loadOrders()
  setupRealtimeConnection()
})

onUnmounted(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

definePageMeta({
  layout: 'staff',
})
</script>

<style scoped>
/* Simple transitions */
button, input {
  transition: all 150ms ease-in-out;
}
</style>