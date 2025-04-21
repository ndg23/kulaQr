<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <div class="flex items-center space-x-4 mb-3">
        <NuxtLink 
          to="/admin/restaurants"
          class="p-2 text-gray-500 hover:text-gray-700 rounded-2xl hover:bg-gray-100 transition-all"
        >
          <ArrowLeft class="w-6 h-6" />
        </NuxtLink>
        <div>
          <h1 class="text-4xl font-bold text-gray-900">{{ restaurant.name }}</h1>
          <p class="text-lg text-gray-600 mt-1">{{ restaurant.address }}</p>
        </div>
        <span 
          class="ml-auto inline-flex items-center px-4 py-2 rounded-2xl text-sm font-medium"
          :class="{
            'bg-green-50 text-green-700': restaurant.status === 'active',
            'bg-red-50 text-red-700': restaurant.status === 'inactive'
          }"
        >
          {{ restaurant.status }}
        </span>
      </div>
    </div>

    <!-- Main Content -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Left Column -->
      <div class="lg:col-span-2 space-y-8">
        <!-- Restaurant Info Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
                <Store class="w-6 h-6 text-blue-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Informations</h2>
            </div>
          </div>
          <div class="p-8">
            <div class="grid grid-cols-2 gap-6">
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom du restaurant</label>
                  <input 
                    v-model="restaurant.name"
                    type="text"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                  <input 
                    v-model="restaurant.email"
                    type="email"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
              </div>
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                  <input 
                    v-model="restaurant.phone"
                    type="tel"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Adresse</label>
                  <input 
                    v-model="restaurant.address"
                    type="text"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Menu Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <div class="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center">
                  <UtensilsCrossed class="w-6 h-6 text-orange-500" />
                </div>
                <h2 class="text-2xl font-semibold text-gray-900">Menu</h2>
              </div>
              <button 
                @click="openNewProductModal"
                class="inline-flex items-center px-6 py-3 bg-black text-white rounded-2xl text-base font-medium transition-colors hover:bg-gray-900"
              >
                <Plus class="w-5 h-5 mr-2" />
                Ajouter
              </button>
            </div>
          </div>
          <div class="p-8">
            <div class="space-y-8">
              <div v-for="category in menuCategories" :key="category.id">
                <div class="flex items-center justify-between mb-4">
                  <h3 class="text-xl font-semibold text-gray-900">{{ category.name }}</h3>
                  <button class="text-blue-500 hover:text-blue-600 font-medium">
                    Gérer
                  </button>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div v-for="product in category.products" :key="product.id"
                    class="p-4 border border-gray-100 rounded-2xl hover:border-gray-200 transition-all group"
                  >
                    <div class="flex justify-between items-start">
                      <div>
                        <h4 class="font-medium text-gray-900">{{ product.name }}</h4>
                        <p class="text-sm text-gray-500 mt-1">{{ product.description }}</p>
                        <p class="text-lg font-semibold text-gray-900 mt-2">{{ product.price }}€</p>
                      </div>
                      <div class="opacity-0 group-hover:opacity-100 transition-opacity">
                        <button class="p-2 text-gray-500 hover:text-gray-700 rounded-xl hover:bg-gray-100">
                          <Edit2 class="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="space-y-8">
        <!-- Owner Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
                <User class="w-6 h-6 text-purple-500" />
              </div>
              <div>
                <h2 class="text-2xl font-semibold text-gray-900">Propriétaire</h2>
                <p class="text-sm text-gray-500 mt-1">Gestionnaire principal</p>
              </div>
            </div>
          </div>
          <div class="p-8">
            <div class="flex items-center space-x-4">
              <div class="w-16 h-16 rounded-2xl bg-gray-100 flex items-center justify-center">
                <User class="w-8 h-8 text-gray-400" />
              </div>
              <div>
                <div class="font-medium text-gray-900">{{ restaurant.owner }}</div>
                <div class="text-gray-500">{{ restaurant.ownerEmail }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Stats Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
                <ChartBar class="w-6 h-6 text-green-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Statistiques</h2>
            </div>
          </div>
          <div class="p-8 space-y-6">
            <div>
              <div class="text-3xl font-bold text-gray-900">€12,450</div>
              <div class="text-base text-gray-500">Revenu mensuel</div>
            </div>
            <div>
              <div class="text-3xl font-bold text-gray-900">1,234</div>
              <div class="text-base text-gray-500">Commandes</div>
            </div>
            <div>
              <div class="text-3xl font-bold text-gray-900">4.8/5</div>
              <div class="text-base text-gray-500">Note moyenne</div>
            </div>
          </div>
        </div>

        <!-- Actions Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8">
            <div class="space-y-4">
              <button 
                @click="saveChanges"
                class="w-full px-6 py-3 bg-black text-white rounded-2xl font-medium hover:bg-gray-900 transition-colors"
              >
                Enregistrer
              </button>
              <button 
                @click="toggleStatus"
                class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-medium hover:bg-gray-200 transition-colors"
              >
                {{ restaurant.status === 'active' ? 'Désactiver' : 'Activer' }}
              </button>
              <button 
                @click="deleteRestaurant"
                class="w-full px-6 py-3 bg-red-50 text-red-600 rounded-2xl font-medium hover:bg-red-100 transition-colors"
              >
                Supprimer
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  ArrowLeft, Store, User, UtensilsCrossed,
  Plus, Edit2, ChartBar
} from 'lucide-vue-next'
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

const openNewProductModal = () => {
  // Implémenter la logique d'ajout de produit
}

const menuCategories = ref([
  {
    id: 1,
    name: 'Entrées',
    products: [
      {
        id: 1,
        name: 'Salade César',
        description: 'Laitue romaine, croûtons, parmesan',
        price: 12.90
      },
      {
        id: 2,
        name: 'Soupe à l\'oignon',
        description: 'Oignons caramélisés, croûtons gratinés',
        price: 9.90
      }
    ]
  },
  {
    id: 2,
    name: 'Plats',
    products: [
      {
        id: 3,
        name: 'Steak Frites',
        description: 'Steak de bœuf, frites maison',
        price: 24.90
      }
    ]
  }
])
</script>