<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Gestion du personnel"
      subtitle="Gérez les membres de votre équipe et leurs accès"
      :icon="Users"
      :primary-action="{
        label: 'Ajouter un membre',
        icon: Plus,
        action: openStaffModal
      }"
    />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
      <!-- Loading State -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-16">
        <Loader2 class="w-10 h-10 text-kula-500 animate-spin mb-4" />
        <p class="text-sm text-gray-500">Chargement du personnel...</p>
      </div>

      <!-- Empty State -->
      <ManagerModernCard v-else-if="staffMembers.length === 0" class="p-8 sm:p-12 text-center">
        <div class="w-16 h-16 sm:w-20 sm:h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
          <Users class="w-7 h-7 sm:w-8 sm:h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Aucun membre du personnel</h3>
        <p class="text-sm sm:text-base text-gray-500 mb-6 max-w-md mx-auto">
          Vous n'avez pas encore ajouté de membres à votre équipe. Commencez par ajouter votre premier membre.
        </p>
        <ManagerModernButton
          variant="primary"
          @click="openStaffModal"
          :icon="Plus"
        >
          Ajouter un membre
        </ManagerModernButton>
      </ManagerModernCard>

      <!-- Staff List - Desktop Table -->
      <ManagerModernCard v-else class="hidden lg:block overflow-hidden">
        <template #header>
          <h2 class="text-lg font-semibold text-gray-900">Membres de l'équipe</h2>
        </template>
      
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Membre
                </th>
                <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  PIN
                </th>
                <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Statut
                </th>
                <th scope="col" class="relative px-6 py-3.5">
                  <span class="sr-only">Actions</span>
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-100">
              <tr v-for="member in staffMembers" :key="member.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="h-10 w-10 flex-shrink-0 rounded-full bg-gradient-to-br from-kula-400 to-kula-600 flex items-center justify-center">
                      <User class="h-5 w-5 text-white" />
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">
                        {{ member.username }}
                      </div>
                      <div class="text-xs text-gray-500">
                        {{ getRoleName(member.role) }}
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center gap-2">
                    <span class="text-sm text-gray-900 font-mono bg-gray-100 px-2.5 py-1 rounded-md">
                      {{ member.pin || '-' }}
                    </span>
                    <button 
                      v-if="member.pin"
                      @click="regeneratePin(member)"
                      class="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-100 rounded-md transition-colors"
                      title="Régénérer le PIN"
                    >
                      <RefreshCw class="w-4 h-4" />
                    </button>
                    <button 
                      v-else
                      @click="generatePin(member)"
                      class="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-100 rounded-md transition-colors"
                      title="Générer un PIN"
                    >
                      <Key class="w-4 h-4" />
                    </button>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <AppleSwitch 
                    :model-value="member.is_active"
                    @update:model-value="toggleStaffStatus(member, $event)"
                  />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right">
                  <div class="flex justify-end gap-1">
                    <button 
                      @click="openStaffModal(member)" 
          class="w-10 h-10 bg-white/95 backdrop-blur-sm rounded-full flex items-center justify-center border border-gray-200  transition-all duration-200 hover:scale-10 z-10"
                      title="Modifier"
                    >
                      <Edit class="w-5 h-5 text-gray-400" />
                    </button>
                    <button 
                      @click="confirmDeleteStaff(member)" 
          class="w-10 h-10 bg-white/95 backdrop-blur-sm rounded-full flex items-center justify-center border border-gray-200  transition-all duration-200 hover:scale-10 z-10"
                      title="Supprimer"
                    >
                      <Trash2 class="w-5 h-5 text-gray-400" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </ManagerModernCard>

      <!-- Staff List - Mobile Cards -->
      <div v-if="!loading && staffMembers.length > 0" class="lg:hidden space-y-3">
        <div 
          v-for="member in staffMembers" 
          :key="member.id"
          class="bg-white rounded-2xl p-4  border border-gray-100"
        >
          <!-- Header -->
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-3">
              <div class="h-12 w-12 rounded-full bg-gradient-to-br from-kula-400 to-kula-600 flex items-center justify-center">
                <User class="h-6 w-6 text-white" />
              </div>
              <div>
                <h3 class="text-base font-semibold text-gray-900">{{ member.username }}</h3>
                <p class="text-xs text-gray-500">{{ getRoleName(member.role) }}</p>
              </div>
            </div>
            <AppleSwitch 
              :model-value="member.is_active"
              @update:model-value="toggleStaffStatus(member, $event)"
              class="scale-90"
            />
          </div>

          <!-- PIN Section -->
          <div class="flex items-center justify-between py-3 px-3 bg-gray-50 rounded-xl mb-3">
            <div class="flex items-center gap-2">
              <Key class="w-4 h-4 text-gray-400" />
              <span class="text-sm text-gray-600">PIN</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-sm font-mono font-medium text-gray-900">
                {{ member.pin || '----' }}
              </span>
              <button 
                v-if="member.pin"
                @click="regeneratePin(member)"
                class="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-200 rounded-lg transition-colors"
              >
                <RefreshCw class="w-3.5 h-3.5" />
              </button>
              <button 
                v-else
                @click="generatePin(member)"
                class="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-200 rounded-lg transition-colors"
              >
                <Plus class="w-3.5 h-3.5" />
              </button>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-2">
            <button 
              @click="openStaffModal(member)"
              class="flex-1 flex items-center justify-center gap-2 py-2.5 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
            >
              <Edit class="w-4 h-4" />
              Modifier
            </button>
            <button 
              @click="confirmDeleteStaff(member)"
              class="flex-1 flex items-center justify-center gap-2 py-2.5 text-sm font-medium text-red-600 bg-red-50 hover:bg-red-100 rounded-xl transition-colors"
            >
              <Trash2 class="w-4 h-4" />
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </main>

    <!-- Staff Modal -->
    <TransitionRoot appear :show="showStaffModal" as="template">
      <Dialog as="div" @close="closeStaffModal" class="relative z-50">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-3xl bg-white p-6 sm:p-8 shadow-2xl transition-all">
                <DialogTitle as="h3" class="text-xl font-semibold text-gray-900 mb-6">
                  {{ isEditing.value ? 'Modifier un membre' : 'Ajouter un membre' }}
                </DialogTitle>
                
                <form @submit.prevent="saveStaff" class="space-y-5">
                  <!-- Username -->
                  <FloatLabelInput
                    id="username"
                    v-model="staffForm.username"
                    type="text"
                    required
                    label="Nom d'utilisateur"
                    placeholder="Ex: Jean D."
                  />
                  
                  <!-- Active Status -->
                  <div class="flex items-center justify-between py-4 px-4 bg-gray-50 rounded-2xl">
                    <label for="is_active" class="text-sm font-medium text-gray-700">
                      Compte actif
                    </label>
                    <AppleSwitch
                      id="is_active"
                      v-model="staffForm.is_active"
                    />
                  </div>
                  
                  <!-- Buttons -->
                  <div class="flex gap-3 pt-2">
                    <button
                      type="button"
                      @click="closeStaffModal"
                      class="flex-1 px-4 py-3 text-sm font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
                    >
                      Annuler
                    </button>
                    <button
                      type="submit"
                      class="flex-1 px-4 py-3 text-sm font-semibold text-white bg-kula-500 hover:bg-kula-600 rounded-xl transition-colors relative disabled:opacity-50"
                      :disabled="formLoading"
                    >
                      <span v-if="formLoading" class="absolute inset-0 flex items-center justify-center">
                        <Loader2 class="w-5 h-5 animate-spin" />
                      </span>
                      <span :class="{ invisible: formLoading }">
                        {{ isEditing.value ? 'Mettre à jour' : 'Ajouter' }}
                      </span>
                    </button>
                  </div>
                </form>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { 
  TransitionRoot, 
  TransitionChild, 
  Dialog, 
  DialogPanel, 
  DialogTitle 
} from '@headlessui/vue'
import { 
  User, 
  Users, 
  Edit, 
  Trash2, 
  Plus, 
  Loader2,
  RefreshCw,
  Key
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import AppleSwitch from '~/components/AppleSwitch.vue'

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const { slug } = route.params

// State
const staffMembers = ref([] as any[])
const loading = ref(true)
const showStaffModal = ref(false)
const editingStaff = ref(null)
const formLoading = ref(false)
const isEditing = ref(false)
// Form state
const staffForm = reactive({
  username: '',
  role: 'staff',
  pin: 1234,
  is_active: true
})

definePageMeta({
  layout: 'manager'
})

// Get role name
const getRoleName = (role: string) => {
  const roles = {
    manager: 'Manager',
    staff: 'Personnel',
    waiter: 'Serveur',
    kitchen: 'Cuisine'
  }
  return roles[role] || role
}

// Load staff members
const loadStaffMembers = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('staff')
      .select('*')
      .eq('establishment_id', slug)
      .order('created_at', { ascending: false })
      .limit(100)
    
    if (error) throw error
    
    staffMembers.value = data || [] as any[]
  } catch (error) {
    console.error('Error loading staff members:', error)
    showToast.error('Erreur', 'Impossible de charger les membres du personnel')
  } finally {
    loading.value = false
  }
}

// Toggle staff status
const toggleStaffStatus = async (member, newStatus) => {
  try {
    const { error } = await supabase
      .from('staff')
      .update({ 
        is_active: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', member.id)
    
    if (error) throw error
    
    // Update local state
    const index = staffMembers.value.findIndex(s => s.id === member.id)
    if (index !== -1) {
      staffMembers.value[index].is_active = newStatus
    }
    
    showToast.success('Succès', `${member.username} est maintenant ${newStatus ? 'actif' : 'inactif'}`)
  } catch (error) {
    console.error('Error toggling staff status:', error)
    showToast.error('Erreur', 'Impossible de modifier le statut')
  }
}

// Open staff modal
const openStaffModal = (staff = null) => {
  if (staff) {
    isEditing.value = true
    editingStaff.value = staff
    staffForm.username = staff.username
    staffForm.role = staff.role
    staffForm.is_active = staff.is_active
  } else {
    isEditing.value = false
    editingStaff.value = null
    staffForm.username = ''
    staffForm.role = 'staff'
    staffForm.is_active = true
  }
  showStaffModal.value = true
}

// Close staff modal
const closeStaffModal = () => {
  showStaffModal.value = false
  setTimeout(() => {
    editingStaff.value = null
  }, 300)
}

// Save staff
const saveStaff = async () => {
  formLoading.value = true
  
  try {
    if (editingStaff.value?.id) {
      const { error } = await supabase
        .from('staff')
        .update({
          username: staffForm.username,
          is_active: staffForm.is_active,
          updated_at: new Date().toISOString()
        })
        .eq('id', editingStaff.value.id)
      
      if (error) throw error
      
      const index = staffMembers.value.findIndex(s => s.id === editingStaff.value.id)
      if (index !== -1) {
        staffMembers.value[index] = {
          ...staffMembers.value[index],
          username: staffForm.username,
          is_active: staffForm.is_active,
          updated_at: new Date().toISOString()
        }
      }
      
      showToast.success('Succès', 'Membre mis à jour avec succès')
    } else {
      const { data, error } = await supabase
        .from('staff')
        .insert({
          username: staffForm.username,
          establishment_id: slug,
          role: "staff",
          pin: staffForm.pin,
          is_active: staffForm.is_active
        })
        .select()
        .single()
      
      if (error) throw error
      
      staffMembers.value.unshift(data)
      showToast.success('Succès', 'Nouveau membre ajouté avec succès')
    }
    
    closeStaffModal()
  } catch (error) {
    console.error('Error saving staff:', error)
    showToast.error('Erreur', 'Impossible de sauvegarder le membre')
  } finally {
    formLoading.value = false
  }
}

// Generate PIN
const generatePin = async (staff) => {
  try {
    const { data, error } = await supabase.rpc('create_staff_pin', {
      p_username: staff.username,
      p_establishment_id: slug,
      p_role: staff.role
    })
    
    if (error) throw error
    
    await loadStaffMembers()
    showToast.success('PIN généré', `PIN: ${data.pin}`)
  } catch (error) {
    console.error('Error generating PIN:', error)
    showToast.error('Erreur', 'Impossible de générer un PIN')
  }
}

// Regenerate PIN
const regeneratePin = async (staff) => {
  try {
    const { data, error } = await supabase.rpc('regenerate_staff_pin', {
      p_staff_id: staff.id
    })
    
    if (error) throw error
    
    const index = staffMembers.value.findIndex(s => s.id === staff.id)
    if (index !== -1) {
      staffMembers.value[index].pin = data
    }
    
    showToast.success('PIN régénéré', `Nouveau PIN: ${data}`)
  } catch (error) {
    console.error('Error regenerating PIN:', error)
    showToast.error('Erreur', 'Impossible de régénérer le PIN')
  }
}

// Confirm delete
const confirmDeleteStaff = (staff) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer ${staff.username} ?`)) {
    deleteStaff(staff.id)
  }
}

// Delete staff
const deleteStaff = async (id) => {
  try {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    staffMembers.value = staffMembers.value.filter((s: any) => s.id !== id)
    showToast.success('Succès', 'Membre supprimé avec succès')
  } catch (error) {
    console.error('Error deleting staff:', error)
    showToast.error('Erreur', 'Impossible de supprimer ce membre')
  }
}

onMounted(() => {
  loadStaffMembers()
})

watch(() => route.path, async (newPath, oldPath) => {
  if (newPath !== oldPath) {
    await loadStaffMembers()
  }
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>