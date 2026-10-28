<template>
  <PageForm
    :title="table ? 'Modifier l\'emplacement' : 'Nouvel emplacement'"
    :subtitle="table ? `Table ${table.table_number}` : 'Un QR code sera généré automatiquement'"
    :back-to="`/manager/${slug}/tables`"
    back-label="Retour aux emplacements"
    :submit-label="table ? 'Mettre à jour' : 'Ajouter l\'emplacement'"
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelInput id="table-number" v-model="form.number" type="number" label="Numéro de l'emplacement" :error="errors.number" :show-char-count="false" pill required />
      <FloatLabelSelect id="table-type" v-model="form.type" label="Type" pill required>
        <option value="SIMPLE">Simple</option>
        <option value="STANDARD">Standard</option>
        <option value="VIP">VIP</option>
      </FloatLabelSelect>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelSelect id="table-section" v-model="form.section_name" label="Section" pill required>
        <option v-for="s in sections" :key="s" :value="s">{{ s }}</option>
      </FloatLabelSelect>
      <FloatLabelSelect id="table-floor" v-model="form.floor_level" label="Étage" pill>
        <option value="">Non précisé</option>
        <option v-for="f in floors" :key="f" :value="f">{{ f }}</option>
      </FloatLabelSelect>
    </div>

    <FloatLabelInput id="table-capacity" v-model="form.capacity" type="number" label="Capacité (places)" :show-char-count="false" pill />

    <div>
      <label for="table-location" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">Localisation détaillée</label>
      <textarea
        id="table-location"
        v-model="form.location_description"
        rows="3"
        placeholder="Ex : près de la fenêtre, à côté du bar, vue sur le jardin..."
        class="w-full px-5 py-4 border border-gray-200 rounded-3xl focus:outline-none focus:border-gray-900 resize-none"
      />
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { encodeTableHashids } from '~/utils/secure-encoding'

const props = defineProps<{
  slug: string
  table?: any
}>()

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const sections = ['Salle principale', 'Terrasse', 'Bar', 'Salle privée', 'Extérieur', 'Entrée']
const floors = ['Rez-de-chaussée', '1er étage', '2ème étage', 'Sous-sol']

const loading = ref(false)
const error = ref('')
const errors = ref({ number: '' })
const form = ref({
  number: String(props.table?.table_number ?? ''),
  type: props.table?.type || 'STANDARD',
  section_name: props.table?.section_name || sections[0],
  floor_level: props.table?.floor_level || '',
  capacity: props.table?.capacity ? String(props.table.capacity) : '',
  location_description: props.table?.location_description || ''
})

const handleSubmit = async () => {
  errors.value = { number: '' }
  const number = parseInt(form.value.number, 10)
  if (!(number > 0)) {
    errors.value.number = "Le numéro de l'emplacement doit être supérieur à 0"
    return
  }
  loading.value = true
  error.value = ''
  try {
    const payload = {
      table_number: String(number),
      type: form.value.type,
      section_name: form.value.section_name,
      floor_level: form.value.floor_level || null,
      capacity: form.value.capacity ? Number(form.value.capacity) : null,
      location_description: form.value.location_description.trim() || null
    }

    if (props.table?.id) {
      const { error: updateError } = await supabase.from('tables').update(payload).eq('id', props.table.id)
      if (updateError) throw updateError
      showToast.success('Emplacement modifié avec succès')
    } else {
      // QR code généré dès la création : le numéro est encodé pour ne pas apparaître en clair dans l'URL
      const qrUrl = `${window.location.origin}/qr/${props.slug}?q=${encodeTableHashids(number, props.slug)}`
      const { error: insertError } = await supabase.from('tables').insert({
        ...payload,
        establishment_id: props.slug,
        qr_code_url: qrUrl,
        qr_code_generated: true
      })
      if (insertError) {
        // tables(establishment_id, table_number) est unique
        throw new Error(insertError.code === '23505' ? 'Ce numéro est déjà utilisé' : insertError.message)
      }
      showToast.success('Emplacement créé avec succès')
    }
    await navigateTo(`/manager/${props.slug}/tables`)
  } catch (err: any) {
    error.value = err?.message || "Impossible de sauvegarder l'emplacement"
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
