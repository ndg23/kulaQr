<template>
  <PageForm
    title="Nouvel administrateur"
    subtitle="Accès complet à la plateforme"
    back-to="/admin/admins"
    back-label="Retour aux administrateurs"
    submit-label="Ajouter l'administrateur"
    loading-label="Ajout..."
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelInput id="fullName" v-model="form.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
    <FloatLabelInput id="email" v-model="form.email" type="email" label="Email" autocomplete="off" :error="errors.email" :show-char-count="false" pill required />
    <FloatLabelInput id="password" v-model="form.password" type="password" label="Mot de passe" help-text="6 caractères minimum." autocomplete="new-password" :error="errors.password" :show-char-count="false" pill required />

    <div class="rounded-3xl bg-[#FFF9C2] p-4 flex gap-3">
      <AlertTriangle class="w-5 h-5 flex-shrink-0 mt-0.5 text-[#6B5B00]" />
      <p class="text-sm text-gray-700">Un administrateur peut gérer tous les utilisateurs, établissements et abonnements.</p>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { AlertTriangle } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const createAuthUser = useCreateAuthUser()

const loading = ref(false)
const error = ref('')
const errors = ref({ full_name: '', email: '', password: '' })
const form = ref({ full_name: '', email: '', password: '' })

const validate = () => {
  errors.value = { full_name: '', email: '', password: '' }
  if (!form.value.full_name.trim()) errors.value.full_name = 'Le nom complet est requis'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) errors.value.email = 'Email invalide'
  if (form.value.password.length < 6) errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    const id = await createAuthUser({
      email: form.value.email,
      password: form.value.password,
      fullName: form.value.full_name
    })
    // Le trigger a créé le profil en « owner » inactif : l'administrateur connecté le promeut
    const { error: updateError } = await supabase.from('users').update({
      full_name: form.value.full_name.trim(),
      email: form.value.email.trim(),
      role: 'admin',
      is_active: true
    }).eq('id', id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'create',
        entity_type: 'user',
        entity_id: id,
        details: { email: form.value.email, role: 'admin' }
      })
    }
    showToast.success('Administrateur ajouté avec succès')
    await navigateTo('/admin/admins')
  } catch (err: any) {
    error.value = err?.message || "Impossible d'ajouter l'administrateur"
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
