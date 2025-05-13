<template>
  <div class="min-h-screen bg-white">
    <!-- Header with glass effect -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/90 border-b border-gray-200/20 shadow-sm">
      <div class="max-w-[1400px] mx-auto px-6 sm:px-8 py-6">
        <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
          <div class="max-w-2xl">
            <div class="flex items-center gap-3 mb-2">
              <h1 class="text-3xl font-bold text-gray-900">Menu</h1>
              <div class="flex items-center gap-2 px-3 py-1 bg-gray-900/5 rounded-full">
                <span class="text-sm font-medium text-gray-600">{{ categories.length }} catégories</span>
                <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                <span class="text-sm font-medium text-gray-600">{{ products.length }} produits</span>
              </div>
            </div>
            <p class="text-base text-gray-500">Gérez votre menu et vos produits. Les modifications sont instantanément visibles pour vos clients.</p>
          </div>
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <div class="relative flex-1 sm:flex-none">
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher un produit..."
                class="w-full sm:w-64 pl-10 pr-4 h-11 rounded-full bg-white shadow-sm border border-gray-200/30 focus:ring-2 focus:ring-blue-500/20 focus:border-transparent transition-all"
              />
              <Search class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
            </div>
            <button 
              @click="openNewCategoryModal"
              class="h-11 px-6 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm font-medium transition-all flex items-center justify-center gap-2"
            >
              <Plus class="w-4 h-4" />
              Catégorie
            </button>
            <button 
              @click="openAddProduct"
              class="h-11 px-6 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-sm"
            >
              <Plus class="w-4 h-4" />
              Nouveau produit
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-[1400px] mx-auto px-6 sm:px-8 py-8 sm:py-10">
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-10">
        <div 
          v-for="stat in quickStats" 
          :key="stat.name"
          class="group bg-white rounded-2xl shadow-sm hover:shadow-md p-5 sm:p-6 transition-all duration-300"
        >
          <div class="flex items-center gap-4">
            <div :class="[
              stat.iconBg, 
              'w-12 h-12 sm:w-14 sm:h-14 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110'
            ]">
              <component :is="stat.icon" class="w-6 h-6 sm:w-7 sm:h-7" :class="stat.iconColor" />
            </div>
            <div>
              <p class="text-sm font-medium text-gray-500">{{ stat.name }}</p>
              <p class="text-2xl sm:text-3xl font-bold text-gray-900 mt-0.5">{{ stat.value }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Catégories -->
      <div class="flex gap-2 overflow-x-auto pb-4 mb-8 scrollbar-hide">
        <button
          v-for="category in categories"
          :key="category.id"
          @click="activeCategory = category.id"
          class="h-11 px-5 rounded-full text-sm font-medium whitespace-nowrap transition-all"
          :class="[
            activeCategory === category.id
              ? 'bg-blue-600 text-white shadow-sm'
              : 'bg-white text-gray-700 border border-gray-200/50 hover:bg-gray-50'
          ]"
        >
          {{ category.name }}
        </button>
      </div>

      <!-- Grid des produits -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5 sm:gap-6">
        <div 
          v-for="product in filteredProducts" 
          :key="product.id"
          class="group bg-white rounded-2xl shadow-sm hover:shadow-md overflow-hidden transition-all duration-300"
        >
          <!-- Image du produit -->
          <div class="aspect-[16/10] relative overflow-hidden bg-gradient-to-br from-gray-50 to-white">
            <img 
              :src="product.image_url || '/placeholder-product.jpg'" 
              :alt="product.name"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            />
            
            <!-- Status Badge -->
            <div class="absolute top-3 left-3">
              <div class="flex items-center gap-2 px-3 py-1.5 bg-white/90 backdrop-blur-sm rounded-full shadow-sm">
                <div class="w-2 h-2 rounded-full" :class="product.is_available ? 'bg-green-500' : 'bg-gray-300'"></div>
                <span class="text-xs font-medium text-gray-700">
                  {{ product.is_available ? 'Disponible' : 'Indisponible' }}
                </span>
              </div>
            </div>

            <!-- Actions -->
            <div class="absolute top-3 right-3 flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-all duration-300">
              <Switch
                v-model="product.is_available"
                @change="toggleAvailability(product)"
                class="relative inline-flex h-6 w-11 items-center rounded-full bg-white/90 backdrop-blur-sm shadow-sm"
              >
                <span class="sr-only">Disponibilité</span>
                <span
                  class="inline-block h-4 w-4 transform rounded-full transition"
                  :class="[
                    product.is_available ? 'translate-x-6 bg-blue-600' : 'translate-x-1 bg-gray-400'
                  ]"
                />
              </Switch>
              <button 
                @click="editProduct(product)"
                class="p-2 bg-white/90 backdrop-blur-sm rounded-full hover:bg-white transition-colors shadow-sm"
              >
                <Pencil class="w-4 h-4 text-gray-700" />
              </button>
            </div>
          </div>

          <!-- Infos produit -->
          <div class="p-5">
            <div class="flex items-start justify-between gap-4">
              <div class="min-w-0">
                <h3 class="font-semibold text-gray-900 truncate">{{ product.name }}</h3>
                <p class="text-sm text-gray-500 mt-1 line-clamp-2">{{ product.description }}</p>
              </div>
              <span class="text-sm font-bold text-gray-900 whitespace-nowrap">
                {{ formatPrice(product.price) }}
              </span>
            </div>
            <div class="mt-3 pt-3 border-t border-gray-100 flex justify-between items-center">
              <span class="text-xs text-gray-500">
                Catégorie: {{ getCategoryName(product.category_id) }}
              </span>
              <div 
                class="text-xs font-medium px-2 py-1 rounded-full"
                :class="product.is_available ? 'bg-green-50 text-green-600' : 'bg-gray-50 text-gray-500'"
              >
                {{ product.is_available ? 'En vente' : 'Masqué' }}
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Empty state -->
      <div v-if="filteredProducts.length === 0" class="py-16 flex flex-col items-center justify-center">
        <div class="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mb-4">
          <Search class="w-10 h-10 text-gray-300" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun produit trouvé</h3>
        <p class="text-gray-500 text-center max-w-md">
          {{ searchQuery ? "Aucun produit ne correspond à votre recherche." : "Aucun produit disponible dans cette catégorie." }}
        </p>
        <button 
          @click="openAddProduct"
          class="mt-6 h-11 px-6 bg-blue-600 text-white rounded-full text-sm font-medium hover:bg-blue-700 transition-all flex items-center justify-center gap-2"
        >
          <Plus class="w-4 h-4" />
          Ajouter un produit
        </button>
      </div>
    </main>

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
import { Switch, TransitionRoot, TransitionChild, Dialog, DialogPanel, DialogTitle } from '@headlessui/vue'
import {
  Plus, UtensilsCrossed, Edit2, Trash2,
  Coffee, Pizza, Store, TrendingUp, IceCream, Loader2,
  Search, MoreVertical, ChevronDown, Pencil
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
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(price)
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

/* Smooth element appearance animation */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.grid > div {
  animation: fadeIn 0.3s ease-out;
  animation-fill-mode: both;
}

.grid > div:nth-child(1) { animation-delay: 0.05s; }
.grid > div:nth-child(2) { animation-delay: 0.1s; }
.grid > div:nth-child(3) { animation-delay: 0.15s; }
.grid > div:nth-child(4) { animation-delay: 0.2s; }
.grid > div:nth-child(5) { animation-delay: 0.25s; }
.grid > div:nth-child(6) { animation-delay: 0.3s; }
.grid > div:nth-child(7) { animation-delay: 0.35s; }
.grid > div:nth-child(8) { animation-delay: 0.4s; }
</style> 