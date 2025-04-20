<template>
  <div class="min-h-screen bg-white">
    <!-- Main Container -->
    <div class="flex min-h-screen">
      <!-- Left Image Panel (Hidden on Mobile) -->
      <div class="hidden lg:block lg:w-[60%] relative">
        <img
          src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"
          alt="Restaurant Ambiance"
          class="absolute inset-0 w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/50 to-transparent">
          <div class="absolute bottom-16 left-16 max-w-lg">
            <h1 class="text-6xl font-bold text-white mb-6">
              Gérez votre restaurant
            </h1>
            <p class="text-2xl text-white/90">
              Rejoignez plus de 2000 restaurants qui font confiance à KulaQr
            </p>
          </div>
        </div>
      </div>

      <!-- Right Login Panel -->
      <div class="w-full lg:w-[40%] px-6 lg:px-16 flex items-center">
        <div class="w-full max-w-md mx-auto py-16">
          <!-- Logo -->
          <div class="mb-12">
            <NuxtLink to="/" class="inline-flex items-center space-x-3">
              <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center">
                <QrCode class="w-7 h-7 text-white" />
              </div>
              <span class="text-3xl font-bold">KulaQr</span>
            </NuxtLink>
          </div>

          <!-- Title -->
          <h2 class="text-3xl font-bold text-gray-900 mb-8">
            Connectez-vous à<br/>votre compte
          </h2>

          <form @submit.prevent="handleLogin" class="space-y-5">
            <!-- Email -->
            <div class="space-y-1">
              <div class="relative">
                <input
                  v-model="email"
                  type="email"
                  id="email"
                  required
                  class="peer w-full h-14 px-4 pt-3 rounded-lg bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors text-lg"
                  placeholder=" "
                  :disabled="loading"
                />
                <label 
                  for="email"
                  class="absolute left-4 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-lg peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-1.5"
                >
                  Email
                </label>
              </div>
            </div>

            <!-- Password -->
            <div class="space-y-1">
              <div class="relative">
                <input
                  v-model="password"
                  type="password"
                  id="password"
                  required
                  class="peer w-full h-14 px-4 pt-3 rounded-lg bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors text-lg"
                  placeholder=" "
                  :disabled="loading"
                />
                <label 
                  for="password"
                  class="absolute left-4 top-3 text-gray-400 text-sm transition-all peer-placeholder-shown:text-lg peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-1.5"
                >
                  Mot de passe
                </label>
              </div>
              <div class="flex justify-end">
                <NuxtLink 
                  to="/forgot-password"
                  class="text-sm text-blue-500 hover:text-blue-600 font-medium"
                >
                  Mot de passe oublié ?
                </NuxtLink>
              </div>
            </div>

            <!-- Submit Button -->
            <button
              type="submit"
              class="w-full h-14 bg-gray-900 text-white rounded-lg hover:bg-gray-800 flex items-center justify-center font-semibold text-lg transition-colors disabled:opacity-50"
              :disabled="loading"
            >
              <template v-if="loading">
                <Loader2 class="w-6 h-6 animate-spin" />
              </template>
              <template v-else>
                Se connecter
              </template>
            </button>
          </form>

          <!-- Divider -->
          <div class="relative my-8">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-200"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-4 bg-white text-gray-500">ou</span>
            </div>
          </div>

          <!-- Social Login -->
          <div class="space-y-3">
            <button
              type="button"
              class="w-full h-14 border-2 border-gray-200 rounded-lg flex items-center justify-center space-x-3 hover:bg-gray-50 transition-colors"
            >

            <span class="font-medium">Continuer avec Google</span>
            </button>
          </div>

          <!-- Sign up link -->
          <p class="mt-8 text-center text-gray-600">
            Pas encore de compte ?{' '}
            <NuxtLink 
              to="/register" 
              class="text-blue-500 hover:text-blue-600 font-semibold"
            >
              Créer un compte
            </NuxtLink>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { QrCode, Loader2 } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const toast = useToast()
const router = useRouter()

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)

const handleLogin = async () => {
  loading.value = true
  try {
    const { error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })

    if (error) throw error

    // Rediriger vers le dashboard
    router.push('/manager')
    toast.success('Succès', 'Connexion réussie')
  } catch (error: any) {
    toast.error('Erreur', error.message || 'Une erreur est survenue')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Animation de fade-in */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

form {
  animation: fadeIn 0.6s ease-out;
}
</style> 