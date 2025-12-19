<template>
  <div class="space-y-4">
    <!-- Filters Bar -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 p-5 bg-white rounded-lg border border-gray-100">
      <div class="flex flex-col sm:flex-row sm:items-center gap-3">
        <div class="relative">
          <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher un utilisateur..."
            class="pl-9 pr-4 py-2.5 border border-gray-200 rounded-lg focus:ring-1 focus:ring-gray-300 focus:border-gray-300 w-full sm:w-64 text-sm transition-all duration-150"
          />
        </div>
        
        <select
          v-model="selectedRole"
          class="px-3 py-2.5 border border-gray-200 rounded-lg focus:ring-1 focus:ring-gray-300 focus:border-gray-300 text-sm transition-all duration-150"
        >
          <option value="">Tous les rôles</option>
          <option value="owner">Propriétaires</option>
          <option value="manager">Managers</option>
          <option value="staff">Personnel</option>
          <option value="admin">Administrateurs</option>
        </select>

        <select
          v-model="selectedTier"
          class="px-3 py-2.5 border border-gray-200 rounded-lg focus:ring-1 focus:ring-gray-300 focus:border-gray-300 text-sm transition-all duration-150"
        >
          <option value="">Tous les plans</option>
          <option value="demo">Démo</option>
          <option value="pro">Pro</option>
          <option value="premium">Premium</option>
        </select>
      </div>

      <div class="flex items-center gap-3">
        <span class="text-sm text-gray-500">{{ filteredUsers.length }} utilisateur{{ filteredUsers.length !== 1 ? 's' : '' }}</span>
        <button
          @click="refreshUsers"
          class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-50 rounded-lg transition-all duration-150"
          title="Actualiser"
        >
          <RefreshCw class="w-4 h-4" />
        </button>
      </div>
    </div>

    <!-- Users List -->
    <div class="bg-white rounded-lg border border-gray-100 overflow-hidden">
      <div class="divide-y divide-gray-50">
        <div
          v-for="user in paginatedUsers"
          :key="user.id"
          class="p-5 hover:bg-gray-50/50 transition-all duration-150"
        >
          <div class="flex items-center justify-between">
            <!-- User Info -->
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center text-gray-600 font-medium">
                {{ getUserInitials(user.full_name) }}
              </div>
              
              <div>
                <div class="flex items-center gap-3">
                  <h3 class="font-medium text-gray-900">{{ user.full_name }}</h3>
                  <span :class="getRoleBadgeClass(user.role)" class="inline-flex items-center px-2 py-1 rounded text-xs font-medium border">
                    {{ getRoleLabel(user.role) }}
                  </span>
                </div>
                <div class="flex items-center gap-4 mt-1.5 text-sm text-gray-500">
                  <span>{{ user.email }}</span>
                  <span v-if="user.phone">{{ user.phone }}</span>
                  <div class="flex items-center gap-2">
                    <span :class="getTierBadgeClass(user.subscription_tier)" class="inline-flex items-center px-2 py-1 rounded text-xs font-medium border">
                      {{ getTierLabel(user.subscription_tier) }}
                    </span>
                    <span :class="getStatusBadgeClass(user.subscription_status)" class="inline-flex items-center px-2 py-1 rounded text-xs font-medium border">
                      {{ getStatusLabel(user.subscription_status) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Actions Dropdown -->
            <ActionDropdown
              :actions="getUserActions(user)"
              @action="handleUserAction"
            />
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="filteredUsers.length === 0" class="p-8 text-center">
          <Users class="w-12 h-12 mx-auto text-gray-300 mb-3" />
          <p class="text-gray-500">Aucun utilisateur trouvé</p>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="border-t border-gray-200 px-4 py-3 flex items-center justify-between">
        <div class="text-sm text-gray-700">
          Page {{ currentPage }} sur {{ totalPages }}
        </div>
        <div class="flex items-center gap-2">
          <button
            @click="currentPage--"
            :disabled="currentPage === 1"
            class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Précédent
          </button>
          <button
            @click="currentPage++"
            :disabled="currentPage === totalPages"
            class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <SubscriptionManagementModal
      :open="showSubscriptionModal"
      :user="selectedUser"
      @close="showSubscriptionModal = false"
      @success="handleModalSuccess"
    />

    <UserFormModal
      :open="showUserModal"
      :user="selectedUser"
      @close="showUserModal = false"
      @success="handleModalSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Search, RefreshCw, Users, Edit, CreditCard, 
  UserCog, Trash2, Ban, CheckCircle
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

const loading = ref(false)
const users = ref<any[]>([])
const searchQuery = ref('')
const selectedRole = ref('')
const selectedTier = ref('')
const currentPage = ref(1)
const itemsPerPage = 10

// Modals
const showSubscriptionModal = ref(false)
const showUserModal = ref(false)
const selectedUser = ref<any>(null)

// Computed
const filteredUsers = computed(() => {
  let filtered = users.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(user => 
      user.full_name?.toLowerCase().includes(query) ||
      user.email?.toLowerCase().includes(query)
    )
  }

  if (selectedRole.value) {
    filtered = filtered.filter(user => user.role === selectedRole.value)
  }

  if (selectedTier.value) {
    filtered = filtered.filter(user => user.subscription_tier === selectedTier.value)
  }

  return filtered
})

const totalPages = computed(() => Math.ceil(filteredUsers.value.length / itemsPerPage))

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredUsers.value.slice(start, end)
})

// Load users
const loadUsers = async () => {
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    users.value = data || []
  } catch (err) {
    console.error('Error loading users:', err)
    showToast.error('Erreur lors du chargement des utilisateurs')
  } finally {
    loading.value = false
  }
}

// Get user actions
const getUserActions = (user: any) => {
  const actions = [
    {
      id: 'edit',
      label: 'Modifier',
      icon: Edit,
      variant: 'primary' as const,
      callback: () => editUser(user)
    },
    {
      id: 'subscription',
      label: 'Gérer Abonnement',
      icon: CreditCard,
      variant: 'primary' as const,
      callback: () => manageSubscription(user)
    },
    {
      id: 'role',
      label: 'Changer Rôle',
      icon: UserCog,
      variant: 'secondary' as const,
      callback: () => changeRole(user)
    }
  ]

  // Add status-specific actions
  if (user.subscription_status === 'active') {
    actions.push({
      id: 'suspend',
      label: 'Suspendre',
      icon: Ban,
      variant: 'danger' as const,
      callback: () => suspendUser(user)
    })
  } else if (user.subscription_status === 'suspended') {
    actions.push({
      id: 'reactivate',
      label: 'Réactiver',
      icon: CheckCircle,
      variant: 'primary' as const,
      callback: () => reactivateUser(user)
    })
  }

  // Add delete for non-admin users
  if (user.role !== 'admin') {
    actions.push({
      id: 'delete',
      label: 'Supprimer',
      icon: Trash2,
      variant: 'danger' as const,
      callback: () => deleteUser(user)
    })
  }

  return actions
}

// Action handlers
const editUser = (user: any) => {
  selectedUser.value = user
  showUserModal.value = true
}

const manageSubscription = (user: any) => {
  selectedUser.value = user
  showSubscriptionModal.value = true
}

const changeRole = async (user: any) => {
  const roles = [
    { value: 'owner', label: 'Propriétaire' },
    { value: 'manager', label: 'Manager' },
    { value: 'staff', label: 'Personnel' },
    { value: 'admin', label: 'Administrateur' }
  ]

  const currentRole = user.role
  const newRole = prompt(`Nouveau rôle pour ${user.full_name}:\n${roles.map(r => `${r.value} - ${r.label}`).join('\n')}`, currentRole)
  
  if (newRole && newRole !== currentRole && roles.some(r => r.value === newRole)) {
    try {
      const { error } = await supabase
        .from('users')
        .update({ role: newRole })
        .eq('id', user.id)

      if (error) throw error

      showToast.success('Rôle mis à jour avec succès')
      await loadUsers()
    } catch (err) {
      console.error('Error updating role:', err)
      showToast.error('Erreur lors de la mise à jour du rôle')
    }
  }
}

const suspendUser = async (user: any) => {
  if (!confirm(`Suspendre l'utilisateur ${user.full_name} ?`)) return

  try {
    const { error } = await supabase
      .from('users')
      .update({ subscription_status: 'suspended' })
      .eq('id', user.id)

    if (error) throw error

    showToast.success('Utilisateur suspendu avec succès')
    await loadUsers()
  } catch (err) {
    console.error('Error suspending user:', err)
    showToast.error('Erreur lors de la suspension')
  }
}

const reactivateUser = async (user: any) => {
  try {
    const { error } = await supabase
      .from('users')
      .update({ subscription_status: 'active' })
      .eq('id', user.id)

    if (error) throw error

    showToast.success('Utilisateur réactivé avec succès')
    await loadUsers()
  } catch (err) {
    console.error('Error reactivating user:', err)
    showToast.error('Erreur lors de la réactivation')
  }
}

const deleteUser = async (user: any) => {
  if (!confirm(`Supprimer définitivement l'utilisateur ${user.full_name} ?\nCette action est irréversible.`)) return

  try {
    const { error } = await supabase.auth.admin.deleteUser(user.id)
    if (error) throw error

    showToast.success('Utilisateur supprimé avec succès')
    await loadUsers()
  } catch (err) {
    console.error('Error deleting user:', err)
    showToast.error('Erreur lors de la suppression')
  }
}

// Handle action from dropdown
const handleUserAction = (action: any) => {
  // Actions are handled by their callbacks
}

// Handle modal success
const handleModalSuccess = () => {
  loadUsers()
}

// Refresh users
const refreshUsers = () => {
  loadUsers()
}

// Helper functions
const getUserInitials = (name: string) => {
  return name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2) || 'U'
}

const getRoleLabel = (role: string) => {
  const roleMap = {
    owner: 'Propriétaire',
    manager: 'Manager',
    staff: 'Personnel',
    admin: 'Admin'
  }
  return roleMap[role] || role
}

const getRoleBadgeClass = (role: string) => {
  const classMap: Record<string, string> = {
    owner: 'bg-white text-purple-700 border-purple-200',
    manager: 'bg-white text-blue-700 border-blue-200',
    staff: 'bg-white text-green-700 border-green-200',
    admin: 'bg-white text-red-700 border-red-200'
  }
  return classMap[role] || 'bg-white text-gray-700 border-gray-200'
}

const getTierLabel = (tier: string) => {
  const tierMap: Record<string, string> = {
    demo: 'Démo',
    pro: 'Pro',
    premium: 'Premium'
  }
  return tierMap[tier] || tier
}

const getTierBadgeClass = (tier: string) => {
  const classMap: Record<string, string> = {
    demo: 'bg-white text-blue-700 border-blue-200',
    pro: 'bg-white text-green-700 border-green-200',
    premium: 'bg-white text-purple-700 border-purple-200'
  }
  return classMap[tier] || 'bg-white text-gray-700 border-gray-200'
}

const getStatusLabel = (status: string) => {
  const statusMap: Record<string, string> = {
    active: 'Actif',
    pending_activation: 'En attente',
    expired: 'Expiré',
    cancelled: 'Annulé',
    suspended: 'Suspendu'
  }
  return statusMap[status] || status
}

const getStatusBadgeClass = (status: string) => {
  const classMap: Record<string, string> = {
    active: 'bg-white text-green-700 border-green-200',
    pending_activation: 'bg-white text-yellow-700 border-yellow-200',
    expired: 'bg-white text-red-700 border-red-200',
    cancelled: 'bg-white text-gray-700 border-gray-200',
    suspended: 'bg-white text-orange-700 border-orange-200'
  }
  return classMap[status] || 'bg-white text-gray-700 border-gray-200'
}

// Load data on mount
onMounted(() => {
  loadUsers()
})
</script>