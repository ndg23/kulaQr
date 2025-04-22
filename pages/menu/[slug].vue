<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white border-b border-gray-100 sticky top-0 z-30">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <h1 class="text-xl font-medium">{{ establishment?.name }}</h1>
          <div class="flex items-center space-x-4">
            <span v-if="cart.tableNumber" class="text-sm text-gray-500">
              Table {{ cart.tableNumber }}
            </span>
          </div>
        </div>
      </div>
    </header>

    <!-- Menu content -->
    <div class="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">
      <!-- Categories and Products -->
      <div v-for="category in categories" :key="category.id" class="mb-12">
        <div class="flex items-center space-x-3 mb-6">
          <div 
            class="w-12 h-12 rounded-xl flex items-center justify-center"
            :class="category.iconBg"
          >
            <component :is="category.icon" class="w-6 h-6" :class="category.iconColor" />
          </div>
          <div>
            <h2 class="text-2xl font-bold text-gray-900">{{ category.name }}</h2>
            <p class="text-sm text-gray-500">{{ category.description }}</p>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="product in getProductsByCategory(category.id)" 
            :key="product.id"
            class="bg-white rounded-2xl shadow-sm overflow-hidden hover:shadow-md transition-shadow duration-200"
          >
            <!-- Product Image -->
            <div class="aspect-w-16 aspect-h-9 bg-gray-100">
              <img 
                v-if="product.image_url"
                :src="product.image_url" 
                :alt="product.name"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center">
                <UtensilsCrossed class="w-8 h-8 text-gray-300" />
              </div>
            </div>
            
            <!-- Product Info -->
            <div class="p-4">
              <div class="mb-3">
                <h3 class="font-medium text-gray-900">{{ product.name }}</h3>
                <p class="mt-1 text-sm text-gray-500 line-clamp-2">{{ product.description }}</p>
              </div>
              <div class="flex items-center justify-between">
                <span class="font-bold">{{ formatPrice(product.price) }}</span>
                <button 
                  @click="addToCart(product)"
                  class="bg-black text-white px-4 py-2 rounded-full text-sm font-medium hover:bg-gray-900 transition-colors"
                >
                  Ajouter
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Cart Drawer -->
    <div 
      v-if="cart.items.length > 0"
      class="fixed bottom-0 left-0 right-0 bg-white shadow-lg border-t border-gray-100 p-4 z-40"
    >
      <div class="max-w-7xl mx-auto flex items-center justify-between">
        <div>
          <span class="text-sm text-gray-500">{{ cart.items.length }} articles</span>
          <p class="font-bold">Total: {{ formatPrice(total) }}</p>
        </div>
        <button 
          @click="showCart = true"
          class="bg-black text-white px-6 py-3 rounded-full font-medium hover:bg-gray-900 transition-colors"
        >
          Voir le panier
        </button>
      </div>
    </div>

    <!-- Cart Modal -->
    <TransitionRoot appear :show="showCart" as="template">
      <Dialog as="div" class="relative z-50" @close="showCart = false">
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
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white shadow-xl transition-all">
                <div class="p-6">
                  <h2 class="text-2xl font-bold mb-6">Votre commande</h2>
                  
                  <!-- Cart Items -->
                  <div class="space-y-4">
                    <div v-for="item in cart.items" :key="item.id"
                      class="flex items-center justify-between"
                    >
                      <div>
                        <h3 class="font-medium">{{ item.name }}</h3>
                        <p class="text-sm text-gray-500">{{ formatPrice(item.price) }}</p>
                      </div>
                      <div class="flex items-center space-x-3">
                        <button 
                          @click="updateQuantity(item.id, item.quantity - 1)"
                          class="w-8 h-8 rounded-full border border-gray-200 flex items-center justify-center hover:bg-gray-50"
                        >
                          -
                        </button>
                        <span class="w-8 text-center">{{ item.quantity }}</span>
                        <button 
                          @click="updateQuantity(item.id, item.quantity + 1)"
                          class="w-8 h-8 rounded-full border border-gray-200 flex items-center justify-center hover:bg-gray-50"
                        >
                          +
                        </button>
                      </div>
                    </div>
                  </div>

                  <!-- Total -->
                  <div class="mt-6 pt-6 border-t">
                    <div class="flex items-center justify-between font-bold text-lg">
                      <span>Total</span>
                      <span>{{ formatPrice(total) }}</span>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div class="mt-6 space-y-3">
                    <button 
                      class="w-full bg-black text-white py-3 rounded-full font-medium hover:bg-gray-900 transition-colors"
                      @click="showCart = false"
                    >
                      Montrer au serveur
                    </button>
                    <button 
                      class="w-full text-red-500 py-3 font-medium hover:text-red-600 transition-colors"
                      @click="clearCart"
                    >
                      Vider le panier
                    </button>
                  </div>
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
const slug = route.params.slug
const supabase = useSupabaseClient()

const showCart = ref(false)
const establishment = ref(null)
const categories = ref([])
const products = ref([])

const { cart, addToCart, updateQuantity, clearCart, total, loadCart } = useCart()

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
    const { data: establishmentData } = await supabase
      .from('establishments')
      .select()
      .eq('slug', slug)
      .single()
    
    establishment.value = establishmentData

    // Load categories
    const { data: categoriesData } = await supabase
      .from('categories')
      .select()
      .eq('establishment_id', establishmentData.id)
      .order('order_number')

    // Load products
    const { data: productsData } = await supabase
      .from('products')
      .select()
      .in('category_id', categoriesData.map(c => c.id))
      .eq('is_available', true)
      .order('order_number')

    categories.value = categoriesData
    products.value = productsData
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