<template>
  <div class="min-h-screen bg-gray-100 p-8">
    <div class="max-w-4xl mx-auto">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">WaitingLoader Test Suite</h1>

      <!-- Test Controls -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-8">
        <h2 class="text-xl font-semibold mb-4">Test Controls</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button
            @click="testStatus('loading')"
            class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Loading
          </button>
          <button
            @click="testStatus('pending')"
            class="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
          >
            Pending
          </button>
          <button
            @click="testStatus('confirmed')"
            class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Confirmed
          </button>
          <button
            @click="testStatus('processing')"
            class="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
          >
            Processing
          </button>
          <button
            @click="testStatus('completed')"
            class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
          >
            Completed
          </button>
        </div>
        <div class="mt-4">
          <button
            @click="toggleVisibility"
            class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
          >
            {{ isVisible ? 'Hide' : 'Show' }} Loader
          </button>
        </div>
      </div>

      <!-- WaitingLoader Component -->
      <WaitingLoader
        :is-visible="isVisible"
        :status="currentStatus"
        :message="currentMessage"
        :order="mockOrder"
        :order-number="'CMD-001'"
        :table-number="5"
        :establishment-name="'Restaurant Test'"
        @close="handleClose"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import WaitingLoader from '~/components/WaitingLoader.vue'

// Test state
const isVisible = ref(false)
const currentStatus = ref('loading')
const currentMessage = ref('Test message')

// Mock order data
const mockOrder = ref({
  id: 'test-order-123',
  table: 5,
  items: [
    { name: 'Burger', price: 15000, quantity: 2 },
    { name: 'Frites', price: 5000, quantity: 1 }
  ],
  total: 35000,
  status: 'confirmed',
  created_at: new Date().toISOString()
})

// Test functions
const testStatus = (status) => {
  currentStatus.value = status
  isVisible.value = true

  // Set appropriate messages for each status
  const messages = {
    loading: 'Nous transmettons votre commande à l\'établissement...',
    pending: 'Votre commande est en attente de confirmation par l\'établissement.',
    confirmed: 'Votre commande a été confirmée et va être préparée.',
    processing: 'Votre commande est en cours de traitement.',
    completed: 'Votre commande a été servie. Bon appétit !'
  }

  currentMessage.value = messages[status] || 'Statut inconnu'
}

const toggleVisibility = () => {
  isVisible.value = !isVisible.value
}

const handleClose = () => {
  isVisible.value = false
  console.log('WaitingLoader closed')
}
</script>