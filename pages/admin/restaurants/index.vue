<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">Restaurants</h1>
      <p class="text-lg text-gray-600">Gérez vos établissements</p>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
      <div v-for="stat in statsDisplay" :key="stat.name" 
        class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all hover:scale-[1.02] hover:shadow-lg"
      >
        <div class="flex items-center space-x-6">
          <div class="w-16 h-16 rounded-2xl flex items-center justify-center"
            :class="stat.iconBg"
          >
            <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
          </div>
          <div>
            <p class="text-base text-gray-500 mb-1">{{ stat.name }}</p>
            <h3 class="text-3xl font-bold text-gray-900">{{ stat.value }}</h3>
          </div>
        </div>
      </div>
    </div>

    <!-- Restaurants List -->
    <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
      <!-- Header -->
      <div class="p-8 border-b border-gray-100">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
              <Store class="w-6 h-6 text-blue-500" />
            </div>
            <h2 class="text-2xl font-semibold text-gray-900">Liste des restaurants</h2>
          </div>
          <NuxtLink 
            to="/admin/restaurants/new"
            class="inline-flex items-center px-6 py-3 bg-black text-white rounded-2xl text-base font-medium transition-colors hover:bg-gray-900"
          >
            <Plus class="w-5 h-5 mr-2" />
            Ajouter
          </NuxtLink>
        </div>
      </div>

      <!-- Search -->
      <div class="p-6 border-b border-gray-100 bg-gray-50">
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[300px]">
            <div class="relative">
              <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                v-model="filters.search"
                type="text"
                placeholder="Rechercher un restaurant..."
                class="w-full h-12 pl-12 pr-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
              />
            </div>
          </div>
          <select
            v-model="filters.status"
            class="h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
          >
            <option value="">Tous les statuts</option>
            <option value="active">Actif</option>
            <option value="inactive">Inactif</option>
          </select>
        </div>
      </div>

      <!-- Restaurants Grid -->
      <div class="p-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div v-for="restaurant in filteredRestaurants" :key="restaurant.id"
            class="p-6 border border-gray-100 rounded-2xl hover:border-gray-200 transition-all group"
          >
            <div class="flex items-start justify-between">
              <div class="flex items-start space-x-4">
                <div class="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center">
                  <Store class="w-6 h-6 text-gray-400" />
                </div>
                <div>
                  <h3 class="text-lg font-semibold text-gray-900">{{ restaurant.name }}</h3>
                  <p class="text-sm text-gray-500 mt-1">{{ restaurant.address }}</p>
                  <div class="flex items-center mt-2">
                    <span 
                      class="inline-flex items-center px-2.5 py-1 rounded-xl text-xs font-medium"
                      :class="{
                        'bg-green-50 text-green-700': restaurant.status === 'active',
                        'bg-gray-50 text-gray-700': restaurant.status === 'inactive'
                      }"
                    >
                      {{ restaurant.status }}
                    </span>
                    <span class="text-sm text-gray-500 ml-3">{{ restaurant.owner }}</span>
                  </div>
                </div>
              </div>
              <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                <NuxtLink 
                  :to="`/admin/restaurants/${restaurant.id}`"
                  class="p-2 text-gray-500 hover:text-gray-700 rounded-xl hover:bg-gray-100"
                >
                  <Edit2 class="w-5 h-5" />
                </NuxtLink>
                <button 
                  @click="deleteRestaurant(restaurant.id)"
                  class="p-2 text-gray-500 hover:text-red-500 rounded-xl hover:bg-red-50"
                >
                  <Trash2 class="w-5 h-5" />
                </button>
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
  Store, Search, Edit2, Trash2,
  Plus, TrendingUp, ShoppingBag, Users
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const loading = ref(false)

// State
const restaurants = ref([])
const stats = ref({
  active: 0,
  orders: 0,
  revenue: 0
})

// Filters
const filters = ref({
  search: '',
  status: ''
})

// Load restaurants data
const loadRestaurants = async () => {
  try {
    loading.value = true
    
    // Get establishments with their owners
    const { data, error } = await supabase
      .from('establishments')
      .select(`
        *,
        users:user_id (
          full_name
        )
      `)
      .order('created_at', { ascending: false })

    if (error) throw error

    // Format the data
    restaurants.value = data.map(est => ({
      id: est.id,
      name: est.name,
      address: est.address || 'Adresse non spécifiée',
      owner: est.users?.full_name || 'Propriétaire inconnu',
      status: est.is_active ? 'active' : 'inactive',
      created_at: est.created_at
    }))

    // Calculate stats
    stats.value = {
      active: data.filter(est => est.is_active).length,
      orders: 0, // We'll implement this later
      revenue: 0  // We'll implement this later
    }

    // Get order stats (optional - implement if you have orders table)
    try {
      const { data: orderStats, error: orderError } = await supabase
        .rpc('get_order_stats')
      
      if (!orderError && orderStats) {
        stats.value.orders = orderStats.total_orders || 0
        stats.value.revenue = orderStats.total_revenue || 0
      }
    } catch (err) {
      console.error('Error loading order stats:', err)
      // Non-critical error, we can continue
    }

  } catch (err) {
    console.error('Error loading restaurants:', err)
    showToast.error('Erreur', 'Impossible de charger les restaurants')
  } finally {
    loading.value = false
  }
}

// Computed stats for display
const statsDisplay = computed(() => [
  { 
    name: 'Restaurants actifs', 
    value: stats.value.active.toString(),
    icon: Store,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  { 
    name: 'Commandes totales', 
    value: stats.value.orders > 1000 
      ? `${(stats.value.orders / 1000).toFixed(1)}k` 
      : stats.value.orders.toString(),
    icon: ShoppingBag,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500'
  },
  { 
    name: 'Revenu mensuel', 
    value: stats.value.revenue > 1000 
      ? `${(stats.value.revenue / 1000).toFixed(0)}k` 
      : stats.value.revenue.toString(),
    icon: TrendingUp,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  }
])

// Filtered restaurants
const filteredRestaurants = computed(() => {
  return restaurants.value.filter(restaurant => {
    const matchesSearch = !filters.value.search || 
      restaurant.name.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      restaurant.address.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesStatus = !filters.value.status || restaurant.status === filters.value.status

    return matchesSearch && matchesStatus
  })
})

// Delete restaurant
const deleteRestaurant = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ?')) return

  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('Restaurant supprimé', 'Le restaurant a été supprimé avec succès')
    await loadRestaurants() // Reload the list
    
  } catch (error) {
    console.error('Error deleting restaurant:', error)
    showToast.error('Erreur', "Une erreur s'est produite lors de la suppression")
  } finally {
    loading.value = false
  }
}

// Load initial data
onMounted(loadRestaurants)

definePageMeta({
  layout: 'admin'
})
</script> 