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
              <div class="px-6 py-5 border-b border-gray-100">
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <DialogTitle class="text-lg font-semibold text-gray-900">
                      Gestion Abonnement
                    </DialogTitle>
                    <p class="text-sm text-gray-500 mt-1">
                      Modifier l'abonnement de cet utilisateur
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
                <!-- User Info -->
                <div v-if="user" class="bg-gray-50 rounded-lg p-4 mb-6">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                      <User class="w-5 h-5 text-gray-600" />
                    </div>
                    <div class="flex-1">
                      <h3 class="font-medium text-gray-900">{{ user.full_name }}</h3>
                      <p class="text-sm text-gray-500">{{ user.email }}</p>
                      <div class="flex items-center gap-2 mt-2">
                        <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-white border"
                              :class="tierBadgeClass(user.subscription_tier)">
                          {{ tierLabel(user.subscription_tier) }}
                        </span>
                        <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-white border"
                              :class="statusBadgeClass(user.subscription_status)">
                          {{ statusLabel(user.subscription_status) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <form @submit.prevent="handleSubmit" class="space-y-6">
                  <!-- Current Subscription -->
                  <div class="bg-gray-50 border border-gray-200 rounded-xl p-4">
                    <div class="flex items-start gap-3 mb-3">
                      <CreditCard class="w-5 h-5 text-gray-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h3 class="font-semibold text-gray-900">Abonnement Actuel</h3>
                        <p class="text-sm text-gray-600 mt-1">
                          Plan {{ tierLabel(user?.subscription_tier) }} - {{ statusLabel(user?.subscription_status) }}
                        </p>
                      </div>
                    </div>

                    <div v-if="user?.subscription_ends_at" class="text-sm text-gray-600">
                      Expire le: {{ formatDate(user.subscription_ends_at) }}
                    </div>
                  </div>

                  <!-- New Subscription -->
                  <div class="space-y-4">
                    <h3 class="font-semibold text-gray-900">Nouveau Plan</h3>
                    
                    <FloatLabelSelect
                      id="subscription-tier"
                      v-model="subscriptionForm.tier"
                      label="Plan d'abonnement"
                      :options="tierOptions"
                      :required="true"
                      :error="errors.tier"
                    />

                    <FloatLabelSelect
                      id="subscription-status"
                      v-model="subscriptionForm.status"
                      label="Statut"
                      :options="statusOptions"
                      :required="true"
                      :error="errors.status"
                    />

                    <!-- Duration (for active subscriptions) -->
                    <div v-if="subscriptionForm.status === 'active'">
                      <FloatLabelSelect
                        id="subscription-duration"
                        v-model="subscriptionForm.duration"
                        label="Durée"
                        :options="durationOptions"
                        :required="true"
                        :error="errors.duration"
                      />
                    </div>

                    <!-- Custom End Date -->
                    <div v-if="subscriptionForm.duration === 'custom'">
                      <FloatLabelInput
                        id="subscription-end-date"
                        v-model="subscriptionForm.custom_end_date"
                        label="Date de fin"
                        type="date"
                        :required="true"
                        :error="errors.custom_end_date"
                      />
                    </div>
                  </div>

                  <!-- Admin Options -->
                  <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-4">
                    <div class="flex items-start gap-3 mb-4">
                      <Settings class="w-5 h-5 text-yellow-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h3 class="font-semibold text-yellow-900">Options Administrateur</h3>
                        <p class="text-sm text-yellow-700 mt-1">
                          Options spéciales pour la gestion des abonnements
                        </p>
                      </div>
                    </div>

                    <div class="space-y-3">
                      <label class="flex items-start gap-3">
                        <input
                          type="checkbox"
                          v-model="adminOptions.notify_user"
                          class="w-4 h-4 text-yellow-600 border-gray-300 rounded focus:ring-yellow-500 mt-0.5"
                        />
                        <div>
                          <span class="text-sm text-gray-700 font-medium">Notifier l'utilisateur</span>
                          <p class="text-xs text-gray-500">Envoyer un email de confirmation du changement</p>
                        </div>
                      </label>
                      
                      <label class="flex items-start gap-3">
                        <input
                          type="checkbox"
                          v-model="adminOptions.force_activation"
                          class="w-4 h-4 text-yellow-600 border-gray-300 rounded focus:ring-yellow-500 mt-0.5"
                        />
                        <div>
                          <span class="text-sm text-gray-700 font-medium">Forcer l'activation immédiate</span>
                          <p class="text-xs text-gray-500">Activer sans attendre la validation de paiement</p>
                        </div>
                      </label>

                      <label class="flex items-start gap-3">
                        <input
                          type="checkbox"
                          v-model="adminOptions.reset_limits"
                          class="w-4 h-4 text-yellow-600 border-gray-300 rounded focus:ring-yellow-500 mt-0.5"
                        />
                        <div>
                          <span class="text-sm text-gray-700 font-medium">Réinitialiser les limites</span>
                          <p class="text-xs text-gray-500">Remettre à zéro les compteurs d'utilisation</p>
                        </div>
                      </label>
                    </div>
                  </div>

                  <!-- Admin Note -->
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                      Note administrative (optionnelle)
                    </label>
                    <textarea
                      v-model="adminNote"
                      rows="3"
                      class="w-full px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                      placeholder="Raison du changement d'abonnement..."
                    />
                  </div>

                  <!-- Error Message -->
                  <div v-if="error" class="bg-red-50 border border-red-200 rounded-xl p-4 flex items-start gap-3">
                    <AlertCircle class="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <p class="text-sm font-semibold text-red-900">Erreur</p>
                      <p class="text-sm text-red-700 mt-1">{{ error }}</p>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div class="flex items-center justify-end gap-3 pt-6 border-t border-gray-100 mt-6">
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
                      <CreditCard v-else class="w-4 h-4" />
                      {{ loading ? 'Mise à jour...' : 'Mettre à Jour' }}
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
  X, User, CreditCard, Settings,
  Loader2, AlertCircle
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  user: {
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

// Forms
const subscriptionForm = ref({
  tier: 'demo',
  status: 'active',
  duration: 'default',
  custom_end_date: ''
})

const adminOptions = ref({
  notify_user: true,
  force_activation: false,
  reset_limits: false
})

const adminNote = ref('')

const errors = ref({
  tier: '',
  status: '',
  duration: '',
  custom_end_date: ''
})

// Options
const tierOptions = [
  { value: 'demo', label: 'Démo (7 jours)' },
  { value: 'pro', label: 'Pro (30 jours)' },
  { value: 'premium', label: 'Premium (90 jours)' }
]

const statusOptions = [
  { value: 'active', label: 'Actif' },
  { value: 'pending_activation', label: 'En attente d\'activation' },
  { value: 'expired', label: 'Expiré' },
  { value: 'cancelled', label: 'Annulé' },
  { value: 'suspended', label: 'Suspendu' }
]

const durationOptions = [
  { value: 'default', label: 'Durée par défaut' },
  { value: 'custom', label: 'Durée personnalisée' }
]

// Computed
const canSubmit = computed(() => {
  const basicValid = subscriptionForm.value.tier && subscriptionForm.value.status

  if (subscriptionForm.value.status === 'active' && subscriptionForm.value.duration === 'custom') {
    return basicValid && subscriptionForm.value.custom_end_date
  }

  return basicValid
})

// Helper functions
const tierLabel = (tier: string) => {
  const tierMap = {
    demo: 'Démo',
    pro: 'Pro',
    premium: 'Premium'
  }
  return tierMap[tier] || tier
}

const statusLabel = (status: string) => {
  const statusMap = {
    active: 'Actif',
    pending_activation: 'En attente',
    expired: 'Expiré',
    cancelled: 'Annulé',
    suspended: 'Suspendu'
  }
  return statusMap[status] || status
}

const tierBadgeClass = (tier: string) => {
  const classMap = {
    demo: 'bg-blue-100 text-blue-800',
    pro: 'bg-green-100 text-green-800',
    premium: 'bg-purple-100 text-purple-800'
  }
  return classMap[tier] || 'bg-gray-100 text-gray-800'
}

const statusBadgeClass = (status: string) => {
  const classMap = {
    active: 'bg-green-100 text-green-800',
    pending_activation: 'bg-yellow-100 text-yellow-800',
    expired: 'bg-red-100 text-red-800',
    cancelled: 'bg-gray-100 text-gray-800',
    suspended: 'bg-orange-100 text-orange-800'
  }
  return classMap[status] || 'bg-gray-100 text-gray-800'
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

// Calculate end date
const calculateEndDate = (tier: string, duration: string, customDate?: string) => {
  if (duration === 'custom' && customDate) {
    return new Date(customDate)
  }

  const now = new Date()
  const durationMap = {
    demo: 7,
    pro: 30,
    premium: 90
  }

  const days = durationMap[tier] || 7
  const endDate = new Date(now)
  endDate.setDate(endDate.getDate() + days)
  
  return endDate
}

// Validate form
const validateForm = () => {
  let isValid = true
  errors.value = {
    tier: '',
    status: '',
    duration: '',
    custom_end_date: ''
  }

  if (!subscriptionForm.value.tier) {
    errors.value.tier = 'Le plan d\'abonnement est requis'
    isValid = false
  }

  if (!subscriptionForm.value.status) {
    errors.value.status = 'Le statut est requis'
    isValid = false
  }

  if (subscriptionForm.value.status === 'active' && subscriptionForm.value.duration === 'custom') {
    if (!subscriptionForm.value.custom_end_date) {
      errors.value.custom_end_date = 'La date de fin est requise'
      isValid = false
    } else {
      const customDate = new Date(subscriptionForm.value.custom_end_date)
      const now = new Date()
      if (customDate <= now) {
        errors.value.custom_end_date = 'La date de fin doit être dans le futur'
        isValid = false
      }
    }
  }

  return isValid
}

// Handle submit
const handleSubmit = async () => {
  if (!props.user?.id || !validateForm()) return

  try {
    loading.value = true
    error.value = ''

    let subscriptionEndDate = null
    if (subscriptionForm.value.status === 'active') {
      subscriptionEndDate = calculateEndDate(
        subscriptionForm.value.tier, 
        subscriptionForm.value.duration,
        subscriptionForm.value.custom_end_date
      )
    }

    // Update user subscription
    const updateData = {
      subscription_tier: subscriptionForm.value.tier,
      subscription_status: subscriptionForm.value.status,
      subscription_ends_at: subscriptionEndDate?.toISOString() || null,
      updated_at: new Date().toISOString()
    }

    const { error: updateError } = await supabase
      .from('users')
      .update(updateData)
      .eq('id', props.user.id)

    if (updateError) throw updateError

    // Update auth user metadata
    const { error: authError } = await supabase.auth.admin.updateUserById(
      props.user.id,
      {
        user_metadata: {
          ...props.user,
          subscription_tier: subscriptionForm.value.tier,
          subscription_status: subscriptionForm.value.status
        }
      }
    )

    if (authError) throw authError

    // Reset limits if requested
    if (adminOptions.value.reset_limits) {
      // TODO: Implement limit reset logic
      // This could involve resetting QR scan counts, order limits, etc.
    }

    // Log activity
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    if (currentUser) {
      await supabase.from('activities').insert({
        user_id: currentUser.id,
        action_type: 'update',
        entity_type: 'subscription',
        entity_id: props.user.id,
        details: {
          user_name: props.user.full_name,
          from_tier: props.user.subscription_tier,
          to_tier: subscriptionForm.value.tier,
          from_status: props.user.subscription_status,
          to_status: subscriptionForm.value.status,
          admin_note: adminNote.value,
          options: adminOptions.value
        }
      })
    }

    // TODO: Send notification if requested
    if (adminOptions.value.notify_user) {
      // Implementation for email notification
    }

    showToast.success('Abonnement mis à jour avec succès')
    emit('success')
    closeModal()
  } catch (err: any) {
    console.error('Error updating subscription:', err)
    error.value = err.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

// Load current subscription data
const loadSubscriptionData = () => {
  if (props.user) {
    subscriptionForm.value = {
      tier: props.user.subscription_tier || 'demo',
      status: props.user.subscription_status || 'pending_activation',
      duration: 'default',
      custom_end_date: ''
    }
  }
}

// Reset form
const resetForm = () => {
  subscriptionForm.value = {
    tier: 'demo',
    status: 'active',
    duration: 'default',
    custom_end_date: ''
  }
  
  adminOptions.value = {
    notify_user: true,
    force_activation: false,
    reset_limits: false
  }
  
  adminNote.value = ''
  
  errors.value = {
    tier: '',
    status: '',
    duration: '',
    custom_end_date: ''
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

// Watch for open changes
watch(() => props.open, (newValue) => {
  if (newValue) {
    resetForm()
    loadSubscriptionData()
  }
})

// Load data on mount
onMounted(() => {
  if (props.open) {
    loadSubscriptionData()
  }
})
</script>