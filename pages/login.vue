<template>
  <div class="max-w-md mx-auto">
    <!-- Logo & Branding -->


    <!-- Title -->
    <h2 class="text-3xl font-bold text-gray-900 mb-1">Se connecter à KulaQr </h2>
    <p class="text-gray-500 mb-8">Accédez à votre espace restaurateur</p>

    <!-- Social Login -->
    <div class="space-y-3 mb-6">
      <button
        type="button"
        class="w-full h-12 bg-white border border-gray-300 rounded-full flex items-center justify-center space-x-3 hover:bg-gray-50 transition-all group shadow-sm"
      >
        <svg viewBox="0 0 24 24" width="24" height="24" class="text-gray-700">
          <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
          <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
          <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
          <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
        </svg>
        <span class="text-base font-medium text-gray-700">Continuer avec Google</span>
      </button>
    </div>

    <!-- Divider -->
    <div class="relative my-6">
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-gray-200"></div>
      </div>
      <div class="relative flex justify-center text-sm">
        <span class="px-4 bg-white text-gray-400 font-medium">ou</span>
      </div>
    </div>

    <form @submit.prevent="handleLogin" class="space-y-5">
      <!-- Email -->
      <div>
        <div class="relative">
          <input
            v-model="email"
            type="email"
            id="email"
            required
            class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white -50 border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
            placeholder="Email"
            :disabled="loading"
          />
          <label 
            for="email"
            class="absolute left-4 text-gray-500 transition-all duration-200 transform
            peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
            peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
            text-sm top-3 translate-y-0"
          >
            Adresse email
          </label>
        </div>
      </div>

      <!-- Password -->
      <div>
        <div class="relative">
          <input
            v-model="password"
            :type="showPassword ? 'text' : 'password'"
            id="password"
            required
            class="peer w-full h-14 px-4 pt-5 rounded-lg bg-white border-2 border-gray-200 focus:border-blue-500 focus:bg-white focus:ring-blue-100 focus:ring-4 transition-all text-base placeholder-transparent"
            placeholder="Mot de passe"
            :disabled="loading"
          />
          <label 
            for="password"
            class="absolute left-4 text-gray-500 transition-all duration-200 transform
            peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
            peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-blue-500
            text-sm top-3 translate-y-0"
          >
            Mot de passe
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
        <div class="flex justify-end mt-2">
          <NuxtLink 
            to="/forgot-password"
            class="text-sm text-blue-500 hover:text-blue-600 font-medium"
          >
            Mot de passe oublié ?
          </NuxtLink>
        </div>
      </div>

      <!-- Remember me -->
      <div class="flex items-center">
        <input 
          type="checkbox" 
          id="remember" 
          v-model="rememberMe"
          class="w-4 h-4 text-blue-500 border-gray-300 rounded focus:ring-blue-500"
        />
        <label for="remember" class="ml-2 text-sm text-gray-600">
          Rester connecté
        </label>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        class="w-full h-12 bg-black text-white rounded-full hover:bg-gray-800 flex items-center justify-center font-medium text-base transition-all disabled:opacity-50 focus:ring-4 focus:ring-gray-500/20"
        :disabled="loading"
      >
        <template v-if="loading">
          <Loader2 class="w-5 h-5 animate-spin mr-2" />
          Connexion en cours...
        </template>
        <template v-else>
          Se connecter
        </template>
      </button>
    </form>

    <!-- Sign up link -->
    <p class="mt-8 text-base text-center text-gray-600">
      Pas encore de compte ?{' '}
      <NuxtLink 
        to="/register" 
        class="text-blue-500 hover:text-blue-600 font-medium"
      >
        S'inscrire maintenant
      </NuxtLink>
    </p>

    <!-- Offline Mode Notice -->
    <div class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-500"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-blue-800">Mode hors ligne disponible</h3>
          <div class="mt-1 text-sm text-blue-700">
            RestauQR fonctionne même sans connexion internet stable.
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { QrCode, Loader2, Eye, EyeOff } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const toast = useToast()
const router = useRouter()

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)
const showPassword = ref(false)

const handleLogin = async () => {
  loading.value = true
  try {
    const { error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
      options: {
        // Utiliser le "remember me"
        expiresIn: rememberMe.value ? 30 * 24 * 60 * 60 : 24 * 60 * 60 // 30 jours ou 24 heures
      }
    })

    if (error) throw error

    // Rediriger vers le dashboard
    router.push('/manager')
    toast.success('Bienvenue !', 'Connexion réussie')
  } catch (error: any) {
    // Gérer différents types d'erreurs
    if (error.message?.includes('credentials')) {
      toast.error('Échec de connexion', 'Email ou mot de passe incorrect')
    } else if (error.message?.includes('network')) {
      // Mode hors ligne
      toast.warning('Mode hors ligne', 'Tentative de connexion locale')
      // Ici vous pourriez implémenter une logique de connexion hors ligne
      // avec des tokens stockés localement (cryptés)
      
      // Simulation pour la démo
      setTimeout(() => {
        router.push('/manager')
        toast.success('Mode hors ligne activé', 'Fonctionnalités limitées disponibles')
      }, 1500)
    } else {
      toast.error('Erreur', error.message || 'Une erreur est survenue')
    }
  } finally {
    loading.value = false
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
/* Animation du loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}

/* Effets de focus améliorés */
input:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.3);
}

/* Animation du hover des boutons */
button {
  transition: all 0.2s ease;
}

button:hover:not(:disabled) {
  transform: translateY(-1px);
}

button:active:not(:disabled) {
  transform: translateY(0);
}

/* Animation des inputs */
input {
  transition: all 0.2s ease;
}
</style>