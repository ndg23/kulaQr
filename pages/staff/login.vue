<template>
  <div class="min-h-dvh bg-white flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <img src="~/assets/icon/logo.png" alt="Logo" class="mx-auto h-12 w-auto" />
      <h2 class="mt-6 text-center text-3xl font-black tracking-tight text-gray-900">Connexion serveur</h2>
      <p class="mt-2 text-center text-sm font-semibold text-gray-500">Entrez votre code PIN</p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <form class="space-y-4 px-2 sm:px-10" @submit.prevent="login">
        <label for="pin" class="sr-only">Code PIN</label>
        <input
          id="pin"
          v-model="pin"
          type="password"
          inputmode="numeric"
          pattern="[0-9]*"
          maxlength="4"
          required
          autocomplete="off"
          class="block w-full h-16 rounded-full bg-gray-100 border-2 border-transparent text-center text-3xl font-black tracking-[0.5em] focus:outline-none focus:border-[#FB6A00]"
        />
        <button
          type="submit"
          :disabled="loading"
          class="w-full h-14 flex items-center justify-center gap-2 rounded-full bg-[#FB6A00] text-black text-[17px] font-black hover:bg-[#FD9542] active:scale-[0.97] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="loading" class="inline-block h-5 w-5 border-2 border-black border-t-transparent rounded-full animate-spin"></span>
          Connexion
        </button>
      </form>
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