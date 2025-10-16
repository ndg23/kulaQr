<template>
  <header class="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-gray-100">
    <div class="max-w-7xl mx-auto px-6 py-4">
      <div class="flex items-center justify-between">
        <!-- Left side - Title and breadcrumb -->
        <div class="flex items-center gap-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
              <component :is="icon" class="w-4 h-4 text-gray-600" />
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">{{ title }}</h1>
              <p v-if="subtitle" class="text-sm text-gray-500">{{ subtitle }}</p>
            </div>
          </div>
        </div>

        <!-- Right side - Actions -->
        <div class="flex items-center gap-3">
          <!-- Status indicator -->
          <div v-if="status" class="flex items-center gap-2 px-3 py-1.5 rounded-full text-sm font-medium"
               :class="statusClasses">
            <div class="w-2 h-2 rounded-full" :class="statusDotClasses"></div>
            <span>{{ status }}</span>
          </div>

          <!-- Primary action button -->
          <button 
            v-if="primaryAction"
            @click="primaryAction.action"
            class="flex items-center gap-2 px-4 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-800 transition-colors"
          >
            <component :is="primaryAction.icon" class="w-4 h-4" />
            <span>{{ primaryAction.label }}</span>
          </button>

          <!-- Secondary actions -->
          <div v-if="secondaryActions?.length" class="flex items-center gap-2">
            <button 
              v-for="action in secondaryActions"
              :key="action.label"
              @click="action.action"
              class="p-2 rounded-full hover:bg-gray-100 transition-colors"
              :title="action.label"
            >
              <component :is="action.icon" class="w-4 h-4 text-gray-600" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'

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

const statusClasses = computed(() => {
  const baseClasses = 'flex items-center gap-2 px-3 py-1.5 rounded-full text-sm font-medium'
  
  switch (props.statusType) {
    case 'success':
      return `${baseClasses} bg-green-50 text-green-700`
    case 'warning':
      return `${baseClasses} bg-yellow-50 text-yellow-700`
    case 'error':
      return `${baseClasses} bg-red-50 text-red-700`
    default:
      return `${baseClasses} bg-blue-50 text-blue-700`
  }
})

const statusDotClasses = computed(() => {
  switch (props.statusType) {
    case 'success':
      return 'bg-green-500'
    case 'warning':
      return 'bg-yellow-500'
    case 'error':
      return 'bg-red-500'
    default:
      return 'bg-blue-500'
  }
})
</script>

<style scoped>
/* Design Twitter 2024 - Header moderne */
.backdrop-blur-md {
  backdrop-filter: blur(12px);
}

/* Transitions fluides */
.transition-colors {
  transition: background-color 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Hover effects subtils */
.hover\:bg-gray-100:hover {
  background-color: #f3f4f6;
}

.hover\:bg-gray-800:hover {
  background-color: #1f2937;
}

/* Focus states pour l'accessibilité */
button:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}
</style>
