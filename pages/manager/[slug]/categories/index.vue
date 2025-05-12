<template>
  <div class="min-h-screen bg-[#F5F5F7]">
    <!-- En-tête avec effet glassmorphism amélioré -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/70 border-b border-gray-200/50">
      <div class="max-w-[1600px] mx-auto px-6 py-5">
        <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
          <div class="max-w-2xl">
            <div class="flex items-center gap-3 mb-2">
              <h1 class="text-3xl font-semibold text-gray-900">Catégories</h1>
              <div class="flex items-center gap-2 px-3 py-1 bg-gray-900/5 rounded-full">
                <span class="text-sm font-medium text-gray-600">{{ categories.length }}</span>
                <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                <span class="text-sm font-medium text-gray-600">{{ getTotalProducts() }} produits</span>
              </div>
            </div>
            <p class="text-base text-gray-500">Organisez votre menu en catégories pour une meilleure expérience client. Glissez-déposez pour réorganiser l'ordre d'affichage.</p>
          </div>
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <div class="relative flex-1 sm:flex-none">
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une catégorie..."
                class="w-full sm:w-64 pl-10 pr-4 h-11 rounded-xl bg-white shadow-sm border border-gray-200/50 focus:ring-2 focus:ring-gray-900/10 focus:border-transparent transition-all"
              />
              <Search class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
            </div>
            <button
              @click="openCategoryModal"
              class="h-11 px-6 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-sm"
            >
              <Plus class="w-4 h-4" />
              Nouvelle catégorie
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-[1600px] mx-auto px-6 py-8">
      <!-- Quick Actions -->
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <div 
          v-for="action in quickActions" 
          :key="action.name"
          class="group bg-white rounded-xl border border-gray-200/50 hover:border-gray-300 p-4 hover:shadow-lg transition-all duration-300 cursor-pointer"
          @click="action.onClick"
        >
          <div class="flex items-center gap-4">
            <div :class="[
              action.iconBg, 
              'w-12 h-12 rounded-xl flex items-center justify-center transition-all duration-300 group-hover:scale-110'
            ]">
              <component :is="action.icon" class="w-6 h-6" :class="action.iconColor" />
            </div>
            <div class="flex-1">
              <h3 class="font-medium text-gray-900">{{ action.name }}</h3>
              <p class="text-sm text-gray-500 mt-0.5">{{ action.description }}</p>
            </div>
            <ArrowRight class="w-4 h-4 text-gray-400 opacity-0 group-hover:opacity-100 transition-all duration-300 transform group-hover:translate-x-1" />
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20">
        <div class="w-16 h-16 relative">
          <div class="w-16 h-16 rounded-2xl bg-gray-100 animate-pulse"></div>
          <Loader2 class="w-8 h-8 text-gray-300 animate-spin absolute inset-0 m-auto" />
        </div>
        <p class="text-sm text-gray-500 mt-4">Chargement des catégories...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="categories.length === 0" 
        class="bg-white rounded-2xl border border-gray-200/50 p-12 text-center max-w-lg mx-auto mt-12"
      >
        <div class="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gray-50 flex items-center justify-center">
          <UtensilsCrossed class="w-10 h-10 text-gray-300" />
        </div>
        <h3 class="text-xl font-medium text-gray-900 mb-2">Commencez votre menu</h3>
        <p class="text-gray-500 mb-8">
          Créez des catégories pour organiser vos produits et faciliter la navigation de vos clients.
        </p>
        <button
          @click="openCategoryModal"
          class="px-6 py-3 bg-gray-900 text-white rounded-full font-medium hover:bg-gray-800 active:scale-95 transition-all inline-flex items-center gap-2"
        >
          <Plus class="w-5 h-5" />
          Créer votre première catégorie
        </button>
      </div>

      <!-- Categories Grid -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-6">
        <div 
          v-for="category in filteredCategories" 
          :key="category.id"
          class="group bg-white rounded-xl border border-gray-200/50 hover:border-gray-300 overflow-hidden hover:shadow-lg transition-all duration-300"
        >
          <!-- Image Header avec effet amélioré -->
          <div class="aspect-[16/10] relative overflow-hidden bg-gradient-to-br from-gray-50 to-white">
            <img
              v-if="category.image_url"
              :src="category.image_url"
              :alt="category.name"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            />
            <div v-else class="absolute inset-0 flex items-center justify-center">
              <div class="text-center transform group-hover:scale-110 transition-all duration-300">
                <div class="w-16 h-16 mx-auto rounded-xl bg-gray-900/5 backdrop-blur flex items-center justify-center mb-3">
                  <component 
                    :is="category.icon || UtensilsCrossed" 
                    class="w-8 h-8 text-gray-400"
                  />
                </div>
              </div>
            </div>

            <!-- Status Badge -->
            <div class="absolute top-3 left-3">
              <div class="flex items-center gap-2 px-3 py-1.5 bg-white/90 backdrop-blur-sm rounded-full shadow-sm">
                <div class="w-2 h-2 rounded-full bg-green-500"></div>
                <span class="text-xs font-medium text-gray-700">{{ getProductCount(category.id) }} produits</span>
              </div>
            </div>

            <!-- Actions -->
            <div class="absolute top-3 right-3 flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-all duration-300">
              <button 
                @click="editCategory(category)"
                class="p-2 bg-white/90 backdrop-blur-sm rounded-full hover:bg-white transition-colors shadow-sm"
              >
                <Edit2 class="w-4 h-4 text-gray-700" />
              </button>
              <button
                @click="deleteCategory(category.id)"
                class="p-2 bg-white/90 backdrop-blur-sm rounded-full hover:bg-white transition-colors shadow-sm"
              >
                <Trash2 class="w-4 h-4 text-gray-700" />
              </button>
            </div>
          </div>

          <!-- Category Info -->
          <div class="p-4">
            <div class="flex items-center gap-3 mb-3">
              <div class="w-10 h-10 rounded-xl bg-gray-900/5 flex items-center justify-center">
                <component 
                  :is="category.icon || UtensilsCrossed" 
                  class="w-5 h-5 text-gray-600" 
                />
              </div>
              <div class="flex-1 min-w-0">
                <h3 class="font-medium text-gray-900 truncate">{{ category.name }}</h3>
                <p class="text-sm text-gray-500">Mise à jour {{ formatDate(category.updated_at) }}</p>
              </div>
            </div>

            <!-- Progress Bar -->
            <div class="h-1.5 bg-gray-100 rounded-full overflow-hidden">
              <div 
                class="h-full bg-gray-900 rounded-full transition-all duration-300"
                :style="{ width: `${(getProductCount(category.id) / Math.max(...categories.map(c => getProductCount(c.id)))) * 100}%` }"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Category Modal -->
    <CategoryModal
      v-if="showCategoryModal"
      :category="editingCategory"
      @close="closeCategoryModal"
      @submit="saveCategory"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Plus, Edit2, Trash2, UtensilsCrossed,
  Coffee, Pizza, IceCream, Wine, Beer, Loader2,
  ImageIcon, Search, ArrowUpDown, Upload, Download,
  ArrowRight
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
const editingCategory = ref<Category | null>(null)
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
          establishment_id: establishment.value?.id
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
    categories.value = categoriesData || []
    
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

definePageMeta({
  layout: 'manager'
})

const handleUploadError = (error: Error): void => {
  showToast.error('Erreur', error.message)
}

const handleUploadSuccess = () => {
  showToast.success('Succès', 'Image téléchargée avec succès')
}

// Nouvelles données
const quickActions = computed(() => [
  {
    name: 'Nouvelle catégorie',
    description: 'Créer une catégorie',
    icon: Plus,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500',
    onClick: openCategoryModal
  },
  {
    name: 'Réorganiser',
    description: 'Modifier l\'ordre',
    icon: ArrowUpDown,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500',
    onClick: () => {} // À implémenter
  },
  {
    name: 'Importer',
    description: 'Depuis un fichier',
    icon: Upload,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500',
    onClick: () => {} // À implémenter
  },
  {
    name: 'Exporter',
    description: 'Sauvegarder',
    icon: Download,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500',
    onClick: () => {} // À implémenter
  }
])

// Filtrage des catégories
const filteredCategories = computed(() => {
  if (!searchQuery.value) return categories.value
  
  const query = searchQuery.value.toLowerCase()
  return categories.value.filter(category => 
    category.name.toLowerCase().includes(query)
  )
})

// Formatage de la date
const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long'
  })
}
</script>

<style scoped>
.backdrop-blur-sm {
  backdrop-filter: blur(8px);
}
</style> 

