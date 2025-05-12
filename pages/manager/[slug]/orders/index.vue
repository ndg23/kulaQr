<template>
  <div class="min-h-screen bg-[#F5F5F7]">
    <!-- En-tête avec effet glassmorphism amélioré -->
    <header class="sticky top-0 z-50 backdrop-blur-xl bg-white/70 border-b border-gray-200/50">
      <div class="max-w-[1600px] mx-auto px-6 py-5">
        <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
          <div class="max-w-2xl">
            <div class="flex items-center gap-3 mb-2">
              <h1 class="text-3xl font-semibold text-gray-900">Commandes</h1>
              <div class="flex items-center gap-2 px-3 py-1 bg-gray-900/5 rounded-full">
                <div class="w-2 h-2 rounded-full bg-green-500"></div>
                <span class="text-sm font-medium text-gray-600">{{ filteredOrders.length }} commandes</span>
              </div>
            </div>
            <p class="text-base text-gray-500">Gérez vos commandes en temps réel. Les mises à jour sont instantanées.</p>
          </div>
          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <div class="relative flex-1 sm:flex-none">
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher une commande..."
                class="w-full sm:w-64 pl-10 pr-4 h-11 rounded-xl bg-white shadow-sm border border-gray-200/50 focus:ring-2 focus:ring-gray-900/10 focus:border-transparent transition-all"
              />
              <Search class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
            </div>
            <button 
              @click="toggleFilters"
              class="h-11 px-6 bg-gray-900/5 hover:bg-gray-900/10 text-gray-700 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2"
              :class="{ 'bg-gray-900 text-white': showFilters }"
            >
              <Filter class="w-4 h-4" />
              Filtres
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Filtres -->
    <div 
      v-if="showFilters"
      class="bg-white/70 backdrop-blur-xl border-b border-gray-200/50"
    >
      <div class="max-w-[1600px] mx-auto px-6 py-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-xs font-medium text-gray-500 mb-2">Statut</label>
            <select 
              v-model="statusFilter" 
              class="w-full h-11 rounded-xl border-gray-200/50 text-sm focus:ring-gray-900/10 bg-white/50"
            >
              <option value="all">Tous les statuts</option>
              <option value="pending">En attente</option>
              <option value="preparing">En préparation</option>
              <option value="ready">Prêtes</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <main class="max-w-[1600px] mx-auto px-6 py-8">
      <!-- Liste des commandes -->
      <TransitionGroup 
        name="list" 
        class="space-y-4"
        tag="div"
      >
        <div 
          v-for="order in filteredOrders" 
          :key="order.id"
          class="group bg-white rounded-xl border border-gray-200/50 overflow-hidden hover:shadow-lg transition-all duration-300"
        >
          <!-- En-tête commande -->
          <div class="p-5 flex items-center justify-between border-b border-gray-100">
            <div class="flex items-center gap-4">
              <div 
                class="w-12 h-12 rounded-xl flex items-center justify-center"
                :class="getStatusColor(order.status).bg"
              >
                <component 
                  :is="getStatusIcon(order.status)" 
                  class="w-6 h-6"
                  :class="getStatusColor(order.status).text" 
                />
              </div>
              <div>
                <div class="flex items-center gap-3">
                  <span class="text-xl font-bold text-gray-900">#{{ order.orderNumber }}</span>
                  <span class="px-3 py-1 rounded-full text-xs font-medium"
                    :class="getStatusColor(order.status).badge"
                  >
                    {{ translateStatus(order.status) }}
                  </span>
                </div>
                <div class="mt-1 text-sm text-gray-500 flex items-center gap-2">
                  <span>Table {{ order.table }}</span>
                  <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                  <span>{{ formatTime(order.created_at) }}</span>
                </div>
              </div>
            </div>
            <span class="text-lg font-bold text-gray-900">{{ formatPrice(order.total) }}</span>
          </div>

          <!-- Articles -->
          <div class="divide-y divide-gray-50">
            <div 
              v-for="item in order.items" 
              :key="item.id"
              class="p-4 flex items-center gap-4 group-hover:bg-gray-50/50 transition-colors"
            >
              <div class="bg-gray-100 w-10 h-10 rounded-xl flex items-center justify-center font-medium text-gray-900">
                {{ item.quantity }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="font-medium text-gray-900">{{ item.name }}</div>
                <div v-if="item.note" class="text-sm text-gray-500 mt-0.5">{{ item.note }}</div>
              </div>
              <span class="text-sm font-medium text-gray-900">
                {{ formatPrice(item.price * item.quantity) }}
              </span>
            </div>
          </div>

          <!-- Actions -->
          <div class="p-4 bg-gray-50/50 flex justify-end gap-2">
            <button 
              v-if="order.status === 'pending'"
              @click="updateOrderStatus(order.id, 'preparing')"
              class="h-10 px-4 bg-gray-900 text-white rounded-xl text-sm font-medium hover:bg-gray-800 active:scale-95 transition-all flex items-center gap-2"
            >
              <ChefHat class="w-4 h-4" />
              Accepter
            </button>
            <button 
              v-if="order.status === 'preparing'"
              @click="updateOrderStatus(order.id, 'ready')"
              class="h-10 px-4 bg-green-600 text-white rounded-xl text-sm font-medium hover:bg-green-700 active:scale-95 transition-all flex items-center gap-2"
            >
              <Check class="w-4 h-4" />
              Prête
            </button>
          </div>
        </div>
      </TransitionGroup>

      <!-- État vide -->
      <div 
        v-if="filteredOrders.length === 0" 
        class="text-center py-16 bg-white rounded-xl border border-gray-200/50"
      >
        <div class="w-20 h-20 mx-auto mb-4 rounded-xl bg-gray-50 flex items-center justify-center">
          <ClipboardCheck class="w-10 h-10 text-gray-300" />
        </div>
        <h3 class="text-lg font-medium text-gray-900">Aucune commande</h3>
        <p class="text-sm text-gray-500 mt-2">Les nouvelles commandes apparaîtront ici</p>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  ClipboardCheck,
  ChefHat,
  Check,
  Search,
  Filter,
  Coffee,
  Clock
} from 'lucide-vue-next'
import type { Order, OrderStatus } from '~/types'

// State
const orders = ref<Order[]>([])
const searchQuery = ref('')
const showFilters = ref(false)
const statusFilter = ref('all')

// Computed
const filteredOrders = computed(() => {
  let filtered = [...orders.value]
  
  // Filter by status
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter(order => order.status === statusFilter.value)
  }
  
  // Filter by search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => 
      order.orderNumber.toLowerCase().includes(query) ||
      order.table.toString().includes(query)
    )
  }
  
  return filtered
})

// Methods
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

const formatTime = (dateString: string) => {
  const now = new Date()
  const orderTime = new Date(dateString)
  const diffMinutes = Math.floor((now.getTime() - orderTime.getTime()) / (1000 * 60))
  
  if (diffMinutes < 1) return 'À l\'instant'
  if (diffMinutes === 1) return 'Il y a 1 min'
  if (diffMinutes < 60) return `Il y a ${diffMinutes} min`
  
  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours === 1) return 'Il y a 1h'
  return `Il y a ${diffHours}h`
}

const translateStatus = (status: OrderStatus): string => {
  const translations: Record<OrderStatus, string> = {
    'pending': 'Nouvelle',
    'accepted': 'Acceptée',
    'preparing': 'En préparation',
    'ready': 'Prête',
    'completed': 'Terminée',
    'rejected': 'Refusée'
  }
  return translations[status]
}

const getStatusColor = (status: OrderStatus) => {
  const colors: Record<OrderStatus, { bg: string; text: string; badge: string }> = {
    'pending': { bg: 'bg-yellow-50', text: 'text-yellow-700', badge: 'bg-yellow-100 text-yellow-800' },
    'accepted': { bg: 'bg-blue-50', text: 'text-blue-700', badge: 'bg-blue-100 text-blue-800' },
    'preparing': { bg: 'bg-blue-50', text: 'text-blue-700', badge: 'bg-blue-100 text-blue-800' },
    'ready': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100 text-green-800' },
    'completed': { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100 text-green-800' },
    'rejected': { bg: 'bg-red-50', text: 'text-red-700', badge: 'bg-red-100 text-red-800' }
  }
  return colors[status]
}

const getStatusIcon = (status: OrderStatus) => {
  const icons = {
    'pending': Coffee,
    'accepted': Check,
    'preparing': ChefHat,
    'ready': Check,
    'completed': Check,
    'rejected': Clock
  }
  return icons[status]
}

const updateOrderStatus = (id: string, newStatus: OrderStatus) => {
  // Implementation of updateOrderStatus method
}

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
.list-enter-active,
.list-leave-active {
  transition: all 0.3s ease;
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
</style> 