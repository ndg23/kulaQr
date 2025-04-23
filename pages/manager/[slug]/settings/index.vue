<template>
  <div class="max-w-3xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">Paramètres</h1>
      <p class="mt-1 text-sm text-gray-500">Gérez les informations de votre établissement</p>
    </div>

    <form @submit.prevent="saveSettings" class="space-y-6">
      <!-- Basic Info Card -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Informations générales</h2>
        </div>
        <div class="p-6 space-y-6">
          <!-- Restaurant Name -->
          <div class="relative group">
            <input
              v-model="form.name"
              type="text"
              required
              class="peer w-full h-16 px-5 pt-4 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
              placeholder=" "
            />
            <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
              Nom de l'établissement
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

          <!-- Logo Upload -->
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">Logo</label>
            <div class="flex items-center space-x-4">
              <div class="relative h-24 w-24 rounded-xl bg-gray-50 border-2 border-gray-100 overflow-hidden">
                <img
                  v-if="imagePreview || form.image_url"
                  :src="imagePreview || form.image_url"
                  class="h-full w-full object-cover"
                />
                <div v-else class="flex h-full items-center justify-center">
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
        </div>
      </div>

      <!-- Contact Info Card -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Contact</h2>
        </div>
        <div class="p-6 space-y-6">
          <!-- Phone -->
          <div class="relative group">
            <input
              v-model="form.phone"
              type="tel"
              class="peer w-full h-16 px-5 pt-4 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
              placeholder=" "
            />
            <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
              Téléphone
            </label>
          </div>

          <!-- Address -->
          <div class="relative group">
            <textarea
              v-model="form.address"
              rows="2"
              class="peer w-full px-5 pt-6 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
              placeholder=" "
            />
            <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
              Adresse
            </label>
          </div>
        </div>
      </div>

      <!-- Opening Hours Card -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Horaires d'ouverture</h2>
        </div>
        <div class="p-6">
          <div class="relative group">
            <textarea
              v-model="form.opening_hours"
              rows="4"
              class="peer w-full px-5 pt-6 rounded-xl bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors"
              placeholder=" "
            />
            <label class="absolute left-5 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-base peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-2 peer-focus:text-blue-500">
              Horaires d'ouverture
            </label>
          </div>
        </div>
      </div>

      <!-- Submit Button -->
      <div class="flex justify-end">
        <button
          type="submit"
          class="inline-flex items-center px-6 py-3 rounded-full bg-blue-500 text-white font-medium hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          :disabled="loading"
        >
          <span v-if="loading" class="flex items-center">
            <Loader2 class="h-4 w-4 animate-spin mr-2" />
            Enregistrement...
          </span>
          <span v-else>Enregistrer les modifications</span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ImageIcon, Upload, Loader2 } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({
  layout: 'manager'
})

const route = useRoute()
const slug = route.params.slug as string
const { client: supabase, withLoading } = useSupabaseWrapper()
const {showToast} = useCustomToast()

const fileInput = ref<HTMLInputElement>()
const imagePreview = ref<string>()
const loading = ref(false)

const form = reactive({
  name: '',
  description: '',
  image_url: '',
  phone: '',
  address: '',
  opening_hours: ''
})

// Load establishment data
const loadEstablishment = async () => {
  const { data, error } = await supabase
    .from('establishments')
    .select()
    .eq('id', slug)
    .single()

  if (error) {
    showToast.error('Erreur', 'Impossible de charger les données')
    return
  }

  // Update form with establishment data
  Object.assign(form, data)
}

const handleImageChange = (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (file) {
    imagePreview.value = URL.createObjectURL(file)
    // TODO: Upload image to storage
  }
}

const saveSettings = async () => {
  const result = await withLoading(async () => {
    const { error } = await supabase
      .from('establishments')
      .update(form)
      .eq('id', slug)

    if (error) throw error

    showToast.success('Succès', 'Les modifications ont été enregistrées')
  })

  if (!result) {
    showToast.error('Erreur', 'Impossible de sauvegarder les modifications')
  }
}

onMounted(loadEstablishment)
</script>

<style scoped>
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
</style> 