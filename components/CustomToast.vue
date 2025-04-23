<template>
    <div class="fixed inset-0 top-0 z-[9999] pointer-events-none flex flex-col items-center">
      <TransitionGroup 
        name="toast"
        tag="div"
        class="flex flex-col gap-4 items-center mt-4"
      >
        <div
          v-for="toast in toasts"
          :key="toast.id"
          class="pointer-events-auto max-w-md rounded-full shadow-xl overflow-hidden transform transition-all duration-300 flex items-center px-6 py-3"
          :class="[
            toast.variant === 'dark' ? 'bg-black dark:bg-gray-800 text-white' : 'bg-white dark:bg-gray-900 text-gray-900 dark:text-white',
            getBorderClass(toast.type)
          ]"
        >
          <!-- Icon -->
          <div class="shrink-0 mr-3">
            <div :class="getIconClass(toast.type)" class="flex items-center justify-center w-6 h-6 rounded-full">
              <icon v-if="toast.type === 'success'" name="i-heroicons-check" class="w-3.5 h-3.5 text-white" />
              <icon v-if="toast.type === 'error'" name="i-heroicons-x-mark" class="w-3.5 h-3.5 text-white" />
              <icon v-if="toast.type === 'info'" name="i-heroicons-information-circle" class="w-3.5 h-3.5 text-white" />
              <icon v-if="toast.type === 'warning'" name="i-heroicons-exclamation-triangle" class="w-3.5 h-3.5 text-white" />
              <icon v-if="toast.type === 'default'" name="i-heroicons-bell" class="w-3.5 h-3.5 text-white" />
            </div>
          </div>
          
          <!-- Content -->
          <div class="flex-1 min-w-0">
            <p class="font-semibold">
              {{ toast.title }}
            </p>
            <p 
              v-if="toast.description"
              class="text-sm"
              :class="toast.variant === 'dark' ? 'text-gray-200' : 'text-gray-600 dark:text-gray-300'"
            >
              {{ toast.description }}
            </p>
          </div>
  
          <!-- Close button -->
          <button
            v-if="toast.dismissible !== false"
            class="shrink-0 ml-3 rounded-full p-1.5 transition-colors"
            :class="toast.variant === 'dark' ? 'hover:bg-white/10' : 'hover:bg-gray-100 dark:hover:bg-gray-800'"
            @click="removeToast(toast.id)"
          >
            <icon 
              name="i-heroicons-x-mark" 
              class="w-4 h-4" 
              :class="toast.variant === 'dark' ? 'text-gray-300' : 'text-gray-500 dark:text-gray-400'"
            />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </template>
  
  <script setup lang="ts">
  // import { useCustomToast } from '~/composables/useCustomToast'
  
  const { toasts, removeToast } = useCustomToast()
  
  const getIconClass = (type: string) => ({
    'bg-green-500': type === 'success',
    'bg-red-500': type === 'error',
    'bg-blue-500': type === 'info',
    'bg-yellow-500': type === 'warning',
    'bg-gray-500': type === 'default' || !type,
  })
  
  const getBorderClass = (type: string) => ({
    'border-2 border-green-500': type === 'success',
    'border-2 border-red-500': type === 'error',
    'border-2 border-blue-500': type === 'info',
    'border-2 border-yellow-500': type === 'warning',
    'border-2 border-gray-300 dark:border-gray-700': type === 'default' || !type,
  })
  </script>
  
  <style scoped>
  .toast-enter-active,
  .toast-leave-active {
    transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  
  .toast-enter-from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  
  .toast-leave-to {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  </style>