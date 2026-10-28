<template>
  <PageForm
    title="Modifier l'utilisateur"
    :subtitle="user?.email"
    back-to="/admin/users"
    back-label="Retour aux utilisateurs"
    submit-label="Mettre à jour"
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !user"
    not-found-text="Utilisateur introuvable"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelInput id="fullName" v-model="form.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
    <FloatLabelInput id="phone" v-model="form.phone" type="tel" label="Téléphone" autocomplete="off" :show-char-count="false" pill />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelSelect id="role" v-model="form.role" label="Rôle" pill required>
        <option v-for="r in ROLE_OPTIONS" :key="r.value" :value="r.value">{{ r.label }}</option>
      </FloatLabelSelect>
      <FloatLabelSelect id="tier" v-model="form.subscription_tier" label="Abonnement" pill required>
        <option v-for="t in TIER_OPTIONS" :key="t.value" :value="t.value">{{ t.label }}</option>
      </FloatLabelSelect>
    </div>

    <FloatLabelInput id="endsAt" v-model="form.subscription_ends_at" type="date" label="Fin d'abonnement" :show-char-count="false" pill />

    <div class="flex gap-2" role="radiogroup" aria-label="Statut du compte">
      <button
        v-for="s in statusChoices"
        :key="s.value"
        type="button"
        role="radio"
        :aria-checked="form.status === s.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          form.status === s.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="form.status = s.value"
      >{{ s.label }}</button>
    </div>

    <!-- Les autres actions ont chacune leur page -->
    <div class="flex flex-wrap gap-2 pt-1">
      <NuxtLink :to="`/admin/users/${route.params.id}/role`" class="h-10 px-4 rounded-full bg-[#EFEAFF] text-[#4B2FCC] text-sm font-bold inline-flex items-center hover:opacity-80 transition-opacity">Changer le rôle</NuxtLink>
      <NuxtLink :to="`/admin/users/${route.params.id}/subscription`" class="h-10 px-4 rounded-full bg-[#D6FBE6] text-[#00632F] text-sm font-bold inline-flex items-center hover:opacity-80 transition-opacity">Gérer l'abonnement</NuxtLink>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { ROLE_OPTIONS, TIER_OPTIONS } from '~/utils/adminLabels'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const statusChoices = [
  { value: 'active', label: 'Compte actif' },
  { value: 'inactive', label: 'Compte inactif' }
]

const user = ref<any>(null)
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')
const errors = ref({ full_name: '' })
const form = ref({
  full_name: '',
  phone: '',
  role: 'owner',
  status: 'active',
  subscription_tier: 'demo',
  subscription_ends_at: ''
})

onMounted(async () => {
  const { data, error: loadError } = await supabase
    .from('users')
    .select('*')
    .eq('id', route.params.id as string)
    .maybeSingle()
  if (loadError) error.value = loadError.message
  user.value = data
  if (data) {
    form.value = {
      full_name: data.full_name || '',
      phone: data.phone || '',
      role: data.role || 'owner',
      status: data.is_active ? 'active' : 'inactive',
      subscription_tier: data.subscription_tier || 'demo',
      subscription_ends_at: data.subscription_ends_at ? new Date(data.subscription_ends_at).toISOString().split('T')[0] : ''
    }
  }
  loadingData.value = false
})

const handleSubmit = async () => {
  errors.value = { full_name: '' }
  if (!form.value.full_name.trim()) {
    errors.value.full_name = 'Le nom complet est requis'
    return
  }
  loading.value = true
  error.value = ''
  try {
    const updates = {
      full_name: form.value.full_name.trim(),
      phone: form.value.phone.trim() || null,
      role: form.value.role,
      is_active: form.value.status === 'active',
      subscription_tier: form.value.subscription_tier,
      subscription_ends_at: form.value.subscription_ends_at ? new Date(form.value.subscription_ends_at).toISOString() : null
    }
    const { error: updateError } = await supabase.from('users').update(updates).eq('id', user.value.id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'update',
        entity_type: 'user',
        entity_id: user.value.id,
        details: { updated_fields: Object.keys(updates) }
      })
    }
    showToast.success('Utilisateur mis à jour avec succès')
    await navigateTo('/admin/users')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
