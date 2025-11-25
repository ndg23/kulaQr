<template>
  <TransitionRoot appear :show="isOpen" as="template">
    <Dialog as="div" @close="closeModal" class="relative z-50">
      <!-- Overlay -->
      <TransitionChild
        enter="duration-300 ease-out"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="duration-200 ease-in"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
      </TransitionChild>

      <!-- Modal -->
      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4">
          <TransitionChild
            enter="duration-300 ease-out"
            enter-from="opacity-0 scale-95"
            enter-to="opacity-100 scale-100"
            leave="duration-200 ease-in"
            leave-from="opacity-100 scale-100"
            leave-to="opacity-0 scale-95"
          >
            <DialogPanel class="w-full max-w-2xl transform overflow-hidden rounded-2xl bg-white shadow-2xl transition-all">
              <!-- Header -->
              <div class="border-b border-gray-200 px-6 py-4">
                <div class="flex items-center justify-between">
                  <DialogTitle class="text-xl font-bold text-gray-900">
                    Créer un Manager avec son Établissement
                  </DialogTitle>
                  <button
                    @click="closeModal"
                    class="p-2 rounded-full hover:bg-gray-100 transition-colors"
                  >
                    <X class="w-5 h-5 text-gray-500" />
                  </button>
                </div>
                <p class="text-sm text-gray-600 mt-1">
                  Créez un compte manager et son établissement en une seule étape
                </p>
              </div>

              <!-- Content -->
              <form @submit.prevent="handleSubmit" class="px-6 py-6">
                <!-- Step Indicator -->
                <div class="flex items-center justify-center mb-8">
                  <div class="flex items-center gap-4">
                    <div class="flex items-center gap-2">
                      <div 
                        class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-all"
                        :class="currentStep >= 1 ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-500'"
                      >
                        1
                      </div>
                      <span class="text-sm font-medium" :class="currentStep >= 1 ? 'text-gray-900' : 'text-gray-500'">
                        Manager
                      </span>
                    </div>
                    <div class="w-12 h-0.5" :class="currentStep >= 2 ? 'bg-blue-600' : 'bg-gray-200'" />
                    <div class="flex items-center gap-2">
                      <div 
                        class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-all"
                        :class="currentStep >= 2 ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-500'"
                      >
                        2
                      </div>
                      <span class="text-sm font-medium" :class="currentStep >= 2 ? 'text-gray-900' : 'text-gray-500'">
                        Établissement
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Step 1: Manager Info -->
                <div v-if="currentStep === 1" class="space-y-5">
                  <div class="bg-blue-50 border border-blue-200 rounded-xl p-4">
                    <div class="flex items-start gap-3">
                      <User class="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h3 class="font-semibold text-blue-900">Informations du Manager</h3>
                        <p class="text-sm text-blue-700 mt-1">
                          Ces informations seront utilisées pour créer le compte du manager
                        </p>
                      </div>
                    </div>
                  </div>

                  <FloatLabelInput
                    id="manager-full-name"
                    v-model="managerForm.full_name"
                    label="Nom complet"
                    type="text"
                    :required="true"
                    :error="errors.full_name"
                  />
                  
                  <FloatLabelInput
                    id="manager-email"
                    v-model="managerForm.email"
                    label="Email"
                    type="email"
                    :required="true"
                    :error="errors.email"
                  />
                  
                  <FloatLabelInput
                    id="manager-phone"
                    v-model="managerForm.phone"
                    label="Téléphone"
                    type="tel"
                    :error="errors.phone"
                  />
                  
                  <FloatLabelInput
                    id="manager-password"
                    v-model="managerForm.password"
                    label="Mot de passe"
                    type="password"
                    :required="true"
                    :error="errors.password"
                  />
                  
                  <div class="text-xs text-gray-500 flex items-start gap-2 bg-gray-50 p-3 rounded-lg">
                    <AlertCircle class="w-4 h-4 mt-0.5 flex-shrink-0" />
                    <span>Le mot de passe doit contenir au moins 6 caractères. Le manager pourra le changer après sa première connexion.</span>
                  </div>
                </div>

                <!-- Step 2: Establishment Info -->
                <div v-if="currentStep === 2" class="space-y-5">
                  <div class="bg-orange-50 border border-orange-200 rounded-xl p-4">
                    <div class="flex items-start gap-3">
                      <Store class="w-5 h-5 text-orange-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h3 class="font-semibold text-orange-900">Informations de l'Établissement</h3>
                        <p class="text-sm text-orange-700 mt-1">
                          L'établissement sera automatiquement lié au compte manager
                        </p>
                      </div>
                    </div>
                  </div>

                  <FloatLabelInput
                    id="establishment-name"
                    v-model="establishmentForm.name"
                    label="Nom de l'établissement"
                    type="text"
                    :required="true"
                    :error="errors.establishment_name"
                  />
                  
                  <FloatLabelInput
                    id="establishment-address"
                    v-model="establishmentForm.address"
                    label="Adresse"
                    type="text"
                    :error="errors.address"
                  />
                  
                  <!-- <FloatLabelInput
                    id="establishment-phone"
                    v-model="establishmentForm.phone"
                    label="Téléphone de l'établissement"
                    type="tel"
                    :error="errors.establishment_phone"
                  /> -->

                  <!-- <FloatLabelInput
                    id="establishment-email"
                    v-model="establishmentForm.email"
                    label="Email de l'établissement"
                    type="email"
                    :error="errors.establishment_email"
                  /> -->

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Type d'établissement</label>
                    <select 
                      v-model="establishmentForm.type_id"
                      class="w-full h-12 px-4 text-base border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
                    >
                      <option value="">Sélectionner un type</option>
                      <option v-for="type in establishmentTypes" :key="type.id" :value="type.id">
                        {{ type.name }}
                      </option>
                    </select>
                  </div>
<!-- 
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Devise</label>
                    <select 
                      v-model="establishmentForm.currency"
                      class="w-full h-12 px-4 text-base border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
                    >
                      <option value="XOF">XOF (Franc CFA)</option>
                      <option value="EUR">EUR (Euro)</option>
                      <option value="USD">USD (Dollar)</option>
                    </select>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Type d'abonnement</label>
                    <select 
                      v-model="establishmentForm.subscription_type"
                      class="w-full h-12 px-4 text-base border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
                    >
                      <option value="basic">Basic</option>
                      <option value="premium">Premium</option>
                      <option value="pro">Pro</option>
                    </select>
                  </div> -->
                </div>

                <!-- Error Message -->
                <div v-if="error" class="mt-4 bg-red-50 border border-red-200 rounded-xl p-4 flex items-start gap-3">
                  <AlertCircle class="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p class="text-sm font-semibold text-red-900">Erreur</p>
                    <p class="text-sm text-red-700 mt-1">{{ error }}</p>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex items-center justify-between mt-8 pt-6 border-t border-gray-200">
                  <button
                    v-if="currentStep === 2"
                    @click="currentStep = 1"
                    type="button"
                    class="px-4 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl font-medium transition-colors flex items-center gap-2"
                  >
                    <ArrowLeft class="w-4 h-4" />
                    Retour
                  </button>
                  <div v-else />

                  <div class="flex items-center gap-3">
                    <button
                      @click="closeModal"
                      type="button"
                      class="px-4 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl font-medium transition-colors"
                    >
                      Annuler
                    </button>

                    <button
                      v-if="currentStep === 1"
                      @click="nextStep"
                      type="button"
                      class="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition-colors flex items-center gap-2"
                    >
                      Suivant
                      <ArrowRight class="w-4 h-4" />
                    </button>

                    <button
                      v-else
                      type="submit"
                      :disabled="loading"
                      class="px-6 py-2.5 bg-green-600 text-white rounded-xl font-semibold hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
                    >
                      <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
                      <Check v-else class="w-4 h-4" />
                      {{ loading ? 'Création...' : 'Créer' }}
                    </button>
                  </div>
                </div>
              </form>
            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  Dialog, DialogPanel, DialogTitle, 
  TransitionRoot, TransitionChild 
} from '@headlessui/vue'
import { 
  X, User, Store, ArrowLeft, ArrowRight, 
  Loader2, Check, AlertCircle 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['close', 'submit'])

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

const isOpen = computed({
  get: () => props.open,
  set: (value) => {
    if (!value) emit('close')
  }
})

const loading = ref(false)
const error = ref('')
const currentStep = ref(1)
const establishmentTypes = ref<any[]>([])

// Forms
const managerForm = ref({
  full_name: '',
  email: '',
  phone: '',
  password: ''
})

const establishmentForm = ref({
  name: '',
  address: '',
  phone: '',
  email: '',
  type_id: '',
  currency: 'XOF',
  subscription_type: 'basic'
})

const errors = ref({
  full_name: '',
  email: '',
  phone: '',
  password: '',
  establishment_name: '',
  address: '',
  establishment_phone: '',
  establishment_email: ''
})

// Load establishment types
const loadEstablishmentTypes = async () => {
  try {
    const { data, error } = await supabase
      .from('establishment_types')
      .select('*')
      .order('name')

    if (error) throw error
    establishmentTypes.value = data || []
  } catch (err) {
    console.error('Error loading establishment types:', err)
  }
}

// Validate step 1
const validateStep1 = () => {
  let isValid = true
  errors.value = {
    full_name: '',
    email: '',
    phone: '',
    password: '',
    establishment_name: '',
    address: '',
    establishment_phone: '',
    establishment_email: ''
  }

  if (!managerForm.value.full_name.trim()) {
    errors.value.full_name = 'Le nom complet est requis'
    isValid = false
  }

  if (!managerForm.value.email.trim()) {
    errors.value.email = 'L\'email est requis'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(managerForm.value.email)) {
    errors.value.email = 'Email invalide'
    isValid = false
  }

  if (!managerForm.value.password || managerForm.value.password.length < 6) {
    errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
    isValid = false
  }

  return isValid
}

// Validate step 2
const validateStep2 = () => {
  let isValid = true

  if (!establishmentForm.value.name.trim()) {
    errors.value.establishment_name = 'Le nom de l\'établissement est requis'
    isValid = false
  }

  return isValid
}

// Next step
const nextStep = () => {
  if (validateStep1()) {
    currentStep.value = 2
  }
}

// Submit form
const handleSubmit = async () => {
  if (!validateStep2()) return

  try {
    loading.value = true
    error.value = ''

    // 1. Create manager account
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: managerForm.value.email,
      password: managerForm.value.password,
      options: {
        data: {
          full_name: managerForm.value.full_name,
          role: 'manager'
        }
      }
    })

    if (authError) throw authError
    if (!authData.user) throw new Error('Erreur lors de la création du compte')

    // 2. Update user in users table
    const { error: userError } = await supabase
      .from('users')
      .update({
        full_name: managerForm.value.full_name,
        phone: managerForm.value.phone,
        role: 'manager',
        is_active: true
      })
      .eq('id', authData.user.id)

    if (userError) throw userError

    // 3. Create establishment
    const { data: establishmentData, error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: establishmentForm.value.name,
        address: establishmentForm.value.address,
        // phone: establishmentForm.value.phone,
        // email: establishmentForm.value.email,
        type_id: establishmentForm.value.type_id || null,
        // currency: establishmentForm.value.currency,
        subscription_type: establishmentForm.value.subscription_type,
        user_id: authData.user.id,
        is_active: true
      })
      .select()
      .single()

    if (establishmentError) throw establishmentError

    // 4. Log activity
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    if (currentUser) {
      await supabase.from('activities').insert({
        user_id: currentUser.id,
        action_type: 'create',
        entity_type: 'manager_with_establishment',
        entity_id: authData.user.id,
        details: {
          manager: managerForm.value.full_name,
          establishment: establishmentForm.value.name
        }
      })
    }

    showToast.success('Manager et établissement créés avec succès')
    emit('submit')
    closeModal()
    resetForm()
  } catch (err: any) {
    console.error('Error creating manager with establishment:', err)
    error.value = err.message || 'Une erreur est survenue lors de la création'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

// Reset form
const resetForm = () => {
  currentStep.value = 1
  managerForm.value = {
    full_name: '',
    email: '',
    phone: '',
    password: ''
  }
  establishmentForm.value = {
    name: '',
    address: '',
    phone: '',
    email: '',
    type_id: '',
    currency: 'XOF',
    subscription_type: 'basic'
  }
  errors.value = {
    full_name: '',
    email: '',
    phone: '',
    password: '',
    establishment_name: '',
    address: '',
    establishment_phone: '',
    establishment_email: ''
  }
  error.value = ''
}

// Close modal
const closeModal = () => {
  if (!loading.value) {
    emit('close')
    setTimeout(resetForm, 300)
  }
}

// Load data on mount
onMounted(() => {
  loadEstablishmentTypes()
})

// Reset on open
watch(() => props.open, (newValue) => {
  if (newValue) {
    resetForm()
  }
})
</script>
