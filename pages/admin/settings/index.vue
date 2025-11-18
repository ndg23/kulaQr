<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">Paramètres</h1>
      <p class="text-lg text-gray-600">Configuration de la plateforme</p>
    </div>

    <!-- Settings Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-5xl">
      <!-- Profile Card -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center">
              <User class="w-6 h-6 text-gray-500" />
            </div>
            <h2 class="text-xl font-semibold text-gray-900">Mon Profil</h2>
          </div>
        </div>

        <div class="p-6">
          <div class="space-y-6">
            <FloatLabelInput
              id="profile-name"
              v-model="profile.name"
              label="Nom complet"
              type="text"
              required
            />
               <FloatLabelInput
              id="profile-phone"
              v-model="profile.phone"
              label="Téléphone"
              type="tel"
              required
            />
            <FloatLabelInput
              id="profile-email"
              v-model="profile.email"
              label="Email"
              type="email"
              required
            />
            
            <button
              @click="saveProfile"
              class="group inline-flex items-center px-12 py-2 bg-kula-500 text-white rounded-full text-xl font-bold hover:bg-kula-600 transition-all duration-200"

              :loading="profileLoading"
            >
              Enregistrer
            </button>
          </div>
        </div>
      </div>

      <!-- System Settings Card -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center">
              <Settings class="w-6 h-6 text-blue-500" />
            </div>
            <h2 class="text-xl font-semibold text-gray-900">Système</h2>
          </div>
        </div>

        <div class="divide-y divide-gray-100">
          <!-- Maintenance Mode -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Power class="w-5 h-5 text-gray-500" />
                <div>
                  <div class="text-gray-900">Mode maintenance</div>
                  <div class="text-xs text-gray-500">Bloquer l'accès temporairement</div>
                </div>
              </div>
              <UToggle
                v-model="maintenanceMode"
                color="amber"
                @change="toggleMaintenanceModeSetting"
              />
            </div>
          </div>

          <!-- Cache Management -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Trash2 class="w-5 h-5 text-gray-500" />
                <div>
                  <div class="text-gray-900">Cache système</div>
                  <div class="text-xs text-gray-500">Vider le cache si problème</div>
                </div>
              </div>
              <button
                @click="clearCache"
                class="group inline-flex items-center px-12 py-2 bg-kula-500 text-white rounded-full text-xl font-bold hover:bg-kula-600 transition-all duration-200"

                :loading="cacheLoading"
              >
              <RotateCw class="w-6 h-6 mr-2"/>
                Vider
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { 
  Settings, User, Trash2, Power, RotateCw
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSettings } from '~/composables/useSettings'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const { 
  settings, 
  toggleMaintenanceMode, 
  updateCacheInfo 
} = useSettings()

// State
const maintenanceMode = computed({
  get: () => settings.maintenance_mode || false,
  set: (value) => toggleMaintenanceModeSetting(value)
})

const cacheLoading = ref(false)
const profileLoading = ref(false)

// Profile
const profile = reactive({
  name: '',
  email: '',
  phone: ''
})

// Methods
const clearCache = async () => {
  try {
    cacheLoading.value = true
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    await updateCacheInfo()
    
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      await supabase
        .from('activities')
        .insert({
          user_id: user.id,
          action_type: 'delete',
          entity_type: 'cache',
          entity_id: null,
          details: { timestamp: new Date().toISOString() }
        })
    }
    
    showToast.success('Cache vidé avec succès', 'success')
  } catch (error) {
    console.error('Erreur lors du vidage du cache:', error)
    showToast.error('Erreur lors du vidage du cache', 'error')
  } finally {
    cacheLoading.value = false
  }
}

const saveProfile = async () => {
  try {
    profileLoading.value = true
    
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Utilisateur non connecté')
    }
    
    const { error: authUpdateError } = await supabase.auth.updateUser({
      data: {
        full_name: profile.name
      }
    })
    
    if (authUpdateError) throw authUpdateError
    
    if (user.email !== profile.email) {
      const { error: emailUpdateError } = await supabase.auth.updateUser({
        email: profile.email
      })
      
      if (emailUpdateError) throw emailUpdateError
    }
    if (user.user_metadata?.full_name !== profile.name) {
      const { error: metadataUpdateError } = await supabase.auth.updateUser({
        data: {
          full_name: profile.name
        }
      })
      
      if (metadataUpdateError) throw metadataUpdateError
    }

    if (user.user_metadata?.phone !== profile.phone) {
      const { error: phoneUpdateError } = await supabase.auth.updateUser({
        data: {
          phone: profile.phone
        }
      })
      
      if (phoneUpdateError) throw phoneUpdateError
    }
    
    const { error: dbUpdateError } = await supabase
      .from('users')
      .update({
        full_name: profile.name,
        email: profile.email,
        phone: profile.phone,
        updated_at: new Date()
      })
      .eq('id', user.id)
    
    if (dbUpdateError) throw dbUpdateError
    
    await supabase
      .from('activities')
      .insert({
        user_id: user.id,
        action_type: 'update',
        entity_type: 'user',
        entity_id: user.id,
        details: { name: profile.name, email: profile.email }
      })
    
    showToast.success('Profil mis à jour avec succès', 'success')
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error)
    showToast.error('Erreur lors de la mise à jour du profil', 'error')
  } finally {
    profileLoading.value = false
  }
}

const toggleMaintenanceModeSetting = async (value: boolean) => {
  try {
    await toggleMaintenanceMode(value)
    
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      await supabase
        .from('activities')
        .insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'system_setting',
          entity_id: null,
          details: { setting: 'maintenance_mode', value: value }
        })
    }
    
    showToast.success(
      value ? 'Mode maintenance activé' : 'Mode maintenance désactivé',
      'success'
    )
  } catch (error) {
    console.error('Erreur lors de la modification du mode maintenance:', error)
    showToast.error('Erreur lors de la modification des paramètres', 'error')
  }
}

// Load initial data
onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (user) {
    profile.name = user.user_metadata?.full_name || ''
    profile.email = user.email || ''
    profile.phone = user.user_metadata?.phone || ''
  }
})

definePageMeta({
  layout: 'admin'
})
</script>