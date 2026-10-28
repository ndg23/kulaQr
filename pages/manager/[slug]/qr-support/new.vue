<template>
  <ManagerSupportRequestForm :slug="String(route.params.slug)" />
</template>

<script setup lang="ts">
definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
</script>
