<template>
  <UModal 
    v-model="isOpen" 
    size="sm" 
    @action="handleSubmit" 
    actionButtonText="Changer le rôle"
  >
    <div class="p-6">
      <div class="flex items-center gap-3 mb-6">
        <div 
          class="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center"
        >
          <Shield class="w-6 h-6 text-purple-600" />
        </div>
        <div>
          <h2 class="text-xl font-semibold text-gray-900">Changer le rôle</h2>
          <p class="text-sm text-gray-500">{{ user?.full_name }}</p>
        </div>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Current Role Display -->
        <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
          <p class="text-xs text-gray-500 mb-1">Rôle actuel</p>
          <div class="flex items-center gap-2">
            <span
              class="px-3 py-1 rounded-full text-sm font-medium"
              :class="getRoleBadgeClass(user?.role)"
            >
              {{ formatRole(user?.role) }}
            </span>
          </div>
        </div>

        <!-- New Role Selection -->
        <div>
          <FloatLabelSelect
            id="newRole"
            v-model="newRole"
            label="Nouveau rôle"
            :error="error"
            required
          >
            <option value="" disabled>Sélectionner un rôle</option>
            <option value="admin">Administrateur</option>
            <option value="owner">Propriétaire</option>
            <option value="manager">Manager</option>
            <option value="staff">Staff</option>
          </FloatLabelSelect>
        </div>

        <!-- Warning for sensitive roles -->
        <div 
          v-if="newRole === 'admin'" 
          class="bg-amber-50 border border-amber-200 rounded-lg p-4"
        >
          <div class="flex gap-3">
            <AlertTriangle class="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div>
              <p class="text-sm font-medium text-amber-900">Attention</p>
              <p class="text-xs text-amber-700 mt-1">
                Le rôle Administrateur donne accès à toutes les fonctionnalités de la plateforme.
              </p>
            </div>
          </div>
        </div>

        <!-- Role Comparison -->
        <div 
          v-if="newRole && newRole !== user?.role" 
          class="bg-blue-50 border border-blue-200 rounded-lg p-4"
        >
          <div class="flex items-center gap-2 text-sm">
            <span class="text-gray-600">Changement:</span>
            <span
              class="px-2 py-0.5 rounded-full text-xs font-medium"
              :class="getRoleBadgeClass(user?.role)"
            >
              {{ formatRole(user?.role) }}
            </span>
            <ChevronRight class="w-4 h-4 text-gray-400" />
            <span
              class="px-2 py-0.5 rounded-full text-xs font-medium"
              :class="getRoleBadgeClass(newRole)"
            >
              {{ formatRole(newRole) }}
            </span>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4">
          <p class="text-sm text-red-900">{{ error }}</p>
        </div>
      </form>
    </div>
  </UModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import UModal from '~/components/UModal.vue'
import FloatLabelSelect from '~/components/FloatLabelSelect.vue'
import { Shield, AlertTriangle, ChevronRight, Loader2 } from 'lucide-vue-next'

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

const emit = defineEmits(['close', 'submit'])

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const isOpen = computed({
  get: () => props.open,
  set: (value) => {
    if (!value) {
      emit('close')
    }
  }
})

const newRole = ref('')
const loading = ref(false)
const error = ref('')

// Watch for user changes to reset form
watch(() => props.user, (user) => {
  if (user) {
    newRole.value = user.role || ''
  }
  error.value = ''
}, { immediate: true })

// Helper methods
const getRoleBadgeClass = (role: string) => {
  const classes: Record<string, string> = {
    'admin': 'bg-purple-100 text-purple-800',
    'owner': 'bg-orange-100 text-orange-800',
    'manager': 'bg-blue-100 text-blue-800',
    'staff': 'bg-green-100 text-green-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const formatRole = (role: string) => {
  const roles: Record<string, string> = {
    'admin': 'Administrateur',
    'owner': 'Propriétaire',
    'manager': 'Manager',
    'staff': 'Staff'
  }
  return roles[role] || role
}

const handleSubmit = async () => {
  if (!newRole.value) {
    error.value = 'Veuillez sélectionner un rôle'
    return
  }

  if (newRole.value === props.user?.role) {
    error.value = 'Le nouveau rôle est identique au rôle actuel'
    return
  }

  try {
    loading.value = true
    error.value = ''

    // Update user role
    const { error: updateError } = await supabase
      .from('users')
      .update({ role: newRole.value })
      .eq('id', props.user.id)

    if (updateError) throw updateError

    // Log activity
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    if (currentUser) {
      await supabase.from('activities').insert({
        user_id: currentUser.id,
        action_type: 'update',
        entity_type: 'user',
        entity_id: props.user.id,
        details: {
          field: 'role',
          old_value: props.user.role,
          new_value: newRole.value
        }
      })
    }

    showToast.success(
      'Rôle modifié',
      `Le rôle a été changé de ${formatRole(props.user.role)} à ${formatRole(newRole.value)}`
    )

    emit('submit')
    emit('close')
  } catch (err) {
    console.error('Error changing user role:', err)
    error.value = (err as any)?.message || 'Une erreur est survenue'
    showToast.error('Erreur', error.value)
  } finally {
    loading.value = false
  }
}
</script>
