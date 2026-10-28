<template>
  <PageForm
    :title="product ? 'Modifier le produit' : 'Nouveau produit'"
    :subtitle="product?.name"
    :back-to="`/manager/${slug}/menu`"
    back-label="Retour au menu"
    :submit-label="product ? 'Mettre à jour' : 'Créer le produit'"
    :loading="loading"
    :loading-data="loadingCategories"
    :error="error"
    @submit="handleSubmit"
  >
    <div v-if="!categories.length" class="rounded-3xl bg-[#FFF9C2] p-4 flex gap-3">
      <AlertTriangle class="w-5 h-5 flex-shrink-0 mt-0.5 text-[#6B5B00]" />
      <div class="text-sm text-gray-700">
        Créez d'abord une catégorie pour pouvoir ajouter un produit.
        <NuxtLink :to="`/manager/${slug}/categories/new`" class="font-bold underline">Nouvelle catégorie</NuxtLink>
      </div>
    </div>

    <PageImagePicker v-model:file="imageFile" v-model:url="imageUrl" label="Photo du produit" />

    <FloatLabelInput id="name" v-model="form.name" label="Nom du produit" autocomplete="off" :error="errors.name" :show-char-count="false" pill required />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelInput id="price" v-model="form.price" type="number" label="Prix" :error="errors.price" :show-char-count="false" pill required />
      <FloatLabelSelect id="category" v-model="form.category_id" label="Catégorie" :error="errors.category" pill required>
        <option value="" disabled>Sélectionner</option>
        <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
      </FloatLabelSelect>
    </div>

    <div>
      <label for="description" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">Description</label>
      <textarea
        id="description"
        v-model="form.description"
        rows="3"
        placeholder="Ingrédients, taille, particularités..."
        class="w-full px-5 py-4 border border-gray-200 rounded-3xl focus:outline-none focus:border-gray-900 resize-none"
      />
    </div>

    <div class="flex gap-2" role="radiogroup" aria-label="Disponibilité">
      <button
        v-for="a in availabilityChoices"
        :key="String(a.value)"
        type="button"
        role="radio"
        :aria-checked="form.is_available === a.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          form.is_available === a.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="form.is_available = a.value"
      >{{ a.label }}</button>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { AlertTriangle } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const props = defineProps<{
  slug: string
  product?: any
}>()

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const uploadImage = useImageUpload()

const availabilityChoices = [
  { value: true, label: 'Disponible' },
  { value: false, label: 'Indisponible' }
]

const categories = ref<any[]>([])
const loadingCategories = ref(true)
const loading = ref(false)
const error = ref('')
const errors = ref({ name: '', price: '', category: '' })
const imageFile = ref<File | null>(null)
const imageUrl = ref(props.product?.image_url || '')
const form = ref({
  name: props.product?.name || '',
  description: props.product?.description || '',
  price: props.product?.price !== undefined ? String(props.product.price) : '',
  category_id: props.product?.category_id || '',
  is_available: props.product?.is_available !== false
})

onMounted(async () => {
  const { data } = await supabase
    .from('categories')
    .select('id, name')
    .eq('establishment_id', props.slug)
    .order('order_number')
  categories.value = data || []
  if (!form.value.category_id && categories.value.length) form.value.category_id = categories.value[0].id
  loadingCategories.value = false
})

const validate = () => {
  errors.value = { name: '', price: '', category: '' }
  if (!form.value.name.trim()) errors.value.name = 'Veuillez entrer un nom de produit'
  if (!(Number(form.value.price) > 0)) errors.value.price = 'Le prix doit être supérieur à 0'
  if (!form.value.category_id) errors.value.category = 'Veuillez sélectionner une catégorie'
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    // La catégorie doit appartenir à cet établissement
    if (!categories.value.some(c => c.id === form.value.category_id)) throw new Error('Catégorie invalide')

    let finalUrl = imageUrl.value || null
    if (imageFile.value) finalUrl = await uploadImage(imageFile.value, 'products')

    const payload = {
      name: form.value.name.trim(),
      description: form.value.description.trim() || null,
      price: Number(form.value.price),
      category_id: form.value.category_id,
      image_url: finalUrl,
      is_available: form.value.is_available,
      establishment_id: props.slug
    }

    if (props.product?.id) {
      const { error: updateError } = await supabase.from('products').update(payload).eq('id', props.product.id)
      if (updateError) throw updateError
    } else {
      const { error: insertError } = await supabase.from('products').insert(payload)
      if (insertError) {
        // products(category_id, name) est unique
        throw new Error(insertError.code === '23505' ? 'Un produit porte déjà ce nom dans cette catégorie' : insertError.message)
      }
    }
    showToast.success(props.product?.id ? 'Modifications enregistrées' : 'Nouveau produit ajouté')
    await navigateTo(`/manager/${props.slug}/menu`)
  } catch (err: any) {
    error.value = err?.message || 'Impossible de sauvegarder le produit'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
