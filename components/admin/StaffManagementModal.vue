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
            <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-xl bg-white shadow-lg border border-gray-100 transition-all">
              <!-- Header -->
              <div class="border-b border-gray-100 px-6 py-5">
                <div class="flex items-center justify-between">
                  <DialogTitle class="text-lg font-medium text-gray-900">
                    Gérer Personnel
                  </DialogTitle>
                  <button
                    @click="closeModal"
                    class="p-1.5 rounded-full hover:bg-gray-50 transition-colors"
                  >
                    <X class="w-5 h-5 text-gray-400" />
                  </button>
                </div>
                <p class="text-sm text-gray-500 mt-0.5">
                  Ajoutez ou gérez le personnel de cet établissement
                </p>
              </div>

              <!-- Content -->
              <div class="px-6 py-6">
                <!-- Establishment Info -->
                <div v-if="establishment" class="bg-gray-50 border border-gray-100 rounded-lg p-4 mb-6">
                  <div class="flex items-start gap-3">
                    <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center flex-shrink-0">
                      <Store class="w-4 h-4 text-gray-600" />
                    </div>
                    <div>
                      <h3 class="font-medium text-gray-900">{{ establishment.name }}</h3>
                      <p class="text-sm text-gray-500 mt-1">
                        Propriétaire: {{ establishment.users?.full_name || 'Non assigné' }}
                      </p>
                    </div>
                  </div>
                </div>

                <!-- Current Staff -->
                <div class="mb-6">
                  <div class="flex items-center justify-between mb-4">
                    <h3 class="font-semibold text-gray-900">Personnel Actuel</h3>
                    <span class="text-sm text-gray-500">{{ currentStaff.length }} membre(s)</span>
                  </div>

                  <div v-if="currentStaff.length === 0" class="text-center py-8 text-gray-500">
                    <Users class="w-12 h-12 mx-auto mb-3 text-gray-300" />
                    <p>Aucun personnel assigné</p>
                  </div>

                  <div v-else class="space-y-2">
                    <div
                      v-for="staff in currentStaff"
                      :key="staff.id"
                      class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-100"
                    >
                      <div class="flex items-center gap-3">
                        <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
                          <User class="w-4 h-4 text-gray-600" />
                        </div>
                        <div>
                          <div class="font-medium text-gray-900">{{ staff.full_name }}</div>
                          <div class="text-sm text-gray-500">{{ staff.email }}</div>
                        </div>
                      </div>
                      <button
                        @click="removeStaff(staff.id)"
                        class="p-1 text-gray-400 hover:text-red-500 hover:bg-gray-100 rounded-lg transition-colors"
                        title="Retirer du personnel"
                      >
                        <X class="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Add Staff Form -->
                <form @submit.prevent="handleSubmit" class="space-y-4">
                  <div class="bg-gray-50 border border-gray-100 rounded-lg p-4">
                    <div class="flex items-start gap-3">
                      <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center flex-shrink-0">
                        <UserPlus class="w-4 h-4 text-gray-600" />
                      </div>
                      <div>
                        <h3 class="font-medium text-gray-900">Ajouter Personnel</h3>
                        <p class="text-sm text-gray-500 mt-1">
                          Créer un compte staff pour cet établissement
                        </p>
                      </div>
                    </div>
                  </div>

                  <FloatLabelInput
                    id="staff-name"
                    v-model="staffForm.full_name"
                    label="Nom complet"
                    type="text"
                    :required="true"
                    :error="errors.full_name"
                  />
                  
                  <FloatLabelInput
                    id="staff-username"
                    v-model="staffForm.username"
                    label="Nom d'utilisateur (pour PIN)"
                    type="text"
                    :required="true"
                    :error="errors.username"
                  />
                  
                  <FloatLabelInput
                    id="staff-email"
                    v-model="staffForm.email"
                    label="Email (optionnel)"
                    type="email"
                    :error="errors.email"
                  />
                  
                  <FloatLabelInput
                    id="staff-pin"
                    v-model="staffForm.pin_code"
                    label="Code PIN (4 chiffres)"
                    type="text"
                    maxlength="4"
                    pattern="[0-9]{4}"
                    :required="true"
                    :error="errors.pin_code"
                  />

                  <div class="text-xs text-gray-500 flex items-start gap-2 bg-gray-50 p-3 rounded-lg border border-gray-100">
                    <AlertCircle class="w-4 h-4 mt-0.5 flex-shrink-0 text-gray-400" />
                    <span>Le personnel pourra se connecter avec son nom d'utilisateur et son code PIN de 4 chiffres.</span>
                  </div>

                  <!-- Error Message -->
                  <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-3 flex items-start gap-2">
                    <AlertCircle class="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                    <div>
                      <p class="text-sm font-medium text-red-900">{{ error }}</p>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div class="flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
                    <button
                      @click="closeModal"
                      type="button"
                      class="px-4 py-2 text-gray-600 hover:bg-gray-50 rounded-lg font-medium transition-colors"
                    >
                      Fermer
                    </button>

                    <button
                      type="submit"
                      :disabled="loading || !canSubmit"
                      class="px-5 py-2 bg-black text-white rounded-lg font-medium hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
                    >
                      <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
                      <UserPlus v-else class="w-4 h-4" />
                      {{ loading ? 'Ajout...' : 'Ajouter Personnel' }}
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
  X, Store, Users, User, UserPlus, 
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
const currentStaff = ref<any[]>([])

// Staff form
const staffForm = ref({
  full_name: '',
  username: '',
  email: '',
  pin_code: ''
})

const errors = ref({
  full_name: '',
  username: '',
  email: '',
  pin_code: ''
})

// Computed
const canSubmit = computed(() => {
  return staffForm.value.full_name && 
         staffForm.value.username && 
         staffForm.value.pin_code && 
         staffForm.value.pin_code.length === 4
})

// Load current staff
const loadCurrentStaff = async () => {
  if (!props.establishment?.id) return

  try {
    const { data, error } = await supabase
      .from('staff')
      .select(`
        id,
        full_name,
        username,
        email,
        pin_code,
        is_active
      `)
      .eq('establishment_id', props.establishment.id)
      .eq('is_active', true)
      .order('full_name')

    if (error) throw error
    currentStaff.value = data || []
  } catch (err) {
    console.error('Error loading staff:', err)
    showToast.error('Erreur lors du chargement du personnel')
  }
}

// Validate form
const validateForm = () => {
  let isValid = true
  errors.value = {
    full_name: '',
    username: '',
    email: '',
    pin_code: ''
  }

  if (!staffForm.value.full_name.trim()) {
    errors.value.full_name = 'Le nom complet est requis'
    isValid = false
  }

  if (!staffForm.value.username.trim()) {
    errors.value.username = 'Le nom d\'utilisateur est requis'
    isValid = false
  }

  if (staffForm.value.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(staffForm.value.email)) {
    errors.value.email = 'Email invalide'
    isValid = false
  }

  if (!staffForm.value.pin_code || !/^\d{4}$/.test(staffForm.value.pin_code)) {
    errors.value.pin_code = 'Le code PIN doit contenir exactement 4 chiffres'
    isValid = false
  }

  return isValid
}

// Handle submit
const handleSubmit = async () => {
  if (!props.establishment?.id || !validateForm()) return

  try {
    loading.value = true
    error.value = ''

    // Check if username or PIN already exists
    const { data: existingStaff, error: checkError } = await supabase
      .from('staff')
      .select('id')
      .eq('establishment_id', props.establishment.id)
      .or(`username.eq.${staffForm.value.username},pin_code.eq.${staffForm.value.pin_code}`)

    if (checkError) throw checkError
    
    if (existingStaff && existingStaff.length > 0) {
      error.value = 'Ce nom d\'utilisateur ou ce code PIN existe déjà pour cet établissement'
      return
    }

    // Create staff member
    const { data: staffData, error: staffError } = await supabase
      .from('staff')
      .insert({
        establishment_id: props.establishment.id,
        full_name: staffForm.value.full_name,
        username: staffForm.value.username,
        email: staffForm.value.email || null,
        pin_code: staffForm.value.pin_code,
        is_active: true,
        created_at: new Date().toISOString()
      })
      .select()
      .single()

    if (staffError) throw staffError

    // Log activity
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    if (currentUser) {
      await supabase.from('activities').insert({
        user_id: currentUser.id,
        action_type: 'create',
        entity_type: 'staff',
        entity_id: staffData.id,
        details: {
          establishment_name: props.establishment.name,
          staff_name: staffForm.value.full_name,
          username: staffForm.value.username
        }
      })
    }

    showToast.success('Personnel ajouté avec succès')
    
    // Reload staff list
    await loadCurrentStaff()
    
    // Reset form
    resetForm()
    
    emit('success')
  } catch (err: any) {
    console.error('Error adding staff:', err)
    error.value = err.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

// Remove staff
const removeStaff = async (staffId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir retirer ce membre du personnel ?')) return

  try {
    const { error } = await supabase
      .from('staff')
      .update({ is_active: false })
      .eq('id', staffId)

    if (error) throw error

    showToast.success('Personnel retiré avec succès')
    await loadCurrentStaff()
  } catch (err: any) {
    console.error('Error removing staff:', err)
    showToast.error('Erreur lors de la suppression du personnel')
  }
}

// Reset form
const resetForm = () => {
  staffForm.value = {
    full_name: '',
    username: '',
    email: '',
    pin_code: ''
  }
  errors.value = {
    full_name: '',
    username: '',
    email: '',
    pin_code: ''
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
  if (props.establishment?.id) {
    loadCurrentStaff()
  }
})

// Reset and reload on open
watch(() => props.open, (newValue) => {
  if (newValue) {
    resetForm()
    if (props.establishment?.id) {
      loadCurrentStaff()
    }
  }
})
</script>