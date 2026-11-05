<template>
  <div class="space-y-4 sm:space-y-6">
    <ManagerModernHeader
      title="Menu"
      subtitle="Gérez vos produits et catégories"
      :icon="MenuIcon"
      :primary-action="{
        label: 'Ajouter',
        icon: Plus,
        action: openAddProduct
      }"
    />

    <!-- La grande carte : les produits du menu -->
    <HeroCard
      label="Produits"
      :value="products.length"
      :hint="`${categories.length} catégorie${categories.length > 1 ? 's' : ''}`"
      :icon="UtensilsCrossed"
      :chips="[
        { label: 'Actifs', value: quickStats[2].value },
        { label: 'Prix moyen', value: quickStats[3].value }
      ]"
    />

    <main class="space-y-4">
      <!-- Recherche et catégories -->
      <div class="relative max-w-md">
        <Search class="w-5 h-5 text-gray-400 absolute left-5 top-1/2 -translate-y-1/2" />
        <input
          v-model="search"
          type="search"
          placeholder="Rechercher un produit"
          class="w-full h-12 pl-12 pr-5 rounded-full bg-gray-100 border-0 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-black"
          @input="handleSearch"
        />
      </div>

      <div v-if="categories.length" class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide" role="tablist" aria-label="Catégories">
        <button
          type="button"
          role="tab"
          :aria-selected="activeCategory === 'all'"
          class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
          :class="activeCategory === 'all' ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
          @click="activeCategory = 'all'"
        >Tout</button>
        <button
          v-for="category in categories"
          :key="category.id"
          type="button"
          role="tab"
          :aria-selected="activeCategory === category.id"
          class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
          :class="activeCategory === category.id ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
          @click="activeCategory = category.id"
        >{{ category.name }}</button>
      </div>

      <!-- Chargement -->
      <div v-if="loading" class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3 sm:gap-4" aria-busy="true">
        <div v-for="i in 8" :key="i" class="rounded-[2rem] bg-gray-100 animate-pulse" style="aspect-ratio: 4 / 5"></div>
      </div>

      <!-- Vide -->
      <div v-else-if="filteredProducts.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
        <Search class="w-10 h-10 text-gray-400 mx-auto" />
        <h3 class="mt-3 text-lg font-black text-gray-900">Aucun produit trouvé</h3>
        <p class="mt-1 text-sm font-semibold text-gray-500">
          {{ search ? 'Aucun produit ne correspond à votre recherche.' : 'Aucun produit dans cette catégorie.' }}
        </p>
        <button
          type="button"
          class="mt-5 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
          @click="openAddProduct"
        >Ajouter un produit</button>
      </div>

      <!-- Produits -->
      <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3 sm:gap-4">
        <article
          v-for="product in filteredProducts"
          :key="product.id"
          class="rounded-[2rem] bg-gray-100 overflow-hidden flex flex-col"
          :class="product.is_available ? '' : 'opacity-70'"
        >
          <div class="relative bg-white" style="aspect-ratio: 4 / 3">
            <img
              :src="product.image_url || '/images/product-empty.png'"
              :alt="product.name"
              class="absolute inset-0 w-full h-full object-contain"
            />
            <span
              class="absolute top-3 left-3 inline-flex items-center h-7 px-3 rounded-full text-xs font-extrabold"
              :class="product.is_available ? 'bg-black text-white' : 'bg-gray-200 text-gray-700'"
            >{{ product.is_available ? 'Disponible' : 'Indisponible' }}</span>
            <button
              type="button"
              role="switch"
              :aria-checked="product.is_available"
              :aria-label="`Disponibilité de ${product.name}`"
              class="absolute top-3 right-3 inline-flex h-[31px] w-[51px] items-center rounded-full transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-black focus:ring-offset-2"
              :class="product.is_available ? 'bg-[#FB6A00]' : 'bg-gray-300'"
              @click="updateAvailability(product, !product.is_available)"
            >
              <span
                class="inline-block h-[27px] w-[27px] transform rounded-full bg-white shadow transition-transform duration-200"
                :class="product.is_available ? 'translate-x-[22px]' : 'translate-x-[2px]'"
              />
            </button>
          </div>

          <div class="p-4 flex flex-col gap-3 flex-1">
            <div class="flex items-start justify-between gap-2">
              <div class="min-w-0">
                <h3 class="font-black text-gray-900 leading-tight break-words">{{ product.name }}</h3>
                <p class="text-xs font-semibold text-gray-500 truncate">{{ getCategoryName(product.category_id) }}</p>
              </div>
              <span class="inline-flex items-center h-8 px-3 rounded-full bg-[#FB6A00] text-black text-sm font-black tabular-nums flex-shrink-0">{{ formatPrice(product.price) }}</span>
            </div>

            <p v-if="product.description" class="text-sm font-medium text-gray-600 line-clamp-2">{{ product.description }}</p>

            <div class="mt-auto flex gap-2">
              <button
                type="button"
                class="flex-1 h-11 inline-flex items-center justify-center gap-2 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
                @click="editProduct(product)"
              >
                <Pencil class="w-4 h-4" :stroke-width="2.5" /> Modifier
              </button>
              <button
                type="button"
                :aria-label="`Supprimer ${product.name}`"
                class="w-11 h-11 flex-shrink-0 inline-flex items-center justify-center rounded-full bg-white text-gray-500 hover:text-[#C54E00] active:scale-[0.92] transition-all"
                @click="confirmDeleteProduct(product)"
              >
                <Trash2 class="w-4 h-4" :stroke-width="2.5" />
              </button>
            </div>
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
  Plus, UtensilsCrossed, Store, TrendingUp, Search, Pencil, List, Menu as MenuIcon, Trash2
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { useEstablishment } from '~/composables/useEstablishment'
import Switch from '~/components/ui/Switch.vue'

const route = useRoute()
const slug = route.params.slug
const { client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()
const { establishment } = useEstablishment()

// State
const activeCategory = ref('all')
const categories = ref<any[]>([])
const products = ref<any[]>([])
const loading = ref(true)
const search = ref('')


// Computed
const filteredProducts = computed(() => {
  let filtered = products.value

  // Filter by category
  if (activeCategory.value !== 'all') {
    filtered = filtered.filter((product: any) => product.category_id === activeCategory.value)
  }

  // Filter by search
  if (search.value) {
    const searchLower = search.value.toLowerCase()
    filtered = filtered.filter((product: any) => 
      product.name.toLowerCase().includes(searchLower) ||
      product.description?.toLowerCase().includes(searchLower)
    )
  }

  return filtered
})

// Quick stats
const quickStats = computed(() => {
  const avgPrice = products.value.length
    ? products.value.reduce((sum: any, p: any) => sum + p.price, 0) / products.value.length
    : 0

  return [
    {
      name: 'Produits',
      value: products.value.length,
      icon: UtensilsCrossed
    },
    {
      name: 'Catégories',
      value: categories.value.length,
      icon: List
    },
    {
      name: 'Actifs',
      value: products.value.filter((p: any) => p.is_available).length,
      icon: Store
    },
    {
      name: 'Prix moyen',
      value: avgPrice > 0 ? formatPrice(avgPrice) : '0 F CFA',
      icon: TrendingUp
    }
  ]
})

// Methods
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(price)
}

const handleSearch = () => {
  // Reset category filter when searching
  if (search.value) {
    activeCategory.value = 'all'
  }
}

const getCategoryName = (categoryId: string) => {
  const category = categories.value.find((c: any) => c.id === categoryId) as any
  return category ? category.name : 'Sans catégorie'
}

const loadData = async () => {
  loading.value = true
  try {
    // Load categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', establishment.value?.id)
      .order('name')

    if (categoriesError) throw categoriesError
    categories.value = categoriesData as any[] || []
    
    // Load products directly by establishment_id
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*, category:categories(name)')
      .eq('establishment_id', establishment.value?.id)
      .order('name')

    if (productsError) throw productsError
    products.value = productsData as any[] || []
  } catch (err) {
    console.error('Erreur chargement:', err)
    showToast.error('Erreur', 'Impossible de charger les données')
  } finally {
    loading.value = false
  }
}

const updateAvailability = async (product: any, isAvailable: boolean) => {
  try {
    const { error } = await supabase
      .from('products')
      .update({ is_available: isAvailable })
      .eq('id', product.id)

    if (error) throw error
    
    // Update local state
    product.is_available = isAvailable
    
    showToast.success(
      'Disponibilité mise à jour', 
      `Le produit "${product.name}" est maintenant ${isAvailable ? 'disponible' : 'indisponible'}`
    )
  } catch (err) {
    console.error('Erreur mise à jour:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour la disponibilité')
    // Revert the change
    product.is_available = !isAvailable
  }
}

const editProduct = (product: any) => navigateTo(`/manager/${slug}/menu/${product.id}/edit`)

const confirmDeleteProduct = (product: any) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer le produit "${product.name}" ? Cette action est irréversible.`)) {
    deleteProduct(product)
  }
}

const deleteProduct = async (product: any) => {
  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', product.id)

    if (error) throw error

    // Remove from local state
    const index = products.value.findIndex((p: any) => p.id === product.id)
    if (index !== -1) {
      products.value.splice(index, 1)
    }

    showToast.success('Produit supprimé', 'Le produit a été supprimé avec succès')
  } catch (err) {
    console.error('Erreur suppression:', err)
    showToast.error('Erreur', 'Impossible de supprimer le produit')
  }
}

const openAddProduct = () => navigateTo(`/manager/${slug}/menu/new`)

// Initial load
onMounted(loadData)

// Watch for route changes to reload data
watch(() => route.path, async (newPath, oldPath) => {
  if (newPath && newPath !== oldPath) {
    await loadData()
  }
}, { immediate: true })

definePageMeta({
  layout: 'manager'
})
</script>
