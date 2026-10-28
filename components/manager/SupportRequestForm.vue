<template>
  <PageForm
    :title="request ? 'Modifier la demande' : 'Nouvelle demande'"
    subtitle="Support QR codes"
    :back-to="`/manager/${slug}/qr-support`"
    back-label="Retour aux demandes"
    :submit-label="request ? 'Modifier' : 'Envoyer la demande'"
    loading-label="Envoi..."
    :loading="submitting"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelSelect id="request-type" v-model="form.request_type" label="Type de demande" :error="errors.request_type" pill required>
      <option value="" disabled>Sélectionnez un type</option>
      <option v-for="t in requestTypes" :key="t.value" :value="t.value">{{ t.label }}</option>
    </FloatLabelSelect>

    <FloatLabelInput id="request-title" v-model="form.title" label="Titre" autocomplete="off" :error="errors.title" :show-char-count="false" pill required />

    <FloatLabelInput id="request-table" v-model="form.table_number" type="number" label="Numéro de table (optionnel)" :show-char-count="false" pill />

    <!-- Priorité : une pilule par niveau -->
    <fieldset>
      <legend class="text-sm font-extrabold text-gray-900 px-1 mb-2">Priorité</legend>
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-2" role="radiogroup">
        <button
          v-for="p in priorities"
          :key="p.value"
          type="button"
          role="radio"
          :aria-checked="form.priority === p.value"
          :class="[
            'h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
            form.priority === p.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
          ]"
          @click="form.priority = p.value"
        >{{ p.label }}</button>
      </div>
    </fieldset>

    <div>
      <label for="request-description" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">Description</label>
      <textarea
        id="request-description"
        v-model="form.description"
        rows="4"
        required
        placeholder="Décrivez votre demande en détail..."
        class="w-full px-5 py-4 border border-gray-200 rounded-3xl focus:outline-none focus:border-gray-900 resize-none"
      />
      <p v-if="errors.description" class="text-sm font-semibold text-red-600 px-1 mt-1">{{ errors.description }}</p>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useQrSupport } from '~/composables/useQrSupport'
import { useCustomToast } from '~/composables/useToast'

const props = defineProps<{
  slug: string
  request?: any
}>()

const { client: supabase } = useSupabaseWrapper()
const { createRequest, updateRequest } = useQrSupport()
const { showToast } = useCustomToast()

const requestTypes = [
  { value: 'new_qr', label: 'Nouveau QR code' },
  { value: 'qr_replacement', label: 'Remplacement de QR code' },
  { value: 'qr_update', label: 'Mise à jour de QR code' },
  { value: 'qr_deactivation', label: 'Désactivation de QR code' },
  { value: 'bulk_qr_generation', label: 'Génération de QR codes en masse' },
  { value: 'qr_customization', label: 'Personnalisation de QR code' },
  { value: 'technical_issue', label: 'Problème technique' }
]

const priorities = [
  { value: 'low', label: 'Faible' },
  { value: 'medium', label: 'Moyen' },
  { value: 'high', label: 'Élevé' },
  { value: 'urgent', label: 'Urgent' }
]

const submitting = ref(false)
const error = ref('')
const errors = ref({ request_type: '', title: '', description: '' })
const form = ref({
  request_type: props.request?.request_type || '',
  title: props.request?.title || '',
  table_number: props.request?.table_number ? String(props.request.table_number) : '',
  priority: props.request?.priority || 'medium',
  description: props.request?.description || ''
})

const validate = () => {
  errors.value = { request_type: '', title: '', description: '' }
  if (!form.value.request_type) errors.value.request_type = 'Sélectionnez un type de demande'
  if (!form.value.title.trim()) errors.value.title = 'Le titre est requis'
  if (!form.value.description.trim()) errors.value.description = 'La description est requise'
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  submitting.value = true
  error.value = ''
  try {
    const payload = {
      request_type: form.value.request_type,
      title: form.value.title.trim(),
      table_number: form.value.table_number ? Number(form.value.table_number) : null,
      priority: form.value.priority,
      description: form.value.description.trim()
    }

    if (props.request?.id) {
      await updateRequest(props.request.id, payload)
    } else {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Utilisateur non connecté')
      await createRequest({ establishment_id: props.slug, requested_by: user.id, ...payload })
    }
    await navigateTo(`/manager/${props.slug}/qr-support`)
  } catch (err: any) {
    error.value = err?.message || "Impossible d'envoyer la demande"
    showToast.error(error.value)
  } finally {
    submitting.value = false
  }
}
</script>
