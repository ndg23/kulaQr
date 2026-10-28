<template>
  <PageForm
    title="Modifier l'établissement"
    :subtitle="establishment?.name"
    back-to="/admin/establishments"
    back-label="Retour aux établissements"
    submit-label="Mettre à jour"
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !establishment"
    not-found-text="Établissement introuvable"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelInput id="name" v-model="form.name" label="Nom de l'établissement" autocomplete="off" :error="errors.name" :show-char-count="false" pill required />
    <FloatLabelInput id="description" v-model="form.description" label="Description" autocomplete="off" :show-char-count="false" pill />
    <FloatLabelInput id="address" v-model="form.address" label="Adresse" autocomplete="off" :show-char-count="false" pill />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelInput id="phone" v-model="form.phone" type="tel" label="Téléphone" autocomplete="off" :show-char-count="false" pill />
      <FloatLabelInput id="email" v-model="form.email" type="email" label="Email" autocomplete="off" :show-char-count="false" pill />
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelSelect id="type" v-model="form.type_id" label="Type d'établissement" pill>
        <option value="">Non précisé</option>
        <option v-for="t in establishmentTypes" :key="t.id" :value="t.id">{{ t.name }}</option>
      </FloatLabelSelect>
      <FloatLabelInput id="hours" v-model="form.opening_hours" label="Heures d'ouverture" autocomplete="off" :show-char-count="false" pill />
    </div>

    <div class="flex gap-2" role="radiogroup" aria-label="Statut de l'établissement">
      <button
        v-for="s in statusChoices"
        :key="String(s.value)"
        type="button"
        role="radio"
        :aria-checked="form.is_active === s.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          form.is_active === s.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="form.is_active = s.value"
      >{{ s.label }}</button>
    </div>

    <!-- Les autres actions ont chacune leur page -->
    <div class="flex flex-wrap gap-2 pt-1">
      <NuxtLink :to="`/admin/establishments/${route.params.id}/owner`" class="h-10 px-4 rounded-full bg-[#EFEAFF] text-[#4B2FCC] text-sm font-bold inline-flex items-center hover:opacity-80 transition-opacity">Propriétaire</NuxtLink>
      <NuxtLink :to="`/admin/establishments/${route.params.id}/staff`" class="h-10 px-4 rounded-full bg-[#E8EEFF] text-[#1741B8] text-sm font-bold inline-flex items-center hover:opacity-80 transition-opacity">Personnel</NuxtLink>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const statusChoices = [
  { value: true, label: 'Actif' },
  { value: false, label: 'Inactif' }
]

const establishment = ref<any>(null)
const establishmentTypes = ref<any[]>([])
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')
const errors = ref({ name: '' })
const form = ref({
  name: '',
  description: '',
  address: '',
  phone: '',
  email: '',
  type_id: '',
  opening_hours: '',
  is_active: true
})

onMounted(async () => {
  const [estRes, typesRes] = await Promise.all([
    supabase.from('establishments').select('*').eq('id', route.params.id as string).maybeSingle(),
    supabase.from('establishment_types').select('id, name').order('name')
  ])
  if (estRes.error) error.value = estRes.error.message
  establishment.value = estRes.data
  establishmentTypes.value = typesRes.data || []
  const d = estRes.data
  if (d) {
    form.value = {
      name: d.name || '',
      description: d.description || '',
      address: d.address || '',
      phone: d.phone || '',
      email: d.email || '',
      type_id: d.type_id || d.establishment_type_id || '',
      opening_hours: d.opening_hours || '',
      is_active: d.is_active !== false
    }
  }
  loadingData.value = false
})

const handleSubmit = async () => {
  errors.value = { name: '' }
  if (!form.value.name.trim()) {
    errors.value.name = "Le nom de l'établissement est requis"
    return
  }
  loading.value = true
  error.value = ''
  try {
    const f = form.value
    const updates = {
      name: f.name.trim(),
      description: f.description.trim() || null,
      address: f.address.trim() || null,
      phone: f.phone.trim() || null,
      email: f.email.trim() || null,
      type_id: f.type_id || null,
      establishment_type_id: f.type_id || null,
      opening_hours: f.opening_hours.trim() || null,
      is_active: f.is_active
    }
    const { error: updateError } = await supabase.from('establishments').update(updates).eq('id', establishment.value.id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'update',
        entity_type: 'establishment',
        entity_id: establishment.value.id,
        details: { updated_fields: Object.keys(updates) }
      })
    }
    showToast.success('Établissement mis à jour avec succès')
    await navigateTo('/admin/establishments')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
