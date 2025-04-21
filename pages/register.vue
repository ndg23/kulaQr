<template>
  <div class="min-h-screen bg-white">
    <!-- Main Container -->
    <div class="max-w-[1400px] mx-auto min-h-screen flex">
      <!-- Left Panel -->
      <div class="hidden lg:flex lg:w-[50%] flex-col justify-center px-24">
        <div class="max-w-lg">
          <h1 class="text-[64px] font-bold leading-[1.1] tracking-tight text-gray-900 mb-8">
            Digitalisez votre restaurant en 
            <span class="bg-gradient-to-r from-blue-600 to-blue-400 text-transparent bg-clip-text">
              5 minutes
            </span>
          </h1>
          <p class="text-2xl text-gray-500 leading-relaxed">
            Rejoignez plus de 2000 restaurants qui utilisent KulaQr pour augmenter leurs ventes.
          </p>

          <!-- Trust Badges -->
          <div class="mt-16 space-y-6">
            <div class="flex items-center space-x-6 p-6 rounded-2xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div class="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
                <Clock class="w-6 h-6 text-blue-500" />
              </div>
              <div>
                <h3 class="font-medium text-gray-900 mb-1">Configuration rapide</h3>
                <p class="text-gray-500">Créez votre menu digital en quelques clics</p>
              </div>
            </div>

            <div class="flex items-center space-x-6 p-6 rounded-2xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div class="w-12 h-12 bg-emerald-50 rounded-xl flex items-center justify-center">
                <Gift class="w-6 h-6 text-emerald-500" />
              </div>
              <div>
                <h3 class="font-medium text-gray-900 mb-1">14 jours gratuits</h3>
                <p class="text-gray-500">Testez toutes les fonctionnalités sans engagement</p>
              </div>
            </div>

            <div class="flex items-center space-x-6 p-6 rounded-2xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div class="w-12 h-12 bg-purple-50 rounded-xl flex items-center justify-center">
                <Headphones class="w-6 h-6 text-purple-500" />
              </div>
              <div>
                <h3 class="font-medium text-gray-900 mb-1">Support premium</h3>
                <p class="text-gray-500">Une équipe dédiée à votre réussite 7j/7</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Panel -->
      <div class="w-full lg:w-[50%] flex items-center justify-center p-8 lg:px-24">
        <div class="w-full max-w-md py-12">
          <!-- Logo -->
          <div class="mb-12">
            <NuxtLink to="/" class="inline-flex items-center space-x-3">
              <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center">
                <QrCode class="w-7 h-7 text-white" />
              </div>
              <span class="text-3xl font-bold">KulaQr</span>
            </NuxtLink>
          </div>

          <div class="max-w-md mx-auto">
            <!-- Title -->
            <h2 class="text-3xl font-bold text-gray-900 mb-1">Créer votre compte</h2>
            <p class="text-gray-500 mb-8">Commencez à digitaliser votre restaurant</p>

            <!-- Progress Steps -->
            <div class="flex items-center justify-between mb-10">
              <div 
                v-for="(step, index) in steps" 
                :key="step.name"
                class="flex items-center"
              >
                <div class="relative flex flex-col items-center">
                  <div 
                    class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-all"
                    :class="[
                      currentStep > index 
                        ? 'bg-black text-white' 
                        : currentStep === index 
                          ? 'bg-black text-white'
                          : 'bg-gray-100 text-gray-400'
                    ]"
                  >
                    <component 
                      :is="step.icon" 
                      v-if="currentStep > index"
                      class="w-4 h-4"
                    />
                    <span v-else>{{ index + 1 }}</span>
                  </div>
                  <span class="absolute -bottom-6 text-xs font-medium" :class="currentStep >= index ? 'text-black' : 'text-gray-400'">
                    {{ step.name }}
                  </span>
                </div>
                <div 
                  v-if="index < steps.length - 1"
                  class="w-full h-[2px] mx-2"
                  :class="currentStep > index ? 'bg-black' : 'bg-gray-200'"
                />
              </div>
            </div>

            <form @submit.prevent="handleSignup" class="space-y-5 mt-12">
              <!-- Step 1: Restaurant Info -->
              <div v-if="currentStep === 0" class="space-y-5">
                <!-- Restaurant Name -->
                <div class="relative">
                  <label 
                    for="restaurantName"
                    class="absolute left-4 text-gray-500 transition-all duration-200 transform
                    peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
                    peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
                    text-sm top-3 translate-y-0 pointer-events-none"
                  >
                    Nom du restaurant
                  </label>
                  <input
                    v-model="form.restaurantName"
                    type="text"
                    id="restaurantName"
                    required
                    class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
                    placeholder="Nom du restaurant"
                    :disabled="loading"
                  />
                </div>

                <!-- Address -->
                <div class="relative">
                  <label 
                    for="address"
                    class="absolute left-4 text-gray-500 transition-all duration-200 transform
                    peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
                    peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
                    text-sm top-3 translate-y-0 pointer-events-none"
                  >
                    Adresse complète
                  </label>
                  <input
                    v-model="form.address"
                    type="text"
                    id="address"
                    required
                    class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
                    placeholder="Adresse"
                    :disabled="loading"
                  />
                </div>
              </div>

              <!-- Step 2: Personal Info -->
              <div v-if="currentStep === 1" class="space-y-5">
                <!-- Full Name -->
                <div class="relative">
                  <label 
                    for="fullName"
                    class="absolute left-4 text-gray-500 transition-all duration-200 transform
                    peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
                    peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
                    text-sm top-3 translate-y-0 pointer-events-none"
                  >
                    Nom complet
                  </label>
                  <input
                    v-model="form.fullName"
                    type="text"
                    id="fullName"
                    required
                    class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
                    placeholder="Nom complet"
                    :disabled="loading"
                  />
                </div>

                <!-- Email -->
                <div class="relative">
                  <label 
                    for="email"
                    class="absolute left-4 text-gray-500 transition-all duration-200 transform
                    peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
                    peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
                    text-sm top-3 translate-y-0 pointer-events-none"
                  >
                    Adresse email
                  </label>
                  <input
                    v-model="form.email"
                    type="email"
                    id="email"
                    required
                    class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
                    placeholder="Email"
                    :disabled="loading"
                  />
                </div>
              </div>

              <!-- Step 3: Password -->
              <div v-if="currentStep === 2" class="space-y-5">
                <!-- Password -->
                <div class="relative">
                  <label 
                    for="password"
                    class="absolute left-4 text-gray-500 transition-all duration-200 transform
                    peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
                    peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
                    text-sm top-3 translate-y-0 pointer-events-none"
                  >
                    Mot de passe
                  </label>
                  <input
                    v-model="form.password"
                    :type="showPassword ? 'text' : 'password'"
                    id="password"
                    required
                    class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
                    placeholder="Mot de passe"
                    :disabled="loading"
                  />
                  <button 
                    type="button"
                    class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    @click="togglePassword"
                  >
                    <Eye v-if="showPassword" class="w-5 h-5" />
                    <EyeOff v-else class="w-5 h-5" />
                  </button>
                </div>

                <!-- Password Strength -->
                <div class="flex gap-2 mt-2">
                  <div 
                    v-for="(strength, index) in passwordStrength" 
                    :key="index"
                    class="h-1 flex-1 rounded-full transition-colors"
                    :class="strength ? 'bg-black' : 'bg-gray-200'"
                  />
                </div>

                <!-- Terms -->
                <div class="flex items-start mt-6">
                  <input
                    v-model="form.acceptTerms"
                    id="terms"
                    type="checkbox"
                    required
                    class="mt-1 w-4 h-4 rounded text-black focus:ring-black border-gray-300"
                  />
                  <label for="terms" class="ml-3 text-sm text-gray-500">
                    J'accepte les <a href="#" class="text-black hover:underline">conditions d'utilisation</a>
                    et la <a href="#" class="text-black hover:underline">politique de confidentialité</a>
                  </label>
                </div>
              </div>

              <!-- Navigation Buttons -->
              <div class="flex justify-between items-center mt-8">
                <button
                  v-if="currentStep > 0"
                  type="button"
                  class="text-gray-600 hover:text-gray-900 font-medium"
                  @click="currentStep--"
                >
                  Retour
                </button>
                <button
                  v-if="currentStep < steps.length - 1"
                  type="button"
                  class="ml-auto h-12 px-8 bg-black text-white rounded-full hover:bg-gray-800 font-medium transition-all"
                  @click="nextStep"
                >
                  Continuer
                </button>
                <button
                  v-else
                  type="submit"
                  class="ml-auto h-12 px-8 bg-black text-white rounded-full hover:bg-gray-800 font-medium transition-all disabled:opacity-50"
                  :disabled="loading || !form.acceptTerms"
                >
                  <template v-if="loading">
                    <Loader2 class="w-5 h-5 animate-spin" />
                  </template>
                  <template v-else>
                    Créer mon compte
                  </template>
                </button>
              </div>
            </form>

            <!-- Sign in link -->
            <p class="mt-8 text-base text-center text-gray-600">
              Déjà un compte ?{' '}
              <NuxtLink 
                to="/login" 
                class="text-blue-500 hover:text-blue-600 font-medium"
              >
                Se connecter
              </NuxtLink>
            </p>

            <!-- Offline Mode Notice -->
            <div class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-100">
              <div class="flex items-start">
                <div class="flex-shrink-0">
                  <WifiOff class="w-5 h-5 text-blue-500" />
                </div>
                <div class="ml-3">
                  <h3 class="text-sm font-medium text-blue-800">Mode hors ligne disponible</h3>
                  <div class="mt-1 text-sm text-blue-700">
                    Vous pourrez finaliser votre inscription plus tard. Vos données seront sauvegardées localement.
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { QrCode, Loader2, Check, Clock, Gift, Headphones ,Store, User, Shield, WifiOff} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const toast = useToast()
const router = useRouter()

const steps = [
  { name: 'Restaurant', icon: Store },
  { name: 'Profil', icon: User },
  { name: 'Sécurité', icon: Shield }
]
const currentStep = ref(0)

const loading = ref(false)
const form = reactive({
  restaurantName: '',
  address: '',
  fullName: '',
  email: '',
  password: '',
  acceptTerms: false
})

// Password strength calculation
const passwordStrength = computed(() => {
  const strength = []
  const password = form.password

  strength.push(password.length >= 8)
  strength.push(/[A-Z]/.test(password))
  strength.push(/[0-9]/.test(password))
  strength.push(/[^A-Za-z0-9]/.test(password))

  return strength
})

const nextStep = () => {
  if (currentStep.value < steps.length - 1) {
    currentStep.value++
  }
}

const handleSignup = async () => {
  loading.value = true
  try {
    // Vérifier la connexion
    if (!navigator.onLine) {
      // Sauvegarder les données localement
      localStorage.setItem('pendingRegistration', JSON.stringify({
        ...form,
        timestamp: Date.now()
      }))

      toast.warning(
        'Mode hors ligne', 
        'Vos données sont sauvegardées. Vous pourrez finaliser l\'inscription quand la connexion sera rétablie'
      )
      
      // Rediriger vers une page temporaire
      router.push('/offline-dashboard')
      return
    }

    // 1. Créer le compte utilisateur
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          full_name: form.fullName
        }
      }
    })

    if (authError) throw authError

    // 2. Créer l'établissement
    const { error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: form.restaurantName,
        owner_id: authData.user?.id
      })

    if (establishmentError) throw establishmentError

    toast.success('Succès', 'Votre compte a été créé')
    router.push('/login')
  } catch (error: any) {
    if (error.message?.includes('network')) {
      // Gestion spécifique des erreurs réseau
      toast.warning('Mode hors ligne', 'Tentative de sauvegarde locale')
      
      localStorage.setItem('pendingRegistration', JSON.stringify({
        ...form,
        timestamp: Date.now()
      }))

      router.push('/offline-dashboard')
    } else {
      toast.error('Erreur', error.message || 'Une erreur est survenue')
    }
  } finally {
    loading.value = false
  }
}

// Ajout des animations de transition
const slideTransition = {
  'enter-active-class': 'transition-all duration-300 ease-out',
  'enter-from-class': 'opacity-0 translate-x-4',
  'enter-to-class': 'opacity-100 translate-x-0',
  'leave-active-class': 'transition-all duration-300 ease-in',
  'leave-from-class': 'opacity-100 translate-x-0',
  'leave-to-class': 'opacity-0 -translate-x-4'
}
</script>

<style scoped>
/* Animations plus fluides */
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

/* Labels flottants améliorés */
.peer:placeholder-shown ~ label {
  cursor: text;
  top: 50%;
  transform: translateY(-50%);
}

.peer:focus ~ label {
  top: 0.5rem;
  transform: translateY(0);
  font-size: 0.875rem;
  color: #3B82F6;
}

/* Hover effects */
.input-group:hover .peer:not(:focus):not(:disabled) {
  border-color: #E5E7EB;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
  transition: all 0.2s ease;
  border-radius: 8px;
}

/* Animations des badges */
.trust-badge {
  transition: all 0.3s ease;
}

.trust-badge:hover {
  transform: translateY(-2px);
}
</style> 