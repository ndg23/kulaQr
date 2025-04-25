<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Vue d'ensemble</h1>
        <p class="text-gray-600">Tableau de bord</p>
      </div>
  
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div v-for="stat in stats" :key="stat.name" 
          class="bg-white p-6 rounded-3xl border border-gray-100 transition-all hover:scale-[1.02]"
        >
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" 
                class="w-6 h-6"
                :class="stat.iconColor" 
              />
            </div>
            <div>
              <p class="text-sm text-gray-500">{{ stat.name }}</p>
              <h3 class="text-2xl font-semibold text-gray-900 mt-1">{{ stat.value }}</h3>
            </div>
          </div>
        </div>
      </div>
  
      <!-- Main Content -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Orders -->
        <div class="bg-white rounded-3xl border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <h2 class="text-lg font-semibold text-gray-900">Commandes récentes</h2>
              </div>
            </div>
          </div>
  
          <div class="divide-y divide-gray-100">
            <div v-for="order in recentOrders" :key="order.id" 
              class="p-4 hover:bg-gray-50 transition-colors"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <Store class="w-5 h-5 text-gray-500" />
                  </div>
                  <div>
                    <div class="font-medium text-gray-900">{{ order.restaurant }}</div>
                    <div class="text-sm text-gray-500">{{ order.time }}</div>
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium text-gray-900">{{ order.amount }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Popular Restaurants -->
        <div class="bg-white rounded-3xl border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <h2 class="text-lg font-semibold text-gray-900">Restaurants populaires</h2>
              </div>
            </div>
          </div>
  
          <div class="p-6">
            <div class="space-y-6">
              <div v-for="restaurant in popularRestaurants" :key="restaurant.id" 
                class="flex items-center justify-between"
              >
                <div class="flex items-center space-x-3">
                  <div class="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <Store class="w-6 h-6 text-gray-500" />
                  </div>
                  <div>
                    <div class="font-medium text-gray-900">{{ restaurant.name }}</div>
                    <div class="text-sm text-gray-500">{{ restaurant.orders }} commandes</div>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <Star class="w-4 h-4 text-yellow-400 fill-current" />
                  <span class="font-medium">{{ restaurant.rating }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import {
    Store, ShoppingBag, Star, Users, CreditCard
  } from 'lucide-vue-next'
  import { useSupabaseWrapper } from '~/composables/useSupabase'
  import { useCustomToast } from '~/composables/useToast'
  
  const { client: supabase } = useSupabaseWrapper()
  const { showToast } = useCustomToast()
  const loading = ref(true)
  
  // Dashboard data
  const dashboardData = ref({
    restaurants: 0,
    users: 0,
    orders: 0,
    revenue: 0
  })
  
  // Recent orders
  const recentOrders = ref([])
  
  // Popular restaurants
  const popularRestaurants = ref([])
  
  // Load dashboard data
  const loadDashboardData = async () => {
    try {
      loading.value = true
  
      // Load counts with error handling
      try {
        const [
          restaurantsResponse,
          usersResponse
        ] = await Promise.all([
          // Count restaurants
          supabase
            .from('establishments')
            .select('id', { count: 'exact', head: true }),
          
          // Count users
          supabase
            .from('users')
            .select('id', { count: 'exact', head: true })
        ])
  
        // Update dashboard data
        dashboardData.value = {
          ...dashboardData.value,
          restaurants: restaurantsResponse.count || 0,
          users: usersResponse.count || 0
        }
      } catch (err) {
        console.error('Error loading basic counts:', err)
      }
  
      // Try to load order stats
      try {
        const { data: orderStats, error: orderError } = await supabase
          .rpc('get_order_stats')
        
        if (!orderError && orderStats) {
          dashboardData.value.orders = orderStats.total_orders || 0
          dashboardData.value.revenue = orderStats.total_revenue || 0
        }
      } catch (err) {
        console.error('Error loading order stats:', err)
        // Non-critical error, we can continue
      }
  
      // Load recent orders and popular restaurants
      await Promise.allSettled([
        loadRecentOrders(),
        loadPopularRestaurants()
      ])
  
    } catch (error) {
      console.error('Error loading dashboard data:', error)
      showToast.error('Erreur', 'Impossible de charger les données du tableau de bord')
    } finally {
      loading.value = false
    }
  }
  
  // Load recent orders with better error handling
  const loadRecentOrders = async () => {
    try {
      // Check if orders table exists by trying to query it
      const { error: checkError } = await supabase
        .from('orders')
        .select('id')
        .limit(1)
      
      if (checkError) {
        console.log('Orders table may not exist yet:', checkError)
        return
      }
  
      const { data, error } = await supabase
        .from('orders')
        .select(`
          id,
          total_amount,
          created_at,
          establishments(name)
        `)
        .order('created_at', { ascending: false })
        .limit(5)
  
      if (error) throw error
  
      recentOrders.value = data.map(order => ({
        id: order.id,
        restaurant: order.establishments?.name || 'Restaurant inconnu',
        time: formatRelativeTime(order.created_at),
        amount: formatCurrency(order.total_amount)
      }))
    } catch (error) {
      console.error('Error loading recent orders:', error)
      // Set empty array as fallback
      recentOrders.value = []
    }
  }
  
  // Load popular restaurants
  const loadPopularRestaurants = async () => {
    try {
      // This query assumes you have a view or function that returns popular restaurants
      // If not, you can create one or use a simpler query
      const { data, error } = await supabase
        .rpc('get_popular_restaurants')
        .limit(5)
  
      if (error) {
        // Fallback to a simpler query if the RPC doesn't exist
        const { data: fallbackData, error: fallbackError } = await supabase
          .from('establishments')
          .select(`
            id,
            name,
            orders:orders(id)
          `)
          .order('created_at', { ascending: false })
          .limit(5)
  
        if (fallbackError) throw fallbackError
  
        popularRestaurants.value = fallbackData.map(restaurant => ({
          id: restaurant.id,
          name: restaurant.name,
          orders: restaurant.orders?.length || 0,
          rating: 4.5 // Default rating since we don't have ratings yet
        }))
      } else {
        popularRestaurants.value = data
      }
    } catch (error) {
      console.error('Error loading popular restaurants:', error)
      // Set some default data
      popularRestaurants.value = []
    }
  }
  
  // Format relative time (e.g., "5 minutes ago")
  const formatRelativeTime = (timestamp) => {
    if (!timestamp) return 'Date inconnue'
    
    const now = new Date()
    const date = new Date(timestamp)
    const diffMs = now - date
    const diffSec = Math.floor(diffMs / 1000)
    const diffMin = Math.floor(diffSec / 60)
    const diffHour = Math.floor(diffMin / 60)
    const diffDay = Math.floor(diffHour / 24)
  
    if (diffMin < 1) return 'À l\'instant'
    if (diffMin < 60) return `Il y a ${diffMin} minute${diffMin > 1 ? 's' : ''}`
    if (diffHour < 24) return `Il y a ${diffHour} heure${diffHour > 1 ? 's' : ''}`
    if (diffDay < 30) return `Il y a ${diffDay} jour${diffDay > 1 ? 's' : ''}`
    
    return date.toLocaleDateString('fr-FR')
  }
  
  // Format currency
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('fr-FR', { 
      style: 'currency', 
      currency: 'XOF' 
    }).format(amount || 0)
  }
  
  // Computed stats for display
  const stats = computed(() => [
    {
      name: 'Restaurants',
      value: formatNumber(dashboardData.value.restaurants),
      icon: Store,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    },
    {
      name: 'Clients',
      value: formatNumber(dashboardData.value.users),
      icon: Users,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    {
      name: 'Commandes',
      value: formatNumber(dashboardData.value.orders),
      icon: ShoppingBag,
      iconBg: 'bg-purple-50',
      iconColor: 'text-purple-500'
    },
    {
      name: 'Revenu',
      value: formatNumber(dashboardData.value.revenue),
      icon: CreditCard,
      iconBg: 'bg-orange-50',
      iconColor: 'text-orange-500'
    }
  ])
  
  // Format large numbers (e.g., 1234 -> 1.2k)
  const formatNumber = (num) => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}k`
    }
    return num.toString()
  }
  
  // Load data on mount
  onMounted(loadDashboardData)
  
  definePageMeta({
    layout: 'admin'
  })
  </script>