<template>
  <div 
    class="absolute inset-0 pointer-events-none pattern-grid"
    :style="{
      opacity: opacity,
      animationDuration: `${duration}s`
    }"
  ></div>
</template>

<script setup lang="ts">
defineProps({
  opacity: {
    type: Number,
    default: 0.03
  },
  duration: {
    type: Number,
    default: 60
  }
})
</script>

<style scoped>
.pattern-grid {
  background-image: url('@/assets/images/pattern.svg');
  background-repeat: repeat;
  background-size: 48px 48px;
  transform: rotate(0deg);
  animation: patternFloat linear infinite;
}

@keyframes patternFloat {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 48px 48px;
  }
}
</style> 