<template>
  <div class="min-h-screen max-w-5xl mx-auto bg-white">
    <StaffNavbar />
    <main class="max-w-5xl z-0 bg-white mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <slot />
    </main>
  </div>
</template>

<script setup>
// Layout dédié pour l'interface serveur
import StaffNavbar from '~/components/layout/StaffNavbar.vue'
</script> 