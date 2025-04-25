<template>
    <div class="font-sans bg-white min-h-screen max-w-lg mx-auto pb-24">
      <ErrorMessage v-if="error" :message="error" />
      
      <div v-if="loading" class="flex flex-col items-center justify-center h-screen">
        <div class="w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
        <p class="mt-4 text-gray-600">Chargement du menu...</p>
      </div>
      
      <template v-else>
        <RestaurantHeader 
          :data="establishment" 
          v-if="establishment" 
        />
        
        <div class="pb-24" v-if="categories.length > 0">
          <div v-for="category in categories" :key="category.id">
            <CategoryButton
              :category="category"
              :is-active="activeCategory === category.id"
              @click="toggleCategory(category.id)"
            />
            
            <TransitionGroup>
              <div v-if="activeCategory === category.id">
                <MenuItem
                  v-for="product in getCategoryProducts(category.id)"
                  :key="product.id"
                  :item="product"
                  @add="addToCart"
                />
              </div>
            </TransitionGroup>
          </div>
        </div>
        
        <div v-else-if="!loading && establishment" class="flex flex-col items-center justify-center py-16">
          <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mb-4">
            <UtensilsCrossed class="w-10 h-10 text-gray-400" />
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune catégorie</h3>
          <p class="text-gray-500 text-center max-w-xs">
            Ce restaurant n'a pas encore ajouté de catégories à son menu.
          </p>
        </div>
      </template>
  
      <FloatingCart
        :cart="cart"
        :is-expanded="isCartExpanded"
        @remove="removeFromCart"
        @increment="incrementCartItem"
        @place-order="placeOrder"
        @toggle="toggleCartExpand"
      />
  
      <WaitingLoader :is-visible="isWaiting" />
      
      <OrderSummaryTicket
        v-if="confirmedOrder"
        :order="confirmedOrder"
        @close="confirmedOrder = null"
      />
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, onMounted, computed } from 'vue'
  import { UtensilsCrossed } from 'lucide-vue-next'
  import type { CartItem, OrderData, Product } from '~/types'
  import RestaurantHeader from '~/components/RestaurantHeader.vue'
  import CategoryButton from '~/components/CategoryButton.vue'
  import MenuItem from '~/components/MenuItem.vue'
  import FloatingCart from '~/components/FloatingCart.vue'
  import OrderSummaryTicket from '~/components/OrderSummaryTicket.vue'
  import WaitingLoader from '~/components/WaitingLoader.vue'
  import ErrorMessage from '~/components/ErrorMessage.vue'
  import { useSupabaseClient } from '#imports'
  
  const route = useRoute()
  const slug = route.params.slug as string
  const supabase = useSupabaseClient()
  
  // State
  const establishment = ref(null)
  const categories = ref([])
  const products = ref([])
  const activeCategory = ref('')
  const cart = ref<CartItem[]>([])
  const isCartExpanded = ref(false)
  const isWaiting = ref(false)
  const confirmedOrder = ref<OrderData | null>(null)
  const error = ref('')
  const loading = ref(true)
  
  // Fetch data from Supabase
  const fetchData = async () => {
    loading.value = true
    error.value = ''
    
    try {
      // Fetch establishment data
      const { data: establishmentData, error: establishmentError } = await supabase
        .from('establishments')
        .select('*')
        .eq('slug', slug)
        .single()
      
      if (establishmentError) throw establishmentError
      establishment.value = establishmentData
      
      // Fetch categories
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('categories')
        .select('*')
        .eq('establishment_id', establishmentData.id)
        .order('order_number')
      
      if (categoriesError) throw categoriesError
      categories.value = categoriesData || []
      
      // Set active category if we have categories
      if (categories.value.length > 0) {
        activeCategory.value = categories.value[0].id
      }
      
      // Fetch products
      const { data: productsData, error: productsError } = await supabase
        .from('products')
        .select('*')
        .eq('establishment_id', establishmentData.id)
        .eq('is_available', true)
      
      if (productsError) throw productsError
      products.value = productsData || []
      
    } catch (err) {
      console.error('Error fetching data:', err)
      error.value = 'Impossible de charger le menu. Veuillez réessayer plus tard.'
    } finally {
      loading.value = false
    }
  }
  
  // Get products for a specific category
  const getCategoryProducts = (categoryId) => {
    return products.value.filter(product => product.category_id === categoryId)
  }
  
  // Cart management
  const addToCart = (item: Product) => {
    const existingItem = cart.value.find(cartItem => cartItem.id === item.id)
    if (existingItem) {
      existingItem.quantity++
    } else {
      cart.value.push({ ...item, quantity: 1 })
    }
  }
  
  const removeFromCart = (itemId: string) => {
    const itemIndex = cart.value.findIndex(item => item.id === itemId)
    if (itemIndex === -1) return
  
    if (cart.value[itemIndex].quantity > 1) {
      cart.value[itemIndex].quantity--
    } else {
      cart.value.splice(itemIndex, 1)
    }
  }
  
  const incrementCartItem = (itemId: string) => {
    const item = cart.value.find(item => item.id === itemId)
    if (item) {
      item.quantity++
    }
  }
  
  // Order placement
  const placeOrder = async () => {
    if (cart.value.length === 0) return
  
    try {
      isWaiting.value = true
      
      // Create a new order
      const { data: orderData, error: orderError } = await supabase
        .from('orders')
        .insert({
          establishment_id: establishment.value.id,
          table_number: Math.floor(Math.random() * 20) + 1, // Random table for demo
          status: 'pending',
          total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
        })
        .select()
        .single()
      
      if (orderError) throw orderError
      
      // Add order items
      const orderItems = cart.value.map(item => ({
        order_id: orderData.id,
        product_id: item.id,
        quantity: item.quantity,
        unit_price: item.price,
        subtotal: item.price * item.quantity
      }))
      
      const { error: itemsError } = await supabase
        .from('order_items')
        .insert(orderItems)
      
      if (itemsError) throw itemsError
      
      // Create confirmed order object
      confirmedOrder.value = {
        id: orderData.id,
        table: orderData.table_number,
        items: cart.value.map(item => ({
          name: item.name,
          price: item.price,
          quantity: item.quantity
        })),
        total: orderData.total_amount,
        status: orderData.status,
        created_at: new Date().toISOString()
      }
      
      // Clear cart
      cart.value = []
      isCartExpanded.value = false
      
    } catch (err) {
      console.error('Error placing order:', err)
      error.value = 'Impossible de passer la commande. Veuillez réessayer.'
    } finally {
      isWaiting.value = false
    }
  }
  
  const toggleCategory = (categoryId: string) => {
    activeCategory.value = activeCategory.value === categoryId ? '' : categoryId
  }
  
  const toggleCartExpand = () => {
    isCartExpanded.value = !isCartExpanded.value
  }
  
  // Format price helper
  const formatPrice = (price) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'XOF'
    }).format(price)
  }
  
  // Load data on mount
  onMounted(() => {
    fetchData()
  })
  </script>
  
  <style scoped>
  .animate-spin {
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
  </style> 