<template>
  <div class="mx-4 my-3 rounded-3xl bg-[#FFD4AD] text-[#7C2900] px-5 py-4 text-sm font-bold" role="alert">{{ message }}</div>
</template>

<script setup lang="ts">
defineProps<{
  message: string
}>()
</script> 