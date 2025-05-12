<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="sticky top-0 z-40 bg-white border-b border-gray-200">
      <div class="px-4 py-4">
        <div class="flex items-center justify-between">
          <h1 class="text-xl font-bold">Dashboard</h1>
          <button 
            @click="refreshData" 
            class="flex items-center gap-2 px-3 py-1.5 text-sm bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors"
            :disabled="isRefreshing"
          >
            <RefreshCw class="w-4 h-4" :class="{ 'animate-spin': isRefreshing }" />
            <span>Actualiser</span>
          </button>
        </div>
      </div>
    </header>

    <div class="max-w-7xl mx-auto px-4 py-6">
      <!-- Welcome section -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold">Bonjour, {{ user?.user_metadata?.full_name?.split(' ')[0] || 'Manager' }} 👋</h2>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" class="flex justify-center items-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>

      <div v-else>
        <!-- Key metrics -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div 
            v-for="stat in dashboardSummary" 
            :key="stat.name"
            class="bg-white rounded-xl p-6 shadow-sm"
          >
            <div class="flex items-center gap-3 mb-3">
              <div :class="[
                stat.iconBg, 
                'w-12 h-12 rounded-full flex items-center justify-center'
              ]">
                <component :is="stat.icon" class="w-6 h-6" :class="stat.iconColor" />
              </div>
              <span class="text-gray-500">{{ stat.name }}</span>
            </div>
            <p class="text-3xl font-bold">{{ stat.value }}</p>
          </div>
        </div>

        <!-- Two-column layout -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Recent Orders -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-bold">Commandes récentes</h3>
              <NuxtLink 
                :to="`/manager/${establishment?.id}/orders`"
                class="text-blue-500 font-medium hover:underline"
              >
                Voir tout
              </NuxtLink>
            </div>
            
            <div class="space-y-4">
              <div 
                v-for="order in recentOrders.slice(0, 5)" 
                :key="order.id"
                class="border-b border-gray-100 pb-4 last:border-0 last:pb-0"
              >
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-4">
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
                      <div class="flex items-center gap-2">
                        <p class="font-bold">#{{ formatOrderNumber(order.id) }}</p>
                        <span class="text-xs px-2 py-0.5 rounded-full"
                          :class="getStatusColor(order.status).badge"
                        >
                          {{ translateStatus(order.status) }}
                        </span>
                      </div>
                      <p class="text-sm text-gray-500 mt-1">
                        Table {{ order.table_number }}
                      </p>
                    </div>
                  </div>
                  <p class="font-bold text-lg">{{ formatPrice(order.total_amount) }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Popular Products -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-bold">Produits populaires</h3>
              <NuxtLink 
                :to="`/manager/${establishment?.id}/menu`"
                class="text-blue-500 font-medium hover:underline"
              >
                Gérer le menu
              </NuxtLink>
            </div>
            
            <div class="space-y-4">
              <div 
                v-for="product in popularProducts.slice(0, 5)" 
                :key="product.id"
                class="border-b border-gray-100 pb-4 last:border-0 last:pb-0"
              >
                <div class="flex items-center gap-4">
                  <img 
                    :src="product.image_url || '/default-product.png'" 
                    class="w-12 h-12 rounded-lg object-cover"
                    alt="Product"
                  />
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between">
                      <p class="font-bold truncate">{{ product.name }}</p>
                      <p class="font-bold">{{ formatPrice(product.price) }}</p>
                    </div>
                    <div class="flex items-center justify-between mt-1">
                      <p class="text-sm text-gray-500">{{ product.total_quantity || 0 }} vendus</p>
                      <div class="w-24 h-1.5 bg-gray-100 rounded-full">
                        <div 
                          class="h-full bg-blue-500 rounded-full"
                          :style="{ width: `${getPercentage(product.total_quantity, maxQuantity)}%` }"
                        ></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Category Performance -->
        <div class="mt-8 bg-white rounded-xl p-6 shadow-sm">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-bold">Performance par catégorie</h3>
            <NuxtLink 
              :to="`/manager/${establishment?.id}/categories`"
              class="text-blue-500 font-medium hover:underline"
            >
              Gérer les catégories
            </NuxtLink>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div 
              v-for="category in categoryPerformance.slice(0, 3)" 
              :key="category.id"
              class="border border-gray-100 rounded-lg p-4"
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
              <div class="grid grid-cols-2 gap-3 text-sm">
                <div class="bg-gray-50 rounded-lg p-3">
                  <p class="text-gray-500 text-xs">Ventes</p>
                  <p class="font-bold text-lg">{{ formatPrice(category.total_revenue || 0) }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                  <p class="text-gray-500 text-xs">Vendus</p>
                  <p class="font-bold text-lg">{{ category.total_items_sold || 0 }}</p>
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
  ShoppingCart, 
  DollarSign,
  Coffee,
  ChefHat,
  Check,
  CheckCircle,
  RefreshCw
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

// Data from views
const dashboardSummary = ref([])
const recentOrders = ref([])
const popularProducts = ref([])
const categoryPerformance = ref([])

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
        iconColor: 'text-blue-500'
      },
      {
        name: 'Commandes',
        value: summaryData.total_orders || 0,
        icon: ShoppingCart,
        iconBg: 'bg-orange-50',
        iconColor: 'text-orange-500'
      },
      {
        name: 'En attente',
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
        iconColor: 'text-green-500'
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
      .limit(3)
    
    if (categoriesError) throw categoriesError
    categoryPerformance.value = categoriesData || []
    
  } catch (error) {
    console.error('Error loading dashboard data:', error)
    showToast.error('Erreur', 'Impossible de charger les données')
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

// Format price with XOF currency
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
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
