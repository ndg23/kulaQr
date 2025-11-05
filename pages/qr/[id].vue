<script setup lang="ts">
const route = useRoute()
const id = route.params.id as string
const tableParam = route.query.table as string | undefined

const { data, error } = await useFetch(`/api/qr/scan/${id}`, {
  method: 'POST'
})

if (error.value) {
  throw createError({
    statusCode: error.value.statusCode,
    message: 'Menu non trouvé'
  })
}

// Rediriger vers le menu de l'établissement avec le numéro de table
navigateTo(`/menu/${data.value?.slug}?table=${tableParam}`)
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-facebook mx-auto mb-4"></div>
      <p class="text-gray-600">Redirection vers le menu...</p>
    </div>
  </div>
</template> 