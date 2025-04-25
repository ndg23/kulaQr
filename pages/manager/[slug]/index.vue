<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <!-- Header with Date -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Tableau de bord</h1>
        <p class="mt-1 text-sm text-gray-500">{{ formattedDate }}</p>
      </div>
      <button 
        @click="loadDashboardData" 
        class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors"
      >
        <RefreshCw class="w-4 h-4 mr-1.5" />
        Actualiser
      </button>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <!-- Today's Orders -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
            <ShoppingCart class="w-6 h-6 text-blue-500" />
          </div>
          <span class="text-sm font-medium text-blue-500">Aujourd'hui</span>
        </div>
        <div class="space-y-1">
          <h3 class="text-2xl font-bold text-gray-900">{{ stats.orders }} commandes</h3>
          <p class="text-sm text-gray-500">{{ stats.revenue }}</p>
        </div>
      </div>

      <!-- Average Order Value -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-green-50 rounded-xl flex items-center justify-center">
            <TrendingUp class="w-6 h-6 text-green-500" />
          </div>
          <span class="text-sm font-medium text-green-500">Moyenne</span>
        </div>
        <div class="space-y-1">
          <h3 class="text-2xl font-bold text-gray-900">{{ stats.averageOrderValue }}</h3>
          <p class="text-sm text-gray-500">par commande</p>
        </div>
      </div>

      <!-- Popular Items -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-purple-50 rounded-xl flex items-center justify-center">
            <Utensils class="w-6 h-6 text-purple-500" />
          </div>
          <span class="text-sm font-medium text-purple-500">Plus vendus</span>
        </div>
        <div class="space-y-1">
          <h3 class="text-2xl font-bold text-gray-900">{{ stats.topProduct || 'Aucun' }}</h3>
          <p class="text-sm text-gray-500">{{ stats.topProductOrders > 0 ? `${stats.topProductOrders} commandes` : 'Pas de données' }}</p>
        </div>
      </div>
    </div>

    <!-- Secondary Stats -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
      <!-- Category Performance -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Performance par catégorie</h2>
        </div>
        <div class="p-6">
          <div v-if="loading" class="flex justify-center py-8">
            <Loader2 class="w-8 h-8 text-gray-300 animate-spin" />
          </div>
          <div v-else-if="stats.categoryPerformance.length === 0" class="text-center py-8">
            <div class="w-16 h-16 mx-auto bg-gray-50 rounded-full flex items-center justify-center mb-4">
              <ChartPie class="w-8 h-8 text-gray-300" />
            </div>
            <p class="text-gray-500">Pas de données disponibles</p>
          </div>
          <div v-else class="space-y-4">
            <div v-for="category in stats.categoryPerformance" :key="category.id" class="flex items-center">
              <div class="w-32 flex-shrink-0">
                <p class="text-sm font-medium text-gray-700 truncate">{{ category.name }}</p>
              </div>
              <div class="flex-1 ml-4">
                <div class="w-full bg-gray-100 rounded-full h-2.5">
                  <div class="bg-blue-500 h-2.5 rounded-full" :style="`width: ${category.percentage}%`"></div>
                </div>
              </div>
              <div class="ml-4 flex-shrink-0 w-16 text-right">
                <p class="text-sm font-medium text-gray-900">{{ category.percentage }}%</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Time Distribution -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Répartition horaire</h2>
        </div>
        <div class="p-6">
          <div v-if="loading" class="flex justify-center py-8">
            <Loader2 class="w-8 h-8 text-gray-300 animate-spin" />
          </div>
          <div v-else-if="stats.hourlyDistribution.length === 0" class="text-center py-8">
            <div class="w-16 h-16 mx-auto bg-gray-50 rounded-full flex items-center justify-center mb-4">
              <Clock class="w-8 h-8 text-gray-300" />
            </div>
            <p class="text-gray-500">Pas de données disponibles</p>
          </div>
          <div v-else class="space-y-4">
            <div v-for="hour in stats.hourlyDistribution" :key="hour.hour" class="flex items-center">
              <div class="w-16 flex-shrink-0">
                <p class="text-sm font-medium text-gray-700">{{ hour.label }}</p>
              </div>
              <div class="flex-1 ml-4">
                <div class="w-full bg-gray-100 rounded-full h-2.5">
                  <div class="bg-green-500 h-2.5 rounded-full" :style="`width: ${hour.percentage}%`"></div>
                </div>
              </div>
              <div class="ml-4 flex-shrink-0 w-16 text-right">
                <p class="text-sm font-medium text-gray-900">{{ hour.count }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Orders -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 border-b border-gray-100 flex items-center justify-between">
        <h2 class="text-lg font-semibold text-gray-900">Commandes récentes</h2>
        <NuxtLink 
          to="/orders" 
          class="text-sm font-medium text-blue-500 hover:text-blue-600 transition-colors"
        >
          Voir toutes
        </NuxtLink>
      </div>
      <div v-if="loading" class="flex justify-center py-12">
        <Loader2 class="w-8 h-8 text-gray-300 animate-spin" />
      </div>
      <div v-else-if="recentOrders.length === 0" class="text-center py-12">
        <div class="w-16 h-16 mx-auto bg-gray-50 rounded-full flex items-center justify-center mb-4">
          <ShoppingCart class="w-8 h-8 text-gray-300" />
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-1">Aucune commande</h3>
        <p class="text-gray-500 max-w-sm mx-auto">
          Vous n'avez pas encore reçu de commandes aujourd'hui.
        </p>
      </div>
      <div v-else class="divide-y divide-gray-100">
        <div 
          v-for="order in recentOrders" 
          :key="order.id"
          class="p-4 hover:bg-gray-50 transition-colors"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <div class="w-10 h-10 bg-blue-50 rounded-xl flex items-center justify-center">
                <span class="text-blue-500 font-medium">T{{ order.table_number }}</span>
              </div>
              <div>
                <div class="font-medium text-gray-900">{{ formatPrice(order.total_amount) }}</div>
                <div class="text-sm text-gray-500">{{ formatTime(order.created_at) }}</div>
              </div>
            </div>
            <div class="flex items-center space-x-2">
              <span 
                class="px-3 py-1 rounded-full text-sm font-medium"
                :class="{
                  'bg-emerald-50 text-emerald-600': order.status === 'completed',
                  'bg-amber-50 text-amber-600': order.status === 'pending',
                  'bg-blue-50 text-blue-600': order.status === 'preparing'
                }"
              >
                {{ orderStatusMap[order.status] }}
              </span>
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
  ShoppingCart, Users, Utensils, TrendingUp, 
  RefreshCw, ChartPie, Clock, Loader2 
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { formatPrice, formatTime } from '~/utils/format'

definePageMeta({
  layout: 'manager'
})

const route = useRoute()
const slug = route.params.slug as string
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const stats = ref({
  orders: 0,
  revenue: '0 XOF',
  averageOrderValue: '0 XOF',
  activeTables: 0,
  topProduct: '-',
  topProductOrders: 0,
  categoryPerformance: [],
  hourlyDistribution: []
})

const recentOrders = ref([])
const loading = ref(true)

const orderStatusMap = {
  'completed': 'Terminée',
  'pending': 'En attente',
  'preparing': 'En préparation'
}

// Format today's date
const formattedDate = computed(() => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date().toLocaleDateString('fr-FR', options)
})

const loadDashboardData = async () => {
  loading.value = true
  try {
    const today = new Date().toISOString().split('T')[0]
    
    // Get today's orders
    const { data: todayOrders, error: ordersError } = await supabase
      .from('orders')
      .select('*, order_items(*)')
      .eq('establishment_id', slug)
      .gte('created_at', today)
      .order('created_at', { ascending: false })
    
    if (ordersError) throw ordersError

    if (todayOrders && todayOrders.length > 0) {
      // Calculate stats
      const totalAmount = todayOrders.reduce((sum, order) => sum + order.total_amount, 0)
      const activeTables = todayOrders.filter(order => order.status !== 'completed').length
      const avgOrderValue = totalAmount / todayOrders.length

      stats.value.orders = todayOrders.length
      stats.value.revenue = formatPrice(totalAmount)
      stats.value.averageOrderValue = formatPrice(avgOrderValue)
      stats.value.activeTables = activeTables
      
      // Get recent orders
      recentOrders.value = todayOrders.slice(0, 5)
      
      // Calculate hourly distribution
      const hourCounts = {}
      const maxHourCount = { count: 0 }
      
      todayOrders.forEach(order => {
        const hour = new Date(order.created_at).getHours()
        hourCounts[hour] = (hourCounts[hour] || 0) + 1
        if (hourCounts[hour] > maxHourCount.count) {
          maxHourCount.count = hourCounts[hour]
        }
      })
      
      stats.value.hourlyDistribution = Object.keys(hourCounts).map(hour => {
        const percentage = Math.round((hourCounts[hour] / maxHourCount.count) * 100)
        return {
          hour,
          label: `${hour}h`,
          count: hourCounts[hour],
          percentage
        }
      }).sort((a, b) => parseInt(a.hour) - parseInt(b.hour))
    } else {
      // Reset stats if no orders
      stats.value.orders = 0
      stats.value.revenue = formatPrice(0)
      stats.value.averageOrderValue = formatPrice(0)
      stats.value.activeTables = 0
      recentOrders.value = []
      stats.value.hourlyDistribution = []
    }

    // Get category performance
    const { data: categories, error: categoriesError } = await supabase
      .from('categories')
      .select('id, name')
      .eq('establishment_id', slug)
    
    if (categoriesError) throw categoriesError
    
    if (categories && categories.length > 0) {
      // Get product counts by category
      const { data: products, error: productsError } = await supabase
        .from('products')
        .select('category_id, orders_count')
        .eq('establishment_id', slug)
      
      if (productsError) throw productsError
      
      if (products && products.length > 0) {
        const categoryCounts = {}
        let totalOrders = 0
        
        products.forEach(product => {
          if (product.category_id) {
            categoryCounts[product.category_id] = (categoryCounts[product.category_id] || 0) + (product.orders_count || 0)
            totalOrders += (product.orders_count || 0)
          }
        })
        
        stats.value.categoryPerformance = categories
          .map(category => ({
            id: category.id,
            name: category.name,
            count: categoryCounts[category.id] || 0,
            percentage: totalOrders > 0 
              ? Math.round((categoryCounts[category.id] || 0) / totalOrders * 100) 
              : 0
          }))
          .filter(cat => cat.count > 0)
          .sort((a, b) => b.count - a.count)
      } else {
        stats.value.categoryPerformance = []
      }
    }

    // Get most popular product
    const { data: popular, error: popularError } = await supabase
      .from('products')
      .select('name, orders_count')
      .eq('establishment_id', slug)
      .order('orders_count', { ascending: false })
      .limit(1)
      .single()
    
    if (!popularError && popular) {
      stats.value.topProduct = popular.name
      stats.value.topProductOrders = popular.orders_count || 0
    } else {
      stats.value.topProduct = '-'
      stats.value.topProductOrders = 0
    }
  } catch (error) {
    console.error('Error loading dashboard data:', error)
    showToast.error('Erreur', 'Impossible de charger les données du tableau de bord')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
/* Animation for the loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style> 