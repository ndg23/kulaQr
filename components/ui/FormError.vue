<template>
    <div v-if="message" class="mt-2 text-sm text-red-600 flex items-center gap-1.5">
      <AlertCircle class="w-4 h-4" />
      {{ message }}
    </div>
  </template>
  
  <script setup lang="ts">
  import { AlertCircle } from 'lucide-vue-next'
  
  defineProps<{
    message?: string
  }>()
  </script>