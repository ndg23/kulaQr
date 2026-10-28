<template>
  <PageForm
    v-if="loadingData || !category"
    title="Modifier la catégorie"
    :back-to="`/manager/${route.params.slug}/categories`"
    back-label="Retour aux catégories"
    :loading-data="loadingData"
    :not-found="!loadingData && !category"
    not-found-text="Catégorie introuvable"
    hide-actions
  />
  <ManagerCategoryForm v-else :slug="String(route.params.slug)" :category="category" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const category = ref<any>(null)
const loadingData = ref(true)

onMounted(async () => {
  // L'établissement est vérifié aussi : on ne modifie pas la catégorie d'un autre
  const { data } = await supabase
    .from('categories')
    .select('*')
    .eq('id', route.params.cid as string)
    .eq('establishment_id', route.params.slug as string)
    .maybeSingle()
  category.value = data
  loadingData.value = false
})
</script>
