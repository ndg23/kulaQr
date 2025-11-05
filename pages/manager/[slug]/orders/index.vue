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

    <main class="max-w-7xl mx-auto px-8 pb-16 mt-2">
      <!-- Stats Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
              <Receipt class="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.total_orders || 0 }}</p>
              <p class="text-sm text-gray-500">Total commandes</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-yellow-50 rounded-xl flex items-center justify-center">
              <Clock class="w-6 h-6 text-yellow-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.pending_orders || 0 }}</p>
              <p class="text-sm text-gray-500">En attente</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-orange-50 rounded-xl flex items-center justify-center">
              <Coffee class="w-6 h-6 text-orange-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.processing_orders || 0 }}</p>
              <p class="text-sm text-gray-500">En préparation</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
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

      <!-- Filters -->
      <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
          <div class="flex items-center gap-2">
            <Filter class="w-5 h-5 text-gray-400" />
            <span class="text-sm font-medium text-gray-700">Filtrer par:</span>
          </div>

          <select
            v-model="statusFilter"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tous les statuts</option>
            <option value="pending">En attente</option>
            <option value="confirmed">Confirmée</option>
            <option value="processing">En traitement</option>
            <option value="completed">Terminée</option>
          </select>

          <select
            v-model="staffFilter"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tout le staff</option>
            <option v-for="member in staff" :key="member.id" :value="member.id">
              {{ member.username }}
            </option>
          </select>

          <div class="relative flex-1 max-w-sm">
            <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              v-model="searchQuery"
              @input="applyFilters"
              type="text"
              placeholder="Rechercher par numéro de commande..."
              class="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      <!-- Orders List -->
      <div class="space-y-4">
        <div
          v-for="order in filteredOrders"
          :key="order.id"
          class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h3 class="text-lg font-semibold text-gray-900">#{{ order.orderNumber }}</h3>
                <span
                  :class="getStatusBadgeClass(order.status)"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ getStatusText(order.status) }}
                </span>
                <span class="text-sm text-gray-500">Table {{ order.table_number || 'N/A' }}</span>
              </div>

              <!-- Staff Assignment -->
              <div class="flex items-center gap-2 mb-3">
                <User class="w-4 h-4 text-gray-400" />
                <span class="text-sm text-gray-600">Staff:</span>
                <select
                  v-model="order.staff_id"
                  @change="assignOrderToStaff(order.id, $event.target.value)"
                  class="text-sm border border-gray-200 rounded px-2 py-1 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="">Non assigné</option>
                  <option v-for="member in staff" :key="member.id" :value="member.id">
                    {{ member.username }}
                  </option>
                </select>
              </div>

              <!-- Order Items -->
              <div class="space-y-2 mb-3">
                <div
                  v-for="item in (order.items || []).slice(0, 3)"
                  :key="item.id"
                  class="flex items-center justify-between text-sm"
                >
                  <span class="text-gray-600">
                    {{ item.quantity || 0 }}x {{ item.name || 'Produit inconnu' }}
                  </span>
                  <span class="font-medium">{{ formatPrice((item.unit_price || 0) * (item.quantity || 0)) }}</span>
                </div>
                <div v-if="(order.items || []).length > 3" class="text-xs text-gray-400">
                  +{{ (order.items || []).length - 3 }} autres articles
                </div>
              </div>

              <div class="flex items-center gap-4 text-sm text-gray-500">
                <span>Total: <strong class="text-gray-900">{{ formatPrice(order.total_amount) }}</strong></span>
                <span>{{ formatDate(order.created_at) }}</span>
              </div>
            </div>

            <div class="flex items-center gap-2 ml-4">
              <button
                v-if="canAcceptOrder(order.status)"
                @click="updateOrderStatus(order.id, 'confirmed')"
                class="p-2 text-green-600 hover:text-green-700 hover:bg-green-50 rounded-lg transition-colors"
                title="Accepter"
              >
                <CheckCircle class="w-5 h-5" />
              </button>
              <button
                v-if="canPrepareOrder(order.status)"
                @click="updateOrderStatus(order.id, 'processing')"
                class="p-2 text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
                title="Préparer"
              >
                <Coffee class="w-5 h-5" />
              </button>
              <button
                v-if="canCompleteOrder(order.status)"
                @click="updateOrderStatus(order.id, 'completed')"
                class="p-2 text-gray-600 hover:text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
                title="Terminer"
              >
                <CheckCircle class="w-5 h-5" />
              </button>
              <button
                @click="printOrder(order)"
                class="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg transition-colors"
                title="Imprimer"
              >
                <Printer class="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="filteredOrders.length === 0 && !loading" class="text-center py-16">
        <div class="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
          <Receipt class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune commande</h3>
        <p class="text-gray-500 mb-6">
          {{ orders.length === 0 ? 'Aucune commande n\'a encore été passée.' : 'Aucune commande ne correspond à vos critères.' }}
        </p>
        <button
          @click="openNewOrderModal"
          class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-xl font-medium transition-colors shadow-sm hover:shadow-md"
        >
          Créer une commande
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-16">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        <span class="ml-3 text-gray-600">Chargement des commandes...</span>
      </div>
    </main>

    <!-- New Order Modal -->
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
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
                <div class="p-6">
                  <div class="flex items-center justify-between mb-6">
                    <h3 class="text-lg font-semibold text-gray-900">
                      Nouvelle commande
                    </h3>
                    <button
                      @click="closeModal"
                      class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100"
                    >
                      <X class="w-5 h-5" />
                    </button>
                  </div>

                  <form @submit.prevent="createNewOrder" class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Numéro de table *
                      </label>
                      <input
                        v-model.number="orderForm.table_number"
                        type="number"
                        required
                        min="1"
                        placeholder="Ex: 5"
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Notes (optionnel)
                      </label>
                      <textarea
                        v-model="orderForm.notes"
                        rows="3"
                        placeholder="Notes spéciales pour la commande..."
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                      ></textarea>
                    </div>

                    <div class="flex gap-3 pt-4">
                      <button
                        type="button"
                        @click="closeModal"
                        class="flex-1 px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                      >
                        Annuler
                      </button>
                      <button
                        type="submit"
                        :disabled="creating"
                        class="flex-1 px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
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
  Printer, User, X, Loader2
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseClient } from '#imports'

// Route and Supabase
const route = useRoute()
const supabase = useSupabaseClient()
const slug = route.params.slug
const { showToast } = useCustomToast()

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
const stats = ref(null)

// Form data
const orderForm = ref({
  table_number: null as number | null,
  notes: ''
})

// Computed
const filteredOrders = computed(() => {
  let filtered = orders.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order =>
      order.orderNumber.toString().includes(query) ||
      (order.table_number && order.table_number.toString().includes(query))
    )
  }

  // Status filter
  if (statusFilter.value) {
    filtered = filtered.filter(order => order.status === statusFilter.value)
  }

  // Staff filter
  if (staffFilter.value) {
    filtered = filtered.filter(order => order.staff_id === staffFilter.value)
  }

  return filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

// Load establishment data
const loadEstablishment = async () => {
  try {
    // Vérifier si le slug est valide
    if (!slug) {
      showToast.error('Erreur', 'URL invalide')
      return
    }
    
    console.log('🏢 Loading establishment with slug:', slug)
    
    // Récupérer l'établissement sans utiliser .single() initialement
    const { data, error } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', slug)
    
    if (error) throw error
    
    // Vérifier si des données ont été trouvées
    if (!data || data.length === 0) {
      showToast.error('Erreur', 'Établissement introuvable')
      return
    }
    
    // Assigner le premier résultat
    establishment.value = data[0]
    console.log('✅ Establishment loaded:', establishment.value)
    
    // Une fois l'établissement chargé, configurer la subscription
    setupRealtimeSubscription()
  } catch (err) {
    console.error('Error loading establishment:', err)
    showToast.error('Erreur', 'Impossible de charger les données de l\'établissement')
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
    
    console.log('👥 Staff members loaded:', data)
    staff.value = data || []
  } catch (err) {
    console.error('Error loading staff:', err)
    showToast.error('Erreur', 'Impossible de charger les membres du staff')
  }
}

// Load orders
const loadOrders = async () => {
  if (!establishment.value?.id) return

  loading.value = true

  try {
    // Get all orders for this establishment
    const { data: ordersData, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })

    if (ordersError) throw ordersError

    console.log('📦 Orders data received:', ordersData)

    // Process orders with their items and staff info
    const processedOrders = await Promise.all(ordersData.map(async (order: any, index: number) => {
      try {
        // Get items for this order
        const { data: itemsData, error: itemsError } = await supabase
          .from('order_items')
          .select('*')
          .eq('order_id', order.id)

        if (itemsError) throw itemsError

        // Format each item with product details
        const items = await Promise.all(itemsData.map(async (item: any) => {
          // Get product details
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

        // Get staff info if assigned
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
            console.warn(`Could not load staff info for order ${order.id}:`, err)
            staffInfo = null
          }
        }

        const processedOrder = {
          ...order,
          items,
          staff: staffInfo,
          orderNumber: 1000 + index
        }

        console.log('🔄 Processed order:', processedOrder)
        return processedOrder
      } catch (err) {
        console.error(`Error loading items for order ${order.id}:`, err)
        return {
          ...order,
          items: [],
          staff: null,
          orderNumber: 1000 + index
        }
      }
    }))

    console.log('✅ Final processed orders:', processedOrders)
    orders.value = processedOrders
    loadStats() // Calculate stats after loading orders
  } catch (err) {
    console.error('Error loading orders:', err)
    showToast.error('Erreur', 'Impossible de charger les commandes')
  } finally {
    loading.value = false
  }
}

// Methods
const openNewOrderModal = () => {
  orderForm.value = {
    table_number: null,
    notes: ''
  }
  showNewOrderModal.value = true
}

const closeModal = () => {
  showNewOrderModal.value = false
}

const createNewOrder = async () => {
  if (!establishment.value?.id) return

  creating.value = true
  try {
    // This would typically create a new order, but for now we'll just show a message
    // In a real implementation, you'd have a proper order creation flow
    showToast.info('Fonction à implémenter', 'La création de commande manuelle sera bientôt disponible')
    closeModal()
  } catch (error) {
    console.error('Error creating order:', error)
    showToast.error('Erreur', 'Impossible de créer la commande')
  } finally {
    creating.value = false
  }
}

const applyFilters = () => {
  // Filters are applied reactively through computed property
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

// Update order status
const updateOrderStatus = async (orderId: string, newStatus: string) => {
  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    // Update local state
    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].status = newStatus
    }

    const order = orders.value.find((o: any) => o.id === orderId)
    showToast.success('Statut mis à jour', `Commande #${order?.orderNumber || orderId.slice(-6)} ${getStatusMessage(newStatus)}`)
    loadStats() // Refresh stats
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

// Assign order to staff member
const assignOrderToStaff = async (orderId: string, staffId: string) => {
  console.log('👤 Assigning order', orderId, 'to staff', staffId)

  try {
    const { error } = await (supabase as any)
      .from('orders')
      .update({
        staff_id: staffId || null,
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    // Update local state
    const index = orders.value.findIndex((o: any) => o.id === orderId)
    if (index !== -1) {
      orders.value[index].staff_id = staffId || null

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