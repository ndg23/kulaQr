<template>
  <div>
    <!-- Overlay -->
    <div 
      v-if="isExpanded" 
      class="fixed inset-0 bg-black bg-opacity-20 backdrop-blur-sm z-40 transition-opacity duration-300"
      @click="$emit('toggle')"
    ></div>
    
    <div
      class="fixed bottom-0 left-0 w-full max-w-lg mx-auto border-t border-gray-300 right-0 bg-white transition-all duration-300 z-50"
      :class="{ 
        'inset-0 rounded-none': isExpanded,
        'rounded-t-3xl': !isExpanded,
        'pb-0': !isExpanded,
        'pb-safe': isExpanded || (!isExpanded && cart.length > 0)
      }"
      :style="cartStyle"
    >
      <!-- En-tête du panier -->
      <div 
        class="p-4 flex justify-between items-center border-b border-gray-100 cursor-pointer relative"
        @click="$emit('toggle')"
      >
        <div class="flex items-center space-x-2">
          <div class="relative">
            <ShoppingBag class="w-6 h-6 text-gray-700" />
            <transition name="bounce">
              <span 
                v-if="totalItems > 0" 
                class="absolute -top-2 font-mono -right-2 bg-black text-white text-xs rounded-full w-5 h-5 flex items-center justify-center"
              >
                {{ totalItems }}
              </span>
            </transition>
          </div>
        </div>
        
        <!-- Chevron centré -->
        <div 
          class="absolute left-1/2 -translate-x-1/2 w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center transition-transform duration-300"
          :class="{ 'rotate-180': isExpanded }"
        >
          <ChevronUp class="w-5 h-5 text-gray-600" />
        </div>
        
        <div class="flex items-center">
          <span class="font-medium text-gray-800">{{ formatPrice(totalPrice) }}</span>
        </div>
      </div>

      <!-- Aperçu rapide des articles (visible quand non déployé) -->
      <div 
        v-if="!isExpanded && cart.length > 0" 
        class="px-4 pb-4 flex items-center overflow-x-auto scrollbar-hide space-x-2"
      >
        <transition-group name="slide-fade">
          <div 
            v-for="item in cart.slice(0, 3)" 
            :key="item.id" 
            class="px-3 py-1.5 bg-gray-100 rounded-full text-sm whitespace-nowrap flex items-center space-x-1"
          >
            <span>{{ item.quantity }}×</span>
            <span>{{ item.name }}</span>
            <span v-if="item.note" class="text-gray-500">
              <SquarePen class="w-3.5 h-3.5 inline-block" />
            </span>
          </div>
          <div 
            v-if="cart.length > 3" 
            :key="'more'" 
            class="px-3 py-1.5 bg-gray-100 rounded-full text-sm whitespace-nowrap text-gray-600"
          >
            +{{ cart.length - 3 }} autres
          </div>
        </transition-group>
      </div>

      <!-- Contenu du panier -->
      <div 
        v-if="isExpanded" 
        class="px-4 overflow-y-auto cart-items"
        :class="{ 'max-h-[50vh]': cart.length > 4 }"
        ref="cartItemsContainer"
      >
        <transition-group name="list" tag="div">
          <div
            v-for="item in cart"
            :key="item.id"
            class="flex justify-between items-start py-3 border-b border-gray-100 last:border-0 relative"
          >
            <!-- Bouton supprimer -->
            <button 
              @click="$emit('remove-item', item.id)"
              class="absolute top-3 right-0 w-10 h-10  border border-gray-300 rounded-full flex items-center justify-center text-gray-400 hover:text-red-500 transition-colors"
            >
              <X class="w-8 h-8" />
            </button>

            <div class="flex flex-col pr-8">
              <span class="font-medium">{{ item.name }}</span>
              <span class="text-sm text-gray-500">{{ formatPrice(item.price) }}</span>
              <div v-if="item.note" class="text-sm text-gray-500 mt-1">
                Note: {{ item.note }}
              </div>
              <div class="flex items-center space-x-4 mt-2">
                <div class="flex items-center space-x-2">
                  <button 
                    @click="$emit('remove', item.id)" 
                    class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center"
                  >
                    <Minus class="w-5 h-5" />
                  </button>
                  <span class="mx-3 font-medium w-5 text-center">{{ item.quantity }}</span>
                  <button
                    @click="$emit('increment', item.id)"
                    v-if="item.quantity<5"
                    class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center"
                    :disabled="item.quantity>=5"
                  >
                    <Plus class="w-5 h-5" />
                  </button>
                </div>
                <button 
                  @click="$emit('add-note', item.id)"
                  class="text-sm text-gray-600 underline"
                >
                  {{ item.note ? 'Modifier la note' : 'Ajouter une note' }}
                </button>
              </div>
            </div>
          </div>
        </transition-group>
      </div>

      <!-- Footer avec boutons -->
      <div v-if="isExpanded" class="px-4 py-4 bg-white border-t border-gray-100 mt-auto space-y-3">
        <div class="flex justify-between py-2">
          <span class="text-gray-600">Sous-total</span>
          <span class="font-medium">{{ formatPrice(totalPrice) }}</span>
        </div>
        
        <button
          @click="handleOrder"
          class="w-full py-3 bg-red-500 rounded-full hover:bg-red-800 text-white font-medium rounded-full transition-all transform active:scale-95 flex items-center justify-center"
          :disabled="cart.length === 0"
          :class="{ 'opacity-50 cursor-not-allowed': cart.length === 0 }"
        >
          <span class="relative text-white text-lg font-medium  ">
            Commander maintenant
          </span>
          <ArrowRight class="ml-2 w-5 h-5 " />
        </button>

        <button 
          @click="$emit('toggle')"
          class="w-full py-3 border border-gray-200 text-gray-600 font-medium rounded-full hover:bg-gray-50 transition-colors"
        >
<span class="text-red-500">          Fermer
</span>
      </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { 
  ShoppingBag, 
  ChevronUp, 
  Plus, 
  Minus, 
  SquarePen,
  ArrowRight,
  Trash2 ,X
} from 'lucide-vue-next'
import type { CartItem } from '~/types'

const props = defineProps<{
  cart: CartItem[]
  isExpanded: boolean
}>()

const emit = defineEmits<{
  (e: 'remove', itemId: string): void
  (e: 'increment', itemId: string): void
  (e: 'add-note', itemId: string): void
  (e: 'place-order'): void
  (e: 'toggle'): void
  (e: 'remove-item', itemId: string): void
}>()

const isNew = ref(false)
const orderButtonHighlight = ref(false)
const cartItemsContainer = ref(null)
const safeAreaBottom = ref(0)
let previousCartLength = 0

// Calcul des totaux
const totalItems = computed(() => 
  props.cart.reduce((sum, item) => sum + item.quantity, 0)
)

const totalPrice = computed(() => 
  props.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
)

// Style dynamique pour supporter le safe area inset
const cartStyle = computed(() => ({
  paddingBottom: props.isExpanded ? `calc(env(safe-area-inset-bottom, ${safeAreaBottom.value}px) + 0.5rem)` : 'inherit'
}))

// Handler pour commander
const handleOrder = () => {
  if (props.cart.length === 0) return
  
  orderButtonHighlight.value = true
  setTimeout(() => {
    orderButtonHighlight.value = false
    emit('place-order')
  }, 300)
}

// Surveillance des changements au panier pour animer
watch(() => props.cart.length, (newLength, oldLength) => {
  if (newLength > oldLength) {
    isNew.value = true
    setTimeout(() => {
      isNew.value = false
    }, 2000)
  }
})

// Blocage du défilement sur le body quand le panier est ouvert
watch(() => props.isExpanded, (newVal) => {
  if (newVal) {
    document.body.style.overflow = 'hidden'
    // Focus sur le conteneur pour faciliter le défilement
    nextTick(() => {
      if (cartItemsContainer.value) {
        cartItemsContainer.value.focus()
      }
    })
  } else {
    document.body.style.overflow = ''
  }
})

// Glissement pour ouvrir/fermer le panier
const startDrag = (e) => {
  e.preventDefault()
  const startY = e.clientY || e.touches?.[0]?.clientY || 0
  const initialState = props.isExpanded
  
  const handleMove = (moveEvent) => {
    const currentY = moveEvent.clientY || moveEvent.touches?.[0]?.clientY || 0
    const diff = currentY - startY
    
    // Si on glisse vers le bas et que le panier est ouvert, ou 
    // si on glisse vers le haut et que le panier est fermé
    if ((diff > 50 && initialState) || (diff < -50 && !initialState)) {
      emit('toggle')
      cleanup()
    }
  }
  
  const cleanup = () => {
    document.removeEventListener('mousemove', handleMove)
    document.removeEventListener('touchmove', handleMove)
    document.removeEventListener('mouseup', cleanup)
    document.removeEventListener('touchend', cleanup)
  }
  
  document.addEventListener('mousemove', handleMove)
  document.addEventListener('touchmove', handleMove)
  document.addEventListener('mouseup', cleanup)
  document.addEventListener('touchend', cleanup)
}

// Formatage du prix
const formatPrice = (price) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF'
  }).format(price)
}

// Détection du safe area inset pour iOS
onMounted(() => {
  // Détection de l'environnement iOS et mobile
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !(window as any).MSStream
  
  if (isIOS) {
    // Estimation si la valeur n'est pas disponible
    safeAreaBottom.value = 34 // Valeur par défaut pour iPhone X et plus récents
  }
  
  previousCartLength = props.cart.length
})

onUnmounted(() => {
  document.body.style.overflow = ''
})
</script>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.pb-safe {
  padding-bottom: env(safe-area-inset-bottom, 0);
}

/* Animation pour l'ajout d'articles */
.bounce-enter-active {
  animation: bounce-in 0.5s;
}
.bounce-leave-active {
  animation: bounce-in 0.5s reverse;
}
@keyframes bounce-in {
  0% { transform: scale(0); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

/* Animation pour la liste d'articles */
.list-enter-active,
.list-leave-active {
  transition: all 0.3s ease;
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

/* Animation pour l'aperçu des articles */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s ease;
}
.slide-fade-enter-from,
.slide-fade-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}

/* Animation du pulse */
@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.6; }
  100% { opacity: 1; }
}
.animate-pulse {
  animation: pulse 2s infinite;
}

/* Animation du ping */
@keyframes ping {
  0% { transform: scale(1); opacity: 1; }
  75%, 100% { transform: scale(2); opacity: 0; }
}
.animate-ping {
  animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;
}

.cart-items {
  scrollbar-width: thin;
  scrollbar-color: #E5E7EB transparent;
}

.cart-items::-webkit-scrollbar {
  width: 6px;
}

.cart-items::-webkit-scrollbar-track {
  background: transparent;
}

.cart-items::-webkit-scrollbar-thumb {
  background-color: #E5E7EB;
  border-radius: 20px;
}
</style>