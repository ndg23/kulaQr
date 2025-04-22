<template>
  <div class="bg-white rounded-2xl mx-auto max-w-lg w-full p-8">
    <!-- Logo -->
    <div class="flex justify-center mb-">
      <img src="~/assets/icon/logo.png" alt="Logo" class="w-[100px] h-[100px]" />
    </div>

    <!-- Title -->
    <h1 class="text-3xl font-extrabold text-center mb-1">Inscrivez votre restaurant</h1>
    <p class="text-gray-700 text-center mb-8">Créez votre menu QR en quelques minutes</p>

    <!-- Social Registration -->
    <button 
      type="button"
      @click="signInWithGoogle"
      class="w-full bg-white border border-gray-300 rounded-full py-3 px-4 mb-4 font-medium flex items-center justify-center hover-scale custom-shadow"
    >
      <svg viewBox="0 0 24 24" width="22" height="22" class="mr-3">
        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
      </svg>
      Continuer avec Google
    </button>

    <!-- Divider -->
    <div class="flex items-center my-6">
      <div class="flex-grow border-t border-gray-200"></div>
      <span class="px-4 text-gray-700 font-medium text-sm">ou inscription manuelle</span>
      <div class="flex-grow border-t border-gray-200"></div>
    </div>

    <!-- Form -->
    <form @submit.prevent="handleRegister" class="space-y-4 max-w-lg mx-auto w-full">
      <!-- Error Message -->
      <FormError :message="error" />

      <!-- Restaurant Name -->
      <div class="relative">
        <input
          v-model="restaurantName"
          type="text"
          id="restaurantName"
          required
          class="peer w-full h-14 px-4 pt-5 rounded-lg bg-gray--50 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook transition-all text-base placeholder-transparent"
          placeholder="Nom du restaurant"
          :disabled="loading"
        />
        <label 
          for="restaurantName"
          class="absolute left-4 text-gray-700 transition-all duration-200 transform
          peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
          peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-facebook
          text-sm top-3 translate-y-0"
        >
          Nom du restaurant
        </label>
      </div>

      <!-- Restaurant Type -->
      <div class="relative">
        <Listbox v-model="selectedType">
          <div class="relative">
            <ListboxButton class="relative w-full h-14 px-4 text-left bg-white border border-gray-300 rounded-lg cursor-pointer focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook">
              <span v-if="selectedType" class="flex items-center">
                <component :is="selectedType.icon" class="w-5 h-5 mr-2 text-gray-500" />
                <span class="block truncate">{{ selectedType.name }}</span>
              </span>
              <span v-else class="text-gray-500">Sélectionnez un type</span>
              <span class="absolute inset-y-0 right-0 flex items-center pr-2">
                <ChevronDown class="w-5 h-5 text-gray-400" aria-hidden="true" />
              </span>
            </ListboxButton>

            <transition
              leave-active-class="transition duration-100 ease-in"
              leave-from-class="opacity-100"
              leave-to-class="opacity-0"
            >
              <ListboxOptions class="absolute z-10 w-full py-1 mt-1 overflow-auto text-base bg-white rounded-lg shadow-lg max-h-60 ring-1 ring-black ring-opacity-5 focus:outline-none">
                <ListboxOption
                  v-for="type in establishmentTypes"
                  :key="type.id"
                  v-slot="{ active, selected }"
                  :value="type"
                >
                  <div :class="[
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
                  </div>
                </ListboxOption>
              </ListboxOptions>
            </transition>
          </div>
        </Listbox>
      </div>

      <!-- Email -->
      <div class="relative">
        <input
          v-model="email"
          type="email"
          id="email"
          required
          class="peer w-full h-14 px-4 pt-5 rounded-lg bg-gray--50 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook transition-all text-base placeholder-transparent"
          placeholder="Email"
          :disabled="loading"
        />
        <label 
          for="email"
          class="absolute left-4 text-gray-700 transition-all duration-200 transform
          peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
          peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-facebook
          text-sm top-3 translate-y-0"
        >
          Adresse email professionnelle
        </label>
      </div>

      <!-- Password -->
      <div class="relative">
        <input
          v-model="password"
          :type="showPassword ? 'text' : 'password'"
          id="password"
          required
          class="peer w-full h-14 px-4 pt-5 rounded-lg bg-gray--50 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook transition-all text-base placeholder-transparent"
          placeholder="Mot de passe"
          :disabled="loading"
        />
        <label 
          for="password"
          class="absolute left-4 text-gray-700 transition-all duration-200 transform
          peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
          peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-facebook
          text-sm top-3 translate-y-0"
        >
          Choisir un mot de passe
        </label>
        <div class="absolute right-4 top-1/2 -translate-y-1/2">
          <button 
            type="button"
            class="text-gray-400 hover:text-gray-600 transition-colors focus:outline-none"
            @click="togglePassword"
          >
            <Eye v-if="showPassword" class="w-5 h-5" />
            <EyeOff v-else class="w-5 h-5" />
          </button>
        </div>
      </div>

      <!-- Terms -->
      <div class="flex items-start mt-4">
        <div class="flex items-center h-5">
          <input
            id="terms"
            type="checkbox"
            v-model="acceptTerms"
            required
            class="w-4 h-4 text-facebook border-gray-300 rounded focus:ring-facebook"
            :disabled="loading"
          />
        </div>
        <div class="ml-3 text-sm">
          <label for="terms" class="text-gray-600">
            J'accepte les <a href="#" class="text-facebook font-medium">conditions d'utilisation</a> et la <a href="#" class="text-facebook font-medium">politique de confidentialité</a>
          </label>
        </div>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        class="w-full h-14 bg-facebook text-white rounded-full hover:bg-facebook-dark flex items-center justify-center font-bold text-base transition-all hover-scale disabled:opacity-50 focus:ring-4 focus:ring-facebook/20 mt-6"
        :disabled="loading || !acceptTerms || !selectedType"
      >
        <template v-if="loading">
          <Loader2 class="w-5 h-5 animate-spin mr-2" />
          Inscription en cours...
        </template>
        <template v-else>
          Créer mon compte restaurant
        </template>
      </button>
    </form>

    <!-- Sign in link -->
    <p class="mt-8 text-base text-center text-gray-600">
      Déjà inscrit ?{' '}
      <NuxtLink 
        to="/auth/login" 
        class="text-facebook hover:text-facebook/80 font-bold transition-colors"
      >
        Se connecter
      </NuxtLink>
    </p>

    <!-- Restaurant advantage -->
    <div class="mt-6 p-4 bg-green-50 rounded-lg border border-green-100">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-green-800">Offre de lancement</h3>
          <div class="mt-1 text-sm text-green-700">
            Inscrivez-vous maintenant et bénéficiez de 3 mois gratuits !
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Eye, EyeOff, Loader2, ChevronDown, Check } from 'lucide-vue-next'
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from '@headlessui/vue'
import FormError from '~/components/ui/FormError.vue'

const restaurantName = ref('')
const selectedType = ref(null)
const email = ref('')
const password = ref('')
const acceptTerms = ref(false)
const loading = ref(false)
const showPassword = ref(false)
const error = ref('')
const supabase = useSupabaseClient()

const { data: establishmentTypes } = await supabase
  .from('establishment_types')
  .select('*')
  .eq('is_active', true)
  .order('name')

const handleRegister = async () => {
  if (!acceptTerms.value || !selectedType.value) return
  
  loading.value = true
  error.value = ''
  try {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        data: {
          restaurant_name: restaurantName.value,
          restaurant_type: selectedType.value.slug
        }
      }
    })
    
    if (authError) {
      error.value = authError.message === 'User already registered'
        ? 'Cette adresse email est déjà utilisée'
        : 'Une erreur est survenue lors de l\'inscription'
      return
    }
    
    const { error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: restaurantName.value,
        slug: restaurantName.value.toLowerCase().replace(/ /g, '-'),
        type_id: selectedType.value.id,
        user_id: authData.user.id,
        is_active: true
      })
    
    if (establishmentError) {
      error.value = 'Erreur lors de la création du restaurant'
      return
    }
    
    navigateTo('/auth/login')
  } catch (err) {
    error.value = 'Une erreur inattendue est survenue'
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
    error.value = 'Erreur de connexion avec Google'
  }
}

const togglePassword = () => {
  showPassword.value = !showPassword.value
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