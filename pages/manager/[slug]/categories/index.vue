<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Catégories"
      subtitle="Organisez vos produits en catégories"
      :icon="List"
      :primary-action="{
        label: 'Nouvelle catégorie',
        icon: Plus,
        action: openCategoryModal
      }"
    />

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
            <Search class="w-5 h-5 text-gray-400" />
            <span class="text-sm font-medium text-gray-700">Rechercher:</span>
          </div>

          <div class="relative flex-1 max-w-sm">
            <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher une catégorie..."
              class="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      <!-- Categories Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        <!-- Loading State -->
        <div v-if="loading" class="col-span-full flex flex-col items-center justify-center py-20">
          <div class="w-16 h-16 relative">
            <div class="w-16 h-16 bg-gray-100 rounded-full animate-pulse"></div>
            <Loader2 class="w-8 h-8 text-gray-400 animate-spin absolute inset-0 m-auto" />
          </div>
          <p class="text-sm text-gray-500 mt-4">Chargement des catégories...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredCategories.length === 0" class="col-span-full text-center py-16">
          <div class="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
            <UtensilsCrossed class="w-8 h-8 text-gray-400" />
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">
            {{ categories.length === 0 ? 'Commencez votre menu' : 'Aucune catégorie trouvée' }}
          </h3>
          <p class="text-gray-500 mb-6">
            {{ categories.length === 0 
              ? 'Créez des catégories pour organiser vos produits et faciliter la navigation de vos clients.'
              : searchQuery ? "Aucune catégorie ne correspond à votre recherche." : "Aucune catégorie disponible." 
            }}
          </p>
          <button
            v-if="categories.length === 0"
            @click="openCategoryModal"
            class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-2 rounded-full text-sm font-medium transition-colors"
          >
            Créer votre première catégorie
          </button>
        </div>

        <!-- Category Cards -->
       <template v-else>
  <div
    v-for="category in filteredCategories"
    :key="category.id"
    class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-all duration-300 group relative"
  >
    <!-- Category Image -->
    <div class="relative aspect-[4/3] overflow-hidden bg-gray-50">
      <!-- Image principale -->
      <img
        v-if="category.image_url && !category.imageError"
        :src="category.image_url"
        :alt="category.name"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        @error="handleImageError(category)"
        @load="handleImageLoad(category)"
      />
      
      <!-- Fallback icon si pas d'image ou erreur -->
      <div
        v-else
        class="absolute inset-0 flex items-center justify-center"
      >
        <div class="w-16 h-16 bg-gradient-to-br from-blue-100 to-blue-200 rounded-2xl flex items-center justify-center shadow-sm">
          <component
            :is="getCategoryIcon(category)"
            class="w-8 h-8 text-blue-600"
          />
        </div>
      </div>

      <!-- Loading overlay pendant le chargement de l'image -->
      <div
        v-if="category.image_url && category.imageLoading"
        class="absolute inset-0 flex items-center justify-center bg-gray-100/80 backdrop-blur-sm"
      >
        <div class="w-6 h-6 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin"></div>
      </div>

      <!-- Bouton Edit -->
      <div class="absolute top-3 right-3">
        <button
          @click="editCategory(category)"
          class="w-10 h-10 bg-white/95 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:shadow-xl transition-all duration-200 hover:scale-105 z-10"
        >
          <Edit2 class="w-5 h-5 text-gray-700" />
        </button>
      </div>
    </div>

    <!-- Category Info -->
    <div class="p-4">
      <div class="flex items-start justify-between mb-2">
        <div class="flex-1">
          <h3 class="font-semibold text-gray-900 text-lg leading-tight mb-1">
            {{ category.name }}
          </h3>
          <p class="text-sm text-gray-500">
            {{ getProductCount(category.id) }} produit{{ getProductCount(category.id) > 1 ? 's' : '' }}
          </p>
        </div>
        <button
          @click="deleteCategory(category.id)"
          class="w-10 h-10 border rounded-full text-gray-400 hover:text-red-500 transition-colors ml-2 flex items-center justify-center"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Category Description -->
      <p v-if="category.description" class="text-sm text-gray-600 mb-3 line-clamp-2">
        {{ category.description }}
      </p>

      <!-- Creation Date -->
      <div class="flex items-center justify-end">
        <span class="text-xs text-gray-400">
          Ajouté le {{ formatDate(category.created_at) }}
        </span>
      </div>
    </div>
  </div>
</template>
      </div>
    </main>

    <!-- Modal -->
    <TransitionRoot appear :show="showCategoryModal" as="template">
      <Dialog as="div" class="relative z-50" @close="closeCategoryModal">
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
              <CategoryModal
                :category="editingCategory"
                @close="closeCategoryModal"
                @submit="saveCategory"
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
import {
  Plus, Edit2, Trash2, UtensilsCrossed,
  X,
  Coffee, Pizza, IceCream, Wine, Beer, Loader2,
  ImageIcon, Search, ArrowUpDown, Upload, Download,
  ArrowRight, List, TrendingUp
} from 'lucide-vue-next'
import CategoryModal from '~/components/modals/CategoryModal.vue'
import {
  TransitionRoot,
  TransitionChild,
  Dialog,
  DialogPanel
} from '@headlessui/vue'
// import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'
import type { Category, Product } from '~/types'
import { useCustomToast } from '~/composables/useToast'
import ImageUploader from '~/components/ui/ImageUploader.vue'
// import { useSupabaseClient } from '@supabase/supabase-js'
const {showToast} = useCustomToast()
const route = useRoute()
const slug = route.params.slug
const supabase = useSupabaseClient()
const { establishment } = useEstablishment()

// State
const showCategoryModal = ref(false)
const editingCategory = ref<Category | null>(null as any)
const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const loading = ref(true)
const searchQuery = ref('')


// Methods
const getTotalProducts = (): number => {
  return products.value.length
}

const getProductCount = (categoryId: string): number => {
  if (!products.value) return 0
  return products.value.filter((p: Product) => p.category_id === categoryId).length
}

const getCategoryProducts = (categoryId: string): Product[] => {
  if (!products.value) return []
  return products.value.filter((p: Product) => p.category_id === categoryId)
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(price)
}

const handleImageError = (category: Category) => {
  category.imageError = true
  category.imageLoaded = false
}

const handleImageLoad = (category: Category) => {
  category.imageLoaded = true
  category.imageError = false
}

const getCategoryIcon = (category: Category) => {
  // Return appropriate icon based on category name or use default
  const name = category.name?.toLowerCase() || ''
  
  if (name.includes('pizza') || name.includes('pâte')) return Pizza
  if (name.includes('boisson') || name.includes('vin') || name.includes('bière')) return Wine
  if (name.includes('glace') || name.includes('dessert')) return IceCream
  if (name.includes('café') || name.includes('thé')) return Coffee
  if (name.includes('bière') || name.includes('alcool')) return Beer
  
  return category.icon || UtensilsCrossed
}

const openCategoryModal = () => {
  editingCategory.value = null
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  editingCategory.value = null
}

const editCategory = (category: Category) => {
  editingCategory.value = { ...category }
  showCategoryModal.value = true
}

interface CategoryData {
  name: string
  order_number: number
  image_url?: string
  establishment_id?: string
}

const saveCategory = async (categoryData: CategoryData) => {
  try {
    if (editingCategory.value?.id) {
      const { data, error } = await supabase
        .from('categories')
        .update({
          name: categoryData.name,
          order_number: categoryData.order_number,
          image_url: categoryData.image_url,
          establishment_id: establishment.value?.id as string
        })
        .eq('id', editingCategory.value.id)
        .select()
        .single()

      if (error) throw error
      
      const updatedCategory = data as Category
      
      // Mise à jour locale
      const index = categories.value.findIndex((c: Category) => c.id === editingCategory.value?.id)
      if (index !== -1) {
        categories.value[index] = {
          ...categories.value[index],
          ...updatedCategory,
          imageError: false,
          imageLoaded: false,
          iconBg: 'bg-blue-50',
          iconColor: 'text-blue-500'
        }
      }
    } else {
      const { data, error } = await supabase
        .from('categories')
        .insert({
          establishment_id: establishment.value?.id,
          name: categoryData.name,
          order_number: categories.value.length + 1,
          image_url: categoryData.image_url
        })
        .select()
        .single()

      if (error) throw error

      // Ajout local
      categories.value.push({
        ...data,
        imageError: false,
        imageLoaded: false,
        iconBg: 'bg-blue-50',
        iconColor: 'text-blue-500'
      })
    }
    
    closeCategoryModal()
    showToast.success(
      'Catégorie sauvegardée',
      editingCategory.value?.id ? 'Modifications enregistrées' : 'Nouvelle catégorie ajoutée'
    )
  } catch (error) {
    console.error('Error saving category:', error)
    showToast.error('Erreur', "Une erreur s'est produite lors de la sauvegarde")
  }
}

const deleteCategory = async (id: string) => {
  // Check if category has products
  const categoryProducts = getCategoryProducts(id)
  if (categoryProducts.length > 0) {
    if (!confirm(`Cette catégorie contient ${categoryProducts.length} produits. Êtes-vous sûr de vouloir la supprimer ? Les produits seront également supprimés.`)) {
      return
    }
  } else {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) {
      return
    }
  }

  try {
    const { error } = await supabase
      .from('categories')
      .delete()
      .eq('id', id)

    if (error) throw error

    // Suppression locale
    categories.value = categories.value.filter(c => c.id !== id)
    // Also remove products from this category from local state
    products.value = products.value.filter(p => p.category_id !== id)
    
    showToast.success('Catégorie supprimée', 'La catégorie a été supprimée')
  } catch (error) {
    console.error('Error deleting category:', error)
    showToast.error('Erreur', "Une erreur s'est produite lors de la suppression")
  }
}

// Charger les catégories et produits
const loadData = async () => {
  try {
    // Load categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('order_number')

    if (categoriesError) throw categoriesError
    
    // Initialize image loading states for categories
    categories.value = (categoriesData || []).map(cat => ({
      ...cat,
      imageError: false,
      imageLoaded: false
    }))
    
    // Load products
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('name')
    
    if (productsError) throw productsError
    products.value = productsData || []
  } catch (err) {
    console.error('Erreur chargement données:', err)
    showToast.error('Erreur', 'Impossible de charger les données')
  } finally {
    loading.value = false
  }
}

// Charger les données au montage
onMounted(async () => {
  await loadData()
})

// Watch for route changes to reload data
// Supprimez la ligne : const slug = route.params.slug as string

// Remplacez le watcher par :
watch(() => route.params.slug, async (newSlug, oldSlug) => {
  if (newSlug && newSlug !== oldSlug) {
    console.log('🔄 Restaurant categories:', newSlug)
    await loadData()
  }
}, { immediate: true }) // immediate: true remplace onMounted
definePageMeta({
  layout: 'manager'
})


// Filtrage des catégories
const filteredCategories = computed(() => {
  if (!searchQuery.value) return categories.value
  
  const query = searchQuery.value.toLowerCase()
  return categories.value.filter(category => 
    category.name.toLowerCase().includes(query)
  )
})

// Quick stats
const quickStats = computed(() => {
  const categoriesWithProducts = categories.value.filter(cat => getProductCount(cat.id) > 0).length
  const avgProductsPerCategory = categories.value.length > 0 
    ? Math.round(products.value.length / categories.value.length) 
    : 0

  return [
    {
      name: 'Catégories',
      value: categories.value.length,
      icon: List
    },
    {
      name: 'Produits',
      value: products.value.length,
      icon: UtensilsCrossed
    },
    {
      name: 'Avec produits',
      value: categoriesWithProducts,
      icon: Coffee
    },
    {
      name: 'Moy. produits/catégorie',
      value: avgProductsPerCategory,
      icon: TrendingUp
    }
  ]
})

// Formatage de la date
const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    
  })
}
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

