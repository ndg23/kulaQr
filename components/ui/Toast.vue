<template>
  <TransitionGroup
    tag="div"
    enter-active-class="transition duration-300 ease-out"
    enter-from-class="transform translate-y-2 opacity-0"
    enter-to-class="transform translate-y-0 opacity-100"
    leave-active-class="transition duration-200 ease-in"
    leave-from-class="transform translate-y-0 opacity-100"
    leave-to-class="transform translate-y-2 opacity-0"
    class="fixed bottom-0 right-0 z-50 p-4 space-y-3"
  >
    <div
      v-for="toast in toasts"
      :key="toast.id"
      class="bg-white rounded-lg shadow-lg p-4 flex items-center max-w-md"
      :class="{
        'border-l-4 border-green-500': toast.type === 'success',
        'border-l-4 border-red-500': toast.type === 'error',
        'border-l-4 border-blue-500': toast.type === 'info'
      }"
    >
      <Icon 
        :name="getIcon(toast.type)"
        class="w-5 h-5 mr-3"
        :class="getIconColor(toast.type)"
      />
      <div class="flex-1">
        <div class="font-medium">{{ toast.title }}</div>
        <div class="text-sm text-gray-600">{{ toast.message }}</div>
      </div>
      <button 
        @click="removeToast(toast.id)"
        class="ml-4 text-gray-400 hover:text-gray-600"
      >
        <Icon name="x" class="w-4 h-4" />
      </button>
    </div>
  </TransitionGroup>
</template>

<script setup lang="ts">
import { useToast } from '~/composables/useToast'

const { toasts, removeToast } = useToast()

const getIcon = (type: string) => {
  switch (type) {
    case 'success': return 'check-circle'
    case 'error': return 'x-circle'
    default: return 'information-circle'
  }
}

const getIconColor = (type: string) => {
  switch (type) {
    case 'success': return 'text-green-500'
    case 'error': return 'text-red-500'
    default: return 'text-blue-500'
  }
}
</script> 