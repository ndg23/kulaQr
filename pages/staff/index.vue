<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/90 border-b border-gray-200/20 shadow-sm">
      <div class="max-w-[1400px] mx-auto px-6 sm:px-8 py-4">
        <!-- Logo et nom de l'app -->
        <div class="flex items-center mb-4">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-blue-600 text-white flex items-center justify-center">
              <UtensilsCrossed class="w-5 h-5" />
            </div>
            <span class="text-xl font-bold text-gray-900">Kula QR</span>
          </div>
        </div>
        
        <!-- Header contenu -->
        <div class="flex justify-between items-center">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">Commandes</h1>
            <p class="text-base text-gray-500">Gérez les commandes en temps réel</p>
          </div>
          
          <div class="flex items-center gap-4">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 rounded-full" :class="connectionStatus === 'connected' ? 'bg-green-500' : connectionStatus === 'connecting' ? 'bg-yellow-500' : 'bg-red-500'"></div>
              <span class="text-sm text-gray-600">{{ connectionStatusText }}</span>
            </div>
            
            <button 
              @click="toggleSound" 
              class="h-10 w-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
            >
              <Volume2 v-if="soundEnabled" class="w-5 h-5 text-gray-700" />
              <VolumeX v-else class="w-5 h-5 text-gray-700" />
            </button>
            
            <button 
              @click="refreshOrders" 
              class="h-10 w-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
              :class="{ 'animate-spin': isRefreshing }"
            >
              <RefreshCw class="w-5 h-5 text-gray-700" />
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-[768px] mx-auto px-6 sm:px-8 py-8 sm:py-10">
      <!-- Informations sur l'établissement (remplace le sélecteur) -->
      <div class="mb-8">
        <div v-if="isLoading" class="h-12 w-full bg-gray-100 animate-pulse rounded-xl mb-6"></div>
        
        <div v-else-if="establishment" class="flex items-center gap-3 p-4 bg-blue-50 rounded-xl mb-6">
          <div class="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
            <Store class="w-5 h-5 text-blue-600" />
          </div>
          <div>
            <h3 class="font-medium text-gray-900">{{ establishment.name }}</h3>
            <p class="text-sm text-gray-600">Gestion des commandes</p>
          </div>
        </div>
        
        <div v-else class="p-4 bg-yellow-50 rounded-xl mb-6 text-yellow-800">
          <p class="text-sm">Aucun établissement associé à votre compte.</p>
        </div>

        <!-- Reste du filtrage/recherche -->
        <div class="flex flex-col sm:flex-row sm:items-center gap-4 mb-6">
          <div class="sm:w-64">
            <label class="block text-sm font-medium text-gray-700 mb-1">Filtrer</label>
            <div class="relative">
              <input 
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
                class="w-full h-12 pl-10 pr-4 rounded-xl bg-white border border-gray-200 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
              />
              <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
            </div>
          </div>
        </div>
        
        <div class="flex overflow-x-auto gap-2 py-2 scrollbar-hide">
          <button 
            v-for="status in ['all', 'pending', 'preparing', 'ready', 'completed', 'cancelled']" 
            :key="status"
            @click="filterStatus = status"
            class="h-10 px-4 rounded-full text-sm font-medium whitespace-nowrap"
            :class="filterStatus === status 
              ? 'bg-blue-600 text-white' 
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'"
          >
            {{ statusLabels[status] }}
          </button>
        </div>
      </div>
      
      <!-- Loading state -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
        <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
        <p class="text-gray-500">Chargement des commandes...</p>
      </div>
      
      <!-- Error state -->
      <div v-else-if="loadError" class="bg-white rounded-2xl shadow-sm p-8 text-center">
        <div class="w-16 h-16 mx-auto bg-red-50 rounded-2xl flex items-center justify-center mb-4">
          <AlertTriangle class="w-8 h-8 text-red-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Erreur de chargement</h3>
        <p class="text-gray-500 max-w-md mx-auto mb-4">
          Impossible de charger les commandes. Veuillez réessayer.
        </p>
        <button 
          @click="loadOrders" 
          class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg inline-flex items-center gap-2"
        >
          <RefreshCw class="w-4 h-4" />
          Réessayer
        </button>
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
              ? `Aucune commande avec le statut "${statusLabels[filterStatus]}".` 
              : "Vous n'avez pas encore reçu de commandes." }}
        </p>
      </div>
      
      <!-- Orders -->
      <div v-else class="grid grid-cols-1 max-w-7xl mx-auto sm:gap-6">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          :class="[
            'bg-white rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300 relative',
            recentlyReceivedOrders.has(order.id) ? 'new-order' : ''
          ]"
        >
          <!-- Order card header -->
          <div class="flex justify-between items-center p-5 border-b border-gray-100">
            <div class="flex items-center gap-3">
              <div :class="[getStatusColor(order.status).bg, 'w-12 h-12 rounded-xl flex items-center justify-center']">
                <component :is="getStatusIcon(order.status)" class="w-6 h-6" :class="getStatusColor(order.status).text" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">Commande #{{ order.orderNumber || '---' }}</h3>
                <p class="text-sm text-gray-500">{{ getElapsedTime(order.created_at) }}</p>
              </div>
            </div>
            
            <!-- Indicateur de nouvelle commande -->
            <div v-if="recentlyReceivedOrders.has(order.id)" class="absolute top-3 right-3 bg-blue-500 text-white px-2 py-0.5 rounded-full text-xs font-medium animate-pulse-subtle">
              Nouvelle
            </div>
            
            <!-- Status badge -->
            <div :class="[getStatusColor(order.status).badge, 'px-3 py-1 rounded-full text-xs font-semibold']">
              {{ translateStatus(order.status) }}
            </div>
          </div>
          
          <!-- Order items -->
          <div class="p-5">
            <h4 class="text-sm font-medium text-gray-500 mb-3">Éléments ({{ order.items.length }})</h4>
            
            <div class="space-y-3 mb-4">
              <div 
                v-for="(item, index) in order.items" 
                :key="index"
                class="flex items-start gap-3"
              >
                <div class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 text-xs font-medium flex-shrink-0 mt-0.5">
                  {{ item.quantity }}
                </div>
                <div class="flex-1 min-w-0">
                  <div class="font-medium text-gray-900">{{ item.name }}</div>
                  <div v-if="item.notes" class="text-sm text-gray-500 mt-1">{{ item.notes }}</div>
                </div>
                <div class="text-sm font-medium text-gray-900">{{ formatPrice(item.unit_price) }}</div>
              </div>
            </div>
            
            <div class="pt-3 border-t border-gray-100 flex justify-between items-center">
              <span class="text-sm text-gray-500">Total</span>
              <span class="text-base font-bold">{{ formatPrice(order.total_amount) }}</span>
            </div>
          </div>
          
          <!-- Actions -->
          <div class="p-4 bg-gray-50 border-t border-gray-100">
            <div class="flex flex-wrap gap-2">
              <button 
                v-if="order.status === 'pending'" 
                @click="updateOrderStatus(order.id, 'preparing')"
                class="flex-1 h-10 px-3 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 active:scale-95 transition-all flex items-center justify-center gap-1.5"
              >
                <Check class="w-4 h-4" />
                Accepter
              </button>
              
              <button 
                v-if="order.status === 'preparing'" 
                @click="updateOrderStatus(order.id, 'ready')"
                class="flex-1 h-10 px-3 bg-green-600 text-white rounded-full text-sm font-medium hover:bg-green-700 active:scale-95 transition-all flex items-center justify-center gap-1.5"
              >
                <CheckCircle class="w-4 h-4" />
                Prêt
              </button>
              
              <button 
                v-if="order.status === 'ready'" 
                @click="updateOrderStatus(order.id, 'completed')"
                class="flex-1 h-10 px-3 bg-purple-600 text-white rounded-full text-sm font-medium hover:bg-purple-700 active:scale-95 transition-all flex items-center justify-center gap-1.5"
              >
                <ClipboardCheck class="w-4 h-4" />
                Terminé
              </button>
              
              <button 
                v-if="['pending', 'preparing'].includes(order.status)"
                @click="updateOrderStatus(order.id, 'cancelled')"
                class="h-10 px-3 bg-white border border-gray-200 text-gray-700 rounded-full text-sm font-medium hover:bg-gray-50 active:scale-95 transition-all flex items-center justify-center gap-1.5"
              >
                <X class="w-4 h-4" />
                Annuler
              </button>
              
              <button 
                @click="printOrder(order)"
                class="h-10 w-10 bg-white border border-gray-200 text-gray-700 rounded-full text-sm font-medium hover:bg-gray-50 active:scale-95 transition-all flex items-center justify-center"
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
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useSupabaseClient } from '#imports'
import { 
  ClipboardCheck, 
  RefreshCw, 
  Printer, 
  X,
  CheckCircle,
  Coffee,
  Search,
  Clock,
  Volume2,
  VolumeX,
  Table as TableIcon,
  Loader2,
  UtensilsCrossed,
  AlertTriangle,
  Store
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useAuth } from '~/composables/useAuth'
import type { 
  Order, 
  OrderItem, 
  OrderStatus, 
  ConnectionStatus 
} from '~/types'

const supabase = useSupabaseClient()
const { showToast } = useCustomToast()
const { user } = useAuth()

// State
const orders = ref<Order[]>([])
const establishment = ref(null)
const selectedEstablishment = ref(null)
const isLoading = ref(true)
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

const statusClasses = {
  pending: 'bg-yellow-50 text-yellow-600',
  preparing: 'bg-blue-50 text-blue-600',
  ready: 'bg-green-50 text-green-600',
  completed: 'bg-purple-50 text-purple-600',
  cancelled: 'bg-red-50 text-red-600'
}

// Methods
const loadOrders = async () => {
  if (!selectedEstablishment.value) return
  
  isLoading.value = true
  loadError.value = false
  
  try {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *
      `)
      .eq('establishment_id', selectedEstablishment.value)
      .order('created_at', { ascending: false })
    
    if (error) throw error
    
    // Traitement par lots pour récupérer les éléments de commande
    const ordersWithItems = await Promise.all(
      data.map(async (order, index) => {
        try {
          const { data: itemsData, error: itemsError } = await supabase
            .from('order_items')
            .select(`
              *
            `)
            .eq('order_id', order.id)
          
          if (itemsError) throw itemsError
          
          // Formater les éléments pour l'affichage
          const items = await Promise.all(itemsData.map(async (item) => {
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
              unit_price: item.unit_price,
              notes: item.notes
            }
          }))
          
          return {
            ...order,
            items,
            orderNumber: 1000 + index,
            isExpanded: false
          }
        } catch (err) {
          console.error(`Error loading items for order ${order.id}:`, err)
          return {
            ...order,
            items: [],
            orderNumber: 1000 + index,
            isExpanded: false
          }
        }
      })
    )
    
    orders.value = ordersWithItems
    console.log('Orders loaded successfully:', orders.value.length)
  } catch (error) {
    console.error('Error loading orders:', error)
    showToast.error('Erreur', 'Impossible de charger les commandes')
    loadError.value = true
  } finally {
    isLoading.value = false
  }
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

const handleNewOrder = async (payload) => {
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
    const items = await Promise.all(itemsData.map(async (item) => {
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

const handleOrderUpdate = (payload) => {
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

const updateOrderStatus = async (orderId, newStatus) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: newStatus })
      .eq('id', orderId)
    
    if (error) throw error
    
    // Mettre à jour localement
    const index = orders.value.findIndex(o => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }
    
    const orderNumber = orders.value.find(o => o.id === orderId)?.orderNumber
    if (!orderNumber) return
    
    const notificationMessage = `Commande #${orderNumber} ${statusMessages[newStatus]}`
    showToast.success('Statut mis à jour', notificationMessage)
    
    // Si terminée ou annulée, retirer de la liste après un délai
    if (newStatus === 'completed' || newStatus === 'cancelled') {
      setTimeout(() => {
        orders.value = orders.value.filter(o => o.id !== orderId)
      }, 10000)
    }
  } catch (error) {
    console.error('Error updating order status:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const statusMessages = {
  pending: 'en attente',
  preparing: 'en préparation',
  ready: 'prête',
  completed: 'terminée',
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

const printOrder = (order) => {
  // Implementation de l'impression
  showToast.info('Impression', 'Fonctionnalité à implémenter')
}

const isNewOrder = (order) => {
  return recentlyReceivedOrders.value.has(order.id)
}

// Formatters
const formatPrice = (price) => {
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

const getElapsedTime = (dateString) => {
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
  const colors = {
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
  const translations = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'cancelled': 'Annulée'
  }
  
  return translations[status] || 'Inconnu'
}

definePageMeta({
  layout: 'default',
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
</style>