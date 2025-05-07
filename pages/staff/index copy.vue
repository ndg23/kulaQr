<template>
  <div class="font-sans bg-gray-50 min-h-screen">
    <!-- Header - Simplified with better contrast -->
    <header class="bg-blue-600 text-white shadow-md">
      <div class="max-w-7xl mx-auto px-4 py-3 flex justify-between items-center">
        <h1 class="text-xl font-bold flex items-center">
          <ClipboardList class="mr-2" size="20" />
          Gestion des commandes
        </h1>
        <div class="flex items-center space-x-3">
          <div class="hidden md:flex items-center bg-blue-500 text-white px-3 py-1 rounded">
            <Clock size="16" class="mr-1.5" />
            <span class="text-sm">{{ currentDateTime }}</span>
          </div>
          <div v-if="connectionStatus" class="hidden md:flex items-center">
            <span 
              class="w-2 h-2 rounded-full mr-1.5"
              :class="connectionStatus === 'connected' ? 'bg-green-400' : 'bg-red-400'"
            ></span>
            <span class="text-sm">{{ connectionStatus === 'connected' ? 'En ligne' : 'Hors ligne' }}</span>
          </div>
          <button 
            @click="logout" 
            class="bg-white text-blue-600 px-3 py-1.5 rounded font-medium text-sm hover:bg-blue-50 transition-colors flex items-center"
          >
            <LogOut size="16" class="mr-1" />
            <span class="hidden md:inline">Déconnexion</span>
          </button>
        </div>
      </div>
    </header>
    
    <!-- Main content -->
    <div class="max-w-7xl mx-auto p-4">
      <!-- Connection status indicator on mobile -->
      <div 
        v-if="connectionStatus !== 'connected'" 
        class="md:hidden bg-red-50 text-red-700 px-3 py-2 rounded-md mb-3 flex items-center"
      >
        <Wifi size="16" class="mr-1.5" /> 
        Connexion perdue. <button @click="reconnect" class="ml-2 underline">Reconnecter</button>
      </div>

      <!-- Latest activity banner -->
      <div 
        v-if="latestActivity" 
        class="bg-blue-50 text-blue-800 px-4 py-3 rounded-lg mb-4 flex items-center justify-between animate-fade-in"
      >
        <div class="flex items-center">
          <Bell size="18" class="mr-2" />
          <span>{{ latestActivity }}</span>
        </div>
        <button @click="latestActivity = null" class="text-blue-600">
          <X size="16" />
        </button>
      </div>

      <!-- Status counts dashboard -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3 my-4">
        <div 
          v-for="status in statusFilters" 
          :key="status.value"
          @click="activeFilter = status.value"
          class="bg-white rounded-lg shadow-sm p-3 cursor-pointer transition-all hover:shadow border-l-4"
          :class="[
            activeFilter === status.value ? 'border-l-blue-500 bg-blue-50' : 'border-l-transparent',
            status.colorClass
          ]"
        >
          <div class="flex justify-between items-start">
            <div>
              <h3 class="font-medium text-gray-800">{{ status.label }}</h3>
              <p class="text-2xl font-bold mt-1">{{ getFilterCount(status.value) }}</p>
            </div>
            <component :is="status.icon" :size="24" class="mt-1" :class="status.iconClass" />
          </div>
        </div>
      </div>

      <!-- Order actions bar -->
      <div class="flex justify-between items-center mb-4">
        <div class="flex space-x-2">
          <div class="relative">
            <input 
              v-model="searchQuery" 
              type="text" 
              placeholder="Rechercher une commande..." 
              class="pl-9 pr-3 py-2 border border-gray-200 rounded-lg text-sm w-full md:w-64"
            />
            <Search size="16" class="absolute left-3 top-2.5 text-gray-400" />
          </div>
        </div>
        <button 
          @click="refreshOrders"
          class="bg-white p-2 rounded-lg text-blue-600 border border-gray-200 hover:bg-gray-50 transition-colors flex items-center"
          :class="{ 'animate-spin': loading }"
        >
          <RefreshCw size="18" class="mr-1" />
          <span class="hidden md:inline">Actualiser</span>
        </button>
      </div>
      
      <!-- Orders list -->
      <div v-if="filteredOrders.length > 0" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white rounded-lg shadow-sm border overflow-hidden hover:shadow-md transition-all"
          :class="{
            'border-blue-200': order.status === 'pending',
            'border-yellow-200': order.status === 'preparing',
            'border-green-200': order.status === 'ready',
            'border-gray-200': order.status === 'accepted'
          }"
        >
          <!-- Order header -->
          <div 
            class="p-3 flex justify-between items-center"
            :class="{
              'bg-blue-50 border-b border-blue-100': order.status === 'pending',
              'bg-gray-50 border-b border-gray-100': order.status === 'accepted',
              'bg-yellow-50 border-b border-yellow-100': order.status === 'preparing',
              'bg-green-50 border-b border-green-100': order.status === 'ready'
            }"
          >
            <div class="flex items-center">
              <div 
                class="w-2 h-10 rounded-full mr-3"
                :class="{
                  'bg-blue-500': order.status === 'pending',
                  'bg-gray-400': order.status === 'accepted',
                  'bg-yellow-500': order.status === 'preparing',
                  'bg-green-500': order.status === 'ready'
                }"
              ></div>
              <div>
                <div class="flex items-center">
                  <span class="font-bold text-lg">#{{ order.orderNumber }}</span>
                  <span 
                    class="ml-2 px-2 py-0.5 text-xs rounded-full font-medium"
                    :class="{
                      'bg-blue-100 text-blue-700': order.status === 'pending',
                      'bg-gray-100 text-gray-700': order.status === 'accepted',
                      'bg-yellow-100 text-yellow-700': order.status === 'preparing',
                      'bg-green-100 text-green-700': order.status === 'ready'
                    }"
                  >
                    {{ translateStatus(order.status) }}
                  </span>
                </div>
                <p class="text-sm flex items-center mt-0.5">
                  <Coffee size="14" class="mr-1" />
                  Table {{ order.table }}
                </p>
              </div>
            </div>
            <div class="text-right text-sm">
              <p class="font-medium">{{ formatTime(order.created_at) }}</p>
              <p class="text-gray-500">{{ getTimeAgo(order.created_at) }}</p>
            </div>
          </div>
          
          <!-- Order items -->
          <div class="px-3 py-2 max-h-64 overflow-y-auto">
            <div 
              v-for="item in order.items" 
              :key="item.id"
              class="py-2 border-b border-gray-100 last:border-0 flex justify-between"
            >
              <div class="flex-1">
                <div class="flex items-center">
                  <span class="bg-gray-100 text-gray-700 rounded-full w-6 h-6 flex items-center justify-center text-sm mr-2">
                    {{ item.quantity }}
                  </span>
                  <span class="font-medium">{{ item.name }}</span>
                </div>
                <p v-if="item.note" class="text-sm text-gray-500 mt-1 ml-8 italic">
                  {{ item.note }}
                </p>
              </div>
              <span class="text-gray-700">{{ formatPrice(item.price * item.quantity) }}</span>
            </div>
          </div>
          
          <!-- Order actions -->
          <div class="p-3 bg-gray-50 flex flex-wrap justify-between items-center gap-2 border-t border-gray-100">
            <span class="font-bold text-lg">{{ formatPrice(order.total) }}</span>
            <div class="flex flex-wrap gap-2">
              <!-- Status-based action buttons -->
              <template v-if="order.status === 'pending'">
                <button 
                  @click="updateOrderStatus(order.id, 'accepted')"
                  class="px-3 py-1.5 bg-green-500 text-white rounded font-medium text-sm hover:bg-green-600 transition-colors flex items-center"
                >
                  <Check size="16" class="mr-1" />
                  Accepter
                </button>
                <button 
                  @click="updateOrderStatus(order.id, 'rejected')"
                  class="px-3 py-1.5 bg-red-500 text-white rounded font-medium text-sm hover:bg-red-600 transition-colors flex items-center"
                >
                  <X size="16" class="mr-1" />
                  Refuser
                </button>
              </template>

              <template v-if="order.status === 'accepted'">
                <button 
                  @click="updateOrderStatus(order.id, 'preparing')"
                  class="px-3 py-1.5 bg-yellow-500 text-white rounded font-medium text-sm hover:bg-yellow-600 transition-colors flex items-center"
                >
                  <ChefHat size="16" class="mr-1" />
                  En préparation
                </button>
              </template>

              <button 
                v-if="order.status === 'preparing'"
                @click="updateOrderStatus(order.id, 'ready')"
                class="px-3 py-1.5 bg-green-500 text-white rounded font-medium text-sm hover:bg-green-600 transition-colors flex items-center"
              >
                <Bell size="16" class="mr-1" />
                Prête
              </button>
              <button 
                v-if="order.status === 'ready'"
                @click="updateOrderStatus(order.id, 'completed')"
                class="px-3 py-1.5 bg-gray-500 text-white rounded font-medium text-sm hover:bg-gray-600 transition-colors flex items-center"
              >
                <CheckCircle size="16" class="mr-1" />
                Terminée
              </button>
              <button
                @click="printOrder(order)"
                class="px-3 py-1.5 bg-blue-500 text-white rounded font-medium text-sm hover:bg-blue-600 transition-colors flex items-center"
              >
                <Printer size="16" class="mr-1" />
                Imprimer
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Empty state -->
      <div 
        v-if="filteredOrders.length === 0" 
        class="bg-white rounded-lg p-8 text-center shadow-sm border border-gray-100"
      >
        <ClipboardCheck size="48" class="text-gray-300 mx-auto mb-3" />
        <h3 class="text-lg font-medium text-gray-800">Aucune commande</h3>
        <p class="text-gray-500 mt-1">
          Il n'y a actuellement aucune commande {{ activeFilter !== 'Toutes' ? 'dans cette catégorie' : '' }}.
        </p>
        <button 
          @click="refreshOrders" 
          class="mt-4 px-4 py-2 bg-blue-500 text-white rounded font-medium text-sm hover:bg-blue-600 transition-colors"
        >
          Actualiser les commandes
        </button>
      </div>
      
      <!-- Notification sonore pour les nouvelles commandes -->
      <audio ref="newOrderSound" src="/sounds/new-order.mp3" preload="auto"></audio>

      <!-- Quick actions panel (fixed at bottom on mobile) -->
      <div class="fixed bottom-0 left-0 right-0 md:hidden bg-white border-t border-gray-200 shadow-lg p-3 z-10">
        <div class="flex justify-between">
          <button 
            @click="refreshOrders" 
            class="flex-1 mx-1 bg-blue-500 text-white py-2 rounded font-medium text-sm flex items-center justify-center"
          >
            <RefreshCw size="16" class="mr-1" />
            Actualiser
          </button>
          <button 
            @click="activeFilter = 'Nouvelles'" 
            class="flex-1 mx-1 bg-blue-50 text-blue-700 py-2 rounded font-medium text-sm flex items-center justify-center"
            :class="{ 'bg-blue-600 text-white': activeFilter === 'Nouvelles' }"
          >
            <Bell size="16" class="mr-1" />
            Nouvelles ({{ getFilterCount('Nouvelles') }})
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { 
  ClipboardCheck, 
  RefreshCw, 
  Printer, 
  LogOut, 
  ClipboardList,
  Bell,
  Check,
  X,
  CheckCircle,
  Coffee,
  ChefHat,
  Search,
  Clock,
  Wifi
} from 'lucide-vue-next'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'

const supabase = useSupabaseClient()
const router = useRouter()
const { showToast } = useCustomToast()

// Types pour les commandes
interface Order {
  id: string
  orderNumber: string
  table: number
  status: OrderStatus
  created_at: string
  total: number
  items: OrderItem[]
}

interface OrderItem {
  id: string
  name: string
  quantity: number
  price: number
  note: string | null
}

// State
const orders = ref<Order[]>([])
const loading = ref(false)
const activeFilter = ref('Toutes')
const searchQuery = ref('')
const connectionStatus = ref<'connected' | 'disconnected'>('connected')
const latestActivity = ref<string | null>(null)

// Status filters with icons
const statusFilters = [
  { 
    label: 'Toutes', 
    value: 'Toutes',
    icon: ClipboardList,
    colorClass: 'hover:bg-gray-50',
    iconClass: 'text-gray-400'
  },
  { 
    label: 'Nouvelles', 
    value: 'Nouvelles',
    icon: Bell,
    colorClass: 'hover:bg-blue-50',
    iconClass: 'text-blue-500'
  },
  { 
    label: 'En préparation', 
    value: 'En préparation',
    icon: ChefHat,
    colorClass: 'hover:bg-yellow-50',
    iconClass: 'text-yellow-500'
  },
  { 
    label: 'Prêtes', 
    value: 'Prêtes',
    icon: CheckCircle,
    colorClass: 'hover:bg-green-50',
    iconClass: 'text-green-500'
  }
]

// Date et heure actuelle
const currentDateTime = computed(() => {
  return new Date().toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    hour: '2-digit',
    minute: '2-digit'
  })
})

const statusMap = {
  'Toutes': ['pending', 'accepted', 'preparing', 'ready'],
  'Nouvelles': ['pending'],
  'Acceptées': ['accepted'],
  'En préparation': ['preparing'],
  'Prêtes': ['ready']
}

// Translate status codes to French
const translateStatus = (status) => {
  const translations = {
    'pending': 'Nouvelle',
    'accepted': 'Acceptée',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'rejected': 'Refusée'
  }
  return translations[status] || status
}

// Filter orders by status and search query
const filteredOrders = computed(() => {
  // First filter by status
  let filtered = orders.value
  
  if (activeFilter.value !== 'Toutes') {
    filtered = filtered.filter(order => 
      statusMap[activeFilter.value]?.includes(order.status)
    )
  } else {
    filtered = filtered.filter(order => 
      !['completed', 'cancelled', 'rejected'].includes(order.status)
    )
  }
  
  // Then filter by search query if present
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => {
      // Search by order number
      if (order.orderNumber.toLowerCase().includes(query)) return true
      // Search by table number
      if (order.table.toString().includes(query)) return true
      // Search by items
      if (order.items.some(item => item.name.toLowerCase().includes(query))) return true
      return false
    })
  }
  
  return filtered
})

// Get count for each filter
const getFilterCount = (filter) => {
  if (filter === 'Toutes') {
    return orders.value.filter(order => 
      !['completed', 'cancelled', 'rejected'].includes(order.status)
    ).length
  }
  
  return orders.value.filter(order => 
    statusMap[filter]?.includes(order.status)
  ).length
}

// Types pour Supabase
type OrderStatus = 'pending' | 'accepted' | 'rejected' | 'preparing' | 'ready' | 'completed'

interface DatabaseOrder {
  id: string
  establishment_id: string
  table_number: number
  status: OrderStatus
  total_amount: number
  created_at: string
  notes: string | null
}

interface FormattedOrder {
  id: string
  orderNumber: string
  table: number
  status: OrderStatus
  created_at: string
  total: number
  items: {
    id: string
    name: string
    quantity: number
    price: number
    note: string | null
  }[]
}

// Load orders from Supabase
const fetchOrders = async () => {
  loading.value = true
  
  try {
    // Get orders
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .order('created_at', { ascending: false })
      .in('status', ['pending', 'accepted', 'preparing', 'ready', 'completed'])
      .limit(50) // Limit for better performance
    
    if (ordersError) throw ordersError
    
    // For each order, get its items
    const ordersWithItems = await Promise.all(ordersData.map(async (order) => {
      // Get order items
      const { data: orderItems, error: itemsError } = await supabase
        .from('order_items')
        .select('*')
        .eq('order_id', order.id)
      
      if (itemsError) throw itemsError
      
      // Process items with joined product data for better performance
      const itemsWithProductInfo = orderItems.map(item => {
        return {
          id: item.id,
          name: item.products?.name || 'Produit inconnu',
          quantity: item.quantity,
          price: item.unit_price,
          note: item.note
        }
      })
      
      return {
        id: order.id,
        orderNumber: order.id.toString().slice(-4).padStart(4, '0'),
        table: order.table_number,
        status: order.status,
        created_at: order.created_at,
        total: order.total_amount,
        items: itemsWithProductInfo
      }
    }))
    
    // Check for new orders and play sound
    const previousPendingCount = orders.value.filter(o => o.status === 'pending').length
    orders.value = ordersWithItems
    const currentPendingCount = ordersWithItems.filter(o => o.status === 'pending').length
    
    if (currentPendingCount > previousPendingCount && previousPendingCount > 0) {
      playNotificationSound()
      showToast.success('Nouvelle commande reçue!', 'info')
    }
    
  } catch (err) {
    console.error('Erreur lors du chargement des commandes:', err)
    showToast.error('Erreur lors du chargement des commandes', 'error')
  } finally {
    loading.value = false
  }
}

// Play notification sound
const playNotificationSound = () => {
  if (newOrderSound.value) {
    newOrderSound.value.currentTime = 0
    newOrderSound.value.play().catch(e => console.log('Erreur de lecture audio:', e))
  }
}

// Refresh orders
const refreshOrders = () => {
  fetchOrders()
}

// Update order status
const updateOrderStatus = async (orderId, newStatus) => {
  try {
    // Find order before update for notification
    const orderBefore = orders.value.find(o => o.id === orderId)
    const orderNumber = orderBefore ? orderBefore.orderNumber : orderId.toString().slice(-4).padStart(4, '0')
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updated_at: new Date().toISOString() // Update timestamp
      })
      .eq('id', orderId)
    
    if (error) throw error
    
    // Update locally (real-time will handle, but immediate feedback is good)
    const order = orders.value.find(o => o.id === orderId)
    if (order) {
      order.status = newStatus
    }
    
    // Confirmation message
    const statusMessages = {
      accepted: 'acceptée',
      rejected: 'refusée',
      preparing: 'en préparation',
      ready: 'prête',
      completed: 'terminée'
    }
    
    const notificationMessage = `Commande #${orderNumber} ${statusMessages[newStatus]}`
    
    showToast.success(notificationMessage, 'success')
    setLatestActivity(notificationMessage)
    
    // Remove completed or rejected orders after delay
    if (['completed', 'rejected'].includes(newStatus)) {
      setTimeout(() => {
        orders.value = orders.value.filter(o => o.id !== orderId)
      }, 3000)
    }
  } catch (err) {
    console.error('Erreur lors de la mise à jour du statut:', err)
    showToast.error('Erreur lors de la mise à jour du statut', 'error')
  }
}

// Set latest activity message with auto-clear
const setLatestActivity = (message) => {
  latestActivity.value = message
  
  // Clear after 10 seconds
  setTimeout(() => {
    if (latestActivity.value === message) {
      latestActivity.value = null
    }
  }, 10000)
}

// Reconnect to Supabase
const reconnect = () => {
  connectionStatus.value = 'connecting'
  
  // Attempt to reconnect
  const unsubscribe = subscribeToOrders()
  
  // Simulate connection status check
  setTimeout(() => {
    connectionStatus.value = 'connected'
    showToast.success('Reconnexion réussie', 'success')
  }, 1000)
}

// Monitor connection status
const setupConnectionMonitoring = () => {
  // Monitor online/offline status
  window.addEventListener('online', () => {
    connectionStatus.value = 'connected'
    reconnect()
  })
  
  window.addEventListener('offline', () => {
    connectionStatus.value = 'disconnected'
    showToast.error('Connexion perdue', 'error')
  })
  
  // Check for Supabase connection issues
  // This is simplified - would need actual health checks

}

// Print order
const printOrder = (order) => {
  const printWindow = window.open('', '_blank')
  if (!printWindow) {
    showToast.error('Veuillez autoriser les popups pour imprimer', 'error')
    return
  }
  
  const orderDate = new Date(order.created_at).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
  
  let itemsHtml = ''
  order.items.forEach(item => {
    itemsHtml += `
      <tr>
        <td>${item.quantity}×</td>
        <td>${item.name}</td>
        <td>${formatPrice(item.price * item.quantity)}</td>
      </tr>
      ${item.note ? `<tr><td colspan="3" class="note">Note: ${item.note}</td></tr>` : ''}
    `
  })
  
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Commande #${order.orderNumber}</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 400px; margin: 0 auto; padding: 20px; }
        h1 { text-align: center; font-size: 20px; margin-bottom: 5px; }
        .info { text-align: center; margin-bottom: 20px; font-size: 14px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { text-align: left; border-bottom: 1px solid #ddd; padding: 8px; }
        td { padding: 8px; border-bottom: 1px solid #eee; }
        .total { font-weight: bold; text-align: right; margin-top: 15px; font-size: 16px; }
        .note { font-style: italic; font-size: 12px; color: #666; }
        .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #666; }
      </style>
    </head>
    <body>
      <h1>Commande #${order.orderNumber}</h1>
      <div class="info">
        <div>Table ${order.table}</div>
        <div>${orderDate}</div>
      </div>
      
      <table>
        <thead>
          <tr>
            <th>Qté</th>
            <th>Article</th>
            <th>Prix</th>
          </tr>
        </thead>
        <tbody>
          ${itemsHtml}
        </tbody>
      </table>
      
      <div class="total">
        Total: ${formatPrice(order.total)}
      </div>
      
      <div class="footer">
        Merci de votre commande !
      </div>
    </body>
    </html>
  `
  
  printWindow.document.write(htmlContent)
  printWindow.document.close()
  
  // Print after content is loaded
  setTimeout(() => {
    printWindow.print()
    printWindow.close()
  }, 500)
}

// Format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

// Format time
const formatTime = (dateString) => {
  return new Date(dateString).toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Calculate time elapsed
const getTimeAgo = (dateString) => {
  const now = new Date()
  const orderTime = new Date(dateString)
  const diffMinutes = Math.floor((now - orderTime) / (1000 * 60))
  
  if (diffMinutes < 1) return 'À l\'instant'
  if (diffMinutes === 1) return 'Il y a 1 min'
  if (diffMinutes < 60) return `Il y a ${diffMinutes} min`
  
  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours === 1) return 'Il y a 1h'
  return `Il y a ${diffHours}h`
}

// Logout
const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    router.push('/auth/login')
    showToast.success('Déconnexion réussie', 'À bientôt !')
  } catch (err) {
    console.error('Erreur lors de la déconnexion:', err)
    showToast.error('Erreur lors de la déconnexion', 'error')
  }
}

// Subscribe to real-time updates
const subscribeToOrders = () => {
  // Subscribe to orders table changes
  const ordersSubscription = supabase
    .channel('orders-changes')
    .on<DatabaseOrder>(
      'postgres_changes',
      {
        event: '*', // Listen to all events (INSERT, UPDATE, DELETE)
        schema: 'public',
        table: 'orders'
      },
      async (payload) => {
        console.log('Order change received:', payload)
        
        if (payload.eventType === 'INSERT') {
          // Fetch complete order data with items
          const { data: orderData } = await supabase
            .from('orders')
            .select(`
              *,
              order_items (
                id,
                quantity,
                unit_price,
                notes,
                products (
                  name
                )
              )
            `)
            .eq('id', payload.new.id)
            .single()

          if (orderData) {
            const formattedOrder: Order = {
              id: orderData.id,
              orderNumber: orderData.id.toString().slice(-4).padStart(4, '0'),
              table: orderData.table_number,
              status: orderData.status,
              created_at: orderData.created_at,
              total: orderData.total_amount,
              items: orderData.order_items.map(item => ({
                id: item.id,
                name: item.products.name,
                quantity: item.quantity,
                price: item.unit_price,
                note: item.notes
              }))
            }
            orders.value.unshift(formattedOrder)
            
            // Notification
            showToast.success(`Nouvelle commande #${formattedOrder.orderNumber}`, 'Table ' + formattedOrder.table)
          }
        } 
        else if (payload.eventType === 'UPDATE') {
          const index = orders.value.findIndex(o => o.id === payload.new.id)
          if (index !== -1) {
            orders.value[index] = {
              ...orders.value[index],
              status: payload.new.status
            }
          }
        }
        else if (payload.eventType === 'DELETE') {
          orders.value = orders.value.filter(o => o.id !== payload.old.id)
        }
      }
    )
    .subscribe()

  // Subscribe to order_items table changes
  const orderItemsSubscription = supabase
    .channel('order-items-changes')
    .on<OrderItem>(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'order_items'
      },
      async (payload) => {
        if (['INSERT', 'UPDATE', 'DELETE'].includes(payload.eventType)) {
          const orderId = payload.new?.order_id || payload.old?.order_id
          if (orderId) {
            const updatedOrder = await fetchOrderWithItems(orderId)
            if (updatedOrder) {
              const orderIndex = orders.value.findIndex(o => o.id === updatedOrder.id)
              if (orderIndex !== -1) {
                orders.value[orderIndex] = updatedOrder
              }
            }
          }
        }
      }
    )
    .subscribe()

  // Return cleanup function
  return () => {
    ordersSubscription.unsubscribe()
    orderItemsSubscription.unsubscribe()
  }
}

// Fetch a single order with its items
const fetchOrderWithItems = async (orderId) => {
  try {
    // Get the order
    const { data: orderData, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single()
    
    if (orderError) throw orderError
    
    // Get order items
    const { data: orderItems, error: itemsError } = await supabase
      .from('order_items')
      .select('*, products(name)')
      .eq('order_id', orderId)
    
    if (itemsError) throw itemsError
    
    // Process items with joined product data
    const itemsWithProductInfo = orderItems.map(item => {
      return {
        id: item.id,
        name: item.products?.name || 'Produit inconnu',
        quantity: item.quantity,
        price: item.unit_price,
        note: item.note
      }
    })
    
    return {
      id: orderData.id,
      orderNumber: orderData.id.toString().slice(-4).padStart(4, '0'),
      table: orderData.table_number,
      status: orderData.status,
      created_at: orderData.created_at,
      total: orderData.total_amount,
      items: itemsWithProductInfo
    }
  } catch (err) {
    console.error('Erreur lors du chargement de la commande:', err)
    return null
  }
}

// Watch for status changes to play sounds
watch(() => orders.value.filter(o => o.status === 'ready').length, (newCount, oldCount) => {
  if (newCount > oldCount) {
    // Play a different sound for ready orders
    playReadySound()
  }
})

// Play sound for ready orders
const playReadySound = () => {
  if (newOrderSound.value) {
    // You can add a different sound file for ready orders
    newOrderSound.value.currentTime = 0
    newOrderSound.value.play().catch(e => console.log('Erreur de lecture audio:', e))
  }
}

// Load orders when component mounts
onMounted(() => {
  fetchOrders()
  
  // Set up real-time subscriptions
  const unsubscribe = subscribeToOrders()
  
  // Set up connection monitoring
  setupConnectionMonitoring()
  
  // Clean up subscriptions when component unmounts
  onUnmounted(() => {
    unsubscribe()
    window.removeEventListener('online', () => {})
    window.removeEventListener('offline', () => {})
  })
})

definePageMeta({
  layout: 'staff'
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>