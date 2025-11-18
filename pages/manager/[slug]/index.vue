<template>
  <div class="min-h-screen bg-white">
    <!-- Minimal Header -->
    <div class="border-b border-gray-100">
      <div class="max-w-7xl mx-auto px-6 sm:px-8 py-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl font-semibold text-gray-900 tracking-tight">Dashboard</h1>
            <p class="text-sm text-gray-500 mt-1">Vue d'ensemble de votre établissement</p>
          </div>
          <button
            @click="refreshData"
            :disabled="isRefreshing"
            class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900 transition-colors"
          >
            <RefreshCw :class="['w-4 h-4', isRefreshing && 'animate-spin']" />
            Actualiser
          </button>
        </div>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-6 sm:px-8 py-12">
      <!-- Welcome Section -->
      <div class="mb-16">
        <h2 class="text-5xl font-semibold text-gray-900 tracking-tight mb-3">
          Bonjour, {{ user?.user_metadata?.full_name?.split(' ')[0] || 'Manager' }}
        </h2>
        <p class="text-xl text-gray-500">Résumé de votre activité</p>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="flex justify-center items-center py-32">
        <div class="animate-spin rounded-full h-12 w-12 border-2 border-gray-200 border-t-gray-900"></div>
      </div>

      <div v-else class="space-y-16">
        <!-- Main Metrics - Large & Impactful -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div 
            v-for="stat in mainMetrics" 
            :key="stat.name"
            class="bg-gray-50 rounded-3xl p-10 hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <component :is="stat.icon" class="w-10 h-10 text-gray-900 mb-6" />
            <p class="text-5xl font-semibold text-gray-900 mb-3 tracking-tight">{{ stat.value }}</p>
            <span class="text-base text-gray-500">{{ stat.name }}</span>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <NuxtLink 
            :to="`/manager/${establishment?.id}/orders`"
            class="group bg-white border border-gray-200 rounded-3xl p-10 hover:border-gray-900 transition-all"
          >
            <ShoppingCart class="w-8 h-8 text-gray-900 mb-6" />
            <h3 class="text-xl font-semibold text-gray-900 mb-2">Commandes</h3>
            <p class="text-sm text-gray-500">{{ recentOrders.length }} commandes récentes</p>
          </NuxtLink>
            
          <NuxtLink 
            :to="`/manager/${establishment?.id}/menu`"
            class="group bg-white border border-gray-200 rounded-3xl p-10 hover:border-gray-900 transition-all"
          >
            <ChefHat class="w-8 h-8 text-gray-900 mb-6" />
            <h3 class="text-xl font-semibold text-gray-900 mb-2">Menu</h3>
            <p class="text-sm text-gray-500">{{ popularProducts.length }} produits</p>
          </NuxtLink>

          <NuxtLink 
            :to="`/manager/${establishment?.id}/qr-codes`"
            class="group bg-white border border-gray-200 rounded-3xl p-10 hover:border-gray-900 transition-all"
          >
            <QrCode class="w-8 h-8 text-gray-900 mb-6" />
            <h3 class="text-xl font-semibold text-gray-900 mb-2">QR Code</h3>
            <p class="text-sm text-gray-500">Menu digital</p>
          </NuxtLink>
        </div>

        <!-- Current Orders Section -->
        <div>
          <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-semibold text-gray-900 tracking-tight">Commandes actuelles</h2>
            <NuxtLink
              :to="`/manager/${establishment?.id}/orders`"
              class="text-sm font-medium text-gray-900 hover:text-gray-600 transition-colors inline-flex items-center gap-2"
            >
              Voir tout
              <ArrowRight class="w-4 h-4" />
            </NuxtLink>
          </div>

          <!-- Order Stats -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-gray-50 rounded-2xl p-6">
              <p class="text-3xl font-semibold text-gray-900 mb-1">{{ currentOrdersStats.total }}</p>
              <p class="text-sm text-gray-500">Total</p>
            </div>

            <div class="bg-yellow-50 rounded-2xl p-6">
              <p class="text-3xl font-semibold text-gray-900 mb-1">{{ currentOrdersStats.pending }}</p>
              <p class="text-sm text-gray-500">En attente</p>
            </div>

            <div class="bg-orange-50 rounded-2xl p-6">
              <p class="text-3xl font-semibold text-gray-900 mb-1">{{ currentOrdersStats.processing }}</p>
              <p class="text-sm text-gray-500">En préparation</p>
            </div>

            <div class="bg-green-50 rounded-2xl p-6">
              <p class="text-3xl font-semibold text-gray-900 mb-1">{{ currentOrdersStats.ready }}</p>
              <p class="text-sm text-gray-500">Prêtes</p>
            </div>
          </div>

          <!-- Orders List -->
          <div v-if="currentOrders.length === 0" class="text-center py-24 bg-gray-50 rounded-3xl">
            <ShoppingCart class="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h4 class="text-lg font-semibold text-gray-900 mb-2">Aucune commande en cours</h4>
            <p class="text-gray-500">Les nouvelles commandes apparaîtront ici</p>
          </div>

          <div v-else class="space-y-4">
            <div
              v-for="order in currentOrders.slice(0, 6)"
              :key="order.id"
              class="bg-white border border-gray-200 rounded-2xl p-6 hover:border-gray-900 transition-all"
            >
              <div class="flex items-start justify-between mb-6">
                <div class="flex-1">
                  <div class="flex items-center gap-3 mb-3">
                    <span class="text-sm font-mono font-medium text-gray-500">#{{ order.id.slice(-4) }}</span>
                    <span
                      :class="[
                        'px-3 py-1 text-xs font-medium rounded-full',
                        order.status === 'pending' && 'bg-yellow-100 text-yellow-900',
                        order.status === 'confirmed' && 'bg-blue-100 text-blue-900',
                        order.status === 'processing' && 'bg-orange-100 text-orange-900',
                        order.status === 'completed' && 'bg-green-100 text-green-900'
                      ]"
                    >
                      {{ getStatusText(order.status) }}
                    </span>
                  </div>
                  
                  <!-- Table Info Enrichie -->
                  <div class="mb-3">
                    <div class="flex items-center gap-2 mb-1">
                      <MapPin class="w-4 h-4 text-gray-400" />
                      <h4 class="text-lg font-semibold text-gray-900">
                        Table {{ order.tables?.table_number || order.table_number || 'N/A' }}
                      </h4>
                      <span 
                        v-if="order.tables?.type === 'VIP'"
                        class="px-2 py-0.5 text-xs font-medium bg-purple-100 text-purple-900 rounded-full"
                      >
                        VIP
                      </span>
                    </div>
                    
                    <div class="flex items-center gap-4 text-sm text-gray-500">
                      <span v-if="order.tables?.section_name" class="inline-flex items-center gap-1">
                        <Store class="w-3.5 h-3.5" />
                        {{ order.tables.section_name }}
                      </span>
                      <span v-if="order.tables?.floor_level" class="inline-flex items-center gap-1">
                        <Building class="w-3.5 h-3.5" />
                        {{ order.tables.floor_level }}
                      </span>
                      <span v-if="order.tables?.capacity" class="inline-flex items-center gap-1">
                        <Users class="w-3.5 h-3.5" />
                        {{ order.tables.capacity }} pers.
                      </span>
                    </div>
                  </div>
                  
                  <p class="text-sm text-gray-500">
                    {{ order.items_count || 0 }} article{{ order.items_count > 1 ? 's' : '' }} · 
                    {{ formatTime(order.created_at) }}
                  </p>
                </div>
                
                <p class="text-2xl font-semibold text-gray-900">{{ formatPrice(order.total_amount || 0) }}</p>
              </div>

              <div class="flex gap-3">
                <NuxtLink
                  :to="`/staff/order-detail/${order?.id}`"
                  class="flex-1 inline-flex items-center justify-center px-4 py-3 bg-gray-100 text-gray-900 rounded-xl text-sm font-medium hover:bg-gray-200 transition-colors"
                >
                  <Eye class="w-4 h-4 mr-2" />
                  Détails
                </NuxtLink>

                <button
                  v-if="order.status === 'pending'"
                  @click="updateOrderStatus(order.id, 'confirmed')"
                  :disabled="updatingOrderId === order.id"
                  class="flex-1 inline-flex items-center justify-center px-4 py-3 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 transition-colors disabled:opacity-50"
                >
                  <div v-if="updatingOrderId === order.id" class="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                  <Check v-else class="w-4 h-4 mr-2" />
                  Confirmer
                </button>

                <button
                  v-else-if="order.status === 'confirmed'"
                  @click="updateOrderStatus(order.id, 'processing')"
                  :disabled="updatingOrderId === order.id"
                  class="flex-1 inline-flex items-center justify-center px-4 py-3 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 transition-colors disabled:opacity-50"
                >
                  <div v-if="updatingOrderId === order.id" class="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                  <Coffee v-else class="w-4 h-4 mr-2" />
                  Préparer
                </button>

                <button
                  v-else-if="order.status === 'processing'"
                  @click="updateOrderStatus(order.id, 'completed')"
                  :disabled="updatingOrderId === order.id"
                  class="flex-1 inline-flex items-center justify-center px-4 py-3 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 transition-colors disabled:opacity-50"
                >
                  <div v-if="updatingOrderId === order.id" class="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                  <CheckCircle v-else class="w-4 h-4 mr-2" />
                  Terminer
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { 
  ShoppingCart, 
  DollarSign,
  Coffee,
  ChefHat,
  Check,
  CheckCircle,
  RefreshCw,
  ArrowRight,
  QrCode,
  Eye,
  DollarSignIcon,
  MapPin,
  Store,
  Building,
  Users
} from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'
import { useSound } from '~/composables/useSound'

const { establishment } = useEstablishment()
const { user } = useAuth()
const supabase = useSupabaseClient()
const { showToast } = useCustomToast()
const { playNewOrderSound } = useSound()

const isLoading = ref(true)
const isRefreshing = ref(false)
const updatingOrderId = ref<string | null>(null)

const recentOrders = ref<any[]>([])
const popularProducts = ref<any[]>([])

// Real-time subscription
let subscription: any = null

const currentOrders = computed(() => {
  return recentOrders.value
    .filter(order => ['pending', 'confirmed', 'processing'].includes(order.status))
    .slice(0, 1000)
})

const currentOrdersStats = computed(() => {
  const orders = currentOrders.value
  return {
    total: orders.length,
    pending: orders.filter(o => o.status === 'pending').length,
    processing: orders.filter(o => o.status === 'processing').length,
    ready: orders.filter(o => o.status === 'completed').length
  }
})

const mainMetrics = ref<any[]>([])

const loadData = async () => {
  try {
    isLoading.value = true
    
    if (!establishment.value?.id) return
    
    // Load KPIs
    const { data: kpiData, error: kpiError } = await (supabase as any)
      .rpc('get_restaurant_kpis', { establishment_uuid: establishment.value.id })
    
    if (kpiError) throw kpiError
    
    const kpis = kpiData || {}
    
    mainMetrics.value = [
      {
        name: 'Scans QR aujourd\'hui',
        value: kpis.qr_scans_today?.toString() || '0',
        icon: QrCode
      },
      {
        name: 'Commandes aujourd\'hui',
        value: kpis.orders_count_today?.toString() || '0',
        icon: ShoppingCart
      },
      {
        name: 'Montant total des commandes',
        value: formatPrice(kpis.revenue_today || 0),
        icon: DollarSignIcon
      },
      {
        name: 'Panier moyen',
        value: formatPrice(kpis.avg_qr_order_value || 0),
        icon: DollarSign
      }
    ]
    
    // Load orders WITH table info (foreign key join)
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select(`
        *,
        tables (
          id,
          table_number,
          type,
          section_name,
          floor_level,
          capacity,
          location_description
        )
      `)
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(50) as { data: any[], error: any }
    
    if (ordersError) throw ordersError
    
    // Add items count for each order
    const ordersWithItemsCount = await Promise.all(
      (ordersData || []).map(async (order) => {
        const { count } = await supabase
          .from('order_items')
          .select('*', { count: 'exact', head: true })
          .eq('order_id', order.id) as { count: number | null }
        
        return {
          ...order,
          items_count: count || 0
        }
      })
    )
    
    recentOrders.value = ordersWithItemsCount
    
    // Load products
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .limit(5)
    
    if (productsError) throw productsError
    popularProducts.value = productsData || []
    
    // Set up real-time subscription after loading data
    setupRealtimeSubscription()
    
  } catch (error: any) {
    console.error('Error loading dashboard data:', error)
    showToast.error('Erreur', 'Impossible de charger les données du dashboard')
  } finally {
    isLoading.value = false
    isRefreshing.value = false
  }
}

const setupRealtimeSubscription = () => {
  if (!establishment.value?.id) return

  // Cancel any existing subscription
  if (subscription) {
    subscription.unsubscribe()
  }

  // Create new subscription for order updates
  subscription = supabase
    .channel(`dashboard-orders-${establishment.value.id}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${establishment.value.id}`
      },
      async (payload) => {
        if (payload.eventType === 'INSERT') {
          // Play sound notification for new orders
          playNewOrderSound()
          // Show toast notification with table info
          const tableInfo = payload.new.table_number ? `Table ${payload.new.table_number}` : 'Nouvelle commande'
          showToast.success('Nouvelle commande', tableInfo)
          scrollToDown()
          // Refresh dashboard data to get table info
          await loadData()
        } else if (payload.eventType === 'UPDATE') {
          // Update existing order in the list
          const index = recentOrders.value.findIndex(order => order.id === payload.new.id)
          if (index !== -1) {
            recentOrders.value[index] = { ...recentOrders.value[index], ...payload.new }
          }
        }
      }
    )
    .subscribe()
}

const refreshData = async () => {
  isRefreshing.value = true
  await loadData()
}

const scrollToDown = () => {
  setTimeout(() => {
    window.scrollTo({
      top: document.body.scrollHeight,
      behavior: 'smooth'
    })
  }, 100)
}

const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    updatingOrderId.value = orderId
    
    const { error } = await (supabase as any)
      .from('orders')
      .update({ status: newStatus })
      .eq('id', orderId)

    if (error) throw error

    const orderIndex = recentOrders.value.findIndex(order => order.id === orderId)
    if (orderIndex !== -1) {
      recentOrders.value[orderIndex].status = newStatus
    }

    showToast.success('Succès', `Commande ${newStatus === 'confirmed' ? 'confirmée' : 'mise à jour'}`)
  } catch (error: any) {
    console.error('Error updating order status:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  } finally {
    updatingOrderId.value = null
  }
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const formatTime = (dateString: string) => {
  return new Date(dateString).toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'processing': 'En préparation',
    'completed': 'Terminée'
  }
  return texts[status] || status
}

onMounted(() => {
  loadData()
})

// Clean up real-time subscription
onUnmounted(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

definePageMeta({
  layout: 'manager'
})
</script>