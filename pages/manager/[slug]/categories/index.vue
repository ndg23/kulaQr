<template>
  <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Catégories</h1>
        <p class="mt-1 text-sm text-gray-500">Gérez les catégories de votre menu</p>
      </div>
      <button
        @click="openCategoryModal"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Nouvelle catégorie
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <Loader2 class="w-10 h-10 text-gray-300 animate-spin mb-4" />
      <p class="text-sm text-gray-500">Chargement des catégories...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="categories.length === 0" class="bg-white rounded-2xl border border-gray-100 p-12 text-center">
      <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-50 flex items-center justify-center">
        <UtensilsCrossed class="w-8 h-8 text-gray-300" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune catégorie</h3>
      <p class="text-gray-500 mb-6 max-w-md mx-auto">
        Vous n'avez pas encore créé de catégories pour votre menu. Commencez par ajouter votre première catégorie.
      </p>
      <button
        @click="openCategoryModal"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Nouvelle catégorie
      </button>
    </div>

    <!-- Categories Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="category in categories" :key="category.id"
        class="bg-white rounded-xl border border-gray-100 overflow-hidden group hover:shadow-sm transition-all"
      >
        <!-- Category Image Header -->
        <div class="aspect-video w-full bg-gray-50 relative">
          <img
            v-if="category.image_url"
            :src="category.image_url"
            :alt="category.name"
            class="w-full h-full object-cover"
          />
          <div v-else class="w-full h-full flex flex-col items-center justify-center p-4">
            <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-2">
              <UtensilsCrossed class="w-8 h-8 text-gray-300" />
            </div>
            <p class="text-sm text-gray-400 text-center">{{ category.name }}</p>
          </div>
          
          <!-- Quick Actions Overlay -->
          <div class="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <div class="flex items-center space-x-2">
              <button 
                @click="editCategory(category)"
                class="p-2 text-white hover:text-gray-200 rounded-lg hover:bg-white/10"
              >
                <Edit2 class="w-5 h-5" />
              </button>
              <button
                @click="deleteCategory(category.id)"
                class="p-2 text-white hover:text-gray-200 rounded-lg hover:bg-white/10"
              >
                <Trash2 class="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
        
        <div class="p-6">
          <div class="flex items-center space-x-3 mb-4">
            <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
              <UtensilsCrossed class="w-5 h-5 text-blue-500" />
            </div>
            <div>
              <h3 class="font-medium text-gray-900">{{ category.name }}</h3>
              <p class="text-sm text-gray-500">{{ getProductCount(category.id) }} produits</p>
            </div>
          </div>

          <!-- Products List -->
          <div v-if="getCategoryProducts(category.id).length > 0" class="space-y-2 mt-4">
            <div v-for="product in getCategoryProducts(category.id).slice(0, 3)" :key="product.id"
              class="flex items-center justify-between py-2 px-3 rounded-lg hover:bg-gray-50"
            >
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-gray-100 rounded-lg overflow-hidden">
                  <img 
                    v-if="product.image_url"
                    :src="product.image_url"
                    :alt="product.name"
                    class="w-full h-full object-cover"
                  />
                  <div v-else class="w-full h-full flex items-center justify-center">
                    <UtensilsCrossed class="w-4 h-4 text-gray-400" />
                  </div>
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900 truncate max-w-[140px]">{{ product.name }}</p>
                  <p class="text-xs text-gray-500">{{ formatPrice(product.price) }}</p>
                </div>
              </div>
              <span 
                class="inline-flex items-center px-1.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-green-50 text-green-700': product.is_available,
                  'bg-gray-50 text-gray-600': !product.is_available
                }"
              >
                {{ product.is_available ? 'Disponible' : 'Indisponible' }}
              </span>
            </div>
            
            <!-- Show more link if there are more products -->
            <div v-if="getCategoryProducts(category.id).length > 3" class="text-center pt-2">
              <NuxtLink 
                :to="`/manager/${establishment.value?.id}/menu?category=${category.id}`"
                class="text-sm text-blue-600 hover:text-blue-800"
              >
                Voir les {{ getCategoryProducts(category.id).length - 3 }} autres produits
              </NuxtLink>
            </div>
          </div>
          
          <!-- Empty products state -->
          <div v-else class="mt-4 py-4 px-3 bg-gray-50 rounded-lg text-center">
            <p class="text-sm text-gray-500">Aucun produit dans cette catégorie</p>
            <NuxtLink 
              :to="`/manager/${establishment.value?.id}/menu`"
              class="text-sm text-blue-600 hover:text-blue-800 inline-block mt-1"
            >
              Ajouter un produit
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>

    <!-- Category Modal -->
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
          <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
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
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white shadow-xl transition-all">
                <CategoryModal
                  :category="editingCategory"
                  @submit="saveCategory"
                  @close="closeCategoryModal"
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
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'
import type { Category, Product } from '~/types'
import { useCustomToast } from '~/composables/useToast'
import ImageUploader from '~/components/ui/ImageUploader.vue'

const {showToast} = useCustomToast()
const route = useRoute()
const slug = route.params.slug
const { client: supabase } = useSupabaseWrapper()
const { establishment } = useEstablishment()

// State
const showCategoryModal = ref(false)
const editingCategory = ref<Category | null>(null)
const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const loading = ref(true)

// Methods
const getProductCount = (categoryId: string) => {
  if (!products.value) return 0
  return products.value.filter(p => p.category_id === categoryId).length
}

const getCategoryProducts = (categoryId: string) => {
  if (!products.value) return []
  return products.value.filter(p => p.category_id === categoryId)
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

const saveCategory = async (categoryData: any) => {
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
      showToast.success('Succès', 'Catégorie sauvegardée')
      // Mise à jour locale
      const index = categories.value.findIndex(c => c.id === editingCategory.value?.id)
      if (index !== -1) {
        categories.value[index] = {
          ...categories.value[index],
          ...data,
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

const handleUploadError = (error) => {
  showToast.error('Erreur', error)
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