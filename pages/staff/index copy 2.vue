<template>
  <div class="container">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="logo">
        <img src="~/assets/images/logo.png" alt="Logo" class="w-10 h-10" />
      </div>
      <nav class="nav-menu">
        <NuxtLink to="/staff" class="nav-link active">
          <ClipboardList class="w-6 h-6" />
          <span>Commandes</span>
        </NuxtLink>
        <NuxtLink to="/staff/products" class="nav-link">
          <Package class="w-6 h-6" />
          <span>Produits</span>
        </NuxtLink>
        <NuxtLink to="/staff/stats" class="nav-link">
          <BarChart2 class="w-6 h-6" />
          <span>Statistiques</span>
        </NuxtLink>
        <button @click="logout" class="nav-link text-left">
          <LogOut class="w-6 h-6" />
          <span>Déconnexion</span>
        </button>
      </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <header class="header">
        <h1 class="text-xl font-bold">Gérer les Commandes</h1>
        <div class="search-container">
          <input 
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher une commande..."
            class="search-input"
          />
          <Search class="search-icon w-4 h-4" />
        </div>
      </header>

      <!-- Tabs -->
      <div class="tabs">
        <button 
          v-for="status in ['Toutes', 'Nouvelles', 'En préparation', 'Prêtes']"
          :key="status"
          @click="activeFilter = status"
          class="tab"
          :class="{ 'active': activeFilter === status }"
        >
          {{ status }}
          <span v-if="status !== 'Toutes'" class="tab-count">
            {{ getFilterCount(status) }}
          </span>
        </button>
      </div>

      <!-- Orders List -->
      <div class="command-list">
        <TransitionGroup name="list">
          <div 
            v-for="order in filteredOrders" 
            :key="order.id"
            class="command-card"
          >
            <div class="command-header">
              <span class="command-id">#{{ order.orderNumber }}</span>
              <span class="command-date">{{ formatTime(order.created_at) }}</span>
            </div>
            
            <div class="command-info">
              <div class="command-details">
                <div class="flex items-center gap-2 text-secondary">
                  <Coffee class="w-4 h-4" />
                  Table {{ order.table }}
                </div>
                <div class="command-items">
                  {{ order.items.length }} article(s)
                </div>
              </div>
              <div class="command-amount">
                {{ formatPrice(order.total) }}
              </div>
            </div>

            <div class="command-items-list">
              <div 
                v-for="item in order.items" 
                :key="item.id"
                class="command-item"
              >
                <span class="item-quantity">{{ item.quantity }}×</span>
                <span class="item-name">{{ item.name }}</span>
                <span class="item-price">{{ formatPrice(item.price * item.quantity) }}</span>
              </div>
            </div>

            <div class="command-status">
              <span 
                class="status-badge"
                :class="{
                  'status-pending': order.status === 'pending',
                  'status-preparing': order.status === 'preparing',
                  'status-ready': order.status === 'ready'
                }"
              >
                {{ translateStatus(order.status) }}
              </span>
              
              <div class="command-actions">
                <button 
                  v-if="order.status === 'pending'"
                  @click="updateOrderStatus(order.id, 'preparing')"
                  class="btn-action prepare"
                >
                  <ChefHat class="w-4 h-4" />
                  Préparer
                </button>
                <button 
                  v-if="order.status === 'preparing'"
                  @click="updateOrderStatus(order.id, 'ready')"
                  class="btn-action complete"
                >
                  <Check class="w-4 h-4" />
                  Terminer
                </button>
              </div>
            </div>
          </div>
        </TransitionGroup>
      </div>
    </main>
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
  Wifi,
  Package,
  BarChart2
} from 'lucide-vue-next'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'

const supabase = useSupabaseClient()
const router = useRouter()
const { showToast } = useCustomToast()

const orders = ref([])
const activeFilter = ref('Toutes')
const loading = ref(false)
const newOrderSound = ref(null)
const searchQuery = ref('')
const connectionStatus = ref('connected') // 'connected' or 'disconnected'
const latestActivity = ref(null) // Latest activity message

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

interface OrderItem {
  id: string
  order_id: string
  product_id: string
  quantity: number
  unit_price: number
  notes: string | null
  products: {
    name: string
  }
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
          // Nouvelle commande
          const order = payload.new
          
          // Récupérer les détails de la commande
          const { data: orderItems, error: itemsError } = await supabase
            .from('order_items')
            .select('*, products(name)')
            .eq('order_id', order.id)
          
          if (itemsError) {
            console.error('Erreur lors de la récupération des items:', itemsError)
            return
          }
          
          const formattedOrder: FormattedOrder = {
            id: order.id,
            orderNumber: order.id.toString().slice(-4).padStart(4, '0'),
            table: order.table_number,
            status: order.status,
            created_at: order.created_at,
            total: order.total_amount,
            items: orderItems.map(item => ({
              id: item.id,
              name: item.products.name,
              quantity: item.quantity,
              price: item.unit_price,
              note: item.notes
            }))
          }
          
          // Ajouter la nouvelle commande au début de la liste
          orders.value = [formattedOrder, ...orders.value]
          
          // Notifications
          if (order.status === 'pending') {
            playNotificationSound()
            const message = `Nouvelle commande #${formattedOrder.orderNumber} (Table ${formattedOrder.table})`
            showToast.success(message, 'Nouvelle commande')
            setLatestActivity(message)
          }
        } 
        else if (payload.eventType === 'UPDATE') {
          // Mise à jour d'une commande
          const updatedOrder = payload.new
          const index = orders.value.findIndex(o => o.id === updatedOrder.id)
          
          if (index !== -1) {
            orders.value[index] = {
              ...orders.value[index],
              status: updatedOrder.status
            }
            
            // Notification de changement de statut
            const statusMessages = {
              accepted: 'acceptée',
              rejected: 'refusée',
              preparing: 'en préparation',
              ready: 'prête',
              completed: 'terminée'
            }
            
            const message = `Commande #${orders.value[index].orderNumber} ${statusMessages[updatedOrder.status]}`
            setLatestActivity(message)
          }
        } 
        else if (payload.eventType === 'DELETE') {
          // Suppression d'une commande
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
/* Import des variables de couleur Twitter */
:root {
  --primary-color: #1DA1F2;
  --primary-hover: #1a91da;
  --secondary-color: #657786;
  --light-gray: #E1E8ED;
  --very-light-gray: #F5F8FA;
  --dark-text: #14171A;
  --danger-color: #E0245E;
  --success-color: #17BF63;
  --warning-color: #FFAD1F;
}

/* Layout */
.container {
  @apply grid grid-cols-[275px_1fr] min-h-screen bg-white;
}

/* Sidebar */
.sidebar {
  @apply p-5 border-r border-gray-200 fixed h-full w-[275px];
}

.nav-menu {
  @apply space-y-2 mt-8;
}

.nav-link {
  @apply flex items-center gap-3 px-4 py-3 rounded-full text-gray-700 hover:bg-blue-50 hover:text-blue-500 transition-colors;
}

.nav-link.active {
  @apply text-blue-500 bg-blue-50;
}

/* Main Content */
.main-content {
  @apply ml-[275px] min-h-screen border-l border-r border-gray-200;
}

/* Header */
.header {
  @apply sticky top-0 bg-white/80 backdrop-blur-sm border-b border-gray-200 p-4 flex justify-between items-center;
}

/* Search */
.search-container {
  @apply relative;
}

.search-input {
  @apply w-64 px-4 py-2 pl-10 bg-gray-100 rounded-full text-sm focus:bg-white focus:ring-2 focus:ring-blue-500 transition-all;
}

.search-icon {
  @apply absolute left-3 top-1/2 -translate-y-1/2 text-gray-400;
}

/* Tabs */
.tabs {
  @apply flex border-b border-gray-200;
}

.tab {
  @apply px-6 py-4 text-gray-600 hover:text-blue-500 relative transition-colors;
}

.tab.active {
  @apply text-blue-500;
}

.tab.active::after {
  content: '';
  @apply absolute bottom-0 left-1/2 -translate-x-1/2 w-12 h-1 bg-blue-500 rounded-full;
}

/* Command Cards */
.command-card {
  @apply bg-white border border-gray-200 rounded-xl p-4 mb-4 hover:shadow-md transition-all;
}

/* ... autres styles ... */
</style>