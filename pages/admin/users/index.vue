<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Utilisateurs</h1>
        <p class="text-gray-600">Gérez les utilisateurs et leurs permissions</p>
      </div>
  
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div v-for="stat in stats" :key="stat.name" 
          class="bg-white p-6 rounded-xl border border-gray-100 hover:border-gray-200 transition-all">
          <div class="flex items-center justify-between">
            <span class="text-gray-500 text-sm">{{ stat.name }}</span>
            <component :is="stat.icon" class="w-5 h-5 text-gray-400" />
          </div>
          <div class="mt-2 flex items-baseline">
            <span class="text-2xl font-semibold text-gray-900">{{ stat.value }}</span>
            <span class="ml-2 text-sm text-green-500 font-medium">+{{ stat.increase }}%</span>
          </div>
        </div>
      </div>
  
      <!-- Users Table -->
      <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-900">Liste des utilisateurs</h2>
            <button 
              @click="openNewUserModal"
              class="inline-flex items-center px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
            >
              <UserPlus class="w-4 h-4 mr-2" />
              Ajouter un utilisateur
            </button>
          </div>
        </div>
  
        <!-- Search and Filters -->
        <div class="p-4 border-b border-gray-100 bg-gray-50">
          <div class="flex items-center space-x-4">
            <div class="flex-1">
              <div class="relative">
                <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  v-model="searchQuery"
                  type="text"
                  placeholder="Rechercher un utilisateur..."
                  class="w-full h-10 pl-10 pr-4 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>
            <select
              v-model="roleFilter"
              class="h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
            >
              <option value="">Tous les rôles</option>
              <option value="admin">Admin</option>
              <option value="manager">Manager</option>
              <option value="user">Utilisateur</option>
            </select>
          </div>
        </div>
  
        <!-- Table -->
        <div class="overflow-x-auto">
          <UTable 
            :rows="filteredUsers" 
            :columns="columns"
            :loading="loading"
            :sort="{ column: 'createdAt', direction: 'desc' }"
          >
            <!-- Avatar Column -->
            <template #avatar-data="{ row }">
              <div class="flex items-center">
                <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
                  <User class="w-4 h-4 text-gray-400" />
                </div>
                <div class="ml-3">
                  <div class="font-medium text-gray-900">{{ row.name }}</div>
                  <div class="text-sm text-gray-500">{{ row.email }}</div>
                </div>
              </div>
            </template>
  
            <!-- Role Column -->
            <template #role-data="{ row }">
              <span 
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-purple-50 text-purple-700': row.role === 'admin',
                  'bg-blue-50 text-blue-700': row.role === 'manager',
                  'bg-gray-50 text-gray-700': row.role === 'user'
                }"
              >
                {{ row.role }}
              </span>
            </template>
  
            <!-- Status Column -->
            <template #status-data="{ row }">
              <span 
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-green-50 text-green-700': row.status === 'active',
                  'bg-yellow-50 text-yellow-700': row.status === 'pending',
                  'bg-red-50 text-red-700': row.status === 'inactive'
                }"
              >
                {{ row.status }}
              </span>
            </template>
  
            <!-- Actions Column -->
            <template #actions-data="{ row }">
              <div class="flex items-center space-x-3">
                <button 
                  @click="editUser(row)"
                  class="text-gray-500 hover:text-gray-700"
                >
                  <Edit2 class="w-4 h-4" />
                </button>
                <button 
                  @click="deleteUser(row.id)"
                  class="text-gray-500 hover:text-red-500"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </template>
          </UTable>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { 
    Users, UserPlus, User, Search, Edit2, Trash2,
    UserCheck, UserX, Shield
  } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const loading = ref(false)
  const searchQuery = ref('')
  const roleFilter = ref('')
  <!-- Ajouter dans le script -->
const showModal = ref(false)
const editingUser = ref(null)

const openNewUserModal = () => {
  editingUser.value = null
  showModal.value = true
}

const editUser = (user: any) => {
  editingUser.value = user
  showModal.value = true
}

const handleUserSubmit = async (userData: any) => {
  try {
    if (editingUser.value) {
      // Update user
      toast.success('Utilisateur modifié', 'Les modifications ont été enregistrées')
    } else {
      // Create user
      toast.success('Utilisateur créé', 'Le nouvel utilisateur a été créé')
    }
  } catch (error) {
    toast.error('Erreur', "Une erreur s'est produite")
  }
}

<!-- Ajouter dans le template -->
<UserModal 
  :is-open="showModal"
  :editing-user="editingUser"
  @close="showModal = false"
  @submit="handleUserSubmit"
/>
  // Stats data
  const stats = [
    { name: 'Total utilisateurs', value: '1,234', increase: '8', icon: Users },
    { name: 'Actifs ce mois', value: '856', increase: '12', icon: UserCheck },
    { name: 'En attente', value: '23', increase: '5', icon: UserX }
  ]
  
  // Table configuration
  const columns = [
    { key: 'avatar', label: 'Utilisateur' },
    { key: 'role', label: 'Rôle' },
    { key: 'status', label: 'Statut' },
    { key: 'lastLogin', label: 'Dernière connexion' },
    { key: 'actions', label: 'Actions' }
  ]
  
  // Sample data
  const users = ref([
    {
      id: 1,
      name: 'Jean Dupont',
      email: 'jean@example.com',
      role: 'admin',
      status: 'active',
      lastLogin: '2024-02-20 15:30'
    },
    {
      id: 2,
      name: 'Marie Martin',
      email: 'marie@example.com',
      role: 'manager',
      status: 'active',
      lastLogin: '2024-02-19 10:15'
    },
    // ... autres utilisateurs
  ])
  
  // Filtered users
  const filteredUsers = computed(() => {
    return users.value.filter(user => {
      const matchesSearch = searchQuery.value === '' || 
        user.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        user.email.toLowerCase().includes(searchQuery.value.toLowerCase())
      
      const matchesRole = roleFilter.value === '' || user.role === roleFilter.value
  
      return matchesSearch && matchesRole
    })
  })
  
  // Actions
  const openNewUserModal = () => {
    // Implémenter la logique d'ouverture du modal
  }
  
  const editUser = (user: any) => {
    // Implémenter la logique d'édition
  }
  
  const deleteUser = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      try {
        // Appel API pour supprimer
        toast.success('Utilisateur supprimé', 'L\'utilisateur a été supprimé avec succès')
      } catch (error) {
        toast.error('Erreur', "Une erreur s'est produite lors de la suppression")
      }
    }
  }
  
  definePageMeta({
    layout: 'admin'
  })
  </script>