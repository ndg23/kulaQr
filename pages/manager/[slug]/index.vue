<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Dashboard"
      subtitle="Vue d'ensemble de votre établissement"
      :icon="LayoutDashboard"
      :primary-action="{
        label: 'Actualiser',
        icon: RefreshCw,
        action: refreshData
      }"
    />

    <div class="max-w-6xl mx-auto px-5 sm:px-10 py-10 sm:py-14">
      <!-- Welcome section -->
      <div class="mb-10 sm:mb-16">
        <h2 class="text-3xl sm:text-4xl font-bold text-gray-900">Bonjour, {{ user?.user_metadata?.full_name?.split(' ')[0] || 'Manager' }} 👋</h2>
        <p class="text-gray-500 mt-2 text-lg">Résumé de votre activité</p>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-14 w-14 border-b-2 border-blue-600"></div>
      </div>

      <div v-else class="space-y-14">
        <!-- Key metrics -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-6">
          <ManagerModernCard 
            v-for="stat in dashboardSummary" 
            :key="stat.name"
            class="p-6"
          >
            <div class="flex items-center gap-4">
              <div :class="[
                stat.iconBg, 
                'w-12 h-12 rounded-full flex items-center justify-center'
              ]">
                <component :is="stat.icon" class="w-6 h-6" :class="stat.iconColor" />
              </div>
              <div>
                <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
                <span class="text-sm text-gray-500">{{ stat.name }}</span>
              </div>
            </div>
          </ManagerModernCard>
        </div>

        <!-- Orders & Products -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Recent Orders -->
          <div class="bg-white rounded-3xl shaodw--lg hover:shaodw--xl transition-all duration-300 border border-gray-100 overflow-hidden">
            <div class="flex items-center justify-between px-7 py-6 border-b border-gray-100">
              <h3 class="text-xl sm:text-2xl font-bold text-gray-900">Commandes récentes</h3>
            </div>
            
            <div class="divide-y divide-gray-50">
              <div 
                v-for="order in recentOrders.slice(0, 3)" 
                :key="order.id"
                class="px-7 py-5 hover:bg-gray-50 transition-colors"
              >
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-5">
                    <div :class="[
                      getStatusColor(order.status).bg,
                      'w-12 h-12 rounded-2xl flex items-center justify-center shaodw--sm'
                    ]">
                      <component 
                        :is="getStatusIcon(order.status)"
                        class="w-6 h-6"
                        :class="getStatusColor(order.status).text"
                      />
                    </div>
                    <div>
                      <div class="flex items-center gap-2">
                        <p class="font-bold text-base text-gray-900">#{{ formatOrderNumber(order.id) }}</p>
                        <span class="text-xs px-3 py-1 rounded-full"
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
                  <p class="font-bold text-xl text-gray-900">{{ formatPrice(order.total_amount) }}</p>
                </div>
              </div>
            </div>
            
            <div class="bg-gradient-to-r from-blue-50 to-gray-50 px-7 py-4 border-t border-gray-100 text-center">
              <NuxtLink 
                :to="`/manager/${establishment?.id}/orders`"
                class="text-blue-600 font-bold hover:text-blue-700 transition-colors text-base inline-flex items-center gap-2 group"
              >
                <span>Voir toutes les commandes</span>
                <ArrowRight class="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </NuxtLink>
            </div>
          </div>

          <!-- Popular Products -->
          <div class="bg-white rounded-3xl shaodw--lg hover:shaodw--xl transition-all duration-300 border border-gray-100 overflow-hidden">
            <div class="flex items-center justify-between px-7 py-6 border-b border-gray-100">
              <h3 class="text-xl sm:text-2xl font-bold text-gray-900">Produits populaires</h3>
            </div>
            
            <div class="divide-y divide-gray-50">
              <div 
                v-for="product in popularProducts.slice(0, 3)" 
                :key="product.id"
                class="px-7 py-5 hover:bg-gray-50 transition-colors"
              >
                <div class="flex items-center gap-5">
                  <img 
                    :src="product.image_url || '/default-product.png'" 
                    class="w-16 h-16 rounded-2xl object-cover shaodw--sm border border-gray-100"
                    alt="Product"
                  />
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between">
                      <p class="font-bold text-lg text-gray-900 truncate">{{ product.name }}</p>
                      <p class="font-bold text-xl text-gray-900">{{ formatPrice(product.price) }}</p>
                    </div>
                    <div class="flex items-center gap-3 mt-2">
                      <p class="text-sm text-gray-500">{{ product.total_quantity || 0 }} vendus</p>
                      <div class="flex-1 h-3 bg-gray-100 rounded-full overflow-hidden">
                        <div 
                          class="h-full bg-blue-600 rounded-full"
                          :style="{ width: `${getPercentage(product.total_quantity, maxQuantity)}%` }"
                        ></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="bg-gradient-to-r from-blue-50 to-gray-50 px-7 py-4 border-t border-gray-100 text-center">
              <NuxtLink 
                :to="`/manager/${establishment?.id}/menu`"
                class="text-blue-600 font-bold hover:text-blue-700 transition-colors text-base inline-flex items-center gap-2 group"
              >
                <span>Gérer le menu</span>
                <ArrowRight class="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </NuxtLink>
            </div>
          </div>
        </div>

        <!-- Category Performance -->
        <div>
          <div class="flex items-center justify-between mb-6 sm:mb-8">
            <h3 class="text-xl sm:text-2xl font-bold text-gray-900">Performance par catégorie</h3>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8">
            <div 
              v-for="category in categoryPerformance.slice(0, 3)" 
              :key="category.id"
              class="bg-white rounded-3xl p-6 sm:p-8 shaodw--lg hover:shaodw--xl transition-all duration-300 border border-gray-100 overflow-hidden"
            >
              <div class="flex flex-col items-center text-center mb-6">
                <img 
                  :src="category.image_url || '/default-category.png'" 
                  class="w-20 h-20 rounded-2xl object-cover border border-gray-100 shaodw--sm mb-4"
                  alt="Category"
                />
                <p class="font-bold text-xl text-gray-900">{{ category.name }}</p>
                <p class="text-sm text-gray-500">{{ category.product_count }} produits</p>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="bg-gray-50 rounded-2xl p-4 hover:bg-blue-50 transition-colors text-center">
                  <p class="text-gray-500 text-xs font-medium mb-1">Ventes</p>
                  <p class="font-bold text-xl sm:text-2xl text-gray-900">{{ formatPrice(category.total_revenue || 0) }}</p>
                </div>
                <div class="bg-gray-50 rounded-2xl p-4 hover:bg-blue-50 transition-colors text-center">
                  <p class="text-gray-500 text-xs font-medium mb-1">Vendus</p>
                  <p class="font-bold text-xl sm:text-2xl text-gray-900">{{ category.total_items_sold || 0 }}</p>
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
  RefreshCw,
  ArrowRight,
  LayoutDashboard
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

// Data from views with proper TypeScript types
const dashboardSummary = ref<{
  name: string;
  value: string | number;
  icon: any;
  iconBg: string;
  iconColor: string;
}[]>([])

const recentOrders = ref<{
  id: string;
  status: string;
  table_number: number;
  total_amount: number;
  created_at: string;
}[]>([])

const popularProducts = ref<{
  id: string;
  name: string;
  price: number;
  image_url: string | null;
  total_quantity: number;
}[]>([])

const categoryPerformance = ref<{
  id: string;
  name: string;
  image_url: string | null;
  product_count: number;
  total_revenue: number;
  total_items_sold: number;
}[]>([])

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
    
  } catch (error: any) {
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
