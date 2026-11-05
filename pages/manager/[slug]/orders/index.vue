<template>
  <div class="space-y-4 sm:space-y-6">
    <ManagerModernHeader
      title="Commandes"
      subtitle="Gérez vos commandes en temps réel"
      :icon="Receipt"
      :primary-action="{
        label: 'Nouvelle commande',
        icon: Plus,
        action: openNewOrderModal
      }"
    />

    <!-- La grande carte : les commandes en un coup d'œil -->
    <HeroCard
      label="Commandes"
      :value="stats?.total_orders || 0"
      :icon="Receipt"
      :chips="[
        { label: 'En attente', value: stats?.pending_orders || 0, alert: (stats?.pending_orders || 0) > 0, dot: (stats?.pending_orders || 0) > 0 },
        { label: 'Préparation', value: stats?.processing_orders || 0 },
        { label: 'Terminées', value: stats?.completed_orders || 0 }
      ]"
    />

    <main class="space-y-4">
      <!-- Filtres en pilules -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-2">
        <select
          v-model="statusFilter"
          aria-label="Statut"
          class="h-12 px-5 rounded-full bg-gray-100 border-0 text-sm font-extrabold text-gray-900 focus:outline-none focus:ring-2 focus:ring-black cursor-pointer"
        >
          <option value="">Tous les statuts</option>
          <option value="pending">En attente</option>
          <option value="confirmed">Confirmée</option>
          <option value="processing">En traitement</option>
          <option value="completed">Terminée</option>
        </select>

        <select
          v-model="staffFilter"
          aria-label="Personnel"
          class="h-12 px-5 rounded-full bg-gray-100 border-0 text-sm font-extrabold text-gray-900 focus:outline-none focus:ring-2 focus:ring-black cursor-pointer"
        >
          <option value="">Tout le staff</option>
          <option v-for="member in staff" :key="member.id" :value="member.id">{{ member.username }}</option>
        </select>

        <div class="relative">
          <Search class="w-5 h-5 text-gray-400 absolute left-5 top-1/2 -translate-y-1/2" />
          <input
            v-model="searchQuery"
            type="search"
            placeholder="Rechercher"
            class="w-full h-12 pl-12 pr-5 rounded-full bg-gray-100 border-0 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-black"
          />
        </div>
      </div>

      <!-- Chargement -->
      <div v-if="loading" class="grid grid-cols-1 lg:grid-cols-2 gap-3 sm:gap-4" aria-busy="true">
        <div v-for="i in 4" :key="i" class="h-56 rounded-[2rem] bg-gray-100 animate-pulse"></div>
      </div>

      <!-- Vide -->
      <div v-else-if="filteredOrders.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
        <Receipt class="w-10 h-10 text-gray-400 mx-auto" />
        <h3 class="mt-3 text-lg font-black text-gray-900">Aucune commande</h3>
        <p class="mt-1 text-sm font-semibold text-gray-500">
          {{ orders.length === 0 ? "Aucune commande n'a encore été passée." : 'Aucune commande ne correspond à vos critères.' }}
        </p>
        <button
          type="button"
          class="mt-5 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
          @click="openNewOrderModal"
        >Créer une commande</button>
      </div>

      <!-- Commandes -->
      <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-3 sm:gap-4">
        <article v-for="order in filteredOrders" :key="order.id" class="rounded-[2rem] bg-gray-100 p-5 sm:p-6 flex flex-col gap-4">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <span class="inline-flex items-center h-9 px-4 rounded-full bg-black text-white text-sm font-extrabold">Table {{ order.table_number || '—' }}</span>
              <p class="mt-2 text-xs font-semibold text-gray-500 flex flex-wrap items-center gap-x-2 gap-y-1">
                <span>Commande #{{ order.orderNumber }}</span>
                <span>·</span>
                <span>{{ formatTime(order.created_at) }}</span>
                <span v-if="order.staff" class="inline-flex items-center h-5 px-2 rounded-full bg-white text-gray-900 font-extrabold">{{ order.staff.username }}</span>
              </p>
            </div>
            <span class="inline-flex items-center h-8 px-4 rounded-full text-xs font-extrabold flex-shrink-0" :class="statusPill(order.status)">{{ getStatusText(order.status) }}</span>
          </div>

          <ul class="space-y-1.5">
            <li v-for="item in order.items.slice(0, 3)" :key="item.id" class="flex items-center justify-between gap-3 text-sm">
              <span class="font-bold text-gray-900 min-w-0 truncate">{{ item.quantity }} × {{ item.name }}</span>
              <span class="font-extrabold text-gray-900 tabular-nums flex-shrink-0">{{ formatPrice(item.unit_price * item.quantity) }}</span>
            </li>
            <li v-if="order.items.length > 3" class="text-xs font-bold text-gray-500">+{{ order.items.length - 3 }} autres articles</li>
          </ul>

          <div class="flex items-center justify-between rounded-full bg-[#FB6A00] px-5 h-14">
            <span class="text-sm font-extrabold text-black">Total</span>
            <span class="text-xl font-black text-black tabular-nums">{{ formatPrice(order.total_amount) }}</span>
          </div>

          <div class="flex items-center gap-2">
            <button
              v-if="canAcceptOrder(order.status)"
              type="button"
              class="flex-1 h-12 rounded-full bg-black text-white text-sm font-black uppercase tracking-wide active:scale-[0.97] transition-all"
              @click.stop="updateOrderStatus(order.id, 'confirmed')"
            >Accepter</button>
            <button
              v-if="canPrepareOrder(order.status)"
              type="button"
              class="flex-1 h-12 rounded-full bg-black text-white text-sm font-black uppercase tracking-wide active:scale-[0.97] transition-all"
              @click.stop="updateOrderStatus(order.id, 'processing')"
            >Préparer</button>
            <button
              v-if="canCompleteOrder(order.status)"
              type="button"
              class="flex-1 h-12 rounded-full bg-black text-white text-sm font-black uppercase tracking-wide active:scale-[0.97] transition-all"
              @click.stop="updateOrderStatus(order.id, 'completed')"
            >Terminer</button>
            <button
              type="button"
              aria-label="Imprimer"
              class="w-12 h-12 flex-shrink-0 rounded-full bg-white text-gray-900 flex items-center justify-center active:scale-[0.92] transition-all"
              @click.stop="printOrder(order)"
            ><Printer class="w-5 h-5" :stroke-width="2.5" /></button>
          </div>
        </article>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import HeroCard from '~/components/ui/HeroCard.vue'
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import {
  Receipt, Plus, Clock, Coffee, CheckCircle, Filter, Search,
  Printer, User, X
} from 'lucide-vue-next'
import ManagerModernHeader from '~/components/manager/ModernHeader.vue'
import { useCustomToast } from '~/composables/useToast'
import { useSound } from '~/composables/useSound'
import { useSupabaseClient } from '#imports'

// Route and Supabase
const route = useRoute()
const supabase = useSupabaseClient()
const slug = route.params.slug
const { showToast } = useCustomToast()
const { playNewOrderSound } = useSound()

// State
const establishment = ref<any>(null)
const orders = ref<any[]>([])
const staff = ref<any[]>([])
const loading = ref<boolean>(true)
const searchQuery = ref<string>('')
const statusFilter = ref('')
const staffFilter = ref('')
const stats = ref<{
  total_orders: number
  pending_orders: number
  processing_orders: number
  completed_orders: number
} | null>(null)


// Pastille de statut, aux couleurs Kula (orange et noir)
const statusPill = (status: string) => ({
  pending: 'bg-[#FB6A00] text-black',
  confirmed: 'bg-black text-white',
  processing: 'bg-[#FFB77A] text-black',
  completed: 'bg-white text-black ring-2 ring-black',
  cancelled: 'bg-gray-300 text-gray-700'
} as Record<string, string>)[status] || 'bg-gray-200 text-gray-900'

// Item color functions - alternating colors for visual distinction
const getItemColorClass = (index: number) => {
  const colors = [
    'bg-[#FFECD8] border border-[#FFECD8]',
    'bg-gray-100 border border-gray-100', 
    'bg-gray-100 border border-gray-100',
    'bg-orange-50 border border-orange-100',
    'bg-[#FFECD8] border border-[#FFECD8]'
  ]
  return colors[index % colors.length]
}

const getItemBadgeClass = (index: number) => {
  const colors = [
    'bg-[#FB6A00] text-black',
    'bg-[#FB6A00] text-black',
    'bg-black text-white',
    'bg-orange-500 text-white',
    'bg-[#C54E00] text-white'
  ]
  return colors[index % colors.length]
}

const getItemTextClass = (index: number) => {
  const colors = [
    'text-[#C54E00]',
    'text-black',
    'text-black',
    'text-orange-900',
    'text-[#C54E00]'
  ]
  return colors[index % colors.length]
}

const getMoreItemsClass = () => {
  return 'text-gray-500'
}
const getStatusClass = (status: string) => {
  switch (status) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'confirmed':
      return 'bg-[#FFECD8] text-[#C54E00]'
    case 'processing':
      return 'bg-orange-100 text-orange-800'
    case 'completed':
      return 'bg-gray-100 text-black'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}
// Computed
const filteredOrders = computed(() => {
  let filtered = orders.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order =>
      order.orderNumber.toString().includes(query) ||
      (order.table_number && order.table_number.toString().includes(query))
    )
  }

  if (statusFilter.value) {
    filtered = filtered.filter(order => order.status === statusFilter.value)
  }

  if (staffFilter.value) {
    filtered = filtered.filter(order => order.staff_id === staffFilter.value)
  }

  return filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

// Load establishment data
const loadEstablishment = async () => {
  try {
    if (!slug) {
      showToast.error('Erreur', 'URL invalide')
      return
    }
    
    const { data, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', slug)
    
    if (error) throw error
    
    if (!data || data.length === 0) {
      showToast.error('Erreur', 'Établissement introuvable')
      return
    }
    
    establishment.value = data[0]
    setupRealtimeSubscription()
  } catch (err) {
    console.error('Error loading establishment:', err)
    showToast.error('Erreur', 'Impossible de charger les données')
  }
}

// Load staff members
const loadStaff = async () => {
  if (!establishment.value?.id) return
  
  try {
    const { data, error } = await supabase
      .from('staff')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .eq('is_active', true)
      .not('username', 'is', null)
      .order('username')
    
    if (error) throw error
    staff.value = data || []
  } catch (err) {
    console.error('Error loading staff:', err)
    showToast.error('Erreur', 'Impossible de charger le staff')
  }
}

// Load orders
const loadOrders = async () => {
  if (!establishment.value?.id) return

  loading.value = true

  try {
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })

    if (ordersError) throw ordersError

    const processedOrders = await Promise.all(ordersData.map(async (order: any, index: number) => {
      try {
        const { data: itemsData, error: itemsError } = await supabase
          .from('order_items')
          .select('*')
          .eq('order_id', order.id)

        if (itemsError) throw itemsError

        const items = await Promise.all(itemsData.map(async (item: any) => {
          const { data: product } = await supabase
            .from('products')
            .select('name, description')
            .eq('id', item.product_id)
            .single()

          return {
            ...item,
            name: (product as any)?.name || 'Produit inconnu',
            description: (product as any)?.description || ''
          }
        }))

        let staffInfo = null
        if (order.staff_id) {
          try {
            const { data: staffData } = await supabase
              .from('staff')
              .select('id, username')
              .eq('id', order.staff_id)
              .single()

            staffInfo = staffData && (staffData as any).username ? staffData : null
          } catch (err) {
            staffInfo = null
          }
        }

        return {
          ...order,
          items,
          staff: staffInfo,
          orderNumber: 1000 + index
        }
      } catch (err) {
        return {
          ...order,
          items: [],
          staff: null,
          orderNumber: 1000 + index
        }
      }
    }))

    orders.value = processedOrders
    loadStats()
  } catch (err) {
    console.error('Error loading orders:', err)
    showToast.error('Erreur', 'Impossible de charger les commandes')
  } finally {
    loading.value = false
  }
}

const openNewOrderModal = () => navigateTo(`/manager/${route.params.slug}/orders/new`)

const loadStats = () => {
  const total = orders.value.length
  const pending = orders.value.filter(o => o.status === 'pending').length
  const processing = orders.value.filter(o => ['confirmed', 'processing'].includes(o.status)).length
  const completed = orders.value.filter(o => o.status === 'completed').length

  stats.value = {
    total_orders: total,
    pending_orders: pending,
    processing_orders: processing,
    completed_orders: completed
  }
}

const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', orderId)

    if (error) throw error

    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }

    const order = orders.value.find((o: any) => o.id === orderId)
    showToast.success('Statut mis à jour', `Commande #${order?.orderNumber || orderId.slice(-6)} ${getStatusMessage(newStatus)}`)
    loadStats()
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const assignOrderToStaff = async (orderId: string, staffId: string) => {
  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({ staff_id: staffId || null, updated_at: new Date().toISOString() })
      .eq('id', orderId)

    if (error) throw error

    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].staff_id = staffId || null
      if (staffId) {
        const staffMember = staff.value.find((s: any) => s.id === staffId)
        orders.value[index].staff = staffMember
      } else {
        orders.value[index].staff = null
      }
    


      // Update staff object
      if (staffId) {
        const staffMember = staff.value.find((s: any) => s.id === staffId)
        orders.value[index].staff = staffMember
        console.log('✅ Staff assigned:', staffMember)
      } else {
        orders.value[index].staff = null
        console.log('✅ Staff assignment removed')
      }
    }

    const staffMember = staffId ? staff.value.find((s: any) => s.id === staffId) : null
    const message = staffMember && staffMember.username
      ? `Commande assignée à ${staffMember.username}`
      : 'Assignation supprimée'

    showToast.success('Assignation mise à jour', message)
  } catch (err) {
    console.error('Error assigning order to staff:', err)
    showToast.error('Erreur', 'Impossible d\'assigner la commande')
  }
}

// Print orders
const printOrders = () => {
  // For now, just show a toast - could be expanded to print all orders
  showToast.info('Impression', 'Fonction d\'impression à implémenter')
}

// Refresh data
const refreshData = async () => {
  await Promise.all([
    loadOrders(),
    loadStaff()
  ])
}

// Format time
const formatTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Staff options for assignment
const staffOptions = computed(() => {
  const options = staff.value
    .filter((member: any) => member && member.username) // Filter out invalid members
    .map((member: any) => ({
      id: member.id,
      username: member.username || 'Unknown',
      label: member.username || 'Unknown',
      disabled: !member.is_active
    }))

  console.log('📋 Staff options:', options)
  return options
})

// Print order
const printOrder = (order: any) => {
  // Ticket 80 mm en police à chasse fixe (utils/ticket.ts)
  if (!printTicket(order, establishment.value?.name || '')) {
    showToast.error('Erreur', "Impossible d'ouvrir l'impression")
  }
}

// Utility functions
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const getStatusBadgeClass = (status: string) => {
  const classes: Record<string, string> = {
    'pending': 'bg-yellow-100 text-yellow-800',
    'confirmed': 'bg-[#FFECD8] text-[#C54E00]',
    'processing': 'bg-orange-100 text-orange-800',
    'completed': 'bg-gray-100 text-black'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'processing': 'En traitement',
    'completed': 'Terminée'
  }
  return texts[status] || status
}

const getStatusMessage = (status: string) => {
  const messages: Record<string, string> = {
    'pending': 'est en attente',
    'confirmed': 'a été confirmée',
    'processing': 'est en traitement',
    'completed': 'est terminée'
  }
  return messages[status] || 'a changé de statut'
}

const canAcceptOrder = (status: string) => status === 'pending'
const canPrepareOrder = (status: string) => status === 'confirmed'
const canCompleteOrder = (status: string) => status === 'processing'

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// SetUp realtime subscription
let subscription: any
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
          // Play sound notification for new orders
          playNewOrderSound()
          // Add new order to the list
          showToast.success('Nouvelle commande', 'Une nouvelle commande a été reçue')
          loadOrders() // Reload all orders to get the complete data
        } else if (payload.eventType === 'UPDATE') {
          // Update existing order
          const index = orders.value.findIndex(o => o.id === payload.new.id)
          if (index !== -1) {
            orders.value[index] = { ...orders.value[index], ...payload.new }
            loadStats() // Refresh stats
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

// Lifecycle
onMounted(async () => {
  try {
    loading.value = true
    await loadEstablishment()

    // Vérifier si l'établissement a été chargé avec succès
    if (establishment.value) {
      await Promise.all([
        loadOrders(),
        loadStaff()
      ])
    }
  } catch (err) {
    console.error('Error initializing page:', err)
    showToast.error('Erreur', 'Impossible de charger la page')
  } finally {
    loading.value = false
  }
})

// Watch for establishment changes to set up realtime subscription
watch(() => establishment.value?.id, async (newId, oldId) => {
  if (newId && newId !== oldId) {
    await Promise.all([
      loadOrders(),
      loadStaff()
    ])
  }
})

// Watch for route changes to reload data
watch(() => route.path, async (newPath, oldPath) => {
  console.log('🔄 Route changed, reloading orders data for path:', newPath)
  try {
    loading.value = true
    await loadEstablishment()

    if (establishment.value) {
      await Promise.all([
        loadOrders(),
        loadStaff()
      ])
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