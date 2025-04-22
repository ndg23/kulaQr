<template>
  <div 
    class="w-full max-w-7xl mx-auto px-6"
    :class="{ 
      'py-24': !noPadding,
      [className]: className
    }"
  >
    <slot />
  </div>
</template>

<script setup lang="ts">
defineProps<{
  noPadding?: boolean
  className?: string
}>()
</script> 