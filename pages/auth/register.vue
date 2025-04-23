<template>
  <div class="min-h-screen bg-white">
    <!-- Header avec logo -->
    <div class="fixed top-0 left-0 right-0 h-16 bg-white border-b border-gray-100 flex items-center px-6">
      <img src="~/assets/icon/logo.png" alt="Logo" class="h-8" />
    </div>

    <!-- Main Content -->
    <div class="max-w-md mx-auto px-6 pt-32 pb-16">
      <!-- Titre et sous-titre -->
      <div class="text-center mb-10">
        <h1 class="text-4xl font-bold text-gray-900 mb-3">
          Créez votre compte
        </h1>
        <p class="text-lg text-gray-600">
          Commencez à digitaliser votre menu en quelques minutes
        </p>
      </div>

      <!-- Formulaire -->
      <div class="space-y-6">
        <!-- Google Sign Up -->
        <button 
          @click="signInWithGoogle"
          class="w-full bg-white h-14 border border-gray-300 rounded-xl font-medium flex items-center justify-center hover:bg-gray-50 transition-all group"
        >
          <svg class="w-5 h-5 mr-3 transition-transform group-hover:scale-110" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Continuer avec Google
        </button>

        <div class="flex items-center">
          <div class="flex-grow h-px bg-gray-200"></div>
          <span class="px-4 text-sm text-gray-500 font-medium">ou</span>
          <div class="flex-grow h-px bg-gray-200"></div>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- Error Message -->
          <FormError :message="error" />

          <FormInput
            v-model="form.email"
            type="email"
            label="Email professionnel"
            :error="errors.email"
            required
          />

          <FormInput
            v-model="form.fullName"
            type="text"
            label="Nom complet"
            :error="errors.fullName"
            required
          />

          <FormInput
            v-model="form.password"
            :type="showPassword ? 'text' : 'password'"
            label="Mot de passe"
            :error="errors.password"
            required
          >
            <template #append>
              <button 
                type="button"
                @click="showPassword = !showPassword"
                class="text-gray-400 hover:text-gray-600"
              >
                <Eye v-if="showPassword" class="w-5 h-5" />
                <EyeOff v-else class="w-5 h-5" />
              </button>
            </template>
          </FormInput>

          <FormInput
            v-model="form.restaurantName"
            label="Nom de l'établissement"
            :error="errors.restaurantName"
            required
          />

          <!-- Restaurant Type Selection -->
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">Type d'établissement</label>
            <div class="relative">
              <Listbox v-model="form.type">
                <div class="relative">
                  <ListboxButton 
                    class="relative w-full h-14 px-4 text-left bg-white border border-gray-300 rounded-xl cursor-pointer focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook"
                    :class="{ 'border-red-300': errors.type }"
                  >
                    <span v-if="selectedType" class="flex items-center">
                      <component :is="selectedType.icon" class="w-5 h-5 mr-2 text-gray-500" />
                      <span class="block truncate">{{ selectedType.name }}</span>
                    </span>
                    <span v-else class="text-gray-500">Sélectionnez un type</span>
                    <span class="absolute inset-y-0 right-0 flex items-center pr-4">
                      <ChevronDown class="w-5 h-5 text-gray-400" aria-hidden="true" />
                    </span>
                  </ListboxButton>

                  <transition
                    leave-active-class="transition duration-100 ease-in"
                    leave-from-class="opacity-100"
                    leave-to-class="opacity-0"
                  >
                    <ListboxOptions class="absolute z-10 w-full py-1 mt-1 overflow-auto text-base bg-white rounded-xl shadow-lg max-h-60 ring-1 ring-black ring-opacity-5 focus:outline-none">
                      <ListboxOption
                        v-for="type in establishmentTypes"
                        :key="type.id"
                        v-slot="{ active, selected }"
                        :value="type.id"
                        as="template"
                      >
                        <li :class="[
                          active ? 'text-facebook bg-facebook/5' : 'text-gray-900',
                          'relative cursor-pointer select-none py-3 px-4'
                        ]">
                          <div class="flex items-center">
                            <component :is="type.icon" class="w-5 h-5 mr-2" :class="selected ? 'text-facebook' : 'text-gray-400'" />
                            <span :class="[
                              selected ? 'font-semibold' : 'font-normal',
                              'block truncate'
                            ]">
                              {{ type.name }}
                            </span>
                          </div>

                          <span v-if="selected" class="absolute inset-y-0 right-0 flex items-center pr-4 text-facebook">
                            <Check class="w-5 h-5" aria-hidden="true" />
                          </span>
                        </li>
                      </ListboxOption>
                    </ListboxOptions>
                  </transition>
                </div>
              </Listbox>
            </div>
            <p v-if="errors.type" class="text-sm text-red-600 mt-1">{{ errors.type }}</p>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            class="w-full h-14 bg-facebook text-white rounded-xl font-medium hover:bg-facebook-dark transition-all disabled:opacity-50 disabled:cursor-not-allowed relative mt-6"
            :disabled="loading"
          >
            <span v-if="loading" class="absolute inset-0 flex items-center justify-center">
              <Loader2 class="w-5 h-5 animate-spin" />
            </span>
            <span :class="{ invisible: loading }">
              Créer mon compte
            </span>
          </button>
        </form>

        <!-- Sign in link -->
        <p class="pt-6 text-center text-gray-600">
          Déjà inscrit ?{' '}
          <NuxtLink 
            to="/auth/login" 
            class="text-facebook hover:text-facebook/80 font-semibold transition-colors"
          >
            Se connecter
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { Eye, EyeOff, Loader2, Check, ChevronDown } from 'lucide-vue-next'
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from '@headlessui/vue'

import FormInput from '~/components/ui/FormInput.vue'

const restaurantName = ref('')
// const selectedType = ref(null)
const email = ref('')
const password = ref('')
const acceptTerms = ref(false)
// const loading = ref(false)
const showPassword = ref(false)
const loading = ref(false)
const error = ref('')
const form = reactive({
  email: '',
  fullName: '',
  password: '',
  restaurantName: '',
  type: null as number | null,
  address: '',
  phone: ''
})

const errors = reactive({
  email: '',
  fullName: '',
  password: '',
  restaurantName: '',
  type: '',
  address: '',
  phone: ''
})

const supabase = useSupabaseClient()

const { data: establishmentTypes } = await supabase
  .from('establishment_types')
  .select('*')
  .eq('is_active', true)
  .order('name')

const selectedType = computed(() => 
  establishmentTypes.find(type => type.id === form.type)
)

const handleRegister = async () => {
  if (!form.type) {
    errors.type = 'Veuillez sélectionner un type de restaurant'
    return
  }
  
  loading.value = true
  error.value = ''
  try {
    // 1. Créer le compte auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          role: 'owner'
        },
        emailRedirectTo: `${window.location.origin}/auth/callback`
      }
    })
    
    if (authError) {
      errors.email = authError.message === 'User already registered'
        ? 'Cette adresse email est déjà utilisée'
        : 'Une erreur est survenue lors de l\'inscription'
      return
    }

    if (!authData.user?.id) {
      throw new Error('User ID not found')
    }

    // 2. Créer l'utilisateur dans la table users
    const { error: userError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        full_name: form.fullName,
        role: 'owner',
        subscription_tier: 'free',
        is_active: true,
        phone: form.phone,
        subscription_ends_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000) // +90 jours (offre de lancement)
      })

    if (userError) throw userError
    
    // 3. Créer l'établissement
    const { error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: form.restaurantName,
        slug: form.restaurantName.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
        type_id: form.type,
        user_id: authData.user.id,
        created_by: authData.user.id,
        is_active: true,
        subscription_type: 'basic',
        address: form.address,
        phone: form.phone
      })
    
    if (establishmentError) {
      errors.restaurantName = 'Erreur lors de la création du restaurant'
      return
    }
    
    // Redirection avec message de succès
    navigateTo('/auth/login', {
      query: { 
        registered: 'true',
        email: form.email
      }
    })
  } catch (err) {
    console.error('Erreur inscription:', err)
    errors.restaurantName = 'Une erreur inattendue est survenue'
  } finally {
    loading.value = false
  }
}

const signInWithGoogle = async () => {
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    })
    if (error) throw error
  } catch (error) {
    errors.email = 'Erreur de connexion avec Google'
  }
}

const nextStep = () => {
  if (step.value === 1) {
    if (Object.values(errors).some(Boolean)) return
    step.value = 2
  } else {
    handleRegister()
  }
}

definePageMeta({
  layout: 'auth'
})
</script>

<style scoped>
/* Animation pour le hover des boutons */
.hover-scale {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.hover-scale:hover:not(:disabled) {
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* Couleur Facebook */
.text-facebook {
  color: #1877F2;
}

.border-facebook {
  border-color: #1877F2;
}

.bg-facebook {
  background-color: #1877F2;
}

.bg-facebook-dark {
  background-color: #166FE5;
}

.focus\:border-facebook:focus {
  border-color: #1877F2;
}

.focus\:ring-facebook:focus {
  --tw-ring-color: #1877F2;
}

.focus\:ring-facebook\/20:focus {
  --tw-ring-color: rgba(24, 119, 242, 0.2);
}

.hover\:text-facebook\/80:hover {
  color: rgba(24, 119, 242, 0.8);
}

/* Animation du loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>