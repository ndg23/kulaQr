<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Commandes"
      subtitle="Gérez vos commandes en temps réel"
      :icon="Clock"
      :primary-action="{
        label: 'Imprimer',
        icon: Printer,
        action: printOrders
      }"
    />

    <!-- Search Bar -->
    <div class="max-w-7xl mx-auto px-6 py-4">
      <div class="relative">
        <Search class="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
          class="w-full pl-10 pr-4 py-3 bg-white border border-gray-200 rounded-full text-sm focus:ring-2 focus:ring-gray-500 focus:border-transparent transition-all"
        />
      </div>
    </div>

    <main class="max-w-7xl mx-auto px-6 py-8">
      <!-- Status Filters -->
      <ManagerModernCard class="p-6 mb-6">
        <div class="flex flex-wrap gap-3">
          <button
            v-for="status in statusOptions"
            :key="status.key"
            @click="activeStatus = status.key"
            :class="[
              'px-6 py-3 rounded-full text-sm font-medium transition-all flex items-center gap-2',
              activeStatus === status.key
                ? 'bg-black text-white'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            ]"
          >
            <component :is="status.icon" class="w-4 h-4" />
            {{ status.label }}
            <span class="bg-white/20 px-2 py-0.5 rounded-full text-xs">
              {{ getStatusCount(status.key) }}
            </span>
          </button>
        </div>
      </ManagerModernCard>

      <!-- Loading State -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20">
        <div class="w-16 h-16 relative">
          <div class="w-16 h-16 bg-gray-100 rounded-full animate-pulse"></div>
          <Loader2 class="w-8 h-8 text-gray-400 animate-spin absolute inset-0 m-auto" />
        </div>
        <p class="text-sm text-gray-500 mt-4">Chargement des commandes...</p>
      </div>

      <!-- Orders Grid -->
      <div v-else-if="filteredOrders.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <ManagerModernCard
          v-for="order in filteredOrders" 
          :key="order.id"
          class="overflow-hidden"
        >
          <!-- Order Header -->
          <div class="p-4 border-b border-gray-100">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-900">#{{ order.orderNumber || order.id.slice(-6) }}</span>
              <StatusBadge :status="order.status" />
            </div>
            <div class="flex items-center justify-between text-sm text-gray-500">
              <span>Table {{ order.table || order.table_number }}</span>
              <span>{{ formatTime(order.created_at) }}</span>
            </div>
          </div>

          <!-- Order Items -->
          <div class="p-4">
            <div class="space-y-2 mb-4">
              <div 
                v-for="item in order.items.slice(0, 3)"
                :key="item.id"
                class="flex items-center justify-between text-sm"
              >
                <span class="text-gray-700">{{ item.quantity }}x {{ item.name }}</span>
                <span class="text-gray-500">{{ formatPrice(item.unit_price * item.quantity) }}</span>
                  </div>
              <div v-if="order.items.length > 3" class="text-xs text-gray-400">
                +{{ order.items.length - 3 }} autres articles
              </div>
            </div>

            <!-- Order Total -->
            <div class="flex items-center justify-between pt-3 border-t border-gray-100">
              <span class="font-semibold text-gray-900">Total</span>
              <span class="font-semibold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
            </div>
          </div>

          <!-- Order Actions -->
          <div class="px-4 pb-4">
            <div class="flex gap-2">
              <button
                v-if="canAcceptOrder(order.status)"
                @click="updateOrderStatus(order.id, 'accepted')"
                class="flex-1 bg-green-500 hover:bg-green-600 text-white px-3 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                Accepter
              </button>
              <button
                v-if="canPrepareOrder(order.status)"
                @click="updateOrderStatus(order.id, 'preparing')"
                class="flex-1 bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                Préparer
              </button>
                <button
                v-if="canCompleteOrder(order.status)"
                @click="updateOrderStatus(order.id, 'ready')"
                class="flex-1 bg-purple-500 hover:bg-purple-600 text-white px-3 py-2 rounded-lg text-sm font-medium transition-colors"
                >
                Prêt
                </button>
              <button
                v-if="canCompleteOrder(order.status)"
                @click="updateOrderStatus(order.id, 'completed')"
                class="flex-1 bg-gray-500 hover:bg-gray-600 text-white px-3 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                Terminer
              </button>
            </div>
          </div>
        </ManagerModernCard>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-16">
        <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Receipt class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-gray-500">
          Les nouvelles commandes apparaîtront ici automatiquement.
        </p>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { 
  Search, RefreshCw, Clock, Table as TableIcon, Printer, 
  ChevronsRight, ClipboardList, CheckCircle, Coffee, 
  Loader2, X, ShoppingBag, Receipt
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
const orders = ref([] as any[])
const loading = ref(true)
const searchQuery = ref('')
const activeStatus = ref('all')

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
  
  loading.value = true
  
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
    loading.value = false
  }
}

// Status options for filter
const statusOptions = [
  { key: 'all', label: 'Toutes', icon: ClipboardList },
  { key: 'pending', label: 'En attente', icon: Clock },
  { key: 'processing', label: 'En traitement', icon: Coffee },
  { key: 'completed', label: 'Terminées', icon: CheckCircle },
  { key: 'cancelled', label: 'Annulées', icon: X }
]

// Get status count
const getStatusCount = (status: string) => {
  if (status === 'all') return orders.value.length
  return orders.value.filter(order => order.status === status).length
}

// Check if order can be accepted
const canAcceptOrder = (status: string) => status === 'pending'

// Check if order can be prepared
const canPrepareOrder = (status: string) => status === 'accepted'

// Check if order can be completed
const canCompleteOrder = (status: string) => status === 'preparing' || status === 'ready'

// Update order status
const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: newStatus })
      .eq('id', orderId)
    
    if (error) throw error
    
    // Update local state
    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }
    
    const order = orders.value.find((o: any) => o.id === orderId)
    showToast.success('Statut mis à jour', `Commande #${order?.orderNumber || orderId.slice(-6)} ${getStatusMessage(newStatus)}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

// Print orders
const printOrders = () => {
  // For now, just show a toast - could be expanded to print all orders
  showToast.info('Impression', 'Fonction d\'impression à implémenter')
}

// Format time
const formatTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Filter orders
const filteredOrders = computed(() => {
  let filtered = [...orders.value]
  
  // Filter by status
  if (activeStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === activeStatus.value)
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
const updateStatus = async (order: any) => {
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
    const index = orders.value.findIndex((o: any) => o.id === order.id)
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
const cancelOrder = async (orderId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) return
  
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: 'cancelled' })
      .eq('id', orderId)
    
    if (error) throw error
    
    // Update local state
    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = 'cancelled'
    }
    
    const order = orders.value.find((o: any) => o.id === orderId)
    showToast.success('Commande annulée', `Commande #${order?.orderNumber || ''} a été annulée`)
  } catch (err) {
    console.error('Error cancelling order:', err)
    showToast.error('Erreur', 'Impossible d\'annuler la commande')
  }
}

// Print order
const printOrder = (order: any) => {
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
const formatOrderNumber = (id: string) => {
  return id.toString().slice(-4).padStart(4, '0')
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleString('fr-FR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const getStatusColor = (status: string) => {
  const colors = {
    'pending': {
      bg: 'bg-yellow-50',
      text: 'text-yellow-500',
      badge: 'bg-yellow-100 text-yellow-800'
    },
    'processing': {
      bg: 'bg-blue-50',
      text: 'text-blue-500',
      badge: 'bg-blue-100 text-blue-800'
    },
    'completed': {
      bg: 'bg-green-50',
      text: 'text-green-500',
      badge: 'bg-green-100 text-green-800'
    },
    'cancelled': {
      bg: 'bg-red-50',
      text: 'text-red-500',
      badge: 'bg-red-100 text-red-800'
    }
  }
  
  return colors[status] || colors.pending
}

const getStatusIcon = (status: string) => {
  const icons = {
    'pending': Clock,
    'processing': Coffee,
    'completed': CheckCircle,
    'cancelled': X
  }
  
  return icons[status] || Clock
}

const translateStatus = (status: string) => {
  const translations = {
    'all': 'Toutes',
    'pending': 'En attente',
    'processing': 'En traitement',
    'completed': 'Terminée',
    'cancelled': 'Annulée'
  }
  
  return translations[status] || status
}

const getNextStatusText = (status: string) => {
  const nextStatus = {
    'pending': 'Commencer la préparation',
    'preparing': 'Marquer comme prête',
    'ready': 'Marquer comme terminée'
  }
  
  return nextStatus[status] || 'Mettre à jour'
}

const getStatusMessage = (status) => {
  const messages = {
    'processing': 'est en traitement',
    'completed': 'est terminée'
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
    loading.value = true
    await loadEstablishment()
    
    // Vérifier si l'établissement a été chargé avec succès
    if (establishment.value) {
      await loadOrders()
    }
  } catch (err) {
    console.error('Error initializing page:', err)
    showToast.error('Erreur', 'Impossible de charger la page')
  } finally {
    loading.value = false
  }
})

// Watch for route changes to reload data
  watch(() => route.path, async (newPath, oldPath) => {
    console.log('🔄 Route changed, reloading orders data for path:', newPath)
    try {
      loading.value = true
      await loadEstablishment()
      
      if (establishment.value) {
        await loadOrders()
      }
    } catch (err) {
      console.error('Error reloading data:', err)
      showToast.error('Erreur', 'Impossible de recharger les données')
    } finally {
      loading.value = false
    }
  
}, { immediate: true })

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