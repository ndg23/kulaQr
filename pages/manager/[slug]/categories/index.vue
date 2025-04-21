<template>
  <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Catégories</h1>
        <p class="mt-1 text-sm text-gray-500">Gérez les catégories de votre menu</p>
      </div>
      <button
        @click="openNewCategory"
        class="inline-flex items-center px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Nouvelle catégorie
      </button>
    </div>

    <!-- Categories Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="category in categories" :key="category.id"
        class="bg-white rounded-xl border border-gray-100 overflow-hidden group hover:shadow-sm transition-all"
      >
        <div class="p-6">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center space-x-3">
              <div class="w-12 h-12 rounded-xl flex items-center justify-center"
                :class="category.iconBg"
              >
                <component :is="category.icon" class="w-6 h-6" :class="category.iconColor" />
              </div>
              <div>
                <h3 class="font-medium text-gray-900">{{ category.name }}</h3>
                <p class="text-sm text-gray-500">{{ getProductCount(category.id) }} produits</p>
              </div>
            </div>
            <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
              <button 
                @click="editCategory(category)"
                class="p-1.5 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-50"
              >
                <Edit2 class="w-4 h-4" />
              </button>
              <button
                @click="deleteCategory(category.id)"
                class="p-1.5 text-gray-400 hover:text-red-500 rounded-lg hover:bg-red-50"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>

          <!-- Products List -->
          <div class="space-y-2">
            <div v-for="product in getCategoryProducts(category.id)" :key="product.id"
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
                <span class="text-sm text-gray-600">{{ product.name }}</span>
              </div>
              <span class="text-sm font-medium text-gray-900">{{ formatPrice(product.price) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Category Modal -->
    <CategoryModal
      v-if="showCategoryModal"
      :show="showCategoryModal"
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
  Coffee, Pizza, IceCream, Wine, Beer
} from 'lucide-vue-next'
import { useToast } from '~/composables/useToast'

const toast = useToast()
const route = useRoute()
const slug = route.params.slug
const supabase = useSupabaseClient()
// Mock Data
const mockCategories = [
  {
    id: '1', // UUID simulé
    created_at: new Date().toISOString(),
    establishment_id: slug,
    name: 'Entrées',
    order_number: 1,
    // Métadonnées UI (non stockées en DB)
    icon: UtensilsCrossed,
    iconBg: 'bg-orange-50',
    iconColor: 'text-orange-500',
    description: 'Nos entrées fraîches et savoureuses'
  },
  {
    id: '2',
    created_at: new Date().toISOString(),
    establishment_id: slug,
    name: 'Plats',
    order_number: 2,
    icon: Pizza,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500',
    description: 'Plats principaux et spécialités'
  },
  {
    id: '3',
    created_at: new Date().toISOString(),
    establishment_id: slug,
    name: 'Desserts',
    order_number: 3,
    icon: IceCream,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500',
    description: 'Desserts maison et pâtisseries'
  },
  {
    id: '4',
    created_at: new Date().toISOString(),
    establishment_id: slug,
    name: 'Boissons',
    order_number: 4,
    icon: Coffee,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500',
    description: 'Boissons chaudes et froides'
  }
]

const mockProducts = [
  {
    id: '1',
    created_at: new Date().toISOString(),
    category_id: '1',
    name: 'Salade César',
    description: 'Laitue romaine, croûtons maison, parmesan, sauce césar',
    price: 12.90,
    image_url: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9',
    is_available: true,
    order_number: 1
  },
  {
    id: '2',
    created_at: new Date().toISOString(),
    category_id: '1',
    name: 'Soupe à l\'oignon',
    description: 'Oignons caramélisés, bouillon maison, croûtons gratinés',
    price: 9.90,
    image_url: 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
    is_available: true,
    order_number: 2
  },
  {
    id: '3',
    created_at: new Date().toISOString(),
    category_id: '2',
    name: 'Pizza Margherita',
    description: 'Sauce tomate, mozzarella, basilic frais',
    price: 14.90,
    image_url: 'https://images.unsplash.com/photo-1600891964092-4316c288032e',
    is_available: true,
    order_number: 1
  },
  {
    id: '4',
    created_at: new Date().toISOString(),
    category_id: '3',
    name: 'Crème brûlée',
    description: 'Crème vanille, caramel croustillant',
    price: 8.90,
    image_url: 'https://images.unsplash.com/photo-1470324161839-ce2bb6fa6bc3',
    is_available: true,
    order_number: 1
  },
  {
    id: '5',
    created_at: new Date().toISOString(),
    category_id: '4',
    name: 'Café expresso',
    description: 'Café 100% arabica',
    price: 2.50,
    image_url: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
    is_available: true,
    order_number: 1
  }
]

// State
const showCategoryModal = ref(false)
const editingCategory = ref(null)
const categories = ref(mockCategories)
const products = ref(mockProducts)

// Methods
const getProductCount = (categoryId: string) => {
  return products.value.filter(p => p.category_id === categoryId).length
}

const getCategoryProducts = (categoryId: string) => {
  return products.value.filter(p => p.category_id === categoryId)
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price)
}

const openNewCategory = () => {
  editingCategory.value = null
  showCategoryModal.value = true
}

const editCategory = (category: any) => {
  editingCategory.value = { ...category }
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  editingCategory.value = null
}

const saveCategory = async (categoryData: Partial<Category>) => {
  try {
    if (editingCategory.value?.id) {
      const { data, error } = await supabase
        .from('categories')
        .update({
          name: categoryData.name,
          order_number: categoryData.order_number
        })
        .eq('id', editingCategory.value.id)
        .select()
        .single()

      if (error) throw error
      
      // Mise à jour locale
      const index = categories.value.findIndex(c => c.id === editingCategory.value?.id)
      if (index !== -1) {
        categories.value[index] = {
          ...categories.value[index],
          ...data,
          icon: categoryData.icon, // Garder les métadonnées UI
          iconBg: categoryData.iconBg,
          iconColor: categoryData.iconColor
        }
      }
    } else {
      const { data, error } = await supabase
        .from('categories')
        .insert({
          establishment_id: slug,
          name: categoryData.name,
          order_number: categories.value.length + 1
        })
        .select()
        .single()

      if (error) throw error

      // Ajout local
      categories.value.push({
        ...data,
        icon: categoryData.icon,
        iconBg: 'bg-blue-50',
        iconColor: 'text-blue-500'
      })
    }
    
    closeCategoryModal()
    toast.success(
      'Catégorie sauvegardée',
      editingCategory.value?.id ? 'Modifications enregistrées' : 'Nouvelle catégorie ajoutée'
    )
  } catch (error) {
    console.error('Error saving category:', error)
    toast.error('Erreur', "Une erreur s'est produite lors de la sauvegarde")
  }
}

const deleteCategory = async (id: string) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) {
    try {
      const { error } = await supabase
        .from('categories')
        .delete()
        .eq('id', id)

      if (error) throw error

      // Suppression locale
      categories.value = categories.value.filter(c => c.id !== id)
      toast.success('Catégorie supprimée', 'La catégorie a été supprimée')
    } catch (error) {
      console.error('Error deleting category:', error)
      toast.error('Erreur', "Une erreur s'est produite lors de la suppression")
    }
  }
}

// Chargement initial des données
const loadData = async () => {
  try {
    // Charger les catégories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select()
      .eq('establishment_id', slug)
      .order('order_number')

    if (categoriesError) throw categoriesError

    // Charger les produits
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select(`
        *,
        category:categories(id)
      `)
      .in('category_id', categoriesData.map(c => c.id))
      .order('order_number')

    if (productsError) throw productsError

    // Assigner les données avec les métadonnées UI
    categories.value = categoriesData.map(category => ({
      ...category,
      icon: getIconForCategory(category.name),
      iconBg: getIconBgForCategory(category.name),
      iconColor: getIconColorForCategory(category.name)
    }))
    products.value = productsData
  } catch (error) {
    console.error('Error loading data:', error)
    toast.error('Erreur', "Une erreur s'est produite lors du chargement des données")
  }
}

// Helper pour assigner les icônes en fonction du nom de la catégorie
const getIconForCategory = (name: string) => {
  const lowercaseName = name.toLowerCase()
  if (lowercaseName.includes('entrée')) return UtensilsCrossed
  if (lowercaseName.includes('plat')) return Pizza
  if (lowercaseName.includes('dessert')) return IceCream
  if (lowercaseName.includes('boisson')) return Coffee
  return UtensilsCrossed
}

onMounted(loadData)

definePageMeta({
  layout: 'manager'
})
</script> 