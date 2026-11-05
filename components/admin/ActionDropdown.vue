<template>
  <div ref="root" class="relative inline-block text-left">
    <!-- Bouton : pilule noire avec les trois points -->
    <button
      type="button"
      :aria-label="triggerText"
      :aria-expanded="open"
      aria-haspopup="menu"
      class="inline-flex items-center justify-center gap-2 h-11 rounded-full bg-gray-100 text-gray-900 font-extrabold text-sm hover:bg-gray-200 active:scale-[0.96] transition-all"
      :class="triggerText && triggerText !== 'Actions' ? 'px-4' : 'w-11'"
      @click.stop="toggle"
    >
      <component :is="triggerIcon" class="w-5 h-5" :stroke-width="2.5" />
      <span v-if="triggerText && triggerText !== 'Actions'">{{ triggerText }}</span>
    </button>

    <!-- Grand écran : petite carte ronde sous le bouton -->
    <Transition
      enter-active-class="transition ease-out duration-150"
      enter-from-class="opacity-0 scale-95 -translate-y-1"
      enter-to-class="opacity-100 scale-100 translate-y-0"
      leave-active-class="transition ease-in duration-100"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="open && isDesktop"
        role="menu"
        class="absolute right-0 z-50 mt-2 w-64 origin-top-right rounded-[1.75rem] bg-white border border-gray-200 shadow-xl p-2 space-y-1"
      >
        <button
          v-for="action in ordered"
          :key="action.id"
          type="button"
          role="menuitem"
          :disabled="action.disabled"
          class="w-full h-12 px-3 rounded-full flex items-center gap-3 text-left text-sm font-extrabold transition-colors disabled:opacity-40"
          :class="action.variant === 'danger' ? 'text-[#7C2900] hover:bg-[#FFECD8]' : 'text-gray-900 hover:bg-gray-100'"
          @click="handleAction(action)"
        >
          <span
            class="w-8 h-8 flex-shrink-0 rounded-full flex items-center justify-center"
            :class="action.variant === 'danger' ? 'bg-[#C54E00] text-white' : 'bg-gray-100 text-[#FB6A00]'"
          >
            <component :is="action.icon" class="w-4 h-4" :stroke-width="2.5" />
          </span>
          <span class="flex-1 min-w-0 truncate">{{ action.label }}</span>
          <span v-if="action.badge" class="inline-flex items-center h-6 px-2.5 rounded-full bg-black text-white text-xs font-extrabold">{{ action.badge.text }}</span>
        </button>
      </div>
    </Transition>

    <!-- Mobile : une feuille qui monte du bas -->
    <UiActionSheet
      v-if="!isDesktop"
      :model-value="open"
      :title="sheetTitle"
      :actions="sheetActions"
      @update:model-value="v => { open = v }"
      @select="onSheetSelect"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { MoreHorizontal } from 'lucide-vue-next'
import UiActionSheet from '~/components/ui/ActionSheet.vue'

interface ActionBadge {
  text: string
  variant: 'success' | 'warning' | 'error' | 'info' | 'neutral'
}

interface DropdownAction {
  id: string
  label: string
  icon: any
  variant: 'primary' | 'secondary' | 'danger'
  disabled?: boolean
  badge?: ActionBadge
  callback?: () => void
}

const props = defineProps<{
  actions: DropdownAction[]
  triggerText?: string
  triggerIcon?: any
  /** Titre de la feuille sur mobile (par défaut « Options ») */
  title?: string
}>()

const emit = defineEmits<{
  action: [action: DropdownAction]
}>()

const root = ref<HTMLElement | null>(null)
const open = ref(false)
const isDesktop = ref(true)

const triggerText = computed(() => props.triggerText || 'Actions')
const triggerIcon = computed(() => props.triggerIcon || MoreHorizontal)
const sheetTitle = computed(() => props.title || 'Options')

// Principales d'abord, secondaires ensuite, la suppression en dernier
const ordered = computed(() => [
  ...props.actions.filter(a => a.variant === 'primary'),
  ...props.actions.filter(a => a.variant === 'secondary'),
  ...props.actions.filter(a => a.variant === 'danger')
])
const sheetActions = computed(() =>
  ordered.value.map(a => ({
    key: a.id,
    label: a.label,
    icon: a.icon,
    danger: a.variant === 'danger',
    disabled: a.disabled,
    hint: a.badge?.text
  }))
)

const toggle = () => { open.value = !open.value }

const handleAction = (action: DropdownAction) => {
  if (action.disabled) return
  open.value = false
  action.callback?.()
  emit('action', action)
}
const onSheetSelect = (key: string) => {
  const action = props.actions.find(a => a.id === key)
  if (action) handleAction(action)
}

// Grand écran : on ferme au clic en dehors ou sur Échap
const media = typeof window !== 'undefined' ? window.matchMedia('(min-width: 768px)') : null
const syncMedia = () => { isDesktop.value = media ? media.matches : true }
const onDocClick = (e: MouseEvent) => {
  if (open.value && isDesktop.value && root.value && !root.value.contains(e.target as Node)) open.value = false
}
const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') open.value = false }

onMounted(() => {
  syncMedia()
  media?.addEventListener('change', syncMedia)
  document.addEventListener('click', onDocClick)
  document.addEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  media?.removeEventListener('change', syncMedia)
  document.removeEventListener('click', onDocClick)
  document.removeEventListener('keydown', onKey)
})
</script>
