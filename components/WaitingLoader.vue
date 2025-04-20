<template>
  <Transition>
    <div
      v-if="isVisible"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white p-6 rounded-lg shadow-lg text-center">
        <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-gray-900 mx-auto mb-4"></div>
        <p class="font-mono text-lg">En attente de confirmation...</p>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
defineProps<{
  isVisible: boolean
}>()
</script>

<style scoped>
.v-enter-active,
.v-leave-active {
  transition: opacity 0.3s ease;
}

.v-enter-from,
.v-leave-to {
  opacity: 0;
}
</style> 