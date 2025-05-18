<template>
  <header class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
      <div class="flex justify-between items-center">
        <div class="flex items-center">
          <NuxtLink 
            v-if="backLink" 
            :to="backLink"
            class="mr-4 p-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <ChevronLeft class="w-5 h-5 text-gray-500" />
          </NuxtLink>
          <h1 class="text-xl font-semibold text-gray-900">{{ title }}</h1>
        </div>
        <div class="flex items-center space-x-4">
          <slot name="actions"></slot>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ChevronLeft } from 'lucide-vue-next'

defineProps({
  title: {
    type: String,
    required: true
  },
  backLink: {
    type: String,
    default: null
  }
})
</script> 