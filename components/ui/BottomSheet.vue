<template>
  <!-- Feuille : monte du bas sur mobile (glisser la poignée pour fermer), fenêtre centrée sur grand écran -->
  <Teleport to="body">
    <Transition name="sheet">
      <div
        v-if="modelValue"
        class="fixed inset-0 z-[60] flex items-end md:items-center justify-center"
        role="dialog"
        aria-modal="true"
        :aria-label="title"
      >
        <div class="sheet-backdrop absolute inset-0 bg-black/40 backdrop-blur-sm" @click="close"></div>

        <div
          :class="wide ? 'md:max-w-3xl' : 'md:max-w-lg'"
          class="sheet-panel relative w-full max-h-[92dvh] md:max-h-[85dvh] flex flex-col rounded-t-[2rem] md:rounded-[2rem] bg-white border border-gray-200 shadow-2xl shadow-black/20"
          :style="dragStyle"
        >
          <div
            class="md:hidden pt-3 pb-1 flex justify-center touch-none select-none"
            @touchstart.passive="onTouchStart"
            @touchmove.passive="onTouchMove"
            @touchend="onTouchEnd"
          >
            <span class="w-10 h-1.5 rounded-full bg-gray-300"></span>
          </div>

          <header class="flex items-center justify-between gap-3 px-5 pt-2 pb-3 md:pt-5">
            <div class="min-w-0">
              <h2 class="text-lg font-black text-gray-900 break-words">{{ title }}</h2>
              <p v-if="subtitle" class="text-sm font-semibold text-gray-500 break-words">{{ subtitle }}</p>
            </div>
            <button
              type="button"
              aria-label="Fermer"
              class="w-10 h-10 flex-shrink-0 rounded-full bg-gray-100 text-gray-700 flex items-center justify-center hover:bg-gray-200 active:scale-[0.94] transition-all"
              @click="close"
            >
              <X class="w-5 h-5" :stroke-width="2.5" />
            </button>
          </header>

          <div class="overflow-y-auto overflow-x-hidden overscroll-contain px-5 pb-[calc(1.25rem+env(safe-area-inset-bottom))]">
            <slot />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import { X } from 'lucide-vue-next'

const props = defineProps<{
  modelValue: boolean
  title: string
  subtitle?: string
  wide?: boolean
}>()
const emit = defineEmits<{ (e: 'update:modelValue', value: boolean): void, (e: 'close'): void }>()

const close = () => {
  emit('update:modelValue', false)
  emit('close')
}

// Fermeture au glisser (poignée)
const startY = ref<number | null>(null)
const dragY = ref(0)
const dragStyle = computed(() =>
  dragY.value > 0 ? { transform: `translateY(${dragY.value}px)`, transition: 'none' } : {}
)
const onTouchStart = (e: TouchEvent) => { startY.value = e.touches[0].clientY }
const onTouchMove = (e: TouchEvent) => {
  if (startY.value === null) return
  dragY.value = Math.max(0, e.touches[0].clientY - startY.value)
}
const onTouchEnd = () => {
  const shouldClose = dragY.value > 100
  startY.value = null
  dragY.value = 0
  if (shouldClose) close()
}

// Échap + blocage du défilement de la page
const onKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && props.modelValue) close()
}
watch(() => props.modelValue, (open) => {
  if (typeof document === 'undefined') return
  document.body.style.overflow = open ? 'hidden' : ''
  if (open) document.addEventListener('keydown', onKeydown)
  else document.removeEventListener('keydown', onKeydown)
})
onUnmounted(() => {
  if (typeof document === 'undefined') return
  document.body.style.overflow = ''
  document.removeEventListener('keydown', onKeydown)
})
</script>

<style>
.sheet-enter-active .sheet-backdrop,
.sheet-leave-active .sheet-backdrop { transition: opacity 0.25s ease; }
.sheet-enter-active .sheet-panel,
.sheet-leave-active .sheet-panel { transition: transform 0.32s cubic-bezier(0.32, 0.72, 0, 1), opacity 0.2s ease; }
.sheet-enter-from .sheet-backdrop,
.sheet-leave-to .sheet-backdrop { opacity: 0; }
.sheet-enter-from .sheet-panel,
.sheet-leave-to .sheet-panel { transform: translateY(100%); }
@media (min-width: 768px) {
  .sheet-enter-from .sheet-panel,
  .sheet-leave-to .sheet-panel { transform: translateY(12px) scale(0.98); opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sheet-enter-active .sheet-panel,
  .sheet-leave-active .sheet-panel,
  .sheet-enter-active .sheet-backdrop,
  .sheet-leave-active .sheet-backdrop { transition-duration: 0.01ms; }
}
</style>
