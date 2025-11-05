<script setup lang="ts">
import { useQRTracking } from '~/composables/useQRTracking'

const route = useRoute()
const id = route.params.id as string
const tableParam = route.query.table as string | undefined

// Utiliser le composable de tracking QR
const { trackScan } = useQRTracking()

const { data, error } = await useFetch(`/api/qr/scan/${id}`, {
  method: 'POST',
  query: {
    table: tableParam
  }
}) as { data: Ref<any>, error: Ref<any> }

if (error.value) {
  throw createError({
    statusCode: error.value.statusCode,
    message: 'Menu non trouvé'
  })
}
console.log('Tracker le scan après avoir récupéré les infos de l\'établissement', data.value)
// Tracker le scan après avoir récupéré les infos de l'établissement
// if (data.value && data.value.establishment && data.value.establishment.id) {
//   await trackScan({
//     establishmentId: data.value.establishment.id,
//     tableNumber: data.value.table // Le numéro de table décodé par l'API
//   })
// }

// Rediriger vers le menu de l'établissement avec le numéro de table décodé
if (data.value && data.value.slug) {
  // const tableParam = data.value.table !== null ? `?table=${data.value.table}` : ''
  navigateTo(`/menu/${data.value.slug}?table=${tableParam}`)
} else {
  console.error('Données de redirection manquantes:', data.value)
  throw createError({
    statusCode: 404,
    message: 'Données de redirection manquantes'
  })
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-facebook mx-auto mb-4"></div>
      <p class="text-gray-600">Redirection vers le menu...</p>
    </div>
  </div>
</template> 