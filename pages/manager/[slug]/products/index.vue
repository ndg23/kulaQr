<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header with subtle shadow -->
    <div class="sticky top-0 z-10 bg-white border-b border-gray-100 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <button class="p-2 rounded-full hover:bg-gray-100 mr-3">
              <Icon name="arrow-left" class="w-5 h-5 text-gray-700" />
            </button>
            <h1 class="text-xl font-bold text-gray-900">Menu</h1>
          </div>
          
          <div class="flex items-center space-x-3">
            <button
              @click="showAddProduct = true"
              class="bg-blue-500 hover:bg-blue-600 text-white font-medium px-4 py-2 rounded-full transition-colors duration-200 flex items-center"
            >
              <Icon name="plus" class="w-5 h-5 mr-1" />
              <span>Ajouter</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <div class="max-w-7xl mx-auto pt-6 pb-12 px-4 sm:px-6 lg:px-8">
      <!-- Search & Filters -->
      <div class="mb-6">
        <div class="relative w-72">
          <Combobox.Input
            v-model="search"
            class="w-full bg-gray-50 border border-gray-200 rounded-full py-2.5 pl-12 pr-4 text-gray-900 placeholder:text-gray-500 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="Rechercher un produit..."
          />
          <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <Search class="w-5 h-5 text-gray-400" />
          </div>
        </div>
        
        <!-- Category Pills -->
        <div class="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          <button
            v-for="category in categories"
            :key="category.id"
            @click="activeCategory = category.id"
            class="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200"
            :class="[
              activeCategory === category.id
                ? 'bg-blue-500 text-white shadow-sm'
                : 'bg-white text-gray-700 border border-gray-200'
            ]"
          >
            {{ category.name }}
          </button>
        </div>
      </div>

      <!-- Products Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="product in filteredProducts"
          :key="product.id"
          class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow duration-200"
        >
          <div class="aspect-w-16 aspect-h-9 bg-gray-100 relative">
            <img
              :src="product.image_url || '/placeholder-food.jpg'"
              :alt="product.name"
              class="object-cover w-full h-full"
            />
            <div class="absolute top-2 right-2">
              <div class="bg-white/90 backdrop-blur-sm rounded-full px-3 py-1 text-sm font-semibold text-gray-900 shadow-sm">
                {{ formatPrice(product.price) }}
              </div>
            </div>
          </div>
          
          <div class="p-4">
            <div class="flex items-start justify-between">
              <div>
                <h3 class="font-semibold text-gray-900">{{ product.name }}</h3>
                <p class="text-sm text-gray-500 mt-1 line-clamp-2">{{ product.description }}</p>
                <div class="mt-2 inline-flex px-2 py-1 rounded-full bg-gray-100 text-xs font-medium text-gray-600">
                  {{ getCategoryName(product.category_id) }}
                </div>
              </div>
              
              <div class="ml-4">
                <Switch
                  v-model="product.is_available"
                  @change="toggleAvailability(product)"
                  class="relative inline-flex"
                >
                  <span class="sr-only">Disponibilité</span>
                  <div 
                    :class="[
                      product.is_available ? 'bg-green-500' : 'bg-gray-200',
                      'relative inline-flex h-6 w-11 flex-shrink-0 rounded-full transition-colors duration-200'
                    ]"
                  >
                    <span
                      :class="[
                        product.is_available ? 'translate-x-5' : 'translate-x-1',
                        'inline-block h-4 w-4 transform rounded-full bg-white shadow transition duration-200 ease-in-out mt-1'
                      ]"
                    />
                  </div>
                </Switch>
              </div>
            </div>
            
            <div class="mt-4 pt-3 border-t border-gray-100 flex justify-end gap-2">
              <button
                @click="editProduct(product)"
                class="p-2 rounded-full hover:bg-gray-100 transition-colors duration-200"
              >
                <Icon name="pencil" class="w-5 h-5 text-gray-700" />
              </button>
              <button
                @click="deleteProduct(product.id)"
                class="p-2 rounded-full hover:bg-red-50 transition-colors duration-200"
              >
                <Icon name="trash" class="w-5 h-5 text-red-500" />
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Empty state -->
      <div v-if="filteredProducts.length === 0" class="mt-8 text-center py-12">
        <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
          <Icon name="utensils" class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-medium text-gray-900">Aucun produit trouvé</h3>
        <p class="text-gray-500 mt-2">
          {{ search ? "Essayez de modifier votre recherche" : "Ajoutez votre premier produit" }}
        </p>
        <button
          v-if="!search"
          @click="showAddProduct = true"
          class="mt-4 bg-blue-500 hover:bg-blue-600 text-white font-medium px-4 py-2 rounded-full transition-colors duration-200"
        >
          Ajouter un produit
        </button>
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
                  v-if="showAddProduct"
                  :product="editingProduct"
                  :categories="categories"
                  @close="closeModal"
                  @save="saveProduct"
                />
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Delete Confirmation Modal -->
    <TransitionRoot appear :show="showDeleteConfirm" as="template">
      <Dialog as="div" class="relative z-50" @close="showDeleteConfirm = false">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/25" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white text-left align-middle shadow-xl transition-all">
                <div class="bg-white px-6 pt-5 pb-6">
                  <div class="flex flex-col items-center justify-center">
                    <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
                      <Trash2 class="h-6 w-6 text-red-600" />
                    </div>
                    <DialogTitle as="h3" class="text-lg font-medium text-gray-900">
                      Supprimer le produit ?
                    </DialogTitle>
                    <p class="text-sm text-gray-500 mt-2 text-center">
                      Cette action est irréversible et supprimera définitivement ce produit de votre menu.
                    </p>
                  </div>
                </div>
                <div class="bg-gray-50 px-6 py-4 flex justify-end gap-3">
                  <button
                    @click="showDeleteConfirm = false"
                    class="px-4 py-2 bg-white text-gray-700 font-medium rounded-full border border-gray-300 hover:bg-gray-50 transition-colors duration-200"
                  >
                    Annuler
                  </button>
                  <button
                    @click="confirmDelete"
                    class="px-4 py-2 bg-red-500 text-white font-medium rounded-full hover:bg-red-600 transition-colors duration-200"
                  >
                    Supprimer
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
import { ref, computed, onMounted, watch } from 'vue'
import type { Product, Category } from '~/types'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'
import ProductModal from '~/components/modals/ProductModal.vue'
import { 
  Search,
  Plus,
  PlusCircle,
  Upload,
  Pencil,
  Trash2,
  Clock,
  ChevronRight,
  Utensils
} from 'lucide-vue-next'
import {
  Combobox,
  ComboboxInput,
  ComboboxOptions,
  ComboboxOption,
  Menu,
  MenuButton,
  MenuItems,
  MenuItem,
  RadioGroup,
  RadioGroupOption,
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionRoot,
  TransitionChild
} from '@headlessui/vue'

const { client: supabase, withLoading } = useSupabaseWrapper()
const toast = useToast()
const slug = route.params.slug as string

// State
const establishment = ref<any>(null)
const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const activeCategory = ref<string>('')
const search = ref('')
const showAddProduct = ref(false)
const editingProduct = ref<Product | null>(null)
const showDeleteConfirm = ref(false)
const productToDelete = ref<string | null>(null)

// Computed
const filteredProducts = computed(() => {
  let filtered = products.value

  if (activeCategory.value) {
    filtered = filtered.filter(p => p.category_id === activeCategory.value)
  }

  if (search.value) {
    const searchLower = search.value.toLowerCase()
    filtered = filtered.filter(p => 
      p.name.toLowerCase().includes(searchLower) ||
      p.description?.toLowerCase().includes(searchLower)
    )
  }

  return filtered
})

// Methods
const loadData = async () => {
  // Load establishment
  const { data: est } = await supabase
    .from('establishments')
    .select()
    .eq('id', slug)
    .single()
  
  establishment.value = est

  // Load categories
  const { data: cats } = await supabase
    .from('categories')
    .select()
    .eq('establishment_id', slug)
    .order('order_number')
  
  categories.value = cats || []
  if (cats?.length) activeCategory.value = cats[0].id

  // Load products
  const { data: prods } = await supabase
    .from('products')
    .select()
    .eq('establishment_id', slug)
    .order('name')
  
  products.value = prods || []
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(price)
}

const toggleAvailability = async (product: Product) => {
  const { error } = await supabase
    .from('products')
    .update({ is_available: product.is_available })
    .eq('id', product.id)

  if (error) {
    console.error('Error toggling availability:', error)
    product.is_available = !product.is_available // Revert on error
    toast.error('Erreur', 'Impossible de modifier la disponibilité')
  } else {
    toast.success('Mise à jour', 'Disponibilité mise à jour')
  }
}

const editProduct = (product: Product) => {
  editingProduct.value = { ...product }
  showAddProduct.value = true
}

const saveProduct = async (productData: Partial<Product>) => {
  const result = await withLoading(async () => {
    if (editingProduct.value?.id) {
      await supabase
        .from('products')
        .update(productData)
        .eq('id', editingProduct.value.id)
    } else {
      await supabase
        .from('products')
        .insert({
          ...productData,
          establishment_id: slug
        })
    }

    await loadData()
    closeModal()
    toast.success(
      'Produit sauvegardé',
      editingProduct.value?.id ? 'Le produit a été mis à jour' : 'Le produit a été créé'
    )
  })

  if (!result) {
    toast.error('Erreur', 'Impossible de sauvegarder le produit')
  }
}

const closeModal = () => {
  showAddProduct.value = false
  editingProduct.value = null
}

const deleteProduct = (productId: string) => {
  productToDelete.value = productId
  showDeleteConfirm.value = true
}

const confirmDelete = async () => {
  const result = await withLoading(async () => {
    await supabase
      .from('products')
      .delete()
      .eq('id', productToDelete.value)

    await loadData()
    showDeleteConfirm.value = false
    toast.success('Produit supprimé', 'Le produit a été supprimé avec succès')
  })

  if (!result) {
    toast.error('Erreur', 'Impossible de supprimer le produit')
  }
}

const getCategoryName = (categoryId: string) => {
  return categories.value.find(c => c.id === categoryId)?.name || ''
}

// Initial load
onMounted(loadData)

// Watch for route changes to reload data
// Supprimez la ligne : const slug = route.params.slug as string

// Remplacez le watcher par :
watch(() => route.params.slug, async (newSlug, oldSlug) => {
  if (newSlug && newSlug !== oldSlug) {
    console.log('🔄 Restaurant changed:', newSlug)
    await loadData()
  }
}, { immediate: true }) // immediate: true remplace onMounted
definePageMeta({
  layout: 'manager'
})
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>

