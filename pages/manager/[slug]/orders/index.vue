<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Commandes"
      subtitle="Gérez vos commandes en temps réel"
      :icon="Receipt"
      :primary-action="{
        label: 'Nouvelle commande',
        icon: Plus,
        action: openNewOrderModal
      }"
    />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
      <!-- Stats Cards - Responsive Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8">
        <div class="bg-white rounded-xl p-6  border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-gray-900 rounded-xl flex items-center justify-center">
              <Receipt class="w-6 h-6 text-white" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.total_orders || 0 }}</p>
              <p class="text-sm text-gray-500">Total</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6  border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-yellow-50 rounded-xl flex items-center justify-center">
              <Clock class="w-6 h-6 text-yellow-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.pending_orders || 0 }}</p>
              <p class="text-sm text-gray-500">Attente</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6  border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-orange-50 rounded-xl flex items-center justify-center">
              <Coffee class="w-6 h-6 text-orange-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.processing_orders || 0 }}</p>
              <p class="text-sm text-gray-500">Préparation</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6  border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-green-50 rounded-xl flex items-center justify-center">
              <CheckCircle class="w-6 h-6 text-green-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.completed_orders || 0 }}</p>
              <p class="text-sm text-gray-500">Terminées</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filtres - Mobile Friendly -->
      <div class="bg-white rounded-xl  border border-gray-100 p-6 mb-6">
        <div class="space-y-4">
          <!-- Header de filtres -->
          <div class="flex items-center gap-3 mb-4">
            <div class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
              <Filter class="w-4 h-4 text-gray-600" />
            </div>
            <h2 class="text-lg font-semibold text-gray-900">Filtres</h2>
          </div>

          <!-- Filtres en colonne sur mobile -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <select
              v-model="statusFilter"
              class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm font-medium focus:outline-none focus:border-gray-900 focus:ring-2 focus:ring-gray-900/10 transition-all bg-white hover:border-gray-300 cursor-pointer"
            >
              <option value="">Tous les statuts</option>
              <option value="pending">En attente</option>
              <option value="confirmed">Confirmée</option>
              <option value="processing">En traitement</option>
              <option value="completed">Terminée</option>
            </select>

            <select
              v-model="staffFilter"
              class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm font-medium focus:outline-none focus:border-gray-900 focus:ring-2 focus:ring-gray-900/10 transition-all bg-white hover:border-gray-300 cursor-pointer"
            >
              <option value="">Tout le staff</option>
              <option v-for="member in staff" :key="member.id" :value="member.id">
                {{ member.username }}
              </option>
            </select>

            <div class="relative">
              <Search class="w-4 h-4 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher..."
                class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm font-medium focus:outline-none focus:border-gray-900 focus:ring-2 focus:ring-gray-900/10 transition-all hover:border-gray-300"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Liste des commandes - Design épuré et responsive -->
      <div class="space-y-4">
        <!-- Order Card -->
        <div
          v-for="order in filteredOrders"
          :key="order.id"
          class="bg-white border border-gray-200 rounded-3xl p-5 hover:border-blue-300 transition-all cursor-pointer active:scale-[0.98]"
        >
          <div class="flex items-start gap-4">
            <!-- Order Avatar/Number -->
            <div class="w-14 h-14 bg-gradient-to-r from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white text-lg font-bold flex-shrink-0">
              {{ order.table_number }}
            </div>

            <!-- Info -->
            <div class="flex-1 min-w-0">
              <!-- Header -->
              <div class="flex items-center justify-between mb-2">
                <h3 class="text-base font-bold text-gray-900">
                  Commande #{{ order.orderNumber }}
                </h3>
                <span
                  :class="[
                    'px-3 py-1 rounded-full text-xs font-semibold',
                    getStatusClass(order.status)
                  ]"
                >
                  {{ getStatusText(order.status) }}
                </span>
              </div>
              
              <!-- Meta Info -->
              <div class="flex items-center gap-2 flex-wrap mb-3 text-xs text-gray-500">
                <span>📍 Table {{ order.table_number }}</span>
                <span>•</span>
                <span>🕐 {{ formatTime(order.created_at) }}</span>
                <span v-if="order.staff" class="flex items-center gap-1 text-blue-600 font-semibold">
                  <svg class="w-3 h-3" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" />
                  </svg>
                  {{ order.staff.username }}
                </span>
              </div>

              <!-- Items Preview -->
              <div class="space-y-2 mb-3">
                <div
                  v-for="item in order.items.slice(0, 2)"
                  :key="item.id"
                  class="flex items-center justify-between text-sm"
                >
                  <div class="flex items-center gap-2 flex-1 min-w-0">
                    <span class="font-medium text-gray-400 w-6">{{ item.quantity }}×</span>
                    <span class="text-gray-900 truncate">{{ item.name }}</span>
                  </div>
                  <span class="font-medium text-gray-900 ml-2">
                    {{ formatPrice(item.unit_price * item.quantity) }}
                  </span>
                </div>
                <div
                  v-if="order.items.length > 2"
                  class="text-xs text-gray-500 font-medium pl-8"
                >
                  +{{ order.items.length - 2 }} autres articles
                </div>
              </div>

              <!-- Footer -->
              <div class="flex items-center justify-between pt-3 border-t border-gray-100">
                <span class="text-lg font-bold text-gray-900">
                  {{ formatPrice(order.total_amount) }}
                </span>
                
                <!-- Actions -->
                <div class="flex items-center gap-2">
                  <button
                    v-if="canAcceptOrder(order.status)"
                    @click.stop="updateOrderStatus(order.id, 'confirmed')"
                    class="w-9 h-9 rounded-full hover:bg-green-50 flex items-center justify-center transition-colors group"
                    title="Accepter"
                  >
                    <svg class="w-5 h-5 text-gray-600 group-hover:text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                  </button>
                  
                  <button
                    v-if="canPrepareOrder(order.status)"
                    @click.stop="updateOrderStatus(order.id, 'processing')"
                    class="w-9 h-9 rounded-full hover:bg-orange-50 flex items-center justify-center transition-colors group"
                    title="Préparer"
                  >
                    <svg class="w-5 h-5 text-gray-600 group-hover:text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                  </button>
                  
                  <button
                    v-if="canCompleteOrder(order.status)"
                    @click.stop="updateOrderStatus(order.id, 'completed')"
                    class="w-9 h-9 rounded-full hover:bg-blue-50 flex items-center justify-center transition-colors group"
                    title="Terminer"
                  >
                    <svg class="w-5 h-5 text-gray-600 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </button>
                  
                  <button
                    @click.stop="printOrder(order)"
                    class="w-9 h-9 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors group"
                    title="Imprimer"
                  >
                    <svg class="w-5 h-5 text-gray-600 group-hover:text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
          
        </div>

        </div>
      <!-- Empty State -->
      <div v-if="filteredOrders.length === 0 && !loading" class="text-center py-12 sm:py-16">
        <div class="w-12 h-12 sm:w-16 sm:h-16 bg-gray-50 rounded-2xl sm:rounded-3xl flex items-center justify-center mx-auto mb-4">
          <Receipt class="w-6 h-6 sm:w-8 sm:h-8 text-gray-400" />
        </div>
        <h3 class="text-lg sm:text-xl font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-sm sm:text-base text-gray-500 mb-6 px-4">
          {{ orders.length === 0 ? 'Aucune commande n\'a encore été passée.' : 'Aucune commande ne correspond à vos critères.' }}
        </p>
        <button
          @click="openNewOrderModal"
          class="bg-black hover:bg-gray-800 text-white px-5 sm:px-6 py-2.5 sm:py-3 rounded-lg sm:rounded-xl text-sm sm:text-base font-medium transition-colors"
        >
          Créer une commande
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-12 sm:py-16">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-black"></div>
        <span class="ml-3 text-sm sm:text-base text-gray-600">Chargement...</span>
      </div>
    </main>

    <!-- Modal - Mobile Optimized -->
    <TransitionRoot appear :show="showNewOrderModal" as="template">
      <Dialog as="div" class="relative z-50" @close="closeModal">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/20 backdrop-blur-sm" />
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
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl sm:rounded-3xl bg-white border border-gray-200 shadow-2xl transition-all">
                <div class="p-6 sm:p-10">
                  <div class="flex items-center justify-between mb-6 sm:mb-8">
                    <h3 class="text-xl sm:text-2xl font-bold text-gray-900">Nouvelle commande</h3>
                    <button
                      @click="closeModal"
                      class="w-9 h-9 sm:w-10 sm:h-10 border border-gray-200 rounded-lg sm:rounded-xl flex items-center justify-center hover:bg-gray-100 transition-colors"
                    >
                      <X class="w-4 h-4 sm:w-5 sm:h-5" />
                    </button>
                  </div>

                  <form @submit.prevent="createNewOrder" class="space-y-5 sm:space-y-6">
                    <div>
                      <label class="block text-sm font-medium text-gray-900 mb-2 sm:mb-3 uppercase tracking-wider">
                        Numéro de table
                      </label>
                      <input
                        v-model.number="orderForm.table_number"
                        type="number"
                        required
                        min="1"
                        placeholder="5"
                        class="w-full px-3 sm:px-4 py-2.5 sm:py-3 border border-gray-200 rounded-lg sm:rounded-xl text-sm sm:text-base focus:outline-none focus:border-black transition-colors"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-900 mb-2 sm:mb-3 uppercase tracking-wider">
                        Notes
                      </label>
                      <textarea
                        v-model="orderForm.notes"
                        rows="4"
                        placeholder="Notes spéciales..."
                        class="w-full px-3 sm:px-4 py-2.5 sm:py-3 border border-gray-200 rounded-lg sm:rounded-xl text-sm sm:text-base focus:outline-none focus:border-black transition-colors resize-none"
                      />
                    </div>

                    <div class="flex gap-3 sm:gap-4 pt-2 sm:pt-4">
                      <button
                        type="button"
                        @click="closeModal"
                        class="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 border border-gray-200 rounded-lg sm:rounded-xl text-sm sm:text-base font-medium hover:bg-gray-50 transition-colors"
                      >
                        Annuler
                      </button>
                      <button
                        type="submit"
                        :disabled="creating"
                        class="flex-1 px-4 sm:px-6 py-2.5 sm:py-3 bg-black text-white rounded-lg sm:rounded-xl text-sm sm:text-base font-medium hover:bg-gray-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {{ creating ? 'Création...' : 'Créer' }}
                      </button>
                    </div>
                  </form>
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
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import { TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  Receipt, Plus, Clock, Coffee, CheckCircle, Filter, Search,
  Printer, User, X
} from 'lucide-vue-next'
import ManagerModernHeader from '~/components/manager/ModernHeader.vue'
import { useCustomToast } from '~/composables/useToast'
import { useSound } from '~/composables/useSound'
import { useSupabaseClient } from '#imports'

// Route and Supabase
const route = useRoute()
const supabase = useSupabaseClient()
const slug = route.params.slug
const { showToast } = useCustomToast()
const { playNewOrderSound } = useSound()

// State
const establishment = ref<any>(null)
const orders = ref<any[]>([])
const staff = ref<any[]>([])
const loading = ref<boolean>(true)
const searchQuery = ref<string>('')
const statusFilter = ref('')
const staffFilter = ref('')
const showNewOrderModal = ref(false)
const creating = ref(false)
const stats = ref<{
  total_orders: number
  pending_orders: number
  processing_orders: number
  completed_orders: number
} | null>(null)

// Form data
const orderForm = ref({
  table_number: null as number | null,
  notes: ''
})

// Item color functions - alternating colors for visual distinction
const getItemColorClass = (index: number) => {
  const colors = [
    'bg-blue-50 border border-blue-100',
    'bg-green-50 border border-green-100', 
    'bg-purple-50 border border-purple-100',
    'bg-orange-50 border border-orange-100',
    'bg-pink-50 border border-pink-100'
  ]
  return colors[index % colors.length]
}

const getItemBadgeClass = (index: number) => {
  const colors = [
    'bg-blue-500 text-white',
    'bg-green-500 text-white',
    'bg-purple-500 text-white',
    'bg-orange-500 text-white',
    'bg-pink-500 text-white'
  ]
  return colors[index % colors.length]
}

const getItemTextClass = (index: number) => {
  const colors = [
    'text-blue-900',
    'text-green-900',
    'text-purple-900',
    'text-orange-900',
    'text-pink-900'
  ]
  return colors[index % colors.length]
}

const getMoreItemsClass = () => {
  return 'text-gray-500'
}
const getStatusClass = (status: string) => {
  switch (status) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'confirmed':
      return 'bg-blue-100 text-blue-800'
    case 'processing':
      return 'bg-orange-100 text-orange-800'
    case 'completed':
      return 'bg-green-100 text-green-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}
// Computed
const filteredOrders = computed(() => {
  let filtered = orders.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order =>
      order.orderNumber.toString().includes(query) ||
      (order.table_number && order.table_number.toString().includes(query))
    )
  }

  if (statusFilter.value) {
    filtered = filtered.filter(order => order.status === statusFilter.value)
  }

  if (staffFilter.value) {
    filtered = filtered.filter(order => order.staff_id === staffFilter.value)
  }

  return filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

// Load establishment data
const loadEstablishment = async () => {
  try {
    if (!slug) {
      showToast.error('Erreur', 'URL invalide')
      return
    }
    
    const { data, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', slug)
    
    if (error) throw error
    
    if (!data || data.length === 0) {
      showToast.error('Erreur', 'Établissement introuvable')
      return
    }
    
    establishment.value = data[0]
    setupRealtimeSubscription()
  } catch (err) {
    console.error('Error loading establishment:', err)
    showToast.error('Erreur', 'Impossible de charger les données')
  }
}

// Load staff members
const loadStaff = async () => {
  if (!establishment.value?.id) return
  
  try {
    const { data, error } = await supabase
      .from('staff')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .eq('is_active', true)
      .not('username', 'is', null)
      .order('username')
    
    if (error) throw error
    staff.value = data || []
  } catch (err) {
    console.error('Error loading staff:', err)
    showToast.error('Erreur', 'Impossible de charger le staff')
  }
}

// Load orders
const loadOrders = async () => {
  if (!establishment.value?.id) return

  loading.value = true

  try {
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })

    if (ordersError) throw ordersError

    const processedOrders = await Promise.all(ordersData.map(async (order: any, index: number) => {
      try {
        const { data: itemsData, error: itemsError } = await supabase
          .from('order_items')
          .select('*')
          .eq('order_id', order.id)

        if (itemsError) throw itemsError

        const items = await Promise.all(itemsData.map(async (item: any) => {
          const { data: product } = await supabase
            .from('products')
            .select('name, description')
            .eq('id', item.product_id)
            .single()

          return {
            ...item,
            name: (product as any)?.name || 'Produit inconnu',
            description: (product as any)?.description || ''
          }
        }))

        let staffInfo = null
        if (order.staff_id) {
          try {
            const { data: staffData } = await supabase
              .from('staff')
              .select('id, username')
              .eq('id', order.staff_id)
              .single()

            staffInfo = staffData && (staffData as any).username ? staffData : null
          } catch (err) {
            staffInfo = null
          }
        }

        return {
          ...order,
          items,
          staff: staffInfo,
          orderNumber: 1000 + index
        }
      } catch (err) {
        return {
          ...order,
          items: [],
          staff: null,
          orderNumber: 1000 + index
        }
      }
    }))

    orders.value = processedOrders
    loadStats()
  } catch (err) {
    console.error('Error loading orders:', err)
    showToast.error('Erreur', 'Impossible de charger les commandes')
  } finally {
    loading.value = false
  }
}

const openNewOrderModal = () => {
  orderForm.value = { table_number: null, notes: '' }
  showNewOrderModal.value = true
}

const closeModal = () => {
  showNewOrderModal.value = false
}

const createNewOrder = async () => {
  if (!establishment.value?.id) return
  creating.value = true
  try {
    showToast.info('Fonction à implémenter', 'La création manuelle sera bientôt disponible')
    closeModal()
  } catch (error) {
    console.error('Error creating order:', error)
    showToast.error('Erreur', 'Impossible de créer la commande')
  } finally {
    creating.value = false
  }
}

const loadStats = () => {
  const total = orders.value.length
  const pending = orders.value.filter(o => o.status === 'pending').length
  const processing = orders.value.filter(o => ['confirmed', 'processing'].includes(o.status)).length
  const completed = orders.value.filter(o => o.status === 'completed').length

  stats.value = {
    total_orders: total,
    pending_orders: pending,
    processing_orders: processing,
    completed_orders: completed
  }
}

const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', orderId)

    if (error) throw error

    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }

    const order = orders.value.find((o: any) => o.id === orderId)
    showToast.success('Statut mis à jour', `Commande #${order?.orderNumber || orderId.slice(-6)} ${getStatusMessage(newStatus)}`)
    loadStats()
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const assignOrderToStaff = async (orderId: string, staffId: string) => {
  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({ staff_id: staffId || null, updated_at: new Date().toISOString() })
      .eq('id', orderId)

    if (error) throw error

    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].staff_id = staffId || null
      if (staffId) {
        const staffMember = staff.value.find((s: any) => s.id === staffId)
        orders.value[index].staff = staffMember
      } else {
        orders.value[index].staff = null
      }
    


      // Update staff object
      if (staffId) {
        const staffMember = staff.value.find((s: any) => s.id === staffId)
        orders.value[index].staff = staffMember
        console.log('✅ Staff assigned:', staffMember)
      } else {
        orders.value[index].staff = null
        console.log('✅ Staff assignment removed')
      }
    }

    const staffMember = staffId ? staff.value.find((s: any) => s.id === staffId) : null
    const message = staffMember && staffMember.username
      ? `Commande assignée à ${staffMember.username}`
      : 'Assignation supprimée'

    showToast.success('Assignation mise à jour', message)
  } catch (err) {
    console.error('Error assigning order to staff:', err)
    showToast.error('Erreur', 'Impossible d\'assigner la commande')
  }
}

// Print orders
const printOrders = () => {
  // For now, just show a toast - could be expanded to print all orders
  showToast.info('Impression', 'Fonction d\'impression à implémenter')
}

// Refresh data
const refreshData = async () => {
  await Promise.all([
    loadOrders(),
    loadStaff()
  ])
}

// Format time
const formatTime = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Staff options for assignment
const staffOptions = computed(() => {
  const options = staff.value
    .filter((member: any) => member && member.username) // Filter out invalid members
    .map((member: any) => ({
      id: member.id,
      username: member.username || 'Unknown',
      label: member.username || 'Unknown',
      disabled: !member.is_active
    }))

  console.log('📋 Staff options:', options)
  return options
})

// Print order
const printOrder = (order: any) => {
  // Create a printable version of the order
  const printWindow = window.open('', '', 'width=800,height=600')

  if (!printWindow) {
    showToast.error('Erreur', 'Impossible d\'ouvrir la fenêtre d\'impression')
    return
  }

  printWindow.document.write(`
    <html>
      <head>
        <title>Commande #${order.orderNumber}</title>
        <style>
          body { font-family: system-ui, -apple-system, sans-serif; padding: 20px; }
          h1 { margin-bottom: 10px; }
          .header { margin-bottom: 20px; }
          .items { margin-top: 20px; border-top: 1px solid #eee; padding-top: 20px; }
          .item { padding: 10px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; }
          .total { margin-top: 20px; font-weight: bold; text-align: right; }
          .notes { margin-top: 20px; font-style: italic; }
          .info { color: #666; font-size: 14px; margin: 5px 0; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Commande #${order.orderNumber}</h1>
          <p class="info">Date: ${formatDate(order.created_at)}</p>
          <p class="info">Table: ${order.table_number || 'N/A'}</p>
          <p class="info">Statut: ${getStatusText(order.status)}</p>
        </div>

        <div class="items">
          <h2>Articles commandés</h2>
          ${(order.items || []).map((item: any) => `
            <div class="item">
              <div>
                <strong>${item.quantity || 0}x</strong> ${item.name || 'Produit inconnu'}
                ${item.notes ? `<p><small>Note: ${item.notes}</small></p>` : ''}
              </div>
              <div>${formatPrice((item.unit_price || 0) * (item.quantity || 0))}</div>
            </div>
          `).join('')}
        </div>

        <div class="total">
          Total: ${formatPrice(order.total_amount)}
        </div>

        ${order.notes ? `
          <div class="notes">
            <p><strong>Notes:</strong> ${order.notes}</p>
          </div>
        ` : ''}
      </body>
    </html>
  `)

  printWindow.document.close()
  printWindow.focus()

  // Print after a short delay to ensure content is loaded
  setTimeout(() => {
    printWindow.print()
    printWindow.close()
  }, 500)
}

// Utility functions
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const getStatusBadgeClass = (status: string) => {
  const classes: Record<string, string> = {
    'pending': 'bg-yellow-100 text-yellow-800',
    'confirmed': 'bg-blue-100 text-blue-800',
    'processing': 'bg-orange-100 text-orange-800',
    'completed': 'bg-green-100 text-green-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'processing': 'En traitement',
    'completed': 'Terminée'
  }
  return texts[status] || status
}

const getStatusMessage = (status: string) => {
  const messages: Record<string, string> = {
    'pending': 'est en attente',
    'confirmed': 'a été confirmée',
    'processing': 'est en traitement',
    'completed': 'est terminée'
  }
  return messages[status] || 'a changé de statut'
}

const canAcceptOrder = (status: string) => status === 'pending'
const canPrepareOrder = (status: string) => status === 'confirmed'
const canCompleteOrder = (status: string) => status === 'processing'

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// SetUp realtime subscription
let subscription: any
const setupRealtimeSubscription = () => {
  if (!establishment.value?.id) return

  // Cancel any existing subscription
  if (subscription) {
    subscription.unsubscribe()
  }

  // Create new subscription for order updates
  subscription = supabase
    .channel(`orders-${establishment.value.id}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `establishment_id=eq.${establishment.value.id}`
      },
      (payload) => {
        // Handle new or updated orders
        if (payload.eventType === 'INSERT') {
          // Play sound notification for new orders
          playNewOrderSound()
          // Add new order to the list
          showToast.success('Nouvelle commande', 'Une nouvelle commande a été reçue')
          loadOrders() // Reload all orders to get the complete data
        } else if (payload.eventType === 'UPDATE') {
          // Update existing order
          const index = orders.value.findIndex(o => o.id === payload.new.id)
          if (index !== -1) {
            orders.value[index] = { ...orders.value[index], ...payload.new }
            loadStats() // Refresh stats
          }
        }
      }
    )
    .subscribe()
}

// Clean up on component unmount
onUnmounted(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

// Watch establishment changes to set up realtime subscription
watch(establishment, (newValue) => {
  if (newValue) {
    setupRealtimeSubscription()
  }
})

// Lifecycle
onMounted(async () => {
  try {
    loading.value = true
    await loadEstablishment()

    // Vérifier si l'établissement a été chargé avec succès
    if (establishment.value) {
      await Promise.all([
        loadOrders(),
        loadStaff()
      ])
    }
  } catch (err) {
    console.error('Error initializing page:', err)
    showToast.error('Erreur', 'Impossible de charger la page')
  } finally {
    loading.value = false
  }
})

// Watch for establishment changes to set up realtime subscription
watch(() => establishment.value?.id, async (newId, oldId) => {
  if (newId && newId !== oldId) {
    await Promise.all([
      loadOrders(),
      loadStaff()
    ])
  }
})

// Watch for route changes to reload data
watch(() => route.path, async (newPath, oldPath) => {
  console.log('🔄 Route changed, reloading orders data for path:', newPath)
  try {
    loading.value = true
    await loadEstablishment()

    if (establishment.value) {
      await Promise.all([
        loadOrders(),
        loadStaff()
      ])
    }
  } catch (err) {
    console.error('Error reloading data:', err)
    showToast.error('Erreur', 'Impossible de recharger les données')
  } finally {
    loading.value = false
  }
}, { immediate: true })

// Define page meta
definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style> 