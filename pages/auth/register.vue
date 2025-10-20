<template>
  <div class="min-h-screen my-20 md:p-5 bg-white items-center justify-center">
    <!-- Logo -->
    <!-- <div class="fixed top-0 left-0 right-0 h-16 bg-white/80 backdrop-blur-xl border-b border-gray-100/50 z-50">
      <div class="max-w-xl mx-auto px-4 h-full flex items-center">
        <NuxtLink to="/" class="flex items-center space-x-2">
          <img src="~/assets/icon/logo.png" alt="Logo" class="h-[50px] w-auto" />
        </NuxtLink>
      </div>
    </div> -->

    <!-- Main Content -->
    <div class="lg:pt-32- pt-20- py-16 px-4">
      <div class="max-w-md mx-auto">
        <!-- Progress Steps -->
        <div class="flex items-center justify-between mb-12">
          <div class="flex items-center">
            <div class="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center font-medium"
            :class="step === 1 ? 'bg-kula-500 text-white' : 'bg-gray-500 text-white'">
              1
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium" :class="step === 1 ? 'text-kula-500' : 'text-gray-500'">
                Compte
              </p>
            </div>
          </div>
          <div class="h-px w-16 bg-gray-200"></div>
          <div class="flex items-center">
            <div class="w-8 h-8 rounded-full flex items-center justify-center font-medium"
              :class="step === 2 ? 'bg-kula-500 text-white' : 'bg-gray-500 text-white'">
              2
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium" :class="step === 2 ? 'text-kula-500' : 'text-gray-500'">
                Etablissement
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
              Commencez votre essai gratuit de 7 jours
            </p>
          </div>

          <!-- Google Sign Up -->
          <button 
            @click="signInWithGoogle"
            class="w-full h-12 border border-gray-300 rounded-full font-medium flex items-center justify-center hover:bg-gray-50 transition-all"
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
            <FloatLabelInput
              v-model="form.fullName"
              id="fullName"
              type="text"
              label="Nom complet"
              :error="errors.fullName"
              required
            />

            <FloatLabelInput
              v-model="form.email"
              type="email"
              label="Adresse email"
              :error="errors.email"
              required
            />

            <FloatLabelInput
              v-model="form.password"
              id="password"
              :type="showPassword ? 'text' : 'password'"
              label="Mot de passe"
              minlength="6"
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
            </FloatLabelInput>

            <button
              type="submit"
              class="w-full h-14 border bg-kula-500 text-white border-kula-500 rounded-full font-medium flex items-center justify-center hover:bg-kula-600 transition-all"
              >
              <span v-if="!loading" class="text-white font-medium text-lg text-center">Continuer</span>
              <span v-else class="flex items-center">
                <Loader2 class="w-5 h-5 animate-spin mr-2" />
                <span class="text-white font-medium text-lg text-center">Chargement en cours...</span>
              </span>
              <ArrowRight class="w-5 h-5 ml-2 text-white" />
            </button>
          </form>
        </div>

        <!-- Step 2: Restaurant Info -->
        <div v-else class="space-y-8">
          <div class="text-center space-y-4">
            <h1 class="text-[2.5rem] leading-tight font-semibold text-gray-900">
              Votre établissement
            </h1>
            <p class="text-xl text-gray-500 font-light">
              Personnalisez votre espace
            </p>
          </div>

          <form @submit.prevent="handleRegister" class="space-y-5">
            <FloatLabelInput
              v-model="form.restaurantName"
              label="Nom de l'établissement"
              :error="errors.restaurantName"
              required
            />

            <!-- Restaurant Type Selection -->
            <div class="space-y-2">
              <!-- <label class="block text-sm font-medium text-gray-700">Type d'établissement</label> -->
              <!-- <div class="relative">

                <Listbox v-model="form.type">
                  <div class="relative">
                    <ListboxButton 
                      class="relative w-full h-12 px-4 text-left bg-white border border-gray-200 rounded-full cursor-pointer focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent"
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
              </div> -->
              <FloatLabelSelect
                id="type"
                v-model="form.type"
                label="Type d'établissement"
                :error="errors.type"
                required
              >
                <option v-for="type in establishmentTypes" :key="type.id" :value="type.id">{{ type.name }}</option>
              </FloatLabelSelect>
              <p v-if="errors.type" class="text-sm text-red-600 mt-1">{{ errors.type }}</p>
            </div>

            <!-- Adresse -->
            <FloatLabelInput
              v-model="form.address"
              label="Adresse"
              :error="errors.address"
              placeholder="Adresse de votre établissement"
            />
             
<!--  -->

             
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
                class="w-2/3 h-14 border bg-kula-500 text-white border-kula-500 rounded-full font-medium flex items-center justify-center hover:bg-kula-600 transition-all"
                :disabled="loading"
              >
                <span v-if="!loading" class="text-white font-medium text-lg text-center">Créer mon compte</span>
                <span v-else class="flex items-center">
                  <Loader2 class="w-5 h-5 animate-spin mr-2" />
                  <span class="text-white font-medium text-lg text-center">Création en cours...</span>
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
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

import FormInput from '~/components/ui/FormInput.vue'
import FloatLabelInput from '~/components/FloatLabelInput.vue'
// import MapPin from '~/components/icons/MapPin.vue'
import { MapPin as MapPinIcon } from 'lucide-vue-next'
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
  phone: '',
})

const errors = reactive({
  email: '',
  fullName: '',
  password: '',
  restaurantName: '',
  type: '',
  address: '',
  phone: '',
})

const { client: supabase } = useSupabaseWrapper()
const router = useRouter()
const {showToast} = useCustomToast()

const { data: establishmentTypes } = await supabase
  .from('establishment_types')
  .select('*')
  .eq('is_active', true)
  .order('name')

const selectedType = computed(() => 
  establishmentTypes?.find((type: any) => type.id === form.type)
)

const route = useRoute()
const step = ref(1)

// Récupérer les données du callback si présentes
onMounted(() => {
  const stepParam = route.query.step
  const dataParam = route.query.data
  
  if (stepParam === '2' && dataParam) {
    try {
      // Décoder les données utilisateur
      const userData = JSON.parse(atob(dataParam as string))
      // console.log('📥 Données utilisateur reçues:', userData)
      
      // Pré-remplir le formulaire
      form.email = userData.email
      form.fullName = userData.fullName
      
      // Passer directement à l'étape 2
      step.value = 2
      
      // console.log('✅ Formulaire pré-rempli, étape 2 activée')
    } catch (error) {
      console.error('❌ Erreur décodage données utilisateur:', error)
    }
  }
})

const handleRegister = async () => {
  // console.log('🚀 Début handleRegister')
  // console.log('📋 Form data:', form)
  
  // Validation complète avant soumission
  let hasErrors = false
  
  if (!form.type) {
    // console.log('❌ Type manquant:', form.type)
    errors.type = 'Veuillez sélectionner un type de restaurant'
    hasErrors = true
  }
  
  if (!form.restaurantName || form.restaurantName.trim() === '') {
    // console.log('❌ Nom établissement manquant:', form.restaurantName)
    errors.restaurantName = 'Le nom du restaurant est obligatoire'
    hasErrors = true
  }
  
  if (!form.fullName || form.fullName.trim() === '') {
    // console.log('❌ Nom complet manquant:', form.fullName)
    errors.fullName = 'Le nom complet est obligatoire'
    hasErrors = true
  }
  
  if (!form.email || form.email.trim() === '') {
    // console.log('❌ Email manquant:', form.email)
    errors.email = 'L\'email est obligatoire'
    hasErrors = true
  }
  
  // Vérifier si l'utilisateur est déjà connecté (venant du callback)
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  const isAlreadyAuthenticated = !!currentUser
  
  if (!isAlreadyAuthenticated) {
    if (!form.password || form.password.length < 6) {
      // console.log('❌ Mot de passe invalide:', form.password?.length)
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères'
      hasErrors = true
    }
  }
  


  if (hasErrors) {
    // console.log('❌ Erreurs de validation détectées')
    return
  }
  
  // console.log('✅ Validation OK, début de l\'inscription')
  loading.value = true
  error.value = ''
  
  try {
    let userId = currentUser?.id
    
    // 1. Créer le compte auth seulement si pas déjà connecté
    if (!isAlreadyAuthenticated) {
      // console.log('🔐 Création du compte auth...')
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: form.email,
        password: form.password,
        options: {
          data: {
            full_name: form.fullName,
            role: 'owner'
          },
          emailRedirectTo: `${window.location.origin}/auth/callback`
        }
      })
      
      if (authError) {
        // console.error('❌ Erreur auth:', authError)
        errors.email = authError.message === 'User already registered'
          ? 'Cette adresse email est déjà utilisée'
          : 'Une erreur est survenue lors de l\'inscription'
        return
      }

      if (!authData.user?.id) {
        // console.error('❌ User ID non trouvé')
        throw new Error('User ID not found')
      }
      
      userId = authData.user.id
      console.log('✅ Compte auth créé, ID:', userId)
    } else {
      console.log('✅ Utilisateur déjà authentifié, ID:', userId)
    }

    // 2. Créer l'utilisateur dans la table users (seulement si pas déjà créé)
    // console.log('👤 Vérification/création de l\'utilisateur dans la table users...')
    const { data: existingUser, error: userCheckError } = await supabase
      .from('users')
      .select('id')
      .eq('id', userId)
      .single()
    
    if (userCheckError && userCheckError.code === 'PGRST116') {
      // Utilisateur n'existe pas, le créer
      const { error: userError } = await supabase
        .from('users')
        .insert({
          id: userId,
          full_name: form.fullName,
          role: 'owner',
          subscription_tier: 'free',
          is_active: true,
          phone: form.phone || null,
          subscription_ends_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
        })

      if (userError) {
        console.error('❌ Erreur création utilisateur:', userError)
        error.value = 'Une erreur est survenue lors de la création du profil'
        return
      }
      
      console.log('✅ Utilisateur créé dans la table users')
    } else {
      console.log('✅ Utilisateur existe déjà dans la table users')
    }
    
    // 3. Créer l'établissement
    console.log('🏪 Création de l\'établissement...')
    console.log('📝 Données établissement:', {
      name: form.restaurantName,
      slug: form.restaurantName.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
      type_id: form.type,
      user_id: userId,
      created_by: userId,
      is_active: true,
      subscription_type: 'basic',
      address: form.address || null,
      phone: form.phone || null
    })
    
    const { data: establishment, error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: form.restaurantName,
        slug: form.restaurantName.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
        type_id: form.type,
        user_id: userId,
        created_by: userId,
        is_active: true,
        subscription_type: 'basic',
        address: form.address || null,
        phone: form.phone || null
      })
    
    if (establishmentError) {
      console.error('❌ Erreur création établissement:', establishmentError)
      errors.restaurantName = 'Erreur lors de la création du restaurant'
      return
    }
    
    console.log('✅ Établissement créé avec succès')
    
    // 4. Si pas déjà connecté, connecter l'utilisateur
    if (!isAlreadyAuthenticated) {
      console.log('🔑 Connexion automatique...')
      const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email: form.email,
        password: form.password
      })
      
      if (signInError) {
        console.error('❌ Erreur de connexion automatique:', signInError)
        navigateTo('/auth/login?registered=true&email=' + encodeURIComponent(form.email))
        return
      }
      
      console.log('✅ Connexion automatique réussie')
    }
    
    // 5. L'utilisateur est maintenant connecté, le plugin auth.ts le redirigera automatiquement
    showToast.success('Configuration terminée !', 'Redirection vers votre dashboard...')
    navigateTo(`/manager/${establishment?.[0]?.slug || establishment?.[0]?.id}`)
    return
  } catch (err) {
    console.error('❌ Erreur inscription:', err)
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
    // Validation complète de l'étape 1
    let hasErrors = false
    
    if (!form.fullName || form.fullName.trim() === '') {
      errors.fullName = 'Le nom complet est obligatoire'
      hasErrors = true
    }
    
    if (!form.email || form.email.trim() === '') {
      errors.email = 'L\'email est obligatoire'
      hasErrors = true
    }
    
    if (!form.password || form.password.length < 6) {
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères'
      hasErrors = true
    }
    
    if (hasErrors) {
      return
    }
    
    // Si tout est valide, passer à l'étape 2
    step.value = 2
    // Réinitialiser les erreurs
    errors.fullName = ''
    errors.email = ''
    errors.password = ''
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