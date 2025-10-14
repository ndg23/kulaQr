<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Utilisateurs</h1>
        <p class="text-lg text-gray-600">Gérez vos utilisateurs</p>
      </div>
  
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
        <div v-for="stat in statsDisplay" :key="stat.name" 
          class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all -hover:scale-[1.02] -hover:shadow-lg"
        >
          <div class="flex items-center space-x-6">
            <div class="w-16 h-16 rounded-2xl flex items-center justify-center"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
            </div>
            <div>
              <p class="text-base text-gray-500 mb-1">{{ stat.name }}</p>
              <h3 class="text-3xl font-bold text-gray-900">{{ stat.value }}</h3>
            </div>
          </div>
        </div>
      </div>
  
      <!-- Users List -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden">
        <!-- Header with Search and Add -->
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <div class="relative flex-1 max-w-lg">
              <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                v-model="filters.search"
                type="search"
                placeholder="Rechercher un utilisateur..."
                class="w-full h-12 pl-12 pr-4 rounded-2xl border border-gray-200 focus:border-gray-300 focus:ring focus:ring-blue-50"
              />
            </div>
            <button
              @click="openUserModal()"
              class="px-6 py-4 text-base font-semibold border border-gray-300 bg-sky-600 text-white hover:bg-sky-700 rounded-2xl focus:outline-none focus:ring-2 focus:ring-gray-200 dark:focus:ring-gray-700 transition-all"

            >
              Ajouter un utilisateur
            </button>
          </div>
        </div>
  
        <!-- Filters -->
        <div class="p-4 bg-gray-50 border-b border-gray-100">
          <div class="flex gap-4">
            <USelect
              v-model="filters.role"
              :options="roleOptions"
              placeholder="Tous les rôles"
              class="w-48"
            />
            <USelect
              v-model="filters.subscription_tier"
              :options="subscriptionOptions"
              placeholder="Tous les abonnements"
              class="w-48"
            />
          </div>
        </div>
  
        <!-- Table -->
        <UTable
          :rows="filteredUsers"
          :columns="columns"
          :loading="loading"
          :empty-state="{ icon: 'i-lucide-users-x', label: 'Aucun utilisateur trouvé' }"
          hover
        >
          <!-- User Column -->
          <template #user-data="{ row }">
            <div class="flex items-center space-x-3">
              <UAvatar
                :text="getUserInitials(row.full_name)"
                :color="getUserColor(row.id)"
                size="sm"
              />
              <div>
                <div class="font-medium text-gray-900">{{ row.full_name }}</div>
                <div class="text-sm text-gray-500">{{ row.email }}</div>
              </div>
            </div>
          </template>
  
          <!-- Role Column -->
          <template #role-data="{ row }">
            <UBadge
              :color="getRoleColor(row.role)"
              variant="subtle"
              size="sm"
            >
              {{ formatRole(row.role) }}
            </UBadge>
          </template>
  
          <!-- Subscription Column -->
          <template #subscription_tier-data="{ row }">
            <UBadge
              :color="getSubscriptionColor(row.subscription_tier)"
              variant="subtle"
              size="sm"
            >
              {{ formatSubscriptionTier(row.subscription_tier) }}
            </UBadge>
          </template>
  
          <!-- Status Column -->
          <template #is_active-data="{ row }">
            <UBadge
              :color="row.is_active ? 'green' : 'red'"
              variant="subtle"
              size="sm"
            >
              <div class="flex items-center">
                <div class="w-1.5 h-1.5 rounded-full mr-1.5"
                  :class="row.is_active ? 'bg-green-500' : 'bg-red-500'"
                />
                {{ row.is_active ? 'Actif' : 'Inactif' }}
              </div>
            </UBadge>
          </template>
  
          <!-- Created At Column -->
          <template #created_at-data="{ row }">
            <div class="flex flex-col">
              <span class="text-sm font-medium text-gray-900">
                {{ formatDate(row.created_at, 'date') }}
              </span>
              <!-- <span class="text-xs text-gray-500">
                {{ formatDate(row.created_at, 'time') }}
              </span> -->
            </div>
          </template>
  
          <!-- Last Login Column -->
          <template #last_login-data="{ row }">
            <div class="flex flex-col">
              <span class="text-sm font-medium text-gray-900">
                {{ formatDate(row.last_login, 'relative') }}
              </span>
            </div>
          </template>
          
  
          <!-- Actions Column -->
          <template #actions-data="{ row }">
            <UDropdown
              :items="[
                [
                  {
                    label: 'Modifier',
                    icon: 'i-heroicons-pencil-square',
                    click: () => editUser(row)
                  },
                  {
                    label: 'Voir le profil',
                    icon: 'i-heroicons-eye',
                    click: () => viewUser(row)
                  }
                ],
                [
                  {
                    label: row.is_active ? 'Désactiver' : 'Activer',
                    icon: row.is_active ? 'i-heroicons-lock-closed' : 'i-heroicons-lock-open',
                    click: () => toggleUserStatus(row)
                  },
                  {
                    label: 'Supprimer',
                    icon: 'i-heroicons-trash',
                    click: () => deleteUser(row.id),
                    color: 'red'
                  }
                ]
              ]"
            >
              <UButton
                color="gray"
                variant="ghost"
                icon="i-heroicons-ellipsis-horizontal"
              />
            </UDropdown>
          </template>
        </UTable>
  
        <!-- Pagination -->
        <div class="p-4 border-t border-gray-100">
          <div class="flex items-center justify-between">
            <p class="text-sm text-gray-500">
              Affichage de {{ paginationInfo.showing }} sur {{ paginationInfo.total }} utilisateurs
            </p>
            <UPagination
              v-model="currentPage"
              :total="filteredUsers.length"
              :per-page="perPage"
              size="sm"
            />
          </div>
        </div>
      </div>
  
      <!-- User Modal -->
      <UserFormModal
        v-if="showUserModal"
        :open="showUserModal"
        :user="selectedUser"
        @close="closeUserModal"
        @submit="handleUserSubmitted"
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
  UserPlus, UserCheck, UserX, Shield, Mail, Ban, Loader2, Search
} from 'lucide-vue-next';
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild, Switch } from '@headlessui/vue'
import UserFormModal from '~/components/admin/UserFormModal.vue'
// import { UDropdown } from '@/components/ui/dropdown'

const {showToast} = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const loading = ref(false)
const showUserModal = ref(false)
const selectedUser = ref(null)
const currentPage = ref(1)
const perPage = ref(10)

// State
const users = ref([])
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
    formatter: (date) => new Date(date).toLocaleDateString('fr-FR')
  },
  {
    key: 'last_login',
    label: 'Dernière connexion',
    sortable: true,
    id: 'last-login-col',
    formatter: (date) => new Date(date).toLocaleDateString('fr-FR')
  },
  {
    key: 'actions',
    label: 'Actions',
    sortable: false
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
    icon: Users,
    iconBg: 'bg-blue-50',
    iconColor: 'text-blue-500',
    borderColor: 'border-blue-500'
  },
  { 
    name: 'Utilisateurs actifs', 
    value: stats.value.active.toString(),
    icon: UserCheck,
    iconBg: 'bg-green-50',
    iconColor: 'text-green-500',
    borderColor: 'border-green-500'
  },
  { 
    name: 'Administrateurs', 
    value: stats.value.admin.toString(),
    icon: Shield,
    iconBg: 'bg-purple-50',
    iconColor: 'text-purple-500',
    borderColor: 'border-purple-500'
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
const getUserInitials = (name) => {
  if (!name) return '?'
  return name.split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .substring(0, 2)
}

const getUserColor = (id) => {
  const colors = ['blue', 'green', 'red', 'yellow', 'purple', 'pink', 'orange', 'cyan']
  const index = Math.abs(hashString(id.toString()) % colors.length)
  return colors[index]
}

const hashString = (str) => {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    hash = ((hash << 5) - hash) + str.charCodeAt(i)
    hash = hash & hash
  }
  return hash
}

const getRoleColor = (role) => {
  switch (role) {
    case 'admin': return 'purple'
    case 'manager': return 'blue'
    case 'staff': return 'green'
    case 'owner': return 'orange'
    default: return 'gray'
  }
}

const getSubscriptionColor = (tier) => {
  const colors = {
    'free': 'gray',
    'premium': 'purple',
    'pro': 'blue'
  }
  return colors[tier] || 'gray'
}

const formatSubscriptionTier = (tier) => {
  const formats = {
    'free': 'Gratuit',
    'premium': 'Premium',
    'pro': 'Pro'
  }
  return formats[tier] || tier
}

// Formatage des rôles
const formatRole = (role) => {
  const roles = {
    'admin': 'Administrateur',
    'manager': 'Gérant',
    'staff': 'Staff',
    'owner': 'Propriétaire'
  }
  return roles[role] || role
}

// Methods
const openUserModal = (user = null) => {
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

const editUser = (user) => {
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

const viewUser = (user) => {
  // Rediriger vers la page de profil utilisateur
  navigateTo(`/admin/users/${user.id}`)
}

const toggleUserStatus = async (user) => {
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

const deleteUser = async (id) => {
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

// Load initial data
onMounted(() => {
  loadUsers()
})

definePageMeta({
  layout: 'admin'
})
</script>
