<template>
  <span :class="['inline-flex items-center justify-center flex-shrink-0 rounded-full', sizes[size], style.solid]" aria-hidden="true">
    <component :is="icon" :class="iconSizes[size]" :stroke-width="2.25" />
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { toneOf, type Tone } from '~/utils/palette'

// Pastille ronde pleine : icône à contraste garanti (voir utils/palette.ts).
const props = withDefaults(defineProps<{
  icon: any
  tone?: Tone
  size?: 'sm' | 'md' | 'lg'
}>(), { size: 'md' })

const style = computed(() => toneOf(props.tone))
const sizes = { sm: 'w-8 h-8', md: 'w-10 h-10', lg: 'w-12 h-12' }
const iconSizes = { sm: 'w-4 h-4', md: 'w-5 h-5', lg: 'w-6 h-6' }
</script>
