<template>
  <!-- Menu d'options en feuille (au lieu d'une carte déroulante) : une pilule par action, la plus sensible en bas -->
  <UiBottomSheet :model-value="modelValue" :title="title" :subtitle="subtitle" @update:model-value="v => emit('update:modelValue', v)">
    <div class="space-y-2">
      <slot name="header" />
      <component
        :is="action.to ? NuxtLink : 'button'"
        v-for="action in actions"
        :key="action.key"
        :to="action.to"
        :type="action.to ? undefined : 'button'"
        :disabled="action.disabled"
        class="w-full min-h-[3.5rem] px-4 rounded-full flex items-center gap-3 text-left font-extrabold active:scale-[0.98] transition-all disabled:opacity-40"
        :class="action.danger ? 'bg-[#FFECD8] text-[#7C2900]' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
        @click="pick(action)"
      >
        <span
          class="w-10 h-10 flex-shrink-0 rounded-full flex items-center justify-center"
          :class="action.danger ? 'bg-[#C54E00] text-white' : 'bg-white text-[#FB6A00]'"
        >
          <component :is="action.icon" v-if="action.icon" class="w-5 h-5" :stroke-width="2.25" />
        </span>
        <span class="flex-1 min-w-0 leading-tight">
          <span class="block break-words">{{ action.label }}</span>
          <span v-if="action.hint" class="block text-xs font-semibold text-gray-500 break-words">{{ action.hint }}</span>
        </span>
      </component>
    </div>
  </UiBottomSheet>
</template>

<script setup lang="ts">
import { resolveComponent } from 'vue'
import UiBottomSheet from '~/components/ui/BottomSheet.vue'

export interface SheetAction {
  key: string
  label: string
  icon?: any
  hint?: string
  to?: string
  danger?: boolean
  disabled?: boolean
}

defineProps<{
  modelValue: boolean
  title: string
  subtitle?: string
  actions: SheetAction[]
}>()
const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
  (e: 'select', key: string): void
}>()

const NuxtLink = resolveComponent('NuxtLink')

// Une action lien ferme la feuille et navigue ; les autres préviennent la page, qui décide de la suite
const pick = (action: SheetAction) => {
  emit('select', action.key)
  emit('update:modelValue', false)
}
</script>
