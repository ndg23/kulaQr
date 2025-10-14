<template>
  <div class="min-h-screen bg-white">
    <!-- Header Twitter 2024 Style - Ultra responsive -->
    <header class="bg-white/80 backdrop-blur-xl border-b border-gray-200/50 sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-3 sm:px-4 py-3">
        <div class="flex items-center justify-between">
          <!-- Logo et titre - Responsive -->
          <div class="flex items-center gap-2 sm:gap-3 min-w-0 flex-1">
            <div class="w-8 h-8 sm:w-10 sm:h-10 bg-black rounded-xl sm:rounded-2xl flex items-center justify-center shadow-sm flex-shrink-0">
              <Clock class="w-4 h-4 sm:w-5 sm:h-5 text-white" />
            </div>
            <div class="min-w-0 flex-1">
              <h1 class="text-lg sm:text-xl font-bold text-gray-900 tracking-tight truncate">Commandes</h1>
              <p class="text-xs sm:text-sm text-gray-500 font-medium truncate">{{ (establishment as any)?.name || 'Restaurant' }}</p>
            </div>
          </div>
          
          <!-- Actions Twitter Style - Responsive -->
          <div class="flex items-center gap-0.5 sm:gap-1 flex-shrink-0">
            <!-- Statut de connexion -->
            <div class="flex items-center gap-1 sm:gap-2 px-2 sm:px-3 py-1.5 sm:py-2 rounded-full text-xs sm:text-sm font-semibold"
                 :class="connectionStatus === 'connected' 
                   ? 'bg-emerald-50 text-emerald-700' 
                   : 'bg-red-50 text-red-700'">
              <div class="w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full"
                   :class="connectionStatus === 'connected' ? 'bg-emerald-500' : 'bg-red-500'"></div>
              <span class="hidden sm:inline">{{ connectionStatusText }}</span>
            </div>
            
            <!-- Bouton refresh -->
            <button @click="refreshOrders" 
                    class="p-2 sm:p-3 rounded-full hover:bg-gray-100 active:scale-95 transition-all duration-150 text-gray-600 touch-target"
                    :class="{ 'animate-spin': isRefreshing }">
              <RefreshCw class="w-4 h-4 sm:w-5 sm:h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-3 sm:px-4 py-4 sm:py-6">
      <!-- Barre de recherche Twitter Style -->
      <div class="mb-6">
            <div class="relative">
          <Search class="w-4 h-4 sm:w-5 sm:h-5 text-gray-400 absolute left-3 sm:left-4 top-1/2 -translate-y-1/2" />
              <input 
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
            class="w-full pl-10 sm:pl-12 pr-3 sm:pr-4 py-3 sm:py-4 bg-gray-50/50 border border-gray-200/50 rounded-xl sm:rounded-2xl text-sm sm:text-base font-medium placeholder:text-gray-400 focus:ring-2 focus:ring-black/10 focus:border-black/20 focus:bg-white transition-all duration-200 shadow-sm hover:shadow-md"
              />
          </div>
        </div>
        
      <!-- Filtres Twitter Style -->
      <div class="mb-8">
        <div class="flex overflow-x-auto gap-2 sm:gap-3 pb-2 sm:pb-3 scrollbar-hide">
          <button 
            v-for="status in statusFilters" 
            :key="status.value"
            @click="filterStatus = status.value"
            class="flex items-center gap-2 px-3 sm:px-4 py-2.5 sm:py-3 rounded-full text-xs sm:text-sm font-semibold whitespace-nowrap transition-all duration-200 active:scale-95 flex-shrink-0 shadow-sm"
            :class="filterStatus === status.value 
              ? 'bg-black text-white shadow-lg shadow-black/10' 
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200 border border-gray-200/50'"
          >
            <component v-if="status.value !== 'all'" :is="getStatusIcon(status.value)" class="w-3 h-3 sm:w-4 sm:h-4 flex-shrink-0" />
            <span class="flex-shrink-0">{{ status.label }}</span>
            <span class="px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full text-xs font-bold min-w-[18px] sm:min-w-[20px] text-center"
                  :class="filterStatus === status.value ? 'bg-white/20' : 'bg-gray-300'">
              {{ orders.filter(order => status.value === 'all' ? true : order.status === status.value).length }}
            </span>
          </button>
        </div>
      </div>
      
      <!-- Loading state Twitter 2024 Style -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
        <div class="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mb-6 shadow-sm">
          <Loader2 class="w-8 h-8 animate-spin text-gray-600" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Chargement des commandes</h3>
        <p class="text-gray-500 text-sm">Récupération des dernières commandes en cours...</p>
      </div>
      
      <!-- Error state Twitter 2024 Style -->
      <div v-else-if="loadError" class="text-center py-20">
        <div class="w-20 h-20 mx-auto bg-red-50 rounded-3xl flex items-center justify-center mb-6 shadow-sm">
          <AlertTriangle class="w-10 h-10 text-red-500" />
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Erreur de chargement</h3>
        <p class="text-gray-600 mb-8 max-w-md mx-auto">
          Impossible de charger les commandes. Veuillez réessayer.
        </p>
        <button @click="loadOrders" 
                class="px-8 py-4 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 active:scale-95 transition-all duration-200 shadow-lg shadow-black/10">
          Réessayer
        </button>
      </div>
      
      <!-- Empty state Twitter 2024 Style -->
      <div v-else-if="filteredOrders.length === 0" class="text-center py-20">
        <div class="w-20 h-20 mx-auto bg-gray-100 rounded-3xl flex items-center justify-center mb-6 shadow-sm">
          <ClipboardList class="w-10 h-10 text-gray-400" />
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Aucune commande</h3>
        <p class="text-gray-600 max-w-md mx-auto">
          {{ searchQuery 
            ? "Aucune commande ne correspond à votre recherche." 
            : filterStatus !== 'all' 
              ? `Aucune commande avec le statut "${filterStatus}".` 
              : "Vous n'avez pas encore reçu de commandes." }}
        </p>
      </div>
      
      <!-- Liste d'orders simple -->
      <div v-else class="space-y-4">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white border border-gray-200/50 rounded-3xl p-6 hover:shadow-xl hover:shadow-black/5 transition-all duration-300 relative"
          :class="recentlyReceivedOrders.has(order.id) ? 'ring-2 ring-blue-500/30 shadow-lg shadow-blue-500/10' : ''"
        >
          <!-- Indicateur de nouvelle commande -->
          <div v-if="recentlyReceivedOrders.has(order.id)" class="absolute -top-3 -right-3 bg-blue-500 text-white px-3 py-1.5 rounded-full text-xs font-bold animate-pulse shadow-lg">
            Nouvelle
              </div>
          
          <!-- Header de la commande -->
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center gap-4">
              <!-- Numéro de table -->
              <div class="w-14 h-14 bg-gray-100 rounded-2xl flex items-center justify-center shadow-sm">
                <span class="text-xl font-bold text-gray-800">{{ order.table_number || '?' }}</span>
              </div>
              
              <!-- Infos de base -->
              <div>
                <h3 class="text-lg font-bold text-gray-900 mb-1">Commande #{{ order.orderNumber || order.id.slice(-6) }}</h3>
                <p class="text-sm text-gray-500 font-medium">{{ getElapsedTime(order.created_at) }}</p>
              </div>
            </div>
            
            <!-- Statut actuel -->
            <div class="flex items-center gap-2">
              <div :class="[getStatusColor(order.status).badge, 'px-4 py-2 rounded-2xl text-sm font-semibold shadow-sm']">
              {{ translateStatus(order.status) }}
              </div>
            </div>
          </div>
          
          <!-- Items de la commande -->
          <div class="mb-6">
            <div class="flex items-center justify-between mb-3">
              <span class="text-sm font-semibold text-gray-600">{{ order.items.length }} article{{ order.items.length > 1 ? 's' : '' }}</span>
              <span class="text-xl font-bold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
            </div>
            
            <!-- Liste des items -->
            <div class="space-y-3">
              <div 
                v-for="(item, index) in order.items.slice(0, 3)" 
                :key="index"
                class="flex items-center gap-4 text-sm"
              >
                <span class="w-7 h-7 bg-gray-100 rounded-full flex items-center justify-center text-xs font-bold text-gray-700">
                  {{ item.quantity }}
                </span>
                <span class="text-gray-900 flex-1 truncate font-medium">{{ item.name }}</span>
                <span class="text-gray-600 font-semibold">{{ formatPrice(item.unit_price) }}</span>
                </div>
              
              <!-- Plus d'items -->
              <div v-if="order.items.length > 3" class="text-sm text-gray-500 pl-11 font-medium">
                +{{ order.items.length - 3 }} autre{{ order.items.length - 3 > 1 ? 's' : '' }} article{{ order.items.length - 3 > 1 ? 's' : '' }}
                </div>
              </div>
            </div>
            
          <!-- Actions simples -->
          <div class="flex items-center justify-between pt-4 border-t border-gray-100">
            <!-- Actions principales -->
            <div class="flex flex-col sm:flex-row gap-3">
              <!-- Bouton d'action principal selon le statut -->
              <button 
                v-if="order.status === 'pending'" 
                @click="updateOrderStatus(order.id, 'preparing')"
                class="px-6 py-3 bg-black text-white rounded-2xl text-sm font-semibold hover:bg-gray-800 active:scale-95 transition-all duration-200 flex items-center gap-2 shadow-lg shadow-black/10"
              >
                <Check class="w-4 h-4" />
                Accepter
              </button>
              
              <button 
                v-if="order.status === 'preparing'" 
                @click="updateOrderStatus(order.id, 'ready')"
                class="px-6 py-3 bg-emerald-600 text-white rounded-2xl text-sm font-semibold hover:bg-emerald-700 active:scale-95 transition-all duration-200 flex items-center gap-2 shadow-lg shadow-emerald-500/20"
              >
                <CheckCircle class="w-4 h-4" />
                Prêt
              </button>
              
              <button 
                v-if="order.status === 'ready'" 
                @click="updateOrderStatus(order.id, 'completed')"
                class="px-6 py-3 bg-purple-600 text-white rounded-2xl text-sm font-semibold hover:bg-purple-700 active:scale-95 transition-all duration-200 flex items-center gap-2 shadow-lg shadow-purple-500/20"
              >
                <ClipboardCheck class="w-4 h-4" />
                Terminé
              </button>
              
              <!-- Bouton d'annulation -->
              <button 
                v-if="['pending', 'preparing'].includes(order.status)"
                @click="updateOrderStatus(order.id, 'cancelled')"
                class="px-4 py-3 bg-gray-100 text-gray-700 rounded-2xl text-sm font-semibold hover:bg-gray-200 active:scale-95 transition-all duration-200 flex items-center gap-2 border border-gray-200/50"
              >
                <X class="w-4 h-4" />
                Annuler
              </button>
            </div>
              
            <!-- Actions secondaires -->
            <div class="flex gap-2">
              <button 
                @click="printOrder(order)"
                class="p-3 bg-gray-100 text-gray-600 rounded-2xl hover:bg-gray-200 active:scale-95 transition-all duration-200 border border-gray-200/50"
                title="Imprimer"
              >
                <Printer class="w-4 h-4" />
              </button>
              
              <button 
                @click="viewOrderDetails(order)"
                class="p-3 bg-gray-100 text-gray-600 rounded-2xl hover:bg-gray-200 active:scale-95 transition-all duration-200 border border-gray-200/50"
                title="Voir détails"
              >
                <Eye class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { 
  Clock, 
  CheckCircle, 
  Coffee, 
  ClipboardCheck, 
  X, 
  Loader2, 
  AlertTriangle, 
  ClipboardList, 
  Search, 
  RefreshCw, 
  Printer,
  Check,
  Store,
  Volume2,
  VolumeX,
  Eye,
  Plus
} from 'lucide-vue-next'
import StatusBadge from '~/components/manager/StatusBadge.vue'
import type { Order, OrderItem, ConnectionStatus, OrderStatus } from '~/types'

const supabase = useSupabaseClient()
const { showToast } = useCustomToast()
const { user } = useAuth()

// State
const orders = ref<Order[]>([])
const establishment = ref(null)
const selectedEstablishment = ref(null)
const isLoading = ref(true)

// Methods
const loadOrders = async () => {
  isLoading.value = true
  loadError.value = false
  
  try {
    // Charger l'établissement du staff
    if (!establishment.value) {
      await loadEstablishment()
    }
    
    if (!establishment.value) {
      throw new Error('Aucun établissement trouvé')
    }
    
    // Charger les commandes depuis l'API
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
    
    // Formater les données
    orders.value = data.map((order, index) => ({
      ...order,
      orderNumber: String(index + 1).padStart(3, '0'), // Générer un numéro de commande basé sur l'index
      items: order.items.map(item => ({
        ...item,
        name: item.products?.name || 'Produit inconnu',
        productId: item.products?.id
      }))
    }))
    
    // Mettre à jour le statut de connexion
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
const isRefreshing = ref(false)
const connectionStatus = ref<ConnectionStatus>('disconnected')
const filterStatus = ref('all')
const searchQuery = ref('')
const soundEnabled = ref(true)
const orderSound = ref<HTMLAudioElement|null>(null)
const staffSession = ref(null)
const recentlyReceivedOrders = ref<Set<string>>(new Set())
const loadError = ref(false)

// Computed
const connectionStatusText = computed(() => {
  switch (connectionStatus.value) {
    case 'connected': return 'Connecté'
    case 'connecting': return 'Connexion...'
    default: return 'Déconnecté'
  }
})

const filteredOrders = computed(() => {
  let filtered = [...orders.value]
  
  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => 
      order.orderNumber.toString().includes(query) ||
      order.items.some(item => item.name.toLowerCase().includes(query))
    )
  }
  
  // Filter by status
  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(order => order.status === filterStatus.value)
  }
  
  // Sort by date (newest first)
  return filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

// Status formatting
const statusLabels = {
  all: 'Toutes',
  pending: 'En attente',
  preparing: 'En préparation',
  ready: 'Prêt',
  completed: 'Terminé',
  cancelled: 'Annulé'
}

const statusFilters = [
  { value: 'all', label: 'Toutes' },
  { value: 'pending', label: 'En attente' },
  { value: 'preparing', label: 'En préparation' },
  { value: 'ready', label: 'Prêt' },
  { value: 'completed', label: 'Terminé' },
  { value: 'cancelled', label: 'Annulé' }
]

const statusClasses = {
  pending: 'bg-yellow-50 text-yellow-600',
  preparing: 'bg-blue-50 text-blue-600',
  ready: 'bg-green-50 text-green-600',
  completed: 'bg-purple-50 text-purple-600',
  cancelled: 'bg-red-50 text-red-600'
}

let subscription;

const setupRealtimeConnection = () => {
  if (!selectedEstablishment.value) return;
  
  // Désabonner de l'ancienne connexion si elle existe
  if (subscription) {
    subscription.unsubscribe()
  }
  
  connectionStatus.value = 'connecting'
  
  // Créer une nouvelle connexion pour suivre les commandes
  subscription = supabase
    .channel(`orders-${selectedEstablishment.value}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${selectedEstablishment.value}`
      },
      handleNewOrder
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${selectedEstablishment.value}`
      },
      handleOrderUpdate
    )
    .subscribe((status) => {
      connectionStatus.value = status === 'SUBSCRIBED' ? 'connected' : 'disconnected'
    })
}

const handleNewOrder = async (payload: any) => {
  console.log('Nouvelle commande reçue:', payload)
  
  try {
    // Récupérer les détails complets de la commande
    const orderData = payload.new
    
    // Récupérer les items de cette commande
    const { data: itemsData, error: itemsError } = await supabase
      .from('order_items')
      .select(`*`)
      .eq('order_id', orderData.id)
    
    if (itemsError) throw itemsError
    
    // Formater les items pour l'affichage
    const items = await Promise.all((itemsData as any[]).map(async (item) => {
      // Récupérer les informations sur le produit
      const { data: productData } = await supabase
        .from('products')
        .select('name, description')
        .eq('id', item.product_id)
        .single()
      
      return {
        id: item.id,
        productId: item.product_id,
        name: productData?.name || 'Produit inconnu',
        description: productData?.description || '',
        quantity: item.quantity,
        price: item.unit_price,
        notes: item.notes
      }
    }))
    
    // Créer la commande formatée avec un numéro d'ordre
    const orderNumber = 1000 + orders.value.length
    const formattedOrder = {
      ...orderData,
      orderNumber,
      items,
      isExpanded: false
    }
    
    // Ajouter la commande à la liste (en premier)
    orders.value = [formattedOrder, ...orders.value]
    
    // Marquer comme nouvelle pour l'animation
    recentlyReceivedOrders.value.add(formattedOrder.id)
    setTimeout(() => {
      recentlyReceivedOrders.value.delete(formattedOrder.id)
    }, 30000) // Garder l'animation pendant 30 secondes
    
    // Notification sonore si activée
    if (soundEnabled.value) {
      playOrderSound()
    }
    
    // Notification toast
    showToast.success('Nouvelle commande', `Commande #${orderNumber} reçue`)
    
  } catch (error) {
    console.error('Error processing new order:', error)
    showToast.error('Erreur', 'Impossible de traiter la nouvelle commande')
  }
}

const handleOrderUpdate = (payload: any) => {
  console.log('Order updated:', payload)
  
  // Mettre à jour la commande dans la liste
  const updatedOrder = payload.new
  const index = orders.value.findIndex(o => o.id === updatedOrder.id)
  
  if (index !== -1) {
    // Conserver les propriétés calculées tout en mettant à jour le statut
    orders.value[index] = {
      ...orders.value[index],
      status: updatedOrder.status
    }
  }
}

const updateOrderStatus = async (orderId: string, newStatus: OrderStatus) => {
  try {
    // Simulation d'un délai de mise à jour
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // Mettre à jour localement (simulation)
    const index = orders.value.findIndex(o => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
      
      // Retirer de la liste des nouvelles commandes si elle y était
      recentlyReceivedOrders.value.delete(orderId)
    }
    
    const orderNumber = orders.value.find(o => o.id === orderId)?.orderNumber
    
    // Afficher un message de succès
    showToast.success('Succès', `Commande #${orderNumber} mise à jour: ${translateStatus(newStatus)}`)
    
    console.log(`✅ Statut mis à jour: Commande ${orderId} → ${newStatus}`)
    
    // Code original commenté pour référence future
    /*
    const { error } = await supabase
      .from('orders')
      .update({ status: newStatus })
      .eq('id', orderId)
    
    if (error) throw error
    if (!orderNumber) return
    
    const notificationMessage = `Commande #${orderNumber} ${statusMessages[newStatus]}`
    showToast.success('Statut mis à jour', notificationMessage)
    
    // Si terminée ou annulée, retirer de la liste après un délai
    if (newStatus === 'completed' || newStatus === 'cancelled') {
      setTimeout(() => {
        orders.value = orders.value.filter(o => o.id !== orderId)
      }, 10000)
    }
    */
  } catch (error) {
    console.error('Error updating order status:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const statusMessages = {
  pending: 'en attente',
  accepted: 'acceptée',
  preparing: 'en préparation',
  ready: 'prête',
  completed: 'terminée',
  rejected: 'rejetée',
  cancelled: 'annulée'
}

const playOrderSound = () => {
  try {
    const audio = new Audio('/sounds/new-order.mp3')
    audio.volume = 0.6
    audio.play()
  } catch (e) {
    console.log('Unable to play sound', e)
  }
}

const toggleSound = () => {
  soundEnabled.value = !soundEnabled.value
  showToast.info(
    soundEnabled.value ? 'Son activé' : 'Son désactivé', 
    soundEnabled.value ? 'Vous serez notifié lors des nouvelles commandes' : 'Les notifications sonores sont désactivées'
  )
}

const printOrder = (order: any) => {
  // Implementation de l'impression
  showToast.info('Impression', 'Fonctionnalité à implémenter')
}

const isNewOrder = (order: any) => {
  return recentlyReceivedOrders.value.has(order.id)
}

// Formatters
const formatPrice = (price: any) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(price)
}

const formatTime = (dateString) => {
  return new Date(dateString).toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getElapsedTime = (dateString: any) => {
  const now = new Date()
  const date = new Date(dateString)
  const diffMs = now.getTime() - date.getTime()
  const diffMins = Math.round(diffMs / 60000)
  
  if (diffMins < 1) return 'À l\'instant'
  if (diffMins === 1) return 'Il y a 1 minute'
  if (diffMins < 60) return `Il y a ${diffMins} minutes`
  
  const hours = Math.floor(diffMins / 60)
  if (hours === 1) return 'Il y a 1 heure'
  return `Il y a ${hours} heures`
}

// Mise à jour de l'initialisation pour utiliser le staff_session directement
const initializeApp = async () => {
  try {
    // Vérifier la session staff dans localStorage au lieu de Supabase auth
    const sessionData = localStorage.getItem('staff_session')
    
    if (!sessionData) {
      isLoading.value = false
      loadError.value = true
      showToast.error('Authentification requise', 'Veuillez vous connecter')
      return
    }
    
    // Charger la session
    staffSession.value = JSON.parse(sessionData)
    
    // Utiliser directement l'establishment_id de la session
    if (staffSession.value.establishment_id) {
      selectedEstablishment.value = staffSession.value.establishment_id
      await loadEstablishment()
      await loadOrders()
      setupRealtimeConnection()
    } else {
      isLoading.value = false
      showToast.warning('Configuration incomplète', 'Aucun établissement associé à votre compte')
    }
  } catch (error) {
    console.error('Initialization error:', error)
    showToast.error('Erreur', "Problème d'initialisation de l'application")
    isLoading.value = false
    loadError.value = true
  }
}

// Charger uniquement l'établissement à partir de l'ID stocké
const loadEstablishment = async () => {
  if (!selectedEstablishment.value) return

  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name')
      .eq('id', selectedEstablishment.value)
      .single()
    
    if (error) throw error
    
    establishment.value = data
    isLoading.value = false
  } catch (error) {
    console.error('Error loading establishment:', error)
    showToast.error('Erreur', 'Impossible de charger les informations de l\'établissement')
    isLoading.value = false
    loadError.value = true
  }
}

// Lifecycle
onMounted(() => {
  // Initialiser l'application avec l'API réelle
  initializeApp()
})

onUnmounted(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

// Ajouter un watcher pour initialiser la connexion quand un établissement est sélectionné
watch(selectedEstablishment, (newValue) => {
  if (newValue) {
    setupRealtimeConnection()
  }
})

// Ajouter ces fonctions pour gérer les statuts des commandes
const getStatusColor = (status: string) => {
  const colors: any = {
    'pending': {
      bg: 'bg-yellow-50',
      text: 'text-yellow-500',
      badge: 'bg-yellow-100 text-yellow-800'
    },
    'confirmed': {
      bg: 'bg-blue-50',
      text: 'text-blue-500',
      badge: 'bg-blue-100 text-blue-800'
    },
    'preparing': {
      bg: 'bg-purple-50',
      text: 'text-purple-500',
      badge: 'bg-purple-100 text-purple-800'
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

const getStatusIcon = (status: string) => {
  const icons = {
    'pending': Clock,
    'confirmed': CheckCircle,
    'preparing': Coffee,
    'ready': ClipboardCheck,
    'completed': CheckCircle,
    'cancelled': X
  }
  
  return icons[status] || Clock
}

// Ajouter cette fonction pour traduire les statuts
const translateStatus = (status: string) => {
  const translations: any = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'cancelled': 'Annulée'
  }
  
  return translations[status] || 'Inconnu'
}

const mapStatusForBadge = (status: string) => {
  const statusMap: Record<string, 'pending' | 'processing' | 'completed' | 'cancelled'> = {
    'pending': 'pending',
    'preparing': 'processing',
    'ready': 'completed',
    'completed': 'completed',
    'cancelled': 'cancelled'
  }
  
  return statusMap[status] || 'pending'
}

const refreshOrders = async () => {
  isRefreshing.value = true
  await loadOrders()
  isRefreshing.value = false
}

const viewOrderDetails = (order: any) => {
  // Navigation vers la page de détails de la commande
  navigateTo(`/staff/order-detail/${order.id}`)
}

definePageMeta({
  layout: 'staff',
})
</script>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes pulse-subtle {
  0% { border-color: rgba(59, 130, 246, 0.5); }
  50% { border-color: rgba(59, 130, 246, 0.8); }
  100% { border-color: rgba(59, 130, 246, 0.5); }
}

.animate-pulse-subtle {
  animation: pulse-subtle 2s infinite;
}

.scrollbar-hide {
  -ms-overflow-style: none;  /* IE and Edge */
  scrollbar-width: none;  /* Firefox */
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;  /* Chrome, Safari and Opera */
}

@keyframes pulse-highlight {
  0% { background-color: rgba(59, 130, 246, 0.1); }
  50% { background-color: rgba(59, 130, 246, 0.2); }
  100% { background-color: rgba(59, 130, 246, 0.1); }
}

.new-order {
  animation: pulse-highlight 2s infinite;
  border-left: 3px solid #3b82f6;
}

/* Animations Twitter 2024 Style */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fadeInUp {
  animation: fadeInUp 0.4s ease-out;
}

/* Mobile-first touch interactions */
@media (max-width: 768px) {
  .touch-target {
    min-height: 44px;
    min-width: 44px;
  }
  
  .mobile-padding {
    padding-left: 1rem;
    padding-right: 1rem;
  }
}

/* Hover effects for desktop */
@media (hover: hover) {
  .hover-lift:hover {
    transform: translateY(-2px);
  }
}
</style>