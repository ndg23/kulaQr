<template>
  <div class="font-sans bg-white min-h-dvh max-w-2xl mx-auto">
    <!-- SEO Head Component -->
    <MenuHead 
      :establishment="establishment"
      :categories="categories"
      :products="products"
      :table-number="tableNumber||undefined"
    />
    
    <!-- Session Recovery Banner -->
    <SessionRecoveryBanner 
      v-if="establishment && !sessionRecovered"
      :establishment-id="establishment.id"
      @continue="handleSessionRecovery"
      @dismiss="dismissSessionBanner"
    />
    
    <!-- Error State -->
    <ErrorMessage v-if="error" :message="error" />
    
    <!-- Chargement -->
    <div v-if="loading" class="min-h-dvh flex items-center justify-center">
      <div class="text-center space-y-4">
        <div class="w-12 h-12 mx-auto animate-spin rounded-full border-4 border-gray-200 border-t-[#FB6A00]"></div>
        <p class="text-sm text-gray-500 font-extrabold">Chargement du menu…</p>
      </div>
    </div>

    <!-- Établissement introuvable -->
    <div v-else-if="!establishment" class="min-h-dvh flex items-center justify-center px-4">
      <div class="max-w-sm w-full text-center space-y-5">
        <span class="w-20 h-20 mx-auto rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><Store class="w-10 h-10" :stroke-width="2.5" /></span>
        <div class="space-y-1">
          <h1 class="text-2xl font-black text-gray-900 tracking-tight">Établissement introuvable</h1>
          <p class="text-base font-medium text-gray-500 leading-relaxed">Cet établissement n'existe pas ou a été désactivé.</p>
        </div>
        <button type="button" class="w-full h-14 rounded-full bg-black text-white font-black uppercase active:scale-[0.98] transition-all" @click="navigateTo('/')">Retour à l'accueil</button>
      </div>
    </div>

    <!-- Main Content -->
    <template v-else>
      <!-- Restaurant Header -->
      <RestaurantHeader :data="establishment" />

      <!-- Table + téléphone, puis les catégories en pilules (qui restent en haut quand on fait défiler) -->
      <div class="sticky top-0 z-30 bg-white/95 backdrop-blur-xl border-b border-gray-100">
        <div v-if="showTableBanner" class="flex items-center justify-between gap-2 px-4 pt-3">
          <span class="inline-flex items-center h-10 px-5 rounded-full bg-black text-white text-base font-black tabular-nums">Table {{ tableNumber }}</span>
          <a
            v-if="establishment?.phone"
            :href="`tel:${establishment.phone}`"
            class="inline-flex items-center gap-2 h-10 px-4 rounded-full bg-gray-100 text-sm font-extrabold text-gray-900 active:scale-[0.96] transition-all"
          >
            <Phone class="w-4 h-4" :stroke-width="2.5" />
            {{ formatPhone(establishment.phone) }}
          </a>
        </div>

        <div v-if="categories.length > 1" class="flex gap-2 overflow-x-auto px-4 py-3 scrollbar-hide" role="tablist" aria-label="Catégories">
          <button
            type="button"
            role="tab"
            :aria-selected="!activeCategory"
            class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
            :class="!activeCategory ? 'bg-black text-white' : 'bg-gray-100 text-gray-900'"
            @click="activeCategory = ''"
          >Tout</button>
          <button
            v-for="category in categories"
            :key="category.id"
            type="button"
            role="tab"
            :aria-selected="activeCategory === category.id"
            class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
            :class="activeCategory === category.id ? 'bg-black text-white' : 'bg-gray-100 text-gray-900'"
            @click="activeCategory = category.id"
          >{{ category.name }}</button>
        </div>
      </div>

      <div class="pb-32" v-if="categories.length > 0">
        <section
          v-for="category in categories.filter(c => !activeCategory || c.id === activeCategory)"
          :key="category.id"
          class="pt-4"
        >
          <h2 v-if="!activeCategory || categories.length > 1" class="px-5 pb-1 text-xl font-black text-gray-900 tracking-tight">{{ category.name }}</h2>
          <MenuItem
            v-for="product in getCategoryProducts(category.id)"
            :key="product.id"
            :item="product"
            :quantity="cartQty(product.id)"
            :disabled="!isQrValid"
            @add="addToCart"
          />
        </section>
      </div>

      <!-- Empty State -->
      <div v-else class="flex flex-col items-center justify-center py-24 px-4">
        <div class="w-20 h-20 bg-gray-100 rounded-3xl flex items-center justify-center mb-6">
          <UtensilsCrossed class="w-10 h-10 text-gray-400" :stroke-width="2" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Pas de contenu</h3>
        <p class="text-base text-gray-500 text-center max-w-xs leading-relaxed">
          Cet établissement n'a pas encore ajouté de contenu.
        </p>
      </div>
    </template>

    <!-- Floating Cart - Apple/Twitter Style -->
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

    <!-- Waiting Loader - Full Screen -->
    <WaitingLoader 
      :is-visible="isWaiting" 
      :status="orderStatus"
      :message="statusMessage"
      :order="currentOrderData"
      :order-number="currentOrderData?.orderNumber || currentOrderData?.id?.slice(-6) || ''"
      :table-number="tableNumber || undefined"
      :establishment-name="establishment?.name || 'N/A'"
      :cancelable="orderStatus === 'pending'"
      @close="handleOrderClose"
      @cancel="cancelOrder"
    />
    
    <!-- Order Summary Ticket -->
    <OrderSummaryTicket
      v-if="showOrderSummary && confirmedOrder"
      :order="confirmedOrder"
      @close="handleOrderClose"
    />

    <!-- Add Note Modal -->
    <AddNote
      v-model:cart="cart"
      ref="addNoteModal"
    />
    
    <!-- Status Toast - Twitter Style -->
    <!-- <transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0 translate-y-4"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 translate-y-4"
    >
      <div 
        v-if="showStatusToast" 
        @click="showStatusToast = false"
        class="fixed bottom-24 left-4 right-4 sm:left-auto sm:right-4 sm:w-auto z-50"
      >
        <div class="bg-gray-900/95 backdrop-blur-xl text-white px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-3 cursor-pointer hover:bg-gray-800 transition-colors">
          <div 
            class="w-2 h-2 rounded-full flex-shrink-0"
            :class="{
              'bg-yellow-400': orderStatus === 'pending',
              'bg-blue-400': orderStatus === 'confirmed',
              'bg-orange-400': orderStatus === 'processing',
              'bg-green-400': orderStatus === 'completed'
            }"
          ></div>
          <span class="text-sm font-medium">{{ statusMessage }}</span>
        </div>
      </div>
    </transition> -->

    <!-- QR invalide -->
    <transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div v-if="showInvalidQrAlert" class="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-4">
        <div class="bg-white rounded-t-[2rem] sm:rounded-[2rem] shadow-2xl max-w-sm w-full overflow-hidden pb-[env(safe-area-inset-bottom)]">
          <div class="pt-8 pb-4 px-6 text-center">
            <span class="w-16 h-16 mx-auto mb-4 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><AlertTriangle class="w-8 h-8" :stroke-width="2.5" /></span>
            <h2 class="text-xl font-black text-gray-900 mb-2">QR code invalide</h2>
            <p class="text-gray-600 text-sm font-medium leading-relaxed">Ce QR code a été modifié ou est abîmé. Scannez à nouveau le QR code de votre table.</p>
          </div>
          <div class="px-6 pb-6 space-y-2">
            <button type="button" class="w-full h-14 rounded-full bg-black text-white font-black inline-flex items-center justify-center gap-2 active:scale-[0.98] transition-all" @click="openCamera">
              <Camera class="w-5 h-5" :stroke-width="2.5" /> Ouvrir le scanner
            </button>
            <input ref="cameraInput" type="file" accept="image/*" capture="environment" class="hidden" />
            <button type="button" class="w-full h-12 rounded-full bg-gray-100 text-gray-900 font-extrabold active:scale-[0.98] transition-all" @click="goHome">Retour à l'accueil</button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted, computed, onUnmounted, watch } from 'vue'
import { UtensilsCrossed, Store, Camera, X, Phone, AlertTriangle } from 'lucide-vue-next'
import { useDebounceFn } from '@vueuse/core'
import { decodeTableHashids } from '~/utils/secure-encoding'

// Types
interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
  notes: string
  category_id?: string
  image_url?: string
}

interface OrderData {
  id: string
  orderNumber: string
  table: string
  items: Array<{
    name: string
    price: number
    quantity: number
    notes: string
  }>
  total_amount: number
  status: OrderStatus
  created_at: string
}

interface Product {
  id: string
  name: string
  price: number
  category_id: string
  is_available: boolean
  image_url?: string
  description?: string
}

interface Category {
  id: string
  name: string
  order_number: number
}

interface Establishment {
  id: string
  slug: string
  name: string
  description?: string
}

type OrderStatus = 'loading' | 'pending' | 'confirmed' | 'processing' | 'completed' | 'cancelled'

// Composables
const route = useRoute()
const supabase = useSupabaseClient()
const slug = route.params.slug as string

// State
const establishment = ref<Establishment | null>(null)
const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const activeCategory = ref('')
const cart = ref<CartItem[]>([])
const isCartExpanded = ref(false)
const isWaiting = ref(false)
const isPlacingOrder = ref(false)
const orderStatus = ref<OrderStatus>('loading')
const confirmedOrder = ref<OrderData | null>(null)
const error = ref('')
const loading = ref(true)
const addNoteModal = ref(null)
const sessionRecovered = ref(false)
const statusMessage = ref('')
const showStatusToast = ref(false)
const currentOrderId = ref<string | null>(null)
const showOrderSummary = ref(false)
const tableInfo = ref<any>(null)

let orderSubscription: any = null
const cameraInput = ref<HTMLInputElement | null>(null)

// Computed - Décodage du numéro de table (ID de la table)
const tableId = computed(() => {
  const encodedTable = route.query.q as string
  
  if (!encodedTable) {
    console.warn('⚠️ Aucun paramètre QR trouvé')
    return null
  }
  
  if (!establishment.value?.id) {
    console.warn('⚠️ Établissement pas encore chargé, attente...')
    return null
  }
  
  try {
    console.log('🔍 Décodage QR:', {
      encoded: encodedTable,
      establishmentId: establishment.value.id
    })
    
    // decodeTableHashids retourne number | null (l'ID de la table)
    const result = decodeTableHashids(encodedTable, establishment.value.id)
    
    if (result !== null && result > 0) {
      console.log('✅ Table ID décodé:', result)
      return result
    }
    
    console.warn('⚠️ Décodage a retourné null ou valeur invalide:', result)
    return null
    
  } catch (e) {
    console.error('❌ Erreur de décodage du QR:', e)
    return null
  }
})

// Computed - Numéro de table pour affichage (ex: "Table 5", "A1", etc.)
const tableNumber = computed(() => {
  return tableInfo.value?.table_number || tableId.value?.toString() || null
})

const isQrValid = computed(() => {
  const isValid = tableId.value !== null
  if (!isValid) {
    console.log('🔐 QR invalide - Raisons possibles:', {
      hasQueryParam: !!route.query.q,
      hasEstablishment: !!establishment.value,
      tableId: tableId.value,
      loading: loading.value
    })
  }
  return isValid
})

const showInvalidQrAlert = computed(() => {
  // N'afficher l'alerte que si:
  // 1. Le QR est invalide
  // 2. L'établissement est chargé
  // 3. Le chargement est terminé
  return !isQrValid.value && !loading.value && establishment.value !== null
})

const showTableBanner = computed(() => tableNumber.value !== null)

const currentOrderData = computed(() => {
  if (!currentOrderId.value || !tableNumber.value) return null
  
  return {
    id: currentOrderId.value,
    orderNumber: currentOrderId.value.slice(-6).toUpperCase(),
    table: tableNumber.value,
    items: cart.value.map(item => ({
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      notes: item.notes
    })),
    total_amount: totalAmount.value,
    status: orderStatus.value,
    created_at: new Date().toISOString()
  }
})

const totalAmount = computed(() => {
  return cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
})

const totalItems = computed(() => {
  return cart.value.reduce((sum, item) => sum + item.quantity, 0)
})

const cartStorageKey = computed(() => {
  return `cart_${slug}_${tableId.value || 'temp'}`
})

// Methods
const fetchData = async () => {
  loading.value = true
  error.value = ''
  
  try {
    // Fetch establishment
    const { data: establishmentData, error: establishmentError } = await supabase
      .from('establishments')
      .select('*')
      .eq('slug', slug)
      .single()
    
    if (establishmentError) throw new Error('Établissement introuvable')
    
    establishment.value = establishmentData
    console.log('✅ Établissement chargé:', establishmentData.id)
    
    // Une fois l'établissement chargé, le tableId sera recalculé automatiquement
    // Ensuite on charge les infos complètes de la table
    
    // Fetch categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('categories')
      .select('*')
      .eq('establishment_id', establishmentData.id)
      .order('order_number')
    
    if (categoriesError) throw categoriesError
    categories.value = categoriesData || []
    
    if (categories.value.length > 0) {
      activeCategory.value = categories.value[0].id
    }
    
    // Fetch products
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('establishment_id', establishmentData.id)
      .eq('is_available', true)
    
    if (productsError) throw productsError
    products.value = productsData || []
    
  } catch (err: any) {
    console.error('❌ Erreur de chargement:', err)
    error.value = err.message || 'Impossible de charger le menu.'
    showToast('❌ ' + error.value)
  } finally {
    loading.value = false
  }
}

// Charger les infos de la table
const fetchTableInfo = async () => {
  if (!tableId.value || !establishment.value?.id) return
  
  try {
    const { data, error } = await supabase
      .from('tables')
      .select('*')
      .eq('table_number', tableId.value)
      .eq('establishment_id', establishment.value.id)
      .single()
    
    if (error) throw error
    
    tableInfo.value = data
    console.log('✅ Infos table chargées:', data)
  } catch (err: any) {
    console.error('⚠️ Impossible de charger les infos de la table:', err)
    // On continue quand même, on utilisera juste l'ID
  }
}

const cartQty = (productId: string) => cart.value.find(item => item.id === productId)?.quantity || 0

const getCategoryProducts = (categoryId: string): Product[] => {
  return products.value.filter(product => product.category_id === categoryId)
}

const toggleCategory = (categoryId: string) => {
  activeCategory.value = activeCategory.value === categoryId ? '' : categoryId
}

const addToCart = (item: Product) => {
  if (!isQrValid.value) {
    showToast('⚠️ QR Code invalide - Veuillez scanner à nouveau')
    return
  }
  
  const existingItem = cart.value.find(cartItem => cartItem.id === item.id)
  if (existingItem) {
    existingItem.quantity++
  } else {
    cart.value.push({ 
      id: item.id,
      name: item.name,
      price: item.price,
      quantity: 1, 
      notes: '',
      category_id: item.category_id,
      image_url: item.image_url
    })
  }
  
  showToast(`✅ ${item.name} ajouté au panier`)
}

// Debounced version for rapid clicks
const debouncedAddToCart = useDebounceFn(addToCart, 300)

const removeFromCart = (itemId: string) => {
  const itemIndex = cart.value.findIndex(item => item.id === itemId)
  if (itemIndex === -1) return

  const item = cart.value[itemIndex]
  if (item.quantity > 1) {
    // Décrémenter la quantité
    cart.value.splice(itemIndex, 1, {
      ...item,
      quantity: item.quantity - 1
    })
  } else {
    // Supprimer l'item complètement
    cart.value.splice(itemIndex, 1)
  }
}

const incrementCartItem = (itemId: string) => {
  const itemIndex = cart.value.findIndex(item => item.id === itemId)
  if (itemIndex !== -1) {
    // Utiliser splice pour déclencher la réactivité
    cart.value.splice(itemIndex, 1, {
      ...cart.value[itemIndex],
      quantity: cart.value[itemIndex].quantity + 1
    })
  }
}

const decrementCartItem = (itemId: string) => {
  const item = cart.value.find(item => item.id === itemId)
  if (!item) return
  
  if (item.quantity > 1) {
    item.quantity--
  } else {
    removeItemFromCart(itemId)
  }
}

const removeItemFromCart = (itemId: string) => {
  cart.value = cart.value.filter(item => item.id !== itemId)
}

const toggleCartExpand = () => {
  isCartExpanded.value = !isCartExpanded.value
}

const openAddNoteModal = (itemId: string) => {
  addNoteModal.value?.openModal(itemId)
}

const updateItemNote = (itemId: string, note: string) => {
  const item = cart.value.find(item => item.id === itemId)
  if (item) {
    item.notes = note
  }
}

const showToast = (message: string) => {
  statusMessage.value = message
  showStatusToast.value = true
  
  setTimeout(() => {
    showStatusToast.value = false
  }, 4000)
}

const handleOrderUpdate = (payload: any) => {
  const newStatus = payload.new.status as OrderStatus
  orderStatus.value = newStatus
  
  const statusMessages: Record<OrderStatus, string> = {
    'loading': 'Chargement...',
    'pending': 'En attente de confirmation',
    'confirmed': 'Commande confirmée',
    'processing': 'En préparation',
    'completed': 'Commande prête !',
    'cancelled': 'Commande annulée'
  }
  
  const message = statusMessages[newStatus] || 'Statut mis à jour'
  showToast(message)
  
  // Si commande terminée
  if (newStatus === 'completed') {
    confirmedOrder.value = {
      id: currentOrderId.value!,
      orderNumber: currentOrderId.value!.slice(-6).toUpperCase(),
      table: tableNumber.value || '',
      items: cart.value.map(item => ({
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        notes: item.notes
      })),
      total_amount: totalAmount.value,
      status: newStatus,
      created_at: new Date().toISOString()
    }
    
    setTimeout(() => {
      isWaiting.value = false
      showOrderSummary.value = true
      clearCart()
    }, 1500)
  }
  
  // Si commande annulée
  if (newStatus === 'cancelled') {
    setTimeout(() => {
      handleOrderClose()
    }, 2000)
  }
}

const subscribeToOrderUpdates = (orderId: string) => {
  // Nettoyer l'ancienne subscription
  if (orderSubscription) {
    supabase.removeChannel(orderSubscription)
    orderSubscription = null
  }
  
  // console.log('🔔 Subscription aux mises à jour de la commande:', orderId)
      
  orderSubscription = supabase
    .channel(`order-status-${orderId}`)
    .on('postgres_changes', {
      event: 'UPDATE',
      schema: 'public',
      table: 'orders',
      filter: `id=eq.${orderId}`
    }, handleOrderUpdate)
    .subscribe((status) => {
      if (status === 'SUBSCRIBED') {
        // console.log('✅ Subscribed to order updates')
      }
    })
}

const placeOrder = async () => {
  if (cart.value.length === 0) {
    showToast(' Votre panier est vide')
    return
  }
  
  if (!isQrValid.value) {
    showToast('QR Code invalide - Impossible de passer commande')
    return
  }
  
  if (isPlacingOrder.value) {
    console.log('Commande déjà en cours')
    return
  }

  isPlacingOrder.value = true
  isWaiting.value = true
  orderStatus.value = 'loading'
  showOrderSummary.value = false
  statusMessage.value = '📤Envoi de votre commande...'
  
  try {
    // Créer la commande
    const orderNotes = cart.value
      .filter(item => item.note && item.note.trim() !== '')
      .map(item => `${item.name}: ${item.note}`)
      .join('\n')
    
    // La base reprend les prix dans la table products et vérifie la table : le navigateur n'envoie que
    // les produits et les quantités (bdd/customer_create_order.sql)
    const { data: created, error: orderError } = await (supabase as any).rpc('create_customer_order', {
      p_establishment_id: establishment.value?.id,
      p_table_number: tableId.value !== null ? String(tableId.value) : null,
      p_notes: orderNotes || null,
      p_items: cart.value.map(item => ({
        product_id: item.id,
        quantity: item.quantity,
        notes: item.note || null
      }))
    })

    let orderId: string | null = created?.id ?? null

    // Fonction SQL pas encore installée (bdd/customer_create_order.sql) : on garde l'ancien chemin
    const functionMissing = orderError && (orderError.code === 'PGRST202' || orderError.code === '42883' || /could not find the function/i.test(orderError.message || ''))
    if (functionMissing) {
      const { data: legacy, error: legacyError } = await supabase
        .from('orders')
        .insert({
          establishment_id: establishment.value?.id,
          table_id: tableInfo.value?.id,
          status: 'pending',
          total_amount: totalAmount.value,
          notes: orderNotes || null
        })
        .select('id')
        .single()
      if (legacyError) throw new Error(legacyError.message)
      const { error: itemsError } = await supabase.from('order_items').insert(
        cart.value.map(item => ({
          order_id: legacy.id,
          product_id: item.id,
          quantity: item.quantity,
          unit_price: item.price,
          subtotal: item.price * item.quantity,
          notes: item.note || null
        }))
      )
      if (itemsError) throw new Error(itemsError.message)
      orderId = legacy.id
    } else if (orderError) {
      throw new Error(orderError.message)
    }
    if (!orderId) throw new Error('Aucune donnée de commande retournée')

    const orderData = { id: orderId }
    currentOrderId.value = orderData.id

    // Mettre à jour le statut
    orderStatus.value = 'pending'
    statusMessage.value = 'En attente de confirmation...'
    
    // S'abonner aux mises à jour
    subscribeToOrderUpdates(orderData.id)
    
    showToast('✅ Commande envoyée avec succès !')
    
  } catch (err: any) {
    console.error('❌ Erreur lors de la commande:', err)
    error.value = err.message || 'Impossible de passer la commande.'
    showToast('❌ ' + error.value)
    isWaiting.value = false
    orderStatus.value = 'loading'
  } finally {
    isPlacingOrder.value = false
  }
}

const cancelOrder = async () => {
  if (!currentOrderId.value) return
  
  // Vérifier que la commande est bien en attente
  if (orderStatus.value !== 'pending') {
    showToast('⚠️ Cette commande ne peut plus être annulée')
    return
  }
  
  if (!confirm('Voulez-vous vraiment annuler cette commande ?')) return
  
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: 'cancelled' })
      .eq('id', currentOrderId.value)
    
    if (error) throw error
    
    handleOrderClose()
    showToast('❌ Commande annulée')
  } catch (err: any) {
    console.error('❌ Erreur:', err)
    showToast('⚠️ Impossible d\'annuler la commande')
  }
}

const handleOrderClose = () => {
  confirmedOrder.value = null
  isWaiting.value = false
  showOrderSummary.value = false
  currentOrderId.value = null
  orderStatus.value = 'loading'
  
  if (orderSubscription) {
    supabase.removeChannel(orderSubscription)
    orderSubscription = null
  }
}

const clearCart = () => {
  cart.value = []
  isCartExpanded.value = false
  
  // Nettoyer le localStorage
  if (typeof window !== 'undefined') {
    localStorage.removeItem(cartStorageKey.value)
  }
}

const saveCartToStorage = () => {
  if (typeof window === 'undefined') return
  
  try {
    const cartData = {
      cart: cart.value,
      timestamp: Date.now(),
      tableId: tableId.value,
      tableNumber: tableNumber.value
    }
    localStorage.setItem(cartStorageKey.value, JSON.stringify(cartData))
  } catch (e) {
    console.warn('⚠️ Impossible de sauvegarder le panier:', e)
  }
}

const loadCartFromStorage = () => {
  if (typeof window === 'undefined') return
  
  try {
    const savedData = localStorage.getItem(cartStorageKey.value)
    if (!savedData) return
    
    const { cart: savedCart, timestamp, tableId: savedTableId } = JSON.parse(savedData)
    
    // Vérifier que la session n'est pas trop ancienne (24h)
    const maxAge = 24 * 60 * 60 * 1000
    if (Date.now() - timestamp > maxAge) {
      localStorage.removeItem(cartStorageKey.value)
      return
    }
    
    // Vérifier que c'est la même table
    if (savedTableId !== tableId.value) {
      return
    }
    
    if (savedCart && savedCart.length > 0) {
      handleSessionRecovery({ cart: savedCart })
    }
  } catch (e) {
    console.warn('⚠️ Erreur de récupération du panier:', e)
    localStorage.removeItem(cartStorageKey.value)
  }
}

const handleSessionRecovery = (sessionData: any) => {
  cart.value = sessionData.cart
  sessionRecovered.value = true
  isCartExpanded.value = true
  showToast('🔄 Panier restauré')
  
  setTimeout(() => {
    sessionRecovered.value = false
  }, 5000)
}

const dismissSessionBanner = () => {
  sessionRecovered.value = false
}

const openCamera = () => {
  window.location.reload()
}

const goHome = () => {
  navigateTo('/')
}

// Format phone number for display
const formatPhone = (phone: string) => {
  if (!phone) return ''
  
  // Remove all non-digit characters
  const digits = phone.replace(/\D/g, '')
  
  // Format based on Senegalese phone numbers (+221 XX XXX XX XX)
  if (digits.startsWith('221') && digits.length === 12) {
    // International format: +221 XX XXX XX XX
    return `+221 ${digits.slice(3, 5)} ${digits.slice(5, 8)} ${digits.slice(8, 10)} ${digits.slice(10, 12)}`
  } else if (digits.length === 9) {
    // Local format: XX XXX XX XX
    return `${digits.slice(0, 2)} ${digits.slice(2, 5)} ${digits.slice(5, 7)} ${digits.slice(7, 9)}`
  }
  
  // Fallback: return original
  return phone
}

// Debug function (available in console)
const debugQR = () => {
  // console.group('🐛 QR Code Debug')
  // console.log('URL complète:', window.location.href)
  // console.log('Query params:', route.query)
  // console.log('Param "q":', route.query.q)
  // console.log('Establishment:', establishment.value)
  // console.log('Table ID:', tableId.value)
  // console.log('Table Number:', tableNumber.value)
  // console.log('Table Info:', tableInfo.value)
  // console.log('Is QR Valid:', isQrValid.value)
  // console.log('Show Alert:', showInvalidQrAlert.value)
  // console.log('Loading:', loading.value)
  
  if (route.query.q && establishment.value) {
    console.log('🧪 Test manuel du décodage:')
    try {
      const result = decodeTableHashids(route.query.q as string, establishment.value.id)
      console.log('Résultat:', result)
    } catch (e) {
      console.error('Erreur:', e)
    }
  }
  console.groupEnd()
}

// Watchers
watch(cart, () => {
  saveCartToStorage()
}, { deep: true })

// Watch pour logger les changements
watch([() => route.query.q, establishment, tableId, tableNumber], 
  ([query, estab, tId, tNum]) => {
    console.log('🔄 Watch déclenché:', {
      hasQuery: !!query,
      establishmentLoaded: !!estab,
      tableId: tId,
      tableNumber: tNum
    })
  },
  { immediate: true }
)

// Watch pour charger les infos de la table quand l'ID est disponible
watch(tableId, async (newTableId) => {
  if (newTableId) {
    await fetchTableInfo()
  }
}, { immediate: true })

// Lifecycle
onMounted(async () => {
  // console.log('🚀 Component monté')
  // console.log('📍 URL:', window.location.href)
  
  await fetchData()
  
  // Debug après chargement
  setTimeout(() => {
    debugQR()
  }, 500)
  
  // Charger le panier sauvegardé
  if (tableId.value) {
    await fetchTableInfo()
    loadCartFromStorage()
  }
  
  // Exposer debugQR globalement
  if (process.client) {
    (window as any).debugQR = debugQR
  }
})

onUnmounted(() => {
  if (orderSubscription) {
    supabase.removeChannel(orderSubscription)
  }
})

// Exposer pour usage dans le template
defineExpose({
  addToCart: debouncedAddToCart,
  removeFromCart,
  incrementCartItem,
  decrementCartItem,
  removeItemFromCart,
  toggleCartExpand,
  openAddNoteModal,
  updateItemNote,
  placeOrder,
  cancelOrder,
  handleOrderClose,
  clearCart,
  openCamera,
  goHome,
  debugQR
})
</script>

<style scoped>
/* Animations pour les toasts */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateY(-20px);
}

.toast-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

/* Animations pour le panier */
.cart-item-enter-active,
.cart-item-leave-active {
  transition: all 0.3s ease;
}

.cart-item-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.cart-item-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>

<style scoped>
/* Animations pour les toasts */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateY(-20px);
}

.toast-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

/* Animations pour le panier */
.cart-item-enter-active,
.cart-item-leave-active {
  transition: all 0.3s ease;
}

.cart-item-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.cart-item-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>

<style scoped>
/* Animations pour les toasts */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateY(-20px);
}

.toast-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

/* Animations pour le panier */
.cart-item-enter-active,
.cart-item-leave-active {
  transition: all 0.3s ease;
}

.cart-item-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.cart-item-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>