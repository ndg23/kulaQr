<template>
  <div class="font-sans bg-white min-h-screen max-w-lg mx-auto pb-24 border-l border-gray-100 border-r">
    <!-- Bannière de récupération de session -->
    <SessionRecoveryBanner 
      v-if="establishment"
      :establishment-id="establishment.id"
      @continue="handleSessionRecovery"
      @dismiss="dismissSessionBanner"
    />
    
    <ErrorMessage v-if="error" :message="error" />
    
    <div v-if="loading" class="min-h-screen flex items-center justify-center bg-white">
      <div class="space-y-4 text-center">
        <Loader2 class="w-10 h-10 animate-spin mx-auto text-gray-400" />
        <p class="text-gray-500">Un moment...</p>
      </div>
    </div>
    
    <div v-else-if="!establishment" class="min-h-screen flex items-center justify-center bg-white px-4">
      <div class="max-w-md w-full space-y-8 text-center">
        <div class="w-20 h-20 mx-auto bg-gray-50 rounded-3xl flex items-center justify-center">
          <Store class="w-10 h-10 text-gray-400" />
        </div>
        <div class="space-y-3">
          <h1 class="text-2xl font-semibold text-gray-900">
            Etablissement introuvable
          </h1>
          <p class="text-gray-500 text-lg">
            Cet établissement n'est plus disponible ou a été bloqué.
          </p>
        </div>
        <div class="pt-4">
          <NuxtLink 
            to="/"
            class="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-2xl text-white bg-black hover:bg-gray-800 transition-colors"
          >
            Retourner à l'accueil
          </NuxtLink>
        </div>
        <p class="text-sm text-gray-400 pt-4">
          Si vous pensez qu'il s'agit d'une erreur, veuillez contacter le support.
        </p>
      </div>
    </div>
    
    <template v-else>
      <RestaurantHeader 
        :data="establishment" 
        v-if="establishment" 
      />

      <div v-if="showTableBanner" class="mb-1 bg-white">
        <div class="flex items-center justify-center gap-4">
          <div class="w-10 h-10 border-r border-gray-300 flex items-center justify-center">
            <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
            </svg>
          </div>
          <div class="text-left">
            <p class="text-2xl font-black font-mono text-gray-900">{{ tableNumber }}</p>
          </div>
        </div>
      </div>
      
      <div class="pb-24" v-if="categories.length > 0">
        <div v-for="category in categories" :key="category.id">
          <CategoryButton
            :category="category"
            :is-active="activeCategory === category.id"
            @click="toggleCategory(category.id)"
          />
          
          <TransitionGroup>
            <div v-if="activeCategory === category.id">
              <MenuItem
                v-for="product in getCategoryProducts(category.id)"
                :key="product.id"
                :item="product"
                @add="addToCart"
              />
            </div>
          </TransitionGroup>
        </div>
      </div>
      
      <div v-else-if="!loading && establishment" class="flex flex-col items-center justify-center py-16">
        <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mb-4">
          <UtensilsCrossed class="w-10 h-10 text-gray-400" />
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune catégorie</h3>
        <p class="text-gray-500 text-center max-w-xs">
          Cet établissement n'a pas encore ajouté de catégories.
        </p>
      </div>
    </template>

    <FloatingCart
      :cart="cart"
      :is-expanded="isCartExpanded"
      @remove="removeFromCart"
      @increment="incrementCartItem"
      @place-order="placeOrder"
      @toggle="toggleCartExpand"
      @add-note="openAddNoteModal"
      @remove-item="removeItemFromCart"
    />

    <!-- ✅ WAITING LOADER - S'affiche pendant tout le processus -->
    <WaitingLoader 
      :is-visible="isWaiting" 
      :status="orderStatus"
      :message="statusMessage"
      :order="currentOrderData"
      :order-number="currentOrderData?.orderNumber || currentOrderData?.id?.slice(-6) || ''"
      :table-number="tableNumber || undefined"
      :establishment-name="establishment?.name || 'N/A'"
      :cancelable="orderStatus === 'pending' || orderStatus === 'confirmed'"
      @close="handleOrderClose"
      @cancel="cancelOrder"
    />
    
    <!-- ✅ ORDER SUMMARY - Ne s'affiche QUE quand completed -->
    <OrderSummaryTicket
      v-if="showOrderSummary && confirmedOrder"
      :order="confirmedOrder"
      @close="handleOrderClose"
    />

    <AddNote
      v-model:cart="cart"
      ref="addNoteModal"
    />
    
    <!-- Notification toast pour les changements de statut -->
    <div 
      v-if="showStatusToast" 
      class="fixed bottom-24 left-0 right-0 flex justify-center z-50 px-4"
      @click="showStatusToast = false"
    >
      <div class="bg-gray-800 text-white px-6 py-3 rounded-full shadow-lg flex items-center gap-3 animate-fadeIn">
        <div v-if="orderStatus === 'pending'" class="w-2 h-2 bg-yellow-400 rounded-full"></div>
        <div v-else-if="orderStatus === 'confirmed'" class="w-2 h-2 bg-blue-400 rounded-full"></div>
        <div v-else-if="orderStatus === 'processing'" class="w-2 h-2 bg-orange-400 rounded-full"></div>
        <div v-else-if="orderStatus === 'completed'" class="w-2 h-2 bg-green-400 rounded-full"></div>
        <span>{{ statusMessage }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, onUnmounted } from 'vue'
import { UtensilsCrossed, Store, Loader2 } from 'lucide-vue-next'
import { decodeTableHashids } from '~/utils/secure-encoding'

const route = useRoute()
const slug = route.params.slug as string
const supabase = useSupabaseClient()

// Utiliser le composable de tracking QR
const { trackScan } = useQRTracking()

// State
const establishment = ref(null)
const categories = ref<any[]>([])
const products = ref([])
const activeCategory = ref('')
const cart = ref<CartItem[]>([])
const isCartExpanded = ref(false)
const isWaiting = ref(false)
const orderStatus = ref<'loading' | 'pending' | 'confirmed' | 'processing' | 'completed'>('loading')
const confirmedOrder = ref<OrderData | null>(null)
const error = ref('')
const loading = ref(true)
const addNoteModal = ref(null)
const sessionRecovered = ref(false)

// ✅ Nouvelles propriétés pour une meilleure gestion
const statusMessage = ref('')
const showStatusToast = ref(false)
const currentOrderId = ref<string | null>(null)
const showOrderSummary = ref(false) // Contrôle l'affichage du ticket final

let orderSubscription: any = null

// ✅ Données de commande en temps réel pour le loader
const currentOrderData = computed(() => {
  if (!currentOrderId.value || !tableNumber.value) return null
  
  return {
    id: currentOrderId.value,
    orderNumber: currentOrderId.value.slice(-6),
    table: tableNumber.value,
    items: cart.value.map(item => ({
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      notes: item.notes
    })),
    total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
    status: orderStatus.value,
    created_at: new Date().toISOString()
  }
})

// Fetch data from Supabase
const fetchData = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const { data: establishmentData, error: establishmentError } = await supabase
      .from('establishments')
      .select('*')
      .eq('slug', slug)
      .single()
    
    if (establishmentError) throw establishmentError
    establishment.value = establishmentData
    
    // Tracker le scan maintenant que l'établissement est chargé
    // if (tableNumber.value) {
    //   await trackScan({
    //     establishmentId: establishmentData.id,
    //     tableNumber: tableNumber.value
    //   })
    // }
    
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', establishmentData.id as string)
      .order('order_number')
    
    if (categoriesError) throw categoriesError
    categories.value = categoriesData || []
    
    if (categories.value.length > 0) {
      activeCategory.value = categories.value[0].id as string
    }
    
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('establishment_id', establishmentData.id as string)
      .eq('is_available', true)
    
    if (productsError) throw productsError
    products.value = productsData || []
    
  } catch (err) {
    console.error('Error fetching data:', err)
    error.value = 'Impossible de charger le menu. Veuillez réessayer plus tard.'
  } finally {
    loading.value = false
  }
}

const openAddNoteModal = (itemId: string) => {
  addNoteModal.value?.openModal(itemId)
}

const getCategoryProducts = (categoryId: string) => {
  return products.value.filter(product => product.category_id === categoryId)
}

const addToCart = (item: Product) => {
  const existingItem = cart.value.find(cartItem => cartItem.id === item.id)
  if (existingItem) {
    existingItem.quantity++
  } else {
    cart.value.push({ ...item, quantity: 1, notes: '' })
  }
}

const removeFromCart = (itemId: string) => {
  const itemIndex = cart.value.findIndex(item => item.id === itemId)
  if (itemIndex === -1) return

  if (cart.value[itemIndex].quantity > 1) {
    cart.value[itemIndex].quantity--
  } else {
    cart.value.splice(itemIndex, 1)
  }
}

const incrementCartItem = (itemId: string) => {
  const item = cart.value.find(item => item.id === itemId)
  if (item) {
    item.quantity++
  }
}

const removeItemFromCart = (itemId: string) => {
  cart.value = cart.value.filter(item => item.id !== itemId)
}

const showToast = (message: string) => {
  statusMessage.value = message
  showStatusToast.value = true
  
  setTimeout(() => {
    showStatusToast.value = false
  }, 5000)
}

// ✅ ABONNEMENT AUX MISES À JOUR
const subscribeToOrderUpdates = (orderId: string) => {
  if (orderSubscription) {
    orderSubscription.unsubscribe()
  }
      
  orderSubscription = supabase
    .channel(`order-status-${orderId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'orders',
        filter: `id=eq.${orderId}`
      },
      (payload) => {
        console.log('📡 Mise à jour reçue:', payload)
        
        const newStatus = payload.new.status
        
        // ✅ Mettre à jour le statut
        orderStatus.value = newStatus
        
        const statusMessages = {
          'pending': 'Commande en attente de confirmation',
          'confirmed': 'Commande confirmée par le restaurant',
          'processing': 'Votre commande est en préparation',
          'completed': 'Votre commande est prête !'
        }
        
        statusMessage.value = statusMessages[newStatus] || 'Mise à jour du statut'
        
        // ✅ Afficher le toast
        showToast(statusMessages[newStatus] || 'Le statut a changé')
        
        // ✅ Si completed, préparer les données finales et masquer le loader
        if (newStatus === 'completed') {
          // Créer l'objet de commande finale
          confirmedOrder.value = {
            id: orderId,
            orderNumber: orderId.slice(-6),
            table: tableNumber.value || 0,
            items: cart.value.map(item => ({
              name: item.name,
              price: item.price,
              quantity: item.quantity,
              notes: item.notes
            })),
            total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
            status: newStatus,
            created_at: new Date().toISOString()
          }
          
          // Masquer le loader et afficher le ticket final
          setTimeout(() => {
            isWaiting.value = false
            showOrderSummary.value = true
            
            // Vider le panier
            cart.value = []
            isCartExpanded.value = false
          }, 1000) // Petit délai pour une transition fluide
        }
      }
    )
    .subscribe()
}

// ✅ PASSER LA COMMANDE
const placeOrder = async () => {
  if (cart.value.length === 0) return

  isWaiting.value = true
  orderStatus.value = 'loading'
  showOrderSummary.value = false
  statusMessage.value = 'Envoi de votre commande...'
  
  try {
    const { data: orderData, error: orderError } = await supabase
      .from('orders')
      .insert({
        establishment_id: establishment.value?.id,
        table_number: tableNumber.value || Math.floor(Math.random() * 20) + 1,
        status: 'pending',
        total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
        notes: cart.value.filter(item => item.notes).map(item => `${item.name}: ${item.notes}`).join('\n')
      })
      .select()
      .single()
    
    if (orderError) throw orderError
    
    // Tracker l'événement de commande passée
    await trackScan({
      establishmentId: establishment.value?.id,
      tableNumber: tableNumber.value
    })
    
    // Sauvegarder l'ID de la commande
    currentOrderId.value = orderData.id
    
    const orderItems = cart.value.map(item => ({
      order_id: orderData.id,
      product_id: item.id,
      quantity: item.quantity,
      unit_price: item.price,
      subtotal: item.price * item.quantity,
      notes: item.notes || null
    }))
    
    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems)
    
    if (itemsError) throw itemsError
    
    // ✅ Passer en pending et s'abonner
    orderStatus.value = 'pending'
    statusMessage.value = 'En attente de confirmation...'
    
    subscribeToOrderUpdates(orderData.id)
    
  } catch (err) {
    console.error('Error placing order:', err)
    error.value = 'Impossible de passer la commande. Veuillez réessayer.'
    isWaiting.value = false
  }
}

// ✅ ANNULER LA COMMANDE
const cancelOrder = async () => {
  if (!currentOrderId.value) return
  
  try {
    await supabase
      .from('orders')
      .update({ status: 'cancelled' })
      .eq('id', currentOrderId.value)
    
    handleOrderClose()
    showToast('Commande annulée')
  } catch (err) {
    console.error('Error cancelling order:', err)
  }
}

// ✅ FERMER / RÉINITIALISER
const handleOrderClose = () => {
  confirmedOrder.value = null
  isWaiting.value = false
  showOrderSummary.value = false
  currentOrderId.value = null
  orderStatus.value = 'loading'
  
  if (orderSubscription) {
    orderSubscription.unsubscribe()
    orderSubscription = null
  }
}

onUnmounted(() => {
  if (orderSubscription) {
    orderSubscription.unsubscribe()
  }
})

const toggleCategory = (categoryId: string) => {
  activeCategory.value = activeCategory.value === categoryId ? '' : categoryId
}

const toggleCartExpand = () => {
  isCartExpanded.value = !isCartExpanded.value
}

const handleSessionRecovery = (sessionData: any) => {
  cart.value = sessionData.cart
  sessionRecovered.value = true
  isCartExpanded.value = true
}

const dismissSessionBanner = () => {
  console.log('❌ Session ignorée')
}

const tableNumber = computed(() => {
  const encodedTable = route.query.table as string
  if (!encodedTable) return null
  
  // Si c'est déjà un numéro (rétrocompatibilité), utiliser directement
  const parsed = parseInt(encodedTable)
  if (!isNaN(parsed)) return parsed
  
  // Sinon, essayer de décoder si l'établissement est chargé
  if (establishment.value?.id) {
    try {
      const decoded = decodeTableHashids(encodedTable, establishment.value.id)
      console.log('Table décodée avec succès:', decoded)
      return decoded
    } catch (error) {
      console.warn('Erreur de décodage du numéro de table:', error)
      return null
    }
  }
  
  return null
})
const showTableBanner = computed(() => tableNumber.value !== null)

onMounted(() => {
//   if (!useCookie('kula_scan_session').value) {
//   return navigateTo('/invalid') // pas issu d’un scan
// }

  fetchData()
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}
</style>