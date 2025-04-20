<template>
  <span 
    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    :class="statusClasses"
  >
    <span class="w-1.5 h-1.5 rounded-full mr-1.5" :class="dotColor"></span>
    {{ statusText }}
  </span>
</template>

<script setup lang="ts">
const props = defineProps<{
  status: 'pending' | 'processing' | 'completed' | 'cancelled'
}>()

const statusConfig = {
  pending: {
    text: 'En attente',
    classes: 'bg-yellow-50 text-yellow-800',
    dot: 'bg-yellow-400'
  },
  processing: {
    text: 'En préparation',
    classes: 'bg-blue-50 text-blue-800',
    dot: 'bg-blue-400'
  },
  completed: {
    text: 'Terminé',
    classes: 'bg-green-50 text-green-800',
    dot: 'bg-green-400'
  },
  cancelled: {
    text: 'Annulé',
    classes: 'bg-red-50 text-red-800',
    dot: 'bg-red-400'
  }
}

const statusClasses = computed(() => statusConfig[props.status].classes)
const statusText = computed(() => statusConfig[props.status].text)
const dotColor = computed(() => statusConfig[props.status].dot)
</script> 