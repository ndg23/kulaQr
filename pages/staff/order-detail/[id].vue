<script setup lang="ts">
// La fiche d'une commande s'ouvre maintenant en feuille depuis /staff
definePageMeta({ layout: 'staff', middleware: () => navigateTo('/staff', { replace: true }) })
</script>

<template><div /></template>
