<template>
  <div class="space-y-4 sm:space-y-6">
    <!-- En-tête : retour, nom, statut, enregistrer -->
    <header class="flex flex-wrap items-center gap-3">
      <NuxtLink
        to="/admin/establishments"
        aria-label="Retour aux établissements"
        class="w-11 h-11 flex-shrink-0 rounded-full bg-gray-100 flex items-center justify-center text-gray-900 hover:bg-gray-200 active:scale-[0.94] transition-all"
      >
        <ArrowLeft class="w-5 h-5" :stroke-width="2.5" />
      </NuxtLink>
      <div class="flex-1 min-w-[10rem]">
        <h1 class="text-2xl lg:text-3xl font-black tracking-tight text-gray-900 break-words">{{ restaurant.name }}</h1>
        <p v-if="restaurant.address" class="text-sm font-semibold text-gray-500 break-words">{{ restaurant.address }}</p>
      </div>
      <span
        class="inline-flex items-center gap-2 h-9 px-4 rounded-full text-xs font-extrabold"
        :class="restaurant.status === 'active' ? 'bg-black text-white' : 'bg-gray-200 text-gray-700'"
      >
        <span class="w-2 h-2 rounded-full" :class="restaurant.status === 'active' ? 'bg-[#FB6A00]' : 'bg-gray-500'"></span>
        {{ restaurant.status === 'active' ? 'Actif' : 'Inactif' }}
      </span>
      <button
        type="button"
        :disabled="loading"
        class="h-11 px-6 rounded-full bg-[#FB6A00] text-black font-black inline-flex items-center gap-2 hover:bg-[#FD9542] active:scale-[0.97] transition-all disabled:opacity-50"
        @click="saveChanges"
      >
        <Save class="w-4 h-4" :stroke-width="2.5" />
        Enregistrer
      </button>
    </header>

    <!-- La grande carte : l'activité de l'établissement -->
    <HeroCard
      label="Revenu"
      :value="formatPrice(stats.totalRevenue)"
      :icon="Store"
      :chips="[
        { label: 'Produits', value: stats.totalProducts },
        { label: 'Catégories', value: stats.totalCategories },
        { label: 'Commandes', value: stats.totalOrders }
      ]"
    />

    <!-- Onglets en pilules -->
    <div class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide" role="tablist" aria-label="Sections">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        type="button"
        role="tab"
        :aria-selected="activeTab === tab.id"
        class="inline-flex items-center gap-2 h-11 px-5 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
        :class="activeTab === tab.id ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
        @click="activeTab = tab.id"
      >
        <component :is="tab.icon" class="w-4 h-4" :stroke-width="2.5" />
        {{ tab.name }}
      </button>
    </div>

    <!-- Informations -->
    <section v-if="activeTab === 'info'" class="space-y-4">
      <div class="rounded-[2rem] bg-gray-100 p-5 sm:p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-4xl">
          <FloatLabelInput id="establishment-name" v-model="restaurant.name" label="Nom de l'établissement" type="text" pill required />
          <FloatLabelInput id="establishment-email" v-model="restaurant.email" label="Email" type="email" pill />
          <FloatLabelInput id="establishment-phone" v-model="restaurant.phone" label="Téléphone" type="tel" pill />
          <FloatLabelInput id="establishment-address" v-model="restaurant.address" label="Adresse" type="text" pill />
          <div class="md:col-span-2">
            <FloatLabelInput id="establishment-description" v-model="restaurant.description" label="Description" type="text" pill />
          </div>
        </div>
      </div>

      <div class="rounded-[2rem] bg-gray-100 p-5 sm:p-6 flex items-center gap-4">
        <span class="w-12 h-12 flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><User class="w-6 h-6" :stroke-width="2.5" /></span>
        <div class="min-w-0">
          <p class="text-xs font-extrabold uppercase tracking-wide text-gray-500">Propriétaire</p>
          <p class="font-black text-gray-900 break-words">{{ restaurant.owner }}</p>
          <p class="text-sm font-semibold text-gray-500 break-words">{{ restaurant.ownerEmail }}</p>
        </div>
      </div>
    </section>

    <!-- Menu : des cartes, les options dans une feuille -->
    <section v-if="activeTab === 'menu'" class="space-y-4">
      <div class="flex flex-wrap gap-2">
        <button
          type="button"
          class="h-11 px-5 rounded-full bg-black text-white text-sm font-extrabold inline-flex items-center gap-2 active:scale-[0.97] transition-all"
          @click="openNewProductModal"
        ><Plus class="w-4 h-4" :stroke-width="3" /> Ajouter un produit</button>
        <button
          type="button"
          class="h-11 px-5 rounded-full bg-gray-100 text-gray-900 text-sm font-extrabold inline-flex items-center gap-2 hover:bg-gray-200 active:scale-[0.97] transition-all"
          @click="handleProductButtonClick('manage-categories')"
        ><Layers class="w-4 h-4" :stroke-width="2.5" /> Catégories</button>
      </div>

      <div v-if="loadingProducts" class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3" aria-busy="true">
        <div v-for="i in 6" :key="i" class="h-28 rounded-[2rem] bg-gray-100 animate-pulse"></div>
      </div>

      <div v-else-if="allProducts.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
        <UtensilsCrossed class="w-10 h-10 text-gray-400 mx-auto" />
        <h3 class="mt-3 text-lg font-black text-gray-900">Aucun produit</h3>
        <p class="mt-1 text-sm font-semibold text-gray-500">Aucun produit n'a été ajouté à cet établissement</p>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
        <article
          v-for="item in pagedProducts"
          :key="item.id"
          class="rounded-[2rem] bg-gray-100 p-3 pr-4 flex items-center gap-3"
          :class="item.is_available ? '' : 'opacity-70'"
        >
          <span class="w-20 h-20 flex-shrink-0 rounded-3xl bg-white overflow-hidden flex items-center justify-center">
            <img v-if="item.image_url" :src="item.image_url" :alt="item.name" class="w-full h-full object-cover" />
            <UtensilsCrossed v-else class="w-7 h-7 text-gray-300" />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="font-black text-gray-900 leading-tight truncate">{{ item.name }}</h3>
            <p class="text-xs font-semibold text-gray-500 truncate">{{ item.category_name }}</p>
            <div class="mt-1.5 flex items-center gap-2">
              <span class="inline-flex items-center h-7 px-3 rounded-full bg-[#FB6A00] text-black text-xs font-black tabular-nums">{{ formatPrice(item.price) }}</span>
              <span
                class="inline-flex items-center h-7 px-3 rounded-full text-xs font-extrabold"
                :class="item.is_available ? 'bg-black text-white' : 'bg-gray-200 text-gray-700'"
              >{{ item.is_available ? 'Disponible' : 'Indisponible' }}</span>
            </div>
          </div>
          <button
            type="button"
            :aria-label="`Options pour ${item.name}`"
            class="w-11 h-11 flex-shrink-0 rounded-full bg-white text-gray-900 flex items-center justify-center active:scale-[0.92] transition-all"
            @click="sheetProduct = item"
          ><MoreHorizontal class="w-5 h-5" :stroke-width="2.5" /></button>
        </article>
      </div>

      <div v-if="allProducts.length > productsPerPage" class="flex items-center justify-center gap-2">
        <button
          type="button"
          class="h-11 px-5 rounded-full bg-gray-100 text-sm font-extrabold disabled:opacity-40 active:scale-[0.97] transition-all"
          :disabled="productsPage <= 1"
          @click="productsPage--"
        >Précédent</button>
        <span class="text-sm font-extrabold text-gray-600 tabular-nums">{{ productsPage }} / {{ productPageCount }}</span>
        <button
          type="button"
          class="h-11 px-5 rounded-full bg-black text-white text-sm font-extrabold disabled:opacity-40 active:scale-[0.97] transition-all"
          :disabled="productsPage >= productPageCount"
          @click="productsPage++"
        >Suivant</button>
      </div>
    </section>

    <!-- Réglages -->
    <section v-if="activeTab === 'settings'" class="space-y-4 max-w-2xl">
      <div class="rounded-[2rem] bg-gray-100 p-5 sm:p-6 flex items-center justify-between gap-4">
        <div class="min-w-0">
          <h3 class="font-black text-gray-900">Statut de l'établissement</h3>
          <p class="text-sm font-semibold text-gray-500 mt-0.5">Activer ou désactiver cet établissement</p>
        </div>
        <AppleSwitch :model-value="!!restaurant.is_active" @update:model-value="toggleStatus" />
      </div>

      <div class="rounded-[2rem] bg-[#FFECD8] p-5 sm:p-6">
        <h3 class="font-black text-[#7C2900]">Zone de danger</h3>
        <p class="text-sm font-semibold text-[#7C2900]/80 mt-1 mb-4">
          La suppression de cet établissement est irréversible. Toutes les données associées seront perdues.
        </p>
        <button
          type="button"
          class="h-12 px-6 rounded-full bg-[#C54E00] text-white font-black inline-flex items-center gap-2 hover:bg-[#7C2900] active:scale-[0.97] transition-all"
          @click="deleteRestaurant"
        ><Trash2 class="w-4 h-4" :stroke-width="2.5" /> Supprimer l'établissement</button>
      </div>
    </section>

    <!-- Options d'un produit : une feuille, pas une carte -->
    <UiActionSheet
      :model-value="!!sheetProduct"
      :title="sheetProduct?.name || 'Produit'"
      :subtitle="sheetProduct ? formatPrice(sheetProduct.price) : ''"
      :actions="sheetActions"
      @update:model-value="v => { if (!v) sheetProduct = null }"
      @select="onSheetSelect"
    />
  </div>
</template>

<script setup lang="ts">
import HeroCard from '~/components/ui/HeroCard.vue'
import UiActionSheet from '~/components/ui/ActionSheet.vue'
import AppleSwitch from '~/components/AppleSwitch.vue'
import { MoreHorizontal } from 'lucide-vue-next'
import {
  ArrowLeft, Store, User, UtensilsCrossed, Save,
  Plus, Edit2, Trash2, Settings as SettingsIcon,
  Info, Layers, ShoppingBag, DollarSign, Eye, EyeOff
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import FloatLabelInput from '~/components/FloatLabelInput.vue'
import DataTable from '~/components/DataTable/index.vue'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()
const loading = ref(false)
const loadingProducts = ref(false)
const activeTab = ref('info')

// Pagination for products
const productsPage = ref(1)
const productsPerPage = ref(10)

// Tabs configuration
const tabs = [
  { id: 'info', name: 'Informations', icon: Info },
  { id: 'menu', name: 'Menu & Produits', icon: UtensilsCrossed },
  { id: 'settings', name: 'Paramètres', icon: SettingsIcon }
]

// Restaurant data
const restaurant = ref({
  id: route.params.id,
  name: '',
  email: '',
  phone: '',
  address: '',
  description: '',
  status: 'inactive',
  owner: '',
  ownerEmail: '',
  is_active: false
})

// Stats
const stats = ref({
  totalProducts: 0,
  totalCategories: 0,
  totalOrders: 0,
  totalRevenue: 0
})

// Menu categories and products
const menuCategories = ref<any[]>([])
const allProducts = ref<any[]>([])

// Product columns for DataTable
const productColumns = [
  { key: 'name', label: 'Produit', sortable: true },
  { key: 'price', label: 'Prix', sortable: true },
  { key: 'is_available', label: 'Disponibilité', sortable: true },
  { key: 'actions', label: 'Actions', sortable: false }
]

// Load restaurant data
const loadRestaurant = async () => {
  try {
    loading.value = true
    
    // Get establishment data
    const { data, error } = await supabase
      .from('establishments')
      .select(`
        *
      `)
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    
    // Format the data
    restaurant.value = {
      id: data.id,
      name: data.name || '',
      email: data.email || '',
      phone: data.phone || '',
      address: data.address || '',
      description: data.description || '',
      status: data.is_active ? 'active' : 'inactive',
      owner: data.users?.full_name || 'Propriétaire inconnu',
      ownerEmail: data.users?.email || '',
      is_active: data.is_active
    }

    // Load menu categories and products
    await loadMenuData()
    
    // Load stats
    await loadStats()
    
  } catch (err) {
    console.error('Error loading restaurant:', err)
    showToast.error('Impossible de charger les données du restaurant', 'error')
    // router.push('/admin/establishments')
  } finally {
    loading.value = false
  }
}

// Load menu categories and products
const loadMenuData = async () => {
  try {
    loadingProducts.value = true
    
    // Get categories with their products
    const { data, error } = await supabase
      .from('categories')
      .select(`
        id,
        name,
        products (
          id,
          name,
          description,
          price,
          is_available,
          image_url
        )
      `)
      .eq('establishment_id', route.params.id)

    if (error) throw error

    menuCategories.value = data || []
    
    // Flatten products for DataTable
    allProducts.value = []
    data?.forEach(category => {
      category.products?.forEach((product: any) => {
        allProducts.value.push({
          ...product,
          category_name: category.name,
          category_id: category.id
        })
      })
    })
    
    stats.value.totalCategories = data?.length || 0
    stats.value.totalProducts = allProducts.value.length
    
  } catch (err) {
    console.error('Error loading menu data:', err)
  } finally {
    loadingProducts.value = false
  }
}

// Load stats
const loadStats = async () => {
  try {
    // Get total orders (you'll need to adjust based on your schema)
    const { count: ordersCount } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true })
      .eq('establishment_id', route.params.id)
    
    stats.value.totalOrders = ordersCount || 0
    
    // Get total revenue (adjust based on your schema)
    const { data: ordersData } = await supabase
      .from('orders')
      .select('total_price')
      .eq('establishment_id', route.params.id)
      .eq('status', 'completed')
    
    stats.value.totalRevenue = ordersData?.reduce((sum, order) => sum + (order.total_price || 0), 0) || 0
    
  } catch (err) {
    console.error('Error loading stats:', err)
  }
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF' 
  }).format(price)
}

// Toggle restaurant status
const toggleStatus = async () => {
  try {
    loading.value = true
    
    const newStatus = !restaurant.value.is_active
    
    const { error } = await supabase
      .from('establishments')
      .update({ is_active: newStatus })
      .eq('id', restaurant.value.id)

    if (error) throw error

    restaurant.value.is_active = newStatus
    restaurant.value.status = newStatus ? 'active' : 'inactive'
    
    showToast.success('Statut modifié', 'Le statut du restaurant a été mis à jour')
  } catch (err) {
    console.error('Error toggling status:', err)
    showToast.error('Erreur', 'Impossible de modifier le statut')
  } finally {
    loading.value = false
  }
}

// Save restaurant changes
const saveChanges = async () => {
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .update({
        name: restaurant.value.name,
        email: restaurant.value.email,
        phone: restaurant.value.phone,
        address: restaurant.value.address,
        description: restaurant.value.description
      })
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées avec succès', 'success')
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Impossible d\'enregistrer les modifications', 'error')
  } finally {
    loading.value = false
  }
}

// Delete restaurant
const deleteRestaurant = async () => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce restaurant ? Cette action est irréversible.')) return
  
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('establishments')
      .delete()
      .eq('id', restaurant.value.id)

    if (error) throw error
    
    showToast.success('Restaurant supprimé avec succès', 'success')
    router.push('/admin/establishments')
  } catch (err) {
    console.error('Error deleting restaurant:', err)
    showToast.error('Impossible de supprimer le restaurant', 'error')
  } finally {
    loading.value = false
  }
}

// Open product modal
const openNewProductModal = () => {
  showToast.info('Fonctionnalité à venir', 'info')
}

// Edit product
const editProduct = (product: any) => {
  showToast.info('Fonctionnalité à venir', 'info')
}

// Toggle product availability
const toggleProductAvailability = async (product: any) => {
  try {
    const { error } = await supabase
      .from('products')
      .update({ is_available: !product.is_available })
      .eq('id', product.id)

    if (error) throw error

    await loadMenuData()
    showToast.success(
      product.is_available ? 'Produit marqué comme indisponible' : 'Produit marqué comme disponible',
      'success'
    )
  } catch (err) {
    console.error('Error toggling product availability:', err)
    showToast.error('Impossible de modifier la disponibilité', 'error')
  }
}

// Delete product
const deleteProduct = async (productId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return

  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', productId)

    if (error) throw error

    await loadMenuData()
    showToast.success('Produit supprimé avec succès', 'success')
  } catch (err) {
    console.error('Error deleting product:', err)
    showToast.error('Impossible de supprimer le produit', 'error')
  }
}

// Handle product button clicks
const handleProductButtonClick = (action: string) => {
  switch (action) {
    case 'manage-categories':
      showToast.info('Fonctionnalité de gestion des catégories à venir', 'info')
      break
    default:
      console.log('Unknown action:', action)
  }
}

// Pagination des produits (cartes) et feuille d'options
const productPageCount = computed(() => Math.max(1, Math.ceil(allProducts.value.length / productsPerPage.value)))
const pagedProducts = computed(() => {
  const start = (productsPage.value - 1) * productsPerPage.value
  return allProducts.value.slice(start, start + productsPerPage.value)
})

const sheetProduct = ref<any | null>(null)
const sheetActions = computed(() => {
  const p = sheetProduct.value
  if (!p) return []
  return [
    { key: 'edit', label: 'Modifier', icon: Edit2, hint: 'Nom, prix, photo, catégorie' },
    {
      key: 'availability',
      label: p.is_available ? 'Marquer indisponible' : 'Marquer disponible',
      icon: p.is_available ? EyeOff : Eye,
      hint: p.is_available ? 'Le produit disparaît du menu client' : 'Le produit revient dans le menu client'
    },
    { key: 'delete', label: 'Supprimer', icon: Trash2, danger: true, hint: 'Action irréversible' }
  ]
})
const onSheetSelect = (key: string) => {
  const p = sheetProduct.value
  if (!p) return
  if (key === 'edit') editProduct(p)
  else if (key === 'availability') toggleProductAvailability(p)
  else if (key === 'delete') deleteProduct(p.id)
}

// Load data on mount
onMounted(loadRestaurant)

definePageMeta({
  layout: 'admin'
})
</script>