<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Utilisateurs</h1>
        <p class="text-lg text-gray-600">Gérez vos utilisateurs</p>
      </div>
  
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
        <div v-for="stat in stats" :key="stat.name" 
          class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all hover:scale-[1.02] hover:shadow-lg"
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
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <!-- Header -->
        <div class="p-8 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
                <Users class="w-6 h-6 text-purple-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Liste des utilisateurs</h2>
            </div>
            <button 
              @click="openNewUserModal"
              class="inline-flex items-center px-6 py-3 bg-black text-white rounded-2xl text-base font-medium transition-colors hover:bg-gray-900"
            >
              <UserPlus class="w-5 h-5 mr-2" />
              Ajouter
            </button>
          </div>
        </div>
  
        <!-- Search -->
        <div class="p-6 border-b border-gray-100 bg-gray-50">
          <div class="flex flex-wrap gap-4">
            <div class="flex-1 min-w-[300px]">
              <div class="relative">
                <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  v-model="filters.search"
                  type="text"
                  placeholder="Rechercher un utilisateur..."
                  class="w-full h-12 pl-12 pr-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                />
              </div>
            </div>
  
            <select
              v-model="filters.role"
              class="h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
            >
              <option value="">Tous les rôles</option>
              <option value="admin">Admin</option>
              <option value="manager">Manager</option>
              <option value="user">Utilisateur</option>
            </select>
          </div>
        </div>
  
        <!-- Users Grid -->
        <div class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div v-for="user in filteredUsers" :key="user.id"
              class="p-6 border border-gray-100 rounded-2xl hover:border-gray-200 transition-all group"
            >
              <div class="flex items-start justify-between">
                <div class="flex items-start space-x-4">
                  <div class="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <User class="w-6 h-6 text-gray-400" />
                  </div>
                  <div>
                    <h3 class="text-lg font-semibold text-gray-900">{{ user.name }}</h3>
                    <p class="text-sm text-gray-500 mt-1">{{ user.email }}</p>
                    <div class="flex items-center mt-2">
                      <span 
                        class="inline-flex items-center px-2.5 py-1 rounded-xl text-xs font-medium"
                        :class="{
                          'bg-purple-50 text-purple-700': user.role === 'admin',
                          'bg-blue-50 text-blue-700': user.role === 'manager',
                          'bg-gray-50 text-gray-700': user.role === 'user'
                        }"
                      >
                        {{ user.role }}
                      </span>
                      <span 
                        class="ml-2 inline-flex items-center px-2.5 py-1 rounded-xl text-xs font-medium"
                        :class="{
                          'bg-green-50 text-green-700': user.status === 'active',
                          'bg-yellow-50 text-yellow-700': user.status === 'pending',
                          'bg-red-50 text-red-700': user.status === 'inactive'
                        }"
                      >
                        {{ user.status }}
                      </span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button 
                    @click="editUser(user)"
                    class="p-2 text-gray-500 hover:text-gray-700 rounded-xl hover:bg-gray-100"
                  >
                    <Edit2 class="w-5 h-5" />
                  </button>
                  <button 
                    @click="deleteUser(user.id)"
                    class="p-2 text-gray-500 hover:text-red-500 rounded-xl hover:bg-red-50"
                  >
                    <Trash2 class="w-5 h-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
  
      <!-- User Modal -->
      <UserModal 
        :show="showUserModal"
        :user="selectedUser"
        @close="closeUserModal"
        @submit="handleUserSubmit"
      />
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, computed } from 'vue'
  import { 
    Users, UserPlus, User, Search, Edit2, Trash2,
    UserCheck, UserX, Shield
  } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const loading = ref(false)
  const showUserModal = ref(false)
  const selectedUser = ref(null)
  
  // Stats data
  const stats = [
    { 
      name: 'Total utilisateurs', 
      value: '1,234',
      icon: Users,
      iconBg: 'bg-purple-50',
      iconColor: 'text-purple-500'
    },
    { 
      name: 'Utilisateurs actifs', 
      value: '856',
      icon: UserCheck,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    { 
      name: 'Administrateurs', 
      value: '12',
      icon: Shield,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    }
  ]
  
  // Filters
  const filters = ref({
    search: '',
    role: ''
  })
  
  // Sample data
  const users = ref([
    {
      id: 1,
      name: 'Jean Dupont',
      email: 'jean@example.com',
      role: 'admin',
      status: 'active'
    },
    {
      id: 2,
      name: 'Marie Martin',
      email: 'marie@example.com',
      role: 'manager',
      status: 'active'
    }
  ])
  
  // Computed
  const filteredUsers = computed(() => {
    return users.value.filter(user => {
      const matchesSearch = !filters.value.search || 
        user.name.toLowerCase().includes(filters.value.search.toLowerCase()) ||
        user.email.toLowerCase().includes(filters.value.search.toLowerCase())
      
      const matchesRole = !filters.value.role || user.role === filters.value.role

      return matchesSearch && matchesRole
    })
  })
  
  // Methods
  const openNewUserModal = () => {
    selectedUser.value = null
    showUserModal.value = true
  }
  
  const editUser = (user: any) => {
    selectedUser.value = user
    showUserModal.value = true
  }
  
  const closeUserModal = () => {
    showUserModal.value = false
    selectedUser.value = null
  }
  
  const handleUserSubmit = async (userData: any) => {
    try {
      loading.value = true
      // Logique de création/modification
      toast.success(
        selectedUser.value ? 'Utilisateur modifié' : 'Utilisateur créé',
        selectedUser.value ? 'Les modifications ont été enregistrées' : 'Le nouvel utilisateur a été créé'
      )
      closeUserModal()
    } catch (error) {
      toast.error('Erreur', "Une erreur s'est produite")
    } finally {
      loading.value = false
    }
  }
  
  const deleteUser = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      try {
        loading.value = true
        // Logique de suppression
        toast.success('Utilisateur supprimé', 'L\'utilisateur a été supprimé avec succès')
      } catch (error) {
        toast.error('Erreur', "Une erreur s'est produite lors de la suppression")
      } finally {
        loading.value = false
      }
    }
  }
  
  definePageMeta({
    layout: 'admin'
  })
  </script>