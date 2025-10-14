<template>
  <div class="min-h-screen bg-white">
    <!-- Header Twitter Style -->
    <div class="sticky top-0 z-50 bg-white/80 backdrop-blur-xl border-b border-gray-200">
      <div class="px-4 py-4">
        <div class="flex items-center gap-4">
          <NuxtLink 
            to="/admin/establishments"
            class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <ArrowLeft class="w-5 h-5" />
          </NuxtLink>
          <div class="flex-1">
            <h1 class="text-xl font-bold text-gray-900">Gérer un établissement</h1>
            <p class="text-sm text-gray-500">Consultez et modifiez les informations d'un établissement</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="px-4 py-6 max-w-4xl mx-auto">
      <!-- Establishment Selector -->
      <div class="bg-white border border-gray-200 rounded-3xl p-6 mb-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Sélectionner un établissement</h2>
        <div class="flex gap-4">
          <select 
            v-model="selectedEstablishmentId" 
            @change="loadEstablishmentData"
            class="flex-1 h-12 px-4 rounded-2xl border border-gray-200 focus:border-black focus:ring-2 focus:ring-black/10 text-base"
            :disabled="loading"
          >
            <option value="">Choisir un établissement...</option>
            <option 
              v-for="establishment in establishments" 
              :key="establishment.id" 
              :value="establishment.id"
            >
              {{ establishment.name }} - {{ establishment.address || 'Aucune adresse' }}
            </option>
          </select>
          <button
            @click="refreshEstablishments"
            :disabled="loading"
            class="px-4 py-3 bg-gray-100 text-gray-700 rounded-2xl hover:bg-gray-200 transition-colors disabled:opacity-50"
          >
            <RefreshCw class="w-5 h-5" :class="{ 'animate-spin': loading }" />
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center py-12">
        <div class="text-center">
          <Loader2 class="w-8 h-8 animate-spin text-gray-400 mx-auto mb-4" />
          <p class="text-gray-500">Chargement des données...</p>
        </div>
      </div>

      <!-- Establishment Data -->
      <div v-else-if="establishmentData" class="space-y-6">
        <!-- Basic Info -->
        <div class="bg-white border border-gray-200 rounded-3xl overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
                <Store class="w-6 h-6 text-blue-500" />
              </div>
              <h2 class="text-xl font-semibold text-gray-900">Informations générales</h2>
            </div>
          </div>
          <div class="p-6 space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                <input 
                  v-model="establishmentData.name"
                  type="text"
                  class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Adresse</label>
                <input 
                  v-model="establishmentData.address"
                  type="text"
                  class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                <input 
                  v-model="establishmentData.phone"
                  type="tel"
                  class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Statut</label>
                <select
                  v-model="establishmentData.is_active"
                  class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10"
                >
                  <option :value="true">Actif</option>
                  <option :value="false">Inactif</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- Categories -->
        <div class="bg-white border border-gray-200 rounded-3xl overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
                  <List class="w-6 h-6 text-green-500" />
                </div>
                <h2 class="text-xl font-semibold text-gray-900">Catégories ({{ categories.length }})</h2>
              </div>
              <button
                @click="openCategoryModal"
                class="px-4 py-2 bg-black text-white rounded-2xl text-sm font-semibold hover:bg-gray-800 transition-colors"
              >
                <Plus class="w-4 h-4 inline mr-2" />
                Ajouter
              </button>
            </div>
          </div>
          <div class="p-6">
            <div v-if="categories.length === 0" class="text-center py-8">
              <List class="w-12 h-12 text-gray-300 mx-auto mb-4" />
              <p class="text-gray-500">Aucune catégorie</p>
            </div>
            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div 
                v-for="category in categories" 
                :key="category.id"
                class="p-4 border border-gray-200 rounded-2xl hover:border-gray-300 transition-colors"
              >
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-8 h-8 rounded-xl bg-gray-100 flex items-center justify-center">
                    <List class="w-4 h-4 text-gray-500" />
                  </div>
                  <h3 class="font-semibold text-gray-900">{{ category.name }}</h3>
                </div>
                <p class="text-sm text-gray-500 mb-3">{{ category.description || 'Aucune description' }}</p>
                <div class="flex gap-2">
                  <button
                    @click="editCategory(category)"
                    class="flex-1 px-3 py-2 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-200 transition-colors"
                  >
                    Modifier
                  </button>
                  <button
                    @click="deleteCategory(category.id)"
                    class="px-3 py-2 bg-red-50 text-red-600 rounded-xl text-sm font-medium hover:bg-red-100 transition-colors"
                  >
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Products -->
        <div class="bg-white border border-gray-200 rounded-3xl overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center">
                  <UtensilsCrossed class="w-6 h-6 text-orange-500" />
                </div>
                <h2 class="text-xl font-semibold text-gray-900">Produits ({{ products.length }})</h2>
              </div>
              <button
                @click="openProductModal"
                class="px-4 py-2 bg-black text-white rounded-2xl text-sm font-semibold hover:bg-gray-800 transition-colors"
              >
                <Plus class="w-4 h-4 inline mr-2" />
                Ajouter
              </button>
            </div>
          </div>
          <div class="p-6">
            <div v-if="products.length === 0" class="text-center py-8">
              <UtensilsCrossed class="w-12 h-12 text-gray-300 mx-auto mb-4" />
              <p class="text-gray-500">Aucun produit</p>
            </div>
            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div 
                v-for="product in products" 
                :key="product.id"
                class="p-4 border border-gray-200 rounded-2xl hover:border-gray-300 transition-colors"
              >
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-8 h-8 rounded-xl bg-gray-100 flex items-center justify-center">
                    <UtensilsCrossed class="w-4 h-4 text-gray-500" />
                  </div>
                  <h3 class="font-semibold text-gray-900">{{ product.name }}</h3>
                </div>
                <p class="text-sm text-gray-500 mb-2">{{ product.description || 'Aucune description' }}</p>
                <p class="text-lg font-bold text-gray-900 mb-3">{{ formatPrice(product.price) }}</p>
                <div class="flex gap-2">
                  <button
                    @click="editProduct(product)"
                    class="flex-1 px-3 py-2 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-200 transition-colors"
                  >
                    Modifier
                  </button>
                  <button
                    @click="deleteProduct(product.id)"
                    class="px-3 py-2 bg-red-50 text-red-600 rounded-xl text-sm font-medium hover:bg-red-100 transition-colors"
                  >
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-4">
          <button
            @click="saveChanges"
            :disabled="loading"
            class="flex-1 px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
          >
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <Loader2 class="w-4 h-4 animate-spin" />
              Enregistrement...
            </span>
            <span v-else>Enregistrer les modifications</span>
          </button>
          
          <button
            @click="resetForm"
            class="px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 transition-all duration-200"
          >
            Réinitialiser
          </button>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-16">
        <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Store class="w-12 h-12 text-gray-400" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun établissement sélectionné</h3>
        <p class="text-gray-600">Sélectionnez un établissement pour voir ses informations</p>
      </div>
    </div>

    <!-- Category Modal -->
    <CategoryModal
      v-if="showCategoryModal"
      :open="showCategoryModal"
      :category="editingCategory"
      :categories="categories"
      @close="closeCategoryModal"
      @submit="handleCategorySubmit"
    />

    <!-- Product Modal -->
    <ProductModal
      v-if="showProductModal"
      :open="showProductModal"
      :product="editingProduct"
      :categories="categories"
      @close="closeProductModal"
      @submit="handleProductSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  ArrowLeft, Store, List, UtensilsCrossed, Plus, Trash2, 
  Loader2, RefreshCw 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import CategoryModal from '~/components/modals/CategoryModal.vue'
import ProductModal from '~/components/modals/ProductModal.vue'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

// State
const loading = ref(false)
const establishments = ref<any[]>([])
const selectedEstablishmentId = ref('')
const establishmentData = ref<any>(null)
const categories = ref<any[]>([])
const products = ref<any[]>([])

// Modal states
const showCategoryModal = ref(false)
const showProductModal = ref(false)
const editingCategory = ref<any>(null)
const editingProduct = ref<any>(null)

// Load establishments for selector
const loadEstablishments = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name, address')
      .order('name', { ascending: true })

    if (error) throw error
    establishments.value = data || []
  } catch (err) {
    console.error('Error loading establishments:', err)
    showToast.error('Erreur', 'Impossible de charger les établissements')
  } finally {
    loading.value = false
  }
}

// Load establishment data
const loadEstablishmentData = async () => {
  if (!selectedEstablishmentId.value) {
    establishmentData.value = null
    categories.value = []
    products.value = []
    return
  }

  try {
    loading.value = true
    
    // Load establishment basic info
    const { data: establishment, error: establishmentError } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', selectedEstablishmentId.value)
      .single()

    if (establishmentError) throw establishmentError
    establishmentData.value = establishment

    // Load categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', selectedEstablishmentId.value)
      .order('name', { ascending: true })

    if (categoriesError) throw categoriesError
    categories.value = categoriesData || []

    // Load products
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select(`
        *,
        categories (
          id,
          name
        )
      `)
      .eq('establishment_id', selectedEstablishmentId.value)
      .order('name', { ascending: true })

    if (productsError) throw productsError
    products.value = productsData || []

  } catch (err) {
    console.error('Error loading establishment data:', err)
    showToast.error('Erreur', 'Impossible de charger les données de l\'établissement')
  } finally {
    loading.value = false
  }
}

// Refresh establishments
const refreshEstablishments = () => {
  loadEstablishments()
}

// Save changes
const saveChanges = async () => {
  if (!establishmentData.value) return

  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .update({
        name: establishmentData.value.name,
        address: establishmentData.value.address,
        phone: establishmentData.value.phone,
        is_active: establishmentData.value.is_active
      })
      .eq('id', establishmentData.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées', 'Les modifications ont été enregistrées avec succès')
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Erreur', 'Impossible d\'enregistrer les modifications')
  } finally {
    loading.value = false
  }
}

// Reset form
const resetForm = () => {
  selectedEstablishmentId.value = ''
  establishmentData.value = null
  categories.value = []
  products.value = []
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

// Category actions
const openCategoryModal = () => {
  editingCategory.value = null
  showCategoryModal.value = true
}

const editCategory = (category: any) => {
  editingCategory.value = category
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  editingCategory.value = null
}

const handleCategorySubmit = () => {
  closeCategoryModal()
  loadEstablishmentData()
}

const deleteCategory = async (categoryId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) return
  
  try {
    const { error } = await supabase
      .from('categories')
      .delete()
      .eq('id', categoryId)

    if (error) throw error
    
    categories.value = categories.value.filter(c => c.id !== categoryId)
    showToast.success('Catégorie supprimée', 'La catégorie a été supprimée avec succès')
  } catch (err) {
    console.error('Error deleting category:', err)
    showToast.error('Erreur', 'Impossible de supprimer la catégorie')
  }
}

// Product actions
const openProductModal = () => {
  editingProduct.value = null
  showProductModal.value = true
}

const editProduct = (product: any) => {
  editingProduct.value = product
  showProductModal.value = true
}

const closeProductModal = () => {
  showProductModal.value = false
  editingProduct.value = null
}

const handleProductSubmit = () => {
  closeProductModal()
  loadEstablishmentData()
}

const deleteProduct = async (productId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return
  
  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', productId)

    if (error) throw error
    
    products.value = products.value.filter(p => p.id !== productId)
    showToast.success('Produit supprimé', 'Le produit a été supprimé avec succès')
  } catch (err) {
    console.error('Error deleting product:', err)
    showToast.error('Erreur', 'Impossible de supprimer le produit')
  }
}

// Initialize
onMounted(() => {
  loadEstablishments()
})

definePageMeta({
  layout: 'admin'
})
</script>
