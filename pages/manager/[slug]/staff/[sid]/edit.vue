<template>
  <PageForm
    v-if="loadingData || !member"
    title="Modifier le membre"
    :back-to="`/manager/${route.params.slug}/staff`"
    back-label="Retour au personnel"
    :loading-data="loadingData"
    :not-found="!loadingData && !member"
    not-found-text="Membre introuvable"
    hide-actions
  />
  <ManagerStaffForm v-else :slug="String(route.params.slug)" :member="member" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const member = ref<any>(null)
const loadingData = ref(true)

onMounted(async () => {
  // L'établissement est vérifié aussi : on ne modifie pas le personnel d'un autre
  const { data } = await supabase
    .from('staff')
    .select('id, username, role, is_active, pin')
    .eq('id', route.params.sid as string)
    .eq('establishment_id', route.params.slug as string)
    .maybeSingle()
  member.value = data
  loadingData.value = false
})
</script>
