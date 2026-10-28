<template>
  <header class="mb-5 sm:mb-6 flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
    <div class="flex items-center gap-3 min-w-0">
      <IconBadge :icon="resolvedIcon" :tone="resolvedTone" size="lg" />
      <div class="min-w-0">
        <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900 break-words">{{ title }}</h1>
        <p v-if="description" class="text-sm text-gray-500 break-words">{{ description }}</p>
      </div>
    </div>
    <div v-if="$slots.actions" class="flex flex-wrap items-center gap-2 lg:justify-end">
      <slot name="actions" />
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import IconBadge from '~/components/ui/IconBadge.vue'
import { adminNavForPath } from '~/utils/adminNav'
import { managerNavForPath } from '~/utils/managerNav'
import type { Tone } from '~/utils/palette'

// Icône et couleur viennent de la page courante (même table que le menu du back-office ou de l'espace manager)
// sauf si la page les impose
const props = defineProps<{
  title: string
  description?: string
  icon?: any
  tone?: Tone
}>()

const route = useRoute()
const nav = computed(() =>
  route.path.startsWith('/manager/')
    ? managerNavForPath(`/manager/${route.params.slug}`, route.path)
    : adminNavForPath(route.path)
)
const resolvedIcon = computed(() => props.icon || nav.value.icon)
const resolvedTone = computed(() => props.tone || nav.value.tone)
</script>
