<template>
  <PageForm
    title="Changer le rôle"
    :subtitle="user?.full_name"
    back-to="/admin/users"
    back-label="Retour aux utilisateurs"
    submit-label="Changer le rôle"
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !user"
    not-found-text="Utilisateur introuvable"
    :error="error"
    @submit="handleSubmit"
  >
    <!-- Rôle actuel -->
    <div class="rounded-3xl bg-gray-100 p-4">
      <p class="text-xs font-bold uppercase tracking-wide text-gray-500 mb-2">Rôle actuel</p>
      <span :class="['inline-flex items-center h-8 px-4 rounded-full text-sm font-bold', roleBadgeClass(user?.role)]">
        {{ roleLabel(user?.role) }}
      </span>
    </div>

    <!-- Nouveau rôle : une pilule par rôle -->
    <fieldset>
      <legend class="text-sm font-extrabold text-gray-900 px-1 mb-2">Nouveau rôle</legend>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
        <label
          v-for="r in ROLE_OPTIONS"
          :key="r.value"
          :class="[
            'flex items-center gap-3 h-12 px-5 rounded-full cursor-pointer select-none transition-colors font-bold',
            newRole === r.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
          ]"
        >
          <input v-model="newRole" type="radio" name="role" :value="r.value" class="sr-only" />
          <span class="flex-1">{{ r.label }}</span>
          <Check v-if="newRole === r.value" class="w-4 h-4" :stroke-width="3" />
        </label>
      </div>
    </fieldset>

    <div v-if="newRole === 'admin'" class="rounded-3xl bg-[#FFF9C2] p-4 flex gap-3">
      <AlertTriangle class="w-5 h-5 flex-shrink-0 mt-0.5 text-[#6B5B00]" />
      <div>
        <p class="text-sm font-extrabold text-gray-900">Attention</p>
        <p class="text-sm text-gray-700 mt-0.5">Le rôle Administrateur donne accès à toutes les fonctionnalités de la plateforme.</p>
      </div>
    </div>

    <div v-if="newRole && user && newRole !== user.role" class="flex flex-wrap items-center gap-2 text-sm">
      <span class="font-bold text-gray-500">Changement</span>
      <span :class="['inline-flex items-center h-7 px-3 rounded-full text-xs font-bold', roleBadgeClass(user.role)]">{{ roleLabel(user.role) }}</span>
      <ChevronRight class="w-4 h-4 text-gray-400" />
      <span :class="['inline-flex items-center h-7 px-3 rounded-full text-xs font-bold', roleBadgeClass(newRole)]">{{ roleLabel(newRole) }}</span>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Check, AlertTriangle, ChevronRight } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { ROLE_OPTIONS, roleLabel, roleBadgeClass } from '~/utils/adminLabels'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const user = ref<any>(null)
const newRole = ref('')
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')

onMounted(async () => {
  const { data, error: loadError } = await supabase
    .from('users')
    .select('id, full_name, role')
    .eq('id', route.params.id as string)
    .maybeSingle()
  if (loadError) error.value = loadError.message
  user.value = data
  newRole.value = data?.role || ''
  loadingData.value = false
})

const handleSubmit = async () => {
  if (!newRole.value) {
    error.value = 'Veuillez sélectionner un rôle'
    return
  }
  if (newRole.value === user.value.role) {
    error.value = 'Le nouveau rôle est identique au rôle actuel'
    return
  }
  loading.value = true
  error.value = ''
  try {
    const { error: updateError } = await supabase.from('users').update({ role: newRole.value }).eq('id', user.value.id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'update',
        entity_type: 'user',
        entity_id: user.value.id,
        details: { field: 'role', old_value: user.value.role, new_value: newRole.value }
      })
    }
    showToast.success(`Rôle changé de ${roleLabel(user.value.role)} à ${roleLabel(newRole.value)}`)
    await navigateTo('/admin/users')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
