<script setup lang="ts">
// L'ancienne liste « Commandes Staff » est remplacée par l'écran de travail /staff
definePageMeta({ layout: 'staff', middleware: () => navigateTo('/staff', { replace: true }) })
</script>

<template><div /></template>
