<template>
  <div>
    <!-- Menu content -->
    <div class="max-w-7xl mx-auto px-4 py-8">
      <!-- Categories and Products -->
      <div v-for="category in categories" :key="category.id">
        <h2 class="text-2xl font-bold mb-4">{{ category.name }}</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="product in getProductsByCategory(category.id)" 
            :key="product.id"
            class="bg-white rounded-xl shadow-sm overflow-hidden"
          >
            <!-- Product Image -->
            <div class="aspect-w-16 aspect-h-9">
              <img 
                :src="product.image_url" 
                :alt="product.name"
                class="w-full h-full object-cover"
              />
            </div>
            
            <!-- Product Info -->
            <div class="p-4">
              <h3 class="font-semibold">{{ product.name }}</h3>
              <p class="text-sm text-gray-500">{{ product.description }}</p>
              <div class="mt-4 flex items-center justify-between">
                <span class="font-bold">{{ formatPrice(product.price) }}</span>
                <button 
                  @click="addToCart(product)"
                  class="bg-black text-white px-4 py-2 rounded-full text-sm"
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
      class="fixed bottom-0 left-0 right-0 bg-white shadow-lg border-t border-gray-100 p-4"
    >
      <div class="max-w-7xl mx-auto flex items-center justify-between">
        <div>
          <span class="text-sm text-gray-500">{{ cart.items.length }} articles</span>
          <p class="font-bold">Total: {{ formatPrice(total) }}</p>
        </div>
        <button 
          @click="showCart = true"
          class="bg-black text-white px-6 py-3 rounded-full"
        >
          Voir le panier
        </button>
      </div>
    </div>

    <!-- Cart Modal -->
    <Modal v-if="showCart" @close="showCart = false">
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
            <div class="flex items-center space-x-2">
              <button @click="updateQuantity(item.id, item.quantity - 1)">-</button>
              <span>{{ item.quantity }}</span>
              <button @click="updateQuantity(item.id, item.quantity + 1)">+</button>
            </div>
          </div>
        </div>

        <!-- Total -->
        <div class="mt-6 pt-6 border-t">
          <div class="flex items-center justify-between font-bold">
            <span>Total</span>
            <span>{{ formatPrice(total) }}</span>
          </div>
        </div>

        <!-- Actions -->
        <div class="mt-6 space-y-3">
          <button 
            class="w-full bg-black text-white py-3 rounded-full"
            @click="showCart = false"
          >
            Montrer au serveur
          </button>
          <button 
            class="w-full text-red-500 py-3"
            @click="clearCart"
          >
            Vider le panier
          </button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useCart } from '~/composables/useCart'

const route = useRoute()
const slug = route.params.slug
const showCart = ref(false)

const { cart, addToCart, updateQuantity, clearCart, total, loadCart } = useCart()

// Charger le panier au montage
onMounted(() => {
  loadCart(slug as string)
  // Récupérer le numéro de table depuis l'URL si présent
  const tableNumber = route.query.table
  if (tableNumber) {
    cart.value.tableNumber = Number(tableNumber)
  }
})
</script> 