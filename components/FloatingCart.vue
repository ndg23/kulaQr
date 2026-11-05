<template>
  <div>
    <!-- Barre repliée : le nombre d'articles, le total, un rond orange pour ouvrir -->
    <div v-if="cart.length && !isExpanded" class="fixed inset-x-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-40 mx-auto max-w-xl">
      <button
        type="button"
        class="w-full h-[68px] pl-6 pr-2 rounded-full bg-black text-white flex items-center gap-3 shadow-xl shadow-black/20 active:scale-[0.98] transition-all"
        @click="$emit('toggle')"
      >
        <span class="min-w-0 flex-1 text-left leading-tight">
          <span class="block text-sm font-black">{{ totalItems }} article{{ totalItems > 1 ? 's' : '' }}</span>
          <span class="block text-[11px] font-semibold opacity-70 truncate">{{ recap }}</span>
        </span>
        <span class="text-xl font-black tabular-nums">{{ formatPrice(totalPrice) }}</span>
        <span class="w-[52px] h-[52px] flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><ShoppingBag class="w-6 h-6" :stroke-width="2.75" /></span>
      </button>
    </div>

    <!-- Panier déployé : une feuille -->
    <Transition
      enter-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      leave-active-class="transition-opacity duration-150"
      leave-to-class="opacity-0"
    >
      <div v-if="isExpanded" class="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-end justify-center" @click.self="$emit('toggle')">
        <div class="w-full max-w-2xl max-h-[92dvh] flex flex-col rounded-t-[2rem] bg-white" role="dialog" aria-modal="true" aria-label="Mon panier">
          <div class="pt-3 pb-1 flex justify-center"><span class="w-10 h-1.5 rounded-full bg-gray-300"></span></div>

          <header class="flex items-center justify-between gap-3 px-5 pt-1 pb-3">
            <h2 class="text-xl font-black text-gray-900">Mon panier</h2>
            <button type="button" aria-label="Fermer" class="w-10 h-10 rounded-full bg-gray-100 text-gray-700 flex items-center justify-center active:scale-[0.94] transition-all" @click="$emit('toggle')">
              <X class="w-5 h-5" :stroke-width="2.5" />
            </button>
          </header>

          <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-5 space-y-2" ref="cartItemsContainer">
            <div v-for="item in cart" :key="item.id" class="rounded-[1.75rem] bg-gray-100 p-4">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <p class="font-black text-gray-900 break-words">{{ item.name }}</p>
                  <p class="text-xs font-semibold text-gray-500">{{ formatPrice(item.price) }}</p>
                </div>
                <div class="flex items-center gap-2 flex-shrink-0">
                  <span class="font-black tabular-nums text-gray-900">{{ formatPrice(item.price * item.quantity) }}</span>
                  <button type="button" :aria-label="`Retirer ${item.name}`" class="w-9 h-9 rounded-full bg-white text-gray-500 hover:text-[#C54E00] flex items-center justify-center active:scale-[0.92] transition-all" @click="$emit('remove-item', item.id)">
                    <X class="w-4 h-4" :stroke-width="2.5" />
                  </button>
                </div>
              </div>

              <p v-if="item.note" class="mt-2 text-sm font-semibold text-[#C54E00] break-words">{{ item.note }}</p>

              <div class="mt-3 flex items-center justify-between gap-3">
                <div class="inline-flex items-center rounded-full bg-white p-1">
                  <button type="button" aria-label="Retirer un" class="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center active:scale-[0.92] transition-all" @click="$emit('remove', item.id)">
                    <Minus class="w-4 h-4" :stroke-width="3" />
                  </button>
                  <span class="w-9 text-center font-black tabular-nums">{{ item.quantity }}</span>
                  <button type="button" aria-label="Ajouter un" :disabled="item.quantity >= 5" class="w-9 h-9 rounded-full bg-black text-white flex items-center justify-center disabled:opacity-30 active:scale-[0.92] transition-all" @click="$emit('increment', item.id)">
                    <Plus class="w-4 h-4" :stroke-width="3" />
                  </button>
                </div>
                <button type="button" class="inline-flex items-center gap-1.5 h-9 px-4 rounded-full bg-white text-sm font-extrabold text-gray-900 active:scale-[0.96] transition-all" @click="$emit('add-note', item.id)">
                  <SquarePen class="w-4 h-4" :stroke-width="2.5" />
                  {{ item.note ? 'Modifier la note' : 'Ajouter une note' }}
                </button>
              </div>
            </div>
          </div>

          <footer class="px-5 pt-3 pb-[calc(1.25rem+env(safe-area-inset-bottom))] space-y-3">
            <div class="rounded-[2rem] bg-[#FB6A00] text-black p-5">
              <p class="text-xs font-extrabold uppercase">{{ totalItems }} article{{ totalItems > 1 ? 's' : '' }}</p>
              <p class="text-4xl font-black tabular-nums tracking-tight break-words">{{ formatPrice(totalPrice) }}</p>
            </div>
            <button
              type="button"
              :disabled="cart.length === 0"
              class="w-full h-16 rounded-full bg-black text-white text-lg font-black uppercase tracking-wide inline-flex items-center justify-center gap-2 disabled:opacity-40 active:scale-[0.98] transition-all"
              @click="handleOrder"
            >
              Commander
              <ArrowRight class="w-5 h-5" :stroke-width="3" />
            </button>
          </footer>
        </div>
      </div>
    </Transition>
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
