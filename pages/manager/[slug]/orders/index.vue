<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/90 border-b border-gray-200/20 shadow-sm">
      <div class="max-w-[1400px] mx-auto px-6 sm:px-8 py-6">
        <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
          <div class="max-w-2xl">
            <div class="flex items-center gap-3 mb-2">
              <h1 class="text-3xl font-bold text-gray-900">Commandes</h1>
              <div class="flex items-center gap-2 px-3 py-1 bg-gray-900/5 rounded-full">
                <span class="text-sm font-medium text-gray-600">{{ orders.length }} commandes</span>
              </div>
            </div>
            <p class="text-base text-gray-500">Gérez les commandes de votre établissement et suivez leur évolution.</p>
          </div>
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <div class="relative flex-1 sm:flex-none">
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
                class="w-full sm:w-64 pl-10 pr-4 h-11 rounded-full bg-white shadow-sm border border-gray-200/30 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
              />
              <Search class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
            </div>
            <button 
              @click="refreshData" 
              class="h-11 px-6 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
              :disabled="isRefreshing"
            >
              <RefreshCw class="w-4 h-4" :class="{ 'animate-spin': isRefreshing }" />
              <span>Actualiser</span>
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-full mx-auto px-6 sm:px-8 py-8 sm:py-10">
      <!-- Filter Tabs -->
      <div class="mb-8">
        <div class="flex overflow-x-auto gap-2 pb-4 scrollbar-hide">
          <button
            v-for="status in ['all', 'pending', 'preparing', 'ready', 'completed', 'cancelled']"
            :key="status"
            @click="filterStatus = status"
            class="h-11 px-5 rounded-full text-sm font-medium whitespace-nowrap transition-all"
            :class="[
              filterStatus === status
                ? 'bg-blue-600 text-white shadow-sm'
                : 'bg-white text-gray-700 border border-gray-200/50 hover:bg-gray-50'
            ]"
          >
            {{ translateStatus(status === 'all' ? status : status) }}
          </button>
        </div>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
        <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
        <p class="text-gray-500">Chargement des commandes...</p>
      </div>

      <!-- Empty state -->
      <div v-else-if="filteredOrders.length === 0" class="bg-white rounded-2xl shadow-sm p-8 text-center">
        <div class="w-16 h-16 mx-auto bg-gray-50 rounded-2xl flex items-center justify-center mb-4">
          <ClipboardList class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-gray-500 max-w-md mx-auto">
          {{ searchQuery 
            ? "Aucune commande ne correspond à votre recherche." 
            : filterStatus !== 'all' 
              ? `Aucune commande avec le statut "${translateStatus(filterStatus)}".` 
              : "Vous n'avez pas encore reçu de commandes." }}
        </p>
      </div>

      <!-- Orders List -->
      <div v-else class="space-y-6">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white rounded-2xl shadow-sm hover:shadow-md transition-all duration-300 overflow-hidden border border-gray-100/50"
        >
          <!-- Order Header -->
          <div class="flex justify-between items-center p-6 border-b border-gray-100">
            <div class="flex items-center gap-4">
              <div :class="[getStatusColor(order.status).bg, 'w-12 h-12 rounded-xl flex items-center justify-center']">
                <component :is="getStatusIcon(order.status)" class="w-6 h-6" :class="getStatusColor(order.status).text" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">Commande #{{ formatOrderNumber(order.id) }}</h3>
                <div class="flex items-center gap-3 mt-1">
                  <div class="flex items-center gap-1 text-sm text-gray-500">
                    <Clock class="w-4 h-4" />
                    <span>{{ formatDate(order.created_at) }}</span>
                  </div>
                  <div class="flex items-center gap-1 text-sm text-gray-500">
                    <TableIcon class="w-4 h-4" />
                    <span>Table {{ order.table_number || 'N/A' }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="flex items-center gap-3">
              <span class="text-xs px-3 py-1 rounded-full" :class="getStatusColor(order.status).badge">
                {{ translateStatus(order.status) }}
              </span>
              <span class="font-bold text-xl text-gray-900">{{ formatPrice(order.total_amount) }}</span>
            </div>
          </div>

          <!-- Order Items -->
          <div class="p-6 bg-gray-50 border-b border-gray-100">
            <h4 class="font-medium text-gray-900 mb-3">Articles commandés</h4>
            <div class="divide-y divide-gray-100/70">
              <div 
                v-for="item in order.items" 
                :key="item.id"
                class="py-3 flex justify-between items-center"
              >
                <div class="flex items-center gap-3">
                  <div class="bg-white w-8 h-8 rounded-lg flex items-center justify-center text-gray-500 font-medium border border-gray-100/30">
                    {{ item.quantity }}
                  </div>
                  <div>
                    <p class="font-medium text-gray-900">{{ item.name }}</p>
                    <p v-if="item.notes" class="text-xs text-gray-500 mt-0.5">Note: {{ item.notes }}</p>
                  </div>
                </div>
                <span class="font-medium text-gray-900">{{ formatPrice(item.unit_price * item.quantity) }}</span>
              </div>
            </div>
          </div>

          <!-- Order Actions -->
          <div class="p-6 flex justify-between items-center">
            <div v-if="order.notes" class="text-sm text-gray-500 max-w-md">
              <span class="font-medium">Notes:</span> {{ order.notes }}
            </div>
            <div class="flex-1"></div>
            <div class="flex items-center gap-3">
              <button
                v-if="order.status !== 'cancelled' && order.status !== 'completed'"
                @click="cancelOrder(order.id)"
                class="px-4 py-2 border border-red-200 text-red-600 hover:bg-red-50 rounded-lg text-sm font-medium transition-colors"
              >
                <span>Annuler</span>
              </button>
              <div v-if="order.status !== 'cancelled' && order.status !== 'completed'" class="relative">
                <button
                  @click="updateStatus(order)"
                  class="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors flex items-center gap-2"
                >
                  <span>{{ getNextStatusText(order.status) }}</span>
                  <ChevronsRight class="w-4 h-4" />
                </button>
              </div>
              <button
                @click="printOrder(order)"
                class="p-2 border border-gray-200 text-gray-600 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <Printer class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { 
  Search, RefreshCw, Clock, Table as TableIcon, Printer, 
  ChevronsRight, ClipboardList, CheckCircle, Coffee, 
  Loader2, X, ShoppingBag 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseClient } from '#imports'

// Route and Supabase
const route = useRoute()
const supabase = useSupabaseClient()
const slug = route.params.slug
const {showToast} = useCustomToast()

// State
const establishment = ref(null)
const orders = ref([])
const isLoading = ref(true)
const isRefreshing = ref(false)
const searchQuery = ref('')
const filterStatus = ref('all')

// Load establishment data
const loadEstablishment = async () => {
  try {
    // Vérifier si le slug est valide
    if (!slug) {
      showToast.error('Erreur', 'URL invalide')
      return
    }
    
    // Récupérer l'établissement sans utiliser .single() initialement
    const { data, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', slug)
    
    if (error) throw error
    
    // Vérifier si des données ont été trouvées
    if (!data || data.length === 0) {
      showToast.error('Erreur', 'Établissement introuvable')
      return
    }
    
    // Assigner le premier résultat
    establishment.value = data[0]
    
    // Une fois l'établissement chargé, configurer la subscription
    setupRealtimeSubscription()
  } catch (err) {
    console.error('Error loading establishment:', err)
    showToast.error('Erreur', 'Impossible de charger les données de l\'établissement')
  }
}

// Load orders
const loadOrders = async () => {
  if (!establishment.value?.id) return
  
  isLoading.value = true
  
  try {
    // Get all orders for this establishment
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
    
    if (ordersError) throw ordersError
    
    // Process orders with their items
    const processedOrders = await Promise.all(ordersData.map(async (order, index) => {
      try {
        // Get items for this order
        const { data: itemsData, error: itemsError } = await supabase
          .from('order_items')
          .select('*')
          .eq('order_id', order.id)
        
        if (itemsError) throw itemsError
        
        // Format each item with product details
        const items = await Promise.all(itemsData.map(async (item) => {
          // Get product details
          const { data: product } = await supabase
            .from('products')
            .select('name, description')
            .eq('id', item.product_id)
            .single()
          
          return {
            ...item,
            name: product?.name || 'Produit inconnu',
            description: product?.description || ''
          }
        }))
        
        return {
          ...order,
          items,
          orderNumber: 1000 + index
        }
      } catch (err) {
        console.error(`Error loading items for order ${order.id}:`, err)
        return {
          ...order,
          items: [],
          orderNumber: 1000 + index
        }
      }
    }))
    
    orders.value = processedOrders
  } catch (err) {
    console.error('Error loading orders:', err)
    showToast.error('Erreur', 'Impossible de charger les commandes')
  } finally {
    isLoading.value = false
    isRefreshing.value = false
  }
}

// Refresh data
const refreshData = async () => {
  isRefreshing.value = true
  await loadOrders()
}

// Filter orders
const filteredOrders = computed(() => {
  let filtered = [...orders.value]
  
  // Filter by status
  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === filterStatus.value)
  }
  
  // Filter by search query
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => 
      order.orderNumber?.toString().includes(query) || 
      order.table_number?.toString().includes(query) ||
      order.items?.some(item => item.name?.toLowerCase().includes(query))
    )
  }
  
  return filtered
})

// Update order status
const updateStatus = async (order) => {
  const statusFlow = {
    'pending': 'preparing',
    'preparing': 'ready',
    'ready': 'completed'
  }
  
  const newStatus = statusFlow[order.status]
  if (!newStatus) return
  
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: newStatus })
      .eq('id', order.id)
    
    if (error) throw error
    
    // Update local state
    const index = orders.value.findIndex(o => o.id === order.id)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }
    
    showToast.success('Statut mis à jour', `Commande #${order.orderNumber} ${getStatusMessage(newStatus)}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

// Cancel order
const cancelOrder = async (orderId) => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) return
  
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: 'cancelled' })
      .eq('id', orderId)
    
    if (error) throw error
    
    // Update local state
    const index = orders.value.findIndex(o => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = 'cancelled'
    }
    
    const order = orders.value.find(o => o.id === orderId)
    showToast.success('Commande annulée', `Commande #${order?.orderNumber || ''} a été annulée`)
  } catch (err) {
    console.error('Error cancelling order:', err)
    showToast.error('Erreur', 'Impossible d\'annuler la commande')
  }
}

// Print order
const printOrder = (order) => {
  // Create a printable version of the order
  const printWindow = window.open('', '', 'width=800,height=600')
  
  if (!printWindow) {
    showToast.error('Erreur', 'Impossible d\'ouvrir la fenêtre d\'impression')
    return
  }
  
  printWindow.document.write(`
    <html>
      <head>
        <title>Commande #${order.orderNumber}</title>
        <style>
          body { font-family: system-ui, -apple-system, sans-serif; padding: 20px; }
          h1 { margin-bottom: 10px; }
          .header { margin-bottom: 20px; }
          .items { margin-top: 20px; border-top: 1px solid #eee; padding-top: 20px; }
          .item { padding: 10px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; }
          .total { margin-top: 20px; font-weight: bold; text-align: right; }
          .notes { margin-top: 20px; font-style: italic; }
          .info { color: #666; font-size: 14px; margin: 5px 0; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Commande #${order.orderNumber}</h1>
          <p class="info">Date: ${formatDate(order.created_at)}</p>
          <p class="info">Table: ${order.table_number || 'N/A'}</p>
          <p class="info">Statut: ${translateStatus(order.status)}</p>
        </div>
        
        <div class="items">
          <h2>Articles commandés</h2>
          ${order.items.map(item => `
            <div class="item">
              <div>
                <strong>${item.quantity}x</strong> ${item.name}
                ${item.notes ? `<p><small>Note: ${item.notes}</small></p>` : ''}
              </div>
              <div>${formatPrice(item.unit_price * item.quantity)}</div>
            </div>
          `).join('')}
        </div>
        
        <div class="total">
          Total: ${formatPrice(order.total_amount)}
        </div>
        
        ${order.notes ? `
          <div class="notes">
            <p><strong>Notes:</strong> ${order.notes}</p>
          </div>
        ` : ''}
      </body>
    </html>
  `)
  
  printWindow.document.close()
  printWindow.focus()
  
  // Print after a short delay to ensure content is loaded
  setTimeout(() => {
    printWindow.print()
    printWindow.close()
  }, 500)
}

// Utility functions
const formatOrderNumber = (id) => {
  return id.toString().slice(-4).padStart(4, '0')
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleString('fr-FR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const getStatusColor = (status) => {
  const colors = {
    'pending': {
      bg: 'bg-yellow-50',
      text: 'text-yellow-500',
      badge: 'bg-yellow-100 text-yellow-800'
    },
    'preparing': {
      bg: 'bg-blue-50',
      text: 'text-blue-500',
      badge: 'bg-blue-100 text-blue-800'
    },
    'ready': {
      bg: 'bg-green-50',
      text: 'text-green-500',
      badge: 'bg-green-100 text-green-800'
    },
    'completed': {
      bg: 'bg-gray-50',
      text: 'text-gray-500',
      badge: 'bg-gray-100 text-gray-800'
    },
    'cancelled': {
      bg: 'bg-red-50',
      text: 'text-red-500',
      badge: 'bg-red-100 text-red-800'
    }
  }
  
  return colors[status] || colors.pending
}

const getStatusIcon = (status) => {
  const icons = {
    'pending': Clock,
    'preparing': Coffee,
    'ready': CheckCircle,
    'completed': CheckCircle,
    'cancelled': X
  }
  
  return icons[status] || Clock
}

const translateStatus = (status) => {
  const translations = {
    'all': 'Toutes',
    'pending': 'En attente',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'cancelled': 'Annulée'
  }
  
  return translations[status] || status
}

const getNextStatusText = (status) => {
  const nextStatus = {
    'pending': 'Commencer la préparation',
    'preparing': 'Marquer comme prête',
    'ready': 'Marquer comme terminée'
  }
  
  return nextStatus[status] || 'Mettre à jour'
}

const getStatusMessage = (status) => {
  const messages = {
    'preparing': 'est en préparation',
    'ready': 'est prête',
    'completed': 'est terminée',
    'cancelled': 'a été annulée'
  }
  
  return messages[status] || 'a changé de statut'
}

// SetUp realtime subscription
let subscription
const setupRealtimeSubscription = () => {
  if (!establishment.value?.id) return
  
  // Cancel any existing subscription
  if (subscription) {
    subscription.unsubscribe()
  }
  
  // Create new subscription for order updates
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
        // Handle new or updated orders
        if (payload.eventType === 'INSERT') {
          // Add new order to the list
          showToast.success('Nouvelle commande', 'Une nouvelle commande a été reçue')
          loadOrders() // Reload all orders to get the complete data
        } else if (payload.eventType === 'UPDATE') {
          // Update existing order
          const index = orders.value.findIndex(o => o.id === payload.new.id)
          if (index !== -1) {
            orders.value[index] = { ...orders.value[index], ...payload.new }
          }
        }
      }
    )
    .subscribe()
}

// Clean up on component unmount
onUnmounted(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

// Watch establishment changes to set up realtime subscription
watch(establishment, (newValue) => {
  if (newValue) {
    setupRealtimeSubscription()
  }
})

// Load data on mount
onMounted(async () => {
  try {
    isLoading.value = true
    await loadEstablishment()
    
    // Vérifier si l'établissement a été chargé avec succès
    if (establishment.value) {
      await loadOrders()
    }
  } catch (err) {
    console.error('Error initializing page:', err)
    showToast.error('Erreur', 'Impossible de charger la page')
  } finally {
    isLoading.value = false
  }
})

// Define page meta
definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style> 