<template>
  <button
    @click="$emit('click')"
    class="w-full text-left py-4 px-6 cursor-pointer flex items-center transition-colors duration-300 border-b border-gray-100"
    :class="{ 'bg-gray-50': isActive, 'bg-white': !isActive }"
  >
    <span class="text-lg font-mono font-medium text-gray-800">{{ category.name }}</span>
    <div class="ml-auto text-gray-400">
      {{ isActive ? "-" : "+" }}
    </div>
  </button>
</template>

<script setup lang="ts">
import type { Category } from '~/types'

defineProps<{
  category: Category
  isActive: boolean
}>()

defineEmits<{
  (e: 'click'): void
}>()
</script> 