<template>
  <PageForm
    v-if="loadingData || !table"
    title="Modifier l'emplacement"
    :back-to="`/manager/${route.params.slug}/tables`"
    back-label="Retour aux emplacements"
    :loading-data="loadingData"
    :not-found="!loadingData && !table"
    not-found-text="Emplacement introuvable"
    hide-actions
  />
  <ManagerTableForm v-else :slug="String(route.params.slug)" :table="table" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const table = ref<any>(null)
const loadingData = ref(true)

onMounted(async () => {
  // L'établissement est vérifié aussi : on ne modifie pas la table d'un autre
  const { data } = await supabase
    .from('tables')
    .select('*')
    .eq('id', route.params.tid as string)
    .eq('establishment_id', route.params.slug as string)
    .maybeSingle()
  table.value = data
  loadingData.value = false
})
</script>
