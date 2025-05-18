<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <div class="flex items-center space-x-4 mb-3">
        <NuxtLink 
          to="/admin/establishments"
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
                        <p class="text-lg font-semibold text-gray-900 mt-2">{{ product.price }}</p>
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
              <div class="text-3xl font-bold text-gray-900">12,450</div>
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
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()
const loading = ref(false)

// Restaurant data
const restaurant = ref({
  id: route.params.id,
  name: '',
  email: '',
  phone: '',
  address: '',
  status: 'inactive',
  owner: '',
  ownerEmail: '',
  is_active: false
})

// Menu categories and products
const menuCategories = ref([])

// Load restaurant data
const loadRestaurant = async () => {
  try {
    loading.value = true
    
    // Get establishment data
    const { data, error } = await supabase
      .from('establishments')
      .select(`
        *
      `)
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    
    // Format the data
    restaurant.value = {
      id: data.id,
      name: data.name,
      email: data.email || '',
      phone: data.phone || '',
      address: data.address || '',
      status: data.is_active ? 'active' : 'inactive',
      owner: data.users?.full_name || 'Propriétaire inconnu',
      ownerEmail: data.users?.email || '',
      is_active: data.is_active
    }

    // Load menu categories and products
    await loadMenuData()
    
  } catch (err) {
    console.error('Error loading restaurant:', err)
    showToast.error('Erreur', 'Impossible de charger les données du restaurant')
    router.push('/admin/establishments')
  } finally {
    loading.value = false
  }
}

// Load menu categories and products
const loadMenuData = async () => {
  try {
    // Get categories with their products
    const { data, error } = await supabase
      .from('categories')
      .select(`
        id,
        name,
        products (
          id,
          name,
          description,
          price,
          is_available
        )
      `)
      .eq('establishment_id', route.params.id)
      .order('order_number')

    if (error) throw error

    menuCategories.value = data.map(category => ({
      ...category,
      products: category.products.map(product => ({
        ...product,
        price: formatPrice(product.price)
      }))
    }))
    
  } catch (err) {
    console.error('Error loading menu data:', err)
    // Non-critical error, we can continue
  }
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF' 
  }).format(price)
}

// Toggle restaurant status
const toggleStatus = async () => {
  try {
    loading.value = true
    
    const newStatus = !restaurant.value.is_active
    
    const { error } = await supabase
      .from('establishments')
      .update({ is_active: newStatus })
      .eq('id', restaurant.value.id)

    if (error) throw error

    restaurant.value.is_active = newStatus
    restaurant.value.status = newStatus ? 'active' : 'inactive'
    
    showToast.success('Statut modifié', 'Le statut du restaurant a été mis à jour')
  } catch (err) {
    console.error('Error toggling status:', err)
    showToast.error('Erreur', 'Impossible de modifier le statut')
  } finally {
    loading.value = false
  }
}

// Save restaurant changes
const saveChanges = async () => {
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .update({
        name: restaurant.value.name,
        email: restaurant.value.email,
        phone: restaurant.value.phone,
        address: restaurant.value.address
      })
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées', 'Les modifications ont été enregistrées avec succès')
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Erreur', 'Impossible d\'enregistrer les modifications')
  } finally {
    loading.value = false
  }
}

// Delete restaurant
const deleteRestaurant = async () => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ?')) return
  
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Restaurant supprimé', 'Le restaurant a été supprimé avec succès')
    router.push('/admin/establishments')
  } catch (err) {
    console.error('Error deleting restaurant:', err)
    showToast.error('Erreur', 'Impossible de supprimer le restaurant')
  } finally {
    loading.value = false
  }
}

// Open product modal
const openNewProductModal = () => {
  // Implement this when you have a product modal component
  showToast.info('Fonctionnalité à venir', 'Cette fonctionnalité sera disponible prochainement')
}

// Load data on mount
onMounted(loadRestaurant)

definePageMeta({
  layout: 'admin'
})
</script>