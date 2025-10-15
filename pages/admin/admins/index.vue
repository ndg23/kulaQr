<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="py-6">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Administrateurs</h1>
              <p class="text-gray-600">Gérez les comptes administrateurs</p>
            </div>
            <button
              @click="showAddAdminModal = true"
              class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              Ajouter un admin
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-12">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4">
        <p class="text-red-800">{{ error }}</p>
      </div>

      <!-- Admins List -->
      <div v-else class="bg-white shadow rounded-lg overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nom
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Statut
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Créé le
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="admin in admins" :key="admin.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">{{ admin.full_name }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-500">{{ admin.email }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                      :class="admin.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
                  {{ admin.status === 'active' ? 'Actif' : 'Inactif' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(admin.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  @click="toggleAdminStatus(admin)"
                  class="text-blue-600 hover:text-blue-900 mr-4"
                >
                  {{ admin.status === 'active' ? 'Désactiver' : 'Activer' }}
                </button>
                <button
                  @click="deleteAdmin(admin)"
                  class="text-red-600 hover:text-red-900"
                >
                  Supprimer
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Add Admin Modal -->
    <div v-if="showAddAdminModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold mb-4">Ajouter un administrateur</h3>
        
        <form @submit.prevent="addAdmin" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Nom complet</label>
            <input
              v-model="newAdmin.full_name"
              type="text"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700">Email</label>
            <input
              v-model="newAdmin.email"
              type="email"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700">Mot de passe</label>
            <input
              v-model="newAdmin.password"
              type="password"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="showAddAdminModal = false"
              class="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="addingAdmin"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {{ addingAdmin ? 'Ajout...' : 'Ajouter' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

// State
const admins = ref([])
const loading = ref(true)
const error = ref('')
const showAddAdminModal = ref(false)
const addingAdmin = ref(false)

const newAdmin = ref({
  full_name: '',
  email: '',
  password: ''
})

// Methods
const loadAdmins = async () => {
  try {
    loading.value = true
    const { data, error: err } = await supabase
      .from('users')
      .select('*')
      .eq('role', 'admin')
      .order('created_at', { ascending: false })

    if (err) throw err
    admins.value = data || []
  } catch (err: any) {
    error.value = err.message
    showToast.error('Erreur', 'Impossible de charger les administrateurs')
  } finally {
    loading.value = false
  }
}

const addAdmin = async () => {
  try {
    addingAdmin.value = true
    
    const { data, error: err } = await $fetch('/api/admin/create-admin', {
      method: 'POST',
      body: newAdmin.value
    })

    if (err) throw err

    showToast.success('Succès', 'Administrateur ajouté avec succès')
    showAddAdminModal.value = false
    newAdmin.value = { full_name: '', email: '', password: '' }
    await loadAdmins()
  } catch (err: any) {
    showToast.error('Erreur', err.message || 'Impossible d\'ajouter l\'administrateur')
  } finally {
    addingAdmin.value = false
  }
}

const toggleAdminStatus = async (admin: any) => {
  try {
    const newStatus = admin.status === 'active' ? 'inactive' : 'active'
    
    const { error: err } = await supabase
      .from('users')
      .update({ status: newStatus })
      .eq('id', admin.id)

    if (err) throw err

    showToast.success('Succès', `Administrateur ${newStatus === 'active' ? 'activé' : 'désactivé'}`)
    await loadAdmins()
  } catch (err: any) {
    showToast.error('Erreur', 'Impossible de modifier le statut')
  }
}

const deleteAdmin = async (admin: any) => {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer ${admin.full_name} ?`)) {
    return
  }

  try {
    const { error: err } = await supabase
      .from('users')
      .delete()
      .eq('id', admin.id)

    if (err) throw err

    showToast.success('Succès', 'Administrateur supprimé')
    await loadAdmins()
  } catch (err: any) {
    showToast.error('Erreur', 'Impossible de supprimer l\'administrateur')
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

// Lifecycle
onMounted(() => {
  loadAdmins()
})

definePageMeta({
  layout: 'admin',
  middleware: 'admin-auth'
})
</script>
