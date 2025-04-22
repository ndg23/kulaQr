<template>
  <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Menu</h1>
        <p class="mt-1 text-sm text-gray-500">Gérez les produits de votre établissement</p>
      </div>
      <button
        @click="openAddProduct"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Nouveau produit
      </button>
    </div>

    <!-- Quick Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
      <div v-for="stat in quickStats" :key="stat.name"
        class="bg-white p-4 rounded-xl border border-gray-100"
      >
        <div class="flex items-center">
          <div class="w-10 h-10 rounded-lg flex items-center justify-center"
            :class="stat.iconBg"
          >
            <component :is="stat.icon" class="w-5 h-5" :class="stat.iconColor" />
          </div>
          <div class="ml-3">
            <p class="text-sm text-gray-500">{{ stat.name }}</p>
            <p class="text-lg font-semibold text-gray-900">{{ stat.value }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Category Pills -->
    <div class="flex gap-2 overflow-x-auto pb-2 mb-6 scrollbar-hide">
      <button
        v-for="category in categories"
        :key="category.id"
        @click="activeCategory = category.id"
        class="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200"
        :class="[
          activeCategory === category.id
            ? 'bg-blue-500 text-white shadow-sm'
            : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
        ]"
      >
        {{ category.name }}
      </button>
    </div>

    <!-- Products Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <div v-for="product in filteredProducts" :key="product.id"
        class="bg-white rounded-xl border border-gray-100 overflow-hidden group hover:shadow-sm transition-all"
      >
        <!-- Product Image -->
        <div class="aspect-square w-full bg-gray-50 relative">
          <img
            v-if="product.image_url"
            :src="product.image_url"
            :alt="product.name"
            class="w-full h-full object-cover"
          />
          <div v-else class="w-full h-full flex items-center justify-center">
            <UtensilsCrossed class="w-6 h-6 text-gray-300" />
          </div>
          
          <!-- Quick Actions Overlay -->
          <div class="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <div class="flex items-center space-x-1">
              <button 
                @click="editProduct(product)"
                class="p-1.5 text-white hover:text-gray-200 rounded-lg hover:bg-white/10"
              >
                <Edit2 class="w-4 h-4" />
              </button>
              <Switch
                v-model="product.is_available"
                @change="toggleAvailability(product)"
                class="relative inline-flex h-5 w-9"
              >
                <span class="sr-only">Disponibilité</span>
                <div 
                  :class="[
                    product.is_available ? 'bg-green-400' : 'bg-gray-200',
                    'relative inline-flex h-5 w-9 flex-shrink-0 rounded-full transition-colors duration-200'
                  ]"
                >
                  <span
                    :class="[
                      product.is_available ? 'translate-x-4' : 'translate-x-1',
                      'inline-block h-3 w-3 transform rounded-full bg-white shadow transition duration-200 ease-in-out mt-1'
                    ]"
                  />
                </div>
              </Switch>
            </div>
          </div>
        </div>

        <!-- Product Info -->
        <div class="p-3">
          <div class="flex items-start justify-between">
            <div>
              <h3 class="font-medium text-gray-900">{{ product.name }}</h3>
              <p class="text-sm text-gray-500 mt-0.5 line-clamp-2">{{ product.description }}</p>
            </div>
            <span class="text-sm font-semibold text-gray-900">{{ formatPrice(product.price) }}</span>
          </div>
          
          <div class="mt-2 flex items-center justify-between">
            <span 
              class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
              :class="{
                'bg-green-50 text-green-700': product.is_available,
                'bg-gray-50 text-gray-600': !product.is_available
              }"
            >
              {{ product.is_available ? 'Disponible' : 'Indisponible' }}
            </span>
            <button
              @click="deleteProduct(product.id)"
              class="p-1 text-gray-400 hover:text-red-500 rounded-lg hover:bg-red-50"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        </div>
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
import { ref, computed } from 'vue'
import { Switch, TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  Plus, UtensilsCrossed, Edit2, Trash2,
  Coffee, Pizza, Store, TrendingUp, IceCream
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'
import ProductModal from '~/components/modals/ProductModal.vue'

const { client: supabase, withLoading } = useSupabaseWrapper()
const toast = useToast()
const route = useRoute()
const slug = route.params.slug

// State
const showAddProduct = ref(false)
const editingProduct = ref(null)
const activeCategory = ref(null)
const categories = ref([])
const products = ref([])

// Mock Data
const mockCategories = [
  {
    id: 1,
    name: 'Entrées',
    icon: Coffee,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500'
  },
  {
    id: 2,
    name: 'Plats',
    icon: UtensilsCrossed,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500'
  },
  {
    id: 3,
    name: 'Desserts',
    icon: IceCream,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500'
  },
  {
    id: 4,
    name: 'Boissons',
    icon: Coffee,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500'
  }
]

const mockProducts = [
  {
    id: 1,
    name: 'Salade César',
    description: 'Laitue romaine, croûtons maison, parmesan, sauce césar',
    price: 12.90,
    category_id: 1,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9'
  },
  {
    id: 2,
    name: 'Soupe à l\'oignon',
    description: 'Oignons caramélisés, bouillon maison, croûtons gratinés',
    price: 9.90,
    category_id: 1,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1547592166-23ac45744acd'
  },
  {
    id: 3,
    name: 'Steak Frites',
    description: 'Steak de bœuf, frites maison, sauce au poivre',
    price: 24.90,
    category_id: 2,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1600891964092-4316c288032e'
  },
  {
    id: 4,
    name: 'Saumon grillé',
    description: 'Saumon frais, légumes de saison, sauce hollandaise',
    price: 26.90,
    category_id: 2,
    is_available: false,
    image_url: 'https://images.unsplash.com/photo-1485921325833-c519f76c4927'
  },
  {
    id: 5,
    name: 'Crème brûlée',
    description: 'Crème vanille, caramel croustillant',
    price: 8.90,
    category_id: 3,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1470324161839-ce2bb6fa6bc3'
  },
  {
    id: 6,
    name: 'Tarte au citron meringuée',
    description: 'Crème citron, meringue italienne',
    price: 9.90,
    category_id: 3,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81'
  },
  {
    id: 7,
    name: 'Vin rouge - Bordeaux',
    description: 'Château Margaux 2018',
    price: 45.00,
    category_id: 4,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3'
  },
  {
    id: 8,
    name: 'Mojito',
    description: 'Rhum, menthe fraîche, citron vert, sucre de canne',
    price: 12.00,
    category_id: 4,
    is_available: true,
    image_url: 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a'
  }
]

// Computed
const filteredProducts = computed(() => {
  let filtered = products.value
  if (activeCategory.value) {
    filtered = filtered.filter(p => p.category_id === activeCategory.value)
  }
  return filtered
})

// Methods
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price)
}

const loadData = async () => {
  // Simuler un délai de chargement
  await new Promise(resolve => setTimeout(resolve, 5000))
  
  categories.value = mockCategories
  products.value = mockProducts
  
  // Définir la première catégorie comme active par défaut
  if (mockCategories.length > 0) {
    activeCategory.value = mockCategories[0].id
  }
}

const toggleAvailability = async (product: any) => {
  // Simuler la mise à jour
  const index = products.value.findIndex(p => p.id === product.id)
  if (index !== -1) {
    products.value[index].is_available = product.is_available
    toast.success('Disponibilité mise à jour', 'Le statut du produit a été modifié')
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
  // Simuler la sauvegarde
  if (editingProduct.value?.id) {
    const index = products.value.findIndex(p => p.id === editingProduct.value?.id)
    if (index !== -1) {
      products.value[index] = { ...products.value[index], ...productData }
    }
  } else {
    products.value.push({
      id: Math.max(...products.value.map(p => p.id)) + 1,
      ...productData,
      is_available: true
    })
  }
  
  closeModal()
  toast.success(
    'Produit sauvegardé',
    editingProduct.value?.id ? 'Modifications enregistrées' : 'Nouveau produit ajouté'
  )
}

const deleteProduct = async (id: string) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) {
    const index = products.value.findIndex(p => p.id === id)
    if (index !== -1) {
      products.value.splice(index, 1)
      toast.success('Produit supprimé', 'Le produit a été supprimé')
    }
  }
}

const openAddProduct = () => {
  editingProduct.value = null
  showAddProduct.value = true
}

// Initial load
onMounted(loadData)

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style> 