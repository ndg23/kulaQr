<template>
  <PageForm
    :title="category ? 'Modifier la catégorie' : 'Nouvelle catégorie'"
    :subtitle="category?.name"
    :back-to="`/manager/${slug}/categories`"
    back-label="Retour aux catégories"
    :submit-label="category ? 'Mettre à jour' : 'Créer la catégorie'"
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <PageImagePicker v-model:file="imageFile" v-model:url="imageUrl" label="Image de la catégorie" />

    <FloatLabelInput id="name" v-model="form.name" label="Nom de la catégorie" autocomplete="off" :error="errors.name" :show-char-count="false" pill required />
    <FloatLabelInput id="order" v-model="form.order_number" type="number" label="Ordre d'affichage" :show-char-count="false" pill />
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const props = defineProps<{
  slug: string
  category?: any
  /** Ordre proposé pour une nouvelle catégorie */
  nextOrder?: number
}>()

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const uploadImage = useImageUpload()

const loading = ref(false)
const error = ref('')
const errors = ref({ name: '' })
const imageFile = ref<File | null>(null)
const imageUrl = ref(props.category?.image_url || '')
const form = ref({
  name: props.category?.name || '',
  order_number: String(props.category?.order_number ?? props.nextOrder ?? 1)
})

const handleSubmit = async () => {
  errors.value = { name: '' }
  if (!form.value.name.trim()) {
    errors.value.name = 'Veuillez entrer un nom de catégorie'
    return
  }
  loading.value = true
  error.value = ''
  try {
    let finalUrl = imageUrl.value || null
    if (imageFile.value) finalUrl = await uploadImage(imageFile.value, 'categories')

    const payload = {
      name: form.value.name.trim(),
      order_number: Number(form.value.order_number) || 1,
      image_url: finalUrl
    }

    if (props.category?.id) {
      const { error: updateError } = await supabase.from('categories').update(payload).eq('id', props.category.id)
      if (updateError) throw updateError
    } else {
      const { error: insertError } = await supabase.from('categories').insert({ ...payload, establishment_id: props.slug })
      if (insertError) {
        // categories(establishment_id, name) est unique
        throw new Error(insertError.code === '23505' ? 'Une catégorie porte déjà ce nom' : insertError.message)
      }
    }
    showToast.success(props.category?.id ? 'Modifications enregistrées' : 'Nouvelle catégorie ajoutée')
    await navigateTo(`/manager/${props.slug}/categories`)
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue lors de la sauvegarde'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
