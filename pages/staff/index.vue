<template>
  <div class="min-h-screen bg-gray-100-">
    <!-- Header - Soft Ticket Style -->
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-4 py-4">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-2xl font-bold font-mono text-gray-800">Commandes</h1>
          <div class="flex gap-2 items-center">
            <!-- Connection Status -->
            <div class="flex items-center gap-2 px-3 py-2 rounded-full text-xs font-medium"
                 :class="connectionStatus === 'connected' 
                   ? 'bg-green-50 text-green-700' 
                   : 'bg-red-50 text-red-700'">
              <div class="w-2 h-2 rounded-full"
                   :class="connectionStatus === 'connected' ? 'bg-green-500' : 'bg-red-500'"></div>
              <span class="hidden sm:inline">{{ connectionStatusText }}</span>
            </div>
            
            <!-- Refresh Button - Twitter style -->
            <button @click="refreshOrders" 
                    class="w-10 h-10 border-none bg-white rounded-full cursor-pointer flex items-center justify-center transition-all hover:bg-gray-100 shadow-sm"
                    :class="{ 'animate-spin': isRefreshing }">
              <RefreshCw class="w-5 h-5 text-gray-600" />
            </button>
          </div>
        </div>
        
        <!-- Search -->
        <div class="relative mb-4">
          <Search class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <input 
                v-model="searchQuery"
                type="text"
            placeholder="Rechercher..."
            class="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm transition-all focus:outline-none focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
        </div>
        
        <!-- Filters - Twitter Style -->
        <div class="flex gap-2 overflow-x-auto pb-2">
          <button 
            v-for="status in statusFilters" 
            :key="status.value"
            @click="filterStatus = status.value"
            class="filter-btn flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all flex-shrink-0"
            :class="[
              filterStatus === status.value 
                ? 'bg-black text-white shadow-sm active' 
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            ]"
          >
            <component v-if="status.value !== 'all'" :is="getStatusIcon(status.value)" class="w-4 h-4" />
            <span>{{ status.label }}</span>
            <span class="px-2 py-0.5 rounded-full text-xs font-bold min-w-[20px] text-center"
                  :class="filterStatus === status.value ? 'bg-white/20' : 'bg-gray-100'">
              {{ orders.filter(order => status.value === 'all' ? true : order.status === status.value).length }}
            </span>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 py-4 pb-16">
      <div id="ordersContainer">
      
        <!-- Loading State - Ticket style -->
        <div v-if="isLoading" class="text-center py-20">
          <Loader2 class="w-12 h-12 mx-auto mb-4 text-gray-400 animate-spin" />
          <p class="text-sm text-gray-600">Chargement...</p>
        </div>
        
        <!-- Error State - Ticket style -->
        <div v-else-if="loadError" class="text-center py-20">
          <AlertTriangle class="w-12 h-12 mx-auto mb-4 text-red-500" />
          <h3 class="text-lg font-bold mb-2">Erreur</h3>
          <p class="text-sm text-gray-600 mb-6">Impossible de charger les commandes</p>
          <button @click="loadOrders" 
                  class="px-6 py-3 bg-black text-white rounded-xl font-bold cursor-pointer transition-all hover:bg-gray-800">
          Réessayer
        </button>
      </div>
      
        <!-- Empty State - Ticket style -->
        <div v-else-if="filteredOrders.length === 0" class="text-center py-20">
          <ClipboardList class="w-12 h-12 mx-auto mb-4 text-gray-400" />
          <h3 class="text-lg font-bold mb-2">Aucune commande</h3>
          <p class="text-sm text-gray-600">
            {{ searchQuery ? 'Aucun résultat trouvé' : 'Aucune commande en cours' }}
        </p>
      </div>
      
        <!-- Orders Grid - Soft Ticket style -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
            class="bg-white border border-gray-200 rounded-xl overflow-hidden cursor-pointer transition-all hover:shadow-sm hover:-translate-y-1"
            @click="viewOrderDetails(order)"
          >
            <!-- Ticket Header -->
            <div class="p-4 border-b border-gray-200"
                 :class="{
                   'bg-yellow-100': order.status === 'pending',
                   'bg-blue-100': order.status === 'processing', 
                   'bg-green-100': order.status === 'completed'
                 }">
              <div class="flex justify-between items-center mb-2">
                <div class="flex items-center gap-2">
                  <div class="w-10 h-10 rounded-full bg-gray-800 text-white flex items-center justify-center font-bold">
                    {{ order.table_number }}
              </div>
              <div>
                    <div class="text-xs text-gray-500 font-medium">Table {{ order.table_number }}</div>
                    <div class="text-sm font-bold font-mono text-gray-800">#{{ order.orderNumber || order.id.slice(-6) }}</div>
                  </div>
                </div>
                <div class="px-3 py-1 rounded-full text-xs font-medium"
                     :class="{
                       'bg-yellow-100 text-yellow-800': order.status === 'pending',
                       'bg-blue-100 text-blue-800': order.status === 'processing',
                       'bg-green-100 text-green-800': order.status === 'completed'
                     }">
                  {{ translateStatus(order.status).toUpperCase() }}
                </div>
              </div>
              <div class="text-xs text-gray-600">{{ formatRelativeTime(order.created_at) }}</div>
            </div>
            
            <!-- Ticket Body -->
            <div class="p-4">
              <div class="font-mono text-xs mb-3">
                <div 
                  v-for="(item, index) in order.items.slice(0, 3)" 
                  :key="index"
                  class="flex justify-between mb-2 text-gray-600"
                >
                  <span class="flex-1 text-slate-700">{{ item.quantity }}x {{ item.name }}</span>
                  <span class="font-normal text-gray-800">{{ formatPrice(item.unit_price * item.quantity) }}</span>
                </div>
                <div v-if="order.items.length > 3" class="text-center text-gray-400 text-xs my-2">
                  +{{ order.items.length - 3 }} autre{{ order.items.length - 3 > 1 ? 's' : '' }}
                </div>
              </div>
              
              <div class="border-t border-dashed border-gray-300 pt-3 flex justify-between font-mono font-bold text-sm">
                <span class="text-black">TOTAL</span>
                <span>{{ formatPrice(order.total_amount) }}</span>
              </div>
              
              <!-- Action Button - Twitter style -->
              <div class="mt-4">
              <button 
                  v-if="order.status === 'pending'" 
                  @click.stop="updateOrderStatus(order.id, 'processing')"
                  class="w-full py-2 px-4 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 transition-colors"
                >
                  Commencer
              </button>
              
              <button 
                  v-else-if="order.status === 'processing'"
                  @click.stop="updateOrderStatus(order.id, 'completed')"
                  class="w-full py-2 px-4 bg-green-600 text-white rounded-full text-sm font-medium hover:bg-green-700 transition-colors"
                >
                  Terminer
              </button>
              
                <div v-else class="text-center py-2 text-sm text-gray-500 font-medium">
                  Commande terminée
                </div>
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
  Loader2, 
  AlertTriangle, 
  ClipboardList, 
  CheckCircle,
  Coffee
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

  // Filter by status
  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === filterStatus.value)
  }
  
  // Filter by search query
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
    
    console.log('✅ Commandes chargées depuis l\'API:', orders.value.length)
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
    
    // Update local state
    const orderIndex = orders.value.findIndex(order => order.id === orderId)
    if (orderIndex !== -1) {
      orders.value[orderIndex].status = newStatus
    }
    
    showToast.success('Succès', `Commande mise à jour: ${translateStatus(newStatus)}`)
    
    console.log(`✅ Statut mis à jour: Commande ${orderId} → ${newStatus}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const viewOrderDetails = (order: any) => {
  navigateTo(`/staff/order-detail/${order.id}`)
}

// Utility functions
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

const formatDateTime = (dateString: string) => {
  if (!dateString) return '---'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return '---'
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const translateStatus = (status: string) => {
  const translations: any = {
    'pending': 'En attente',
    'processing': 'En traitement',
    'completed': 'Terminée'
  }
  
  return translations[status] || 'Inconnu'
}

const formatRelativeTime = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000)
  const diffInMinutes = Math.floor(diffInSeconds / 60)
  const diffInHours = Math.floor(diffInMinutes / 60)
  const diffInDays = Math.floor(diffInHours / 24)
  
  if (diffInSeconds < 30) return 'À l\'instant'
  if (diffInSeconds < 60) return 'il y a 1 min'
  if (diffInMinutes < 60) return `il y a ${diffInMinutes} min`
  if (diffInHours < 24) return `il y a ${diffInHours}h`
  if (diffInDays < 7) return `il y a ${diffInDays}j`
  if (diffInDays < 30) return `il y a ${Math.floor(diffInDays / 7)} sem`
  if (diffInDays < 365) return `il y a ${Math.floor(diffInDays / 30)} mois`
  return `il y a ${Math.floor(diffInDays / 365)} an`
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

const getStatusIcon = (status: string) => {
  const icons = {
    'pending': Clock,
    'processing': Coffee,
    'completed': CheckCircle
  }
  
  return icons[status as keyof typeof icons] || Clock
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
/* Soft Ticket Style Custom Styles */
.font-mono {
  font-family: 'Courier New', monospace;
}

/* Custom scrollbar */
.overflow-x-auto::-webkit-scrollbar {
  height: 4px;
}

.overflow-x-auto::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 2px;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 2px;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Soft hover effects */
.hover\:-translate-y-1:hover {
  transform: translateY(-2px);
}

/* Smooth transitions */
* {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Soft shadows for tickets */
.shadow-lg {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.shadow-sm {
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* Twitter-style button hover effects */
button:hover {
  transform: translateY(-1px);
}

/* Filter buttons specific styles */
.filter-btn {
  position: relative;
  overflow: hidden;
}

.filter-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.filter-btn:hover::before {
  left: 100%;
}

/* Active filter button animation */
.filter-btn.active {
  animation: pulse 0.3s ease-in-out;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

/* Responsive improvements */
@media (max-width: 640px) {
  .grid-cols-1 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }
  
  .md\:grid-cols-2 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }
  
  .text-2xl {
    font-size: 1.25rem;
  }
}

/* Animation for refresh button */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style>