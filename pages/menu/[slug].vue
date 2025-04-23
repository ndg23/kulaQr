<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 py-6">
        <h1 class="text-3xl font-bold text-gray-900">
          {{ establishment.name }}
        </h1>
        <p v-if="establishment.description" class="mt-2 text-gray-600">
          {{ establishment.description }}
        </p>
      </div>
    </header>

    <!-- Menu Content -->
    <main class="max-w-7xl mx-auto px-4 py-8">
      <div v-for="category in establishment.categories" 
        :key="category.id"
        class="mb-12"
      >
        <div class="flex items-center gap-3 mb-6">
          <component 
            :is="category.icon" 
            class="w-6 h-6 text-gray-700"
          />
          <h2 class="text-2xl font-semibold text-gray-900">
            {{ category.name }}
          </h2>
        </div>

        <div class="grid md:grid-cols-2 gap-6">
          <div v-for="product in category.products" 
            :key="product.id"
            class="bg-white rounded-xl p-6 shadow-sm"
            :class="{ 'opacity-50': !product.is_available }"
          >
            <div class="flex gap-4">
              <img 
                v-if="product.image_url"
                :src="product.image_url"
                :alt="product.name"
                class="w-24 h-24 object-cover rounded-lg"
              />
              <div class="flex-1">
                <div class="flex justify-between items-start mb-2">
                  <h3 class="text-lg font-medium text-gray-900">
                    {{ product.name }}
                  </h3>
                  <span class="text-lg font-semibold text-facebook">
                    {{ product.price.toFixed(2) }}€
                  </span>
                </div>
                <p class="text-gray-600">{{ product.description }}</p>
                <div v-if="!product.is_available" class="mt-2 text-sm text-red-600">
                  Non disponible
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { UtensilsCrossed } from 'lucide-vue-next'
import { useCart } from '~/composables/useCart'
import {
  TransitionRoot,
  TransitionChild,
  Dialog,
  DialogPanel
} from '@headlessui/vue'

const route = useRoute()
const slug = route.params.slug as string
const supabase = useSupabaseClient()

const showCart = ref(false)
const establishment = ref(null)
const categories = ref([])
const products = ref([])

const { cart, addToCart, updateQuantity, clearCart, total, loadCart } = useCart()

// Charger les données du menu
const { data: establishmentData } = await useAsyncData(
  `establishment-${slug}`,
  async () => {
    const { data, error } = await supabase
      .from('establishments')
      .select(`
        id,
        name,
        description,
        categories (
          id,
          name,
          icon,
          products (
            id,
            name,
            description,
            price,
            image_url,
            is_available
          )
        )
      `)
      .eq('slug', slug)
      .single()

    if (error) throw error
    return data
  }
)

if (!establishmentData.value) {
  throw createError({
    statusCode: 404,
    message: 'Menu non trouvé'
  })
}

// Helpers
const getProductsByCategory = (categoryId: string) => {
  return products.value.filter(p => p.category_id === categoryId)
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price)
}

// Load data
const loadData = async () => {
  try {
    // Load establishment
    establishment.value = establishmentData.value

    // Load categories
    categories.value = establishmentData.value.categories

    // Load products
    products.value = establishmentData.value.categories.map(c => c.products).flat()
  } catch (error) {
    console.error('Error loading data:', error)
  }
}

onMounted(() => {
  loadData()
  loadCart(slug as string)
  // Get table number from URL if present
  const tableNumber = route.query.table
  if (tableNumber) {
    cart.value.tableNumber = Number(tableNumber)
  }
})
</script> 