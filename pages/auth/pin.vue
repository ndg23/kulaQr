<template>
  <div class="min-h-screen bg-white flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <img src="~/assets/icon/logo.png" alt="Logo" class="mx-auto h-12 w-auto" />
      <h2 class="mt-6 text-center text-2xl font-bold text-gray-900">
        Connexion du personnel
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow-sm sm:rounded-lg sm:px-10">
        <!-- Error message -->
        <div 
          v-if="error" 
          class="mb-6 p-3 bg-red-50 border border-red-100 text-red-700 text-sm rounded-md"
        >
          {{ error }}
        </div>

        <form @submit.prevent="login" class="space-y-6">
          <!-- Username Input -->
          <div>
            <FloatLabelInput
              id="username"
              v-model="username"
              type="text"
              
              required
              label="Identifiant"
           
            />
          </div>

          <!-- PIN Input -->
          <div>
            <div class="flex justify-between space-x-2">
              <input
                v-for="(digit, index) in pinDigits"
                :key="index"
                :ref="el => { if (el) pinInputs[index] = el }"
                v-model="pinDigits[index]"
                type="password"
                inputmode="numeric"
                maxlength="1"
                class="block w-1/4 h-12 text-center text-xl font-medium border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-black focus:border-black"
                @input="onPinDigitInput(index)"
                @keydown="onPinDigitKeydown($event, index)"
                @focus="$event.target.select()"
              />
            </div>
            <p class="mt-2 text-xs text-gray-500 text-center">Entrez votre code PIN à 4 chiffres</p>
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading || !isPinComplete || !username"
              class="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-black hover:bg-gray-800 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="loading" class="inline-block h-5 w-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></span>
              <span>Se connecter</span>
            </button>
          </div>
          
          <div class="text-center mt-4">
            <NuxtLink to="/auth/login" class="text-sm text-gray-600 hover:text-gray-900">
              Retour à la connexion classique
            </NuxtLink>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { useRouter } from 'vue-router'
import FormInput from '~/components/ui/FormInput.vue'
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const router = useRouter()

// State
const pinDigits = ref(['', '', '', ''])
const pinInputs = ref([])
const loading = ref(false)
const error = ref('')
const username = ref('')

// Computed
const isPinComplete = computed(() => {
  return pinDigits.value.every(digit => digit !== '')
})

const pin = computed(() => {
  return pinDigits.value.join('')
})

// Methods
const onPinDigitInput = (index) => {
  // Force numeric input
  pinDigits.value[index] = pinDigits.value[index].replace(/[^0-9]/g, '')
  
  // Move to next input
  if (pinDigits.value[index] && index < 3) {
    pinInputs.value[index + 1].focus()
  } else if (index === 3 && isPinComplete.value && username.value) {
    // If last digit is entered and form is complete, submit
    login()
  }
}

const onPinDigitKeydown = (event, index) => {
  // Handle backspace
  if (event.key === 'Backspace' && !pinDigits.value[index] && index > 0) {
    pinDigits.value[index - 1] = ''
    pinInputs.value[index - 1].focus()
  }
  
  // Handle left/right arrows
  if (event.key === 'ArrowLeft' && index > 0) {
    pinInputs.value[index - 1].focus()
  }
  
  if (event.key === 'ArrowRight' && index < 3) {
    pinInputs.value[index + 1].focus()
  }
}

// Login with username and PIN
const login = async () => {
  if (!isPinComplete.value || !username.value) return
  
  loading.value = true
  error.value = ''
  
  try {
    // Check if username and PIN are valid
    const { data, error: err } = await supabase
      .from('staff')
      .select('*')
      .eq('pin', pin.value)
      .eq('username', username.value)
      .eq('is_active', true)
      .single()
    
    if (err) {
      if (err.code === 'PGRST116') {
        error.value = 'Identifiant ou code PIN incorrect'
      } else {
        throw err
      }
      return
    }
    
    if (!data) {
      error.value = 'Identifiant ou code PIN incorrect'
      return
    }
    
    // Create a session for the staff member
    const sessionData = {
      staff_id: data.id,
      username: data.username,
      role: data.role,
      establishment_id: data.establishment_id,
      auth_type: 'pin'
    }
    
    // Store session in localStorage
    localStorage.setItem('staff_session', JSON.stringify(sessionData))
    
    // Log activity
    // await supabase.from('staff_activity_logs').insert({
    //   staff_id: data.id,
    //   action: 'login',
    //   details: { method: 'pin' }
    // }).catch(e => console.error('Error logging activity:', e))
    
    // Update last login
    await supabase
      .from('staff')
      .update({ last_login: new Date().toISOString() })
      .eq('id', data.id)
    
    // Redirect based on role
    let redirectPath = '/staff'
    if (data.role === 'waiter') {
      redirectPath = '/staff/orders'
    } else if (data.role === 'kitchen') {
      redirectPath = '/staff/kitchen'
    } else if (data.role === 'manager') {
      redirectPath = `/manager/${data.establishment_id}/dashboard`
    }
    
    showToast.success('Connexion réussie', `Bienvenue, ${data.username}`)
    router.push(redirectPath)
    
  } catch (err) {
    console.error('Error logging in:', err)
    error.value = 'Une erreur est survenue lors de la connexion'
  } finally {
    loading.value = false
  }
}

// Focus username input on mount
onMounted(() => {
  setTimeout(() => {
    const usernameInput = document.getElementById('username')
    if (usernameInput) {
      usernameInput.focus()
    }
  }, 100)
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