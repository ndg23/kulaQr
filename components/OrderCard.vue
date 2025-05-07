<script setup lang="ts">
const props = defineProps<{
  order: Order
}>()

const emit = defineEmits<{
  (e: 'update-status', orderId: string, status: OrderStatus): void
}>()

const statusColors = {
  pending: 'bg-blue-50 border-blue-200',
  preparing: 'bg-yellow-50 border-yellow-200',
  ready: 'bg-green-50 border-green-200',
  completed: 'bg-gray-50 border-gray-200'
}

const statusLabels = {
  pending: 'Nouvelle',
  preparing: 'En préparation',
  ready: 'Prête',
  completed: 'Terminée'
}
</script>

<template>
  <div 
    class="bg-white rounded-lg border overflow-hidden shadow-sm hover:shadow-md transition-shadow"
    :class="statusColors[order.status]"
  >
    <!-- Header -->
    <div class="p-4 border-b">
      <div class="flex items-center justify-between">
        <div>
          <span class="text-lg font-bold">#{{ order.orderNumber }}</span>
          <div class="flex items-center mt-1 text-sm text-gray-500">
            <Coffee class="w-4 h-4 mr-1" />
            Table {{ order.table }}
          </div>
        </div>
        <div class="text-right">
          <span class="text-sm font-medium">{{ formatTime(order.created_at) }}</span>
          <div class="text-sm text-gray-500">{{ getTimeAgo(order.created_at) }}</div>
        </div>
      </div>
    </div>

    <!-- Items -->
    <div class="p-4 space-y-2">
      <div 
        v-for="item in order.items" 
        :key="item.id"
        class="flex justify-between text-sm"
      >
        <div>
          <span class="font-medium">{{ item.quantity }}x</span>
          {{ item.name }}
        </div>
        <span class="text-gray-600">{{ formatPrice(item.price * item.quantity) }}</span>
      </div>
    </div>

    <!-- Footer -->
    <div class="p-4 bg-gray-50 border-t flex items-center justify-between">
      <span class="font-bold">{{ formatPrice(order.total) }}</span>
      <div class="flex gap-2">
        <button
          v-if="order.status === 'pending'"
          @click="emit('update-status', order.id, 'preparing')"
          class="px-3 py-1.5 bg-blue-500 text-white rounded-md text-sm font-medium hover:bg-blue-600"
        >
          Préparer
        </button>
        <button
          v-if="order.status === 'preparing'"
          @click="emit('update-status', order.id, 'ready')"
          class="px-3 py-1.5 bg-green-500 text-white rounded-md text-sm font-medium hover:bg-green-600"
        >
          Terminer
        </button>
      </div>
    </div>
  </div>
</template> 