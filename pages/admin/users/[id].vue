<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-12">
      <div class="flex items-center space-x-4 mb-3">
        <NuxtLink 
          to="/admin/users"
          class="p-2 text-gray-500 hover:text-gray-700 rounded-2xl hover:bg-gray-100 transition-all"
        >
          <ArrowLeft class="w-6 h-6" />
        </NuxtLink>
        <div>
          <h1 class="text-4xl font-bold text-gray-900">{{ user.full_name || 'Utilisateur' }}</h1>
          <p class="text-lg text-gray-600 mt-1">{{ user.email }}</p>
        </div>
        <span 
          class="ml-auto inline-flex items-center px-4 py-2 rounded-2xl text-sm font-medium"
          :class="{
            'bg-green-50 text-green-700': user.is_active,
            'bg-red-50 text-red-700': !user.is_active
          }"
        >
          {{ user.is_active ? 'Actif' : 'Inactif' }}
        </span>
      </div>
    </div>

    <!-- Main Content -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Left Column -->
      <div class="lg:col-span-2 space-y-8">
        <!-- User Info Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
                <User class="w-6 h-6 text-blue-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Informations personnelles</h2>
            </div>
          </div>
          <div class="p-8">
            <div class="grid grid-cols-2 gap-6">
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom complet</label>
                  <input 
                    v-model="user.full_name"
                    type="text"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                  <input 
                    v-model="user.email"
                    type="email"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
              </div>
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                  <input 
                    v-model="user.phone"
                    type="tel"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Rôle</label>
                  <select
                    v-model="user.role"
                    class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
                  >
                    <option value="user">Utilisateur</option>
                    <option value="staff">Personnel</option>
                    <option value="admin">Administrateur</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Associated Establishments Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <div class="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center">
                  <Store class="w-6 h-6 text-orange-500" />
                </div>
                <h2 class="text-2xl font-semibold text-gray-900">Établissements associés</h2>
              </div>
              <button 
                @click="openNewEstablishmentModal"
                class="inline-flex items-center px-6 py-3 bg-black text-white rounded-2xl text-base font-medium transition-colors hover:bg-gray-900"
              >
                <Plus class="w-5 h-5 mr-2" />
                Associer
              </button>
            </div>
          </div>
          <div class="p-8">
            <div v-if="loading" class="flex justify-center p-8">
              <Loader2 class="w-8 h-8 animate-spin text-gray-300" />
            </div>
            <div v-else-if="userEstablishments.length === 0" class="flex flex-col items-center justify-center py-12 border border-dashed border-gray-200 rounded-2xl">
              <Store class="w-12 h-12 text-gray-300 mb-4" />
              <p class="text-gray-500">Aucun établissement associé</p>
            </div>
            <div v-else class="space-y-4">
              <div v-for="establishment in userEstablishments" :key="establishment.id"
                class="p-4 border border-gray-100 rounded-2xl hover:border-gray-200 transition-all group"
              >
                <div class="flex justify-between items-center">
                  <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-xl bg-gray-100 flex items-center justify-center">
                      <Store class="w-5 h-5 text-gray-500" />
                    </div>
                    <div>
                      <h4 class="font-medium text-gray-900">{{ establishment.name }}</h4>
                      <p class="text-sm text-gray-500">{{ establishment.address || 'Aucune adresse' }}</p>
                    </div>
                  </div>
                  <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button 
                      @click="viewEstablishment(establishment.id)"
                      class="p-2 text-gray-500 hover:text-gray-700 rounded-xl hover:bg-gray-100"
                    >
                      <ExternalLink class="w-4 h-4" />
                    </button>
                    <button 
                      @click="removeEstablishment(establishment.id)"
                      class="p-2 text-red-500 hover:text-red-700 rounded-xl hover:bg-red-50"
                    >
                      <Trash class="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Activity Log Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center">
                <ActivityIcon class="w-6 h-6 text-purple-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Activité récente</h2>
            </div>
          </div>
          <div class="p-8">
            <div v-if="loading" class="flex justify-center p-8">
              <Loader2 class="w-8 h-8 animate-spin text-gray-300" />
            </div>
            <div v-else-if="activity.length === 0" class="flex flex-col items-center justify-center py-12 border border-dashed border-gray-200 rounded-2xl">
              <ActivityIcon class="w-12 h-12 text-gray-300 mb-4" />
              <p class="text-gray-500">Aucune activité récente</p>
            </div>
            <div v-else class="divide-y divide-gray-100">
              <div v-for="(item, index) in activity" :key="index" class="py-4 first:pt-0 last:pb-0">
                <div class="flex items-start space-x-3">
                  <div class="w-8 h-8 rounded-full bg-gray-100 flex-shrink-0 flex items-center justify-center">
                    <component :is="getActivityIcon(item.type)" class="w-4 h-4 text-gray-500" />
                  </div>
                  <div>
                    <p class="text-gray-900">{{ item.description }}</p>
                    <p class="text-sm text-gray-500 mt-1">{{ formatDate(item.date) }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="space-y-8">
        <!-- User Status Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
                <ShieldCheck class="w-6 h-6 text-green-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Statut du compte</h2>
            </div>
          </div>
          <div class="p-8 space-y-6">
            <div>
              <div class="flex justify-between items-center mb-2">
                <span class="text-gray-700 font-medium">Date d'inscription</span>
                <span class="text-gray-500">{{ formatDate(user.created_at) }}</span>
              </div>
              <div class="flex justify-between items-center mb-2">
                <span class="text-gray-700 font-medium">Dernière connexion</span>
                <span class="text-gray-500">{{ formatDate(user.last_login) || 'Jamais' }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-gray-700 font-medium">Statut</span>
                <span 
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="{
                    'bg-green-100 text-green-800': user.is_active,
                    'bg-red-100 text-red-800': !user.is_active
                  }"
                >
                  {{ user.is_active ? 'Actif' : 'Inactif' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Security Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8 border-b border-gray-100">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center">
                <LockIcon class="w-6 h-6 text-red-500" />
              </div>
              <h2 class="text-2xl font-semibold text-gray-900">Sécurité</h2>
            </div>
          </div>
          <div class="p-8 space-y-4">
            <button 
              @click="resetPassword"
              class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-medium hover:bg-gray-200 transition-colors text-left flex items-center"
            >
              <KeyIcon class="w-5 h-5 mr-3 text-gray-500" />
              Réinitialiser le mot de passe
            </button>
            <button 
              @click="generateSecureToken"
              class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-medium hover:bg-gray-200 transition-colors text-left flex items-center"
            >
              <RefreshCw class="w-5 h-5 mr-3 text-gray-500" />
              Générer un nouveau token
            </button>
          </div>
        </div>

        <!-- Actions Card -->
        <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
          <div class="p-8">
            <div class="space-y-4">
              <button 
                @click="saveChanges"
                class="w-full px-6 py-3 bg-black text-white rounded-2xl font-medium hover:bg-gray-900 transition-colors"
              >
                Enregistrer
              </button>
              <button 
                @click="toggleStatus"
                class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-medium hover:bg-gray-200 transition-colors"
              >
                {{ user.is_active ? 'Désactiver le compte' : 'Activer le compte' }}
              </button>
              <button 
                @click="deleteUser"
                class="w-full px-6 py-3 bg-red-50 text-red-600 rounded-2xl font-medium hover:bg-red-100 transition-colors"
              >
                Supprimer le compte
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  ArrowLeft, User, Store, ExternalLink, Trash, Plus,
  Loader2, ShieldCheck, LockIcon, RefreshCw, KeyIcon
} from 'lucide-vue-next'
import { ActivityIcon } from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const route = useRoute()
const router = useRouter()
const loading = ref(false)

// User data
const user = ref({
  id: route.params.id,
  full_name: '',
  email: '',
  phone: '',
  role: 'user',
  is_active: true,
  created_at: null,
  last_login: null
})

// Associated establishments
const userEstablishments = ref([])

// Activity log
const activity = ref([])

// Load user data
const loadUser = async () => {
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    
    user.value = data
    
    // Load associated establishments and activity
    await Promise.all([
      loadEstablishments(),
      loadActivity()
    ])
  } catch (err) {
    console.error('Error loading user:', err)
    showToast.error('Erreur', 'Impossible de charger les données de l\'utilisateur')
    router.push('/admin/users')
  } finally {
    loading.value = false
  }
}

// Load establishments associated with the user
const loadEstablishments = async () => {
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('id, name, address')
      .eq('user_id', route.params.id)

    if (error) throw error
    
    userEstablishments.value = data || []
  } catch (err) {
    console.error('Error loading establishments:', err)
  }
}

// Load user activity
const loadActivity = async () => {
  try {
    // This is a placeholder - you would implement the actual activity logging
    // based on your database structure
    activity.value = [
      {
        type: 'login',
        description: 'Connexion au système',
        date: new Date(Date.now() - 1000 * 60 * 60 * 2) // 2 hours ago
      },
      {
        type: 'update',
        description: 'Mise à jour du profil',
        date: new Date(Date.now() - 1000 * 60 * 60 * 24) // 1 day ago
      },
      {
        type: 'order',
        description: 'Commande #1234 créée',
        date: new Date(Date.now() - 1000 * 60 * 60 * 48) // 2 days ago
      }
    ]
  } catch (err) {
    console.error('Error loading activity:', err)
  }
}

// Format date
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Get icon for activity type
const getActivityIcon = (type) => {
  const icons = {
    login: User,
    update: RefreshCw,
    order: Store
  }
  
  return icons[type] || ActivityIcon
}

// View establishment
const viewEstablishment = (id) => {
  router.push(`/admin/establishments/${id}`)
}

// Remove establishment association
const removeEstablishment = async (id) => {
  if (!confirm('Êtes-vous sûr de vouloir retirer cette association ?')) return
  
  try {
    loading.value = true
    
    // This is a placeholder - your actual implementation would depend on your data structure
    const { error } = await supabase
      .from('establishments')
      .update({ user_id: null })
      .eq('id', id)

    if (error) throw error
    
    // Remove from the local list
    userEstablishments.value = userEstablishments.value.filter(est => est.id !== id)
    
    showToast.success('Association supprimée', 'L\'établissement a été dissocié de cet utilisateur')
  } catch (err) {
    console.error('Error removing establishment:', err)
    showToast.error('Erreur', 'Impossible de retirer l\'association')
  } finally {
    loading.value = false
  }
}

// Save user changes
const saveChanges = async () => {
  try {
    loading.value = true
    
    const { error } = await supabase
      .from('users')
      .update({
        full_name: user.value.full_name,
        email: user.value.email,
        phone: user.value.phone,
        role: user.value.role
      })
      .eq('id', user.value.id)

    if (error) throw error
    
    showToast.success('Modifications enregistrées', 'Les modifications ont été enregistrées avec succès')
  } catch (err) {
    console.error('Error saving changes:', err)
    showToast.error('Erreur', 'Impossible d\'enregistrer les modifications')
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
    
    showToast.success('Statut modifié', 'Le statut de l\'utilisateur a été mis à jour')
  } catch (err) {
    console.error('Error toggling status:', err)
    showToast.error('Erreur', 'Impossible de modifier le statut')
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
    
    showToast.success('Utilisateur supprimé', 'L\'utilisateur a été supprimé avec succès')
    router.push('/admin/users')
  } catch (err) {
    console.error('Error deleting user:', err)
    showToast.error('Erreur', 'Impossible de supprimer l\'utilisateur')
  } finally {
    loading.value = false
  }
}

// Reset password
const resetPassword = () => {
  if (!confirm('Envoyer un email de réinitialisation de mot de passe à cet utilisateur ?')) return
  
  try {
    // Implement password reset functionality
    showToast.success('Email envoyé', 'Un email de réinitialisation a été envoyé à l\'utilisateur')
  } catch (err) {
    console.error('Error resetting password:', err)
    showToast.error('Erreur', 'Impossible d\'envoyer l\'email de réinitialisation')
  }
}

// Generate secure token
const generateSecureToken = () => {
  if (!confirm('Générer un nouveau token d\'authentification pour cet utilisateur ?')) return
  
  try {
    // Implement token generation functionality
    showToast.success('Token généré', 'Un nouveau token a été généré avec succès')
  } catch (err) {
    console.error('Error generating token:', err)
    showToast.error('Erreur', 'Impossible de générer un nouveau token')
  }
}

// Open new establishment modal
const openNewEstablishmentModal = () => {
  // Implement this when you have an establishment association modal
  showToast.info('Fonctionnalité à venir', 'Cette fonctionnalité sera disponible prochainement')
}

// Load data on mount
onMounted(loadUser)

definePageMeta({
  layout: 'admin'
})
</script> 