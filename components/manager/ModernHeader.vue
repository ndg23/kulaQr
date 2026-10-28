<template>
  <header class="mb-5 sm:mb-6 flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
    <div class="flex items-center gap-3 min-w-0">
      <IconBadge :icon="icon || nav.icon" :tone="nav.tone" size="lg" />
      <div class="min-w-0">
        <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900 break-words">{{ title }}</h1>
        <p v-if="subtitle" class="text-sm text-gray-500 break-words">{{ subtitle }}</p>
      </div>
    </div>

    <div v-if="status || primaryAction || secondaryActions?.length" class="flex flex-wrap items-center gap-2 lg:justify-end">
      <span
        v-if="status"
        :class="['inline-flex items-center gap-2 h-9 px-4 rounded-full text-sm font-bold', statusClasses]"
      >
        <span class="w-2 h-2 rounded-full" :class="statusDotClasses" />
        {{ status }}
      </span>

      <button
        v-for="action in secondaryActions"
        :key="action.label"
        type="button"
        :aria-label="action.label"
        :title="action.label"
        class="w-11 h-11 rounded-full bg-gray-100 text-gray-700 flex items-center justify-center hover:bg-gray-200 active:scale-[0.96] transition-all"
        @click="action.action"
      >
        <component :is="action.icon" class="w-5 h-5" />
      </button>

      <button
        v-if="primaryAction"
        type="button"
        class="h-11 px-5 bg-gray-900 text-white rounded-full text-sm font-bold inline-flex items-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all"
        @click="primaryAction.action"
      >
        <component :is="primaryAction.icon" class="w-4 h-4" :stroke-width="2.5" />
        <span>{{ primaryAction.label }}</span>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import IconBadge from '~/components/ui/IconBadge.vue'
import { managerNavForPath } from '~/utils/managerNav'

interface Action {
  label: string
  icon: any
  action: () => void
}

interface Props {
  title: string
  subtitle?: string
  icon?: any
  status?: string
  statusType?: 'success' | 'warning' | 'error' | 'info'
  primaryAction?: Action
  secondaryActions?: Action[]
}

const props = withDefaults(defineProps<Props>(), {
  statusType: 'info'
})

// Couleur de la pastille d'icône : celle de l'entrée de menu de la page courante
const route = useRoute()
const nav = computed(() => managerNavForPath(`/manager/${route.params.slug}`, route.path))

const statusClasses = computed(() => ({
  success: 'bg-[#D6FBE6] text-[#00632F]',
  warning: 'bg-[#FFF9C2] text-[#6B5B00]',
  error: 'bg-[#FFE0F0] text-[#A10054]',
  info: 'bg-[#E8EEFF] text-[#1741B8]'
}[props.statusType]))

const statusDotClasses = computed(() => ({
  success: 'bg-[#00A650]',
  warning: 'bg-[#C9A900]',
  error: 'bg-[#FF007F]',
  info: 'bg-[#2962FF]'
}[props.statusType]))
</script>
