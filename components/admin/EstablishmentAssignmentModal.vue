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
            <DialogPanel class="w-full max-w-2xl transform overflow-hidden rounded-xl bg-white shadow-lg border border-gray-100 transition-all">
              <!-- Header -->
              <div class="px-6 py-5 border-b border-gray-100">
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <DialogTitle class="text-lg font-semibold text-gray-900">
                      {{ modalTitle }}
                    </DialogTitle>
                    <p class="text-sm text-gray-500 mt-1">
                      {{ modalDescription }}
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
                <!-- Establishment Info (if editing existing) -->
                <div v-if="establishment && mode !== 'create'" class="bg-gray-50 rounded-lg p-4 mb-6">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                      <Store class="w-5 h-5 text-gray-600" />
                    </div>
                    <div class="flex-1">
                      <h3 class="font-medium text-gray-900">{{ establishment.name }}</h3>
                      <p class="text-sm text-gray-500 mt-0.5">
                        {{ establishment.address || 'Adresse non spécifiée' }}
                      </p>
                      <p v-if="establishment.users" class="text-xs text-gray-400 mt-0.5">
                        Propriétaire actuel: {{ establishment.users.full_name }}
                      </p>
                    </div>
                  </div>
                </div>

                <form @submit.prevent="handleSubmit" class="space-y-6">
                  <!-- Owner Selection/Creation -->
                  <div class="space-y-4">
                    <div class="flex items-center gap-4">
                      <label class="flex items-center cursor-pointer">
                        <input
                          type="radio"
                          value="existing"
                          v-model="ownerType"
                          class="w-4 h-4 text-black border-gray-300 focus:ring-black/10"
                        />
                        <span class="ml-2 text-sm text-gray-700">Propriétaire existant</span>
                      </label>
                      <label class="flex items-center cursor-pointer">
                        <input
                          type="radio"
                          value="new"
                          v-model="ownerType"
                          class="w-4 h-4 text-black border-gray-300 focus:ring-black/10"
                        />
                        <span class="ml-2 text-sm text-gray-700">Nouveau propriétaire</span>
                      </label>
                    </div>

                    <!-- Existing Owner Selection -->
                    <div v-if="ownerType === 'existing'">
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Sélectionner un propriétaire
                      </label>
                      <select
                        v-model="selectedOwnerId"
                        class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors bg-white"
                      >
                        <option value="">Choisir un propriétaire...</option>
                        <option
                          v-for="owner in availableOwners"
                          :key="owner.id"
                          :value="owner.id"
                        >
                          {{ owner.full_name }} - {{ owner.phone }}
                        </option>
                      </select>
                    </div>

                    <!-- New Owner Form -->
                    <div v-else class="space-y-4">
                      <div class="bg-gray-50 border border-gray-100 rounded-lg p-4">
                        <div class="flex items-start gap-3">
                          <UserPlus class="w-5 h-5 text-gray-600 mt-0.5 flex-shrink-0" />
                          <div>
                            <h3 class="font-medium text-gray-900">Nouveau Propriétaire</h3>
                            <p class="text-sm text-gray-500 mt-1">
                              Un compte sera créé avec les informations ci-dessous
                            </p>
                          </div>
                        </div>
                      </div>

                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Nom complet</label>
                          <input
                            v-model="newOwnerForm.full_name"
                            type="text"
                            class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                            :class="{ 'border-red-300': errors.full_name }"
                          />
                          <p v-if="errors.full_name" class="text-red-600 text-xs mt-1">{{ errors.full_name }}</p>
                        </div>
                        
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                          <input
                            v-model="newOwnerForm.email"
                            type="email"
                            class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                            :class="{ 'border-red-300': errors.email }"
                          />
                          <p v-if="errors.email" class="text-red-600 text-xs mt-1">{{ errors.email }}</p>
                        </div>
                      </div>

                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                          <input
                            v-model="newOwnerForm.phone"
                            type="tel"
                            class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                          />
                        </div>
                        
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Mot de passe temporaire</label>
                          <input
                            v-model="newOwnerForm.password"
                            type="password"
                            class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                            :class="{ 'border-red-300': errors.password }"
                          />
                          <p v-if="errors.password" class="text-red-600 text-xs mt-1">{{ errors.password }}</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Establishment Form (if creating new) -->
                  <div v-if="mode === 'create'" class="space-y-4">
                    <div class="bg-gray-50 border border-gray-100 rounded-lg p-4">
                      <div class="flex items-start gap-3">
                        <Store class="w-5 h-5 text-gray-600 mt-0.5 flex-shrink-0" />
                        <div>
                          <h3 class="font-medium text-gray-900">Nouvel Établissement</h3>
                          <p class="text-sm text-gray-500 mt-1">
                            Informations de l'établissement à créer
                          </p>
                        </div>
                      </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Nom de l'établissement</label>
                        <input
                          v-model="establishmentForm.name"
                          type="text"
                          class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                          :class="{ 'border-red-300': errors.establishment_name }"
                        />
                        <p v-if="errors.establishment_name" class="text-red-600 text-xs mt-1">{{ errors.establishment_name }}</p>
                      </div>
                      
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Type d'établissement</label>
                        <select
                          v-model="establishmentForm.establishment_type_id"
                          class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors bg-white"
                        >
                          <option value="">Choisir un type...</option>
                          <option
                            v-for="type in establishmentTypes"
                            :key="type.id"
                            :value="type.id"
                          >
                            {{ type.name }}
                          </option>
                        </select>
                      </div>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Adresse</label>
                      <input
                        v-model="establishmentForm.address"
                        type="text"
                        class="w-full px-4 py-3 border border-gray-200 rounded-lg focus:border-gray-400 focus:ring-2 focus:ring-black/5 transition-colors"
                      />
                    </div>
                  </div>

                  <!-- Transfer Options (if transferring) -->
                  <div v-if="mode === 'transfer'" class="space-y-3">
                    <div class="bg-gray-50 border border-gray-100 rounded-lg p-4">
                      <h3 class="font-medium text-gray-900 mb-3">Options de transfert</h3>
                      <div class="space-y-3">
                        <label class="flex items-start gap-3 cursor-pointer">
                          <input
                            type="checkbox"
                            v-model="transferOptions.notify_current"
                            class="w-4 h-4 text-black border-gray-300 rounded focus:ring-black/10 mt-0.5"
                          />
                          <div>
                            <span class="text-sm text-gray-700 font-medium">Notifier le propriétaire actuel</span>
                            <p class="text-xs text-gray-500">Envoyer un email au propriétaire sortant</p>
                          </div>
                        </label>
                        
                        <label class="flex items-start gap-3 cursor-pointer">
                          <input
                            type="checkbox"
                            v-model="transferOptions.notify_new"
                            class="w-4 h-4 text-black border-gray-300 rounded focus:ring-black/10 mt-0.5"
                          />
                          <div>
                            <span class="text-sm text-gray-700 font-medium">Notifier le nouveau propriétaire</span>
                            <p class="text-xs text-gray-500">Envoyer un email au nouveau propriétaire</p>
                          </div>
                        </label>
                      </div>
                    </div>
                  </div>

                  <!-- Error Message -->
                  <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-3 flex items-start gap-2">
                    <AlertCircle class="w-4 h-4 text-red-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <p class="text-sm font-medium text-red-900">{{ error }}</p>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div class="flex items-center justify-end gap-3 pt-6 border-t border-gray-100">
                    <button
                      @click="closeModal"
                      type="button"
                      class="px-4 py-2 text-gray-600 hover:text-gray-800 font-medium transition-colors"
                    >
                      Annuler
                    </button>

                    <button
                      type="submit"
                      :disabled="loading || !canSubmit"
                      class="px-6 py-2 bg-black text-white rounded-lg font-medium hover:bg-gray-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all duration-150 flex items-center gap-2"
                    >
                      <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
                      <component :is="actionIcon" v-else class="w-4 h-4" />
                      {{ loading ? 'Traitement...' : actionLabel }}
                    </button>
                  </div>
                </form>
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
  Loader2, AlertCircle, ArrowRightLeft
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

// Props pour définir le mode d'utilisation
const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  mode: {
    type: String,
    default: 'assign', // 'assign', 'transfer', 'create'
    validator: (value: string) => ['assign', 'transfer', 'create'].includes(value)
  },
  establishment: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'success'])

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

// State
const loading = ref(false)
const error = ref('')
const ownerType = ref('existing')
const selectedOwnerId = ref('')
const availableOwners = ref<any[]>([])
const establishmentTypes = ref<any[]>([])

// Forms
const newOwnerForm = ref({
  full_name: '',
  email: '',
  phone: '',
  password: ''
})

const establishmentForm = ref({
  name: '',
  address: '',
  establishment_type_id: ''
})

const transferOptions = ref({
  notify_current: true,
  notify_new: true
})

const errors = ref({
  full_name: '',
  email: '',
  password: '',
  establishment_name: ''
})

// Computed
const isOpen = computed({
  get: () => props.open,
  set: (value) => {
    if (!value) emit('close')
  }
})

const modalTitle = computed(() => {
  switch (props.mode) {
    case 'assign': return 'Attribuer Établissement'
    case 'transfer': return 'Transférer Établissement'
    case 'create': return 'Créer Propriétaire + Établissement'
    default: return 'Gestion Établissement'
  }
})

const modalDescription = computed(() => {
  switch (props.mode) {
    case 'assign': return 'Assignez cet établissement à un propriétaire'
    case 'transfer': return 'Transférez la propriété vers un autre compte'
    case 'create': return 'Créez un compte propriétaire avec son établissement'
    default: return 'Gérer la propriété de l\'établissement'
  }
})

const actionLabel = computed(() => {
  switch (props.mode) {
    case 'assign': return 'Attribuer'
    case 'transfer': return 'Transférer'
    case 'create': return 'Créer'
    default: return 'Valider'
  }
})

const actionIcon = computed(() => {
  switch (props.mode) {
    case 'assign': return Store
    case 'transfer': return ArrowRightLeft
    case 'create': return UserPlus
    default: return Store
  }
})

const canSubmit = computed(() => {
  const hasOwner = ownerType.value === 'existing' 
    ? selectedOwnerId.value !== ''
    : newOwnerForm.value.full_name && newOwnerForm.value.email && newOwnerForm.value.password
  
  if (props.mode === 'create') {
    return hasOwner && establishmentForm.value.name
  }
  
  return hasOwner
})

// Methods
const loadAvailableOwners = async () => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('id, full_name, phone, subscription_tier, is_active')
      .eq('role', 'owner')
      .order('full_name')

    if (error) throw error
    
    // Filter based on mode
    if (props.mode === 'assign') {
      // Only owners without establishments
      availableOwners.value = (data || []).filter(owner => !owner.establishment_id)
    } else if (props.mode === 'transfer') {
      // All owners except current one
      availableOwners.value = (data || []).filter(owner => owner.id !== props.establishment?.user_id)
    } else {
      availableOwners.value = data || []
    }
  } catch (err) {
    console.error('Error loading owners:', err)
    showToast.error('Erreur lors du chargement des propriétaires')
  }
}

const loadEstablishmentTypes = async () => {
  if (props.mode !== 'create') return
  
  try {
    const { data, error } = await supabase
      .from('establishment_types')
      .select('id, name')
      .order('name')

    if (error) throw error
    establishmentTypes.value = data || []
  } catch (err) {
    console.error('Error loading establishment types:', err)
  }
}

const validateForm = () => {
  let isValid = true
  errors.value = {
    full_name: '',
    email: '',
    password: '',
    establishment_name: ''
  }

  if (ownerType.value === 'new') {
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
  }

  if (props.mode === 'create' && !establishmentForm.value.name.trim()) {
    errors.value.establishment_name = 'Le nom de l\'établissement est requis'
    isValid = false
  }

  return isValid
}

const handleSubmit = async () => {
  if (!validateForm()) return

  try {
    loading.value = true
    error.value = ''

    let ownerId = selectedOwnerId.value

    // Create new owner if needed
    if (ownerType.value === 'new') {
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

      const { error: userError } = await supabase
        .from('users')
        .upsert({
          id: authData.user.id,
          full_name: newOwnerForm.value.full_name,
          email: newOwnerForm.value.email,
          phone: newOwnerForm.value.phone,
          role: 'owner',
          subscription_tier: 'demo',
          is_active: true,
          subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        })

      if (userError) throw userError
      ownerId = authData.user.id
    }

    // Handle different modes
    if (props.mode === 'create') {
      // Create establishment
      const { data: estData, error: estError } = await supabase
        .from('establishments')
        .insert({
          name: establishmentForm.value.name,
          address: establishmentForm.value.address,
          establishment_type_id: establishmentForm.value.establishment_type_id || null,
          user_id: ownerId,
          is_active: true
        })
        .select()
        .single()

      if (estError) throw estError
      
      showToast.success('Propriétaire et établissement créés avec succès')
    } else {
      // Assign or transfer existing establishment
      const { error: updateError } = await supabase
        .from('establishments')
        .update({
          user_id: ownerId,
          updated_at: new Date().toISOString()
        })
        .eq('id', props.establishment.id)

      if (updateError) throw updateError

      const action = props.mode === 'transfer' ? 'transféré' : 'attribué'
      showToast.success(`Établissement ${action} avec succès`)
    }

    emit('success')
    closeModal()
  } catch (err: any) {
    console.error('Error processing request:', err)
    error.value = err.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  ownerType.value = 'existing'
  selectedOwnerId.value = ''
  newOwnerForm.value = {
    full_name: '',
    email: '',
    phone: '',
    password: ''
  }
  establishmentForm.value = {
    name: '',
    address: '',
    establishment_type_id: ''
  }
  transferOptions.value = {
    notify_current: true,
    notify_new: true
  }
  errors.value = {
    full_name: '',
    email: '',
    password: '',
    establishment_name: ''
  }
  error.value = ''
}

const closeModal = () => {
  if (!loading.value) {
    emit('close')
    setTimeout(resetForm, 300)
  }
}

// Watchers
watch(() => props.open, (newValue) => {
  if (newValue) {
    resetForm()
    loadAvailableOwners()
    loadEstablishmentTypes()
  }
})

onMounted(() => {
  if (props.open) {
    loadAvailableOwners()
    loadEstablishmentTypes()
  }
})
</script>