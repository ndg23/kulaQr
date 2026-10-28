<template>
  <div>
    <PageHeader
      :title="`Bonjour, ${user?.user_metadata?.full_name?.split(' ')[0] || 'Manager'}`"
      description="Vue d'ensemble de votre établissement"
    >
      <template #actions>
        <button
          class="inline-flex items-center gap-2 h-12 px-5 rounded-full bg-gray-100 hover:bg-gray-200 font-bold text-gray-900 transition-colors disabled:opacity-50"
          :disabled="isRefreshing"
          @click="refreshData"
        >
          <RefreshCw :class="['w-4 h-4', isRefreshing && 'animate-spin']" />
          Actualiser
        </button>
      </template>
    </PageHeader>

    <div v-if="isLoading" class="flex justify-center items-center py-32">
      <div class="animate-spin rounded-full h-12 w-12 border-4 border-gray-200 border-t-gray-900"></div>
    </div>

    <div v-else class="space-y-6 sm:space-y-8">
      <!-- Indicateurs du jour -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <PageStatCard
          v-for="(stat, i) in mainMetrics"
          :key="stat.name"
          :name="stat.name"
          :value="stat.value"
          :icon="stat.icon"
          :tone="cycleTone(i)"
        />
      </div>

      <!-- Accès rapides -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">
        <NuxtLink
          v-for="link in quickLinks"
          :key="link.to"
          :to="`/manager/${establishment?.id}${link.to}`"
          class="flex items-center gap-4 rounded-[2rem] bg-gray-50 hover:bg-gray-100 p-4 sm:p-5 transition-colors"
        >
          <IconBadge :icon="link.icon" :tone="link.tone" size="lg" />
          <div class="min-w-0">
            <h3 class="font-extrabold text-gray-900">{{ link.name }}</h3>
            <p class="text-sm text-gray-500">{{ link.hint }}</p>
          </div>
          <ArrowRight class="w-5 h-5 text-gray-400 ml-auto flex-shrink-0" />
        </NuxtLink>
      </div>

      <!-- Commandes en cours -->
      <section>
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900">Commandes actuelles</h2>
          <NuxtLink
            :to="`/manager/${establishment?.id}/orders`"
            class="inline-flex items-center gap-2 h-10 px-4 rounded-full bg-gray-100 hover:bg-gray-200 text-sm font-bold text-gray-900 transition-colors"
          >
            Voir tout
            <ArrowRight class="w-4 h-4" />
          </NuxtLink>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 mb-4">
          <PageStatCard name="Total" :value="currentOrdersStats.total" :icon="ShoppingCart" tone="black" />
          <PageStatCard name="En attente" :value="currentOrdersStats.pending" :icon="Clock" tone="yellow" />
          <PageStatCard name="En préparation" :value="currentOrdersStats.processing" :icon="Coffee" tone="orange" />
          <PageStatCard name="Prêtes" :value="currentOrdersStats.ready" :icon="CheckCircle" tone="green" />
        </div>

        <div v-if="currentOrders.length === 0" class="text-center py-20 bg-gray-50 rounded-[2rem]">
          <IconBadge :icon="ShoppingCart" tone="black" size="lg" class="mx-auto mb-4" />
          <h4 class="text-lg font-extrabold text-gray-900 mb-1">Aucune commande en cours</h4>
          <p class="text-gray-500">Les nouvelles commandes apparaîtront ici</p>
        </div>

        <div v-else class="grid grid-cols-1 xl:grid-cols-2 gap-3 sm:gap-4">
          <article
            v-for="order in currentOrders.slice(0, 6)"
            :key="order.id"
            class="bg-white border border-gray-200 rounded-[2rem] p-5 sm:p-6"
          >
            <div class="flex items-start justify-between gap-4 mb-5">
              <div class="min-w-0">
                <div class="flex flex-wrap items-center gap-2 mb-3">
                  <span class="text-sm font-mono font-bold text-gray-500">#{{ order.id.slice(-4) }}</span>
                  <span
                    :class="[
                      'inline-flex items-center h-7 px-3 text-xs font-bold rounded-full',
                      order.status === 'pending' && 'bg-yellow-100 text-yellow-900',
                      order.status === 'confirmed' && 'bg-blue-100 text-blue-900',
                      order.status === 'processing' && 'bg-orange-100 text-orange-900',
                      order.status === 'completed' && 'bg-green-100 text-green-900'
                    ]"
                  >{{ getStatusText(order.status) }}</span>
                  <span
                    v-if="order.tables?.type === 'VIP'"
                    class="inline-flex items-center h-7 px-3 text-xs font-bold bg-purple-100 text-purple-900 rounded-full"
                  >VIP</span>
                </div>

                <div class="flex items-center gap-2 mb-1">
                  <MapPin class="w-4 h-4 text-gray-400" />
                  <h4 class="text-lg font-extrabold text-gray-900">
                    Table {{ order.tables?.table_number || order.table_number || 'N/A' }}
                  </h4>
                </div>

                <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-sm text-gray-500">
                  <span v-if="order.tables?.section_name" class="inline-flex items-center gap-1">
                    <Store class="w-3.5 h-3.5" />{{ order.tables.section_name }}
                  </span>
                  <span v-if="order.tables?.floor_level" class="inline-flex items-center gap-1">
                    <Building class="w-3.5 h-3.5" />{{ order.tables.floor_level }}
                  </span>
                  <span v-if="order.tables?.capacity" class="inline-flex items-center gap-1">
                    <Users class="w-3.5 h-3.5" />{{ order.tables.capacity }} pers.
                  </span>
                </div>

                <p class="text-sm text-gray-500 mt-2">
                  {{ order.items_count || 0 }} article{{ order.items_count > 1 ? 's' : '' }} · {{ formatTime(order.created_at) }}
                </p>
              </div>

              <p class="text-xl sm:text-2xl font-black text-gray-900 whitespace-nowrap">{{ formatPrice(order.total_amount || 0) }}</p>
            </div>

            <div class="flex gap-2">
              <NuxtLink
                :to="`/staff/order-detail/${order?.id}`"
                class="flex-1 inline-flex items-center justify-center h-12 px-4 bg-gray-100 text-gray-900 rounded-full font-bold hover:bg-gray-200 transition-colors"
              >
                <Eye class="w-4 h-4 mr-2" />
                Détails
              </NuxtLink>

              <button
                v-if="nextAction(order.status)"
                :disabled="updatingOrderId === order.id"
                class="flex-1 inline-flex items-center justify-center h-12 px-4 bg-gray-900 text-white rounded-full font-bold hover:bg-gray-800 transition-colors disabled:opacity-50"
                @click="updateOrderStatus(order.id, nextAction(order.status)!.status)"
              >
                <div v-if="updatingOrderId === order.id" class="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                <component :is="nextAction(order.status)!.icon" v-else class="w-4 h-4 mr-2" />
                {{ nextAction(order.status)!.label }}
              </button>
            </div>
          </article>
        </div>
      </section>
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
  Users,
  Clock
} from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'
import { useSound } from '~/composables/useSound'
import { cycleTone } from '~/utils/palette'
import IconBadge from '~/components/ui/IconBadge.vue'

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

const quickLinks = [
  { name: 'Commandes', hint: 'Suivre et gérer', to: '/orders', icon: ShoppingCart, tone: 'orange' as const },
  { name: 'Menu', hint: 'Produits et prix', to: '/menu', icon: ChefHat, tone: 'blue' as const },
  { name: 'QR Codes', hint: 'Tables et menu digital', to: '/tables', icon: QrCode, tone: 'pink' as const }
]

// Prochaine étape d'une commande
const nextAction = (status: string) => ({
  pending: { status: 'confirmed', label: 'Confirmer', icon: Check },
  confirmed: { status: 'processing', label: 'Préparer', icon: Coffee },
  processing: { status: 'completed', label: 'Terminer', icon: CheckCircle }
} as Record<string, { status: string; label: string; icon: any }>)[status]

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