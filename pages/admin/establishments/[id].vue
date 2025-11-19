<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center space-x-4">
          <NuxtLink 
            to="/admin/establishments"
            class="p-2 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-all"
          >
            <ArrowLeft class="w-5 h-5" />
          </NuxtLink>
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{{ restaurant.name }}</h1>
            <p class="text-sm text-gray-500 mt-1">{{ restaurant.address }}</p>
          </div>
        </div>
        <div class="flex items-center gap-3">
          <span 
            class="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium"
            :class="{
              'bg-green-100 text-green-700': restaurant.status === 'active',
              'bg-red-100 text-red-700': restaurant.status === 'inactive'
            }"
          >
            <div 
              class="w-2 h-2 rounded-full mr-2"
              :class="{
                'bg-green-500': restaurant.status === 'active',
                'bg-red-500': restaurant.status === 'inactive'
              }"
            />
            {{ restaurant.status === 'active' ? 'Actif' : 'Inactif' }}
          </span>
          <button
            @click="saveChanges"
            :disabled="loading"
            class="px-6 py-2 bg-black text-white rounded-full font-medium hover:bg-gray-800 transition-all shadow-sm hover:shadow-md disabled:opacity-50"
          >
            <Save class="w-4 h-4 inline mr-2" />
            Enregistrer
          </button>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div class="bg-white p-6 rounded-2xl border border-gray-100">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Produits</p>
              <h3 class="text-2xl font-bold text-gray-900 mt-1">{{ stats.totalProducts }}</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center">
              <UtensilsCrossed class="w-6 h-6 text-blue-500" />
            </div>
          </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-gray-100">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Catégories</p>
              <h3 class="text-2xl font-bold text-gray-900 mt-1">{{ stats.totalCategories }}</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-purple-50 flex items-center justify-center">
              <Layers class="w-6 h-6 text-purple-500" />
            </div>
          </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-gray-100">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Commandes</p>
              <h3 class="text-2xl font-bold text-gray-900 mt-1">{{ stats.totalOrders }}</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-green-50 flex items-center justify-center">
              <ShoppingBag class="w-6 h-6 text-green-500" />
            </div>
          </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-gray-100">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Revenu</p>
              <h3 class="text-2xl font-bold text-gray-900 mt-1">{{ formatPrice(stats.totalRevenue) }}</h3>
            </div>
            <div class="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center">
              <DollarSign class="w-6 h-6 text-orange-500" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden">
      <div class="border-b border-gray-100">
        <nav class="flex space-x-8 px-6" aria-label="Tabs">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            class="py-4 px-1 border-b-2 font-medium text-sm transition-colors"
            :class="[
              activeTab === tab.id
                ? 'border-black text-black'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            ]"
          >
            <component :is="tab.icon" class="w-5 h-5 inline mr-2" />
            {{ tab.name }}
          </button>
        </nav>
      </div>

      <!-- Tab Content -->
      <div class="p-6">
        <!-- Informations Tab -->
        <div v-if="activeTab === 'info'">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-4xl">
            <FloatLabelInput
              id="establishment-name"
              v-model="restaurant.name"
              label="Nom de l'établissement"
              type="text"
              required
            />
            
            <FloatLabelInput
              id="establishment-email"
              v-model="restaurant.email"
              label="Email"
              type="email"
            />
            
            <FloatLabelInput
              id="establishment-phone"
              v-model="restaurant.phone"
              label="Téléphone"
              type="tel"
            />
            
            <FloatLabelInput
              id="establishment-address"
              v-model="restaurant.address"
              label="Adresse"
              type="text"
            />

            <div class="md:col-span-2">
              <FloatLabelInput
                id="establishment-description"
                v-model="restaurant.description"
                label="Description"
                type="text"
              />
            </div>
          </div>

          <!-- Owner Info -->
          <div class="mt-8 p-6 bg-gray-50 rounded-2xl">
            <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <User class="w-5 h-5 mr-2" />
              Propriétaire
            </h3>
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center">
                <User class="w-6 h-6 text-gray-400" />
              </div>
              <div>
                <div class="font-medium text-gray-900">{{ restaurant.owner }}</div>
                <div class="text-sm text-gray-500">{{ restaurant.ownerEmail }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Menu/Products Tab -->
        <div v-if="activeTab === 'menu'">
          <DataTable
            :items="allProducts"
            :columns="productColumns"
            :loading="loadingProducts"
            :current-page="productsPage"
            :per-page="productsPerPage"
            :total-items="allProducts.length"
            :show-pagination="true"
            :show-add-button="true"
            add-button-label="Ajouter un produit"
            :header-buttons="[
              { label: 'Catégories', icon: 'fas fa-folder', variant: 'secondary', action: 'manage-categories' }
            ]"
            empty-title="Aucun produit"
            empty-description="Aucun produit n'a été ajouté à ce restaurant"
            empty-icon="fas fa-utensils"
            @page-change="productsPage = $event"
            @update:per-page="productsPerPage = $event"
            @add="openNewProductModal"
            @button-click="handleProductButtonClick"
          >
            <!-- Product Name with Image -->
            <template #cell-name="{ item }">
              <div class="flex items-center space-x-3 max-w-[300px]">
                <div class="w-12 h-12 rounded-xl bg-gray-100 flex items-center justify-center flex-shrink-0 overflow-hidden">
                  <img v-if="item.image_url" :src="item.image_url" :alt="item.name" class="w-full h-full object-cover" />
                  <UtensilsCrossed v-else class="w-6 h-6 text-gray-400" />
                </div>
                <div class="min-w-0 flex-1">
                  <div class="font-medium text-gray-900 truncate">{{ item.name }}</div>
                  <div class="text-sm text-gray-500 truncate">{{ item.category_name }}</div>
                </div>
              </div>
            </template>

            <!-- Price -->
            <template #cell-price="{ item }">
              <div class="font-semibold text-gray-900">{{ formatPrice(item.price) }}</div>
            </template>

            <!-- Availability -->
            <template #cell-is_available="{ item }">
              <span
                class="px-3 py-1 rounded-full text-xs font-medium inline-flex items-center whitespace-nowrap"
                :class="item.is_available ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'"
              >
                <div 
                  class="w-1.5 h-1.5 rounded-full mr-1.5"
                  :class="item.is_available ? 'bg-green-500' : 'bg-gray-500'"
                />
                {{ item.is_available ? 'Disponible' : 'Indisponible' }}
              </span>
            </template>

            <!-- Actions -->
            <template #cell-actions="{ item }">
              <div class="flex items-center gap-2">
                <button
                  @click="editProduct(item)"
                  class="p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                  title="Modifier"
                >
                  <Edit2 class="w-4 h-4" />
                </button>
                <button
                  @click="toggleProductAvailability(item)"
                  class="p-2 text-gray-600 hover:text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                  :title="item.is_available ? 'Marquer indisponible' : 'Marquer disponible'"
                >
                  <EyeOff v-if="item.is_available" class="w-4 h-4" />
                  <Eye v-else class="w-4 h-4" />
                </button>
                <button
                  @click="deleteProduct(item.id)"
                  class="p-2 text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  title="Supprimer"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </template>
          </DataTable>
        </div>

        <!-- Settings Tab -->
        <div v-if="activeTab === 'settings'" class="max-w-2xl">
          <div class="space-y-6">
            <!-- Status Toggle -->
            <div class="flex items-center justify-between p-6 bg-gray-50 rounded-2xl">
              <div>
                <h3 class="font-semibold text-gray-900">Statut de l'établissement</h3>
                <p class="text-sm text-gray-500 mt-1">Activer ou désactiver cet établissement</p>
              </div>
              <button
                @click="toggleStatus"
                :class="[
                  'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none',
                  restaurant.is_active ? 'bg-black' : 'bg-gray-200'
                ]"
              >
                <span
                  :class="[
                    'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                    restaurant.is_active ? 'translate-x-5' : 'translate-x-0'
                  ]"
                />
              </button>
            </div>

            <!-- Danger Zone -->
            <div class="border-2 border-red-200 rounded-2xl p-6">
              <h3 class="font-semibold text-red-900 mb-2">Zone de danger</h3>
              <p class="text-sm text-gray-600 mb-4">
                La suppression de cet établissement est irréversible. Toutes les données associées seront perdues.
              </p>
              <button
                @click="deleteRestaurant"
                class="px-6 py-2 bg-red-500 text-white rounded-full font-medium hover:bg-red-600 transition-all shadow-sm hover:shadow-md"
              >
                <Trash2 class="w-4 h-4 inline mr-2" />
                Supprimer l'établissement
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
  ArrowLeft, Store, User, UtensilsCrossed, Save,
  Plus, Edit2, Trash2, Settings as SettingsIcon,
  Info, Layers, ShoppingBag, DollarSign, Eye, EyeOff
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import FloatLabelInput from '~/components/FloatLabelInput.vue'
import DataTable from '~/components/DataTable/index.vue'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()
const loading = ref(false)
const loadingProducts = ref(false)
const activeTab = ref('info')

// Pagination for products
const productsPage = ref(1)
const productsPerPage = ref(10)

// Tabs configuration
const tabs = [
  { id: 'info', name: 'Informations', icon: Info },
  { id: 'menu', name: 'Menu & Produits', icon: UtensilsCrossed },
  { id: 'settings', name: 'Paramètres', icon: SettingsIcon }
]

// Restaurant data
const restaurant = ref({
  id: route.params.id,
  name: '',
  email: '',
  phone: '',
  address: '',
  description: '',
  status: 'inactive',
  owner: '',
  ownerEmail: '',
  is_active: false
})

// Stats
const stats = ref({
  totalProducts: 0,
  totalCategories: 0,
  totalOrders: 0,
  totalRevenue: 0
})

// Menu categories and products
const menuCategories = ref<any[]>([])
const allProducts = ref<any[]>([])

// Product columns for DataTable
const productColumns = [
  { key: 'name', label: 'Produit', sortable: true },
  { key: 'price', label: 'Prix', sortable: true },
  { key: 'is_available', label: 'Disponibilité', sortable: true },
  { key: 'actions', label: 'Actions', sortable: false }
]

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
      name: data.name || '',
      email: data.email || '',
      phone: data.phone || '',
      address: data.address || '',
      description: data.description || '',
      status: data.is_active ? 'active' : 'inactive',
      owner: data.users?.full_name || 'Propriétaire inconnu',
      ownerEmail: data.users?.email || '',
      is_active: data.is_active
    }

    // Load menu categories and products
    await loadMenuData()
    
    // Load stats
    await loadStats()
    
  } catch (err) {
    console.error('Error loading restaurant:', err)
    showToast.error('Impossible de charger les données du restaurant', 'error')
    // router.push('/admin/establishments')
  } finally {
    loading.value = false
  }
}

// Load menu categories and products
const loadMenuData = async () => {
  try {
    loadingProducts.value = true
    
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
          is_available,
          image_url
        )
      `)
      .eq('establishment_id', route.params.id)

    if (error) throw error

    menuCategories.value = data || []
    
    // Flatten products for DataTable
    allProducts.value = []
    data?.forEach(category => {
      category.products?.forEach((product: any) => {
        allProducts.value.push({
          ...product,
          category_name: category.name,
          category_id: category.id
        })
      })
    })
    
    stats.value.totalCategories = data?.length || 0
    stats.value.totalProducts = allProducts.value.length
    
  } catch (err) {
    console.error('Error loading menu data:', err)
  } finally {
    loadingProducts.value = false
  }
}

// Load stats
const loadStats = async () => {
  try {
    // Get total orders (you'll need to adjust based on your schema)
    const { count: ordersCount } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true })
      .eq('establishment_id', route.params.id)
    
    stats.value.totalOrders = ordersCount || 0
    
    // Get total revenue (adjust based on your schema)
    const { data: ordersData } = await supabase
      .from('orders')
      .select('total_price')
      .eq('establishment_id', route.params.id)
      .eq('status', 'completed')
    
    stats.value.totalRevenue = ordersData?.reduce((sum, order) => sum + (order.total_price || 0), 0) || 0
    
  } catch (err) {
    console.error('Error loading stats:', err)
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
        address: restaurant.value.address,
        description: restaurant.value.description
      })
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées avec succès', 'success')
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Impossible d\'enregistrer les modifications', 'error')
  } finally {
    loading.value = false
  }
}

// Delete restaurant
const deleteRestaurant = async () => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ? Cette action est irréversible.')) return
  
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Restaurant supprimé avec succès', 'success')
    router.push('/admin/establishments')
  } catch (err) {
    console.error('Error deleting restaurant:', err)
    showToast.error('Impossible de supprimer le restaurant', 'error')
  } finally {
    loading.value = false
  }
}

// Open product modal
const openNewProductModal = () => {
  showToast.info('Fonctionnalité à venir', 'info')
}

// Edit product
const editProduct = (product: any) => {
  showToast.info('Fonctionnalité à venir', 'info')
}

// Toggle product availability
const toggleProductAvailability = async (product: any) => {
  try {
    const { error } = await supabase
      .from('products')
      .update({ is_available: !product.is_available })
      .eq('id', product.id)

    if (error) throw error

    await loadMenuData()
    showToast.success(
      product.is_available ? 'Produit marqué comme indisponible' : 'Produit marqué comme disponible',
      'success'
    )
  } catch (err) {
    console.error('Error toggling product availability:', err)
    showToast.error('Impossible de modifier la disponibilité', 'error')
  }
}

// Delete product
const deleteProduct = async (productId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return

  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', productId)

    if (error) throw error

    await loadMenuData()
    showToast.success('Produit supprimé avec succès', 'success')
  } catch (err) {
    console.error('Error deleting product:', err)
    showToast.error('Impossible de supprimer le produit', 'error')
  }
}

// Handle product button clicks
const handleProductButtonClick = (action: string) => {
  switch (action) {
    case 'manage-categories':
      showToast.info('Fonctionnalité de gestion des catégories à venir', 'info')
      break
    default:
      console.log('Unknown action:', action)
  }
}

// Load data on mount
onMounted(loadRestaurant)

definePageMeta({
  layout: 'admin'
})
</script>