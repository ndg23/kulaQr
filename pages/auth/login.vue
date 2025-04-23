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
          Bienvenue sur KulaQr
        </h1>
        <p class="text-lg text-gray-600">
          Connectez-vous pour gérer votre menu digital
        </p>
      </div>

      <!-- Alert de succès -->
      <TransitionHeight>
        <div 
          v-if="route.query.registered"
          class="mb-8 p-5 rounded-2xl bg-green-50 border border-green-100"
        >
          <div class="flex">
            <div class="flex-shrink-0">
              <CheckCircle class="w-6 h-6 text-green-500" />
            </div>
            <div class="ml-4">
              <h3 class="font-medium text-green-800">
                Compte créé avec succès !
              </h3>
              <div class="mt-2 text-sm text-green-700">
                Un email de confirmation a été envoyé à <strong>{{ route.query.email }}</strong>. 
                Veuillez vérifier votre boîte de réception pour activer votre compte.
              </div>
            </div>
          </div>
        </div>
      </TransitionHeight>

      <!-- Formulaire -->
      <div class="space-y-6">
        <!-- Google Login -->
        <button 
          type="button"
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

        <form @submit.prevent="handleLogin" class="space-y-4">
          <!-- Error Message -->
          <FormError :message="error" />

          <FormInput
            v-model="email"
            type="email"
            label="Adresse email"
            required
            :disabled="loading"
          />

          <FormInput
            v-model="password"
            :type="showPassword ? 'text' : 'password'"
            label="Mot de passe"
            required
            :disabled="loading"
          >
            <template #append>
              <button 
                type="button"
                @click="togglePassword"
                class="text-gray-400 hover:text-gray-600"
              >
                <Eye v-if="showPassword" class="w-5 h-5" />
                <EyeOff v-else class="w-5 h-5" />
              </button>
            </template>
          </FormInput>

          <!-- Remember me & Forgot password -->
          <div class="flex items-center justify-between">
            <label class="flex items-center">
              <input
                v-model="rememberMe"
                type="checkbox"
                class="w-4 h-4 rounded border-gray-300 text-facebook focus:ring-facebook"
              />
              <span class="ml-2 text-sm text-gray-600">Se souvenir de moi</span>
            </label>
            <NuxtLink 
              to="/auth/forgot-password"
              class="text-sm text-facebook hover:text-facebook/80 transition-colors"
            >
              Mot de passe oublié ?
            </NuxtLink>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            class="w-full h-14 bg-facebook text-white rounded-xl font-medium hover:bg-facebook-dark transition-all disabled:opacity-50 disabled:cursor-not-allowed relative"
            :disabled="loading"
          >
            <span v-if="loading" class="absolute inset-0 flex items-center justify-center">
              <Loader2 class="w-5 h-5 animate-spin" />
            </span>
            <span :class="{ invisible: loading }">
              Se connecter
            </span>
          </button>
        </form>

        <!-- Sign up link -->
        <p class="pt-6 text-center text-gray-600">
          Pas encore inscrit ?{' '}
          <NuxtLink 
            to="/auth/register" 
            class="text-facebook hover:text-facebook/80 font-semibold transition-colors"
          >
            Créer un compte
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Eye, EyeOff, Loader2, CheckCircle } from 'lucide-vue-next'
import FormError from '~/components/ui/FormError.vue'
import FormInput from '~/components/ui/FormInput.vue'

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
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
  if (route.query.error === 'callback') {
    error.value = 'Erreur lors de la connexion avec Google'
  }
})

definePageMeta({
  layout: 'auth'
})
</script>

<style scoped>
.TransitionHeight-enter-active,
.TransitionHeight-leave-active {
  transition: all 0.3s ease-out;
  max-height: 300px;
  opacity: 1;
}

.TransitionHeight-enter-from,
.TransitionHeight-leave-to {
  max-height: 0;
  opacity: 0;
  margin: 0;
}

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