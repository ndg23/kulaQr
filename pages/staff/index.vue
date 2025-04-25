<template>
    <!-- Header -->
    <!-- <header class="bg-white/70 backdrop-blur-lg sticky top-0 z-50 border-b border-gray-100">
      <div class="max-w-5xl mx-auto px-4 py-6 sm:px-6 flex justify-between items-center">
        <h1 class="text-2xl font-bold text-gray-900">
          {{ establishment.name }}
        </h1>
        <div class="flex items-center space-x-4">
          <span v-if="realtimeStatus === 'connected'" class="hidden sm:flex items-center text-sm text-green-600">
            <span class="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></span>
            En direct
          </span>
          <button 
            @click="logout" 
            class="p-3 rounded-full hover:bg-gray-100 transition-colors"
          >
            <LogOut class="w-6 h-6 text-gray-700" />
          </button>
        </div>
      </div>
    </header> -->

    <!-- Main content -->
    <main class=" mx-auto px-4 py-6 sm:px-6 space-y-6">
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="bg-white rounded-2xl p-6 shadow-sm hover:shadow-md transition-all">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-blue-500 rounded-2xl p-4">
              <Clock class="h-8 w-8 text-white" />
            </div>
            <div class="ml-5">
              <p class="text-sm font-medium text-gray-500">
                En attente
              </p>
              <h3 class="text-4xl font-bold text-gray-900 mt-1">
                {{ stats.pendingOrders }}
              </h3>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-2xl p-6 shadow-sm hover:shadow-md transition-all">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-green-500 rounded-2xl p-4">
              <CheckCircle class="h-8 w-8 text-white" />
            </div>
            <div class="ml-5">
              <p class="text-sm font-medium text-gray-500">
                Servies aujourd'hui
              </p>
              <h3 class="text-4xl font-bold text-gray-900 mt-1">
                {{ stats.completedOrders }}
              </h3>
            </div>
          </div>
        </div>
      </div>

      <!-- Nouvelles commandes -->
      <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 class="text-xl font-bold text-gray-900">Nouvelles commandes</h2>
          <NuxtLink 
            :to="`/staff/${establishmentId}/orders`"
            class="text-blue-600 hover:text-blue-800 font-medium flex items-center"
          >
            Toutes les commandes
            <ChevronRight class="h-5 w-5 ml-1" />
          </NuxtLink>
        </div>

        <div v-if="loading" class="space-y-4 p-4">
          <div v-for="i in 3" :key="i" class="animate-pulse">
            <div class="bg-gray-50 rounded-xl p-4">
              <div class="flex items-center space-x-4">
                <div class="h-12 w-12 bg-gray-200 rounded-xl"></div>
                <div class="flex-1">
                  <div class="h-4 bg-gray-200 rounded w-1/4"></div>
                  <div class="h-4 bg-gray-200 rounded w-1/2 mt-2"></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-else-if="recentOrders.length === 0" 
          class="flex flex-col items-center justify-center py-12 px-4 text-center"
        >
          <div class="rounded-full bg-gray-100 p-6 mb-4">
            <ClipboardX class="h-8 w-8 text-gray-400" />
          </div>
          <h3 class="text-lg font-medium text-gray-900">Aucune commande</h3>
          <p class="mt-2 text-sm text-gray-500 max-w-sm">
            Les nouvelles commandes apparaîtront ici automatiquement.
          </p>
        </div>

        <div v-else class="divide-y divide-gray-100">
          <div 
            v-for="order in recentOrders" 
            :key="order.id"
            class="group hover:bg-gray-50 transition-colors"
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
                    v-if="order.status === 'pending'"
                    @click="takeOrder(order.id)"
                    class="px-4 py-2 bg-blue-500 text-white rounded-full text-sm font-medium hover:bg-blue-600 transition-colors"
                  >
                    Je m'en occupe
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
      </div>
    </main>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  LogOut, Clock, CheckCircle,
  ChevronRight, ClipboardX
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const route = useRoute()
const router = useRouter()

const establishmentId = route.params.establishmentId
const loading = ref(true)
const establishment = ref({
  name: 'Chargement...'
})
const stats = ref({
  pendingOrders: 0,
  completedOrders: 0
})
const recentOrders = ref([])
const realtimeStatus = ref('disconnected')

// Charger les informations du restaurant
const loadEstablishment = async () => {
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('name')
      .eq('id', establishmentId)
      .single()

    if (error) throw error

    establishment.value = data
  } catch (error) {
    console.error('Erreur de chargement du restaurant:', error)
    showToast.error('Erreur', 'Impossible de charger les informations du restaurant')
  }
}

// Charger les statistiques et les commandes récentes
const loadDashboardData = async () => {
  try {
    loading.value = true
    
    // Charger les statistiques
    await loadStats()
    
    // Essayer de charger les commandes réelles
    const { data, error } = await supabase
      .from('orders')
      .select(`
        id,
        table_number,
        status,
        total_amount,
        created_at,
        items:order_items(id)
      `)
      .eq('establishment_id', establishmentId)
      .order('created_at', { ascending: false })
      .limit(5)

    if (error) throw error

    // Si des commandes existent, les utiliser
    if (data && data.length > 0) {
      recentOrders.value = data.map(order => ({
        ...order,
        items: order.items || []
      }))
    } else {
      // Sinon, utiliser des données fictives
      recentOrders.value = generateMockOrders()
    }
  } catch (error) {
    console.error('Erreur de chargement des données:', error)
    // En cas d'erreur, utiliser des données fictives
    recentOrders.value = generateMockOrders()
  } finally {
    loading.value = false
  }
}

// Charger les statistiques
const loadStats = async () => {
  try {
    // Commandes en attente
    const { data: pendingData, error: pendingError } = await supabase
      .from('orders')
      .select('id')
      .eq('establishment_id', establishmentId)
      .in('status', ['pending', 'confirmed', 'preparing'])
      .count()

    if (pendingError) throw pendingError
    stats.value.pendingOrders = pendingData[0]?.count || 0

    // Commandes servies aujourd'hui
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const { data: completedData, error: completedError } = await supabase
      .from('orders')
      .select('id')
      .eq('establishment_id', establishmentId)
      .eq('status', 'delivered')
      .gte('updated_at', today.toISOString())
      .count()

    if (completedError) throw completedError
    stats.value.completedOrders = completedData[0]?.count || 0
  } catch (error) {
    console.error('Erreur de chargement des statistiques:', error)
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

// Déconnexion
const logout = async () => {
  try {
    await supabase.auth.signOut()
    router.push('/staff/login')
  } catch (error) {
    console.error('Erreur de déconnexion:', error)
  }
}

// Générer des commandes fictives pour la démonstration
const generateMockOrders = () => {
  const statuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered']
  const now = new Date()
  
  return Array.from({ length: 5 }, (_, i) => {
    const itemCount = Math.floor(Math.random() * 5) + 1
    const status = statuses[Math.floor(Math.random() * (i === 0 ? 3 : statuses.length))]
    const totalAmount = (Math.floor(Math.random() * 20) + 1) * 1000
    
    // Créer une date dans les dernières 24h
    const orderDate = new Date(now)
    orderDate.setMinutes(now.getMinutes() - (i * 30 + Math.floor(Math.random() * 30)))
    
    return {
      id: `mock-${i + 1}`,
      table_number: Math.floor(Math.random() * 20) + 1,
      status,
      total_amount: totalAmount,
      created_at: orderDate.toISOString(),
      items: Array.from({ length: itemCount }, (_, j) => ({
        id: `item-${i}-${j}`,
        quantity: Math.floor(Math.random() * 3) + 1,
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
const handleOrderUpdate = async (payload) => {
  const { eventType, new: newOrder, old: oldOrder } = payload

  switch (eventType) {
    case 'INSERT':
      // Recharger les données pour avoir les items
      await loadDashboardData()
      // Jouer un son de notification
      playNotificationSound()
      break
    case 'UPDATE':
      // Mettre à jour les statistiques
      await loadStats()
      // Mettre à jour la commande si elle est dans la liste
      const index = recentOrders.value.findIndex(o => o.id === oldOrder.id)
      if (index !== -1) {
        const { data } = await supabase
          .from('orders')
          .select(`
            id,
            table_number,
            status,
            total_amount,
            created_at,
            items:order_items(id)
          `)
          .eq('id', oldOrder.id)
          .single()

        if (data) {
          recentOrders.value[index] = {
            ...data,
            items: data.items || []
          }
        }
      }
      break
    case 'DELETE':
      recentOrders.value = recentOrders.value.filter(o => o.id !== oldOrder.id)
      await loadStats()
      break
  }
}

// Son de notification
const playNotificationSound = () => {
  const audio = new Audio('/sounds/notification.mp3')
  audio.play().catch(() => {
    // Gérer l'erreur silencieusement
  })
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
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

onMounted(() => {
  loadEstablishment()
  loadDashboardData()
  setupRealtimeSubscription()
})

definePageMeta({
  layout: 'staff'
})
</script>

<style scoped>
/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Better touch handling on iOS */
@supports (-webkit-touch-callout: none) {
  .min-h-screen {
    min-height: -webkit-fill-available;
  }
}
</style> 