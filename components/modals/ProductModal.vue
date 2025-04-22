<template>
  <div>
    <div class="bg-white px-6 pb-6 pt-5">
      <div class="flex items-center justify-between border-b border-gray-100 pb-4 mb-4">
        <h3 class="text-lg font-semibold text-gray-900">
          {{ product ? 'Modifier le produit' : 'Ajouter un produit' }}
        </h3>
        <button
          @click="$emit('close')"
          class="rounded-full p-2 text-gray-400 hover:text-gray-500 hover:bg-gray-100"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Name -->
        <div class="relative group">
          <input
            v-model="form.name"
            type="text"
            required
            class="peer w-full h-16 px-5 pt-4 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
            placeholder=" "
          />
          <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
            Nom du produit
          </label>
        </div>

        <!-- Price -->
        <div class="relative group">
          <input
            v-model="form.price"
            type="number"
            step="0.01"
            required
            class="peer w-full h-16 px-5 pt-4 pl-10 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
            placeholder=" "
          />
          <span class="absolute left-5 top-1/2 -translate-y-1/2 text-gray-400">€</span>
          <label class="absolute left-10 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
            Prix
          </label>
        </div>

        <!-- Description -->
        <div class="relative group">
          <textarea
            v-model="form.description"
            rows="3"
            class="peer w-full px-5 pt-6 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
            placeholder=" "
          />
          <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
            Description
          </label>
        </div>

        <!-- Category -->
        <div class="relative group">
          <Listbox v-model="form.category_id">
            <div class="relative">
              <ListboxButton class="relative w-full h-16 px-5 pt-4 text-left rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors">
                <span class="block truncate mt-2">
                  {{ categories.find(c => c.id === form.category_id)?.name || 'Sélectionner' }}
                </span>
                <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                  <ChevronDown class="h-4 w-4 text-gray-400" />
                </span>
                <label class="absolute left-5 top-2 text-sm text-gray-400">
                  Catégorie
                </label>
              </ListboxButton>
              <Transition
                leave-active-class="transition ease-in duration-100"
                leave-from-class="opacity-100"
                leave-to-class="opacity-0"
              >
                <ListboxOptions class="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-xl bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                  <ListboxOption
                    v-for="category in categories"
                    :key="category.id"
                    :value="category.id"
                    v-slot="{ active, selected }"
                  >
                    <li
                      :class="[
                        active ? 'bg-blue-500 text-white' : 'text-gray-900',
                        'relative cursor-pointer select-none py-3 px-5'
                      ]"
                    >
                      <span :class="[selected ? 'font-semibold' : 'font-normal', 'block truncate']">
                        {{ category.name }}
                      </span>
                      <span
                        v-if="selected"
                        :class="[
                          active ? 'text-white' : 'text-blue-500',
                          'absolute inset-y-0 right-0 flex items-center pr-4'
                        ]"
                      >
                        <Check class="h-4 w-4" />
                      </span>
                    </li>
                  </ListboxOption>
                </ListboxOptions>
              </Transition>
            </div>
          </Listbox>
        </div>

        <!-- Image Upload -->
        <div class="relative">
          <label class="block text-sm font-medium text-gray-400 mb-2">
            Image
          </label>
          <div class="flex items-center space-x-4">
            <div class="relative h-24 w-24 rounded-xl bg-gray-50 border-2 border-gray-100 overflow-hidden">
              <img
                v-if="imagePreview || form.image_url"
                :src="imagePreview || form.image_url"
                class="h-full w-full object-cover"
              />
              <div
                v-else
                class="flex h-full items-center justify-center"
              >
                <ImageIcon class="h-8 w-8 text-gray-300" />
              </div>
            </div>
            <div>
              <input
                ref="fileInput"
                type="file"
                accept="image/*"
                class="hidden"
                @change="handleImageChange"
              />
              <button
                type="button"
                @click="fileInput?.click()"
                class="inline-flex items-center rounded-full border-2 border-gray-100 bg-gray-50 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 transition-colors"
              >
                <Upload class="h-4 w-4 mr-2" />
                Choisir une image
              </button>
            </div>
          </div>
        </div>

        <!-- Availability -->
        <div class="flex items-center justify-between p-4 rounded-xl bg-gray-50 border-2 border-gray-100">
          <span class="text-sm font-medium text-gray-700">Disponible</span>
          <Switch
            v-model="form.is_available"
            :class="[form.is_available ? 'bg-blue-500' : 'bg-gray-200']"
            class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
          >
            <span class="sr-only">Disponibilité</span>
            <span
              :class="[form.is_available ? 'translate-x-5' : 'translate-x-0']"
              class="inline-block h-5 w-5 transform rounded-full bg-white shadow transition duration-200 ease-in-out"
            />
          </Switch>
        </div>
      </form>
    </div>

    <div class="bg-gray-50 px-6 py-4 flex justify-end space-x-3">
      <button
        type="button"
        @click="$emit('close')"
        class="rounded-full px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100"
      >
        Annuler
      </button>
      <button
        type="submit"
        @click="handleSubmit"
        class="rounded-full bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
        :disabled="loading"
      >
        <span v-if="loading" class="flex items-center">
          <Loader2 class="h-4 w-4 animate-spin mr-2" />
          Enregistrement...
        </span>
        <span v-else>
          {{ product ? 'Modifier' : 'Ajouter' }}
        </span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Listbox, ListboxButton, ListboxOptions, ListboxOption, Switch } from '@headlessui/vue'
import {
  X,
  ImageIcon,
  Upload,
  ChevronDown,
  Check,
  Loader2
} from 'lucide-vue-next'
import type { Product, Category } from '~/types'

const props = defineProps({
  product: {
    type: Object,
    default: null
  },
  categories: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['close', 'save'])

const fileInput = ref<HTMLInputElement>()
const imagePreview = ref<string>()
const loading = ref(false)

const form = reactive({
  name: props.product?.name || '',
  category_id: props.product?.category_id || '',
  price: props.product?.price || 0,
  description: props.product?.description || '',
  image_url: props.product?.image_url || '',
  is_available: props.product?.is_available ?? true
})

const handleImageChange = (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (file) {
    imagePreview.value = URL.createObjectURL(file)
    // Ici vous pouvez ajouter la logique pour uploader l'image
  }
}

const handleSubmit = async () => {
  loading.value = true
  try {
    emit('save', form)
  } finally {
    loading.value = false
  }
}
</script>
<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}
.peer:placeholder-shown ~ label {
  cursor: text;
  top: 50%;
  transform: translateY(-50%);
}

.peer:focus ~ label {
  top: 0.5rem;
  transform: translateY(0);
  font-size: 0.875rem;
}

.peer:-webkit-autofill {
  -webkit-background-clip: text;
}

/* Animation du loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>
