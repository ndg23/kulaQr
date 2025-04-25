<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Gestion du personnel</h1>
        <p class="mt-1 text-sm text-gray-500">Créez et gérez les accès rapides pour votre équipe</p>
      </div>
      <button
        @click="openStaffModal()"
        class="inline-flex items-center px-4 py-2 bg-kula-500 text-white rounded-full text-sm font-medium hover:bg-kula-600 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Ajouter un membre
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <Loader2 class="w-10 h-10 text-kula-500 animate-spin mb-4" />
      <p class="text-sm text-gray-500">Chargement du personnel...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="staffMembers.length === 0" class="bg-white rounded-2xl border border-gray-100 p-12 text-center">
      <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-kula-50 flex items-center justify-center">
        <Users class="w-8 h-8 text-kula-500" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Aucun membre du personnel</h3>
      <p class="text-gray-500 mb-6 max-w-md mx-auto">
        Vous n'avez pas encore ajouté de membres à votre équipe. Commencez par ajouter votre premier membre.
      </p>
      <button
        @click="openStaffModal()"
        class="inline-flex items-center px-4 py-2 bg-kula-500 text-white rounded-full text-sm font-medium hover:bg-kula-600 transition-colors"
      >
        <Plus class="w-4 h-4 mr-1.5" />
        Ajouter un membre
      </button>
    </div>

    <!-- Staff List -->
    <div v-else class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="p-6 border-b border-gray-100">
        <h2 class="text-lg font-semibold text-gray-900">Personnel</h2>
      </div>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nom
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
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Créé le
              </th>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="staff in staffMembers" :key="staff.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="h-10 w-10 rounded-full bg-kula-50 flex items-center justify-center">
                    <User class="h-5 w-5 text-kula-500" />
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">
                      {{ staff.username }}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-medium rounded-full" 
                  :class="{
                    'bg-kula-100 text-kula-800': staff.role === 'staff',
                    'bg-blue-100 text-blue-800': staff.role === 'waiter',
                    'bg-green-100 text-green-800': staff.role === 'kitchen'
                  }">
                  {{ getRoleName(staff.role) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <span class="text-sm text-gray-900 font-mono">{{ staff.pin }}</span>
                  <button 
                    @click="regeneratePin(staff)"
                    class="ml-2 text-gray-400 hover:text-gray-700"
                    title="Régénérer le PIN"
                  >
                    <RefreshCw class="w-4 h-4" />
                  </button>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-medium rounded-full" 
                  :class="staff.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'">
                  {{ staff.is_active ? 'Actif' : 'Inactif' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(staff.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end space-x-2">
                  <button
                    @click="editStaff(staff)"
                    class="text-gray-400 hover:text-gray-700"
                    title="Modifier"
                  >
                    <Edit class="w-4 h-4" />
                  </button>
                  <button
                    @click="confirmDeleteStaff(staff)"
                    class="text-gray-400 hover:text-red-600"
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
    </div>

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
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-1">
                      Nom d'utilisateur
                    </label>
                    <input
                      id="username"
                      v-model="staffForm.username"
                      type="text"
                      required
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-kula-500 focus:border-kula-500"
                      placeholder="Ex: Jean D."
                    />
                    <p class="mt-1 text-xs text-gray-500">
                      Nom que le membre utilisera pour se connecter avec son PIN
                    </p>
                  </div>
                  
                  <!-- PIN (visible only when editing) -->
                  <div v-if="editingStaff">
                    <div class="flex items-center justify-between">
                      <label class="block text-sm font-medium text-gray-700">
                        PIN actuel
                      </label>
                      <button 
                        type="button"
                        @click="regeneratePin(editingStaff)"
                        class="text-xs text-kula-500 hover:text-kula-600 flex items-center"
                      >
                        <RefreshCw class="w-3 h-3 mr-1" />
                        Régénérer
                      </button>
                    </div>
                    <div class="mt-1 flex items-center space-x-2">
                      <div class="bg-gray-50 px-3 py-2 rounded-lg border border-gray-200 font-mono text-lg w-24 text-center">
                        {{ editingStaff.pin }}
                      </div>
                      <p class="text-xs text-gray-500">
                        Code à 4 chiffres pour la connexion rapide
                      </p>
                    </div>
                  </div>
                  
                  <!-- Role -->
                  <div>
                    <label for="role" class="block text-sm font-medium text-gray-700 mb-1">
                      Rôle
                    </label>
                    <select
                      id="role"
                      v-model="staffForm.role"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-kula-500 focus:border-kula-500"
                    >
                      <option value="waiter">Serveur</option>
                      <option value="kitchen">Cuisine</option>
                      <option value="staff">Personnel</option>
                    </select>
                  </div>
                  
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

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import { 
  Plus, 
  Loader2, 
  User, 
  Users, 
  Edit, 
  Trash2, 
  RefreshCw 
} from 'lucide-vue-next'
import { 
  Dialog, 
  DialogPanel, 
  DialogTitle, 
  TransitionChild, 
  TransitionRoot 
} from '@headlessui/vue'
import { useCustomToast } from '~/composables/useToast'

const route = useRoute()
const supabase = useSupabaseClient()
const { showToast } = useCustomToast()

const slug = route.params.slug
const loading = ref(false)
const formLoading = ref(false)
const staffMembers = ref([])
const showStaffModal = ref(false)
const editingStaff = ref(null)

const staffForm = reactive({
  username: '',
  role: 'waiter',
  is_active: true
})

// Format date
const formatDate = (dateString) => {
  try {
    return format(new Date(dateString), 'dd MMM yyyy, HH:mm', { locale: fr })
  } catch (e) {
    return dateString
  }
}

// Get role name
const getRoleName = (role) => {
  const roles = {
    staff: 'Staff',
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
    
    if (error) throw error
    
    staffMembers.value = data || []
  } catch (error) {
    console.error('Error loading staff:', error)
    showToast.error('Erreur', 'Impossible de charger les membres du personnel')
  } finally {
    loading.value = false
  }
}

// Open staff modal
const openStaffModal = () => {
  editingStaff.value = null
  staffForm.username = ''
  staffForm.role = 'waiter'
  staffForm.is_active = true
  showStaffModal.value = true
}

// Close staff modal
const closeStaffModal = () => {
  showStaffModal.value = false
}

// Edit staff
const editStaff = (staff) => {
  editingStaff.value = staff
  staffForm.username = staff.username
  staffForm.role = staff.role
  staffForm.is_active = staff.is_active
  showStaffModal.value = true
}

// Save staff
const saveStaff = async () => {
  try {
    formLoading.value = true
    
    if (editingStaff.value) {
      // Update existing staff
      const { error } = await supabase
        .from('staff')
        .update({
          username: staffForm.username,
          role: staffForm.role,
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
          role: staffForm.role,
          is_active: staffForm.is_active,
          updated_at: new Date().toISOString()
        }
      }
      
      showToast.success('Succès', 'Membre mis à jour avec succès')
    } else {
      // Create new staff using the function
      const { data, error } = await supabase.rpc('create_staff_pin', {
        p_username: staffForm.username,
        p_establishment_id: slug,
        p_role: staffForm.role
      })
      
      if (error) throw error
      
      // Show PIN to manager
      showToast.success('Nouveau membre créé', `PIN: ${data.pin}`, 10000)
      
      // Reload staff to get the new one with PIN
      await loadStaffMembers()
    }
    
    closeStaffModal()
  } catch (error) {
    console.error('Error saving staff:', error)
    showToast.error('Erreur', error.message || 'Une erreur est survenue')
  } finally {
    formLoading.value = false
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
      
      // If we're editing this staff, update the editing state too
      if (editingStaff.value?.id === staff.id) {
        editingStaff.value.pin = data
      }
    }
    
    showToast.success('Succès', 'PIN régénéré avec succès')
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

// Delete staff
const deleteStaff = async (id) => {
  try {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    // Update local state
    staffMembers.value = staffMembers.value.filter(s => s.id !== id)
    
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
</script> 