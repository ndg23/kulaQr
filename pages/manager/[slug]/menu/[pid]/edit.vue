<template>
  <PageForm
    v-if="loadingData || !product"
    title="Modifier le produit"
    :back-to="`/manager/${route.params.slug}/menu`"
    back-label="Retour au menu"
    :loading-data="loadingData"
    :not-found="!loadingData && !product"
    not-found-text="Produit introuvable"
    hide-actions
  />
  <ManagerProductForm v-else :slug="String(route.params.slug)" :product="product" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const product = ref<any>(null)
const loadingData = ref(true)

onMounted(async () => {
  // L'établissement est vérifié aussi : on ne modifie pas le produit d'un autre
  const { data } = await supabase
    .from('products')
    .select('*')
    .eq('id', route.params.pid as string)
    .eq('establishment_id', route.params.slug as string)
    .maybeSingle()
  product.value = data
  loadingData.value = false
})
</script>
