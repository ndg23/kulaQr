<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Menu"
      subtitle="Gérez vos produits et catégories"
      :icon="MenuIcon"
      :primary-action="{
        label: 'Nouveau produit',
        icon: Plus,
        action: openAddProduct
      }"
      :secondary-actions="[
        {
          label: 'Rechercher',
          icon: Search,
          action: () => {} // Will be handled by the search input
        }
      ]"
    />

    <!-- Search Bar -->
    <div class="max-w-4xl mx-auto px-6 py-4">
      <div class="relative">
        <Search class="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher un produit..."
          class="w-full pl-10 pr-4 py-3 bg-white border border-gray-200 rounded-full text-sm focus:ring-2 focus:ring-gray-500 focus:border-transparent transition-all"
        />
      </div>
    </div>

    <main class="max-w-4xl mx-auto px-6 py-8">
      <!-- Stats -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
        <ManagerModernCard 
          v-for="stat in quickStats"
          :key="stat.name"
          class="p-6"
        >
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
              <component :is="stat.icon" class="w-6 h-6 text-gray-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
              <p class="text-sm text-gray-500">{{ stat.name }}</p>
            </div>
          </div>
        </ManagerModernCard>
      </div>

      <!-- Categories -->
      <div class="mb-8">
        <div class="flex gap-3 overflow-x-auto pb-2">
          <button
            @click="activeCategory = 'all'"
            class="px-6 py-3 rounded-full text-sm font-medium whitespace-nowrap transition-all"
            :class="activeCategory === 'all' ? 'bg-black text-white' : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-100'"
          >
            Tout
          </button>
          <button
            v-for="category in categories"
            :key="category.id"
            @click="activeCategory = category.id"
            class="px-6 py-3 rounded-full text-sm font-medium whitespace-nowrap transition-all"
            :class="activeCategory === category.id ? 'bg-black text-white' : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-100'"
          >
            {{ category.name }}
          </button>
        </div>
      </div>

      <!-- Products Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <ManagerModernCard
          v-for="product in filteredProducts"
          :key="product.id"
          class="overflow-hidden"
        >
          <!-- Product Image -->
          <div class="aspect-[4/3] relative bg-gray-100 -m-6 mb-6">
            <img
              :src="product.image_url || '/placeholder-product.jpg'"
              :alt="product.name"
              class="w-full h-full object-cover"
            />
            <div class="absolute top-3 right-3">
              <button
                @click="editProduct(product)"
                class="w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-sm hover:shadow-md transition-shadow"
              >
                <Pencil class="w-4 h-4 text-gray-600" />
              </button>
            </div>
          </div>

          <!-- Product Info -->
          <div>
            <div class="flex items-start justify-between gap-3 mb-2">
              <h3 class="font-semibold text-gray-900 text-lg leading-tight">{{ product.name }}</h3>
              <span class="font-bold text-gray-900 text-lg">{{ formatPrice(product.price) }}</span>
            </div>

            <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ product.description }}</p>

            <div class="flex items-center justify-between">
              <span class="text-xs text-gray-500">{{ getCategoryName(product.category_id) }}</span>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="product.is_available"
                  @change="toggleAvailability(product)"
                  class="sr-only peer"
                >
                <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-blue-500"></div>
              </label>
            </div>
          </div>
        </ManagerModernCard>
      </div>
      <!-- Empty State -->
      <div v-if="filteredProducts.length === 0" class="text-center py-16">
        <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Search class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucun produit trouvé</h3>
        <p class="text-gray-500 mb-6">
          {{ search ? "Aucun produit ne correspond à votre recherche." : "Aucun produit dans cette catégorie." }}
        </p>
        <button
          @click="openAddProduct"
          class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-2 rounded-full text-sm font-medium transition-colors"
        >
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
import { ref, computed, onMounted, watch } from 'vue'
import { TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  Plus, UtensilsCrossed, Store, TrendingUp, Search, Pencil, List, Menu as MenuIcon
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
      value: formatPrice(
        products.value.length
          ? products.value.reduce((sum: any, p: any) => sum + p.price, 0) / products.value.length
          : 0
      ),
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