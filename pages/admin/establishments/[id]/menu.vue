<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <div class="flex items-center space-x-4 mb-3">
        <NuxtLink 
          :to="`/admin/restaurants/${restaurantId}`"
          class="p-2 text-gray-500 hover:text-gray-700 rounded-2xl hover:bg-gray-100 transition-all"
        >
          <ArrowLeft class="w-6 h-6" />
        </NuxtLink>
        <div>
          <h1 class="text-4xl font-bold text-gray-900">Menu</h1>
          <p class="text-lg text-gray-600 mt-1">Gérez les produits de votre restaurant</p>
        </div>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
      <div v-for="stat in stats" :key="stat.name" 
        class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all hover:scale-[1.02] hover:shadow-lg"
      >
        <div class="flex items-center space-x-6">
          <div class="w-16 h-16 rounded-2xl flex items-center justify-center"
            :class="stat.iconBg"
          >
            <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
          </div>
          <div>
            <p class="text-base text-gray-500 mb-1">{{ stat.name }}</p>
            <h3 class="text-3xl font-bold text-gray-900">{{ stat.value }}</h3>
          </div>
        </div>
      </div>
    </div>

    <!-- Categories and Products -->
    <div class="space-y-8">
      <div v-for="category in categories" :key="category.id"
        class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm"
      >
        <!-- Category Header -->
        <div class="p-8 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center">
                <component :is="category.icon" class="w-6 h-6 text-orange-500" />
              </div>
              <div>
                <h2 class="text-2xl font-semibold text-gray-900">{{ category.name }}</h2>
                <p class="text-sm text-gray-500">{{ category.products.length }} produits</p>
              </div>
            </div>
            <div class="flex items-center space-x-3">
              <button 
                @click="editCategory(category)"
                class="p-2 text-gray-500 hover:text-gray-700 rounded-xl hover:bg-gray-100"
              >
                <Edit2 class="w-5 h-5" />
              </button>
              <button 
                @click="openNewProductModal(category)"
                class="inline-flex items-center px-6 py-3 bg-black text-white rounded-2xl text-base font-medium transition-colors hover:bg-gray-900"
              >
                <Plus class="w-5 h-5 mr-2" />
                Ajouter
              </button>
            </div>
          </div>
        </div>

        <!-- Products Grid -->
        <div class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div v-for="product in category.products" :key="product.id"
              class="group relative bg-white rounded-2xl border border-gray-100 overflow-hidden hover:border-gray-200 hover:shadow-sm transition-all"
            >
              <!-- Product Image -->
              <div class="aspect-square w-full bg-gray-100 relative overflow-hidden">
                <img 
                  v-if="product.image"
                  :src="product.image"
                  :alt="product.name"
                  class="w-full h-full object-cover"
                />
                <div v-else class="w-full h-full flex items-center justify-center">
                  <UtensilsCrossed class="w-8 h-8 text-gray-400" />
                </div>
                <!-- Hover Actions -->
                <div class="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <div class="flex items-center space-x-2">
                    <button 
                      @click="editProduct(product)"
                      class="p-2 text-white hover:text-gray-200 rounded-xl hover:bg-white/10"
                    >
                      <Edit2 class="w-5 h-5" />
                    </button>
                    <button 
                      @click="deleteProduct(product.id)"
                      class="p-2 text-white hover:text-red-400 rounded-xl hover:bg-white/10"
                    >
                      <Trash2 class="w-5 h-5" />
                    </button>
                  </div>
                </div>
              </div>

              <!-- Product Info -->
              <div class="p-4">
                <h3 class="text-lg font-semibold text-gray-900">{{ product.name }}</h3>
                <p class="text-sm text-gray-500 mt-1 line-clamp-2">{{ product.description }}</p>
                <div class="flex items-center justify-between mt-3">
                  <span class="text-xl font-bold text-gray-900">{{ product.price }}</span>
                  <span 
                    class="inline-flex items-center px-2.5 py-1 rounded-xl text-xs font-medium"
                    :class="{
                      'bg-green-50 text-green-700': product.available,
                      'bg-red-50 text-red-700': !product.available
                    }"
                  >
                    {{ product.available ? 'Disponible' : 'Indisponible' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Product Modal -->
    <ProductModal 
      v-if="showProductModal"
      :show="showProductModal"
      :product="selectedProduct"
      :category="selectedCategory"
      @close="closeProductModal"
      @submit="handleProductSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import {
  ArrowLeft, UtensilsCrossed, Coffee, Pizza,
  Sandwich, IceCream, Plus, Edit2, Trash2
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'

const { showToast } = useCustomToast()
const route = useRoute()
const restaurantId = route.params.id

const showProductModal = ref(false)
const selectedProduct = ref(null)
const selectedCategory = ref(null)

// Stats data
const stats = [
  {
    name: 'Total produits',
    value: '48',
    icon: UtensilsCrossed,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500'
  },
  {
    name: 'Catégories',
    value: '6',
    icon: Coffee,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500'
  },
  {
    name: 'Produits actifs',
    value: '42',
    icon: Pizza,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  }
]

// Sample categories and products
const categories = ref([
  {
    id: 1,
    name: 'Entrées',
    icon: Sandwich,
    products: [
      {
        id: 1,
        name: 'Salade César',
        description: 'Laitue romaine, croûtons, parmesan, sauce césar maison',
        price: 12.90,
        available: true,
        image: null
      },
      {
        id: 2,
        name: 'Soupe à l\'oignon',
        description: 'Oignons caramélisés, croûtons gratinés au fromage',
        price: 9.90,
        available: true,
        image: null
      }
    ]
  },
  {
    id: 2,
    name: 'Desserts',
    icon: IceCream,
    products: [
      {
        id: 3,
        name: 'Crème brûlée',
        description: 'Crème vanille, caramel croustillant',
        price: 8.90,
        available: true,
        image: null
      }
    ]
  }
])

// Methods
const openNewProductModal = (category: any) => {
  selectedProduct.value = null
  selectedCategory.value = category
  showProductModal.value = true
}

const editProduct = (product: any) => {
  selectedProduct.value = product
  showProductModal.value = true
}

const closeProductModal = () => {
  showProductModal.value = false
  selectedProduct.value = null
  selectedCategory.value = null
}

const handleProductSubmit = async (productData: any) => {
  try {
    // Logique de création/modification
    showToast.success(
      selectedProduct.value ? 'Produit modifié' : 'Produit créé',
      selectedProduct.value ? 'Les modifications ont été enregistrées' : 'Le nouveau produit a été créé'
    )
    closeProductModal()
  } catch (error) {
    showToast.error('Erreur', "Une erreur s'est produite")
  }
}

const deleteProduct = async (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) {
    try {
      // Logique de suppression
      showToast.success('Produit supprimé', 'Le produit a été supprimé avec succès')
    } catch (error) {
      showToast.error('Erreur', "Une erreur s'est produite lors de la suppression")
    }
  }
}

const editCategory = (category: any) => {
  // Implémenter la logique d'édition de catégorie
}

definePageMeta({
  layout: 'admin'
})
</script> 