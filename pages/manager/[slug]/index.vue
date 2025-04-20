<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
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

      <!-- Active Tables -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 bg-emerald-50 rounded-xl flex items-center justify-center">
            <Users class="w-6 h-6 text-emerald-500" />
          </div>
          <span class="text-sm font-medium text-emerald-500">En cours</span>
        </div>
        <div class="space-y-1">
          <h3 class="text-2xl font-bold text-gray-900">{{ stats.activeTables }} tables</h3>
          <p class="text-sm text-gray-500">occupées</p>
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
          <h3 class="text-2xl font-bold text-gray-900">{{ stats.topProduct }}</h3>
          <p class="text-sm text-gray-500">{{ stats.topProductOrders }} commandes</p>
        </div>
      </div>
    </div>

    <!-- Recent Orders -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 border-b border-gray-100">
        <h2 class="text-lg font-semibold text-gray-900">Commandes récentes</h2>
      </div>
      <div class="divide-y divide-gray-100">
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
import { ref, onMounted, onUnmounted } from 'vue'
import { ShoppingCart, Users, Utensils } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { formatPrice, formatTime } from '~/utils/format'

definePageMeta({
  layout: 'manager'
})

const route = useRoute()
const slug = route.params.slug as string
const { client: supabase } = useSupabaseWrapper()

const stats = ref({
  orders: 0,
  revenue: '0 €',
  activeTables: 0,
  topProduct: '-',
  topProductOrders: 0
})

const recentOrders = ref([])

const REFRESH_INTERVAL = 30000 // 30 secondes

const orderStatusMap = {
  'completed': 'Terminée',
  'pending': 'En attente',
  'preparing': 'En préparation'
}

const loading = ref(false)

const loadDashboardData = async () => {
  loading.value = true
  try {
    const today = new Date().toISOString().split('T')[0]
    
    // Get today's orders
    const { data: todayOrders } = await supabase
      .from('orders')
      .select('*, order_items(*)')
      .eq('establishment_id', slug)
      .gte('created_at', today)
      .order('created_at', { ascending: false })

    if (todayOrders) {
      // Calculate stats
      const totalAmount = todayOrders.reduce((sum, order) => sum + order.total_amount, 0)
      const activeTables = todayOrders.filter(order => order.status !== 'completed').length

      stats.value.orders = todayOrders.length
      stats.value.revenue = formatPrice(totalAmount)
      stats.value.activeTables = activeTables

      // Get recent orders
      recentOrders.value = todayOrders.slice(0, 5)
    }

    // Get most popular product
    const { data: popular } = await supabase
      .from('products')
      .select('name, orders_count')
      .eq('establishment_id', slug)
      .order('orders_count', { ascending: false })
      .limit(1)
      .single()

    if (popular) {
      stats.value.topProduct = popular.name
      stats.value.topProductOrders = popular.orders_count
    }
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboardData()
  const interval = setInterval(loadDashboardData, REFRESH_INTERVAL)
  onUnmounted(() => clearInterval(interval))
})
</script> 