<template>
  <RescanQRScreen
    title="Session expirée"
    message="Votre session a expiré. Scannez à nouveau le QR code."
    button-text="Nouveau scan"
    @rescan="handleRescan"
    @go-back="navigateTo('/')"
    @contact-support="openSupport"
  />
</template>

<script setup>
const handleRescan = () => {
  // Logique de rescan
}
</script>