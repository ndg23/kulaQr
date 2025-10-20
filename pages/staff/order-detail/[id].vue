<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="border-b border-gray-100 py-6">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 flex justify-between items-center">
        <div class="flex items-center">
          <NuxtLink 
            to="/staff"
            class="mr-4 text-gray-500 hover:text-gray-700"
          >
            <ArrowLeft class="w-6 h-6" />
          </NuxtLink>
          <!-- <span class="text-gray-500 font-medium text-xl font-bold text-blue-600 ml-2">Commande</span> -->
          <h1 class="text-2xl font-bold text-gray-900">
Details de la commande          </h1>
        </div>
        <div>
          <span 
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
            :class="getStatusClass(order.status)"
          >
            {{ getStatusText(order.status) }}
          </span>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="max-w-5xl mx-auto px-4 py-8 sm:px-6">
      <div v-if="loading" class="flex justify-center py-12">
        <svg class="animate-spin h-10 w-10 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      </div>

      <div v-else class="space-y-8">
        <!-- Informations de base -->
        <div class="bg-white border border-gray-100 rounded-2xl overflow-hidden shadow-sm">
          <div class="px-6 py-5">
            <h3 class="text-xl font-semibold text-gray-900">
              Informations de la commande
            </h3>
          </div>
          <div class="border-t border-gray-100 px-6 py-5">
            <dl class="grid grid-cols-1 gap-x-6 gap-y-6 sm:grid-cols-2">
              <div class="sm:col-span-1">
                <dt class="text-sm font-medium text-gray-500">Table</dt>
                <dd class="mt-1 text-xl text-gray-900">{{ order.table_number }}</dd>
              </div>
              <div class="sm:col-span-1">
                <dt class="text-sm font-medium text-gray-500">Heure</dt>
                <dd class="mt-1 text-xl text-gray-900">{{ formatDateTime(order.created_at) }}</dd>
              </div>
              <div class="sm:col-span-1">
                <dt class="text-sm font-medium text-gray-500">Total</dt>
                <dd class="mt-1 text-xl font-bold text-gray-900">{{ formatPrice(order.total_amount) }}</dd>
              </div>
              <div class="sm:col-span-1">
                <dt class="text-sm font-medium text-gray-500">Paiement</dt>
                <dd class="mt-1 text-xl text-gray-900">
                  <span 
                    class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                    :class="order.payment_status === 'paid' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'"
                  >
                    {{ order.payment_status === 'paid' ? 'Payé' : 'En attente' }}
                  </span>
                </dd>
              </div>
              <div v-if="order.notes" class="sm:col-span-2">
                <dt class="text-sm font-medium text-gray-500">Notes</dt>
                <dd class="mt-1 text-xl text-gray-900">{{ order.notes }}</dd>
              </div>
            </dl>
          </div>
        </div>

        <!-- Articles de la commande -->
        <div class="bg-white border border-gray-100 rounded-2xl overflow-hidden shadow-sm">
          <div class="px-6 py-5">
            <h3 class="text-xl font-semibold text-gray-900">
              Articles commandés
            </h3>
          </div>
          <div class="border-t border-gray-100">
            <ul class="divide-y divide-gray-100">
              <li v-for="item in order.items" :key="item.id" class="px-6 py-5">
                <div class="flex items-center justify-between">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-12 w-12 bg-gray-50 rounded-xl flex items-center justify-center">
                      <span class="text-gray-600 font-semibold">{{ item.quantity }}×</span>
                    </div>
                    <div class="ml-4">
                      <div class="text-lg font-medium text-gray-900">{{ item.name }}</div>
                      <div v-if="item.notes" class="text-sm text-gray-500 mt-1">{{ item.notes }}</div>
                    </div>
                  </div>
                  <div class="text-lg font-semibold text-gray-900">{{ formatPrice(item.unit_price * item.quantity) }}</div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <!-- Actions -->
        <div class="space-y-4">
          <!-- Boutons d'action selon le statut -->
          <button 
            v-if="order.status === 'pending'"
            @click="startProcessing"
            class="w-full flex justify-center items-center px-6 py-5 border border-transparent text-xl font-medium rounded-2xl shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <CheckCircle class="w-6 h-6 mr-2" />
            Commencer le traitement
          </button>
          
          <button 
            v-if="order.status === 'processing'"
            @click="markAsCompleted"
            class="w-full flex justify-center items-center px-6 py-5 border border-transparent text-xl font-medium rounded-2xl shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <Check class="w-6 h-6 mr-2" />
            Marquer comme terminé
          </button>
          
          <!-- Bouton d'annulation pour les commandes en attente ou en traitement -->
          <button 
            v-if="canCancelOrder(order.status)"
            @click="cancelOrder"
            class="w-full flex justify-center items-center px-6 py-5 border border-red-300 text-xl font-medium rounded-2xl shadow-sm text-red-600 bg-red-50 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            <X class="w-6 h-6 mr-2" />
            Annuler la commande
          </button>
          
          <!-- Message pour les commandes annulées -->
          <div v-if="order.status === 'cancelled'" class="w-full flex justify-center items-center px-6 py-5 border border-red-200 text-xl font-medium rounded-2xl text-red-600 bg-red-50">
            <X class="w-6 h-6 mr-2" />
            Commande annulée
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  ArrowLeft, CheckCircle, Check, X
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const route = useRoute()
const router = useRouter()

const orderId = route.params.id as string
const loading = ref(true)
const error = ref(false)
interface OrderItem {
  id: string
  name: string
  quantity: number
  unit_price: number
  notes?: string
  productId?: string
}

interface Order {
  id: string
  table_number: number
  status: string
  total_amount: number
  payment_status: string
  notes?: string
  created_at: string
  updated_at?: string
  items: OrderItem[]
}

const order = ref<Order>({
  id: orderId,
  table_number: 0,
  status: '',
  total_amount: 0,
  payment_status: '',
  notes: '',
  created_at: '',
  updated_at: '',
  items: []
})

// Charger les détails de la commande
const loadOrderDetails = async () => {
  try {
    loading.value = true
    error.value = false
    
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
    loading.value = false
  }
}

// Commencer le traitement de la commande
const startProcessing = async () => {
  try {
    if (!orderId) {
      showToast.error('Erreur', 'ID de commande manquant')
      return
    }
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'processing',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Traitement de la commande commencé')
    order.value.status = 'processing'
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Marquer comme terminé
const markAsCompleted = async () => {
  try {
    if (!orderId) {
      showToast.error('Erreur', 'ID de commande manquant')
      return
    }
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'completed',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande terminée')
    order.value.status = 'completed'
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Annuler la commande
const cancelOrder = async () => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) {
    return
  }
  
  try {
    if (!orderId) {
      showToast.error('Erreur', 'ID de commande manquant')
      return
    }
    
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande annulée avec succès')
    order.value.status = 'cancelled'
  } catch (error) {
    console.error('Erreur lors de l\'annulation de la commande:', error)
    showToast.error('Erreur', 'Impossible d\'annuler la commande')
  }
}

// Vérifier si la commande peut être annulée
const canCancelOrder = (status: string) => {
  return status === 'pending' || status === 'processing'
}

// Formater la date et l'heure
const formatDateTime = (timestamp: string) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString('fr-FR')
}

// Formater le prix
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF' 
  }).format(price || 0)
}

// Obtenir la classe CSS pour le statut
const getStatusClass = (status: string) => {
  switch (status) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'processing':
      return 'bg-blue-100 text-blue-800'
    case 'completed':
      return 'bg-green-100 text-green-800'
    case 'cancelled':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

// Obtenir le texte du statut
const getStatusText = (status: string) => {
  switch (status) {
    case 'pending':
      return 'En attente'
    case 'processing':
      return 'En traitement'
    case 'completed':
      return 'Terminée'
    case 'cancelled':
      return 'Annulée'
    default:
      return status
  }
}

onMounted(() => {
  loadOrderDetails()
})

definePageMeta({
  layout: 'staff',
})
</script>

<style scoped>
/* Styles pour optimiser l'affichage sur mobile */
@media (max-width: 640px) {
  .sm\:grid-cols-2 {
    grid-template-columns: 1fr;
  }
}
</style>