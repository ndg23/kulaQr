<template>
  <div class="min-h-screen bg-[#F8FAFC]">
    <ManagerHeader :establishment="establishment" />
    
    <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <!-- Stats Overview -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div 
          v-for="stat in stats" 
          :key="stat.label"
          class="bg-white rounded-2xl p-6 shadow-[0_2px_8px_rgb(0,0,0,0.04)] hover:shadow-[0_4px_12px_rgb(0,0,0,0.06)] transition-shadow duration-200"
        >
          <div class="flex items-center justify-between mb-3">
            <div class="text-sm font-medium text-gray-600">{{ stat.label }}</div>
            <div 
              class="w-8 h-8 rounded-full flex items-center justify-center"
              :class="stat.iconBg"
            >
              <Icon :name="stat.icon" class="w-4 h-4 text-white" />
            </div>
          </div>
          <div class="flex items-baseline">
            <div class="text-2xl font-semibold text-gray-900">{{ stat.value }}</div>
            <div 
              class="ml-2 text-sm flex items-center"
              :class="stat.trend > 0 ? 'text-emerald-600' : 'text-rose-600'"
            >
              <Icon 
                :name="stat.trend > 0 ? 'trending-up' : 'trending-down'"
                class="w-4 h-4 mr-1"
              />
              {{ Math.abs(stat.trend) }}%
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white rounded-2xl shadow-[0_2px_8px_rgb(0,0,0,0.04)] mb-8">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Actions rapides</h2>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 p-6">
          <button
            v-for="action in quickActions"
            :key="action.label"
            class="group flex flex-col items-center p-4 rounded-xl hover:bg-gray-50 transition-all duration-200"
            @click="navigateTo(action.path)"
          >
            <div 
              class="w-12 h-12 rounded-full flex items-center justify-center mb-3 transition-transform duration-200 group-hover:scale-110"
              :class="action.bgColor"
            >
              <Icon 
                :name="action.icon" 
                class="w-5 h-5 text-white"
              />
            </div>
            <span class="text-sm font-medium text-gray-700">{{ action.label }}</span>
          </button>
        </div>
      </div>

      <!-- Recent Orders -->
      <div class="bg-white rounded-2xl shadow-[0_2px_8px_rgb(0,0,0,0.04)]">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-lg font-semibold text-gray-900">Commandes récentes</h2>
              <p class="text-sm text-gray-500 mt-1">Mise à jour en temps réel</p>
            </div>
            <button class="inline-flex items-center text-sm text-blue-600 hover:text-blue-700">
              Voir tout
              <Icon name="arrow-right" class="w-4 h-4 ml-1" />
            </button>
          </div>
        </div>
        <div class="divide-y divide-gray-100">
          <div 
            v-for="order in recentOrders" 
            :key="order.id"
            class="p-4 hover:bg-gray-50 transition-colors duration-200"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <div 
                  class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center"
                >
                  <Icon name="utensils" class="w-5 h-5 text-gray-500" />
                </div>
                <div>
                  <div class="font-medium text-gray-900">Table {{ order.table_number }}</div>
                  <div class="text-sm text-gray-500 flex items-center">
                    <Icon name="clock" class="w-4 h-4 mr-1" />
                    {{ formatTime(order.created_at) }}
                  </div>
                </div>
              </div>
              <div class="flex items-center space-x-4">
                <div class="text-right">
                  <div class="font-medium text-gray-900">{{ formatPrice(order.total_amount) }}</div>
                  <div class="text-sm text-gray-500">{{ order.items_count }} articles</div>
                </div>
                <StatusBadge :status="order.status" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const slug = route.params.slug as string

// State
const establishment = ref<Establishment | null>(null)
const recentOrders = ref<Order[]>([])
const stats = ref([
  { 
    label: "Commandes aujourd'hui",
    value: "0",
    trend: 0,
    icon: "shopping-cart",
    iconBg: "bg-blue-500/10"
  },
  { 
    label: "Chiffre d'affaires",
    value: "0€",
    trend: 0,
    icon: "currency-euro",
    iconBg: "bg-emerald-500/10"
  },
  { 
    label: "Temps moyen",
    value: "0min",
    trend: 0,
    icon: "clock",
    iconBg: "bg-amber-500/10"
  },
  { 
    label: "Satisfaction",
    value: "0",
    trend: 0,
    icon: "star",
    iconBg: "bg-rose-500/10"
  }
])

const quickActions = [
  {
    label: 'Nouveau produit',
    icon: 'plus-circle',
    path: `/manager/${slug}/products/new`,
    bgColor: 'bg-gradient-to-br from-blue-500 to-blue-600'
  },
  {
    label: 'QR Codes',
    icon: 'qr-code',
    path: `/manager/${slug}/qr-codes`,
    bgColor: 'bg-gradient-to-br from-purple-500 to-purple-600'
  },
  {
    label: 'Catégories',
    icon: 'list',
    path: `/manager/${slug}/categories`,
    bgColor: 'bg-gradient-to-br from-amber-500 to-amber-600'
  },
  {
    label: 'Statistiques',
    icon: 'chart-bar',
    path: `/manager/${slug}/stats`,
    bgColor: 'bg-gradient-to-br from-emerald-500 to-emerald-600'
  }
]

// Load data
const loadEstablishment = async () => {
  const { data, error } = await supabase
    .from('establishments')
    .select('*')
    .eq('id', slug)
    .single()

  if (error) throw error
  establishment.value = data
}

const loadStats = async () => {
  const today = new Date().toISOString().split('T')[0]
  
  // Get today's orders
  const { data: todayOrders } = await supabase
    .from('orders')
    .select('*')
    .eq('establishment_id', slug)
    .gte('created_at', today)

  // Get yesterday's orders for comparison
  const yesterday = new Date(new Date().setDate(new Date().getDate() - 1))
    .toISOString().split('T')[0]
  
  const { data: yesterdayOrders } = await supabase
    .from('orders')
    .select('*')
    .eq('establishment_id', slug)
    .gte('created_at', yesterday)
    .lt('created_at', today)

  // Calculate trends
  const todayCount = todayOrders?.length || 0
  const yesterdayCount = yesterdayOrders?.length || 0
  const ordersTrend = yesterdayCount ? 
    ((todayCount - yesterdayCount) / yesterdayCount) * 100 : 0

  const todayRevenue = todayOrders?.reduce((sum, order) => sum + order.total_amount, 0) || 0
  const yesterdayRevenue = yesterdayOrders?.reduce((sum, order) => sum + order.total_amount, 0) || 0
  const revenueTrend = yesterdayRevenue ? 
    ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100 : 0

  // Update stats
  stats.value = [
    {
      label: "Commandes aujourd'hui",
      value: todayCount.toString(),
      trend: Math.round(ordersTrend),
      icon: "shopping-cart",
      iconBg: "bg-blue-500/10"
    },
    {
      label: "Chiffre d'affaires",
      value: formatPrice(todayRevenue),
      trend: Math.round(revenueTrend),
      icon: "currency-euro",
      iconBg: "bg-emerald-500/10"
    },
    // ... autres stats
  ]
}

const loadRecentOrders = async () => {
  const { data } = await supabase
    .from('orders')
    .select('*, order_items(*)')
    .eq('establishment_id', slug)
    .order('created_at', { ascending: false })
    .limit(5)

  if (data) {
    recentOrders.value = data.map(order => ({
      ...order,
      items_count: order.order_items.length
    }))
  }
}

// Real-time updates
onMounted(async () => {
  await Promise.all([
    loadEstablishment(),
    loadStats(),
    loadRecentOrders()
  ])

  // Subscribe to new orders
  const channel = supabase
    .channel('orders')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${slug}`
      },
      () => {
        loadStats()
        loadRecentOrders()
      }
    )
    .subscribe()

  onUnmounted(() => {
    channel.unsubscribe()
  })
})
</script> 