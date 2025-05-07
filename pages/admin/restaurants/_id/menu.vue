<template>
  <div class="p-6 lg:p-8">
    <!-- Header avec navigation -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <div class="flex items-center space-x-3 mb-2">
          <UButton
            icon="i-heroicons-arrow-left"
            color="gray"
            variant="ghost"
            @click="navigateTo('/admin/restaurants')"
          />
          <h1 class="text-3xl font-bold text-gray-900">Menu du restaurant</h1>
        </div>
        <p class="text-lg text-gray-600">{{ restaurant?.name }}</p>
      </div>
      
      <div class="flex space-x-3">
        <UButton
          icon="i-heroicons-qr-code"
          label="QR Code"
          color="gray"
          @click="manageQrCodes(restaurant)"
        />
        <UButton
          icon="i-heroicons-plus"
          label="Ajouter une catégorie"
          color="black"
          @click="openNewCategoryModal"
        />
      </div>
    </div>

    <!-- Contenu du menu -->
    <div v-if="loading" class="flex justify-center py-12">
      <ULoader size="lg" />
    </div>
    
    <div v-else-if="!categories.length" class="bg-white rounded-3xl border border-gray-100 p-12 text-center">
      <div class="mx-auto w-24 h-24 bg-gray-50 rounded-full flex items-center justify-center mb-6">
        <UIcon name="i-heroicons-clipboard-document-list" class="w-12 h-12 text-gray-400" />
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune catégorie</h3>
      <p class="text-gray-500 mb-6 max-w-md mx-auto">
        Ce restaurant n'a pas encore de catégories dans son menu. Commencez par ajouter une catégorie.
      </p>
      <UButton
        icon="i-heroicons-plus"
        label="Ajouter une catégorie"
        color="black"
        @click="openNewCategoryModal"
      />
    </div>
    
    <div v-else class="space-y-8">
      <!-- Catégories et produits -->
      <div v-for="category in categories" :key="category.id" class="bg-white rounded-3xl border border-gray-100 overflow-hidden">
        <!-- En-tête de catégorie -->
        <div class="p-6 border-b border-gray-100 flex items-center justify-between">
          <div>
            <h2 class="text-xl font-semibold text-gray-900">{{ category.name }}</h2>
            <p v-if="category.description" class="text-gray-500 mt-1">{{ category.description }}</p>
          </div>
          
          <div class="flex space-x-2">
            <UButton
              icon="i-heroicons-plus"
              label="Ajouter un produit"
              color="gray"
              variant="soft"
              @click="openNewProductModal(category)"
            />
            <UDropdown
              :items="[
                [
                  {
                    label: 'Modifier',
                    icon: 'i-heroicons-pencil-square',
                    click: () => editCategory(category)
                  }
                ],
                [
                  {
                    label: 'Supprimer',
                    icon: 'i-heroicons-trash',
                    click: () => deleteCategory(category.id),
                    color: 'red'
                  }
                ]
              ]"
            >
              <UButton
                color="gray"
                variant="ghost"
                icon="i-heroicons-ellipsis-horizontal"
              />
            </UDropdown>
          </div>
        </div>
        
        <!-- Liste des produits -->
        <div v-if="!category.products?.length" class="p-8 text-center">
          <p class="text-gray-500">Aucun produit dans cette catégorie</p>
        </div>
        
        <div v-else class="divide-y divide-gray-100">
          <div v-for="product in category.products" :key="product.id" class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <div v-if="product.image_url" class="w-16 h-16 rounded-xl overflow-hidden bg-gray-100">
                  <img :src="product.image_url" :alt="product.name" class="w-full h-full object-cover" />
                </div>
                <div v-else class="w-16 h-16 rounded-xl bg-gray-100 flex items-center justify-center">
                  <UIcon name="i-heroicons-photo" class="w-8 h-8 text-gray-300" />
                </div>
                
                <div>
                  <h3 class="font-medium text-gray-900">{{ product.name }}</h3>
                  <p v-if="product.description" class="text-sm text-gray-500 mt-1">{{ product.description }}</p>
                  <p class="text-sm font-semibold text-gray-900 mt-1">{{ formatPrice(product.price) }}</p>
                </div>
              </div>
              
              <UDropdown
                :items="[
                  [
                    {
                      label: 'Modifier',
                      icon: 'i-heroicons-pencil-square',
                      click: () => editProduct(product, category)
                    }
                  ],
                  [
                    {
                      label: product.is_available ? 'Masquer' : 'Afficher',
                      icon: product.is_available ? 'i-heroicons-eye-slash' : 'i-heroicons-eye',
                      click: () => toggleProductAvailability(product)
                    },
                    {
                      label: 'Supprimer',
                      icon: 'i-heroicons-trash',
                      click: () => deleteProduct(product.id),
                      color: 'red'
                    }
                  ]
                ]"
              >
                <UButton
                  color="gray"
                  variant="ghost"
                  icon="i-heroicons-ellipsis-horizontal"
                  size="sm"
                />
              </UDropdown>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de catégorie -->
    <TransitionRoot appear :show="showCategoryModal" as="template">
      <Dialog as="div" @close="closeCategoryModal" class="relative z-50">
        <!-- Overlay -->
        <TransitionChild
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30" />
        </TransitionChild>

        <!-- Modal -->
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-lg transform overflow-hidden rounded-3xl bg-white p-8 border border-gray-100 shadow-xl transition-all">
                <div class="flex items-center justify-between mb-6">
                  <DialogTitle as="h3" class="text-xl font-semibold text-gray-900">
                    {{ selectedCategory ? 'Modifier la catégorie' : 'Ajouter une catégorie' }}
                  </DialogTitle>
                  <button 
                    @click="closeCategoryModal"
                    class="text-gray-400 hover:text-gray-500"
                  >
                    <X class="w-5 h-5" />
                  </button>
                </div>

                <form @submit.prevent="handleCategorySubmit(categoryForm)" class="space-y-6">
                  <!-- Nom -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Nom de la catégorie
                    </label>
                    <input
                      v-model="categoryForm.name"
                      type="text"
                      required
                      class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    />
                  </div>

                  <!-- Description -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Description (optionnelle)
                    </label>
                    <textarea
                      v-model="categoryForm.description"
                      rows="3"
                      class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    ></textarea>
                  </div>

                  <!-- Ordre -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Ordre d'affichage
                    </label>
                    <input
                      v-model.number="categoryForm.order"
                      type="number"
                      min="0"
                      class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    />
                  </div>

                  <!-- Boutons -->
                  <div class="flex justify-end space-x-3 pt-4">
                    <UButton
                      label="Annuler"
                      color="gray"
                      variant="soft"
                      @click="closeCategoryModal"
                    />
                    <UButton
                      type="submit"
                      label="Enregistrer"
                      color="black"
                      :loading="loading"
                    />
                  </div>
                </form>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Modal de produit -->
    <TransitionRoot appear :show="showProductModal" as="template">
      <Dialog as="div" @close="closeProductModal" class="relative z-50">
        <!-- Overlay -->
        <TransitionChild
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30" />
        </TransitionChild>

        <!-- Modal -->
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-xl transform overflow-hidden rounded-3xl bg-white p-8 border border-gray-100 shadow-xl transition-all">
                <div class="flex items-center justify-between mb-6">
                  <DialogTitle as="h3" class="text-xl font-semibold text-gray-900">
                    {{ selectedProduct ? 'Modifier le produit' : 'Ajouter un produit' }}
                  </DialogTitle>
                  <button 
                    @click="closeProductModal"
                    class="text-gray-400 hover:text-gray-500"
                  >
                    <X class="w-5 h-5" />
                  </button>
                </div>

                <form @submit.prevent="handleProductSubmit(productForm)" class="space-y-6">
                  <!-- Nom -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Nom du produit
                    </label>
                    <input
                      v-model="productForm.name"
                      type="text"
                      required
                      class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    />
                  </div>

                  <!-- Description -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Description (optionnelle)
                    </label>
                    <textarea
                      v-model="productForm.description"
                      rows="3"
                      class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    ></textarea>
                  </div>

                  <!-- Prix -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Prix
                    </label>
                    <div class="relative">
                      <div class="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none">
                        <span class="text-gray-500">{{ getCurrencySymbol() }}</span>
                      </div>
                      <input
                        v-model.number="productForm.price"
                        type="number"
                        min="0"
                        step="0.01"
                        required
                        class="w-full h-12 pl-10 pr-4 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                      />
                    </div>
                  </div>

                  <!-- Image URL -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      URL de l'image (optionnelle)
                    </label>
                    <input
                      v-model="productForm.image_url"
                      type="url"
                      class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
                    />
                  </div>

                  <!-- Disponibilité -->
                  <div class="flex items-center">
                    <Switch
                      v-model="productForm.is_available"
                      :class="productForm.is_available ? 'bg-green-500' : 'bg-gray-200'"
                      class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                    >
                      <span
                        :class="productForm.is_available ? 'translate-x-6' : 'translate-x-1'"
                        class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
                      />
                    </Switch>
                    <span class="ml-3 text-sm font-medium text-gray-700">
                      {{ productForm.is_available ? 'Disponible' : 'Non disponible' }}
                    </span>
                  </div>

                  <!-- Boutons -->
                  <div class="flex justify-end space-x-3 pt-4">
                    <UButton
                      label="Annuler"
                      color="gray"
                      variant="soft"
                      @click="closeProductModal"
                    />
                    <UButton
                      type="submit"
                      label="Enregistrer"
                      color="black"
                      :loading="loading"
                    />
                  </div>
                </form>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- QR Code Modal -->
    <TransitionRoot appear :show="showQrModal" as="template">
      <Dialog as="div" @close="closeQrModal" class="relative z-50">
        <!-- Overlay -->
        <TransitionChild
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
        </TransitionChild>

        <!-- Modal -->
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
                <div class="relative">
                  <!-- Header avec le nom du restaurant -->
                  <div class="bg-gray-50 px-6 py-4 text-center">
                    <DialogTitle as="h3" class="text-xl font-semibold text-gray-900">
                      {{ restaurant?.name }}
                    </DialogTitle>
                    <p class="mt-1 text-sm text-gray-500">
                      Scanner ce QR code pour accéder au menu
                    </p>
                  </div>
                  
                  <!-- QR Code -->
                  <div class="flex justify-center p-8 bg-white">
                    <div class="p-4 bg-white rounded-2xl shadow-sm border border-gray-100">
                      <QRCodeVue3
                        v-if="qrCodeUrl"
                        :value="qrCodeUrl"
                        :size="240"
                        level="H"
                        :margin="2"
                        class="rounded-xl overflow-hidden"
                        :dotsOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :cornersSquareOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :cornersDotOptions="{ 
                          type: 'square',
                          color: '#000000' 
                        }"
                        :backgroundOptions="{ 
                          color: '#FFFFFF' 
                        }"
                      />
                    </div>
                  </div>
                  
                  <!-- URL -->
                  <div class="px-6 pb-4 text-center">
                    <p class="text-sm font-medium text-gray-700 mb-2">URL du menu</p>
                    <div class="flex items-center justify-center space-x-2">
                      <input
                        type="text"
                        readonly
                        :value="qrCodeUrl"
                        class="flex-1 px-3 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg"
                      />
                      <button
                        @click="copyToClipboard(qrCodeUrl)"
                        class="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100"
                        title="Copier l'URL"
                      >
                        <ClipboardCopy class="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                  
                  <!-- Actions -->
                  <div class="border-t border-gray-100 px-6 py-4 bg-gray-50 flex justify-between">
                    <button
                      @click="downloadQrCode"
                      class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
                    >
                      <Download class="w-4 h-4 mr-2" />
                      Télécharger
                    </button>
                    <button
                      @click="printQrCode"
                      class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-black rounded-lg hover:bg-gray-800"
                    >
                      <Printer class="w-4 h-4 mr-2" />
                      Imprimer
                    </button>
                  </div>
                  
                  <!-- Bouton de fermeture -->
                  <button
                    @click="closeQrModal"
                    class="absolute top-4 right-4 text-gray-400 hover:text-gray-500"
                  >
                    <X class="w-5 h-5" />
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

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { QRCodeVue3 } from 'qrcode-vue3'
import { ClipboardCopy, Download, Printer, X } from 'lucide-vue-next'
import { Switch } from '@headlessui/vue'
import html2canvas from 'html2canvas'

const route = useRoute()
const restaurantId = route.params.id
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

// État
const loading = ref(true)
const restaurant = ref(null)
const categories = ref([])
const selectedCategory = ref(null)
const selectedProduct = ref(null)
const showCategoryModal = ref(false)
const showProductModal = ref(false)
const showQrModal = ref(false)
const qrCodeUrl = ref('')

// Formulaires
const categoryForm = ref({
  name: '',
  description: '',
  order: 0
})

const productForm = ref({
  name: '',
  description: '',
  price: 0,
  image_url: '',
  is_available: true,
  category_id: ''
})

// Chargement des données
const loadRestaurant = async () => {
  try {
    loading.value = true
    
    // Charger le restaurant
    const { data: restaurantData, error: restaurantError } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', restaurantId)
      .single()
    
    if (restaurantError) throw restaurantError
    restaurant.value = restaurantData
    
    // Charger les catégories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('menu_categories')
      .select('*')
      .eq('establishment_id', restaurantId)
      .order('order')
    
    if (categoriesError) throw categoriesError
    
    // Charger les produits pour chaque catégorie
    const categoryIds = categoriesData.map(c => c.id)
    
    if (categoryIds.length) {
      const { data: productsData, error: productsError } = await supabase
        .from('menu_items')
        .select('*')
        .in('category_id', categoryIds)
        .order('order')
      
      if (productsError) throw productsError
      
      // Organiser les produits par catégorie
      const productsByCategory = {}
      productsData.forEach(product => {
        if (!productsByCategory[product.category_id]) {
          productsByCategory[product.category_id] = []
        }
        productsByCategory[product.category_id].push(product)
      })
      
      // Associer les produits aux catégories
      categories.value = categoriesData.map(category => ({
        ...category,
        products: productsByCategory[category.id] || []
      }))
    } else {
      categories.value = categoriesData
    }
    
  } catch (error) {
    console.error('Error loading menu:', error)
    showToast.error('Impossible de charger le menu', 'error')
  } finally {
    loading.value = false
  }
}

// Formatage du prix
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: restaurant.value?.currency || 'XOF'
  }).format(price)
}

// Méthodes pour les catégories
const openNewCategoryModal = () => {
  selectedCategory.value = null
  categoryForm.value = {
    name: '',
    description: '',
    order: categories.value.length
  }
  showCategoryModal.value = true
}

const editCategory = (category) => {
  selectedCategory.value = category
  categoryForm.value = {
    name: category.name,
    description: category.description || '',
    order: category.order
  }
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  selectedCategory.value = null
}

const handleCategorySubmit = async (formData) => {
  try {
    loading.value = true
    
    const categoryData = {
      name: formData.name,
      description: formData.description,
      order: formData.order,
      establishment_id: restaurantId
    }

    if (selectedCategory.value?.id) {
      const { error } = await supabase
        .from('menu_categories')
        .update(categoryData)
        .eq('id', selectedCategory.value.id)

      if (error) throw error
    } else {
      const { error } = await supabase
        .from('menu_categories')
        .insert(categoryData)

      if (error) throw error
    }

    showToast.success(
      selectedCategory.value ? 'Catégorie modifiée' : 'Catégorie ajoutée',
      'success'
    )
    
    closeCategoryModal()
    await loadRestaurant()
    
  } catch (error) {
    console.error('Error saving category:', error)
    showToast.error("Une erreur s'est produite", 'error')
  } finally {
    loading.value = false
  }
}

const deleteCategory = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette catégorie et tous ses produits ?')) return

  try {
    loading.value = true
    const { error } = await supabase
      .from('menu_categories')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('Catégorie supprimée avec succès', 'success')
    await loadRestaurant()
    
  } catch (error) {
    console.error('Error deleting category:', error)
    showToast.error("Une erreur s'est produite lors de la suppression", 'error')
  } finally {
    loading.value = false
  }
}

// Méthodes pour les produits
const openNewProductModal = (category) => {
  selectedProduct.value = null
  productForm.value = {
    name: '',
    description: '',
    price: 0,
    image_url: '',
    is_available: true,
    category_id: category.id
  }
  showProductModal.value = true
}

const editProduct = (product, category) => {
  selectedProduct.value = product
  productForm.value = {
    name: product.name,
    description: product.description || '',
    price: product.price,
    image_url: product.image_url || '',
    is_available: product.is_available,
    category_id: product.category_id
  }
  showProductModal.value = true
}

const closeProductModal = () => {
  showProductModal.value = false
  selectedProduct.value = null
}

const handleProductSubmit = async (formData) => {
  try {
    loading.value = true
    
    const productData = {
      name: formData.name,
      description: formData.description,
      price: formData.price,
      image_url: formData.image_url,
      is_available: formData.is_available,
      category_id: formData.category_id
    }

    if (selectedProduct.value?.id) {
      const { error } = await supabase
        .from('menu_items')
        .update(productData)
        .eq('id', selectedProduct.value.id)

      if (error) throw error
    } else {
      // Déterminer l'ordre du nouveau produit
      const { data, error: countError } = await supabase
        .from('menu_items')
        .select('id', { count: 'exact' })
        .eq('category_id', formData.category_id)
      
      if (countError) throw countError
      
      productData.order = data.length
      
      const { error } = await supabase
        .from('menu_items')
        .insert(productData)

      if (error) throw error
    }

    showToast.success(
      selectedProduct.value ? 'Produit modifié' : 'Produit ajouté',
      'success'
    )
    
    closeProductModal()
    await loadRestaurant()
    
  } catch (error) {
    console.error('Error saving product:', error)
    showToast.error("Une erreur s'est produite", 'error')
  } finally {
    loading.value = false
  }
}

const deleteProduct = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return

  try {
    loading.value = true
    const { error } = await supabase
      .from('menu_items')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('Produit supprimé avec succès', 'success')
    await loadRestaurant()
    
  } catch (error) {
    console.error('Error deleting product:', error)
    showToast.error("Une erreur s'est produite lors de la suppression", 'error')
  } finally {
    loading.value = false
  }
}

const toggleProductAvailability = async (product) => {
  try {
    loading.value = true
    const { error } = await supabase
      .from('menu_items')
      .update({ is_available: !product.is_available })
      .eq('id', product.id)

    if (error) throw error

    showToast.success(
      `Produit ${product.is_available ? 'masqué' : 'affiché'} avec succès`,
      'success'
    )
    await loadRestaurant()
  } catch (error) {
    console.error('Error toggling product availability:', error)
    showToast.error("Une erreur s'est produite", 'error')
  } finally {
    loading.value = false
  }
}

// Méthode pour obtenir le symbole de la devise
const getCurrencySymbol = () => {
  const currency = restaurant.value?.currency || 'XOF'
  const formatter = new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: currency,
    currencyDisplay: 'symbol'
  })
  return formatter.format(0).replace(/[0-9.,]/g, '').trim()
}

// Méthodes pour le QR code
const manageQrCodes = (restaurant) => {
  qrCodeUrl.value = `${window.location.origin}/menu/${restaurant.slug}`
  showQrModal.value = true
}

const closeQrModal = () => {
  showQrModal.value = false
}

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    showToast.success('URL copiée dans le presse-papier', 'success')
  } catch (err) {
    console.error('Erreur lors de la copie :', err)
    showToast.error('Impossible de copier l\'URL', 'error')
  }
}

const downloadQrCode = async () => {
  try {
    const qrElement = document.querySelector('.qrcode-vue3')
    if (!qrElement) return
    
    const canvas = await html2canvas(qrElement)
    const dataUrl = canvas.toDataURL('image/png')
    
    const link = document.createElement('a')
    link.href = dataUrl
    link.download = `qrcode-${restaurant.value.slug}.png`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    showToast.success('QR code téléchargé', 'success')
  } catch (err) {
    console.error('Erreur lors du téléchargement :', err)
    showToast.error('Impossible de télécharger le QR code', 'error')
  }
}

const printQrCode = async () => {
  try {
    const qrElement = document.querySelector('.qrcode-vue3')
    if (!qrElement) return
    
    const canvas = await html2canvas(qrElement)
    const dataUrl = canvas.toDataURL('image/png')
    
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      showToast.error('Veuillez autoriser les popups pour imprimer', 'error')
      return
    }
    
    printWindow.document.write(`
      <html>
        <head>
          <title>QR Code - ${restaurant.value.name}</title>
          <style>
            body {
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              height: 100vh;
              margin: 0;
              font-family: system-ui, -apple-system, sans-serif;
            }
            .container {
              text-align: center;
            }
            h1 {
              font-size: 24px;
              margin-bottom: 8px;
            }
            p {
              font-size: 14px;
              color: #666;
              margin-bottom: 24px;
            }
            img {
              max-width: 300px;
              border: 1px solid #eee;
              border-radius: 12px;
              padding: 16px;
            }
            .url {
              margin-top: 16px;
              font-size: 12px;
              color: #666;
            }
          </style>
        </head>
        <body onload="window.print(); window.close();">
          <div class="container">
            <h1>${restaurant.value.name}</h1>
            <p>Scannez ce QR code pour accéder au menu</p>
            <img src="${dataUrl}" alt="QR Code" />
            <div class="url">${qrCodeUrl.value}</div>
          </div>
        </body>
      </html>
    `)
    printWindow.document.close()
  } catch (err) {
    console.error('Erreur lors de l\'impression :', err)
    showToast.error('Impossible d\'imprimer le QR code', 'error')
  }
}

// Initialisation
onMounted(() => {
  loadRestaurant()
})

definePageMeta({
  layout: 'admin'
})
</script> 