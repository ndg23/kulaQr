<template>
  <PageForm
    title="Nouvel utilisateur"
    subtitle="Créez un compte avec un rôle et un abonnement"
    back-to="/admin/users"
    back-label="Retour aux utilisateurs"
    submit-label="Créer l'utilisateur"
    loading-label="Création..."
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelInput id="fullName" v-model="form.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
    <FloatLabelInput id="email" v-model="form.email" type="email" label="Email" autocomplete="off" :error="errors.email" :show-char-count="false" pill required />
    <FloatLabelInput id="password" v-model="form.password" type="password" label="Mot de passe" help-text="6 caractères minimum." autocomplete="new-password" :error="errors.password" :show-char-count="false" pill required />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelSelect id="role" v-model="form.role" label="Rôle" :error="errors.role" pill required>
        <option v-for="r in ROLE_OPTIONS" :key="r.value" :value="r.value">{{ r.label }}</option>
      </FloatLabelSelect>
      <FloatLabelSelect id="tier" v-model="form.subscription_tier" label="Abonnement" pill required>
        <option v-for="t in TIER_OPTIONS" :key="t.value" :value="t.value">{{ t.label }}</option>
      </FloatLabelSelect>
    </div>

    <!-- Statut : deux pilules -->
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
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { createClient } from '@supabase/supabase-js'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { ROLE_OPTIONS, TIER_OPTIONS } from '~/utils/adminLabels'

definePageMeta({ layout: 'admin' })

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const config = useRuntimeConfig()

const statusChoices = [
  { value: 'active', label: 'Compte actif' },
  { value: 'inactive', label: 'Compte inactif' }
]

const loading = ref(false)
const error = ref('')
const errors = ref({ full_name: '', email: '', password: '', role: '' })
const form = ref({
  full_name: '',
  email: '',
  password: '',
  role: 'owner',
  status: 'active',
  subscription_tier: 'demo'
})

const TIER_DAYS: Record<string, number> = { demo: 7, pro: 30, premium: 90 }

const validate = () => {
  errors.value = { full_name: '', email: '', password: '', role: '' }
  if (!form.value.full_name.trim()) errors.value.full_name = 'Le nom complet est requis'
  if (!form.value.email.trim()) errors.value.email = "L'email est requis"
  if (form.value.password.length < 6) errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
  if (!form.value.role) errors.value.role = 'Le rôle est requis'
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    // Client jetable : signUp sur le client principal remplacerait la session de l'administrateur
    const signUpClient = createClient(config.public.supabaseUrl as string, config.public.supabaseKey as string, {
      auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
    })
    const { data: authData, error: authError } = await signUpClient.auth.signUp({
      email: form.value.email.trim(),
      password: form.value.password,
      options: { data: { full_name: form.value.full_name.trim() } }
    })
    if (authError) throw authError
    const newId = authData.user?.id
    if (!newId) throw new Error("Le compte n'a pas pu être créé")

    // Le trigger d'inscription crée déjà la ligne users : on la complète (droits admin)
    const endsAt = new Date()
    endsAt.setDate(endsAt.getDate() + (TIER_DAYS[form.value.subscription_tier] || 7))
    const { error: updateError } = await supabase
      .from('users')
      .update({
        full_name: form.value.full_name.trim(),
        email: form.value.email.trim(),
        role: form.value.role,
        is_active: form.value.status === 'active',
        subscription_tier: form.value.subscription_tier,
        subscription_ends_at: endsAt.toISOString()
      })
      .eq('id', newId)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'create',
        entity_type: 'user',
        entity_id: newId,
        details: { email: form.value.email, role: form.value.role }
      })
    }

    showToast.success('Utilisateur créé avec succès')
    await navigateTo('/admin/users')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
