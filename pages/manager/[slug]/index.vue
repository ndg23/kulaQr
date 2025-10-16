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

      <div v-else class="space-y-8">
        <!-- 3 métriques principales -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <ManagerModernCard 
            v-for="stat in mainMetrics" 
            :key="stat.name"
            class="p-6 text-center"
          >
              <div :class="[
                stat.iconBg, 
              'w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4'
              ]">
              <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
            </div>
            <p class="text-3xl font-bold text-gray-900 mb-2">{{ stat.value }}</p>
            <span class="text-sm text-gray-500">{{ stat.name }}</span>
          </ManagerModernCard>
        </div>

        <!-- Actions rapides -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <NuxtLink 
                :to="`/manager/${establishment?.id}/orders`"
            class="group"
          >
            <ManagerModernCard class="p-6 text-center hover:shadow-lg transition-all duration-200">
              <div class="w-16 h-16 rounded-2xl bg-blue-50 flex items-center justify-center mx-auto mb-4 group-hover:bg-blue-100 transition-colors">
                <ShoppingCart class="w-8 h-8 text-blue-500" />
              </div>
              <h3 class="text-lg font-bold text-gray-900 mb-2">Voir les commandes</h3>
              <p class="text-sm text-gray-500">{{ recentOrders.length }} commandes récentes</p>
            </ManagerModernCard>
          </NuxtLink>
            
              <NuxtLink 
                :to="`/manager/${establishment?.id}/menu`"
            class="group"
          >
            <ManagerModernCard class="p-6 text-center hover:shadow-lg transition-all duration-200">
              <div class="w-16 h-16 rounded-2xl bg-green-50 flex items-center justify-center mx-auto mb-4 group-hover:bg-green-100 transition-colors">
                <ChefHat class="w-8 h-8 text-green-500" />
              </div>
              <h3 class="text-lg font-bold text-gray-900 mb-2">Gérer le menu</h3>
              <p class="text-sm text-gray-500">{{ popularProducts.length }} produits populaires</p>
            </ManagerModernCard>
          </NuxtLink>

          <NuxtLink 
            :to="`/manager/${establishment?.id}/qr-codes`"
            class="group"
          >
            <ManagerModernCard class="p-6 text-center hover:shadow-lg transition-all duration-200">
              <div class="w-16 h-16 rounded-2xl bg-orange-50 flex items-center justify-center mx-auto mb-4 group-hover:bg-orange-100 transition-colors">
                <QrCode class="w-8 h-8 text-orange-500" />
              </div>
              <h3 class="text-lg font-bold text-gray-900 mb-2">Imprimer QR code</h3>
              <p class="text-sm text-gray-500">Menu digital</p>
            </ManagerModernCard>
          </NuxtLink>
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
  LayoutDashboard,
  QrCode
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

// Données simplifiées
const recentOrders = ref<any[]>([])
const popularProducts = ref<any[]>([])

// 3 métriques principales
const mainMetrics = computed(() => {
  const todayRevenue = recentOrders.value
    .filter(order => {
      const today = new Date().toDateString()
      const orderDate = new Date(order.created_at).toDateString()
      return today === orderDate
    })
    .reduce((sum, order) => sum + (order.total_amount || 0), 0)

  const pendingOrders = recentOrders.value.filter(order => order.status === 'pending').length

  return [
    {
      name: 'Revenus aujourd\'hui',
      value: formatPrice(todayRevenue),
      icon: DollarSign,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    {
      name: 'Commandes en attente',
      value: pendingOrders,
      icon: Coffee,
      iconBg: pendingOrders > 0 ? 'bg-red-50' : 'bg-green-50',
      iconColor: pendingOrders > 0 ? 'text-red-500' : 'text-green-500'
    },
    {
      name: 'Produits populaires',
      value: popularProducts.value.length,
      icon: ChefHat,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    }
  ]
})

// Charger les données essentielles
const loadData = async () => {
  try {
    isLoading.value = true
    
    if (!establishment.value?.id) return
    
    // Charger les commandes récentes
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(10)
    
    if (ordersError) throw ordersError
    recentOrders.value = ordersData || []
    
    // Charger les produits populaires (simplifié)
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .limit(5)
    
    if (productsError) throw productsError
    popularProducts.value = productsData || []
    
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


onMounted(() => {
  loadData()
})

definePageMeta({
  layout: 'manager'
})
</script> 
