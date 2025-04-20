<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 w-full max-w-md">
      <h2 class="text-xl font-bold mb-4">
        {{ category ? 'Modifier la catégorie' : 'Nouvelle catégorie' }}
      </h2>
      
      <form @submit.prevent="handleSubmit">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700">Nom</label>
          <input 
            v-model="form.name"
            type="text"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
            required
          />
        </div>

        <div class="flex justify-end space-x-3">
          <button 
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border rounded-md"
          >
            Annuler
          </button>
          <button 
            type="submit"
            class="px-4 py-2 bg-blue-500 text-white rounded-md"
          >
            Enregistrer
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Category } from '~/types'

const props = defineProps<{
  category?: Category
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'save', data: { name: string }): void
}>()

const form = ref({
  name: props.category?.name || ''
})

const handleSubmit = () => {
  emit('save', { name: form.value.name })
}
</script> 