<template>
  <TransitionRoot appear show as="template">
    <Dialog as="div" class="relative z-50" @close="$emit('close')">
      <TransitionChild
        as="template"
        enter="duration-300 ease-out"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="duration-200 ease-in"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-black/25" />
      </TransitionChild>

      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center">
          <TransitionChild
            as="template"
            enter="duration-300 ease-out"
            enter-from="opacity-0 scale-95"
            enter-to="opacity-100 scale-100"
            leave="duration-200 ease-in"
            leave-from="opacity-100 scale-100"
            leave-to="opacity-0 scale-95"
          >
            <DialogPanel class="w-full max-w-lg transform overflow-hidden rounded-2xl bg-white text-left align-middle shadow-xl transition-all">
              <div class="bg-white px-6 pb-6 pt-5">
                <div class="flex items-center justify-between border-b border-gray-100 pb-4 mb-4">
                  <DialogTitle as="h3" class="text-lg font-semibold text-gray-900">
                    {{ product ? 'Modifier le produit' : 'Ajouter un produit' }}
                  </DialogTitle>
                  <button
                    @click="$emit('close')"
                    class="rounded-full p-2 text-gray-400 hover:text-gray-500 hover:bg-gray-100"
                  >
                    <X class="w-5 h-5" />
                  </button>
                </div>

                <form @submit.prevent="handleSubmit" class="space-y-4">
                  <!-- Image Upload -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Image
                    </label>
                    <div class="flex items-center space-x-4">
                      <div class="relative h-24 w-24 rounded-xl bg-gray-100 overflow-hidden">
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
                          class="inline-flex items-center rounded-full border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50"
                        >
                          <Upload class="h-4 w-4 mr-2" />
                          Choisir une image
                        </button>
                      </div>
                    </div>
                  </div>

                  <!-- Name -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Nom
                    </label>
                    <input
                      v-model="form.name"
                      type="text"
                      required
                      class="block w-full rounded-xl border-gray-200 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                  </div>

                  <!-- Category -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Catégorie
                    </label>
                    <Listbox v-model="form.category_id">
                      <div class="relative">
                        <ListboxButton class="relative w-full rounded-xl border border-gray-200 bg-white py-2 pl-3 pr-10 text-left shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500">
                          <span class="block truncate">
                            {{ categories.find(c => c.id === form.category_id)?.name || 'Sélectionner' }}
                          </span>
                          <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
                            <ChevronDown class="h-4 w-4 text-gray-400" />
                          </span>
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
                                  'relative cursor-pointer select-none py-2 pl-3 pr-9'
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

                  <!-- Price -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Prix
                    </label>
                    <div class="relative rounded-xl shadow-sm">
                      <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                        <span class="text-gray-500 sm:text-sm">€</span>
                      </div>
                      <input
                        v-model="form.price"
                        type="number"
                        step="0.01"
                        required
                        class="block w-full rounded-xl border-gray-200 pl-7 focus:border-blue-500 focus:ring-blue-500"
                      />
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
                      class="block w-full rounded-xl border-gray-200 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                  </div>

                  <!-- Availability -->
                  <div class="flex items-center">
                    <Switch
                      v-model="form.is_available"
                      :class="[form.is_available ? 'bg-blue-500' : 'bg-gray-200']"
                      class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out"
                    >
                      <span
                        :class="[form.is_available ? 'translate-x-5' : 'translate-x-0']"
                        class="inline-block h-5 w-5 transform rounded-full bg-white shadow transition duration-200 ease-in-out"
                      />
                    </Switch>
                    <span class="ml-3 text-sm font-medium text-gray-700">Disponible</span>
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
            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  Listbox,
  ListboxButton,
  ListboxOptions,
  ListboxOption,
  Switch,
  TransitionRoot,
  TransitionChild
} from '@headlessui/vue'
import {
  X,
  ImageIcon,
  Upload,
  ChevronDown,
  Check,
  Loader2
} from 'lucide-vue-next'
import type { Product, Category } from '~/types'

const props = defineProps<{
  product?: Product | null
  categories: Category[]
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'save', data: Partial<Product>): void
}>()

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