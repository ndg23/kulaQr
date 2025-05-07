<template>
  <div class="min-h-screen bg-[#F5F5F7]">
    <!-- En-tête avec effet glassmorphism -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/70 border-b border-gray-200/50">
      <div class="max-w-6xl mx-auto px-6 py-5">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl font-semibold bg-gradient-to-r from-gray-900 to-gray-700 bg-clip-text text-transparent">
              Catégories
            </h1>
            <p class="text-sm text-gray-500 mt-0.5">{{ categories.length }} catégories • {{ getTotalProducts() }} produits</p>
          </div>
          <button
            @click="openCategoryModal"
            class="px-5 py-2.5 bg-gray-900 text-white rounded-full text-sm font-medium hover:bg-gray-800 active:scale-95 transition-all flex items-center gap-2"
          >
            <Plus class="w-4 h-4" />
            Nouvelle catégorie
          </button>
        </div>
      </div>
    </header>

    <main class="max-w-6xl mx-auto px-6 py-8">
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
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="category in categories" :key="category.id"
          class="group bg-white rounded-2xl border border-gray-200/50 overflow-hidden hover:shadow-lg transition-all duration-300"
        >
          <!-- Image Header -->
          <div class="aspect-[4/3] relative overflow-hidden">
            <img
              v-if="category.image_url"
              :src="category.image_url"
              :alt="category.name"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            />
            <div v-else 
              class="w-full h-full bg-gradient-to-br from-gray-100 to-gray-50 flex items-center justify-center"
            >
              <div class="text-center">
                <div class="w-16 h-16 mx-auto rounded-2xl bg-white/80 backdrop-blur flex items-center justify-center mb-2">
                  <UtensilsCrossed class="w-8 h-8 text-gray-400" />
                </div>
                <p class="text-sm text-gray-400">{{ category.name }}</p>
              </div>
            </div>

            <!-- Actions Overlay -->
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <div class="absolute bottom-0 left-0 right-0 p-4 flex justify-end items-center gap-2">
                <button 
                  @click="editCategory(category)"
                  class="p-2 text-white rounded-full hover:bg-white/20 transition-colors"
                >
                  <Edit2 class="w-4 h-4" />
                </button>
                <button
                  @click="deleteCategory(category.id)"
                  class="p-2 text-white rounded-full hover:bg-white/20 transition-colors"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          <!-- Category Info -->
          <div class="p-6">
            <div class="flex items-center gap-4 mb-4">
              <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
                <UtensilsCrossed class="w-6 h-6 text-blue-500" />
              </div>
              <div>
                <h3 class="font-medium text-gray-900">{{ category.name }}</h3>
                <p class="text-sm text-gray-500">{{ getProductCount(category.id) }} produits</p>
              </div>
            </div>

            <!-- Products Preview -->
            <div v-if="getCategoryProducts(category.id).length > 0" 
              class="space-y-3 mt-4 border-t border-gray-100 pt-4"
            >
              <div v-for="product in getCategoryProducts(category.id).slice(0, 3)" :key="product.id"
                class="flex items-center gap-3 p-2 rounded-xl hover:bg-gray-50 transition-colors"
              >
                <div class="w-10 h-10 bg-gray-100 rounded-xl overflow-hidden">
                  <img 
                    v-if="product.image_url"
                    :src="product.image_url"
                    :alt="product.name"
                    class="w-full h-full object-cover"
                  />
                  <div v-else class="w-full h-full flex items-center justify-center">
                    <UtensilsCrossed class="w-5 h-5 text-gray-400" />
                  </div>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="font-medium text-gray-900 truncate">{{ product.name }}</p>
                  <p class="text-sm text-gray-500">{{ formatPrice(product.price) }}</p>
                </div>
                <span 
                  class="flex-shrink-0 px-2 py-1 rounded-full text-xs font-medium"
                  :class="product.is_available ? 'bg-green-50 text-green-700' : 'bg-gray-50 text-gray-600'"
                >
                  {{ product.is_available ? 'Disponible' : 'Indisponible' }}
                </span>
              </div>

              <!-- More products link -->
              <div v-if="getCategoryProducts(category.id).length > 3" 
                class="text-center pt-2"
              >
                <NuxtLink 
                  :to="`/manager/${establishment.value?.id}/menu?category=${category.id}`"
                  class="text-sm text-blue-600 hover:text-blue-800 font-medium"
                >
                  Voir {{ getCategoryProducts(category.id).length - 3 }} autres produits
                </NuxtLink>
              </div>
            </div>

            <!-- Empty category state -->
            <div v-else class="mt-4 py-4 px-4 bg-gray-50 rounded-xl text-center">
              <p class="text-sm text-gray-500">Aucun produit dans cette catégorie</p>
              <NuxtLink 
                :to="`/manager/${establishment.value?.id}/menu`"
                class="text-sm text-blue-600 hover:text-blue-800 font-medium inline-block mt-2"
              >
                Ajouter un produit
              </NuxtLink>
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
  ImageIcon
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
</script>

<style scoped>
.backdrop-blur-sm {
  backdrop-filter: blur(8px);
}
</style> 
