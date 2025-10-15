<template>
  <div class="min-h-screen bg-white">
    <!-- Header Twitter 2024 Style - Ultra responsive -->
    <header class="bg-white/80 backdrop-blur-xl border-b border-gray-200/50 sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-3 sm:px-4 py-3">
        <div class="flex items-center justify-between">
          <!-- Logo et titre - Responsive -->
          <div class="flex items-center gap-2 sm:gap-3 min-w-0 flex-1">
            <button @click="goBack" 
                    class="p-2 rounded-full hover:bg-gray-100 active:scale-95 transition-all duration-150 touch-target">
              <ArrowLeft class="w-4 h-4 sm:w-5 sm:h-5 text-gray-600" />
            </button>
            <div class="w-8 h-8 sm:w-10 sm:h-10 bg-black rounded-xl sm:rounded-2xl flex items-center justify-center shadow-sm flex-shrink-0">
              <ClipboardList class="w-4 h-4 sm:w-5 sm:h-5 text-white" />
            </div>
            <div class="min-w-0 flex-1">
              <h1 class="text-lg sm:text-xl font-bold text-gray-900 tracking-tight truncate">Détails Commande</h1>
              <p class="text-xs sm:text-sm text-gray-500 font-medium truncate">#{{ (isValidOrder && order.orderNumber) || '---' }}</p>
            </div>
          </div>
          
          <!-- Actions Twitter Style - Responsive -->
          <div class="flex items-center gap-0.5 sm:gap-1 flex-shrink-0">
            <button @click="printOrder" 
                    class="p-2 sm:p-3 rounded-full hover:bg-gray-100 active:scale-95 transition-all duration-150 text-gray-600 touch-target"
                    title="Imprimer">
              <Printer class="w-4 h-4 sm:w-5 sm:h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-3 sm:px-4 py-4 sm:py-6">
      <!-- Loading state -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
        <div class="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mb-6">
          <Loader2 class="w-8 h-8 animate-spin text-gray-600" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Chargement de la commande</h3>
        <p class="text-gray-500 text-sm">Veuillez patienter...</p>
      </div>
      
      <!-- Error state -->
      <div v-else-if="error" class="text-center py-20">
        <div class="w-20 h-20 mx-auto bg-red-50 rounded-3xl flex items-center justify-center mb-6">
          <AlertTriangle class="w-10 h-10 text-red-500" />
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Commande introuvable</h3>
        <p class="text-gray-600 mb-8 max-w-md mx-auto">
          Cette commande n'existe pas ou a été supprimée.
        </p>
        <button @click="goBack" 
                class="px-8 py-4 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 active:scale-95 transition-all duration-200 shadow-lg">
          Retour aux commandes
        </button>
      </div>
      
      <!-- Order details -->
      <div v-else-if="isValidOrder" class="space-y-4 sm:space-y-6">
        <!-- Order header card -->
        <div class="bg-white border border-gray-200/50 rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-sm">
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center gap-3 sm:gap-4">
              <!-- Table number -->
              <div class="w-12 h-12 sm:w-14 sm:h-14 bg-gray-100 rounded-xl sm:rounded-2xl flex items-center justify-center shadow-sm">
                <span class="text-lg sm:text-xl font-bold text-gray-800">{{ order.table_number || '?' }}</span>
              </div>
              
              <!-- Order info -->
              <div>
                <h2 class="text-lg sm:text-xl font-bold text-gray-900 mb-1">Commande #{{ order.orderNumber || (isValidOrder && order.id ? order.id.slice(-6) : '---') }}</h2>
                <p class="text-sm text-gray-500 font-medium">{{ (isValidOrder && order.created_at) ? formatDateTime(order.created_at) : '---' }}</p>
              </div>
            </div>
            
            <!-- Status badge -->
            <div :class="[getStatusColor((isValidOrder && order.status) || 'pending').badge, 'px-4 py-2 rounded-2xl text-sm font-semibold shadow-sm']">
              {{ translateStatus((isValidOrder && order.status) || 'pending') }}
            </div>
          </div>
          
          <!-- Order summary -->
          <div class="flex items-center justify-between pt-4 border-t border-gray-100/50">
            <div class="text-sm text-gray-600">
              <span class="font-semibold">{{ (isValidOrder && order.items ? order.items : []).length }} article{{ (isValidOrder && order.items ? order.items : []).length > 1 ? 's' : '' }}</span>
            </div>
            <div class="text-xl font-bold text-gray-900">
              {{ formatPrice((isValidOrder && order.total_amount) ? order.total_amount : 0) }}
            </div>
          </div>
        </div>
        
        <!-- Items list -->
        <div class="bg-white border border-gray-200/50 rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-sm">
          <h3 class="text-lg font-bold text-gray-900 mb-4">Article.s commandés</h3>
          
          <div class="space-y-4">
            <div 
              v-for="(item, index) in (isValidOrder && order.items ? order.items : [])" 
              :key="index"
              class="flex items-start gap-4 p-3 sm:p-4 bg-gray-50/50 rounded-xl sm:rounded-2xl"
            >
              <!-- Quantity -->
              <div class="w-8 h-8 sm:w-10 sm:h-10 bg-white rounded-full flex items-center justify-center shadow-sm flex-shrink-0">
                <span class="text-sm sm:text-base font-bold text-gray-800">{{ item.quantity || 0 }}</span>
              </div>
              
              <!-- Item details -->
              <div class="flex-1 min-w-0">
                <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-1">{{ item.name || 'Article' }}</h4>
                <p v-if="item.notes" class="text-sm text-gray-600 mb-2 italic">Note: {{ item.notes }}</p>
                <div class="flex items-center justify-between">
                  <span class="text-sm text-gray-500">Prix unitaire</span>
                  <span class="text-base font-semibold text-gray-900">{{ formatPrice(item.unit_price || 0) }}</span>
                </div>
                <div class="flex items-center justify-between mt-1">
                  <span class="text-sm text-gray-500">Total</span>
                  <span class="text-lg font-bold text-gray-900">{{ formatPrice((item.unit_price || 0) * (item.quantity || 0)) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Order actions -->
        <div class="bg-white border border-gray-200/50 rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-sm">
          <h3 class="text-lg font-bold text-gray-900 mb-4">Actions</h3>
          
          <div class="flex flex-col sm:flex-row gap-3">
            <!-- Primary action based on status -->
            <button 
              v-if="isValidOrder && (order.status || 'pending') === 'pending'" 
              @click="updateOrderStatus('processing')"
              class="flex-1 px-6 py-3 bg-black text-white rounded-2xl text-sm font-semibold hover:bg-gray-800 active:scale-95 transition-all duration-200 flex items-center justify-center gap-2 shadow-lg shadow-black/10 touch-target"
            >
              <Check class="w-4 h-4" />
              Commencer le traitement
            </button>
            
            <button 
              v-if="isValidOrder && (order.status || 'pending') === 'processing'" 
              @click="updateOrderStatus('completed')"
              class="flex-1 px-6 py-3 bg-green-600 text-white rounded-2xl text-sm font-semibold hover:bg-green-700 active:scale-95 transition-all duration-200 flex items-center justify-center gap-2 shadow-lg shadow-green-500/20 touch-target"
            >
              <CheckCircle class="w-4 h-4" />
              Marquer comme terminé
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { 
  ArrowLeft,
  ClipboardList, 
  Loader2, 
  AlertTriangle, 
  Printer,
  Check,
  CheckCircle,
  ClipboardCheck,
  X
} from 'lucide-vue-next'
import { useRoute, useRouter } from 'vue-router'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const route = useRoute()
const router = useRouter()
const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

// State
const order = ref<any>(undefined)
const isLoading = ref(true)
const error = ref(false)

// Computed
const isValidOrder = computed(() => {
  return order.value && order.value.id && typeof order.value.id === 'string'
})


// Methods
const loadOrder = async () => {
  isLoading.value = true
  error.value = false
  
  try {
    const orderId = route.params.id as string
    
    // Récupérer la commande avec ses articles
    const { data, error: fetchError } = await supabase
      .from('orders')
      .select(`
        id,
        table_number,
        status,
        total_amount,
        payment_status,
        notes,
        created_at,
        updated_at,
        items:order_items(
          id,
          quantity,
          unit_price,
          notes,
          products(
            id,
            name,
            description,
            price
          )
        )
      `)
      .eq('id', orderId)
      .single()
    
    if (fetchError) {
      console.error('Error fetching order:', fetchError)
      error.value = true
      return
    }
    
    if (data) {
      // Transformer les données pour correspondre au format attendu
      order.value = {
        id: data.id,
        orderNumber: data.id.slice(-6), // Utiliser les 6 derniers caractères de l'ID
        table_number: data.table_number,
        status: data.status,
        total_amount: data.total_amount,
        payment_status: data.payment_status,
        notes: data.notes,
        created_at: data.created_at,
        updated_at: data.updated_at,
        items: data.items?.map((item: any) => ({
          id: item.id,
          name: item.products?.name || 'Produit inconnu',
          quantity: item.quantity,
          unit_price: item.unit_price,
          notes: item.notes,
          productId: item.products?.id
        })) || []
      }
      
      console.log('✅ Commande chargée depuis l\'API:', order.value)
    } else {
      error.value = true
    }
  } catch (err) {
    console.error('Error loading order:', err)
    error.value = true
  } finally {
    isLoading.value = false
  }
}

const updateOrderStatus = async (newStatus: string) => {
  if (!order.value) return
  
  try {
    // Mettre à jour le statut dans la base de données
    const { error: updateError } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', order.value.id)
    
    if (updateError) {
      console.error('Error updating order status:', updateError)
      showToast.error('Erreur', 'Impossible de mettre à jour le statut')
      return
    }
    
    // Mettre à jour l'état local
    order.value.status = newStatus
    order.value.updated_at = new Date().toISOString()
    
    showToast.success('Succès', `Commande mise à jour: ${translateStatus(newStatus)}`)
    
    console.log(`✅ Statut mis à jour: Commande ${order.value.id} → ${newStatus}`)
  } catch (err) {
    console.error('Error updating order status:', err)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

const printOrder = () => {
  if (!order.value) return
  showToast.success('Impression', 'Commande envoyée à l\'imprimante')
  console.log('🖨️ Impression de la commande:', order.value.id)
}

const goBack = () => {
  router.push('/staff')
}

// Utility functions
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

const formatDateTime = (dateString: string) => {
  if (!dateString) return '---'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return '---'
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const translateStatus = (status: string) => {
  const statusMap: Record<string, string> = {
    pending: 'En attente',
    processing: 'En traitement',
    completed: 'Terminé'
  }
  return statusMap[status] || status
}

const getStatusColor = (status: string) => {
  const colors: Record<string, any> = {
    pending: { badge: 'bg-yellow-50 text-yellow-700 border border-yellow-200' },
    processing: { badge: 'bg-blue-50 text-blue-700 border border-blue-200' },
    completed: { badge: 'bg-green-50 text-green-700 border border-green-200' }
  }
  return colors[status] || colors.pending
}

// Lifecycle
onMounted(() => {
  loadOrder()
})

definePageMeta({
  layout: 'staff',
})
</script>

<style scoped>
/* Mobile-first touch interactions */
@media (max-width: 768px) {
  .touch-target {
    min-height: 44px;
    min-width: 44px;
  }
}

/* Hover effects for desktop */
@media (hover: hover) {
  .hover-lift:hover {
    transform: translateY(-2px);
  }
}
</style>
