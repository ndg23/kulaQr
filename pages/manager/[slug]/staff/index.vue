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

    <main class="max-w-4xl mx-auto px-6 py-8">

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <Loader2 class="w-10 h-10 text-kula-500 animate-spin mb-4" />
      <p class="text-sm text-gray-500">Chargement du personnel...</p>
    </div>

      <!-- Empty State -->
      <ManagerModernCard v-else-if="staffMembers.length === 0" class="p-12 text-center">
        <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
          <Users class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Aucun membre du personnel</h3>
        <p class="text-gray-500 mb-6 max-w-md mx-auto">
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

      <!-- Staff List -->
      <ManagerModernCard v-else class="overflow-hidden">
        <template #header>
          <h2 class="text-lg font-semibold text-gray-900">Membres de l'équipe</h2>
        </template>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Membre
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Rôle
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                PIN
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Statut
              </th>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="member in staffMembers" :key="member.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="h-10 w-10 flex-shrink-0">
                    <div class="h-10 w-10 rounded-full bg-kula-50 flex items-center justify-center">
                      <User class="h-5 w-5 text-kula-500" />
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">
                      {{ member.username }}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-medium rounded-full" 
                  :class="{
                    'bg-kula-100 text-kula-800': member.role === 'manager',
                    'bg-blue-100 text-blue-800': member.role === 'staff',
                    'bg-green-100 text-green-800': member.role === 'waiter',
                    'bg-kula-50 text-kula-700': member.role === 'kitchen'
                  }">
                  {{ getRoleName(member.role) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div class="flex items-center">
                  <span class="text-sm text-gray-900 font-mono">{{ member.pin || '-' }}</span>
                  <button 
                    v-if="member.pin"
                    @click="regeneratePin(member)"
                    class="ml-2 text-gray-400 hover:text-gray-700"
                    title="Régénérer le PIN"
                  >
                    <RefreshCw class="w-4 h-4" />
                  </button>
                  <button 
                    v-else
                    @click="generatePin(member)"
                    class="ml-2 text-gray-400 hover:text-gray-700"
                    title="Générer un PIN"
                  >
                    <Key class="w-4 h-4" />
                  </button>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-medium rounded-full" 
                  :class="{
                    'bg-green-100 text-green-800': member.is_active,
                    'bg-red-100 text-red-800': !member.is_active
                  }">
                  {{ member.is_active ? 'Actif' : 'Inactif' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex justify-end space-x-2">
                  <button 
                    @click="openStaffModal(member)" 
                    class="text-kula-600 hover:text-kula-900"
                    title="Modifier"
                  >
                    <Edit class="w-4 h-4" />
                  </button>
                  <button 
                    @click="confirmDeleteStaff(member)" 
                    class="text-red-600 hover:text-red-900"
                    title="Supprimer"
                  >
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      </ManagerModernCard>
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
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
                <DialogTitle as="h3" class="text-lg font-medium leading-6 text-gray-900 mb-4">
                  {{ editingStaff ? 'Modifier un membre' : 'Ajouter un membre' }}
                </DialogTitle>
                
                <form @submit.prevent="saveStaff" class="space-y-4">
                  <!-- Username -->
                  <div>
                  
                    <FloatLabelInput
                      id="username"
                      v-model="staffForm.username"
                      type="text"
                      required
                      label="Nom d'utilisateur"
                      placeholder="Ex: Jean D."
                    />
                  </div>
                  
                  <!-- Role -->
                  <!-- <div>
                    
                    <FloatLabelSelect
                      id="role"
                      label="Rôle"
                      v-model="staffForm.role"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-kula-500 focus:border-kula-500"
                    >
                      <option value="manager">Manager</option>
                      <option value="staff">Personnel</option>
                      <option value="waiter">Serveur</option>
                      <option value="kitchen">Cuisine</option>
                    </FloatLabelSelect>
                  </div> -->
                  
                  <!-- Active Status -->
                  <div class="flex items-center">
                    <input
                      id="is_active"
                      v-model="staffForm.is_active"
                      type="checkbox"
                      class="h-4 w-4 text-kula-500 focus:ring-kula-500 border-gray-300 rounded"
                    />
                    <label for="is_active" class="ml-2 block text-sm text-gray-700">
                      Compte actif
                    </label>
                  </div>
                  
                  <!-- Buttons -->
                  <div class="mt-6 flex justify-end space-x-3">
                    <button
                      type="button"
                      @click="closeStaffModal"
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kula-500"
                    >
                      Annuler
                    </button>
                    <button
                      type="submit"
                      class="px-4 py-2 text-sm font-medium text-white bg-kula-500 border border-transparent rounded-md hover:bg-kula-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kula-500 relative"
                      :disabled="formLoading"
                    >
                      <span v-if="formLoading" class="absolute inset-0 flex items-center justify-center">
                        <Loader2 class="w-5 h-5 animate-spin" />
                      </span>
                      <span :class="{ invisible: formLoading }">
                        {{ editingStaff ? 'Mettre à jour' : 'Ajouter' }}
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
import { ref, reactive, computed, onMounted, watch } from 'vue'
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

// Open staff modal
const openStaffModal = (staff = null) => {
  if (staff) {
    editingStaff.value = staff
    staffForm.username = staff.username
    staffForm.role = staff.role
    staffForm.is_active = staff.is_active
  } else {
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
    // Update existing staff
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
      
      // Update local state
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
    } 
    // Create new staff
    else {
      // Insert directly without PIN
      const { data, error } = await supabase
        .from('staff')
        .insert({
          username: staffForm.username,
          establishment_id: slug,
          role:"staff",
          pin: staffForm.pin,
          is_active: staffForm.is_active
        })
        .select()
        .single()
      
      if (error) throw error
      
      // Add to local state
      staffMembers.value.unshift(data)
      
      showToast.success('Succès', 'Nouveau membre ajouté avec succès')
    }
    
    closeStaffModal()
  } catch (error) {
    console.error('Error saving staff:', error)
    showToast.error('Erreur', 'Impossible de sauvegarder le membre, veuillez vérifier les champs')
  } finally {
    formLoading.value = false
  }
}

// Generate PIN for staff member
const generatePin = async (staff) => {
  try {
    const { data, error } = await supabase.rpc('create_staff_pin', {
      p_username: staff.username,
      p_establishment_id: slug,
      p_role: staff.role
    })
    
    if (error) throw error
    
    // Update local state
    await loadStaffMembers()
    
    // Show PIN to manager
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
    
    // Update local state
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

// Confirm delete staff
const confirmDeleteStaff = (staff) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer ${staff.username} ?`)) {
    deleteStaff(staff.id)
  }
}

// Delete staff member
const deleteStaff = async (id) => {
  try {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    // Update local state
    staffMembers.value = staffMembers.value.filter((s: any) => s.id !== id)
    
    showToast.success('Succès', 'Membre supprimé avec succès')
  } catch (error) {
    console.error('Error deleting staff:', error)
    showToast.error('Erreur', 'Impossible de supprimer ce membre')
  }
}

// Load data on mount
onMounted(() => {
  loadStaffMembers()
})

// Watch for route changes to reload data
watch(() => route.path, async (newPath, oldPath) => {
  if (newPath !== oldPath) {
    console.log('🔄 Route changed, reloading staff data for path:', newPath)
    await loadStaffMembers()
  }
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style> 