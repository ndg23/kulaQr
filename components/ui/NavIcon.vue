<template>
  <!-- Pastille de menu : rond blanc + icône orange ; actif : rond orange + icône noire (charte Kula) -->
  <span
    :class="[
      'inline-flex items-center justify-center flex-shrink-0 rounded-full w-10 h-10 transition-colors',
      active ? 'bg-[#FB6A00] text-black' : 'bg-white text-[#FB6A00]'
    ]"
    aria-hidden="true"
  >
    <component :is="icon" class="w-5 h-5" :stroke-width="2.25" />
  </span>
</template>

<script setup lang="ts">
defineProps<{ icon: any; active?: boolean }>()
</script>
