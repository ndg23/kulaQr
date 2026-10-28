<template>
  <div>
    <PageHeader title="Gestion des permissions" description="Définissez les permissions pour chaque membre du personnel" />

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <Loader2 class="w-10 h-10 text-gray-900 animate-spin mb-4" />
      <p class="text-sm text-gray-500">Chargement des permissions...</p>
    </div>

    <!-- Staff Permissions -->
    <div v-else class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden">
      <div class="px-6 py-5 border-b border-gray-100">
        <h2 class="text-lg font-extrabold text-gray-900">Permissions par rôle</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Manager Permissions -->
          <div class="border border-gray-200 rounded-3xl p-5">
            <h3 class="font-extrabold text-gray-900 mb-4">Manager</h3>
            <ul class="space-y-2">
              <li v-for="perm in allPermissions" :key="perm.id" class="flex items-center">
                <CheckCircle class="w-5 h-5 text-green-500 mr-2" />
                <span class="text-sm text-gray-700">{{ perm.label }}</span>
              </li>
            </ul>
          </div>
          
          <!-- Staff Permissions -->
          <div class="border border-gray-200 rounded-3xl p-5">
            <h3 class="font-extrabold text-gray-900 mb-4">Staff</h3>
            <ul class="space-y-2">
              <li v-for="perm in staffPermissions" :key="perm.id" class="flex items-center">
                <CheckCircle class="w-5 h-5 text-green-500 mr-2" />
                <span class="text-sm text-gray-700">{{ perm.label }}</span>
              </li>
            </ul>
          </div>
          
          <!-- Kitchen Permissions -->
          <div class="border border-gray-200 rounded-3xl p-5">
            <h3 class="font-extrabold text-gray-900 mb-4">Cuisine</h3>
            <ul class="space-y-2">
              <li v-for="perm in kitchenPermissions" :key="perm.id" class="flex items-center">
                <CheckCircle class="w-5 h-5 text-green-500 mr-2" />
                <span class="text-sm text-gray-700">{{ perm.label }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
      
      <div class="p-6 border-t border-gray-100">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Permissions personnalisées</h2>
        
        <div class="mt-4">
          <p class="text-sm text-gray-500 mb-4">
            Pour attribuer des permissions personnalisées à un membre spécifique, sélectionnez-le ci-dessous:
          </p>
          
          <select
            v-model="selectedStaffId"
            class="w-full md:w-1/2 h-12 px-5 border border-gray-200 rounded-full focus:outline-none focus:border-gray-900"
          >
            <option value="">Sélectionnez un membre du personnel</option>
            <option v-for="staff in staffMembers" :key="staff.id" :value="staff.id">
              {{ staff.username }} ({{ getRoleLabel(staff.role) }})
            </option>
          </select>
          
          <div v-if="selectedStaffId" class="mt-6">
            <h3 class="font-extrabold text-gray-900 mb-4">Permissions pour {{ getSelectedStaffName() }}</h3>
            
            <div class="space-y-4">
              <div v-for="perm in allPermissions" :key="perm.id" class="flex items-center">
                <input
                  :id="`perm-${perm.id}`"
                  type="checkbox"
                  :checked="hasPermission(perm.id)"
                  @change="togglePermission(perm.id)"
                  class="h-5 w-5 text-gray-900 focus:ring-gray-900 border-gray-300 rounded-md"
                />
                <label :for="`perm-${perm.id}`" class="ml-3 text-sm text-gray-700">
                  {{ perm.label }}
                </label>
              </div>
            </div>
            
            <div class="mt-6">
              <button
                @click="savePermissions"
                :disabled="savingPermissions"
                class="inline-flex items-center h-12 px-6 bg-gray-900 text-white rounded-full font-bold hover:bg-gray-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Loader2 v-if="savingPermissions" class="w-4 h-4 mr-1.5 animate-spin" />
                <Save v-else class="w-4 h-4 mr-1.5" />
                Enregistrer les permissions
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { 
  CheckCircle, 
  Loader2, 
  Save 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const route = useRoute()
const { showToast } = useCustomToast()
const { supabase } = useSupabaseWrapper()

const slug = computed(() => route.params.slug)
const loading = ref(true)
const staffMembers = ref([])
const selectedStaffId = ref('')
const selectedStaffPermissions = ref([])
const savingPermissions = ref(false)

// Permissions disponibles
const allPermissions = [
  { id: 'view_dashboard', label: 'Accéder au tableau de bord' },
  { id: 'manage_orders', label: 'Gérer les commandes' },
  { id: 'manage_menu', label: 'Gérer le menu' },
  { id: 'manage_staff', label: 'Gérer le personnel' },
  { id: 'view_kitchen_orders', label: 'Voir les commandes cuisine' },
  { id: 'view_analytics', label: 'Voir les statistiques' },
  { id: 'manage_tables', label: 'Gérer les tables' },
  { id: 'manage_payments', label: 'Gérer les paiements' }
]

// Permissions par défaut par rôle
const staffPermissions = computed(() => 
  allPermissions.filter(p => ['view_dashboard', 'manage_orders', 'manage_tables'].includes(p.id))
)

const kitchenPermissions = computed(() => 
  allPermissions.filter(p => ['view_dashboard', 'view_kitchen_orders'].includes(p.id))
)

// Charger les membres du personnel
const loadStaffMembers = async () => {
  try {
    const { data, error } = await supabase
      .from('staff_pins')
      .select('*')
      .eq('establishment_id', slug.value)
      .order('username')
    
    if (error) throw error
    
    staffMembers.value = data || []
  } catch (error) {
    console.error('Error loading staff members:', error)
    showToast.error('Erreur', 'Impossible de charger les membres du personnel')
  } finally {
    loading.value = false
  }
}

// Charger les permissions d'un membre
const loadStaffPermissions = async (staffId) => {
  try {
    const { data, error } = await supabase
      .from('staff_permissions')
      .select('permission')
      .eq('staff_id', staffId)
    
    if (error) throw error
    
    selectedStaffPermissions.value = data?.map(p => p.permission) || []
  } catch (error) {
    console.error('Error loading staff permissions:', error)
    showToast.error('Erreur', 'Impossible de charger les permissions')
  }
}

// Vérifier si un membre a une permission
const hasPermission = (permissionId) => {
  return selectedStaffPermissions.value.includes(permissionId)
}

// Activer/désactiver une permission
const togglePermission = (permissionId) => {
  if (hasPermission(permissionId)) {
    selectedStaffPermissions.value = selectedStaffPermissions.value.filter(p => p !== permissionId)
  } else {
    selectedStaffPermissions.value.push(permissionId)
  }
}

// Enregistrer les permissions
const savePermissions = async () => {
  if (!selectedStaffId.value) return
  
  savingPermissions.value = true
  
  try {
    // Supprimer toutes les permissions existantes
    const { error: deleteError } = await supabase
      .from('staff_permissions')
      .delete()
      .eq('staff_id', selectedStaffId.value)
    
    if (deleteError) throw deleteError
    
    // Ajouter les nouvelles permissions
    if (selectedStaffPermissions.value.length > 0) {
      const permissionsToInsert = selectedStaffPermissions.value.map(permission => ({
        staff_id: selectedStaffId.value,
        permission
      }))
      
      const { error: insertError } = await supabase
        .from('staff_permissions')
        .insert(permissionsToInsert)
      
      if (insertError) throw insertError
    }
    
    showToast.success('Succès', 'Permissions enregistrées avec succès')
  } catch (error) {
    console.error('Error saving permissions:', error)
    showToast.error('Erreur', 'Impossible d\'enregistrer les permissions')
  } finally {
    savingPermissions.value = false
  }
}

// Obtenir le nom d'un membre sélectionné
const getSelectedStaffName = () => {
  const staff = staffMembers.value.find(s => s.id === selectedStaffId.value)
  return staff ? staff.username : ''
}

// Obtenir le libellé d'un rôle
const getRoleLabel = (role) => {
  const roles = {
    'manager': 'Manager',
    'staff': 'Personnel',
    'waiter': 'Serveur',
    'kitchen': 'Cuisine'
  }
  return roles[role] || role
}

// Surveiller les changements de membre sélectionné
watch(selectedStaffId, (newId) => {
  if (newId) {
    loadStaffPermissions(newId)
  } else {
    selectedStaffPermissions.value = []
  }
})

onMounted(() => {
  loadStaffMembers()
})
</script> 