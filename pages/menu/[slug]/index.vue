  <template>
    <div class="font-sans bg-white min-h-screen max-w-lg mx-auto pb-24">
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
          <Loader2 class="w-8 h-8 animate-spin mx-auto text-gray-400" />
          <p class="text-gray-500">Chargement du menu...</p>
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
              Ce menu n'est plus disponible ou a été déplacé.
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
        
        <div v-if="showTableBanner" class="bg-blue-50 p-4 rounded-xl mb-6 text-center">
          <p class="text-blue-700 font-medium">Table {{ tableNumber }}</p>
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
            Cet établissement n'a pas encore ajouté de catégories à son menu.
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
  
      <WaitingLoader 
        :is-visible="isWaiting" 
        :status="orderStatus"
        :status-message="statusMessage"
        :order="confirmedOrder || undefined"
        :order-number="confirmedOrder?.orderNumber || ''"
        :table-number="tableNumber || undefined"
        :establishment-name="establishment?.name || 'Restaurant'"
        :cancelable="orderStatus === 'waiting'"
        @close="handleOrderClose"
        @cancel="handleOrderCancel"
      />
      
      <OrderSummaryTicket
        v-if="confirmedOrder"
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
          <div v-if="orderStatus === 'waiting'" class="w-2 h-2 bg-blue-400 rounded-full"></div>
          <div v-else-if="orderStatus === 'success'" class="w-2 h-2 bg-green-400 rounded-full"></div>
          <div v-else-if="orderStatus === 'rejected'" class="w-2 h-2 bg-red-400 rounded-full"></div>
          <span>{{ statusMessage }}</span>
        </div>
      </div>
    </div>
  
    <!-- <div v-if="isDev && debugQrTracking" class="fixed bottom-0 left-0 right-0 bg-black bg-opacity-70 text-white p-4 font-mono text-xs z-50 max-h-60 overflow-auto">
      <pre>{{ debugQrTracking }}</pre>
    </div> -->
    
    <!-- Bouton de test en développement -->
    <!-- <div v-if="isDev" class="fixed top-20 right-4 z-50">
      <button 
        @click="testScanManually" 
        class="bg-blue-500 text-white font-bold py-2 px-4 rounded shadow-lg hover:bg-blue-600"
      >
        Test Scan
      </button>
    </div> -->
  </template>
  
  <script setup lang="ts">
  import { ref, onMounted, computed, onUnmounted, watch } from 'vue'
  import { UtensilsCrossed, Store, Loader2 } from 'lucide-vue-next'
  import type { CartItem, OrderData, Product } from '~/types'
  import RestaurantHeader from '~/components/RestaurantHeader.vue'
  import CategoryButton from '~/components/CategoryButton.vue'
  import MenuItem from '~/components/MenuItem.vue'
  import FloatingCart from '~/components/FloatingCart.vue'
  import OrderSummaryTicket from '~/components/OrderSummaryTicket.vue'
  import WaitingLoader from '~/components/WaitingLoader.vue'
  import ErrorMessage from '~/components/ErrorMessage.vue'
  import SessionRecoveryBanner from '~/components/SessionRecoveryBanner.vue'
  import { useSupabaseClient } from '#imports'
  import AddNote from '~/components/AddNote.vue'
  import { useCart } from '~/composables/useCart'
  
  const route = useRoute()
  const slug = route.params.slug as string
  const supabase = useSupabaseClient()
  const { loadCartWithRecovery, clearCartAndCompleteOrder } = useCart()
  
  // State
  const establishment = ref(null)
  const categories = ref<any[]>([])
  const products = ref([])
  const activeCategory = ref('')
  const cart = ref<CartItem[]>([])
  const isCartExpanded = ref(false)
  const isWaiting = ref(false)
  const orderStatus = ref<'loading' | 'waiting' | 'success' | 'rejected'>('loading')
  const confirmedOrder = ref<OrderData | null>(null)
  const error = ref('')
  const loading = ref(true)
  const addNoteModal = ref(null)
  const debugQrTracking = ref('')
  const sessionRecovered = ref(false)
  
  // Nouvelles propriétés pour gérer les notifications
  const statusMessage = ref('')
  const showStatusToast = ref(false)
  
  const isDev = process.dev
  
  // Types for Supabase
  type OrderStatus = 'pending' | 'accepted' | 'rejected' | 'preparing' | 'ready' | 'completed'
  
  interface DatabaseOrder {
    id: string
    establishment_id: string
    table_number: number
    status: OrderStatus
    total_amount: number
    created_at: string
    notes: string | null
  }
  
  // Nouvelle propriété pour suivre l'abonnement aux changements de statut des commandes
  let orderSubscription: any = null
  
  // Fetch data from Supabase
  const fetchData = async () => {
    loading.value = true
    error.value = ''
    
    try {
      // Fetch establishment data
      const { data: establishmentData, error: establishmentError } = await supabase
        .from('establishments')
        .select('*')
        .eq('slug', slug)
        .single()
      
      if (establishmentError) throw establishmentError
      establishment.value = establishmentData
      
      // Fetch categories
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('categories')
        .select('*')
        .eq('establishment_id', establishmentData.id as string)
        .order('order_number')
      
      if (categoriesError) throw categoriesError
      categories.value = categoriesData || []
      
      // Set active category if we have categories
      if (categories.value.length > 0) {
        activeCategory.value = categories.value[0].id as string
      }
      
      // Fetch products
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
  // Get products for a specific category
  const getCategoryProducts = (categoryId: string) => {
    return products.value.filter(product => product.category_id === categoryId)
  }
  
  // Cart management
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
  
  // Méthode pour afficher un toast de notification
  const showToast = (message: string) => {
    statusMessage.value = message
    showStatusToast.value = true
    
    // Masquer automatiquement après 5 secondes
    setTimeout(() => {
      showStatusToast.value = false
    }, 5000)
  }
  
  // Méthode pour s'abonner aux changements de statut de commande
  const subscribeToOrderUpdates = (orderId: string) => {
    // Annuler l'abonnement existant s'il y en a un
    if (orderSubscription) {
      orderSubscription.unsubscribe()
    }
    
    console.log('Abonnement aux mises à jour pour la commande:', orderId)
    
    // Créer un nouvel abonnement pour cette commande
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
          console.log('Mise à jour de statut de commande reçue:', payload)
          
          const newStatus = payload.new.status
          
          // Mettre à jour le statut dans l'objet confirmedOrder
          if (confirmedOrder.value && confirmedOrder.value._id === orderId) {
            confirmedOrder.value.status = newStatus
          }
          
          // Définir les messages de statut pour l'interface
          const statusMessages = {
            'confirmed': 'Votre commande a été confirmée',
            'preparing': 'Votre commande est en préparation',
            'ready': 'Votre commande est prête !',
            'completed': 'Votre commande a été livrée',
            'cancelled': 'Votre commande a été annulée'
          }
          
          // Mettre à jour le message de statut
          statusMessage.value = statusMessages[newStatus] || 'Mise à jour du statut'
          
          // Mettre à jour l'affichage pour le composant WaitingLoader
          orderStatus.value = getWaitingStatus(newStatus)
          
          // Si c'est une transition importante, afficher un toast
          showToast(statusMessages[newStatus] || 'Le statut de votre commande a changé')
          
          // Si la commande est terminée ou annulée, cacher le loader d'attente
          if (newStatus === 'completed' || newStatus === 'cancelled') {
            isWaiting.value = false
          }
          
          // Si la commande est confirmée (et qu'elle était en attente),
          // mettre à jour confirmedOrder et vider le panier
          if (newStatus === 'confirmed' && !confirmedOrder.value) {
            isWaiting.value = false // Masquer le loader
            
            // Créer la commande confirmée
            confirmedOrder.value = {
              id: orderId,
              table: tableNumber.value || 0,
              items: cart.value.map(item => ({
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                notes: item.notes
              })),
              total: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
              status: newStatus,
              created_at: new Date().toISOString()
            }
            
            // Vider le panier et fermer l'interface de panier
            cart.value = []
            isCartExpanded.value = false
            
            // Nettoyer la session après commande réussie
            if (establishment.value?.id) {
              clearCartAndCompleteOrder()
            }
          }
        }
      )
      .subscribe()
  }
  
  // Fonction d'aide pour convertir le statut en état d'attente
  const getWaitingStatus = (orderStatus: string) => {
    const statusMap = {
      'pending': 'loading',
      'confirmed': 'waiting',
      'preparing': 'waiting',
      'ready': 'success',
      'completed': 'success',
      'cancelled': 'rejected'
    }
    return statusMap[orderStatus] || 'loading'
  }
  
  // Mettre à jour la fonction placeOrder pour s'abonner aux mises à jour
  const placeOrder = async () => {
    if (cart.value.length === 0) return
  
    isWaiting.value = true
    orderStatus.value = 'loading'
    
    try {
      // Create a new order
      const { data: orderData, error: orderError } = await supabase
        .from('orders')
        .insert({
          establishment_id: establishment.value?.id,
          table_number: Math.floor(Math.random() * 20) + 1,
          status: 'pending',
          total_amount: cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
          notes: cart.value.filter(item => item.notes).map(item => `${item.name}: ${item.notes}`).join('\n')
        } as DatabaseOrder)
        .select()
        .single()
      
      if (orderError) throw orderError
      
      // Add order items
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
      
      // Change status to waiting for staff confirmation
      orderStatus.value = 'waiting'
      
      // S'abonner aux mises à jour de statut pour cette commande
      subscribeToOrderUpdates(orderData.id)
      
    } catch (err) {
      console.error('Error placing order:', err)
      error.value = 'Impossible de passer la commande. Veuillez réessayer.'
      isWaiting.value = false
    }
  }
  
  // Fonction pour se désabonner lors du démontage du composant
  onUnmounted(() => {
    if (orderSubscription) {
      orderSubscription.unsubscribe()
    }
  })
  
  // Mettre à jour la fonction handleOrderClose pour se désabonner 
  const handleOrderClose = () => {
    confirmedOrder.value = null
    isWaiting.value = false
    
    // Se désabonner des mises à jour
    if (orderSubscription) {
      orderSubscription.unsubscribe()
      orderSubscription = null
    }
  }

  const handleOrderCancel = () => {
    // Annuler la commande en cours
    isWaiting.value = false
    orderStatus.value = 'loading'
    confirmedOrder.value = null
    
    // Se désabonner des mises à jour
    if (orderSubscription) {
      orderSubscription.unsubscribe()
      orderSubscription = null
    }
    
    // Optionnel: envoyer une requête pour annuler la commande côté serveur
    // await cancelOrder(confirmedOrder.value?._id)
  }
  
  const toggleCategory = (categoryId: string) => {
    activeCategory.value = activeCategory.value === categoryId ? '' : categoryId
  }
  
  const toggleCartExpand = () => {
    isCartExpanded.value = !isCartExpanded.value
  }
  
  // Format price helper
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'XOF'
    }).format(price)
  }
  
  // Gestion de la récupération de session
  const handleSessionRecovery = (sessionData: any) => {
    cart.value = sessionData.cart
    if (sessionData.tableNumber) {
      tableNumber.value = sessionData.tableNumber
    }
    sessionRecovered.value = true
    isCartExpanded.value = true
    console.log('✅ Session récupérée:', sessionData)
  }

  const dismissSessionBanner = () => {
    // L'utilisateur choisit de ne pas récupérer la session
    console.log('❌ Session ignorée par l\'utilisateur')
  }

  // Load data on mount
  onMounted(() => {
    fetchData()
  })
  
  onMounted(() => {
    // Supprimer cette logique pour éviter le double scan
    // Ne garder que la vérification des scans en attente (qui n'ont pas pu être envoyés précédemment)
    const pendingData = localStorage.getItem('qr_scan_pending')
    if (pendingData && !route.query.track) {
      // Ne traiter les scans en attente que si nous ne sommes pas dans un nouveau scan
      sendPendingTracking()
    }
  })
  
  // Simplifier la fonction d'envoi
  const sendPendingTracking = async () => {
    const pendingData = localStorage.getItem('qr_scan_pending')
    if (!pendingData) return
    
    try {
      const data = JSON.parse(pendingData as string)
      
      // Convertir slug en UUID si besoin
      let establishmentId = data.establishment_id
      const { data: establishment } = await supabase
        .from('establishments')
        .select('id')
        .eq('slug', data.establishment_id)
        .single()
      
      if (establishment) {
        establishmentId = establishment.id
      }
      
      // Envoi via l'API
      const response = await fetch(`${window.location.origin}/api/qr-scan`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...data,
          establishment_id: establishmentId
        })
      })
      
      if (response.ok) {
        localStorage.removeItem('qr_scan_pending')
      }
    } catch (err) {
      // Silencieux en production
    }
  }
  
  const tableNumber = computed(() => route.query.table ? Number(route.query.table) : null)
  
  // Show table number if available
  const showTableBanner = computed(() => tableNumber.value !== null)
  
  </script>
  
  <style scoped>
  .animate-spin {
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
  
  .min-h-screen {
    min-height: 100vh;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  .animate-fadeIn {
    animation: fadeIn 0.3s ease-out;
  }
  </style> 