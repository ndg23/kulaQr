<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="border-b border-gray-100 py-6">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 flex justify-between items-center">
        <div class="flex items-center">
          <NuxtLink 
            :to="`/staff/${establishmentId}/orders`"
            class="mr-4 text-gray-500 hover:text-gray-700"
          >
            <ArrowLeft class="w-6 h-6" />
          </NuxtLink>
          <h1 class="text-2xl font-bold text-gray-900">
            Commande #{{ orderId.substring(0, 8) }}
          </h1>
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
                      <div class="text-lg font-medium text-gray-900">{{ item.product_name }}</div>
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
            @click="takeOrder"
            class="w-full flex justify-center items-center px-6 py-5 border border-transparent text-xl font-medium rounded-2xl shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <CheckCircle class="w-6 h-6 mr-2" />
            Je m'en occupe
          </button>
          
          <button 
            v-if="order.status === 'preparing'"
            @click="markAsReady"
            class="w-full flex justify-center items-center px-6 py-5 border border-transparent text-xl font-medium rounded-2xl shadow-sm text-white bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
          >
            <Bell class="w-6 h-6 mr-2" />
            Prêt à servir
          </button>
          
          <button 
            v-if="order.status === 'ready'"
            @click="markAsDelivered"
            class="w-full flex justify-center items-center px-6 py-5 border border-transparent text-xl font-medium rounded-2xl shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <Check class="w-6 h-6 mr-2" />
            Commande servie
          </button>
          
          <button 
            v-if="['pending', 'confirmed', 'preparing'].includes(order.status)"
            @click="cancelOrder"
            class="w-full flex justify-center items-center px-6 py-5 border border-gray-300 text-xl font-medium rounded-2xl shadow-sm text-red-600 bg-white hover:bg-red-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            <X class="w-6 h-6 mr-2" />
            Annuler la commande
          </button>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  ArrowLeft, CheckCircle, Bell, Check, X
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const route = useRoute()
const router = useRouter()

const establishmentId = route.params.establishmentId
const orderId = route.params.orderId
const loading = ref(true)
const order = ref({
  id: orderId,
  table_number: '',
  status: '',
  total_amount: 0,
  payment_status: '',
  notes: '',
  created_at: '',
  items: []
})

// Charger les détails de la commande
const loadOrderDetails = async () => {
  try {
    loading.value = true
    
    // Essayer de charger les détails réels de la commande
    const { data, error } = await supabase
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
          products(name)
        )
      `)
      .eq('id', orderId)
      .eq('establishment_id', establishmentId)
      .single()

    if (error) {
      // Si la commande n'existe pas ou en cas d'erreur, utiliser des données fictives
      if (error.code === 'PGRST116') {
        order.value = generateMockOrderDetail()
        return
      }
      throw error
    }

    // Formater les données
    order.value = {
      ...data,
      items: data.items.map(item => ({
        ...item,
        product_name: item.products?.name || 'Produit inconnu'
      }))
    }
  } catch (error) {
    console.error('Erreur de chargement des détails de la commande:', error)
    // En cas d'erreur, utiliser des données fictives
    order.value = generateMockOrderDetail()
  } finally {
    loading.value = false
  }
}

// Générer une commande fictive détaillée pour la démonstration
const generateMockOrderDetail = () => {
  const statuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered']
  const now = new Date()
  const itemCount = Math.floor(Math.random() * 5) + 2
  const status = statuses[Math.floor(Math.random() * statuses.length)]
  
  const items = Array.from({ length: itemCount }, (_, i) => {
    const quantity = Math.floor(Math.random() * 3) + 1
    const unitPrice = (Math.floor(Math.random() * 10) + 1) * 500
    
    return {
      id: `item-${i}`,
      quantity,
      unit_price: unitPrice,
      notes: Math.random() > 0.7 ? 'Sans sauce' : '',
      product_name: ['Burger', 'Pizza', 'Salade', 'Poulet', 'Poisson', 'Pâtes', 'Riz'][Math.floor(Math.random() * 7)]
    }
  })
  
  const totalAmount = items.reduce((sum, item) => sum + (item.quantity * item.unit_price), 0)
  
  return {
    id: orderId,
    table_number: Math.floor(Math.random() * 20) + 1,
    status,
    total_amount: totalAmount,
    payment_status: Math.random() > 0.5 ? 'paid' : 'unpaid',
    notes: Math.random() > 0.7 ? 'Client pressé' : '',
    created_at: now.toISOString(),
    updated_at: now.toISOString(),
    items
  }
}

// Prendre en charge une commande
const takeOrder = async () => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'confirmed',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande prise en charge')
    order.value.status = 'confirmed'
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Marquer comme prêt à servir
const markAsReady = async () => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'ready',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande prête à servir')
    order.value.status = 'ready'
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Marquer comme servie
const markAsDelivered = async () => {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'delivered',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande servie')
    order.value.status = 'delivered'
  } catch (error) {
    console.error('Erreur de mise à jour de la commande:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la commande')
  }
}

// Annuler la commande
const cancelOrder = async () => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) return
  
  try {
    const { error } = await supabase
      .from('orders')
      .update({ 
        status: 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)

    if (error) throw error

    showToast.success('Succès', 'Commande annulée')
    order.value.status = 'cancelled'
  } catch (error) {
    console.error('Erreur d\'annulation de la commande:', error)
    showToast.error('Erreur', 'Impossible d\'annuler la commande')
  }
}

// Formater la date et l'heure
const formatDateTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString('fr-FR', { 
    day: '2-digit',
    month: '2-digit',
    hour: '2-digit', 
    minute: '2-digit'
  })
}

// Formater le prix
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF' 
  }).format(price || 0)
}

// Obtenir la classe CSS pour le statut
const getStatusClass = (status) => {
  switch (status) {
    case 'pending':
      return 'bg-gray-100 text-gray-800'
    case 'confirmed':
      return 'bg-blue-100 text-blue-800'
    case 'preparing':
      return 'bg-yellow-100 text-yellow-800'
    case 'ready':
      return 'bg-green-100 text-green-800'
    case 'delivered':
      return 'bg-green-100 text-green-800'
    case 'cancelled':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

// Obtenir le texte du statut
const getStatusText = (status) => {
  switch (status) {
    case 'pending':
      return 'En attente'
    case 'confirmed':
      return 'Confirmée'
    case 'preparing':
      return 'En préparation'
    case 'ready':
      return 'Prête'
    case 'delivered':
      return 'Servie'
    case 'cancelled':
      return 'Annulée'
    default:
      return status
  }
}

onMounted(() => {
  loadOrderDetails()
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