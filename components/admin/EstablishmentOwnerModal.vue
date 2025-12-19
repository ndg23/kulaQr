<template>
  <TransitionRoot appear :show="isOpen" as="template">
    <Dialog as="div" @close="closeModal" class="relative z-50">
      <!-- Overlay -->
      <TransitionChild
        enter="duration-200 ease-out"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="duration-150 ease-in"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-black/20 backdrop-blur-sm" />
      </TransitionChild>

      <!-- Modal -->
      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-6">
          <TransitionChild
            enter="duration-200 ease-out"
            enter-from="opacity-0 scale-98 translate-y-2"
            enter-to="opacity-100 scale-100 translate-y-0"
            leave="duration-150 ease-in"
            leave-from="opacity-100 scale-100 translate-y-0"
            leave-to="opacity-0 scale-98 translate-y-2"
          >
            <DialogPanel class="w-full max-w-xl transform overflow-hidden rounded-xl bg-white shadow-lg border border-gray-100 transition-all">
              <!-- Header -->
              <div class="px-6 py-5 border-b border-gray-100">
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <DialogTitle class="text-lg font-semibold text-gray-900">
                      Attribuer un Établissement
                    </DialogTitle>
                    <p class="text-sm text-gray-500 mt-1">
                      Assignez cet établissement à un propriétaire existant ou créez un nouveau compte
                    </p>
                  </div>
                  <button
                    @click="closeModal"
                    class="ml-4 p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-50 transition-all duration-150"
                  >
                    <X class="w-4 h-4" />
                  </button>
                </div>
              </div>

              <!-- Content -->
              <div class="px-6 py-6">
                <!-- Establishment Info -->
                <div v-if="establishment" class="bg-gray-50 rounded-lg p-4 mb-6">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                      <Store class="w-5 h-5 text-gray-600" />
                    </div>
                    <div class="flex-1">
                      <h3 class="font-medium text-gray-900">{{ establishment.name }}</h3>
                      <p class="text-sm text-gray-500 mt-0.5">
                        {{ establishment.address || 'Adresse non spécifiée' }}
                      </p>
                      <p class="text-xs text-gray-400 mt-0.5">
                        Type: {{ establishment.establishment_types?.name || 'Non spécifié' }}
                      </p>
                    </div>
                  </div>
                </div>

                <!-- Action Selection -->
                <div class="space-y-3 mb-6">
                  <label class="block text-sm font-medium text-gray-900">
                    Choisir une action
                  </label>
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <label class="relative cursor-pointer">
                      <input
                        v-model="actionType"
                        type="radio"
                        value="existing"
                        class="sr-only"
                      />
                      <div
                        :class="[
                          'p-4 border rounded-lg transition-all duration-150',
                          actionType === 'existing'
                            ? 'border-gray-300 bg-gray-50'
                            : 'border-gray-200 hover:border-gray-300'
                        ]"
                      >
                        <div class="flex items-center gap-3">
                          <Users class="w-5 h-5 text-gray-600" />
                          <div>
                            <h3 class="font-medium text-gray-900">
                              Propriétaire Existant
                            </h3>
                            <p class="text-sm text-gray-500">
                              Attribuer à un compte existant
                            </p>
                          </div>
                        </div>
                      </div>
                    </label>

                    <label class="relative cursor-pointer">
                      <input
                        v-model="actionType"
                        type="radio"
                        value="new"
                        class="sr-only"
                      />
                      <div
                        :class="[
                          'p-4 border rounded-lg transition-all duration-150',
                          actionType === 'new'
                            ? 'border-gray-300 bg-gray-50'
                            : 'border-gray-200 hover:border-gray-300'
                        ]"
                      >
                        <div class="flex items-center gap-3">
                          <UserPlus class="w-5 h-5 text-gray-600" />
                          <div>
                            <h3 class="font-medium text-gray-900">
                              Nouveau Propriétaire
                            </h3>
                            <p class="text-sm text-gray-500">
                              Créer un nouveau compte
                            </p>
                          </div>
                        </div>
                      </div>
                    </label>
                  </div>
                </div>

                <!-- Existing Owner Selection -->
                <div v-if="actionType === 'existing'" class="space-y-4">
                  <label class="block text-sm font-medium text-gray-700">
                    Sélectionner un propriétaire
                  </label>
                  
                  <!-- Simple Dropdown -->
                  <select
                    v-model="selectedOwnerId"
                    class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors bg-white"
                  >
                    <option value="">Choisir un propriétaire...</option>
                    <option
                      v-for="owner in owners"
                      :key="owner.id"
                      :value="owner.id"
                    >
                      {{ owner.full_name }} - {{ owner.phone }}
                    </option>
                  </select>

                  <!-- Selected Owner Info -->
                  <div v-if="selectedOwner" class="bg-gray-50 border border-gray-100 rounded-lg p-4">
                    <div class="flex items-center gap-3">
                      <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                        <Users class="w-5 h-5 text-gray-600" />
                      </div>
                      <div class="flex-1">
                        <div class="font-medium text-gray-900">{{ selectedOwner.full_name }}</div>
                        <div class="text-sm text-gray-500">{{ selectedOwner.phone }}</div>
                        <div class="text-xs text-gray-400 mt-1">
                          {{ selectedOwner.subscription_tier }} • {{ selectedOwner.is_active ? 'Actif' : 'Inactif' }}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- New Owner Form -->
                <div v-if="actionType === 'new'" class="space-y-4">
                  <div class="bg-green-50 border border-green-200 rounded-xl p-4">
                    <div class="flex items-start gap-3">
                      <UserPlus class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h3 class="font-semibold text-green-900">Nouveau Propriétaire</h3>
                        <p class="text-sm text-green-700 mt-1">
                          Un compte sera créé avec les informations ci-dessous
                        </p>
                      </div>
                    </div>
                  </div>

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FloatLabelInput
                      id="new-owner-name"
                      v-model="newOwnerForm.full_name"
                      label="Nom complet"
                      type="text"
                      :required="true"
                      :error="errors.full_name"
                    />
                    
                    <FloatLabelInput
                      id="new-owner-email"
                      v-model="newOwnerForm.email"
                      label="Email"
                      type="email"
                      :required="true"
                      :error="errors.email"
                    />
                  </div>

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FloatLabelInput
                      id="new-owner-phone"
                      v-model="newOwnerForm.phone"
                      label="Téléphone"
                      type="tel"
                      :error="errors.phone"
                    />
                    
                    <FloatLabelInput
                      id="new-owner-password"
                      v-model="newOwnerForm.password"
                      label="Mot de passe temporaire"
                      type="password"
                      :required="true"
                      :error="errors.password"
                    />
                  </div>

                  <div class="text-xs text-gray-500 flex items-start gap-2 bg-gray-50 p-3 rounded-lg">
                    <AlertCircle class="w-4 h-4 mt-0.5 flex-shrink-0" />
                    <span>Le propriétaire recevra un email avec ses identifiants de connexion et pourra modifier son mot de passe après sa première connexion.</span>
                  </div>
                </div>

                <!-- Error Message -->
                <div v-if="error" class="mt-4 bg-red-50 border border-red-200 rounded-lg p-3 flex items-start gap-2">
                  <AlertCircle class="w-4 h-4 text-red-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p class="text-sm font-medium text-red-900">Erreur</p>
                    <p class="text-sm text-red-700 mt-0.5">{{ error }}</p>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex items-center justify-end gap-3 mt-6 pt-6 border-t border-gray-100">
                  <button
                    @click="closeModal"
                    type="button"
                    class="px-4 py-2 text-gray-600 hover:text-gray-800 font-medium transition-colors"
                  >
                    Annuler
                  </button>

                  <button
                    @click="handleSubmit"
                    :disabled="loading || !canSubmit"
                    class="px-6 py-2 bg-black text-white rounded-lg font-medium hover:bg-gray-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all duration-150 flex items-center gap-2"
                  >
                    <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
                    <Store v-else class="w-4 h-4" />
                    {{ loading ? 'Attribution...' : 'Attribuer' }}
                  </button>
                </div>
              </div>
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
  X, Store, Users, UserPlus, 
  Loader2, AlertCircle 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  establishment: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'success'])

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
const actionType = ref('existing') // 'existing' or 'new'
const selectedOwnerId = ref('')
const owners = ref<any[]>([])

// New owner form
const newOwnerForm = ref({
  full_name: '',
  email: '',
  phone: '',
  password: ''
})

const errors = ref({
  full_name: '',
  email: '',
  phone: '',
  password: ''
})

// Computed
const selectedOwner = computed(() => {
  return owners.value.find(owner => owner.id === selectedOwnerId.value)
})

const canSubmit = computed(() => {
  if (actionType.value === 'existing') {
    return selectedOwnerId.value !== ''
  } else {
    return newOwnerForm.value.full_name && 
           newOwnerForm.value.email && 
           newOwnerForm.value.password
  }
})

// Load owners without establishments
const loadAvailableOwners = async () => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('id, full_name, phone, subscription_tier, is_active')
      .eq('role', 'owner')
      .is('establishment_id', null) // Owners without establishments
      .order('full_name')

    if (error) throw error
    owners.value = data || []
  } catch (err) {
    console.error('Error loading owners:', err)
    showToast.error('Erreur lors du chargement des propriétaires')
  }
}

// Validate new owner form
const validateNewOwnerForm = () => {
  let isValid = true
  errors.value = {
    full_name: '',
    email: '',
    phone: '',
    password: ''
  }

  if (!newOwnerForm.value.full_name.trim()) {
    errors.value.full_name = 'Le nom complet est requis'
    isValid = false
  }

  if (!newOwnerForm.value.email.trim()) {
    errors.value.email = 'L\'email est requis'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(newOwnerForm.value.email)) {
    errors.value.email = 'Email invalide'
    isValid = false
  }

  if (!newOwnerForm.value.password || newOwnerForm.value.password.length < 6) {
    errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
    isValid = false
  }

  return isValid
}

// Handle submit
const handleSubmit = async () => {
  if (!props.establishment) return

  try {
    loading.value = true
    error.value = ''

    let ownerId = selectedOwnerId.value

    // Create new owner if needed
    if (actionType.value === 'new') {
      if (!validateNewOwnerForm()) return

      // Create auth user
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: newOwnerForm.value.email,
        password: newOwnerForm.value.password,
        options: {
          data: {
            full_name: newOwnerForm.value.full_name,
            role: 'owner'
          }
        }
      })

      if (authError) throw authError
      if (!authData.user) throw new Error('Erreur lors de la création du compte')

      // Update user in users table
      const { error: userError } = await supabase
        .from('users')
        .upsert({
          id: authData.user.id,
          full_name: newOwnerForm.value.full_name,
          email: newOwnerForm.value.email,
          phone: newOwnerForm.value.phone,
          role: 'owner',
          subscription_tier: 'demo',
          is_active: false, // Will be activated by admin
          subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days demo
        })

      if (userError) throw userError
      ownerId = authData.user.id
    }

    // Assign establishment to owner
    const { error: assignError } = await supabase
      .from('establishments')
      .update({
        user_id: ownerId,
        updated_at: new Date().toISOString()
      })
      .eq('id', props.establishment.id)

    if (assignError) throw assignError

    // Log activity
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    if (currentUser) {
      await supabase.from('activities').insert({
        user_id: currentUser.id,
        action_type: 'assign',
        entity_type: 'establishment',
        entity_id: props.establishment.id,
        details: {
          establishment_name: props.establishment.name,
          owner_id: ownerId,
          action_type: actionType.value
        }
      })
    }

    showToast.success(
      actionType.value === 'new' 
        ? 'Propriétaire créé et établissement attribué avec succès'
        : 'Établissement attribué avec succès'
    )
    
    emit('success')
    closeModal()
    resetForm()
  } catch (err: any) {
    console.error('Error assigning establishment:', err)
    error.value = err.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

// Reset form
const resetForm = () => {
  actionType.value = 'existing'
  selectedOwnerId.value = ''
  newOwnerForm.value = {
    full_name: '',
    email: '',
    phone: '',
    password: ''
  }
  errors.value = {
    full_name: '',
    email: '',
    phone: '',
    password: ''
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
  loadAvailableOwners()
})

// Reset on open
watch(() => props.open, (newValue) => {
  if (newValue) {
    resetForm()
    loadAvailableOwners()
  }
})
</script>