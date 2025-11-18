<template>
    <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
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
            <FloatLabelInput
              v-model="form.name"
              type="text"
              required
              label="Nom de l'établissement"
              placeholder=" "
            />
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
          <h2 class="text-lg font-semibold text-gray-900">Contact de l'établissement</h2>
        </div>
        <div class="p-6 space-y-6">
          <!-- Phone -->
          <div class="relative group">
            <FloatLabelInput
              v-model="form.phone"
              type="tel"
              required
              label="Téléphone"
            />
          </div>

          <!-- Address -->
          <div class="relative group">
            <FloatLabelInput
              v-model="form.address"
              placeholder=" "
              label="Adresse"
            />
          </div>
        </div>
      </div>

      <!-- Notifications Settings Card -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">Notifications</h2>
        </div>
        <div class="p-6 space-y-6">
          <!-- Sound Notifications -->
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-sm font-medium text-gray-900">Notifications sonores</h3>
              <p class="text-sm text-gray-500">Jouer un son lors de nouvelles commandes</p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input
                v-model="form.sound_notifications_enabled"
                type="checkbox"
                class="sr-only peer"
              />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
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
import { useSound } from '~/composables/useSound'
import FloatLabelInput from '~/components/FloatLabelInput.vue'
definePageMeta({
  layout: 'manager'
})

const route = useRoute()
const slug = route.params.slug as string
const { client: supabase, withLoading } = useSupabaseWrapper()
const {showToast} = useCustomToast()
const { setEnabled: setSoundEnabled } = useSound()

const fileInput = ref<HTMLInputElement>()
const imagePreview = ref<string>()
const loading = ref(false)

const form = reactive({
  name: '',
  description: '',
  image_url: '',
  phone: '',
  address: '',
  sound_notifications_enabled: true
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
  
  // Load sound preference from localStorage
  const soundEnabled = localStorage.getItem('sound-notifications-enabled')
  form.sound_notifications_enabled = soundEnabled !== null ? JSON.parse(soundEnabled) : true
}

const handleImageChange = async (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Validate file type
  if (!file.type.startsWith('image/')) {
    showToast.error('Erreur', 'Veuillez sélectionner un fichier image valide')
    return
  }

  // Validate file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    showToast.error('Erreur', 'L\'image ne doit pas dépasser 5MB')
    return
  }

  // Show preview immediately
  imagePreview.value = URL.createObjectURL(file)

  try {
    // Upload to Supabase Storage
    const fileExt = file.name.split('.').pop()
    const fileName = `establishment-logos/${slug}_${Date.now()}.${fileExt}`

    const { data, error } = await supabase.storage
      .from('images')
      .upload(fileName, file, {
        cacheControl: '3600',
        upsert: false
      })

    if (error) throw error

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('images')
      .getPublicUrl(fileName)

    // Update form with new image URL
    form.image_url = publicUrl

    showToast.success('Logo uploadé', 'Le logo a été mis à jour avec succès')
  } catch (error: any) {
    console.error('Error uploading image:', error)
    showToast.error('Erreur', 'Impossible d\'uploader l\'image')
    // Reset preview on error
    imagePreview.value = ''
  }
}

const saveSettings = async () => {
  try {
    loading.value = true
    const { error } = await supabase
      .from('establishments')
      .update({
        name: form.name,
        description: form.description,
        image_url: form.image_url,
        phone: form.phone,
        address: form.address
      })
      .eq('id', slug)

    if (error) throw error

    // Save sound preference to localStorage
    localStorage.setItem('sound-notifications-enabled', JSON.stringify(form.sound_notifications_enabled))
    
    // Update sound composable
    const { setEnabled } = useSound()
    setEnabled(form.sound_notifications_enabled)

    showToast.success('Succès', 'Les modifications ont été enregistrées')
  } catch (error) {
    showToast.error('Erreur', 'Impossible de sauvegarder les modifications')
    console.error(error)
  } finally {
    loading.value = false
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