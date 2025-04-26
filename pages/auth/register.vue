<template>
  <div class="min-h-screen bg-[#FBsFBFD]">
    <!-- Logo -->
    <!-- <div class="fixed top-0 left-0 right-0 h-16 bg-white/80 backdrop-blur-xl border-b border-gray-100/50 z-50">
      <div class="max-w-xl mx-auto px-4 h-full flex items-center">
        <NuxtLink to="/" class="flex items-center space-x-2">
          <img src="~/assets/icon/logo.png" alt="Logo" class="h-[50px] w-auto" />
        </NuxtLink>
      </div>
    </div> -->

    <!-- Main Content -->
    <div class="lg:pt-32 pt-20 pb-16 px-4">
      <div class="max-w-md mx-auto">
        <!-- Progress Steps -->
        <div class="flex items-center justify-between mb-12">
          <div class="flex items-center">
            <div class="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center font-medium">
              1
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium" :class="step === 1 ? 'text-black' : 'text-gray-500'">
                Compte
              </p>
            </div>
          </div>
          <div class="h-px w-16 bg-gray-200"></div>
          <div class="flex items-center">
            <div class="w-8 h-8 rounded-full flex items-center justify-center font-medium"
              :class="step === 2 ? 'bg-black text-white' : 'bg-gray-100 text-gray-400'">
              2
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium" :class="step === 2 ? 'text-black' : 'text-gray-500'">
                Restaurant
              </p>
            </div>
          </div>
        </div>

        <!-- Step 1: User Info -->
        <div v-if="step === 1" class="space-y-8">
          <div class="text-center space-y-4">
            <h1 class="text-[2.5rem] leading-tight font-semibold text-gray-900">
              Créez votre compte
            </h1>
            <p class="text-xl text-gray-500 font-light">
              Commencez votre essai gratuit de 14 jours
            </p>
          </div>

          <!-- Google Sign Up -->
          <button 
            @click="signInWithGoogle"
            class="w-full h-[52px] bg-white border border-gray-200 rounded-2xl font-medium flex items-center justify-center hover:bg-gray-50 transition-all group shadow-sm"
          >
            <svg class="w-5 h-5 mr-3" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Continuer avec Google
          </button>

          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-200"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-4 bg-[#FBFBFD] text-gray-500 font-medium">ou</span>
            </div>
          </div>

          <form @submit.prevent="nextStep" class="space-y-5">
            <FormInput
              v-model="form.fullName"
              type="text"
              label="Nom complet"
              :error="errors.fullName"
              required
            />

            <FormInput
              v-model="form.email"
              type="email"
              label="Email professionnel"
              :error="errors.email"
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

            <button
              type="submit"
              class="w-full h-[52px] bg-black text-white rounded-2xl font-medium hover:opacity-90 transition-all flex items-center justify-center shadow-lg shadow-black/[0.08] hover:shadow-black/[0.12]"
            >
              Continuer
              <ArrowRight class="w-5 h-5 ml-2" />
            </button>
          </form>
        </div>

        <!-- Step 2: Restaurant Info -->
        <div v-else class="space-y-8">
          <div class="text-center space-y-4">
            <h1 class="text-[2.5rem] leading-tight font-semibold text-gray-900">
              Votre restaurant
            </h1>
            <p class="text-xl text-gray-500 font-light">
              Personnalisez votre espace
            </p>
          </div>

          <form @submit.prevent="handleRegister" class="space-y-5">
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
                      class="relative w-full h-[52px] px-4 text-left bg-white border border-gray-200 rounded-2xl cursor-pointer focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent"
                      :class="{ 'border-red-300': errors.type }"
                    >
                      <span v-if="selectedType" class="flex items-center">
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
                      <ListboxOptions class="absolute z-10 w-full py-1 mt-1 overflow-auto text-base bg-white rounded-2xl shadow-lg max-h-60 ring-1 ring-black ring-opacity-5 focus:outline-none">
                        <ListboxOption
                          v-for="type in establishmentTypes"
                          :key="type.id"
                          v-slot="{ active, selected }"
                          :value="type.id"
                          as="template"
                        >
                          <li :class="[
                            active ? 'bg-black/5 text-black' : 'text-gray-900',
                            'relative cursor-pointer select-none py-3 px-4'
                          ]">
                            <div class="flex items-center">
                              <span :class="[
                                selected ? 'font-semibold' : 'font-normal',
                                'block truncate'
                              ]">
                                {{ type.name }}
                              </span>
                            </div>

                            <span v-if="selected" class="absolute inset-y-0 right-0 flex items-center pr-4 text-black">
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

            <div class="flex items-start py-2">
              <input
                v-model="form.terms"
                type="checkbox"
                required
                class="mt-1 h-4 w-4 rounded border-gray-300 text-black focus:ring-black"
              />
              <label class="ml-3 text-sm text-gray-500">
                J'accepte les <a href="/legal/terms" class="text-black font-medium hover:opacity-70">conditions d'utilisation</a> et la 
                <a href="/legal/privacy" class="text-black font-medium hover:opacity-70">politique de confidentialité</a>
              </label>
            </div>

            <div class="flex gap-4">
              <button
                type="button"
                @click="step = 1"
                class="w-1/3 h-[52px] bg-gray-100 text-gray-900 rounded-2xl font-medium hover:bg-gray-200 transition-all flex items-center justify-center"
              >
                <ArrowLeft class="w-5 h-5 mr-2" />
                Retour
              </button>

              <button
                type="submit"
                class="w-2/3 h-[52px] bg-black text-white rounded-2xl font-medium hover:opacity-90 transition-all flex items-center justify-center shadow-lg shadow-black/[0.08] hover:shadow-black/[0.12]"
                :disabled="loading"
              >
                <span v-if="!loading">Créer mon compte</span>
                <span v-else class="flex items-center">
                  <Loader2 class="w-5 h-5 animate-spin mr-2" />
                  Création en cours...
                </span>
              </button>
            </div>
          </form>
        </div>

        <!-- Trust signals -->
        <div class="mt-16 grid grid-cols-3 gap-6 text-center">
          <!-- ... Trust signals content ... -->
        </div>

        <!-- Add after the form -->
        <div class="mt-8 text-center space-y-4">
          <div class="h-px w-full bg-gray-100"></div>
          
          <p class="text-gray-500">
            Vous avez déjà un compte ?
            <NuxtLink 
              to="/auth/login" 
              class="text-black font-medium hover:opacity-80 transition-opacity"
            >
              Se connecter
            </NuxtLink>
          </p>

          <!-- Terms and Privacy -->
          <p class="text-xs text-gray-400 max-w-md mx-auto">
            En continuant, vous acceptez nos 
            <NuxtLink to="/terms" class="underline hover:text-gray-600">Conditions d'utilisation</NuxtLink> 
            et notre 
            <NuxtLink to="/privacy" class="underline hover:text-gray-600">Politique de confidentialité</NuxtLink>
          </p>
        </div>

        <!-- Language Selector -->
        <div class="fixed bottom-4 right-4">
          <select 
            class="h-8 pl-2 pr-8 text-sm bg-white border border-gray-200 rounded-lg focus:outline-none focus:border-gray-300"
          >
            <option value="fr">Français</option>
            <option value="en">English</option>
          </select>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { Eye, EyeOff, Loader2, Check, ChevronDown, ArrowRight, ArrowLeft } from 'lucide-vue-next'
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from '@headlessui/vue'
import { useRouter } from 'vue-router'
// import { useSupabase } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

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
const router = useRouter()
const {showToast} = useCustomToast()

const { data: establishmentTypes } = await supabase
  .from('establishment_types')
  .select('*')
  .eq('is_active', true)
  .order('name')

const selectedType = computed(() => 
  establishmentTypes.find(type => type.id === form.type)
)

const step = ref(1)

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
    // Validate first step
    if (!form.fullName || !form.email || !form.password) {
      return
    }
    step.value = 2
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

/* Add smooth transitions */
.transition-opacity {
  transition: opacity 0.2s ease;
}

/* Improve link hover states */
a:hover {
  opacity: 0.8;
}

/* Style select dropdown */
select {
  appearance: none;
  background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.5rem center;
  background-size: 1em;
}
</style>