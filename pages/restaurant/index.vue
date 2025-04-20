<template>
    <div class="font-sans bg-white min-h-screen max-w-lg mx-auto pb-24">
      <ErrorMessage v-if="error" :message="error" />
      
      <RestaurantHeader :data="data" v-if="data" />
      
      <div class="pb-24" v-if="data">
        <div v-for="category in data.categories" :key="category._id">
          <CategoryButton
            :category="category"
            :is-active="activeCategory === category._id"
            @click="toggleCategory(category._id)"
          />
          
          <TransitionGroup>
            <div v-if="activeCategory === category._id">
              <MenuItem
                v-for="item in category.products"
                :key="item._id"
                :item="item"
                @add="addToCart"
              />
            </div>
          </TransitionGroup>
        </div>
      </div>
  
      <FloatingCart
        :cart="cart"
        :is-expanded="isCartExpanded"
        @remove="removeFromCart"
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
  import { ref, onMounted } from 'vue'
  import { io } from 'socket.io-client'
  import type { EstablishmentData, CartItem, OrderData, Product } from '~/types'
  import { mockEstablishment, mockOrder } from '~/utils/mockData'
  import RestaurantHeader from '~/components/RestaurantHeader.vue'
  import CategoryButton from '~/components/CategoryButton.vue'
  import MenuItem from '~/components/MenuItem.vue'
  import FloatingCart from '~/components/FloatingCart.vue'
  import OrderSummaryTicket from '~/components/OrderSummaryTicket.vue'
  import WaitingLoader from '~/components/WaitingLoader.vue'
  
  const API_BASE_URL = 'your-api-url'
  const route = useRoute()
  const establishmentId = route.params.establishmentId as string
  
  const data = ref<EstablishmentData>(mockEstablishment)
  const activeCategory = ref(mockEstablishment.categories[0]._id)
  const cart = ref<CartItem[]>([])
  const socket = ref<any>(null)
  const isCartExpanded = ref(false)
  const isWaiting = ref(false)
  const confirmedOrder = ref<OrderData | null>(null)
  const error = ref('')
  
  // Simulation de la connexion socket
  onMounted(() => {
    setTimeout(() => {
      if (isWaiting.value) {
        isWaiting.value = false
        confirmedOrder.value = mockOrder
      }
    }, 2000)
  })
  
  // Fetch initial data
  // onMounted(async () => {
  //   try {
  //     const response = await fetch(
  //       `${API_BASE_URL}/api/categories/establishment/${establishmentId}`
  //     )
  //     data.value = await response.json()
  //     if (data.value?.categories.length > 0) {
  //       activeCategory.value = data.value.categories[0]._id
  //     }
  //   } catch (err) {
  //     error.value = 'Failed to load menu data'
  //     console.error('Error fetching establishment data:', err)
  //   }
  // })
  
  // Cart management
  const addToCart = (item: Product) => {
    const existingItem = cart.value.find(cartItem => cartItem._id === item._id)
    if (existingItem) {
      existingItem.quantity++
    } else {
      cart.value.push({ ...item, quantity: 1 })
    }
  }
  
  const removeFromCart = (itemId: string, isIncrement = false) => {
    const itemIndex = cart.value.findIndex(item => item._id === itemId)
    if (itemIndex === -1) return
  
    if (isIncrement) {
      cart.value[itemIndex].quantity++
      return
    }
  
    if (cart.value[itemIndex].quantity > 1) {
      cart.value[itemIndex].quantity--
    } else {
      cart.value.splice(itemIndex, 1)
    }
  }
  
  // Order placement
  const placeOrder = async () => {
    if (!socket.value || cart.value.length === 0) return
  
    try {
      const orderData = {
        establishmentId,
        products: cart.value.map(item => ({
          productId: item._id,
          quantity: item.quantity,
          name: item.name,
          price: item.price,
        })),
        totalAmount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
        status: 'pending' as const,
      }
  
      const response = await fetch(`${API_BASE_URL}/api/transactions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(orderData),
      })
      const result = await response.json()
  
      socket.value.emit('join_room', `order_${result._id}`)
      isWaiting.value = true
      cart.value = []
      isCartExpanded.value = false
      error.value = ''
    } catch (err) {
      error.value = 'Failed to place order'
      console.error('Error placing order:', err)
    }
  }
  
  const toggleCategory = (categoryId: string) => {
    activeCategory.value = activeCategory.value === categoryId ? '' : categoryId
  }
  
  const toggleCartExpand = () => {
    isCartExpanded.value = !isCartExpanded.value
  }
  </script> 