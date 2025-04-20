<template>
  <div
    class="fixed bottom-0 left-0 w-full max-w-lg mx-auto right-0 bg-white border-t border-gray-200 rounded-t-3xl shadow-lg"
    :class="{ 'h-72': isExpanded }"
  >
    <div
      class="p-4 flex justify-between items-center cursor-pointer"
      @click="$emit('toggle')"
    >
      <div class="flex items-center">
        <Icon name="shopping-bag" class="w-6 h-6 text-gray-500 mr-2" />
        <span class="font-mono font-medium text-gray-800">{{ totalItems }} éléments</span>
      </div>
      <div class="flex items-center">
        <span class="font-mono font-medium text-gray-800 mr-4">€{{ totalPrice.toFixed(2) }}</span>
        <Icon 
          name="chevron-up" 
          size="24"
          :class="{ 'rotate-180': isExpanded }"
          class="transition-transform duration-300"
        />
      </div>
    </div>

    <div v-if="isExpanded" class="px-4 pb-4">
      <div 
        v-for="item in cart" 
        :key="item._id" 
        class="flex justify-between items-center py-2"
      >
        <span class="font-mono">{{ item.name }}</span>
        <div class="flex items-center">
          <button
            @click="$emit('remove', item._id)"
            class="text-gray-500 focus:outline-none"
          >
            <Icon name="minus" size="18" />
          </button>
          <span class="mx-2 font-mono">{{ item.quantity }}</span>
          <button
            @click="$emit('remove', item._id, true)"
            class="text-gray-500 focus:outline-none"
          >
            <Icon name="plus" size="18" />
          </button>
        </div>
      </div>

      <button
        @click="$emit('place-order')"
        class="w-full bg-black text-white py-3 rounded-full font-mono font-medium mt-4"
      >
        Confirmer la commande
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { CartItem } from '~/types'

const props = defineProps<{
  cart: CartItem[]
  isExpanded: boolean
}>()

defineEmits<{
  (e: 'remove', itemId: string, isIncrement?: boolean): void
  (e: 'place-order'): void
  (e: 'toggle'): void
}>()

const totalItems = computed(() => 
  props.cart.reduce((sum, item) => sum + item.quantity, 0)
)

const totalPrice = computed(() => 
  props.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
)
</script> 