<template>
  <component
    :is="to ? NuxtLink : 'div'"
    v-bind="to ? { to } : {}"
    :class="['block rounded-[2rem] p-4 sm:p-5 min-w-0 text-gray-900', style.tint, to ? 'hover:opacity-90 transition-opacity' : '']"
  >
    <div class="flex items-center justify-between gap-2 mb-3">
      <span :class="['w-11 h-11 flex-shrink-0 rounded-full flex items-center justify-center', style.solid]" aria-hidden="true">
        <component :is="icon" v-if="icon" class="w-5 h-5" :stroke-width="2.25" />
      </span>
      <span
        v-if="badge"
        class="inline-flex items-center h-7 px-3 rounded-full bg-white/80 text-xs font-bold text-gray-900"
      >
        {{ badge }}
      </span>
    </div>

    <p class="text-sm font-bold opacity-80 break-words min-w-0">{{ name }}</p>
    <p class="mt-1 text-[clamp(1.25rem,2.4vw,1.85rem)] font-black tracking-tight leading-tight tabular-nums">
      {{ displayValue }}
    </p>
  </component>
</template>

<script setup lang="ts">
import { computed, type Component } from 'vue'
import { NuxtLink } from '#components'
import { toneOf, type Tone } from '~/utils/palette'

const props = withDefaults(defineProps<{
  name: string
  value: string | number | null | undefined
  icon?: Component
  to?: string
  badge?: string
  tone?: Tone
}>(), { tone: 'blue' })

const style = computed(() => toneOf(props.tone))

// Valeur absente => « — » : jamais un 0 qui prétendrait qu'on a compté
const displayValue = computed(() => {
  const v = props.value
  if (v === null || v === undefined || v === '') return '—'
  return typeof v === 'number' ? v.toLocaleString('fr-FR') : v
})
</script>
