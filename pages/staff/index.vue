<template>
  <div class="min-h-screen bg-white">
    <!-- Apple-style Header -->
    <header class="border-b border-gray-100 sticky top-0 z-30 bg-white/80 backdrop-blur-xl">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 py-6">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h1 class="text-3xl font-semibold text-gray-900 tracking-tight">Commandes</h1>
            <p class="text-sm text-gray-500 mt-1">Gérez vos commandes en temps réel</p>
          </div>
          
          <div class="flex gap-3 items-center">
            <!-- Connection Status -->
            <div class="flex items-center gap-2 px-3 py-2 rounded-full text-xs font-medium"
                 :class="connectionStatus === 'connected' 
                   ? 'bg-green-50 text-green-700' 
                   : 'bg-red-50 text-red-700'">
              <div class="w-2 h-2 rounded-full"
                   :class="connectionStatus === 'connected' ? 'bg-green-500' : 'bg-red-500'"></div>
              <span class="hidden sm:inline">{{ connectionStatusText }}</span>
            </div>
            
            <!-- Refresh Button -->
            <button @click="refreshOrders" 
                    class="w-10 h-10 rounded-full flex items-center justify-center transition-colors hover:bg-gray-100"
                    :class="{ 'animate-spin': isRefreshing }">
              <RefreshCw class="w-5 h-5 text-gray-700" />
            </button>
          </div>
        </div>
        
        <!-- Search -->
        <div class="relative mb-6">
          <Search class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
          <input 
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher une commande..."
            class="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-2xl text-sm transition-all focus:outline-none focus:bg-white focus:border-gray-900"
          />
        </div>
        
        <!-- Filters -->
        <div class="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          <button 
            v-for="status in statusFilters" 
            :key="status.value"
            @click="filterStatus = status.value"
            class="flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all flex-shrink-0"
            :class="[
              filterStatus === status.value 
                ? 'bg-gray-900 text-white' 
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            ]"
          >
            <component v-if="status.value !== 'all'" :is="getStatusIcon(status.value)" class="w-4 h-4" />
            <span>{{ status.label }}</span>
            <span class="px-2 py-0.5 rounded-full text-xs font-semibold min-w-[20px] text-center"
                  :class="filterStatus === status.value ? 'bg-white/20' : 'bg-white'">
              {{ orders.filter(order => status.value === 'all' ? true : order.status === status.value).length }}
            </span>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-6xl mx-auto px-6 sm:px-8 py-8 pb-16">
      <!-- Loading State -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-32">
        <div class="animate-spin rounded-full h-12 w-12 border-2 border-gray-200 border-t-gray-900 mb-4"></div>
        <p class="text-sm text-gray-500">Chargement des commandes...</p>
      </div>
      
      <!-- Error State -->
      <div v-else-if="loadError" class="text-center py-32">
        <div class="w-16 h-16 rounded-full bg-red-50 flex items-center justify-center mx-auto mb-4">
          <AlertTriangle class="w-8 h-8 text-red-500" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Erreur de chargement</h3>
        <p class="text-sm text-gray-500 mb-6">Impossible de charger les commandes</p>
        <button @click="loadOrders" 
                class="px-6 py-3 bg-gray-900 text-white rounded-2xl text-sm font-medium hover:bg-gray-800 transition-colors">
          Réessayer
        </button>
      </div>
      
      <!-- Empty State -->
      <div v-else-if="filteredOrders.length === 0" class="text-center py-32">
        <div class="w-16 h-16 rounded-full bg-gray-50 flex items-center justify-center mx-auto mb-4">
          <ClipboardList class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-sm text-gray-500">
          {{ searchQuery ? 'Aucun résultat trouvé' : 'Les commandes apparaîtront ici' }}
        </p>
      </div>
      
      <!-- Orders Grid -->
      <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white border border-gray-200 rounded-3xl overflow-hidden cursor-pointer transition-all hover:border-gray-900"
          @click="viewOrderDetails(order)"
        >
          <!-- Order Header -->
          <div class="p-6 border-b border-gray-100"
               :class="{
                 'bg-yellow-500': order.status === 'pending',
                 'bg-blue-500': order.status === 'confirmed', 
                 'bg-orange-500': order.status === 'processing',
                 'bg-green-500': order.status === 'completed',
                 'bg-red-500': order.status === 'cancelled'
               }">
            <div class="flex justify-between items-start mb-3">
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-2xl bg-gray-900 text-white flex items-center justify-center text-lg font-semibold">
                  {{ order.table_number }}
                </div>
                <div>
                  <!-- Table Info Enrichie -->
                  <div class="mb-3">
                    <div class="flex items-center gap-2 mb-1">
                      <MapPin class="w-4 h-4 text-white" />
                      <h4 class="text-lg font-semibold text-white">
                        N° {{ order.tables?.table_number || order.table_number || 'N/A' }}
                      </h4>
                      <span 
                        v-if="order.tables?.type === 'VIP'"
                        class="px-2 py-0.5 text-xs font-medium bg-purple-100 text-purple-900 rounded-full"
                      >
                        VIP
                      </span>
                    </div>
                    
                    <div class="flex items-center gap-4 text-sm text-white">
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
                
                </div>
              </div>
              <span class="px-3 py-1 rounded-full text-xs font-medium"
                   :class="{
                     'bg-yellow-100 text-yellow-900': order.status === 'pending',
                     'bg-blue-100 text-blue-900': order.status === 'confirmed',
                     'bg-orange-100 text-orange-900': order.status === 'processing',
                     'bg-green-100 text-green-900': order.status === 'completed',
                     'bg-red-100 text-red-900': order.status === 'cancelled'
                   }">
                {{ translateStatus(order.status) }}
              </span>
            </div>
            <div class="text-sm font-sans text-white">{{ formatRelativeTime(order.created_at) }}</div>
          </div>
          
          <!-- Order Body -->
          <div class="p-6">
            <!-- Items List -->
            <div class="space-y-3 mb-6">
              <div 
                v-for="(item, index) in order.items.slice(0, 3)" 
                :key="index"
                class="flex justify-between text-sm"
              >
                <div class="text-gray-700 font-mono">{{ item.quantity }}× {{ item.name }} </div>
                <span class="font-medium text-gray-900 font-mono">{{ formatPrice(item.unit_price * item.quantity) }}</span>
              </div>
              <div v-if="order.items.length > 3" class="text-center text-gray-400 text-xs py-2">
                +{{ order.items.length - 3 }} article{{ order.items.length - 3 > 1 ? 's' : '' }} supplémentaire{{ order.items.length - 3 > 1 ? 's' : '' }}
              </div>
            </div>
            
            <!-- Total -->
             <div class="my-1 flex ">
               <span v-if="order.notes" class="text-gray-700 italic text-sm "> <FileText class="w-4 h-4 inline-block mr-1" /> {{ order.notes }}</span>
             </div>
            <div class="border-t border-gray-200 pt-4 flex justify-between items-center mb-6">
              <span class="text-sm text-gray-500">Total</span>
              <span class="text-2xl font-semibold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
            </div>
            
            <!-- Action Buttons -->
            <div class="space-y-2">
              <!-- Main Action -->
              <button 
                v-if="order.status === 'pending'" 
                @click.stop="updateOrderStatus(order.id, 'confirmed')"
                class="w-full py-3 px-4 bg-gray-900 text-white rounded-2xl text-sm font-medium hover:bg-gray-800 transition-colors"
              >
                Confirmer la commande
              </button>
              
              <button 
                v-else-if="order.status === 'confirmed'"
                @click.stop="updateOrderStatus(order.id, 'processing')"
                class="w-full py-3 px-4 bg-gray-900 text-white rounded-2xl text-sm font-medium hover:bg-gray-800 transition-colors"
              >
                Commencer la préparation
              </button>
              
              <button 
                v-else-if="order.status === 'processing'"
                @click.stop="updateOrderStatus(order.id, 'completed')"
                class="w-full py-3 px-4 bg-gray-900 text-white rounded-2xl text-sm font-medium hover:bg-gray-800 transition-colors"
              >
                Marquer comme terminée
              </button>
              
              <div v-else-if="order.status === 'completed'" class="text-center py-3 text-sm text-gray-500 font-medium">
                Commande terminée
              </div>
              
              <!-- Cancel Button -->
              <button 
                v-if="order.status === 'pending' || order.status === 'confirmed'"
                @click.stop="cancelOrder(order.id)"
                class="w-full py-3 px-4 bg-gray-100 text-gray-900 rounded-2xl text-sm font-medium hover:bg-gray-200 transition-colors"
              >
                Annuler la commande
              </button>
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
  Coffee,
  X,
  MapPin,
  Store,
  Building,
  Users,
  FileText,
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
  { value: 'confirmed', label: 'Confirmées' },
  { value: 'processing', label: 'En traitement' },
  { value: 'completed', label: 'Terminées' }
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
    // Pour l'interface staff, récupérer l'établissement depuis la session staff
    const currentStaff = await getCurrentStaff()
    if (!currentStaff) {
      throw new Error('Session du personnel non trouvée')
    }
    
    // Charger l'établissement directement avec l'ID du staff
    if (!establishment.value) {
      const { data: establishmentData, error } = await supabase
        .from('establishments')
        .select('*')
        .eq('id', currentStaff.establishment_id)
        .single()
      
      if (error) throw error
      establishment.value = establishmentData
    }
    
    const { data, error } = await supabase
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
        ),
        id,
        table_number,
        status,
        total_amount,
        payment_status,
        notes,
        created_at,
        updated_at,
        staff_id,
        staff:staff_id (
          id,
          username
        ),
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
    // Pour l'interface staff, utiliser la session PIN au lieu de Supabase Auth
    const currentStaff = await getCurrentStaff()
    if (!currentStaff) {
      throw new Error('Session du personnel non trouvée')
    }
    
    const { data: establishmentData, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', currentStaff.establishment_id)
      .single()
    
    if (error) throw error
    establishment.value = establishmentData
  } catch (error) {
    console.error('Error loading establishment:', error)
    // Rediriger vers la page de connexion staff si pas de session
    navigateTo('/auth/pin')
  }
}

const refreshOrders = async () => {
  isRefreshing.value = true
  await loadOrders()
  isRefreshing.value = false
}

// Helper function to get current staff info (prioritizes PIN auth for staff interface)
const getCurrentStaff = async () => {
  try {
    // For staff interface, prioritize PIN auth from localStorage
    const staffSession = localStorage.getItem('staff_session')
    if (staffSession) {
      const sessionData = JSON.parse(staffSession)
      if (sessionData.staff_id && sessionData.auth_type === 'pin') {
        // Verify the staff still exists and is active
        const { data: staffData, error } = await supabase
          .from('staff')
          .select('id, username, role, establishment_id')
          .eq('id', sessionData.staff_id)
          .eq('is_active', true)
          .single()
        
        if (!error && staffData) {
          console.log('✅ Staff session found:', staffData.username)
          return staffData
        } else {
          console.warn('⚠️ Staff session invalid, clearing localStorage')
          localStorage.removeItem('staff_session')
        }
      }
    }
    
    console.warn('⚠️ No valid staff session found')
    return null
  } catch (error) {
    console.error('Error getting current staff:', error)
    return null
  }
}

const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    // Récupérer l'ID du staff actuel (gère les deux types d'authentification)
    const currentStaff = await getCurrentStaff()
    if (!currentStaff) {
      showToast.error('Erreur', 'Informations du personnel non trouvées')
      return
    }

    const updateData: any = { 
      status: newStatus,
      updated_at: new Date().toISOString()
    }

    // Si on passe en confirmed ou processing, assigner le staff
    if (newStatus === 'confirmed' || newStatus === 'processing') {
      updateData.staff_id = currentStaff.id
    }

    // Condition pour éviter les race conditions selon le statut actuel attendu
    let currentStatusCondition = 'pending'
    if (newStatus === 'processing') {
      currentStatusCondition = 'confirmed'
    } else if (newStatus === 'completed') {
      currentStatusCondition = 'processing'
    }

    const { error } = await supabase
      .from('orders')
      .update(updateData)
      .eq('id', orderId)
      .eq('status', currentStatusCondition)
    
    if (error) {
      if (error.code === 'PGRST116') { // No rows updated (status changed)
        showToast.error('Commande déjà mise à jour', 'Le statut de cette commande a changé')
        await loadOrders() // Recharger pour voir l'état actuel
        return
      }
      throw error
    }
    
    // Update local state
    const orderIndex = orders.value.findIndex(order => order.id === orderId)
    if (orderIndex !== -1) {
      orders.value[orderIndex].status = newStatus
      if (newStatus === 'confirmed' || newStatus === 'processing') {
        orders.value[orderIndex].staff_id = currentStaff.id
      }
    }
    
    showToast.success('Succès', `Commande mise à jour: ${translateStatus(newStatus)}`)
    
    console.log(`✅ Statut mis à jour: Commande ${orderId} → ${newStatus}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const cancelOrder = async (orderId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) {
    return
  }
  
  try {
    await updateOrderStatus(orderId, 'cancelled')
    showToast.success('Commande annulée', 'La commande a été annulée avec succès')
  } catch (err) {
    console.error('Error cancelling order:', err)
    showToast.error('Erreur', 'Impossible d\'annuler la commande')
  }
}

const canCancelOrder = (status: string) => {
  return status === 'pending' || status === 'confirmed'
}

const canManageOrder = (order: any) => {
  // Pour l'instant, on permet à tout le monde de gérer les commandes processing
  // TODO: Dans le futur, on pourrait restreindre aux seuls agents qui l'ont prise
  return true
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
    'confirmed': 'Confirmée',
    'processing': 'En traitement',
    'completed': 'Terminée',
    'cancelled': 'Annulée'
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
    'confirmed': {
      badge: 'bg-blue-100 text-blue-800'
    },
    'processing': {
      badge: 'bg-orange-100 text-orange-800'
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
    'confirmed': CheckCircle,
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
        playNotificationSound()
      }
    )
    .subscribe((status) => {
      connectionStatus.value = status === 'SUBSCRIBED' ? 'connected' : 'disconnected'
    })
}

const playNotificationSound = () => {
  const audio = new Audio('/sounds/new-order.mp3')
  audio.play().catch(() => {
    // Gérer l'erreur silencieusement (les navigateurs peuvent bloquer l'autoplay)
  })
}
// Lifecycle
onMounted(async () => {
  // Vérifier d'abord si on a une session staff valide
  const currentStaff = await getCurrentStaff()
  if (!currentStaff) {
    console.warn('Aucune session staff trouvée, redirection vers login')
    navigateTo('/auth/pin')
    return
  }
  
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