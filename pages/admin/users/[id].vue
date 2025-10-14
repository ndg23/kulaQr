<template>
  <div class="min-h-screen bg-white">
    <!-- Header Twitter Style -->
    <div class="sticky top-0 z-50 bg-white/80 backdrop-blur-xl border-b border-gray-200">
      <div class="px-4 py-4">
        <div class="flex items-center gap-4">
        <NuxtLink 
          to="/admin/users"
            class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
            <ArrowLeft class="w-5 h-5" />
        </NuxtLink>
          <div class="flex-1">
            <h1 class="text-xl font-bold text-gray-900">{{ user.full_name || 'Utilisateur' }}</h1>
            <p class="text-sm text-gray-500">{{ user.email }}</p>
        </div>
          <div 
            class="px-3 py-1 rounded-full text-xs font-semibold"
          :class="{
              'bg-green-100 text-green-700': user.is_active,
              'bg-red-100 text-red-700': !user.is_active
          }"
        >
          {{ user.is_active ? 'Actif' : 'Inactif' }}
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="px-4 py-6 max-w-2xl mx-auto">
      <!-- User Profile Card -->
      <div class="bg-white border border-gray-200 rounded-3xl overflow-hidden">
        <!-- Profile Header -->
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center">
              <User class="w-8 h-8 text-gray-500" />
            </div>
            <div class="flex-1">
              <h2 class="text-xl font-bold text-gray-900">{{ user.full_name || 'Utilisateur' }}</h2>
              <p class="text-sm text-gray-500">{{ user.email }}</p>
              <div class="flex items-center gap-2 mt-1">
                <span class="text-xs px-2 py-1 rounded-full bg-gray-100 text-gray-600">
                  {{ user.role }}
                </span>
                <span class="text-xs text-gray-400">•</span>
                <span class="text-xs text-gray-400">
                  Inscrit le {{ formatDate(user.created_at) }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Profile Info -->
        <div class="p-6 space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom complet</label>
                  <input 
                    v-model="user.full_name"
                    type="text"
              class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10 transition-all"
                  />
                </div>
          
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                  <input 
                    v-model="user.phone"
                    type="tel"
              class="w-full h-12 px-4 text-base border border-gray-200 rounded-2xl focus:border-black focus:ring-2 focus:ring-black/10 transition-all"
            />
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="mt-6 space-y-3">
              <button 
                @click="saveChanges"
            :disabled="loading"
            class="w-full px-6 py-3 bg-black text-white rounded-2xl font-semibold hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
          >
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <Loader2 class="w-4 h-4 animate-spin" />
              Enregistrement...
            </span>
            <span v-else>Enregistrer les modifications</span>
              </button>
          
              <button 
                @click="toggleStatus"
            :disabled="loading"
            class="w-full px-6 py-3 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
              >
                {{ user.is_active ? 'Désactiver le compte' : 'Activer le compte' }}
              </button>
          
              <button 
                @click="deleteUser"
            :disabled="loading"
            class="w-full px-6 py-3 bg-red-50 text-red-600 rounded-2xl font-semibold hover:bg-red-100 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
              >
                Supprimer le compte
              </button>
        </div>
      </div>
    </div>
  <!-- </div> -->
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ArrowLeft, User, Loader2 } from 'lucide-vue-next'
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
  created_at: null
})

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
  } catch (err) {
    console.error('Error loading user:', err)
    showToast.error('Erreur', 'Impossible de charger les données de l\'utilisateur')
    router.push('/admin/users')
  } finally {
    loading.value = false
  }
}


// Format date
const formatDate = (dateString: string | null) => {
  if (!dateString) return 'N/A'
  
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
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
        phone: user.value.phone
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


// Load data on mount
onMounted(loadUser)

definePageMeta({
  layout: 'admin'
})
</script> 