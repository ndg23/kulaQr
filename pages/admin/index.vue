<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Vue d'ensemble</h1>
        <p class="text-gray-600">Gérez tous vos restaurants depuis un seul endroit</p>
      </div>
  
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div v-for="stat in stats" :key="stat.name" 
          class="bg-white p-6 rounded-xl border border-gray-100 hover:border-gray-200 transition-all">
          <div class="flex items-center justify-between">
            <span class="text-gray-500 text-sm">{{ stat.name }}</span>
            <component :is="stat.icon" class="w-5 h-5 text-gray-400" />
          </div>
          <div class="mt-2 flex items-baseline">
            <span class="text-2xl font-semibold text-gray-900">{{ stat.value }}</span>
            <span class="ml-2 text-sm text-green-500 font-medium">+{{ stat.increase }}%</span>
          </div>
        </div>
      </div>
  
      <!-- Restaurants Table -->
      <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-900">Restaurants</h2>
            <NuxtLink 
              to="/admin/restaurants/new"
              class="inline-flex items-center px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
            >
              <Plus class="w-4 h-4 mr-2" />
              Ajouter un restaurant
            </NuxtLink>
          </div>
        </div>
  
        <!-- Table -->
        <div class="overflow-x-auto">
          <UTable 
            :rows="restaurants" 
            :columns="columns"
            :loading="loading"
            :sort="{ column: 'createdAt', direction: 'desc' }"
          >
            <!-- Status Column -->
            <template #status-data="{ row }">
              <span 
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-green-50 text-green-700': row.status === 'active',
                  'bg-yellow-50 text-yellow-700': row.status === 'pending',
                  'bg-red-50 text-red-700': row.status === 'inactive'
                }"
              >
                {{ row.status }}
              </span>
            </template>
  
            <!-- Actions Column -->
            <template #actions-data="{ row }">
              <div class="flex items-center space-x-3">
                <NuxtLink 
                  :to="`/admin/restaurants/${row.id}`"
                  class="text-gray-500 hover:text-gray-700"
                >
                  <Edit2 class="w-4 h-4" />
                </NuxtLink>
                <button 
                  @click="deleteRestaurant(row.id)"
                  class="text-gray-500 hover:text-red-500"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </template>
          </UTable>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { Users, Store, ShoppingBag, TrendingUp, Plus, Edit2, Trash2 } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const loading = ref(false)
  
  // Stats data
  const stats = [
    { name: 'Restaurants actifs', value: '234', increase: '12', icon: Store },
    { name: 'Nouveaux clients', value: '1.4k', increase: '8', icon: Users },
    { name: 'Commandes totales', value: '12.5k', increase: '24', icon: ShoppingBag },
    { name: 'Revenu mensuel', value: '€45k', increase: '18', icon: TrendingUp }
  ]
  
  // Table configuration
  const columns = [
    { key: 'name', label: 'Nom' },
    { key: 'owner', label: 'Propriétaire' },
    { key: 'status', label: 'Statut' },
    { key: 'createdAt', label: 'Date de création' },
    { key: 'actions', label: 'Actions' }
  ]
  
  // Sample data
  const restaurants = ref([
    {
      id: 1,
      name: 'Le Bistrot Parisien',
      owner: 'Jean Dupont',
      status: 'active',
      createdAt: '2024-02-20'
    },
    // ... autres restaurants
  ])
  
  // Delete restaurant
  const deleteRestaurant = async (id: number) => {
    try {
      // Appel API pour supprimer
      toast.success('Restaurant supprimé', 'Le restaurant a été supprimé avec succès')
    } catch (error) {
      toast.error('Erreur', "Une erreur s'est produite lors de la suppression")
    }
  }
  
  // Page meta
  definePageMeta({
    layout: 'admin',
  })
  </script>