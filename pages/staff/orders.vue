<template>
  <div class="min-h-screen bg-[#F5F5F7]">
    <!-- Header -->
    <header class="bg-white/70 backdrop-blur-lg sticky top-0 z-50 border-b border-gray-100">
      <div class="max-w-5xl mx-auto px-4 py-6 sm:px-6 flex justify-between items-center">
        <div class="flex items-center">
          <NuxtLink 
            :to="`/staff/${establishmentId}`"
            class="mr-4 text-gray-500 hover:text-gray-700"
          >
            <ArrowLeft class="w-6 h-6" />
          </NuxtLink>
          <h1 class="text-2xl font-bold text-gray-900">
            Commandes
          </h1>
        </div>
        <div class="flex items-center space-x-2">
          <span v-if="realtimeStatus === 'connected'" class="flex items-center text-sm text-green-600">
            <span class="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></span>
            En direct
          </span>
          <span v-else class="flex items-center text-sm text-gray-500">
            <span class="w-2 h-2 bg-gray-400 rounded-full mr-2"></span>
            Hors ligne
          </span>
        </div>
      </div>
    </header>

    <!-- Filtres -->
    <div class="border-b border-gray-100 bg-white">
      <div class="max-w-5xl mx-auto px-4 sm:px-6">
        <div class="flex overflow-x-auto py-2 space-x-4">
          <button 
            v-for="status in orderStatuses" 
            :key="status.value"
            @click="activeStatus = status.value"
            class="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors"
            :class="[
              activeStatus === status.value 
                ? 'bg-blue-500 text-white' 
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            ]"
          >
            {{ status.label }}
            <span class="ml-2 text-xs">
              {{ getOrderCountByStatus(status.value) }}
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- Liste des commandes -->
    <main class="max-w-5xl mx-auto px-4 py-6 sm:px-6">
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 3" :key="i" class="animate-pulse">
          <div class="bg-white rounded-2xl p-6">
            <div class="flex items-center space-x-4">
              <div class="h-12 w-12 bg-gray-200 rounded-2xl"></div>
              <div class="flex-1">
                <div class="h-4 bg-gray-200 rounded w-1/4"></div>
                <div class="h-4 bg-gray-200 rounded w-1/2 mt-2"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="filteredOrders.length === 0" 
        class="flex flex-col items-center justify-center py-12"
      >
        <div class="rounded-full bg-gray-100 p-6 mb-4">
          <ClipboardX class="h-8 w-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-medium text-gray-900">Aucune commande</h3>
        <p class="mt-2 text-sm text-gray-500 max-w-sm text-center">
          Il n'y a pas de commandes {{ getStatusText(activeStatus).toLowerCase() }} pour le moment.
        </p>
      </div>

      <div v-else class="space-y-4">
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="bg-white rounded-2xl shadow-sm hover:shadow-md transition-all"
        >
          <div class="p-6">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <div class="h-12 w-12 bg-gray-100 rounded-2xl flex items-center justify-center">
                  <span class="text-xl font-semibold text-gray-700">
                    {{ order.table_number }}
                  </span>
                </div>
                <div class="ml-4">
                  <div class="flex items-center">
                    <span class="text-sm text-gray-500">
                      {{ formatTime(order.created_at) }}
                    </span>
                    <span class="mx-2 text-gray-300">•</span>
                    <span class="text-sm font-medium text-gray-900">
                      {{ order.items.length }} article{{ order.items.length > 1 ? 's' : '' }}
                    </span>
                  </div>
                  <div class="mt-1">
                    <span class="text-lg font-semibold text-gray-900">
                      {{ formatPrice(order.total_amount) }}
                    </span>
                  </div>
                </div>
              </div>
              
              <div class="flex items-center space-x-2">
                <button 
                  v-if="canTakeOrder(order)"
                  @click="takeOrder(order.id)"
                  class="px-4 py-2 bg-blue-500 text-white rounded-full text-sm font-medium hover:bg-blue-600 transition-colors"
                >
                  Je m'en occupe
                </button>
                <button 
                  v-if="canMarkAsReady(order)"
                  @click="markAsReady(order.id)"
                  class="px-4 py-2 bg-yellow-500 text-white rounded-full text-sm font-medium hover:bg-yellow-600 transition-colors"
                >
                  Prêt
                </button>
                <button 
                  v-if="canMarkAsDelivered(order)"
                  @click="markAsDelivered(order.id)"
                  class="px-4 py-2 bg-green-500 text-white rounded-full text-sm font-medium hover:bg-green-600 transition-colors"
                >
                  Servie
                </button>
                <NuxtLink 
                  :to="`/staff/${establishmentId}/order/${order.id}`"
                  class="p-2 text-gray-400 hover:text-gray-600"
                >
                  <ChevronRight class="h-5 w-5" />
                </NuxtLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  ArrowLeft, RefreshCw, ClipboardX, 
  ChevronRight, Eye, CheckCircle, Bell, Check
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const route = useRoute()
const router = useRouter()

const establishmentId = route.params.establishmentId
const loading = ref(true)
const refreshing = ref(false)
const realtimeStatus = ref('disconnected')
const activeStatus = ref('pending')
const orders = ref([])

const orderStatuses = [
  { value: 'pending', label: 'En attente' },
  { value: 'confirmed', label: 'Confirmées' },
  { value: 'preparing', label: 'En préparation' },
  { value: 'ready', label: 'Prêtes' },
  { value: 'delivered', label: 'Servies' }
]

// Filtrer les commandes selon le statut actif
const filteredOrders = computed(() => {
  if (activeStatus.value === 'pending') {
    return orders.value.filter(order => order.status === 'pending')
  }
  return orders.value.filter(order => order.status === activeStatus.value)
})

// Compter les commandes par statut
const getOrderCountByStatus = (status) => {
  return orders.value.filter(order => order.status === status).length
}

// Charger les commandes
const loadOrders = async () => {
  try {
    loading.value = true
    
    // Essayer de charger les commandes réelles
    const { data, error } = await supabase
      .from('orders')
      .select(`
        id,
        table_number,
        status,
        total_amount,
        created_at,
        updated_at,
        items:order_items(
          id,
          product_id,
          quantity,
          unit_price,
          products(name)
        )
      `)
      .eq('establishment_id', establishmentId)
      .order('created_at', { ascending: false })
      .limit(50)

    if (error) throw error

    // Si des commandes existent, les utiliser
    if (data && data.length > 0) {
      // Formater les données
      orders.value = data.map(order => ({
        ...order,
        items: order.items.map(item => ({
          ...item,
          product_name: item.products?.name || 'Produit inconnu'
        }))
      }))
    } else {
      // Sinon, utiliser des données fictives
      orders.value = generateMockOrders(20)
    }
  } catch (error) {
    console.error('Erreur de chargement des commandes:', error)
    // En cas d'erreur, utiliser des données fictives
    orders.value = generateMockOrders(20)
  } finally {
    loading.value = false
  }
}

// Générer des commandes fictives pour la démonstration
const generateMockOrders = (count = 20) => {
  const statuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered']
  const now = new Date()
  
  return Array.from({ length: count }, (_, i) => {
    const itemCount = Math.floor(Math.random() * 5) + 1
    // Distribuer les statuts pour avoir des commandes dans chaque catégorie
    let status
    if (i < count * 0.3) {
      status = 'pending' // 30% en attente
    } else if (i < count * 0.5) {
      status = 'confirmed' // 20% confirmées
    } else if (i < count * 0.7) {
      status = 'preparing' // 20% en préparation
    } else if (i < count * 0.9) {
      status = 'ready' // 20% prêtes
    } else {
      status = 'delivered' // 10% livrées
    }
    
    const totalAmount = (Math.floor(Math.random() * 20) + 1) * 1000
    
    // Créer une date dans les dernières 24h
    const orderDate = new Date(now)
    orderDate.setMinutes(now.getMinutes() - (i * 15 + Math.floor(Math.random() * 15)))
    
    return {
      id: `mock-${i + 1}`,
      table_number: Math.floor(Math.random() * 20) + 1,
      status,
      total_amount: totalAmount,
      created_at: orderDate.toISOString(),
      updated_at: orderDate.toISOString(),
      items: Array.from({ length: itemCount }, (_, j) => ({
        id: `item-${i}-${j}`,
        quantity: Math.floor(Math.random() * 3) + 1,
        unit_price: (Math.floor(Math.random() * 10) + 1) * 500,
        product_name: ['Burger', 'Pizza', 'Salade', 'Poulet', 'Poisson', 'Pâtes', 'Riz'][Math.floor(Math.random() * 7)]
      }))
    }
  })
}

// Configurer la souscription en temps réel
const setupRealtimeSubscription = () => {
  const channel = supabase
    .channel('orders')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'orders',
      filter: `establishment_id=eq.${establishmentId}`
    }, 
    (payload) => {
      handleOrderUpdate(payload)
    })
    .subscribe((status) => {
      realtimeStatus.value = status === 'SUBSCRIBED' ? 'connected' : 'disconnected'
    })

  // Nettoyer la souscription lors du démontage
  onUnmounted(() => {
    channel.unsubscribe()
  })
}

// Gérer les mises à jour en temps réel
const handleOrderUpdate = (payload) => {
  const { eventType, new: newOrder, old: oldOrder } = payload

  switch (eventType) {
    case 'INSERT':
      orders.value = [newOrder, ...orders.value]
      // Jouer un son de notification
      playNotificationSound()
      break
    case 'UPDATE':
      const index = orders.value.findIndex(o => o.id === oldOrder.id)
      if (index !== -1) {
        orders.value[index] = { ...orders.value[index], ...newOrder }
      }
      break
    case 'DELETE':
      orders.value = orders.value.filter(o => o.id !== oldOrder.id)
      break
  }
}

// Son de notification
const playNotificationSound = () => {
  const audio = new Audio('/sounds/notification.mp3')
  audio.play().catch(() => {
    // Gérer l'erreur silencieusement (les navigateurs peuvent bloquer l'autoplay)
  })
}

// Voir les détails d'une commande
const viewOrderDetails = (orderId) => {
  router.push(`/staff/${establishmentId}/order/${orderId}`)
}

// Prendre en charge une commande
const takeOrder = async (orderId) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'confirmed',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande prise en charge')
    await loadOrders()
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Marquer comme prêt à servir
const markAsReady = async (orderId) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'ready',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande prête à servir')
    await loadOrders()
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Marquer comme servie
const markAsDelivered = async (orderId) => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'delivered',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande servie')
    await loadOrders()
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Formater l'heure
const formatTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleTimeString('fr-FR', { 
    hour: '2-digit', 
    minute: '2-digit'
  })
}

// Formater le prix
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF' 
  }).format(price || 0)
}

// Obtenir la classe CSS pour le statut
const getStatusClass = (status) => {
  switch (status) {
    case 'pending':
      return 'bg-gray-100 text-gray-800'
    case 'confirmed':
      return 'bg-blue-100 text-blue-800'
    case 'preparing':
      return 'bg-yellow-100 text-yellow-800'
    case 'ready':
      return 'bg-green-100 text-green-800'
    case 'delivered':
      return 'bg-green-100 text-green-800'
    case 'cancelled':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

// Obtenir le texte du statut
const getStatusText = (status) => {
  switch (status) {
    case 'pending':
      return 'En attente'
    case 'confirmed':
      return 'Confirmée'
    case 'preparing':
      return 'En préparation'
    case 'ready':
      return 'Prête'
    case 'delivered':
      return 'Servie'
    case 'cancelled':
      return 'Annulée'
    default:
      return status
  }
}

// Obtenir les conditions pour prendre en charge une commande
const canTakeOrder = (order) => {
  return order.status === 'pending'
}

// Obtenir les conditions pour marquer une commande comme prête à servir
const canMarkAsReady = (order) => {
  return order.status === 'confirmed'
}

// Obtenir les conditions pour marquer une commande comme servie
const canMarkAsDelivered = (order) => {
  return order.status === 'ready'
}

onMounted(() => {
  loadOrders()
  setupRealtimeSubscription()
})
</script> 