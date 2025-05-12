<template>
  <div class="min-h-screen bg-white">
    <!-- En-tête simplifié -->
    <header class="sticky top-0 z-50 bg-white border-b">
      <div class="px-4 py-3 sm:px-6 sm:py-4">
        <div class="flex items-center justify-between">
          <h1 class="text-lg sm:text-xl font-medium text-gray-900">Commandes</h1>
          <div class="flex items-center gap-3">
            <div class="flex items-center gap-2">
              <div class="w-2 h-2 rounded-full" :class="isOnline ? 'bg-green-500' : 'bg-gray-300'"></div>
              <span class="text-sm text-gray-600">{{ isOnline ? 'En ligne' : 'Hors ligne' }}</span>
            </div>
            <button 
              @click="toggleSound"
              class="p-2 text-gray-500 hover:text-gray-900"
            >
              <component :is="isSoundEnabled ? Volume2 : VolumeX" class="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="px-4 py-4 sm:px-6 max-w-5xl mx-auto">
      <!-- Filtres style Leboncoin -->
      <div class="flex gap-2 overflow-x-auto pb-4">
        <button
          v-for="status in ['all', 'pending', 'preparing', 'ready']"
          :key="status"
          @click="statusFilter = status"
          class="h-10 px-5 text-sm font-medium whitespace-nowrap transition-all"
          :class="[
            statusFilter === status 
              ? 'bg-orange-500 text-white rounded-full' 
              : 'text-gray-700 hover:bg-gray-100 rounded-full'
          ]"
        >
          {{ status === 'all' ? 'Toutes' : translateStatus(status) }}
          <span v-if="status !== 'all'" class="ml-2 text-xs">
            {{ orders.filter(o => o.status === status).length }}
          </span>
        </button>
      </div>

      <!-- Liste des commandes style Leboncoin -->
      <div class="mt-6 space-y-4">
        <div
          v-for="order in filteredOrders"
          :key="order.id"
          class="bg-white border rounded-lg hover:shadow-md transition-shadow"
        >
          <div class="p-5">
            <!-- En-tête avec statut et temps -->
            <div class="flex items-start justify-between gap-4">
              <div class="flex items-center gap-4">
                <div :class="[
                  'w-14 h-14 rounded-lg flex items-center justify-center',
                  order.status === 'pending' ? 'bg-orange-50 text-orange-600' :
                  order.status === 'preparing' ? 'bg-blue-50 text-blue-600' :
                  'bg-green-50 text-green-600'
                ]">
                  <component 
                    :is="getStatusIcon(order.status)"
                    class="w-7 h-7"
                  />
                </div>
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-xl font-medium text-gray-900">#{{ order.orderNumber }}</span>
                    <span class="px-3 py-1 rounded-full text-sm font-medium"
                      :class="[
                        order.status === 'pending' ? 'bg-orange-50 text-orange-600' :
                        order.status === 'preparing' ? 'bg-blue-50 text-blue-600' :
                        'bg-green-50 text-green-600'
                      ]"
                    >
                      {{ translateStatus(order.status) }}
                    </span>
                  </div>
                  <div class="flex items-center gap-2 mt-1.5 text-sm text-gray-500">
                    <TableIcon class="w-4 h-4" />
                    <span>Table {{ order.table }}</span>
                    <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                    <span>{{ formatTime(order.created_at) }}</span>
                  </div>
                </div>
              </div>
              
              <!-- Actions rapides -->
              <div class="flex items-center gap-2">
                <button
                  v-if="order.status === 'pending'"
                  @click="updateOrderStatus(order.id, 'preparing')"
                  class="h-10 px-6 bg-orange-500 text-white rounded-full text-sm font-medium hover:bg-orange-600"
                >
                  Accepter
                </button>
                <button
                  v-if="order.status === 'preparing'"
                  @click="updateOrderStatus(order.id, 'ready')"
                  class="h-10 px-6 bg-orange-500 text-white rounded-full text-sm font-medium hover:bg-orange-600"
                >
                  Prêt
                </button>
                <button
                  v-if="order.status === 'ready'"
                  @click="updateOrderStatus(order.id, 'completed')"
                  class="h-10 px-6 bg-orange-500 text-white rounded-full text-sm font-medium hover:bg-orange-600"
                >
                  Terminé
                </button>
              </div>
            </div>

            <!-- Liste des articles -->
            <div class="mt-6 pl-[4.5rem]">
              <div class="space-y-3">
                <div 
                  v-for="item in order.items" 
                  :key="item.id"
                  class="flex justify-between items-center text-sm"
                >
                  <div class="flex items-center gap-2">
                    <span class="font-medium text-gray-900">{{ item.quantity }}×</span>
                    <span class="text-gray-600">{{ item.name }}</span>
                  </div>
                  <span class="text-gray-900">{{ formatPrice(item.price) }}</span>
                </div>
                <!-- Total -->
                <div class="flex justify-between items-center pt-3 border-t">
                  <span class="font-medium text-gray-900">Total</span>
                  <span class="text-lg font-medium text-gray-900">{{ formatPrice(order.total) }}</span>
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
  BarChart2,
  ShoppingCart,
  Filter,
  Volume2,
  VolumeX,
  Table as TableIcon
} from 'lucide-vue-next'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'
import type { 
  Order, 
  OrderItem, 
  OrderStatus, 
  StatusMessage,
  DatabaseOrder,
  DatabaseOrderItem,
  ConnectionStatus 
} from '~/types'

const supabase = useSupabaseClient()
const router = useRouter()
const { showToast } = useCustomToast()

// State avec typage
const orders = ref<Order[]>([])
const activeFilter = ref('Toutes')
const loading = ref(false)
const latestActivity = ref<string | null>(null)
const newOrderSound = ref<HTMLAudioElement | null>(null)
const isOnline = ref(true)
const searchQuery = ref('')
const connectionStatus = ref<ConnectionStatus>('connected')
const showFilters = ref(false)
const statusFilter = ref('all')
const isSoundEnabled = ref(true)

// Typage des fonctions
const statusMessages: StatusMessage = {
  accepted: 'acceptée',
  rejected: 'refusée',
  preparing: 'en préparation',
  ready: 'prête',
  completed: 'terminée'
}

const translateStatus = (status: OrderStatus): string => {
  const translations: Record<OrderStatus, string> = {
    'pending': 'Nouvelle',
    'accepted': 'Acceptée',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'rejected': 'Refusée'
  }
  return translations[status]
}

const getFilterCount = (filter: string): number => {
  if (filter === 'Toutes') {
    return orders.value.filter((order: Order) => 
      ['pending', 'preparing', 'ready'].includes(order.status)
    ).length
  }
  
  return orders.value.filter((order: Order) => 
    statusMap[filter]?.includes(order.status)
  ).length
}

const formatTime = (dateString: string): string => {
  const now = new Date()
  const orderTime = new Date(dateString)
  const diffMinutes = Math.floor((now.getTime() - orderTime.getTime()) / (1000 * 60))
  
  if (diffMinutes < 1) return 'À l\'instant'
  if (diffMinutes === 1) return 'Il y a 1 min'
  if (diffMinutes < 60) return `Il y a ${diffMinutes} min`
  
  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours === 1) return 'Il y a 1h'
  return `Il y a ${diffHours}h`
}

const updateOrderStatus = async (orderId: string, newStatus: OrderStatus) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)
    
    if (error) throw error

    const orderNumber = orders.value.find(o => o.id === orderId)?.orderNumber
    if (!orderNumber) return

    const notificationMessage = `Commande #${orderNumber} ${statusMessages[newStatus]}`
    showToast.success(notificationMessage, 'success')
    setLatestActivity(notificationMessage)
  } catch (err) {
    console.error('Erreur mise à jour:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

const setLatestActivity = (message: string): void => {
  latestActivity.value = message
  setTimeout(() => {
    if (latestActivity.value === message) {
      latestActivity.value = null
    }
  }, 10000)
}

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

const statusMap: Record<string, OrderStatus[]> = {
  'Toutes': ['pending', 'accepted', 'preparing', 'ready'],
  'Nouvelles': ['pending'],
  'Acceptées': ['accepted'],
  'En préparation': ['preparing'],
  'Prêtes': ['ready']
}

// Filter orders by status and search query
const filteredOrders = computed(() => {
  let filtered = [...orders.value]
  
  // Filter by status
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter((order: Order) => 
      statusMap[statusFilter.value]?.includes(order.status)
    )
  } else {
    filtered = filtered.filter((order: Order) => 
      !['completed', 'cancelled', 'rejected'].includes(order.status)
    )
  }
  
  // Filter by search query
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter((order: Order) => {
      // Search by order number
      if (order.orderNumber.toLowerCase().includes(query)) return true
      // Search by table number
      if (order.table.toString().includes(query)) return true
      // Search by items
      if (order.items.some((item: OrderItem) => 
        item.name.toLowerCase().includes(query)
      )) return true
      return false
    })
  }
  
  return filtered
})

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
const printOrder = (order: Order) => {
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
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
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
const fetchOrderWithItems = async (orderId: string) => {
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

// Ajoutez ces types pour les données de la base de données
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
  items: OrderItem[]
}

const getStatusColor = (status: OrderStatus) => {
  const colors: Record<OrderStatus, { bg: string; text: string; badge: string }> = {
    'pending': { bg: 'bg-yellow-50', text: 'text-yellow-700', badge: 'bg-yellow-100' },
    'accepted': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100' },
    'preparing': { bg: 'bg-blue-50', text: 'text-blue-700', badge: 'bg-blue-100' },
    'ready': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100' },
    'completed': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100' },
    'rejected': { bg: 'bg-red-50', text: 'text-red-700', badge: 'bg-red-100' }
  }
  return colors[status]
}

const getStatusIcon = (status: OrderStatus) => {
  const icons: Record<OrderStatus, Component> = {
    'pending': Coffee,
    'accepted': CheckCircle,
    'preparing': ChefHat,
    'ready': CheckCircle,
    'completed': CheckCircle,
    'rejected': X
  }
  return icons[status]
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const toggleSound = () => {
  isSoundEnabled.value = !isSoundEnabled.value
}
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

.pattern-grid {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Cpath fill='%23000000' d='M8 21H4a1 1 0 0 1-1-1v-4a1 1 0 0 0-2 0v4a3 3 0 0 0 3 3h4a1 1 0 0 0 0-2m14-6a1 1 0 0 0-1 1v4a1 1 0 0 1-1 1h-4a1 1 0 0 0 0 2h4a3 3 0 0 0 3-3v-4a1 1 0 0 0-1-1M20 1h-4a1 1 0 0 0 0 2h4a1 1 0 0 1 1 1v4a1 1 0 0 0 2 0V4a3 3 0 0 0-3-3M2 9a1 1 0 0 0 1-1V4a1 1 0 0 1 1-1h4a1 1 0 0 0 0-2H4a3 3 0 0 0-3 3v4a1 1 0 0 0 1 1m8-4H6a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1M9 9H7V7h2Zm5 2h4a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1m1-4h2v2h-2Zm-5 6H6a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1m-1 4H7v-2h2Zm5-1a1 1 0 0 0 1-1a1 1 0 0 0 0-2h-1a1 1 0 0 0-1 1v1a1 1 0 0 0 1 1m4-3a1 1 0 0 0-1 1v3a1 1 0 0 0 0 2h1a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1m-4 4a1 1 0 1 0 1 1a1 1 0 0 0-1-1'/%3E%3C/svg%3E");
  background-repeat: repeat;
  background-size: 48px 48px; /* Double size for better visibility */
  transform: rotate(0deg);
  animation: patternFloat 60s linear infinite;
}

@keyframes patternFloat {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 48px 48px;
  }
}

/* ... reste des styles ... */
</style>