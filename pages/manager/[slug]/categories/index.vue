<template>
  <div class="space-y-4 sm:space-y-6">
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

    <!-- La grande carte : le nombre de catégories et ce qu'elles contiennent -->
    <HeroCard
      label="Catégories"
      :value="categories.length"
      :hint="`${products.length} produit${products.length > 1 ? 's' : ''} au total`"
      :icon="List"
      :chips="[
        { label: 'Avec produits', value: quickStats[2].value },
        { label: 'Moy. par catégorie', value: quickStats[3].value }
      ]"
    />

    <main class="space-y-4">
      <!-- Recherche -->
      <div class="relative max-w-md">
        <Search class="w-5 h-5 text-gray-400 absolute left-5 top-1/2 -translate-y-1/2" />
        <input
          v-model="searchQuery"
          type="search"
          placeholder="Rechercher une catégorie"
          class="w-full h-12 pl-12 pr-5 rounded-full bg-gray-100 border-0 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-black"
        />
      </div>

      <!-- Chargement -->
      <div v-if="loading" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4" aria-busy="true">
        <div v-for="i in 8" :key="i" class="rounded-[2rem] bg-gray-100 animate-pulse" style="aspect-ratio: 4 / 5"></div>
      </div>

      <!-- Vide -->
      <div v-else-if="filteredCategories.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
        <UtensilsCrossed class="w-10 h-10 text-gray-400 mx-auto" />
        <h3 class="mt-3 text-lg font-black text-gray-900">
          {{ categories.length === 0 ? 'Commencez votre menu' : 'Aucune catégorie trouvée' }}
        </h3>
        <p class="mt-1 text-sm font-semibold text-gray-500 max-w-md mx-auto">
          {{ categories.length === 0
            ? 'Créez des catégories pour organiser vos produits et faciliter la navigation de vos clients.'
            : 'Aucune catégorie ne correspond à votre recherche.' }}
        </p>
        <button
          v-if="categories.length === 0"
          type="button"
          class="mt-5 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
          @click="openCategoryModal"
        >Créer votre première catégorie</button>
      </div>

      <!-- Cartes -->
      <div v-else class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
        <article
          v-for="category in filteredCategories"
          :key="category.id"
          class="rounded-[2rem] bg-gray-100 overflow-hidden"
        >
          <div class="relative overflow-hidden" style="aspect-ratio: 4 / 3">
            <img
              v-if="category.image_url && !category.imageError"
              :src="category.image_url"
              :alt="category.name"
              class="absolute inset-0 w-full h-full object-cover"
              @error="handleImageError(category)"
              @load="handleImageLoad(category)"
            />
            <span v-else class="absolute inset-0 flex items-center justify-center bg-[#FB6A00] text-black">
              <component :is="getCategoryIcon(category)" class="w-12 h-12" :stroke-width="2.25" />
            </span>

            <button
              type="button"
              :aria-label="`Modifier ${category.name}`"
              class="absolute top-3 right-3 w-10 h-10 rounded-full bg-black text-white flex items-center justify-center active:scale-[0.92] transition-all"
              @click="editCategory(category)"
            >
              <Edit2 class="w-4 h-4" :stroke-width="2.5" />
            </button>
          </div>

          <div class="p-4 flex items-center gap-3">
            <div class="min-w-0 flex-1">
              <h3 class="font-black text-gray-900 leading-tight truncate">{{ category.name }}</h3>
              <span class="mt-1.5 inline-flex items-center h-7 px-3 rounded-full bg-white text-xs font-extrabold text-gray-900">
                {{ getProductCount(category.id) }} produit{{ getProductCount(category.id) > 1 ? 's' : '' }}
              </span>
            </div>
            <button
              type="button"
              :aria-label="`Supprimer ${category.name}`"
              class="w-10 h-10 flex-shrink-0 rounded-full bg-white text-gray-500 hover:text-[#C54E00] flex items-center justify-center active:scale-[0.92] transition-all"
              @click="deleteCategory(category.id)"
            >
              <X class="w-5 h-5" :stroke-width="2.5" />
            </button>
          </div>
        </article>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import HeroCard from '~/components/ui/HeroCard.vue'
import { ref, computed, onMounted, watch } from 'vue'
import {
  Plus, Edit2, Trash2, UtensilsCrossed,
  X,
  Coffee, Pizza, IceCream, Wine, Beer, Loader2,
  ImageIcon, Search, ArrowUpDown, Upload, Download,
  ArrowRight, List, TrendingUp
} from 'lucide-vue-next'
// import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'
import type { Category, Product } from '~/types'
import { useCustomToast } from '~/composables/useToast'
// import { useSupabaseClient } from '@supabase/supabase-js'
const {showToast} = useCustomToast()
const route = useRoute()
const slug = route.params.slug
const supabase = useSupabaseClient()
const { establishment } = useEstablishment()

// State
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
  if (name.includes('image') || name.includes('photo')) return ImageIcon
  if (name.includes('autre')) return UtensilsCrossed
  
  return category.icon || UtensilsCrossed
}

const openCategoryModal = () => navigateTo(`/manager/${slug}/categories/new`)

const editCategory = (category: Category) => navigateTo(`/manager/${slug}/categories/${category.id}/edit`)

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
    
    showToast.success('Catégorie supprimée', 'La catégorie a été supprimé avec succès')
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
    // console.log('🔄 Restaurant categories:', newSlug)
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
      name: 'Nombre de Catégories',
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
