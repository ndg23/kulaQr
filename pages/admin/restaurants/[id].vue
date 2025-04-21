<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <div class="flex items-center space-x-3">
            <NuxtLink 
              to="/admin"
              class="text-gray-500 hover:text-gray-700"
            >
              <ArrowLeft class="w-5 h-5" />
            </NuxtLink>
            <h1 class="text-2xl font-bold text-gray-900">{{ restaurant.name }}</h1>
            <span 
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
              :class="{
                'bg-green-50 text-green-700': restaurant.status === 'active',
                'bg-yellow-50 text-yellow-700': restaurant.status === 'pending',
                'bg-red-50 text-red-700': restaurant.status === 'inactive'
              }"
            >
              {{ restaurant.status }}
            </span>
          </div>
          <p class="text-gray-600 mt-1">Gérez les détails et les paramètres du restaurant</p>
        </div>
  
        <div class="flex items-center space-x-4">
          <button 
            @click="toggleStatus"
            class="px-4 py-2 bg-white border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors"
          >
            {{ restaurant.status === 'active' ? 'Désactiver' : 'Activer' }}
          </button>
          <button 
            @click="deleteRestaurant"
            class="px-4 py-2 bg-red-50 text-red-600 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors"
          >
            Supprimer
          </button>
        </div>
      </div>
  
      <!-- Content Grid -->
      <div class="grid grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="col-span-2 space-y-6">
          <!-- Restaurant Details -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Informations</h2>
            </div>
            <div class="p-6">
              <div class="grid grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Nom du restaurant
                  </label>
                  <input 
                    v-model="restaurant.name"
                    type="text"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Adresse email
                  </label>
                  <input 
                    v-model="restaurant.email"
                    type="email"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Téléphone
                  </label>
                  <input 
                    v-model="restaurant.phone"
                    type="tel"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Adresse
                  </label>
                  <input 
                    v-model="restaurant.address"
                    type="text"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
              </div>
  
              <div class="mt-6 flex justify-end">
                <button 
                  @click="saveChanges"
                  class="px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
                >
                  Enregistrer les modifications
                </button>
              </div>
            </div>
          </div>
  
          <!-- Statistics -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Statistiques</h2>
            </div>
            <div class="p-6">
              <div class="grid grid-cols-3 gap-6">
                <div>
                  <div class="text-2xl font-semibold text-gray-900">€12,450</div>
                  <div class="text-sm text-gray-500">Revenu mensuel</div>
                </div>
                <div>
                  <div class="text-2xl font-semibold text-gray-900">1,234</div>
                  <div class="text-sm text-gray-500">Commandes</div>
                </div>
                <div>
                  <div class="text-2xl font-semibold text-gray-900">4.8/5</div>
                  <div class="text-sm text-gray-500">Note moyenne</div>
                </div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Sidebar -->
        <div class="space-y-6">
          <!-- Owner Info -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Propriétaire</h2>
            </div>
            <div class="p-6">
              <div class="flex items-center space-x-4">
                <div class="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center">
                  <User class="w-6 h-6 text-gray-400" />
                </div>
                <div>
                  <div class="font-medium text-gray-900">{{ restaurant.owner }}</div>
                  <div class="text-sm text-gray-500">{{ restaurant.ownerEmail }}</div>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Quick Actions -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Actions rapides</h2>
            </div>
            <div class="p-6">
              <div class="space-y-3">
                <button class="w-full px-4 py-2 bg-gray-50 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-100 transition-colors text-left">
                  Voir le menu
                </button>
                <button class="w-full px-4 py-2 bg-gray-50 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-100 transition-colors text-left">
                  Gérer les QR codes
                </button>
                <button class="w-full px-4 py-2 bg-gray-50 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-100 transition-colors text-left">
                  Voir les commandes
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ArrowLeft, User } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const route = useRoute()
  
  // Sample data
  const restaurant = ref({
    id: route.params.id,
    name: 'Le Bistrot Parisien',
    email: 'contact@bistrotparisien.fr',
    phone: '+33 1 23 45 67 89',
    address: '123 Rue de Paris, 75001 Paris',
    status: 'active',
    owner: 'Jean Dupont',
    ownerEmail: 'jean@bistrotparisien.fr'
  })
  
  const toggleStatus = () => {
    restaurant.value.status = restaurant.value.status === 'active' ? 'inactive' : 'active'
    toast.success('Statut modifié', 'Le statut du restaurant a été mis à jour')
  }
  
  const saveChanges = () => {
    toast.success('Modifications enregistrées', 'Les modifications ont été enregistrées avec succès')
  }
  
  const deleteRestaurant = () => {
    // Ajouter une confirmation avant suppression
    if (confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ?')) {
      toast.success('Restaurant supprimé', 'Le restaurant a été supprimé avec succès')
      navigateTo('/admin')
    }
  }
  

  </script>