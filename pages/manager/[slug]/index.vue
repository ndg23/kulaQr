<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="sticky top-0 z-40 bg-white bg-opacity-90 backdrop-blur-sm border-b border-gray-100">
      <div class="px-4 py-3">
        <div class="flex items-center justify-between">
          <h1 class="text-xl font-bold">Tableau de bord</h1>
          <button 
            @click="refreshData" 
            class="flex items-center gap-2 text-sm text-blue-500 hover:text-blue-600"
            :class="{ 'animate-spin': isRefreshing }"
          >
            <RefreshCw class="w-4 h-4" />
            <span class="hidden sm:inline">Actualiser</span>
          </button>
        </div>
      </div>
    </header>

    <div class="px-4 py-3">
      <!-- Date and welcome -->
      <div class="mb-6">
        <p class="text-sm text-gray-500 capitalize">{{ getCurrentDate() }}</p>
        <h2 class="text-2xl font-bold mt-1">Bonjour, {{ user?.user_metadata?.full_name?.split(' ')[0] || 'Manager' }} 👋</h2>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" class="flex justify-center items-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>

      <div v-else>
        <!-- Dashboard Summary -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
          <div 
            v-for="stat in dashboardSummary" 
            :key="stat.name"
            class="bg-white border border-gray-200 rounded-xl p-4"
          >
            <div class="flex items-center gap-3 mb-2">
              <div :class="[
                stat.iconBg, 
                'w-10 h-10 rounded-full flex items-center justify-center'
              ]">
                <component :is="stat.icon" class="w-5 h-5" :class="stat.iconColor" />
              </div>
              <span class="text-sm text-gray-500">{{ stat.name }}</span>
            </div>
            <p class="text-xl font-bold">{{ stat.value }}</p>
            <p v-if="stat.change" class="text-xs mt-1" :class="stat.change > 0 ? 'text-green-500' : 'text-red-500'">
              {{ stat.change > 0 ? '+' : '' }}{{ stat.change }}% vs hier
            </p>
          </div>
        </div>

        <!-- Sales Chart -->
        <div class="mb-6 bg-white border border-gray-200 rounded-xl p-4">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">Ventes</h3>
            <div class="flex gap-2">
              <button 
                v-for="period in ['day', 'week', 'month']" 
                :key="period"
                @click="chartPeriod = period"
                class="px-3 py-1 text-xs rounded-full"
                :class="chartPeriod === period ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
              >
                {{ periodLabels[period] }}
              </button>
            </div>
          </div>
          <div class="h-64">
            <!-- Chart would go here - using a placeholder -->
            <div class="h-full flex items-center justify-center bg-gray-50 rounded-lg">
              <div class="flex flex-col items-center">
                <BarChart2 class="w-12 h-12 text-gray-300 mb-2" />
                <p class="text-sm text-gray-500">Graphique des ventes par {{ periodLabels[chartPeriod].toLowerCase() }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Two-column layout for desktop -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Recent Orders -->
          <div class="mb-6">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold">Commandes récentes</h3>
              <NuxtLink 
                :to="`/manager/${establishment?.id}/orders`"
                class="text-blue-500 text-sm font-medium hover:underline"
              >
                Voir tout
              </NuxtLink>
            </div>
            
            <div class="space-y-3">
              <div 
                v-for="order in recentOrders" 
                :key="order.id"
                class="bg-white border border-gray-200 rounded-xl p-4"
              >
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div :class="[
                      getStatusColor(order.status).bg,
                      'w-10 h-10 rounded-full flex items-center justify-center'
                    ]">
                      <component 
                        :is="getStatusIcon(order.status)"
                        class="w-5 h-5"
                        :class="getStatusColor(order.status).text"
                      />
                    </div>
                    <div>
                      <p class="font-bold">#{{ formatOrderNumber(order.id) }}</p>
                      <div class="flex items-center gap-2 mt-0.5">
                        <span class="text-xs px-2 py-0.5 rounded-full"
                          :class="getStatusColor(order.status).badge"
                        >
                          {{ translateStatus(order.status) }}
                        </span>
                        <span class="text-xs text-gray-500">{{ formatTime(order.created_at) }}</span>
                      </div>
                    </div>
                  </div>
                  <p class="font-bold">{{ formatPrice(order.total_amount) }}</p>
                </div>
                <div class="mt-2 pl-[3.25rem] text-xs text-gray-500">
                  {{ order.product_names?.slice(0, 3).join(', ') }}
                  <span v-if="order.product_names?.length > 3">
                    et {{ order.product_names.length - 3 }} autres
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Popular Products -->
          <div>
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold">Produits populaires</h3>
              <NuxtLink 
                :to="`/manager/${establishment?.id}/menu`"
                class="text-blue-500 text-sm font-medium hover:underline"
              >
                Voir tout
              </NuxtLink>
            </div>
            
            <div class="space-y-3">
              <div 
                v-for="product in popularProducts" 
                :key="product.id"
                class="bg-white border border-gray-200 rounded-xl p-4"
              >
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <img 
                      :src="product.image_url || '/default-product.png'" 
                      class="w-12 h-12 rounded-lg object-cover"
                      alt="Product"
                    />
                    <div>
                      <p class="font-bold">{{ product.name }}</p>
                      <div class="flex items-center gap-2 mt-0.5">
                        <span class="text-xs text-gray-500">{{ product.total_quantity || 0 }} vendus</span>
                        <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                        <span class="text-xs text-gray-500">{{ product.category_name }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="text-right">
                    <p class="font-bold">{{ formatPrice(product.price) }}</p>
                    <p class="text-xs text-gray-500 mt-0.5">
                      {{ formatPrice(product.total_revenue || 0) }} total
                    </p>
                  </div>
                </div>
                <!-- Progress bar -->
                <div class="h-1.5 bg-gray-100 rounded-full mt-3 overflow-hidden">
                  <div 
                    class="h-full bg-blue-500 rounded-full"
                    :style="{ width: `${getPercentage(product.total_quantity, maxQuantity)}%` }"
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Category Performance -->
        <div class="mt-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">Performance des catégories</h3>
            <NuxtLink 
              :to="`/manager/${establishment?.id}/categories`"
              class="text-blue-500 text-sm font-medium hover:underline"
            >
              Gérer les catégories
            </NuxtLink>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            <div 
              v-for="category in categoryPerformance" 
              :key="category.id"
              class="bg-white border border-gray-200 rounded-xl p-4"
            >
              <div class="flex items-center gap-3 mb-3">
                <img 
                  :src="category.image_url || '/default-category.png'" 
                  class="w-10 h-10 rounded-full object-cover"
                  alt="Category"
                />
                <div>
                  <p class="font-bold">{{ category.name }}</p>
                  <p class="text-xs text-gray-500">{{ category.product_count }} produits</p>
                </div>
              </div>
              <div class="grid grid-cols-2 gap-2 text-sm">
                <div class="bg-gray-50 rounded-lg p-2">
                  <p class="text-gray-500 text-xs">Ventes</p>
                  <p class="font-bold">{{ formatPrice(category.total_revenue || 0) }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-2">
                  <p class="text-gray-500 text-xs">Articles vendus</p>
                  <p class="font-bold">{{ category.total_items_sold || 0 }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  TrendingUp, 
  Users, 
  ShoppingCart, 
  DollarSign,
  Coffee,
  ChefHat,
  Check,
  CheckCircle,
  RefreshCw,
  BarChart2
} from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'
import { useSupabaseClient } from '#imports'
import { useCustomToast } from '~/composables/useToast'

const { establishment } = useEstablishment()
const { user } = useAuth()
const supabase = useSupabaseClient()
const showToast = useCustomToast()

const isLoading = ref(true)
const isRefreshing = ref(false)
const chartPeriod = ref('week')
const periodLabels = {
  day: 'Jour',
  week: 'Semaine',
  month: 'Mois'
}

// Data from views
const dashboardSummary = ref([])
const recentOrders = ref([])
const popularProducts = ref([])
const categoryPerformance = ref([])
const salesData = ref([])

// Computed max quantity for progress bars
const maxQuantity = computed(() => {
  if (!popularProducts.value.length) return 1
  return Math.max(...popularProducts.value.map(p => p.total_quantity || 0))
})

// Load data from Supabase views
const loadData = async () => {
  try {
    isLoading.value = true
    
    // Load dashboard summary
    const { data: summaryData, error: summaryError } = await supabase
      .from('dashboard_summary')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .single()
    
    if (summaryError) throw summaryError
    
    // Format dashboard summary
    dashboardSummary.value = [
      {
        name: 'Ventes totales',
        value: formatPrice(summaryData.total_revenue || 0),
        icon: DollarSign,
        iconBg: 'bg-blue-50',
        iconColor: 'text-blue-500',
        change: 8 // Example change percentage
      },
      {
        name: 'Commandes',
        value: summaryData.total_orders || 0,
        icon: ShoppingCart,
        iconBg: 'bg-orange-50',
        iconColor: 'text-orange-500',
        change: 12
      },
      {
        name: 'Commandes en attente',
        value: summaryData.pending_orders || 0,
        icon: Coffee,
        iconBg: 'bg-yellow-50',
        iconColor: 'text-yellow-500'
      },
      {
        name: 'Panier moyen',
        value: formatPrice(summaryData.average_order_value || 0),
        icon: TrendingUp,
        iconBg: 'bg-green-50',
        iconColor: 'text-green-500',
        change: -2
      }
    ]
    
    // Load recent orders
    const { data: ordersData, error: ordersError } = await supabase
      .from('recent_orders')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('created_at', { ascending: false })
      .limit(5)
    
    if (ordersError) throw ordersError
    recentOrders.value = ordersData || []
    
    // Load popular products
    const { data: productsData, error: productsError } = await supabase
      .from('popular_products')
      .select('*')
      .limit(5)
    
    if (productsError) throw productsError
    popularProducts.value = productsData || []
    
    // Load category performance
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('category_performance')
      .select('*')
      .limit(6)
    
    if (categoriesError) throw categoriesError
    categoryPerformance.value = categoriesData || []
    
    // Load sales data for chart
    const { data: salesOverviewData, error: salesError } = await supabase
      .from('sales_overview')
      .select('*')
      .order('day', { ascending: false })
      .limit(30)
    
    if (salesError) throw salesError
    salesData.value = salesOverviewData || []
    
  } catch (error) {
    console.error('Error loading dashboard data:', error)
    showToast.error('Erreur', 'Impossible de charger les données du tableau de bord')
  } finally {
    isLoading.value = false
    isRefreshing.value = false
  }
}

// Refresh data
const refreshData = async () => {
  isRefreshing.value = true
  await loadData()
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

// Format time
const formatTime = (dateString: string) => {
  return new Date(dateString).toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Get current date
const getCurrentDate = () => {
  return new Date().toLocaleDateString('fr-FR', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Format order number
const formatOrderNumber = (id: string) => {
  return id.toString().slice(-4).padStart(4, '0')
}

// Get percentage for progress bars
const getPercentage = (value: number, max: number) => {
  if (!value || !max) return 0
  return (value / max) * 100
}

const getStatusColor = (status: string) => {
  const colors = {
    'pending': { bg: 'bg-yellow-50', text: 'text-yellow-700', badge: 'bg-yellow-100 text-yellow-700' },
    'preparing': { bg: 'bg-blue-50', text: 'text-blue-700', badge: 'bg-blue-100 text-blue-700' },
    'ready': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100 text-green-700' },
    'completed': { bg: 'bg-gray-50', text: 'text-gray-700', badge: 'bg-gray-100 text-gray-700' }
  }
  return colors[status as keyof typeof colors] || colors.pending
}

const getStatusIcon = (status: string) => {
  const icons = {
    'pending': Coffee,
    'preparing': ChefHat,
    'ready': Check,
    'completed': CheckCircle
  }
  return icons[status as keyof typeof icons] || Coffee
}

const translateStatus = (status: string) => {
  const translations = {
    'pending': 'En attente',
    'preparing': 'En préparation',
    'ready': 'Prêt',
    'completed': 'Terminé'
  }
  return translations[status as keyof typeof translations] || status
}

onMounted(() => {
  loadData()
})

definePageMeta({
  layout: 'manager'
})
</script> 