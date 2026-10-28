<template>
  <PageForm
    v-if="loadingData || !request"
    title="Modifier la demande"
    :back-to="`/manager/${route.params.slug}/qr-support`"
    back-label="Retour aux demandes"
    :loading-data="loadingData"
    :not-found="!loadingData && !request"
    not-found-text="Demande introuvable"
    hide-actions
  />
  <ManagerSupportRequestForm v-else :slug="String(route.params.slug)" :request="request" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const request = ref<any>(null)
const loadingData = ref(true)

onMounted(async () => {
  // L'établissement est vérifié aussi : on ne modifie pas la demande d'un autre
  const { data } = await supabase
    .from('qr_support_requests')
    .select('*')
    .eq('id', route.params.rid as string)
    .eq('establishment_id', route.params.slug as string)
    .maybeSingle()
  request.value = data
  loadingData.value = false
})
</script>
