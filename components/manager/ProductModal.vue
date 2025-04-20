<template>
  <div class="fixed inset-0 bg-black/30 backdrop-blur-sm flex items-center justify-center z-50">
    <div class="bg-white rounded-2xl w-full max-w-xl mx-4 overflow-hidden">
      <!-- Header -->
      <div class="px-6 py-4 border-b">
        <div class="flex justify-between items-center">
          <h2 class="text-xl font-semibold">
            {{ product ? 'Modifier le produit' : 'Nouveau produit' }}
          </h2>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">
            <Icon name="x" class="w-6 h-6" />
          </button>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
        <!-- Image Upload -->
        <div class="relative">
          <div 
            class="aspect-w-16 aspect-h-9 rounded-lg bg-gray-100 overflow-hidden group"
            :class="{ 'border-2 border-dashed border-gray-300': !imagePreview }"
          >
            <img
              v-if="imagePreview"
              :src="imagePreview"
              class="object-cover w-full h-full"
            />
            <div 
              v-else
              class="flex flex-col items-center justify-center text-gray-500"
            >
              <Icon name="image" class="w-8 h-8 mb-2" />
              <span class="text-sm">Ajouter une image</span>
            </div>
            <input
              type="file"
              accept="image/*"
              class="absolute inset-0 opacity-0 cursor-pointer"
              @change="handleImageChange"
            />
          </div>
        </div>

        <!-- Basic Info -->
        <div class="grid grid-cols-2 gap-4">
          <div class="col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Nom du produit
            </label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full px-3 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Catégorie
            </label>
            <select
              v-model="form.category_id"
              required
              class="w-full px-3 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Prix
            </label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">€</span>
              <input
                v-model="form.price"
                type="number"
                step="0.01"
                required
                class="w-full pl-8 pr-3 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Description
          </label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-3 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50"
          >
            Annuler
          </button>
          <button
            type="submit"
            class="px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700"
          >
            {{ product ? 'Enregistrer' : 'Ajouter' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Product, Category } from '~/types'

const props = defineProps<{
  product?: Product
  categories: Category[]
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'save', product: Partial<Product>): void
}>()

const supabase = useSupabaseClient()
const imagePreview = ref<string>('')
const form = ref({
  name: props.product?.name || '',
  description: props.product?.description || '',
  price: props.product?.price || 0,
  category_id: props.product?.category_id || '',
  image_url: props.product?.image_url || ''
})

// Image handling
const handleImageChange = async (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Preview
  imagePreview.value = URL.createObjectURL(file)

  // Upload to Supabase Storage
  const { data, error } = await supabase.storage
    .from('products')
    .upload(`${Date.now()}-${file.name}`, file)

  if (error) {
    console.error('Error uploading image:', error)
    return
  }

  const { data: { publicUrl } } = supabase.storage
    .from('products')
    .getPublicUrl(data.path)

  form.value.image_url = publicUrl
}

const handleSubmit = () => {
  emit('save', {
    ...form.value,
    price: Number(form.value.price)
  })
}

// Load image preview if editing
onMounted(() => {
  if (props.product?.image_url) {
    imagePreview.value = props.product.image_url
  }
})
</script> 