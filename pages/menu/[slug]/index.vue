<template>
    <div class="font-sans bg-white min-h-screen max-w-lg mx-auto pb-24">
      <ErrorMessage v-if="error" :message="error" />
      
      <div v-if="loading" class="min-h-screen flex items-center justify-center bg-white">
        <div class="space-y-4 text-center">
          <Loader2 class="w-8 h-8 animate-spin mx-auto text-gray-400" />
          <p class="text-gray-500">Chargement du menu...</p>
        </div>
      </div>
      
      <div v-else-if="!establishment" class="min-h-screen flex items-center justify-center bg-white px-4">
        <div class="max-w-md w-full space-y-8 text-center">
          <div class="w-20 h-20 mx-auto bg-gray-50 rounded-3xl flex items-center justify-center">
            <Store class="w-10 h-10 text-gray-400" />
          </div>
          <div class="space-y-3">
            <h1 class="text-2xl font-semibold text-gray-900">
              Restaurant introuvable
            </h1>
            <p class="text-gray-500 text-lg">
              Ce menu n'est plus disponible ou a été déplacé.
            </p>
          </div>
          <div class="pt-4">
            <NuxtLink 
              to="/"
              class="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-2xl text-white bg-black hover:bg-gray-800 transition-colors"
            >
              Retourner à l'accueil
            </NuxtLink>
          </div>
          <p class="text-sm text-gray-400 pt-4">
            Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support.
          </p>
        </div>
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
        @add-note="openAddNoteModal"
        @remove-item="removeItemFromCart"
      />
  
      <WaitingLoader 
        :is-visible="isWaiting" 
        :status="orderStatus"
      />
      
      <OrderSummaryTicket
        v-if="confirmedOrder"
        :order="confirmedOrder"
        @close="handleOrderClose"
      />
  
      <AddNote
        v-model:cart="cart"
        ref="addNoteModal"
      />
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, onMounted, computed, onUnmounted } from 'vue'
  import { UtensilsCrossed, Store, Loader2 } from 'lucide-vue-next'
  import type { CartItem, OrderData, Product } from '~/types'
  import RestaurantHeader from '~/components/RestaurantHeader.vue'
  import CategoryButton from '~/components/CategoryButton.vue'
  import MenuItem from '~/components/MenuItem.vue'
  import FloatingCart from '~/components/FloatingCart.vue'
  import OrderSummaryTicket from '~/components/OrderSummaryTicket.vue'
  import WaitingLoader from '~/components/WaitingLoader.vue'
  import ErrorMessage from '~/components/ErrorMessage.vue'
  import { useSupabaseClient } from '#imports'
  import AddNote from '~/components/AddNote.vue'
  
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
  const orderStatus = ref<'loading' | 'waiting' | 'success' | 'rejected'>('loading')
  const confirmedOrder = ref<OrderData | null>(null)
  const error = ref('')
  const loading = ref(true)
  const addNoteModal = ref(null)
  
  // Types for Supabase
  type OrderStatus = 'pending' | 'accepted' | 'rejected' | 'preparing' | 'ready' | 'completed'
  
  interface DatabaseOrder {
    id: string
    establishment_id: string
    table_number: number
    status: OrderStatus
    total_amount: number
    created_at: string
    notes: string | null
  }
  
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
  const openAddNoteModal = (itemId: string) => {
    addNoteModal.value.openModal(itemId)
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
      cart.value.push({ ...item, quantity: 1, notes: '' })
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
  
  const removeItemFromCart = (itemId: string) => {
    cart.value = cart.value.filter(item => item.id !== itemId)
  }
  
  // Order placement
  const placeOrder = async () => {
    if (cart.value.length === 0) return
  
    try {
      isWaiting.value = true
      orderStatus.value = 'loading'
      
      // Create a new order
      const { data: orderData, error: orderError } = await supabase
        .from('orders')
        .insert({
          establishment_id: establishment.value?.id,
          table_number: Math.floor(Math.random() * 20) + 1,
          status: 'pending',
          total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
          notes: cart.value.filter(item => item.notes).map(item => `${item.name}: ${item.notes}`).join('\n')
        } as DatabaseOrder)
        .select()
        .single()
      
      if (orderError) throw orderError
      
      // Add order items
      const orderItems = cart.value.map(item => ({
        order_id: orderData.id,
        product_id: item.id,
        quantity: item.quantity,
        unit_price: item.price,
        subtotal: item.price * item.quantity,
        notes: item.notes || null
      }))
      
      const { error: itemsError } = await supabase
        .from('order_items')
        .insert(orderItems)
      
      if (itemsError) throw itemsError
      
      // Change status to waiting for staff confirmation
      orderStatus.value = 'waiting'
      
      // Subscribe to order status changes
      const channel = supabase
      .channel('orders-changes')
      .on<DatabaseOrder>(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'orders',
            filter: `id=eq.${orderData.id}`
          },
          (payload) => {
            const newStatus = payload.new.status

            switch (newStatus) {
              case 'accepted':
                orderStatus.value = 'success'
                setTimeout(() => {
                  isWaiting.value = false
                  confirmedOrder.value = {
                    id: orderData.id,
                    table: orderData.table_number,
                    items: cart.value.map(item => ({
                      name: item.name,
                      price: item.price,
                      quantity: item.quantity,
                      notes: item.notes
                    })),
                    total: orderData.total_amount,
                    status: newStatus,
                    created_at: new Date().toISOString()
                  }
                  cart.value = []
                  isCartExpanded.value = false
                }, 1000)
                break

              case 'rejected':
                orderStatus.value = 'rejected'
                setTimeout(() => {
                  isWaiting.value = false
                  error.value = 'Votre commande a été refusée par le restaurant.'
                }, 2000)
                break

              case 'preparing':
                if (confirmedOrder.value) {
                  confirmedOrder.value.status = newStatus
                }
                break

              case 'ready':
                if (confirmedOrder.value) {
                  confirmedOrder.value.status = newStatus
                }
                break
            }
          }
        )
        .subscribe()

      // Cleanup subscription on component unmount
      onUnmounted(() => {
        channel.unsubscribe()
      })
      
    } catch (err) {
      console.error('Error placing order:', err)
      error.value = 'Impossible de passer la commande. Veuillez réessayer.'
      isWaiting.value = false
    }
  }
  
  const handleOrderClose = () => {
    confirmedOrder.value = null
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
  
  .min-h-screen {
    min-height: 100vh;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  .space-y-8 {
    animation: fadeIn 0.3s ease-out;
  }
  </style> 