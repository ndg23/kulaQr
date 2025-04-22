<template>
  <div class="bg-white rounded-2xl mx-auto max-w-lg w-full p-8">
    <!-- Logo -->
    <div class="flex justify-center mb-">
      <img src="~/assets/icon/logo.png" alt="Logo" class="w-[100px] h-[100px]" />
    </div>

    <!-- Title -->
    <h1 class="text-3xl font-extrabold text-center mb-1">Se connecter à KulaQr</h1>
    <p class="text-gray-500 text-center mb-8">Gérez votre menu de restaurant en quelques clics</p>

    <!-- Social Login -->
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
      <span class="px-4 text-gray-700 font-medium text-sm">ou connexion manuelle</span>
      <div class="flex-grow border-t border-gray-200"></div>
    </div>

    <!-- Form -->
    <form @submit.prevent="handleLogin" class="space-y-4">
      <!-- Error Message -->
      <FormError :message="error" />

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
          Adresse email
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

      <!-- Remember Me -->
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <input
            id="remember-me"
            type="checkbox"
            v-model="rememberMe"
            class="w-4 h-4 text-facebook border-gray-300 rounded focus:ring-facebook"
          />
          <label for="remember-me" class="ml-2 block text-sm text-gray-700">
            Se souvenir de moi
          </label>
        </div>
        <NuxtLink 
          to="/auth/forgot-password"
          class="text-sm font-medium text-facebook hover:text-facebook/80"
        >
          Mot de passe oublié ?
        </NuxtLink>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        class="w-full h-14 bg-facebook text-white rounded-full hover:bg-facebook-dark flex items-center justify-center font-bold text-base transition-all hover-scale disabled:opacity-50 focus:ring-4 focus:ring-facebook/20 mt-6"
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
      Pas encore inscrit ?{' '}
      <NuxtLink 
        to="/auth/register" 
        class="text-facebook hover:text-facebook/80 font-bold transition-colors"
      >
        Créer un compte
      </NuxtLink>
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Eye, EyeOff, Loader2 } from 'lucide-vue-next'
import FormError from '~/components/ui/FormError.vue'

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)
const showPassword = ref(false)
const error = ref('')
const supabase = useSupabaseClient()

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

    // Rediriger vers le dashboard avec le slug de l'établissement
    navigateTo(`/manager/${establishment.slug}/menu`)
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

const togglePassword = () => {
  showPassword.value = !showPassword.value
}

// Vérifier si on vient d'une erreur de callback
onMounted(() => {
  const route = useRoute()
  if (route.query.error === 'callback') {
    error.value = 'Erreur lors de la connexion avec Google'
  }
})

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