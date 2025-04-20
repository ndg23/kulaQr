<template>
  <div class="min-h-screen bg-white flex items-center justify-center px-6">
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

      <!-- Title -->
      <h1 class="text-[32px] font-bold text-gray-900 mb-3">
        Créez votre compte
      </h1>
      <p class="text-xl text-gray-500 mb-10">
        Et commencez à digitaliser votre restaurant
      </p>

      <form @submit.prevent="handleSignup" class="space-y-5">
        <!-- Restaurant Name -->
        <div class="space-y-1">
          <div class="relative">
            <input
              v-model="form.restaurantName"
              type="text"
              id="restaurantName"
              required
              class="peer w-full h-14 px-4 pt-3 rounded-lg bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors text-lg"
              placeholder=" "
              :disabled="loading"
            />
            <label 
              for="restaurantName"
              class="absolute left-4 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-lg peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-1.5"
            >
              Nom du restaurant
            </label>
          </div>
        </div>

        <!-- Full Name -->
        <div class="space-y-1">
          <div class="relative">
            <input
              v-model="form.fullName"
              type="text"
              id="fullName"
              required
              class="peer w-full h-14 px-4 pt-3 rounded-lg bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors text-lg"
              placeholder=" "
              :disabled="loading"
            />
            <label 
              for="fullName"
              class="absolute left-4 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-lg peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-1.5"
            >
              Votre nom complet
            </label>
          </div>
        </div>

        <!-- Email -->
        <div class="space-y-1">
          <div class="relative">
            <input
              v-model="form.email"
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
              Email professionnel
            </label>
          </div>
        </div>

        <!-- Password -->
        <div class="space-y-1">
          <div class="relative">
            <input
              v-model="form.password"
              type="password"
              id="password"
              required
              class="peer w-full h-14 px-4 pt-3 rounded-lg bg-gray-50 border-2 border-gray-100 focus:border-blue-500 focus:ring-0 transition-colors text-lg"
              placeholder=" "
              :disabled="loading"
            />
            <label 
              for="password"
              class="absolute left-4 top-4 text-gray-400 text-sm transition-all peer-placeholder-shown:text-lg peer-placeholder-shown:top-4 peer-focus:text-sm peer-focus:top-1.5"
            >
              Mot de passe
            </label>
          </div>
        </div>

        <!-- Terms -->
        <div class="space-y-4">
          <div class="flex items-start">
            <div class="flex items-center h-5">
              <input
                v-model="form.acceptTerms"
                id="terms"
                type="checkbox"
                required
                class="w-4 h-4 rounded text-blue-500 focus:ring-blue-500"
                :disabled="loading"
              />
            </div>
            <div class="ml-3">
              <label for="terms" class="text-sm text-gray-500">
                J'accepte les <a href="#" class="text-blue-500 hover:text-blue-600">conditions d'utilisation</a>
                et la <a href="#" class="text-blue-500 hover:text-blue-600">politique de confidentialité</a>
              </label>
            </div>
          </div>
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full h-14 bg-gray-900 text-white rounded-lg hover:bg-gray-800 flex items-center justify-center font-semibold text-lg transition-colors disabled:opacity-50"
          :disabled="loading || !form.acceptTerms"
        >
          <template v-if="loading">
            <Loader2 class="w-6 h-6 animate-spin" />
          </template>
          <template v-else>
            Créer mon compte
          </template>
        </button>

        <p class="text-sm text-gray-500 text-center">
          En créant un compte, vous acceptez de recevoir des emails de notre part.
        </p>
      </form>

      <!-- Sign in link -->
      <p class="mt-8 text-center text-gray-600">
        Déjà un compte ?{' '}
        <NuxtLink 
          to="/login" 
          class="text-blue-500 hover:text-blue-600 font-semibold"
        >
          Se connecter
        </NuxtLink>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { QrCode, Loader2 } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const toast = useToast()
const router = useRouter()

const loading = ref(false)
const form = reactive({
  restaurantName: '',
  fullName: '',
  email: '',
  password: '',
  acceptTerms: false
})

const handleSignup = async () => {
  loading.value = true
  try {
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