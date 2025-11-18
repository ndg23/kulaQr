<template>
  <div class="min-h-screen  flex items-center justify-center p-4">
    <div class="w-full max-w-[480px]">
      <!-- Success Alert -->
      <transition
        enter-active-class="transition-all duration-500 ease-out"
        enter-from-class="opacity-0 -translate-y-4"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition-all duration-300 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-4"
      >
        <div 
          v-if="route.query.registered"
          class="mb-8 p-4 rounded-2xl bg-green-50 border border-green-100"
        >
          <div class="flex items-start">
            <CheckCircle class="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
            <div class="ml-3">
              <p class="text-sm text-green-800 font-medium">
                Compte créé avec succès ! Un email de confirmation a été envoyé à 
                <span class="font-semibold">{{ route.query.email }}</span>
              </p>
            </div>
          </div>
        </div>
      </transition>

      <!-- Header -->
      <div class="text-center space-y-3 mb-10">
        <h1 class="text-3xl md:text-5xl font-black tracking-tight text-gray-900">
          Bon retour
        </h1>
        <p class="text-md md:text-lg text-gray-500 font-light-">
          Connectez-vous à votre compte
        </p>
      </div>

      <!-- Main Form -->
      <div class="space-y-10">
        <!-- Google Sign In -->
        <button 
          type="button"
          @click="signInWithGoogle"
          class="group w-full h-14 bg-white border border-gray-200 rounded-2xl font-medium flex items-center justify-center hover:border-gray-300 hover:shadow-sm transition-all duration-200"
        >
          <svg class="w-5 h-5 mr-3" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          <span class="text-gray-700 group-hover:text-gray-900 transition-colors">
            Continuer avec Google
          </span>
        </button>

        <!-- Divider -->
        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-200"></div>
          </div>
          <div class="relative flex justify-center">
            <span class="px-4 bg-gradient-to-b from-white to-gray-50 text-sm text-gray-400">ou</span>
          </div>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="space-y-5">
          <!-- Error Message -->
          <transition
            enter-active-class="transition-all duration-300 ease-out"
            enter-from-class="opacity-0 scale-95"
            enter-to-class="opacity-100 scale-100"
            leave-active-class="transition-all duration-200 ease-in"
            leave-from-class="opacity-100 scale-100"
            leave-to-class="opacity-0 scale-95"
          >
            <div 
              v-if="error"
              class="p-4 rounded-2xl bg-red-50 border border-red-100"
            >
              <p class="text-sm text-red-800 font-medium">{{ error }}</p>
            </div>
          </transition>

          <!-- Email Float Input -->
          <div class="relative">
            <input
              v-model="email"
              type="email"
              id="email"
              required
              :disabled="loading"
              class="peer w-full h-14 px-4 pt-6 pb-2 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              placeholder=" "
            />
            <label
              for="email"
              class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                     peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                     peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
            >
              Adresse email
            </label>
          </div>

          <!-- Password Float Input -->
          <div class="relative">
            <input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              id="password"
              required
              :disabled="loading"
              class="peer w-full h-14 px-4 pt-6 pb-2 pr-12 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              placeholder=" "
            />
            <label
              for="password"
              class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                     peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                     peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
            >
              Mot de passe
            </label>
            <button 
              type="button"
              @click="showPassword = !showPassword"
              :disabled="loading"
              class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors disabled:opacity-50"
            >
              <Eye v-if="showPassword" class="w-5 h-5" />
              <EyeOff v-else class="w-5 h-5" />
            </button>
          </div>

          <!-- Forgot Password Link -->
          <div class="flex justify-end">
            <NuxtLink 
              to="/auth/forgot-password"
              class="text-sm text-kula-500 hover:text-kula-600 font-medium transition-colors"
            >
              Mot de passe oublié ?
            </NuxtLink>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            class="group w-full h-14 bg-kula-500 text-white rounded-3xl font-medium hover:bg-kula-600 active:scale-[0.98] transition-all duration-200 flex items-center justify-center  disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-kula-500 disabled:active:scale-100"
            :disabled="loading"
          >
            <span v-if="!loading" class="flex items-center">
              <span>Se connecter</span>
              <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
              </svg>
            </span>
            <span v-else class="flex items-center">
              <Loader2 class="w-5 h-5 animate-spin" />
            </span>
          </button>
        </form>

        <!-- Sign Up Link -->
        <div class="text-center pt-1">
          <p class="text-md md:text-lg text-gray-800">
            Pas encore inscrit ?
            <NuxtLink 
              to="/auth/register" 
              class="text-kula-500 font-medium hover:text-kula-600 transition-colors ml-1"
            >
              Créer un compte
            </NuxtLink>
          </p>
        </div>

        <!-- Staff PIN Login -->
        <div class="pt">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-200"></div>
            </div>
            <div class="relative flex justify-center">
              <span class="px-4 bg-gradient-to-b from-white to-gray-50 text-sm text-gray-400">Personnel</span>
            </div>
          </div>
        </div>

        <NuxtLink 
          to="/auth/pin"
          class="group w-full h-14 bg-white border border-gray-200 rounded-2xl font-medium flex items-center justify-center hover:border-gray-300 hover:shadow-sm transition-all duration-200"
        >
          <svg class="w-5 h-5 mr-3 text-gray-500 group-hover:text-gray-700 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
          </svg>
          <span class="text-gray-700 group-hover:text-gray-900 transition-colors">
            Connexion par PIN
          </span>
        </NuxtLink>
      </div>

      <!-- Footer -->
      <div class="mt-12 text-center">
        <p class="text-xs text-gray-400 leading-relaxed">
          En continuant, vous acceptez nos
          <NuxtLink to="/terms" class="text-gray-500 hover:text-gray-700 transition-colors">Conditions</NuxtLink>
          et notre
          <NuxtLink to="/privacy" class="text-gray-500 hover:text-gray-700 transition-colors">Politique de confidentialité</NuxtLink>
        </p>
        <p class="text-xs text-gray-400 mt-4">
          © {{ new Date().getFullYear() }} Kula Qr. Tous droits réservés.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Eye, EyeOff, Loader2, CheckCircle } from 'lucide-vue-next'

const email = ref('')
const password = ref('')
const loading = ref(false)
const showPassword = ref(false)
const error = ref('')
const supabase = useSupabaseClient()
const route = useRoute()

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })
    
    if (authError) {
      error.value = authError.message === 'Invalid login credentials'
        ? 'Email ou mot de passe incorrect'
        : 'Une erreur est survenue lors de la connexion'
      return
    }

    // Récupérer l'établissement de l'utilisateur
    const { data: establishment, error: establishmentError } = await supabase
      .from('establishments')
      .select('id, slug')
      .eq('user_id', data.user.id)
      .single()

    if (establishmentError) {
      error.value = 'Erreur lors de la récupération des données'
      return
    }
    
    if (!establishment) {
      error.value = "Aucun établissement trouvé pour cet utilisateur"
      return
    }
    
    if (!!data.user.role || data.user.role !== 'manager') {
      navigateTo(`/admin`)
    }

    // Rediriger vers le dashboard avec le slug de l'établissement
    navigateTo(`/manager/${establishment?.id}`)
  } catch (err) {
    error.value = 'Une erreur inattendue est survenue'
  } finally {
    loading.value = false
  }
}

const signInWithGoogle = async () => {
  try {
    const { error: authError } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    })
    if (authError) {
      error.value = 'Erreur de connexion avec Google'
    }
  } catch (err) {
    error.value = 'Une erreur inattendue est survenue'
  }
}

// Vérifier si on vient d'une erreur de callback
onMounted(() => {
  if (route.query.error === 'callback') {
    const message = route.query.message 
      ? decodeURIComponent(route.query.message as string) 
      : 'Erreur lors de la connexion avec Google'
    error.value = message
    console.error('❌ Erreur de callback reçue:', message)
  }
})

definePageMeta({
  layout: 'auth'
})
</script>

<style scoped>
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>