<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 border-b border-gray-100">
        <h1 class="text-xl font-semibold text-gray-900">Profil utilisateur</h1>
        <p class="mt-1 text-sm text-gray-500">
          Gérez vos informations personnelles et vos préférences
        </p>
      </div>

      <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
        <!-- Avatar -->
        <div class="flex items-center space-x-6">
          <div class="relative">
            <div class="h-24 w-24 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden">
              <img
                v-if="user?.user_metadata?.avatar_url"
                :src="user.user_metadata.avatar_url"
                alt="Avatar"
                class="h-full w-full object-cover"
              />
              <UserCircle v-else class="h-16 w-16 text-gray-300" />
            </div>
            <button
              type="button"
              @click="triggerFileInput"
              class="absolute bottom-0 right-0 bg-blue-500 text-white p-1.5 rounded-full shadow-sm hover:bg-blue-600 transition-colors"
            >
              <Camera class="h-4 w-4" />
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
            <h3 class="text-lg font-medium text-gray-900">
              {{ user?.user_metadata?.full_name || user?.email }}
            </h3>
            <p class="text-sm text-gray-500">{{ user?.email }}</p>
          </div>
        </div>

        <!-- Personal Information -->
        <div class="space-y-4">
          <h3 class="text-lg font-medium text-gray-900">Informations personnelles</h3>
          
          <FormInput
            v-model="form.fullName"
            label="Nom complet"
            :error="errors.fullName"
          />
          
          <FormInput
            v-model="form.email"
            type="email"
            label="Email"
            disabled
            :error="errors.email"
          />
          
          <FormInput
            v-model="form.phone"
            type="tel"
            label="Téléphone"
            :error="errors.phone"
          />
        </div>

        <!-- Security -->
        <div class="space-y-4">
          <h3 class="text-lg font-medium text-gray-900">Sécurité</h3>
          
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
            class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
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
import { ref, reactive, onMounted } from 'vue'
import { UserCircle, Camera, Loader2 } from 'lucide-vue-next'
import FormInput from '~/components/ui/FormInput.vue'
import { useCustomToast } from '~/composables/useToast'

const { showToast } = useCustomToast()
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

// Trigger file input click
const triggerFileInput = () => {
  if (fileInput.value) {
    fileInput.value.click()
  }
}

// Charger les données utilisateur
const loadUserData = async () => {
  if (!user.value?.id) return

  try {
    loading.value = true
    const { data, error } = await supabase
      .from('users')
      .select('full_name, phone')
      .eq('id', user.value.id)
      .single()

    if (error) throw error

    if (data) {
      form.fullName = data.full_name || user.value?.user_metadata?.full_name || ''
      form.phone = data.phone || ''
    }
  } catch (error) {
    console.error('Error loading user data:', error)
    showToast.error('Erreur', 'Impossible de charger vos informations')
  } finally {
    loading.value = false
  }
}

// Gérer le changement d'image
const handleImageChange = async (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Check file size (2MB max)
  if (file.size > 2 * 1024 * 1024) {
    showToast.error('Erreur', 'L\'image est trop volumineuse (max 2MB)')
    return
  }

  try {
    loading.value = true

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

    // Get public URL
    const { data } = supabase.storage
      .from('avatars')
      .getPublicUrl(filePath)

    // Mettre à jour l'URL de l'avatar
    const { error: updateError } = await supabase.auth.updateUser({
      data: { avatar_url: data.publicUrl }
    })

    if (updateError) {
      showToast.error('Erreur', 'Erreur lors de la mise à jour de l\'avatar')
      return
    }

    showToast.success('Succès', 'Avatar mis à jour avec succès')
  } catch (error) {
    console.error('Error updating avatar:', error)
    showToast.error('Erreur', 'Une erreur est survenue')
  } finally {
    loading.value = false
  }
}

// Validate form
const validateForm = () => {
  let isValid = true
  
  // Reset errors
  Object.keys(errors).forEach(key => errors[key as keyof typeof errors] = '')
  
  // Validate full name
  if (!form.fullName.trim()) {
    errors.fullName = 'Le nom complet est requis'
    isValid = false
  }
  
  // Validate new password
  if (form.newPassword && form.newPassword.length < 6) {
    errors.newPassword = 'Le mot de passe doit contenir au moins 6 caractères'
    isValid = false
  }
  
  // Validate current password if new password is provided
  if (form.newPassword && !form.currentPassword) {
    errors.currentPassword = 'Veuillez entrer votre mot de passe actuel'
    isValid = false
  }
  
  return isValid
}

// Soumettre le formulaire
const handleSubmit = async () => {
  if (!validateForm()) return
  
  loading.value = true
  
  try {
    // Mettre à jour les informations de base
    const { error: profileError } = await supabase
      .from('users')
      .upsert({
        id: user.value?.id,
        full_name: form.fullName,
        phone: form.phone,
        updated_at: new Date().toISOString()
      })

    if (profileError) throw profileError

    // Update user metadata
    const { error: metadataError } = await supabase.auth.updateUser({
      data: { full_name: form.fullName }
    })

    if (metadataError) throw metadataError

    // Mettre à jour le mot de passe si nécessaire
    if (form.newPassword && form.currentPassword) {
      const { error: passwordError } = await supabase.auth.updateUser({
        password: form.newPassword
      })

      if (passwordError) {
        showToast.error('Erreur', 'Impossible de mettre à jour le mot de passe')
        throw passwordError
      }
    }

    // Réinitialiser les champs de mot de passe
    form.currentPassword = ''
    form.newPassword = ''

    showToast.success('Succès', 'Profil mis à jour avec succès')
  } catch (error) {
    console.error('Erreur mise à jour profil:', error)
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
.bg-facebook-dark {
  background-color: #166FE5;
}
</style>