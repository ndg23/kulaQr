<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">
        Paramètres du profil
      </h1>
      <p class="mt-1 text-sm text-gray-500">
        Gérez vos informations personnelles et vos préférences
      </p>
    </div>

    <!-- Main Content -->
    <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Photo de profil -->
        <div class="flex items-start space-x-4">
          <div class="relative">
            <div class="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden">
              <img 
                v-if="imagePreview || user?.avatar_url" 
                :src="imagePreview || user?.avatar_url" 
                alt="Avatar"
                class="w-full h-full object-cover"
              />
              <UserCircle v-else class="w-12 h-12 text-gray-400" />
            </div>
            <button
              type="button"
              class="absolute -bottom-1 -right-1 p-1.5 rounded-full bg-facebook text-white hover:bg-facebook-dark transition-colors"
              @click="$refs.fileInput.click()"
            >
              <Camera class="w-4 h-4" />
            </button>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="handleImageChange"
            />
          </div>
          <div>
            <h3 class="text-sm font-medium text-gray-900">Photo de profil</h3>
            <p class="mt-1 text-xs text-gray-500">
              JPG, PNG ou GIF. 1MB maximum.
            </p>
          </div>
        </div>

        <!-- Informations personnelles -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormInput
            v-model="form.fullName"
            label="Nom complet"
            :error="errors.fullName"
            required
          />

          <FormInput
            v-model="form.email"
            type="email"
            label="Email"
            :error="errors.email"
            disabled
          />

          <FormInput
            v-model="form.phone"
            type="tel"
            label="Téléphone"
            :error="errors.phone"
          />
        </div>

        <!-- Mot de passe -->
        <div class="pt-6 border-t border-gray-100">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            Changer le mot de passe
          </h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormInput
              v-model="form.currentPassword"
              type="password"
              label="Mot de passe actuel"
              :error="errors.currentPassword"
            />

            <FormInput
              v-model="form.newPassword"
              type="password"
              label="Nouveau mot de passe"
              :error="errors.newPassword"
            />
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-end space-x-3 pt-6">
          <button
            type="button"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
            @click="resetForm"
          >
            Annuler
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-facebook text-white rounded-lg hover:bg-facebook-dark transition-colors disabled:opacity-50"
            :disabled="loading"
          >
            <span v-if="loading" class="flex items-center">
              <Loader2 class="w-4 h-4 animate-spin mr-2" />
              Enregistrement...
            </span>
            <span v-else>
              Enregistrer les modifications
            </span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { UserCircle, Camera, Loader2 } from 'lucide-vue-next'
import FormInput from '~/components/ui/FormInput.vue'
import { useCustomToast } from '~/composables/useToast'

const {showToast} = useCustomToast()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const loading = ref(false)
const imagePreview = ref('')
const fileInput = ref<HTMLInputElement>()

const form = reactive({
  fullName: user.value?.user_metadata?.full_name || '',
  email: user.value?.email || '',
  phone: '',
  currentPassword: '',
  newPassword: ''
})

const errors = reactive({
  fullName: '',
  email: '',
  phone: '',
  currentPassword: '',
  newPassword: ''
})

// Charger les données utilisateur
const loadUserData = async () => {
  if (!user.value?.id) return

  const { data, error } = await supabase
    .from('users')
    .select('full_name, phone')
    .eq('id', "38afccef-7a30-4b44-8e50-da10d26d6f00")
    .single()

  if (data) {
    form.fullName = data.full_name
    form.phone = data.phone
  }
}

// Gérer le changement d'image
const handleImageChange = async (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Prévisualisation
  imagePreview.value = URL.createObjectURL(file)

  // Upload
  const fileExt = file.name.split('.').pop()
  const fileName = `${Math.random()}.${fileExt}`
  const filePath = `avatars/${fileName}`

  const { error: uploadError } = await supabase.storage
    .from('avatars')
    .upload(filePath, file)

  if (uploadError) {
    showToast.error('Erreur', 'Erreur lors du téléchargement de l\'image')
    return
  }

  // Mettre à jour l'URL de l'avatar
  const { error: updateError } = await supabase.auth.updateUser({
    data: { avatar_url: filePath }
  })

  if (updateError) {
    showToast.error('Erreur', 'Erreur lors de la mise à jour de l\'avatar')
  }
}

// Soumettre le formulaire
const handleSubmit = async () => {
  loading.value = true
  errors.fullName = ''
  errors.newPassword = ''

  try {
    // Mettre à jour les informations de base
    const { error: userError } = await supabase
      .from('users')
      .update({
        full_name: form.fullName,
        phone: form.phone
      })
      .eq('id', user.value?.id)

    if (userError) throw userError

    // Mettre à jour le mot de passe si nécessaire
    if (form.newPassword && form.currentPassword) {
      const { error: passwordError } = await supabase.auth.updateUser({
        password: form.newPassword
      })

      if (passwordError) throw passwordError
    }

    // Réinitialiser les champs de mot de passe
    form.currentPassword = ''
    form.newPassword = ''

    showToast.success('Succès', 'Profil mis à jour avec succès')
  } catch (error) {
    console.error('Erreur mise à jour profil:', error)
    errors.fullName = 'Une erreur est survenue'
    showToast.error('Erreur', 'Une erreur est survenue')
  } finally {
    loading.value = false
  }
}

// Réinitialiser le formulaire
const resetForm = () => {
  loadUserData()
  form.currentPassword = ''
  form.newPassword = ''
  Object.keys(errors).forEach(key => errors[key as keyof typeof errors] = '')
}

// Charger les données au montage
onMounted(() => {
  loadUserData()
})
definePageMeta({
  layout: 'manager'
})
</script> 


<style scoped>
.bg-facebook {
  background-color: #1877F2;
}



</style>