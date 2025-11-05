<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Menu"
      subtitle="Gérez vos produits et catégories"
      :icon="MenuIcon"
      :primary-action="{
        label: 'Ajouter',
        icon: Plus,
        action: openAddProduct
      }"
    
    />

    <!-- Search Bar -->
    <!-- <div class="max-w-7xl mx-auto px-8 py-6">
      <div class="relative">
        <Search class="w-5 h-5 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <input
          v-model="search"
                type="text"
                placeholder="Rechercher un produit..."
          class="w-full pl-12 pr-6 py-4 bg-white border border-gray-200 rounded-2xl text-base focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all shadow-sm"
        />
      </div>
    </div> -->

    <main class="max-w-7xl mx-auto px-8 pb-16 mt-2">
      <!-- Stats Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
        <div
          v-for="stat in quickStats"
          :key="stat.name"
          class="bg-white rounded-xl p-6 shadow-sm border border-gray-100"
        >
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-gray-50 rounded-xl flex items-center justify-center">
              <component :is="stat.icon" class="w-6 h-6 text-gray-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
              <p class="text-sm text-gray-500 mt-1">{{ stat.name }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
          <div class="flex items-center gap-2">
            <List class="w-5 h-5 text-gray-400" />
            <span class="text-sm font-medium text-gray-700">Filtrer par:</span>
          </div>

          <select
            v-model="activeCategory"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="all">Toutes les catégories</option>
            <option
              v-for="category in categories"
              :key="category.id"
              :value="category.id"
            >
              {{ category.name }}
            </option>
          </select>

          <div class="relative flex-1 max-w-sm">
            <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              v-model="search"
              type="text"
              placeholder="Rechercher un produit..."
              class="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              @input="handleSearch"
            />
          </div>
        </div>
      </div>

      <!-- Products Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <!-- Loading State -->
        <div v-if="loading" class="col-span-full flex flex-col items-center justify-center py-20">
          <div class="w-16 h-16 relative">
            <div class="w-16 h-16 bg-gray-100 rounded-full animate-pulse"></div>
            <div class="w-8 h-8 text-gray-400 animate-spin absolute inset-0 m-auto" />
          </div>
          <p class="text-sm text-gray-500 mt-4">Chargement...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredProducts.length === 0" class="col-span-full text-center py-16">
          <div class="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
            <Search class="w-8 h-8 text-gray-400" />
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun produit trouvé</h3>
          <p class="text-gray-500 mb-6">
            {{ search ? "Aucun produit ne correspond à votre recherche." : "Aucun produit dans cette catégorie." }}
          </p>
          <button
            @click="openAddProduct"
            class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-xl font-medium transition-colors shadow-sm hover:shadow-md"
          >
            Ajouter un produit
          </button>
        </div>

        <!-- Product Cards -->
        <div
          v-for="product in filteredProducts"
          :key="product.id"
          class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-all duration-300 group"
        >
          <!-- Product Image -->
          <div class="relative aspect-[4/3] overflow-hidden">
            <img
              :src="product.image_url || '/images/product-empty.png'"
              :alt="product.name"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            />
            <!-- Availability Toggle -->
            <div class="absolute top-3 right-3">
              <button
                @click="toggleAvailability(product)"
                class="w-10 h-10 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center border border-gray-200 hover:shadow-md transition-all duration-200"
                :class="product.is_available ? 'text-green-600' : 'text-gray-400'"
              >
                <Store class="w-5 h-5" />
              </button>
            </div>
            <!-- Status Badge -->
            <div class="absolute top-3 left-3">
              <span
                class="px-2 py-1 text-xs font-medium rounded-full"
                :class="product.is_available
                  ? 'bg-green-100 text-green-800'
                  : 'bg-gray-100 text-gray-600'"
              >
                {{ product.is_available ? 'Disponible' : 'Indisponible' }}
              </span>
            </div>
          </div>

          <!-- Product Info -->
          <div class="p-4">
            <div class="flex items-start justify-between mb-2">
              <div class="flex-1">
                <h3 class="font-semibold text-gray-900 text-lg leading-tight mb-1">
                  {{ product.name }}
                </h3>
                <p class="text-sm text-gray-500">
                  {{ getCategoryName(product.category_id) }}
                </p>
              </div>
              <div class="text-right ml-2">
                <p class="font-bold text-lg text-gray-900">
                  {{ formatPrice(product.price) }}
                </p>
              </div>
            </div>

            <!-- Product Description -->
            <p v-if="product.description" class="text-sm text-gray-600 mb-4 line-clamp-2">
              {{ product.description }}
            </p>

            <!-- Action Buttons -->
            <div class="flex gap-2">
              <button
                @click="editProduct(product)"
                class="flex-1 flex items-center justify-center gap-2 px-3 py-2 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-lg text-sm font-medium transition-colors duration-200"
              >
                <Pencil class="w-4 h-4" />
                Modifier
              </button>
              <button
                @click="confirmDeleteProduct(product)"
                class="flex-1 flex items-center justify-center gap-2 px-3 py-2 bg-red-50 hover:bg-red-100 text-red-700 rounded-lg text-sm font-medium transition-colors duration-200"
              >
                <Trash2 class="w-4 h-4" />
                Supprimer
              </button>
            </div>
          </div>
        </div>
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
          <div class="flex min-h-full items-center justify-center p-8">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-2xl transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
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
import { ref, computed, onMounted, watch } from 'vue'
import { TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  Plus, UtensilsCrossed, Store, TrendingUp, Search, Pencil, List, Menu as MenuIcon, Trash2
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { useEstablishment } from '~/composables/useEstablishment'
import ProductModal from '~/components/modals/ProductModal.vue'

const route = useRoute()
const slug = route.params.slug
const { client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()
const { establishment } = useEstablishment()

// State
const showAddProduct = ref(false)
const editingProduct = ref(null as any)
const activeCategory = ref('all')
const categories = ref<any[]>([])
const products = ref<any[]>([])
const loading = ref(true)
const search = ref('')


// Computed
const filteredProducts = computed(() => {
  let filtered = products.value

  // Filter by category
  if (activeCategory.value !== 'all') {
    filtered = filtered.filter((product: any) => product.category_id === activeCategory.value)
  }

  // Filter by search
  if (search.value) {
    const searchLower = search.value.toLowerCase()
    filtered = filtered.filter((product: any) => 
      product.name.toLowerCase().includes(searchLower) ||
      product.description?.toLowerCase().includes(searchLower)
    )
  }

  return filtered
})

// Quick stats
const quickStats = computed(() => {
  const avgPrice = products.value.length
    ? products.value.reduce((sum: any, p: any) => sum + p.price, 0) / products.value.length
    : 0

  return [
    {
      name: 'Produits',
      value: products.value.length,
      icon: UtensilsCrossed
    },
    {
      name: 'Catégories',
      value: categories.value.length,
      icon: List
    },
    {
      name: 'Actifs',
      value: products.value.filter((p: any) => p.is_available).length,
      icon: Store
    },
    {
      name: 'Prix moyen',
      value: avgPrice > 0 ? formatPrice(avgPrice) : '0 F CFA',
      icon: TrendingUp
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

const getCategoryName = (categoryId: string) => {
  const category = categories.value.find((c: any) => c.id === categoryId) as any
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
    categories.value = categoriesData as any[] || []
    
    // Load products directly by establishment_id
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*, category:categories(name)')
      .eq('establishment_id', establishment.value?.id)
      .order('name')

    if (productsError) throw productsError
    products.value = productsData as any[] || []
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
      .update({ is_available: !product.is_available })
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

const confirmDeleteProduct = (product: any) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer le produit "${product.name}" ? Cette action est irréversible.`)) {
    deleteProduct(product)
  }
}

const deleteProduct = async (product: any) => {
  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', product.id)

    if (error) throw error

    // Remove from local state
    const index = products.value.findIndex((p: any) => p.id === product.id)
    if (index !== -1) {
      products.value.splice(index, 1)
    }

    showToast.success('Produit supprimé', 'Le produit a été supprimé avec succès')
  } catch (err) {
    console.error('Erreur suppression:', err)
    showToast.error('Erreur', 'Impossible de supprimer le produit')
  }
}

const closeModal = () => {
  showAddProduct.value = false
  editingProduct.value = null
}

const saveProduct = async (productData: any) => {
  try {
    // Make sure the product has a valid category_id that belongs to this establishment
    if (!productData.category_id) {
      showToast.error('Erreur', 'Veuillez sélectionner une catégorie')
      return
    }
    
    // Verify the category belongs to this establishment
    const categoryExists = categories.value.some((c: any) => c.id === productData.category_id)
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
        .eq('id', editingProduct.value?.id as string) as any as any
      if (error) throw error
    } else {
      // Create new product
      const { error } = await supabase
        .from('products')
        .insert({
          ...productData,
          is_available: true
        }) as any as any

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

const openAddProduct = () => {
  editingProduct.value = null
  showAddProduct.value = true
}

// Initial load
onMounted(loadData)

// Watch for route changes to reload data
watch(() => route.path, async (newPath, oldPath) => {
  if (newPath && newPath !== oldPath) {
    await loadData()
  }
}, { immediate: true })

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
/* Smooth element appearance animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.grid > div {
  animation: fadeInUp 0.4s ease-out;
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
.grid > div:nth-child(9) { animation-delay: 0.45s; }
.grid > div:nth-child(10) { animation-delay: 0.5s; }
.grid > div:nth-child(11) { animation-delay: 0.55s; }
.grid > div:nth-child(12) { animation-delay: 0.6s; }

/* Enhanced hover effects */
.ManagerModernCard {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.ManagerModernCard:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

/* Improved focus states */
input:focus, button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Better scrollbar styling */
.overflow-x-auto::-webkit-scrollbar {
  height: 6px;
}

.overflow-x-auto::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 3px;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Line clamp utility */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-clamp: 2;
  overflow: hidden;
}
</style> 