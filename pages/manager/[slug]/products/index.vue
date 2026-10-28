<template>
  <div />
</template>

<script setup lang="ts">
// Les produits se gèrent depuis le menu (même écran, sans doublon)
definePageMeta({
  layout: 'manager',
  middleware: 'auth',
  redirect: (to) => ({ path: `/manager/${to.params.slug}/menu` })
})
</script>
