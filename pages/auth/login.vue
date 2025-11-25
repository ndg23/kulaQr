<template>
 <div class="min-h-screen bg-white flex items-start sm:items-center justify-center p-4 sm:p-6 overflow-y-auto">
    <div class="w-full max-w-[400px] py-4 sm:py-0">
      <!-- Success Alert -->
      <transition
        enter-active-class="transition-all duration-300 ease-out"
        enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition-all duration-200 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-2"
      >
        <div 
          v-if="route.query.registered"
          class="mb-6 p-4 rounded-xl bg-green-50 border border-green-200"
        >
          <div class="flex items-start gap-3">
            <CheckCircle class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
            <p class="text-sm text-green-900 font-medium">
              Compte créé avec succès ! Un email de confirmation a été envoyé à 
              <span class="font-semibold">{{ route.query.email }}</span>
            </p>
          </div>
        </div>
      </transition>

      <!-- Logo / Icon -->
      <!-- <div class="mb-8">
        <div class="w-12 h-12 bg-black rounded-xl flex items-center justify-center">
          <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/>
          </svg>
        </div>
      </div> -->

      <!-- Header -->
      <div class="text-center space-y-3 mb-10 w-full mx-auto">
        <h1 class="text-3xl md:text-5xl font-black tracking-tight text-gray-900">
          Bon retour
        </h1>
        <p class="text-md md:text-lg text-gray-500 font-light-">
          Connectez-vous à votre compte
        </p>
      </div>

      <!-- Main Form -->
      <div class="space-y-3 max-w-full ">
        <!-- Google Sign In -->
        <button 
          type="button"
          @click="signInWithGoogle"
          class="w-full h-[52px] bg-white border border-gray-300 rounded-xl font-bold text-[15px] flex items-center justify-center hover:bg-gray-50 transition-colors duration-200"
        >
          <svg class="w-[18px] h-[18px] mr-2" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          <span class="text-gray-900">
            Continuer avec Google
          </span>
        </button>

        <!-- Divider -->
        <div class="relative my-4">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
          </div>
          <div class="relative flex justify-center">
            <span class="px-2 bg-white text-[15px] text-gray-500">ou</span>
          </div>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="space-y-5 w-full ">
          <!-- Error Message -->
          <transition
            enter-active-class="transition-all duration-200 ease-out"
            enter-from-class="opacity-0 scale-95"
            enter-to-class="opacity-100 scale-100"
            leave-active-class="transition-all duration-150 ease-in"
            leave-from-class="opacity-100 scale-100"
            leave-to-class="opacity-0 scale-95"
          >
            <div 
              v-if="error"
              class="p-4 rounded-xl bg-red-50 border border-red-200"
            >
              <p class="text-sm text-red-900 font-medium">{{ error }}</p>
            </div>
          </transition>

          <!-- Email Input -->
          <div>
            <input
              v-model="email"
              type="email"
              id="email"
              required
              :disabled="loading"
              placeholder="Adresse e-mail"
              class="w-full h-[56px] px-4 bg-white border border-gray-300 rounded-xl text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-1 focus:ring-red-500 transition-all duration-200 disabled:opacity-50 disabled:bg-gray-50"
            />
          </div>

          <!-- Password Input -->
          <div class="relative">
            <input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              id="password"
              required
              :disabled="loading"
              placeholder="Mot de passe"
              class="w-full h-[56px] px-4 pr-12 bg-white border border-gray-300 rounded-xl text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-1 focus:ring-red-500 transition-all duration-200 disabled:opacity-50 disabled:bg-gray-50"
            />
            <button 
              type="button"
              @click="showPassword = !showPassword"
              :disabled="loading"
              class="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-gray-500 hover:text-gray-900 transition-colors disabled:opacity-50"
            >
              <Eye v-if="showPassword" class="w-5 h-5" />
              <EyeOff v-else class="w-5 h-5" />
            </button>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            class="w-full h-[52px] bg-black text-white rounded-xl text-[17px] font-bold hover:bg-gray-800 active:scale-[0.97] transition-all duration-200 flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-black disabled:active:scale-100"
            :disabled="loading"
          >
            <span v-if="!loading">Suivant</span>
            <Loader2 v-else class="w-5 h-5 animate-spin" />
          </button>

          <!-- Forgot Password Link -->
          <button
            type="button"
            @click="navigateTo('/auth/forgot-password')"
            class="w-full h-[52px] bg-white border border-gray-300 rounded-xl text-[17px] font-bold text-gray-900 hover:bg-gray-50 transition-colors duration-200"
          >
            Mot de passe oublié ?
          </button>
        </form>

        <!-- Sign Up Section -->
        <div class="mt-10 pt-5 border-t border-gray-300">
          <p class="text-[17px] text-gray-600">
            Vous n'avez pas de compte ?
            <NuxtLink 
              to="/auth/register" 
              class="text-blue-500 hover:underline font-normal ml-1"
            >
              S'inscrire
            </NuxtLink>
          </p>
        </div>
      </div>

      <!-- Staff PIN Login -->
      <div class="mt-8 pt-6 border-t border-gray-200">
        <NuxtLink 
          to="/auth/pin"
          class="flex items-center justify-center gap-2 text-[15px] text-gray-600 hover:text-gray-900 transition-colors"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
          </svg>
          <span class="font-medium">Connexion personnel (PIN)</span>
        </NuxtLink>
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

    // Vérifier si l'utilisateur est actif
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('is_active, full_name')
      .eq('id', data.user.id)
      .single()
    
    if (userError || !userData) {
      error.value = 'Erreur lors de la vérification du compte'
      return
    }

    // Si le compte est inactif, déconnecter et rediriger vers la page d'attente
    if (!userData.is_active) {
      await supabase.auth.signOut()
      navigateTo('/auth/pending-activation?name=' + encodeURIComponent(userData.full_name || ''))
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
    
if (data.user.role && data.user.role === 'admin') {
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