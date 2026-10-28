<template>
  <PageForm
    title="Nouvel établissement"
    subtitle="Créez un établissement et rattachez-le à un propriétaire"
    back-to="/admin/establishments"
    back-label="Retour aux établissements"
    submit-label="Créer l'établissement"
    loading-label="Création..."
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <h2 class="text-sm font-extrabold text-gray-900 px-1">Établissement</h2>
    <FloatLabelInput id="name" v-model="form.name" label="Nom de l'établissement" autocomplete="off" :error="errors.name" :show-char-count="false" pill required />
    <FloatLabelInput id="address" v-model="form.address" label="Adresse" autocomplete="off" :show-char-count="false" pill />
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelInput id="phone" v-model="form.phone" type="tel" label="Téléphone" autocomplete="off" :show-char-count="false" pill />
      <FloatLabelInput id="email" v-model="form.email" type="email" label="Email" autocomplete="off" :show-char-count="false" pill />
    </div>
    <FloatLabelSelect id="type" v-model="form.type_id" label="Type d'établissement" pill>
      <option value="">Non précisé</option>
      <option v-for="t in establishmentTypes" :key="t.id" :value="t.id">{{ t.name }}</option>
    </FloatLabelSelect>

    <h2 class="text-sm font-extrabold text-gray-900 px-1 pt-3">Propriétaire</h2>
    <div class="flex gap-2" role="radiogroup" aria-label="Type de propriétaire">
      <button
        v-for="o in ownerChoices"
        :key="o.value"
        type="button"
        role="radio"
        :aria-checked="ownerType === o.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          ownerType === o.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="ownerType = o.value"
      >{{ o.label }}</button>
    </div>

    <FloatLabelSelect v-if="ownerType === 'existing'" id="owner" v-model="selectedOwnerId" label="Propriétaire" :error="errors.owner" pill required>
      <option value="" disabled>Sélectionner un propriétaire</option>
      <option v-for="o in owners" :key="o.id" :value="o.id">{{ o.full_name || o.email }}{{ o.phone ? ` · ${o.phone}` : '' }}</option>
    </FloatLabelSelect>

    <template v-else>
      <FloatLabelInput id="ownerName" v-model="newOwner.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
      <FloatLabelInput id="ownerEmail" v-model="newOwner.email" type="email" label="Email" autocomplete="off" :error="errors.owner_email" :show-char-count="false" pill required />
      <FloatLabelInput id="ownerPhone" v-model="newOwner.phone" type="tel" label="Téléphone" autocomplete="off" :show-char-count="false" pill />
      <FloatLabelInput id="ownerPassword" v-model="newOwner.password" type="password" label="Mot de passe" help-text="6 caractères minimum." autocomplete="new-password" :error="errors.password" :show-char-count="false" pill required />
    </template>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const createAuthUser = useCreateAuthUser()

const ownerChoices = [
  { value: 'existing', label: 'Propriétaire existant' },
  { value: 'new', label: 'Nouveau propriétaire' }
]

const loading = ref(false)
const error = ref('')
const errors = ref({ name: '', owner: '', full_name: '', owner_email: '', password: '' })
const ownerType = ref('existing')
const selectedOwnerId = ref('')
const owners = ref<any[]>([])
const establishmentTypes = ref<any[]>([])
const form = ref({ name: '', address: '', phone: '', email: '', type_id: '' })
const newOwner = ref({ full_name: '', email: '', phone: '', password: '' })

onMounted(async () => {
  const [ownersRes, typesRes] = await Promise.all([
    supabase.from('users').select('id, full_name, email, phone').eq('role', 'owner').order('full_name'),
    supabase.from('establishment_types').select('id, name').order('name')
  ])
  owners.value = ownersRes.data || []
  establishmentTypes.value = typesRes.data || []
})

const validate = () => {
  errors.value = { name: '', owner: '', full_name: '', owner_email: '', password: '' }
  if (!form.value.name.trim()) errors.value.name = "Le nom de l'établissement est requis"
  if (ownerType.value === 'existing') {
    if (!selectedOwnerId.value) errors.value.owner = 'Sélectionnez un propriétaire'
  } else {
    if (!newOwner.value.full_name.trim()) errors.value.full_name = 'Le nom complet est requis'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(newOwner.value.email)) errors.value.owner_email = 'Email invalide'
    if (newOwner.value.password.length < 6) errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
  }
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    let ownerId = selectedOwnerId.value

    if (ownerType.value === 'new') {
      ownerId = await createAuthUser({
        email: newOwner.value.email,
        password: newOwner.value.password,
        fullName: newOwner.value.full_name,
        phone: newOwner.value.phone
      })
      // Compte créé par un administrateur : actif d'emblée, essai de 7 jours
      const { error: userError } = await supabase.from('users').update({
        full_name: newOwner.value.full_name.trim(),
        email: newOwner.value.email.trim(),
        phone: newOwner.value.phone.trim() || null,
        role: 'owner',
        is_active: true,
        subscription_tier: 'demo',
        subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
      }).eq('id', ownerId)
      if (userError) throw userError
    }

    const { data: { user: admin } } = await supabase.auth.getUser()
    const { data: establishment, error: estError } = await supabase
      .from('establishments')
      .insert({
        name: form.value.name.trim(),
        address: form.value.address.trim() || null,
        phone: form.value.phone.trim() || null,
        email: form.value.email.trim() || null,
        type_id: form.value.type_id || null,
        establishment_type_id: form.value.type_id || null,
        user_id: ownerId,
        created_by: admin?.id,
        is_active: true
      })
      .select('id')
      .single()
    if (estError) throw estError

    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'create',
        entity_type: 'establishment',
        entity_id: establishment.id,
        details: { name: form.value.name, owner_id: ownerId }
      })
    }

    showToast.success(ownerType.value === 'new' ? 'Propriétaire et établissement créés' : 'Établissement créé')
    await navigateTo('/admin/establishments')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
