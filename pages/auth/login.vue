<template>
  <div class="min-h-screen bg-white my-20 lg:p-5 items- center ju stify-center">
    <!-- Main Content -->
    <div class="max-w-md mx-auto items-cen ter jus tify-center px-6 pt-24 pb-16 flex flex-col min-h-screen">
      <!-- Logo centered at top -->
      <!-- <div class="mb-10 text-center">
        <img src="~/assets/icon/logo.png" alt="Logo" class="h-12 mx-auto" />
      </div> -->

      <!-- Titre principal -->
      <h1 class="text-3xl font-bold text-gray-900 mb-2 text-center">
       Se connecter à Kula <span class="text-kula-500 font-bold- font-black">Qr</span>
      </h1>

      <!-- Alert de succès -->
      <TransitionHeight>
        <div 
          v-if="route.query.registered"
          class="my-6 p-4 rounded-lg bg-green-50 border border-green-100"
        >
          <div class="flex">
            <div class="flex-shrink-0">
              <CheckCircle class="w-5 h-5 text-green-500" />
            </div>
            <div class="ml-3">
              <p class="text-sm text-green-800 font-medium">
                Compte créé avec succès ! Un email de confirmation a été envoyé à <strong>{{ route.query.email }}</strong>.
              </p>
            </div>
          </div>
        </div>
      </TransitionHeight>

      <!-- Formulaire -->
      <div class="space-y-5 mt-6">
        <!-- Google Login -->
        <button 
          type="button"
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

        <div class="flex items-center my-4">
          <div class="flex-grow h-px bg-gray-200"></div>
          <span class="px-4 text-sm text-gray-500">ou</span>
          <div class="flex-grow h-px bg-gray-200"></div>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">
          <!-- Error Message -->
          <FormError :message="error" />

          <!-- Email input with floating label -->
          <div class="relative">
            <FloatLabelInput
              v-model="email"
              type="email"
              label="Adresse email"
              required
              :disabled="loading"
            />
          </div>

          <!-- Password input with floating label -->
          <div class="relative">
            <FloatLabelInput
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
                  class="text-gray-400 hover:text-gray-700"
                >
                  <Eye v-if="showPassword" class="w-5 h-5" />
                  <EyeOff v-else class="w-5 h-5" />
                </button>
              </template>
            </FloatLabelInput>
          </div>

          <!-- Remember me & Forgot password -->
          <div class="flex items-center justify-between">
            <label class="flex items-center">
              <input
                v-model="rememberMe"
                type="checkbox"
                class="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500"
              />
              <span class="ml-2 text-sm text-gray-600">Se souvenir de moi</span>
            </label>
            <NuxtLink 
              to="/auth/forgot-password"
              class="text-sm text-blue-500 hover:text-blue-600 transition-colors"
            >
              Mot de passe oublié ?
            </NuxtLink>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            class="w-full h-12 bg-kula-500 text-white rounded-full font-medium hover:bg-kula-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed relative"
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
            class="text-blue-500 hover:text-blue-600 font-medium transition-colors"
          >
            Créer un compte
          </NuxtLink>
        </p>

        <!-- Ajouter ce lien à la fin du formulaire -->
        <!-- <div class="text-center mt-4">
          <NuxtLink to="/auth/pin" class="text-sm font-medium text-kula-500 hover:text-kula-600">
            Connexion serveur avec PIN
          </NuxtLink>
        </div> -->

        <!-- Ajouter ce lien dans votre page de connexion -->
        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            Vous êtes membre du personnel ?
            <NuxtLink to="/auth/pin" class="font-medium text-kula-600 hover:text-kula-500">
              Connexion par PIN
            </NuxtLink>
          </p>
        </div>
      </div>

      <!-- Spacer to push footer content down -->
      <div class="flex-grow"></div>

      <!-- Footer with subtle branding -->
      <div class="text-center text-xs text-gray-400 mt-10">
        © {{ new Date().getFullYear() }} Kula Qr. Tous droits réservés.
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
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

const togglePassword = () => {
  showPassword.value = !showPassword.value
}

// Vérifier si on vient d'une erreur de callback
onMounted(() => {
  if (route.query.error === 'callback') {
    const message = route.query.message ? decodeURIComponent(route.query.message as string) : 'Erreur lors de la connexion avec Google'
    error.value = message
    console.error('❌ Erreur de callback reçue:', message)
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

/* Animation du loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>