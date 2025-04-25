<template>
  <div class="min-h-screen bg-gray-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Connexion Serveur
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <form class="space-y-6" @submit.prevent="login">
          <div>
            <label for="pin" class="block text-sm font-medium text-gray-700">
              Code PIN
            </label>
            <div class="mt-1">
              <input
                id="pin"
                v-model="pin"
                type="password"
                inputmode="numeric"
                pattern="[0-9]*"
                maxlength="4"
                required
                class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 text-center text-2xl"
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading"
              class="w-full flex justify-center py-4 px-4 border border-transparent rounded-md shadow-sm text-lg font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <span v-if="loading">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              </span>
              Connexion
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const router = useRouter()

const pin = ref('')
const loading = ref(false)

const login = async () => {
  if (pin.value.length !== 4) {
    showToast.error('Erreur', 'Le code PIN doit contenir 4 chiffres')
    return
  }

  loading.value = true

  try {
    // Vérifier le PIN dans la table staff_pins
    const { data, error } = await supabase
      .from('staff_pins')
      .select('user_id, establishment_id')
      .eq('pin', pin.value)
      .eq('is_active', true)
      .single()

    if (error) throw error

    if (!data) {
      showToast.error('Erreur', 'Code PIN invalide')
      return
    }

    // Connecter l'utilisateur avec son ID
    const { error: authError } = await supabase.auth.signIn({
      user_id: data.user_id
    }, {
      redirectTo: `/staff/${data.establishment_id}`
    })

    if (authError) throw authError

    router.push(`/staff/${data.establishment_id}`)
  } catch (error) {
    console.error('Erreur de connexion:', error)
    showToast.error('Erreur', 'Impossible de se connecter')
  } finally {
    loading.value = false
  }
}
</script> 