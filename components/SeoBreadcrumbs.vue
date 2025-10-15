<template>
  <nav v-if="breadcrumbs.length > 0" class="flex items-center space-x-2 text-sm text-gray-500 mb-6" aria-label="Breadcrumb">
    <NuxtLink 
      v-for="(item, index) in breadcrumbs" 
      :key="index"
      :to="item.url"
      class="hover:text-gray-700 transition-colors"
      :class="{ 'text-gray-900 font-medium': index === breadcrumbs.length - 1 }"
    >
      {{ item.name }}
    </NuxtLink>
    <span v-if="index < breadcrumbs.length - 1" class="text-gray-400">/</span>
  </nav>
</template>

<script setup lang="ts">
interface Breadcrumb {
  name: string
  url: string
}

defineProps<{
  breadcrumbs: Breadcrumb[]
}>()
</script>
