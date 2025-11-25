<template>
  <div class="p-6 lg:p-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-2">
        <NuxtLink 
          to="/admin/orders"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
          <ArrowLeft class="w-5 h-5" />
        </NuxtLink>
        <div class="flex-1">
          <h1 class="text-3xl font-bold text-gray-900">Commande #{{ order.id?.slice(0, 8) }}</h1>
          <p class="text-gray-600">Détails et gestion de la commande</p>
        </div>
        <button
          @click="loadOrder"
          :disabled="isLoading"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
          <RefreshCw class="w-5 h-5" :class="{ 'animate-spin': isLoading }" />
        </button>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
      <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
      <p class="text-gray-500">Chargement des détails de la commande...</p>
    </div>

    <!-- Content -->
    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Left Column - Order Details -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Order Info Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Informations de la commande</h3>
          
          <div class="grid grid-cols-2 gap-4">
            <div>
              <p class="text-sm text-gray-600 mb-1">ID de la commande</p>
              <p class="font-mono text-sm text-gray-900">{{ order.id }}</p>
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-1">Numéro de l'emplacement</p>
              <p class="font-semibold text-gray-900">N° {{ order.table_number }}</p>
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-1">Date de création</p>
              <p class="font-semibold text-gray-900">{{ formatDateTime(order.created_at) }}</p>
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-1">Dernière mise à jour</p>
              <p class="font-semibold text-gray-900">{{ formatDateTime(order.updated_at) }}</p>
            </div>
            
            <div v-if="order.staff_id" class="col-span-2">
              <p class="text-sm text-gray-600 mb-1">Serveur assigné</p>
              <div class="flex items-center gap-2">
                <UserCheck class="w-4 h-4 text-gray-400" />
                <p class="font-semibold text-gray-900">{{ order.staff_name || 'Staff inconnu' }}</p>
              </div>
            </div>
            
            <div v-if="order.notes" class="col-span-2">
              <p class="text-sm text-gray-600 mb-1">Notes</p>
              <p class="text-gray-900 bg-gray-50 rounded-lg p-3">{{ order.notes }}</p>
            </div>
          </div>
        </div>

        <!-- Establishment Info -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Store class="w-5 h-5" />
            Établissement
          </h3>
          
          <div v-if="establishment">
            <div class="flex items-start gap-4 mb-4">
              <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center flex-shrink-0">
                <Store class="w-8 h-8 text-white" />
              </div>
              <div class="flex-1">
                <h4 class="font-semibold text-gray-900 mb-1">{{ establishment.name }}</h4>
                <p v-if="establishment.address" class="text-sm text-gray-600 mb-2">{{ establishment.address }}</p>
                <div class="flex items-center gap-2 flex-wrap">
                  <span
                    class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold"
                    :class="{
                      'bg-green-50 text-green-700 border border-green-200': establishment.is_active,
                      'bg-gray-50 text-gray-600 border border-gray-200': !establishment.is_active
                    }"
                  >
                    {{ establishment.is_active ? 'Actif' : 'Inactif' }}
                  </span>
                  <NuxtLink
                    :to="`/admin/establishments/${establishment.id}`"
                    class="text-sm text-blue-600 hover:text-blue-700 font-medium"
                  >
                    Voir l'établissement →
                  </NuxtLink>
                </div>
              </div>
            </div>

            <!-- Owner Status Alert -->
            <div v-if="owner" class="border-t border-gray-100 pt-4">
              <div class="flex items-start gap-3">
                <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0">
                  <UserCheck class="w-5 h-5 text-gray-600" />
                </div>
                <div class="flex-1">
                  <div class="flex items-center justify-between mb-1">
                    <p class="text-sm font-medium text-gray-700">Propriétaire</p>
                    <span
                      class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold"
                      :class="{
                        'bg-green-50 text-green-700 border border-green-200': owner.is_active,
                        'bg-red-50 text-red-700 border border-red-200': !owner.is_active
                      }"
                    >
                      <div 
                        class="w-1.5 h-1.5 rounded-full mr-1.5"
                        :class="owner.is_active ? 'bg-green-500' : 'bg-red-500'"
                      />
                      {{ owner.is_active ? 'Actif' : 'Bloqué' }}
                    </span>
                  </div>
                  <p class="text-sm text-gray-900">{{ owner.full_name || 'Nom non renseigné' }}</p>
                  <p class="text-xs text-gray-500">{{ owner.email }}</p>
                  
                  <!-- Warning if owner is blocked -->
                  <div v-if="!owner.is_active" class="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <div class="flex items-start gap-2">
                      <AlertCircle class="w-4 h-4 text-red-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <p class="text-xs font-semibold text-red-900">Propriétaire bloqué</p>
                        <p class="text-xs text-red-700 mt-1">
                          Cet établissement ne peut plus recevoir de nouvelles commandes. 
                          Les commandes en attente ont été automatiquement annulées.
                        </p>
                      </div>
                    </div>
                  </div>

                  <!-- Info if both are active -->
                  <div v-else-if="owner.is_active && establishment.is_active" class="mt-3 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <div class="flex items-start gap-2">
                      <CheckCircle class="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                      <p class="text-xs text-green-700">
                        Cet établissement peut recevoir des commandes normalement.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="text-center py-4 text-gray-500">
            <Store class="w-8 h-8 mx-auto mb-2 text-gray-300" />
            <p>Établissement introuvable</p>
          </div>
        </div>

        <!-- Order Items -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Articles commandés</h3>
          
          <div v-if="orderItems.length > 0" class="space-y-3">
            <div
              v-for="item in orderItems"
              :key="item.id"
              class="flex items-center justify-between p-4 bg-gray-50 rounded-xl"
            >
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-lg bg-white flex items-center justify-center flex-shrink-0">
                  <Package class="w-6 h-6 text-gray-400" />
                </div>
                <div>
                  <h4 class="font-semibold text-gray-900">{{ item.product_name }}</h4>
                  <p class="text-sm text-gray-600">Quantité: {{ item.quantity }}</p>
                  <p v-if="item.notes" class="text-xs text-gray-500 mt-1">Note: {{ item.notes }}</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm text-gray-600">{{ formatPrice(item.unit_price) }} × {{ item.quantity }}</p>
                <p class="font-semibold text-gray-900">{{ formatPrice(item.subtotal) }}</p>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-8 text-gray-500">
            <Package class="w-12 h-12 mx-auto mb-2 text-gray-300" />
            <p>Aucun article dans cette commande</p>
          </div>
        </div>

        <!-- Rating -->
        <div v-if="order.rating" class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Star class="w-5 h-5" />
            Évaluation client
          </h3>
          
          <div class="flex items-center gap-2 mb-3">
            <Star
              v-for="i in 5"
              :key="i"
              class="w-5 h-5"
              :class="i <= order.rating ? 'text-yellow-400 fill-yellow-400' : 'text-gray-300'"
            />
            <span class="text-sm text-gray-600 ml-2">{{ order.rating }}/5</span>
          </div>
          
          <p v-if="order.rating_comment" class="text-gray-900 bg-gray-50 rounded-lg p-3">
            {{ order.rating_comment }}
          </p>
        </div>
      </div>

      <!-- Right Column - Status & Actions -->
      <div class="space-y-6">
        <!-- Status Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Statut</h3>
          
          <div class="space-y-3">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Statut de la commande</label>
              <select 
                v-model="order.status"
                @change="updateOrderStatus"
                :disabled="updating"
                class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
              >
                <option value="pending">En attente</option>
                <option value="processing">En cours</option>
                <option value="ready">Prêt</option>
                <option value="completed">Terminé</option>
                <option value="cancelled">Annulé</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Statut du paiement</label>
              <select 
                v-model="order.payment_status"
                @change="updatePaymentStatus"
                :disabled="updating"
                class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
              >
                <option value="unpaid">Non payé</option>
                <option value="paid">Payé</option>
              </select>
            </div>

            <div v-if="order.payment_status === 'paid' && order.payment_method">
              <label class="block text-sm font-medium text-gray-700 mb-2">Méthode de paiement</label>
              <p class="text-gray-900 font-semibold">{{ order.payment_method }}</p>
            </div>
          </div>
        </div>

        <!-- Total Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Total</h3>
          
          <div class="space-y-2">
            <div class="flex justify-between text-gray-600">
              <span>Sous-total</span>
              <span>{{ formatPrice(order.total_amount) }}</span>
            </div>
            <div class="border-t border-gray-200 pt-2 mt-2">
              <div class="flex justify-between">
                <span class="text-lg font-bold text-gray-900">Total</span>
                <span class="text-lg font-bold text-gray-900">{{ formatPrice(order.total_amount) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Actions</h3>
          
          <div class="space-y-3">
            <button 
              @click="printOrder"
              class="w-full px-4 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-all flex items-center justify-center gap-2"
            >
              <Printer class="w-4 h-4" />
              Imprimer
            </button>
            
            <button 
              v-if="order.status === 'pending'"
              @click="cancelOrder"
              :disabled="updating"
              class="w-full px-4 py-3 bg-red-50 text-red-600 rounded-xl font-semibold hover:bg-red-100 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <XCircle class="w-4 h-4" />
              Annuler la commande
            </button>

            <button 
              @click="deleteOrder"
              :disabled="updating"
              class="w-full px-4 py-3 bg-red-50 text-red-600 rounded-xl font-semibold hover:bg-red-100 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <Trash2 class="w-4 h-4" />
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  ArrowLeft, RefreshCw, Loader2, Store, Package, 
  UserCheck, Star, Printer, XCircle, Trash2, AlertCircle, CheckCircle
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const updating = ref(false)

// Order data
const order = ref<any>({
  id: route.params.id,
  establishment_id: '',
  table_number: 0,
  status: 'pending',
  total_amount: 0,
  payment_status: 'unpaid',
  payment_method: null,
  notes: null,
  rating: null,
  rating_comment: null,
  created_at: null,
  updated_at: null,
  staff_id: null,
  staff_name: null
})

const establishment = ref<any>(null)
const owner = ref<any>(null)
const orderItems = ref<any[]>([])

// Load order data
const loadOrder = async () => {
  try {
    isLoading.value = true
    
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        establishments (
          id,
          name,
          address,
          is_active,
          user_id
        ),
        staff (
          id,
          username
        )
      `)
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    
    order.value = {
      ...data,
      staff_name: data.staff?.username
    }
    establishment.value = data.establishments
    
    // Load owner information
    if (data.establishments?.user_id) {
      await loadOwner(data.establishments.user_id)
    }
    
    // Load order items
    await loadOrderItems()
    
  } catch (err) {
    console.error('Error loading order:', err)
    showToast.error('Erreur lors du chargement de la commande')
    router.push('/admin/orders')
  } finally {
    isLoading.value = false
  }
}

// Load owner information
const loadOwner = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('id, full_name, is_active')
      .eq('id', userId)
      .single()

    if (error) throw error
    
    owner.value = data
    
  } catch (err) {
    console.error('Error loading owner:', err)
  }
}

// Load order items
const loadOrderItems = async () => {
  try {
    const { data, error } = await supabase
      .from('order_items')
      .select(`
        *,
        products (
          name
        )
      `)
      .eq('order_id', route.params.id)

    if (error) throw error
    
    orderItems.value = data.map(item => ({
      ...item,
      product_name: item.products?.name || 'Produit inconnu'
    }))
    
  } catch (err) {
    console.error('Error loading order items:', err)
  }
}

// Update order status
const updateOrderStatus = async () => {
  try {
    updating.value = true
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: order.value.status,
        updated_at: new Date().toISOString()
      })
      .eq('id', order.value.id)

    if (error) throw error
    
    showToast.success('Statut de la commande mis à jour')
    
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Impossible de mettre à jour le statut')
  } finally {
    updating.value = false
  }
}

// Update payment status
const updatePaymentStatus = async () => {
  try {
    updating.value = true
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        payment_status: order.value.payment_status,
        updated_at: new Date().toISOString()
      })
      .eq('id', order.value.id)

    if (error) throw error
    
    showToast.success('Statut du paiement mis à jour')
    
  } catch (err) {
    console.error('Error updating payment status:', err)
    showToast.error('Impossible de mettre à jour le statut du paiement')
  } finally {
    updating.value = false
  }
}

// Cancel order (uniquement si en attente, pas après confirmation)
const cancelOrder = async () => {
  // Vérifier que la commande est en attente
  if (order.value.status !== 'pending') {
    showToast.error('Impossible d\'annuler', 'Seules les commandes en attente peuvent être annulées')
    return
  }
  
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) return
  
  try {
    updating.value = true
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('id', order.value.id)

    if (error) throw error
    
    order.value.status = 'cancelled'
    showToast.success('Commande annulée')
    
  } catch (err) {
    console.error('Error cancelling order:', err)
    showToast.error('Impossible d\'annuler la commande')
  } finally {
    updating.value = false
  }
}

// Delete order
const deleteOrder = async () => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette commande ? Cette action est irréversible.')) return
  
  try {
    updating.value = true
    
    const { error } = await supabase
      .from('orders')
      .delete()
      .eq('id', order.value.id)

    if (error) throw error
    
    showToast.success('Commande supprimée')
    router.push('/admin/orders')
    
  } catch (err) {
    console.error('Error deleting order:', err)
    showToast.error('Impossible de supprimer la commande')
  } finally {
    updating.value = false
  }
}

// Print order
const printOrder = () => {
  window.print()
}

// Format price
const formatPrice = (amount: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0
  }).format(amount || 0)
}

// Format date time
const formatDateTime = (dateString: string | null) => {
  if (!dateString) return 'N/A'
  
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Load data on mount
onMounted(loadOrder)

definePageMeta({
  layout: 'admin',
  // middleware: 'admin-auth'
})
</script>
