<template>
  <div class="p-6 lg:p-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-2">
        <NuxtLink 
          to="/admin/users"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
          <ArrowLeft class="w-5 h-5" />
        </NuxtLink>
        <div class="flex-1">
          <h1 class="text-3xl font-bold text-gray-900">{{ user.full_name || 'Utilisateur' }}</h1>
          <p class="text-gray-600">Gérer les informations de l'utilisateur</p>
        </div>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
      <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
      <p class="text-gray-500">Chargement des informations...</p>
    </div>

    <!-- Content -->
    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Left Column - Profile Info -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Profile Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <div class="flex items-start gap-4 mb-6 pb-6 border-b border-gray-100">
            <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center flex-shrink-0">
              <span class="text-2xl font-bold text-white">{{ getInitials(user.full_name) }}</span>
            </div>
            <div class="flex-1">
              <h2 class="text-2xl font-bold text-gray-900 mb-1">{{ user.full_name || 'Utilisateur' }}</h2>
              <p class="text-gray-600 mb-3">{{ user.email }}</p>
              <div class="flex items-center gap-3 flex-wrap">
                <span 
                  class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold"
                  :class="{
                    'bg-green-50 text-green-700 border border-green-200': user.is_active,
                    'bg-gray-50 text-gray-600 border border-gray-200': !user.is_active
                  }"
                >
                  <div 
                    class="w-1.5 h-1.5 rounded-full mr-1.5"
                    :class="user.is_active ? 'bg-green-500' : 'bg-gray-400'"
                  />
                  {{ user.is_active ? 'Actif' : 'Inactif' }}
                </span>
                <span class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
                  <Shield class="w-3.5 h-3.5 mr-1.5" />
                  {{ getRoleLabel(user.role) }}
                </span>
              </div>
            </div>
          </div>

          <!-- Form Fields -->
          <div class="space-y-4">
            <FloatLabelInput
              v-model="user.full_name"
              label="Nom complet"
              type="text"
              :required="true"
            />
            
            <FloatLabelInput
              v-model="user.email"
              label="Email"
              type="email"
              :required="true"
              :disabled="true"
            />
            
            <FloatLabelInput
              v-model="user.phone"
              label="Téléphone"
              type="tel"
            />

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Rôle</label>
              <select 
                v-model="user.role"
                class="w-full h-12 px-4 text-base border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-2 focus:ring-blue-500/10 transition-all"
              >
                <option value="user">Utilisateur</option>
                <option value="manager">Manager</option>
                <option value="admin">Administrateur</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Establishments Card (if manager) -->
        <div v-if="user.role === 'manager'" class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Store class="w-5 h-5" />
            Établissements gérés
          </h3>
          <div v-if="loadingEstablishments" class="text-center py-8">
            <Loader2 class="w-6 h-6 animate-spin text-gray-400 mx-auto mb-2" />
            <p class="text-gray-500">Chargement...</p>
          </div>
          <div v-else-if="establishments.length === 0" class="text-center py-8 border border-dashed border-gray-300 rounded-xl">
            <Store class="w-10 h-10 text-gray-300 mx-auto mb-2" />
            <p class="text-gray-500">Aucun établissement associé</p>
          </div>
          <div v-else class="space-y-3">
            <NuxtLink
              v-for="establishment in establishments"
              :key="establishment.id"
              :to="`/admin/establishments/${establishment.id}`"
              class="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors group"
            >
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center flex-shrink-0">
                <Store class="w-5 h-5 text-white" />
              </div>
              <div class="flex-1 min-w-0">
                <p class="font-semibold text-gray-900 truncate group-hover:text-orange-600 transition-colors">{{ establishment.name }}</p>
                <p class="text-sm text-gray-500 truncate">{{ establishment.address || 'Adresse non définie' }}</p>
              </div>
              <ArrowRight class="w-4 h-4 text-gray-400 group-hover:text-orange-600 transition-colors" />
            </NuxtLink>
          </div>
        </div>
      </div>

      <!-- Right Column - Stats & Actions -->
      <div class="space-y-6">
        <!-- Stats Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Statistiques</h3>
          <div class="space-y-4">
            <div>
              <p class="text-sm text-gray-600 mb-1">Date d'inscription</p>
              <p class="font-semibold text-gray-900">{{ formatDate(user.created_at) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-1">Dernière mise à jour</p>
              <p class="font-semibold text-gray-900">{{ formatDate(user.updated_at) }}</p>
            </div>
            <div v-if="user.last_sign_in_at">
              <p class="text-sm text-gray-600 mb-1">Dernière connexion</p>
              <p class="font-semibold text-gray-900">{{ formatDate(user.last_sign_in_at) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-1">ID</p>
              <p class="font-mono text-xs text-gray-500 break-all">{{ user.id }}</p>
            </div>
          </div>
        </div>

        <!-- Actions Card -->
        <div class="bg-white rounded-2xl border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Actions</h3>
          <div class="space-y-3">
            <button 
              @click="saveChanges"
              :disabled="loading"
              class="w-full px-4 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
              <Save v-else class="w-4 h-4" />
              {{ loading ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
            
            <button 
              @click="toggleStatus"
              :disabled="loading"
              class="w-full px-4 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <ToggleLeft v-if="user.is_active" class="w-4 h-4" />
              <ToggleRight v-else class="w-4 h-4" />
              {{ user.is_active ? 'Désactiver' : 'Activer' }}
            </button>
            
            <button 
              @click="resetPassword"
              :disabled="loading"
              class="w-full px-4 py-3 bg-orange-50 text-orange-700 rounded-xl font-semibold hover:bg-orange-100 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <Key class="w-4 h-4" />
              Réinitialiser le mot de passe
            </button>
            
            <button 
              @click="deleteUser"
              :disabled="loading"
              class="w-full px-4 py-3 bg-red-50 text-red-600 rounded-xl font-semibold hover:bg-red-100 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <Trash2 class="w-4 h-4" />
              Supprimer le compte
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  ArrowLeft, User, Loader2, Save, Trash2, Shield, 
  Store, ArrowRight, ToggleLeft, ToggleRight, Key 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()
const loading = ref(false)
const isLoading = ref(true)
const loadingEstablishments = ref(false)
const establishments = ref<any[]>([])

// User data
const user = ref({
  id: route.params.id,
  full_name: '',
  email: '',
  phone: '',
  role: 'user',
  is_active: true,
  created_at: null,
  updated_at: null,
  last_sign_in_at: null
})

// Load user data
const loadUser = async () => {
  try {
    isLoading.value = true
    
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    
    user.value = data
    
    // Load establishments if manager
    if (data.role === 'manager') {
      await loadEstablishments()
    }
  } catch (err) {
    console.error('Error loading user:', err)
    showToast.error('Erreur lors du chargement des données de l\'utilisateur')
    router.push('/admin/users')
  } finally {
    isLoading.value = false
  }
}

// Load establishments for manager
const loadEstablishments = async () => {
  try {
    loadingEstablishments.value = true
    
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name, address, is_active')
      .eq('user_id', route.params.id)

    if (error) throw error
    
    establishments.value = data || []
  } catch (err) {
    console.error('Error loading establishments:', err)
  } finally {
    loadingEstablishments.value = false
  }
}

// Get initials from name
const getInitials = (name: string | null) => {
  if (!name) return 'U'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return `${parts[0][0]}${parts[1][0]}`.toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

// Get role label
const getRoleLabel = (role: string) => {
  const roles: Record<string, string> = {
    'user': 'Utilisateur',
    'manager': 'Manager',
    'admin': 'Administrateur'
  }
  return roles[role] || role
}

// Format date
const formatDate = (dateString: string | null) => {
  if (!dateString) return 'N/A'
  
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Save user changes
const saveChanges = async () => {
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('users')
      .update({
        full_name: user.value.full_name,
        phone: user.value.phone,
        role: user.value.role
      })
      .eq('id', user.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées avec succès')
    await loadUser() // Reload to get updated data
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Impossible d\'enregistrer les modifications')
  } finally {
    loading.value = false
  }
}

// Toggle user status
const toggleStatus = async () => {
  try {
    loading.value = true
    
    const newStatus = !user.value.is_active
    
    const { error } = await supabase
      .from('users')
      .update({ is_active: newStatus })
      .eq('id', user.value.id)

    if (error) throw error

    user.value.is_active = newStatus
    
    showToast.success(`Utilisateur ${newStatus ? 'activé' : 'désactivé'} avec succès`)
  } catch (err) {
    console.error('Error toggling status:', err)
    showToast.error('Impossible de modifier le statut')
  } finally {
    loading.value = false
  }
}

// Reset password
const resetPassword = async () => {
  if (!confirm('Envoyer un email de réinitialisation de mot de passe à cet utilisateur ?')) return
  
  try {
    loading.value = true
    
    const { error } = await supabase.auth.resetPasswordForEmail(user.value.email, {
      redirectTo: `${window.location.origin}/auth/reset-password`
    })

    if (error) throw error
    
    showToast.success('Email de réinitialisation envoyé')
  } catch (err) {
    console.error('Error resetting password:', err)
    showToast.error('Impossible d\'envoyer l\'email de réinitialisation')
  } finally {
    loading.value = false
  }
}

// Delete user
const deleteUser = async () => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ? Cette action est irréversible.')) return
  
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', user.value.id)

    if (error) throw error
    
    showToast.success('Utilisateur supprimé avec succès')
    router.push('/admin/users')
  } catch (err) {
    console.error('Error deleting user:', err)
    showToast.error('Impossible de supprimer l\'utilisateur')
  } finally {
    loading.value = false
  }
}

// Load data on mount
onMounted(loadUser)

definePageMeta({
  layout: 'admin'
})
</script> 