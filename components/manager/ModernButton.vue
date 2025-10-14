<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="buttonClasses"
    @click="handleClick"
  >
    <!-- Loading spinner -->
    <div v-if="loading" class="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
    
    <!-- Icon -->
    <component v-else-if="icon" :is="icon" class="w-4 h-4" />
    
    <!-- Button content -->
    <span v-if="$slots.default || label" class="flex items-center gap-2">
      <slot>{{ label }}</slot>
    </span>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  type?: 'button' | 'submit' | 'reset'
  disabled?: boolean
  loading?: boolean
  icon?: any
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  type: 'button',
  disabled: false,
  loading: false
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const buttonClasses = computed(() => {
  const baseClasses = 'inline-flex items-center justify-center font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed'
  
  // Size classes
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm rounded-lg',
    md: 'px-4 py-2 text-sm rounded-full',
    lg: 'px-6 py-3 text-base rounded-full'
  }
  
  // Variant classes
  const variantClasses = {
    primary: 'bg-black text-white hover:bg-gray-800 focus:ring-gray-500',
    secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-500',
    outline: 'border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 focus:ring-gray-500',
    ghost: 'text-gray-700 hover:bg-gray-100 focus:ring-gray-500',
    danger: 'bg-red-500 text-white hover:bg-red-600 focus:ring-red-500'
  }
  
  return `${baseClasses} ${sizeClasses[props.size]} ${variantClasses[props.variant]}`
})

const handleClick = (event: MouseEvent) => {
  if (!props.disabled && !props.loading) {
    emit('click', event)
  }
}
</script>

<style scoped>
/* Design Twitter 2024 - Boutons modernes */
.rounded-full {
  border-radius: 9999px;
}

.rounded-lg {
  border-radius: 0.5rem;
}

/* Transitions fluides */
.transition-all {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Animation de rotation pour le spinner */
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* Hover effects */
.hover\:bg-gray-800:hover {
  background-color: #1f2937;
}

.hover\:bg-gray-200:hover {
  background-color: #e5e7eb;
}

.hover\:bg-gray-50:hover {
  background-color: #f9fafb;
}

.hover\:bg-gray-100:hover {
  background-color: #f3f4f6;
}

.hover\:bg-red-600:hover {
  background-color: #dc2626;
}

/* Focus states */
.focus\:ring-2:focus {
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.5);
}

.focus\:ring-gray-500:focus {
  box-shadow: 0 0 0 2px rgba(107, 114, 128, 0.5);
}

.focus\:ring-red-500:focus {
  box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.5);
}

.focus\:ring-offset-2:focus {
  box-shadow: 0 0 0 2px rgba(255, 255, 255, 1), 0 0 0 4px rgba(59, 130, 246, 0.5);
}
</style>
