<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">Restaurants</h1>
      <p class="text-lg text-gray-600">Gérez vos établissements</p>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
      <div v-for="stat in stats" :key="stat.name" 
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
import { ref, computed } from 'vue'
import { 
  Store, Search, Edit2, Trash2,
  Plus, TrendingUp, ShoppingBag, Users
} from 'lucide-vue-next'
import { useToast } from '~/composables/useToast'

const toast = useToast()
const loading = ref(false)

// Stats data
const stats = [
  { 
    name: 'Restaurants actifs', 
    value: '234',
    icon: Store,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  { 
    name: 'Commandes totales', 
    value: '12.5k',
    icon: ShoppingBag,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500'
  },
  { 
    name: 'Revenu mensuel', 
    value: '€45k',
    icon: TrendingUp,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  }
]

// Filters
const filters = ref({
  search: '',
  status: ''
})

// Sample data
const restaurants = ref([
  {
    id: 1,
    name: 'Le Bistrot Parisien',
    address: '123 Rue de Paris, 75001 Paris',
    owner: 'Jean Dupont',
    status: 'active'
  },
  {
    id: 2,
    name: 'La Trattoria',
    address: '45 Avenue des Champs-Élysées, 75008 Paris',
    owner: 'Marie Martin',
    status: 'inactive'
  }
])

// Computed
const filteredRestaurants = computed(() => {
  return restaurants.value.filter(restaurant => {
    const matchesSearch = !filters.value.search || 
      restaurant.name.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      restaurant.address.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesStatus = !filters.value.status || restaurant.status === filters.value.status

    return matchesSearch && matchesStatus
  })
})

// Methods
const deleteRestaurant = async (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ?')) {
    try {
      loading.value = true
      // Logique de suppression
      toast.success('Restaurant supprimé', 'Le restaurant a été supprimé avec succès')
    } catch (error) {
      toast.error('Erreur', "Une erreur s'est produite lors de la suppression")
    } finally {
      loading.value = false
    }
  }
}

definePageMeta({
  layout: 'admin'
})
</script> 