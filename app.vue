<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
      <CustomToast />

    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// Configuration globale de l'application

</script>
<style scoped>
@font-face {
  font-family: 'Arial Rounded MT Bold';
  src: url('~/assets/fonts/ArialRoundedMTBold.ttf') format('truetype');
  font-weight: bold;
  font-style: normal;
}

.font-logo {
  font-family: 'Arial Rounded MT Bold', system-ui, -apple-system, sans-serif;
}
</style>
