<template>
  <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Menu</h1>
        <p class="mt-1 text-sm text-gray-500">Gérez les produits de votre établissement</p>
      </div>
      <button
        @click="openAddProduct"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Nouveau produit
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <Loader2 class="w-10 h-10 text-gray-300 animate-spin mb-4" />
      <p class="text-sm text-gray-500">Chargement de votre menu...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="products.length === 0" class="bg-white rounded-2xl border border-gray-100 p-12 text-center">
      <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-50 flex items-center justify-center">
        <UtensilsCrossed class="w-10 h-10 text-gray-300" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-1">
        Votre menu est vide
      </h3>
      <p class="text-sm text-gray-500 mb-6 max-w-md mx-auto">
        Commencez par ajouter des produits à votre menu pour que vos clients puissent les découvrir.
      </p>
      <button
        @click="openAddProduct"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Ajouter votre premier produit
      </button>
    </div>

    <!-- Content (only shown if there are products) -->
    <div v-else>
      <!-- Quick Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div v-for="stat in quickStats" :key="stat.name"
          class="bg-white p-4 rounded-xl border border-gray-100"
        >
          <div class="flex items-center">
            <div class="w-10 h-10 rounded-lg flex items-center justify-center"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" class="w-5 h-5" :class="stat.iconColor" />
            </div>
            <div class="ml-3">
              <p class="text-sm text-gray-500">{{ stat.name }}</p>
              <p class="text-lg font-semibold text-gray-900">{{ stat.value }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Category Pills -->
      <div class="flex gap-2 overflow-x-auto pb-2 mb-6 scrollbar-hide">
        <button
          v-for="category in categories"
          :key="category.id"
          @click="activeCategory = category.id"
          class="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200"
          :class="[
            activeCategory === category.id
              ? 'bg-blue-500 text-white shadow-sm'
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
          ]"
        >
          {{ category.name }}
        </button>
      </div>

      <!-- Products Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <div v-for="product in filteredProducts" :key="product.id"
          class="bg-white rounded-xl border border-gray-100 overflow-hidden group hover:shadow-sm transition-all"
        >
          <!-- Product Image -->
          <div class="aspect-square w-full bg-gray-50 relative">
            <img
              v-if="product.image_url"
              :src="product.image_url"
              :alt="product.name"
              class="w-full h-full object-cover"
            />
            <div v-else class="w-full h-full flex items-center justify-center">
              <UtensilsCrossed class="w-6 h-6 text-gray-300" />
            </div>
            
            <!-- Quick Actions Overlay -->
            <div class="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
              <div class="flex items-center space-x-1">
                <button 
                  @click="editProduct(product)"
                  class="p-1.5 text-white hover:text-gray-200 rounded-lg hover:bg-white/10"
                >
                  <Edit2 class="w-4 h-4" />
                </button>
                <Switch
                  v-model="product.is_available"
                  @change="toggleAvailability(product)"
                  class="relative inline-flex h-5 w-10 items-center rounded-full"
                  :class="product.is_available ? 'bg-green-500' : 'bg-gray-400'"
                >
                  <span
                    class="inline-block h-4 w-4 transform rounded-full bg-white transition"
                    :class="product.is_available ? 'translate-x-5' : 'translate-x-1'"
                  />
                </Switch>
              </div>
            </div>
          </div>
          
          <!-- Product Info -->
          <div class="p-3">
            <div class="flex items-start justify-between">
              <div>
                <h3 class="font-medium text-gray-900">{{ product.name }}</h3>
                <p class="text-sm text-gray-500 mt-0.5 line-clamp-2">{{ product.description }}</p>
              </div>
              <span class="text-sm font-semibold text-gray-900">{{ formatPrice(product.price) }}</span>
            </div>
            
            <div class="mt-2 flex items-center justify-between">
              <span 
                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-green-50 text-green-700': product.is_available,
                  'bg-gray-50 text-gray-600': !product.is_available
                }"
              >
                {{ product.is_available ? 'Disponible' : 'Indisponible' }}
              </span>
              <button
                @click="deleteProduct(product.id)"
                class="p-1 text-gray-400 hover:text-red-500 rounded-lg hover:bg-red-50"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Product Modal -->
    <TransitionRoot appear :show="showAddProduct" as="template">
      <Dialog as="div" class="relative z-50" @close="closeModal">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-lg transform overflow-hidden rounded-2xl bg-white shadow-xl transition-all">
                <ProductModal
                  :product="editingProduct"
                  :categories="categories"
                  @close="closeModal"
                  @submit="saveProduct"
                />
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Switch, TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  Plus, UtensilsCrossed, Edit2, Trash2,
  Coffee, Pizza, Store, TrendingUp, IceCream, Loader2,
  Search, MoreVertical, ChevronDown
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { useEstablishment } from '~/composables/useEstablishment'
import ProductModal from '~/components/modals/ProductModal.vue'
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/vue'

const route = useRoute()
const slug = route.params.slug
const { client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()
const { establishment } = useEstablishment()

// State
const showAddProduct = ref(false)
const editingProduct = ref(null)
const activeCategory = ref('all')
const categories = ref([])
const products = ref([])
const loading = ref(true)
const search = ref('')

// Mock Data
const mockCategories = [
  {
    id: 1,
    name: 'Entrées',
    icon: Coffee,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500'
  },
  {
    id: 2,
    name: 'Plats',
    icon: UtensilsCrossed,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  {
    id: 3,
    name: 'Desserts',
    icon: IceCream,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500'
  },
  {
    id: 4,
    name: 'Boissons',
    icon: Coffee,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  }
]

const mockProducts = [
  {
    id: 1,
    name: 'Salade César',
    description: 'Laitue romaine, croûtons maison, parmesan, sauce césar',
    price: 12.90,
    category_id: 1,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9'
  },
  {
    id: 2,
    name: 'Soupe à l\'oignon',
    description: 'Oignons caramélisés, bouillon maison, croûtons gratinés',
    price: 9.90,
    category_id: 1,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1547592166-23ac45744acd'
  },
  {
    id: 3,
    name: 'Steak Frites',
    description: 'Steak de bœuf, frites maison, sauce au poivre',
    price: 24.90,
    category_id: 2,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1600891964092-4316c288032e'
  },
  {
    id: 4,
    name: 'Saumon grillé',
    description: 'Saumon frais, légumes de saison, sauce hollandaise',
    price: 26.90,
    category_id: 2,
    is_available: false,
    image_url: 'https://images.unsplash.com/photo-1485921325833-c519f76c4927'
  },
  {
    id: 5,
    name: 'Crème brûlée',
    description: 'Crème vanille, caramel croustillant',
    price: 8.90,
    category_id: 3,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1470324161839-ce2bb6fa6bc3'
  },
  {
    id: 6,
    name: 'Tarte au citron meringuée',
    description: 'Crème citron, meringue italienne',
    price: 9.90,
    category_id: 3,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81'
  },
  {
    id: 7,
    name: 'Vin rouge - Bordeaux',
    description: 'Château Margaux 2018',
    price: 45.00,
    category_id: 4,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3'
  },
  {
    id: 8,
    name: 'Mojito',
    description: 'Rhum, menthe fraîche, citron vert, sucre de canne',
    price: 12.00,
    category_id: 4,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a'
  }
]

// Computed
const filteredProducts = computed(() => {
  let filtered = products.value

  // Filter by category
  if (activeCategory.value !== 'all') {
    filtered = filtered.filter(product => product.category_id === activeCategory.value)
  }

  // Filter by search
  if (search.value) {
    const searchLower = search.value.toLowerCase()
    filtered = filtered.filter(product => 
      product.name.toLowerCase().includes(searchLower) ||
      product.description?.toLowerCase().includes(searchLower)
    )
  }

  return filtered
})

// Quick stats
const quickStats = computed(() => {
  return [
    {
      name: 'Total produits',
      value: products.value.length,
      icon: UtensilsCrossed,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    },
    {
      name: 'Catégories',
      value: categories.value.length,
      icon: ChevronDown,
      iconBg: 'bg-purple-50',
      iconColor: 'text-purple-500'
    },
    {
      name: 'Produits actifs',
      value: products.value.filter(p => p.is_available).length,
      icon: Plus,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    {
      name: 'Prix moyen',
      value: formatPrice(
        products.value.length
          ? products.value.reduce((sum, p) => sum + p.price, 0) / products.value.length
          : 0
      ),
      icon: MoreVertical,
      iconBg: 'bg-amber-50',
      iconColor: 'text-amber-500'
    }
  ]
})

// Methods
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price)
}

const handleSearch = () => {
  // Reset category filter when searching
  if (search.value) {
    activeCategory.value = 'all'
  }
}

const getCategoryName = (categoryId) => {
  const category = categories.value.find(c => c.id === categoryId)
  return category ? category.name : 'Sans catégorie'
}

const loadData = async () => {
  loading.value = true
  try {
    // Load categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('name')

    if (categoriesError) throw categoriesError
    categories.value = categoriesData || []
    
    // Load products directly by establishment_id
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*, category:categories(name)')
      .eq('establishment_id', establishment.value?.id)
      .order('name')

    if (productsError) throw productsError
    products.value = productsData || []
  } catch (err) {
    console.error('Erreur chargement:', err)
    showToast.error('Erreur', 'Impossible de charger les données')
  } finally {
    loading.value = false
  }
}

const toggleAvailability = async (product: any) => {
  try {
    const { error } = await supabase
      .from('products')
      .update({ is_available: product.is_available })
      .eq('id', product.id)

    if (error) throw error
    showToast.success('Disponibilité mise à jour', 'Le statut du produit a été modifié')
  } catch (err) {
    console.error('Erreur mise à jour:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour la disponibilité')
    // Revenir à l'état précédent
    product.is_available = !product.is_available
  }
}

const editProduct = (product: any) => {
  editingProduct.value = { ...product }
  showAddProduct.value = true
}

const closeModal = () => {
  showAddProduct.value = false
  editingProduct.value = null
}

const saveProduct = async (productData) => {
  try {
    // Make sure the product has a valid category_id that belongs to this establishment
    if (!productData.category_id) {
      showToast.error('Erreur', 'Veuillez sélectionner une catégorie')
      return
    }
    
    // Verify the category belongs to this establishment
    const categoryExists = categories.value.some(c => c.id === productData.category_id)
    if (!categoryExists) {
      showToast.error('Erreur', 'Catégorie invalide')
      return
    }
    
    // Add establishment_id to the product data
    productData.establishment_id = establishment.value?.id
    
    if (editingProduct.value?.id) {
      // Update existing product
      const { error } = await supabase
        .from('products')
        .update(productData)
        .eq('id', editingProduct.value.id)

      if (error) throw error
    } else {
      // Create new product
      const { error } = await supabase
        .from('products')
        .insert({
          ...productData,
          is_available: true
        })

      if (error) throw error
    }

    // Reload data
    await loadData()
    closeModal()
    showToast.success(
      'Produit sauvegardé',
      editingProduct.value?.id ? 'Modifications enregistrées' : 'Nouveau produit ajouté'
    )
  } catch (err) {
    console.error('Erreur sauvegarde:', err)
    showToast.error('Erreur', 'Impossible de sauvegarder le produit')
  }
}

const deleteProduct = async (id: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return

  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', id)

    if (error) throw error
    await loadData()
      showToast.success('Produit supprimé', 'Le produit a été supprimé')
  } catch (err) {
    console.error('Erreur suppression:', err)
    showToast.error('Erreur', 'Impossible de supprimer le produit')
  }
}

const openAddProduct = () => {
  editingProduct.value = null
  showAddProduct.value = true
}

// Initial load
onMounted(loadData)

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style> 