<template>
  <div class="py-6">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-semibold text-gray-900 mb-2">Utilisateurs</h1>
      <p class="text-gray-600">Gérez vos utilisateurs et leurs permissions</p>
    </div>    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
      <div v-for="stat in statsDisplay" :key="stat.name" 
        class="bg-white p-6 rounded-2xl border border-gray-100 hover:border-gray-200 transition-colors"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-500 mb-2">{{ stat.name }}</p>
            <h3 class="text-4xl font-black text-gray-900">{{ stat.value }}</h3>
          </div>
          <div class="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center">
            <component :is="stat.icon" class="w-6 h-6 text-gray-700" />
          </div>
        </div>
      </div>
    </div>      <!-- Users List with DataTable -->
      <DataTable
        :items="users"
        :columns="tableColumns"
        :loading="loading"
        :current-page="currentPage"
        :per-page="perPage"
        :total-items="filteredUsers.length"
        :show-pagination="true"
        :show-add-button="true"
        add-button-label="Ajouter"
        :header-buttons="[
          { label: 'Manager + Établissement', icon: 'fas fa-store', variant: 'success', action: 'add-manager-establishment' },
          { label: 'Importer', icon: 'fas fa-upload', variant: 'secondary', action: 'import' },
          { label: 'Rafraîchir', icon: 'fas fa-sync', variant: 'secondary', action: 'refresh' }
        ]"
        empty-title="Aucun utilisateur trouvé"
        empty-description="Aucun utilisateur ne correspond à vos critères de recherche"
        empty-icon="fas fa-users"
        @page-change="currentPage = $event"
        @update:per-page="perPage = $event"
        @add="showUserModal = true"
        @button-click="handleButtonClick"
      >
        <!-- User Column with Avatar -->
        <template #cell-full_name="{ item }">
          <div class="flex items-center space-x-3 min-w-[200px]">
            <div 
              class="w-8 h-8 rounded-full flex items-center justify-center text-white text-sm font-medium flex-shrink-0"
              :class="`bg-${getUserColor(item.id)}-500`"
            >
              {{ getUserInitials(item.full_name) }}
            </div>
            <div class="min-w-0 flex-1">
              <div class="font-medium text-gray-900 truncate">{{ item.full_name }}</div>
              <div class="text-xs text-gray-500 truncate">{{ item.email }}</div>
            </div>
          </div>
        </template>

        <!-- Role Column -->
        <template #cell-role="{ item }">
          <span
            class="px-2 py-1 rounded-md text-xs font-medium whitespace-nowrap"
            :class="getRoleBadgeClass(item.role)"
          >
            {{ formatRole(item.role) }}
          </span>
        </template>

        <!-- Subscription Column -->
        <template #cell-subscription_tier="{ item }">
          <span
            class="px-2 py-1 rounded-md text-xs font-medium whitespace-nowrap"
            :class="getSubscriptionBadgeClass(item.subscription_tier)"
          >
            {{ formatSubscriptionTier(item.subscription_tier) }}
          </span>
        </template>

        <!-- Status Column -->
        <template #cell-is_active="{ item }">
          <span
            class="px-2 py-1 rounded-md text-xs font-medium inline-flex items-center whitespace-nowrap"
            :class="item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
          >
            <div 
              class="w-1.5 h-1.5 rounded-full mr-1.5 flex-shrink-0"
              :class="item.is_active ? 'bg-green-500' : 'bg-red-500'"
            />
            {{ item.is_active ? 'Actif' : 'Inactif' }}
          </span>
        </template>

        <!-- Actions Column -->
        <template #cell-actions="{ item }">
          <ActionDropdown
            :actions="getUserActions(item)"
            @action="handleUserAction"
            trigger-text="Actions"
          />
        </template>
      </DataTable>
  
    <!-- User Modal -->
    <UserFormModal
      v-if="showUserModal"
      :open="showUserModal"
      :user="selectedUser"
      @close="closeUserModal"
      @submit="handleUserSubmitted"
    />

    <!-- Role Change Modal -->
    <RoleChangeModal
      :open="showRoleChangeModal"
      :user="selectedUser"
      @close="showRoleChangeModal = false"
      @submit="handleRoleChanged"
    />

    <!-- Establishment Assignment Modal -->
    <EstablishmentAssignmentModal
      :open="assignmentModal.modalOpen.value"
      :mode="assignmentModal.modalOptions.value.mode"
      :establishment="assignmentModal.modalOptions.value.establishment"
      @close="assignmentModal.closeModal"
      @success="handleEstablishmentAssignmentSuccess"
    />

    <!-- Subscription Management Modal -->
    <SubscriptionManagementModal
      :open="showSubscriptionModal"
      :user="selectedUser"
      @close="showSubscriptionModal = false"
      @success="handleModalSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue'
// import { Users, UserPlus, UserCheck, Shield, Search, Edit, Trash2, RefreshCw, X, CheckCircle, AlertTriangle, Info, Users, ChevronLeft, ChevronRight, Eye, EyeOff, User, Download, UserPlus, UserCheck, UserX, Shield, Mail, Ban, Loader2 } from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
// import { UTable, UPagination } from '@/components/ui/table'
import { 
  Plus, Edit, Trash2, RefreshCw, X, CheckCircle, AlertTriangle, 
  Info, Users, ChevronLeft, ChevronRight, Eye, EyeOff, User, Download,
  UserPlus, UserCheck, UserX, Shield, Mail, Ban, Loader2, Search, 
  CreditCard, UserCog
} from 'lucide-vue-next';
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild, Switch } from '@headlessui/vue'
import UserFormModal from '~/components/admin/UserFormModal.vue'
import RoleChangeModal from '~/components/admin/RoleChangeModal.vue'
import EstablishmentAssignmentModal from '~/components/admin/EstablishmentAssignmentModal.vue'
import ActionDropdown from '~/components/admin/ActionDropdown.vue'
import SubscriptionManagementModal from '~/components/admin/SubscriptionManagementModal.vue'
// import { UDropdown } from '@/components/ui/dropdown'

const {showToast} = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const loading = ref(false)
const showUserModal = ref(false)
const showRoleChangeModal = ref(false)
// Import establishment assignment composable
import { useEstablishmentAssignment } from '~/composables/useEstablishmentAssignment'
const assignmentModal = useEstablishmentAssignment()
const showSubscriptionModal = ref(false)
const selectedUser = ref(null)
const currentPage = ref(1)
const perPage = ref(10)

// State
const users = ref<any[]>([])
const stats = ref({
  total: 0,
  active: 0,
  admin: 0
})

// Filters
const filters = ref({
  search: '',
  role: '',
  subscription_tier: ''
})

// User form
const userForm = reactive({
  full_name: '',
  email: '',
  role: 'owner',
  is_active: true,
  subscription_tier: 'free',
  subscription_ends_at: null
})

// Options for selects
const roleOptions = [
  { label: 'Propriétaire', value: 'owner' },
  { label: 'Staff', value: 'staff' },
  { label: 'Admin', value: 'admin' }
]

const subscriptionOptions = [
  { label: 'Gratuit', value: 'free' },
  { label: 'Premium', value: 'premium' },
  { label: 'Pro', value: 'pro' }
]

// Table columns
const columns = [
  {
    key: 'full_name',
    label: 'Utilisateur',
    sortable: true,
    id: 'user-col'
  },
  {
    key: 'role',
    label: 'Rôle',
    sortable: true,
    id: 'role-col'
  },
  {
    key: 'subscription_tier',
    label: 'Abonnement',
    sortable: true,
    id: 'subscription-col'
  },
  {
    key: 'is_active',
    label: 'Statut',
    sortable: true,
    id: 'status-col'
  },
  {
    key: 'created_at',
    label: 'Créé le',
    sortable: true,
    id: 'created-col',
    type: 'date'
  },
  {
    key: 'last_login',
    label: 'Dernière connexion',
    sortable: true,
    id: 'last-login-col',
    type: 'datetime'
  },
  {
    key: 'actions',
    label: 'Actions',
    sortable: false
  }
]

// Table columns for DataTable component
const tableColumns = [
  {
    key: 'full_name',
    label: 'Utilisateur',
    sortable: true,
    width: '25%'
  },
  {
    key: 'role',
    label: 'Rôle',
    sortable: true,
    width: '12%'
  },
  {
    key: 'subscription_tier',
    label: 'Abonnement',
    sortable: true,
    width: '12%'
  },
  {
    key: 'is_active',
    label: 'Statut',
    sortable: true,
    width: '10%'
  },
  {
    key: 'created_at',
    label: 'Créé le',
    sortable: true,
    type: 'date' as const,
    width: '12%'
  },
  {
    key: 'last_login',
    label: 'Dernière connexion',
    sortable: true,
    type: 'datetime' as const,
    width: '17%'
  },
  {
    key: 'actions',
    label: 'Actions',
    sortable: false,
    width: '12%'
  }
]

// Load users data
const loadUsers = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    users.value = data

    // Calculate stats
    stats.value = {
      total: data.length,
      active: data.filter(u => u.is_active).length,
      admin: data.filter(u => u.role === 'admin').length
    }
    console.log(users.value)
    loading.value = false
  } catch (err) {
    console.error('Error loading users:', err)
    showToast.error('Impossible de charger les utilisateurs', 'error')
  } finally {
    loading.value = false
  }
}

// Computed stats for display
const statsDisplay = computed(() => [
  { 
    name: 'Total utilisateurs', 
    value: stats.value.total.toString(),
    icon: Users
  },
  { 
    name: 'Utilisateurs actifs', 
    value: stats.value.active.toString(),
    icon: UserCheck
  },
  { 
    name: 'Administrateurs', 
    value: stats.value.admin.toString(),
    icon: Shield
  }
])

// Filtered users
const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const matchesSearch = !filters.value.search || 
      user.full_name?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      user.email?.toLowerCase().includes(filters.value.search.toLowerCase())
    
    const matchesRole = !filters.value.role || user.role === filters.value.role
    const matchesSubscription = !filters.value.subscription_tier || user.subscription_tier === filters.value.subscription_tier

    return matchesSearch && matchesRole && matchesSubscription
  })
})

// Pagination info
const paginationInfo = computed(() => {
  const start = (currentPage.value - 1) * perPage.value + 1
  const end = Math.min(start + perPage.value - 1, filteredUsers.value.length)
  return {
    showing: `${start}-${end}`,
    total: filteredUsers.value.length
  }
})

// Helper methods
const getUserInitials = (name: string) => {
  if (!name) return '?'
  return name.split(' ')
    .map((word: string) => word[0])
    .join('')
    .toUpperCase()
    .substring(0, 2)
}

const getUserColor = (id: string) => {
  const colors = ['blue', 'green', 'red', 'yellow', 'purple', 'pink', 'orange', 'cyan', 'teal', 'indigo', 'lime', 'emerald', 'fuchsia', 'rose', 'amber', 'violet', 'sky','gray', 'slate', 'stone', 'neutral', 'zinc', 'burgundy', 'navy', 'olive', 'maroon', 'turquoise', 'magenta']
  const index = Math.abs(hashString(id.toString()) % colors.length)
  return colors[index]
}

const hashString = (str: string) => {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    hash = ((hash << 5) - hash) + str.charCodeAt(i)
    hash = hash & hash
  }
  return hash
}

const getRoleColor = (role: string) => {
  switch (role) {
    case 'admin': return 'purple'
    case 'manager': return 'blue'
    case 'staff': return 'green'
    case 'owner': return 'orange'
    default: return 'gray'
  }
}

const getRoleBadgeClass = (role: string) => {
  switch (role) {
    case 'admin': return 'bg-purple-100 text-purple-800'
    case 'manager': return 'bg-blue-100 text-blue-800'
    case 'staff': return 'bg-green-100 text-green-800'
    case 'owner': return 'bg-orange-100 text-orange-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const getSubscriptionColor = (tier: string) => {
  const colors: Record<string, string> = {
    'free': 'gray',
    'premium': 'purple',
    'pro': 'blue'
  }
  return colors[tier] || 'gray'
}

const getSubscriptionBadgeClass = (tier: string) => {
  const classes: Record<string, string> = {
    'free': 'bg-gray-100 text-gray-800',
    'premium': 'bg-purple-100 text-purple-800',
    'pro': 'bg-blue-100 text-blue-800'
  }
  return classes[tier] || 'bg-gray-100 text-gray-800'
}

const formatSubscriptionTier = (tier: string) => {
  const formats: Record<string, string> = {
    'free': 'Gratuit',
    'premium': 'Premium',
    'pro': 'Pro'
  }
  return formats[tier] || tier
}

// Formatage des rôles
const formatRole = (role: string) => {
  const roles: Record<string, string> = {
    'admin': 'Administrateur',
    'manager': 'Gérant',
    'staff': 'Staff',
    'owner': 'Propriétaire'
  }
  return roles[role] || role
}

// Methods
const openUserModal = (user: any = null) => {
  selectedUser.value = user
  showUserModal.value = true
}

const closeUserModal = () => {
  showUserModal.value = false
  selectedUser.value = null
}

const handleUserSubmitted = () => {
  loadUsers()
}

const editUser = (user: any) => {
  selectedUser.value = { ...user }
  Object.assign(userForm, {
    full_name: user.full_name,
    email: user.email,
    role: user.role,
    is_active: user.is_active,
    subscription_tier: user.subscription_tier,
    subscription_ends_at: user.subscription_ends_at
  })
  showUserModal.value = true
}

const changeUserRole = (user: any) => {
  // Ouvrir le modal dédié au changement de rôle
  selectedUser.value = { ...user }
  showRoleChangeModal.value = true
}

const handleRoleChanged = async () => {
  showRoleChangeModal.value = false
  await loadUsers()
}

const viewUser = (user: any) => {
  // Rediriger vers la page de profil utilisateur
  navigateTo(`/admin/users/${user.id}`)
}

const toggleUserStatus = async (user: any) => {
  try {
    loading.value = true
    const { error } = await supabase
      .from('users')
      .update({ is_active: !user.is_active })
      .eq('id', user.id)

    if (error) throw error

    showToast.success(`Utilisateur ${user.is_active ? 'désactivé' : 'activé'} avec succès`, 'success')
    await loadUsers()
  } catch (error) {
    console.error('Error toggling user status:', error)
    showToast.error("Une erreur s'est produite", 'error')
  } finally {
    loading.value = false
  }
}

const deleteUser = async (id: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) return

  try {
    loading.value = true
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', id)

    if (error) throw error

    showToast.success('L\'utilisateur a été supprimé avec succès', 'success')
    await loadUsers() // Reload users list
    
  } catch (error) {
    console.error('Error deleting user:', error)
    showToast.error("Une erreur s'est produite lors de la suppression", 'error')
  } finally {
    loading.value = false
  }
}

const handleButtonClick = (action: string) => {
  console.log('Button clicked with action:', action)
  
  switch (action) {
    case 'add-manager-establishment':
      console.log('Opening Manager + Establishment modal')
      assignmentModal.createOwnerWithEstablishment()
      break
    case 'import':
      showToast.info('Fonctionnalité d\'importation à venir')
      break
    case 'refresh':
      loadUsers()
      showToast.success('Liste rafraîchie')
      break
    default:
      console.warn('Unknown action:', action)
      showToast.error(`Action inconnue: ${action}`)
  }
}

// Get user actions for dropdown
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
      callback: () => changeUserRole(user)
    },
    {
      id: 'view',
      label: 'Voir Profil',
      icon: Eye,
      variant: 'secondary' as const,
      callback: () => viewUser(user)
    }
  ]

  // Add status-specific actions
  if (user.is_active) {
    actions.push({
      id: 'suspend',
      label: 'Suspendre',
      icon: Ban,
      variant: 'danger' as const,
      callback: () => toggleUserStatus(user)
    })
  } else {
    actions.push({
      id: 'activate',
      label: 'Activer',
      icon: CheckCircle,
      variant: 'primary' as const,
      callback: () => toggleUserStatus(user)
    })
  }

  // Add delete for non-admin users
  if (user.role !== 'admin') {
    actions.push({
      id: 'delete',
      label: 'Supprimer',
      icon: Trash2,
      variant: 'danger' as const,
      callback: () => deleteUser(user.id)
    })
  }

  return actions
}

// Handle action from dropdown
const handleUserAction = (action: any) => {
  // Actions are handled by their callbacks
}

// Manage subscription
const manageSubscription = (user: any) => {
  selectedUser.value = user
  showSubscriptionModal.value = true
}

// Handle modal success
const handleModalSuccess = () => {
  loadUsers()
}

// Handle establishment assignment success
const handleEstablishmentAssignmentSuccess = async () => {
  assignmentModal.onSuccess()
  await loadUsers()
}

// Load initial data
onMounted(() => {
  loadUsers()
})

definePageMeta({
  layout: 'admin'
})
</script>
