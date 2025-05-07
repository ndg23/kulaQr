<template>
  <div class="p-6 lg:p-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-2">Paramètres</h1>
      <p class="text-lg text-gray-600">Configuration système</p>
    </div>

    <!-- Settings Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
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
          <!-- SMTP Settings -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Mail class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Configuration SMTP</span>
              </div>
              <UButton
                @click="openSmtpSettings"
                color="gray"
                variant="soft"
              >
                Configurer
              </UButton>
            </div>
          </div>

          <!-- Database Backup -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Database class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Sauvegarde</span>
              </div>
              <UButton
                @click="startBackup"
                color="gray"
                variant="soft"
                :loading="backupLoading"
              >
                Sauvegarder
              </UButton>
            </div>
          </div>
          
          <!-- Cache Management -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Trash2 class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Cache système</span>
              </div>
              <UButton
                @click="clearCache"
                color="gray"
                variant="soft"
                :loading="cacheLoading"
              >
                Vider
              </UButton>
            </div>
          </div>
        </div>
      </div>

      <!-- Security Settings Card -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center">
              <Shield class="w-6 h-6 text-red-500" />
            </div>
            <h2 class="text-xl font-semibold text-gray-900">Sécurité</h2>
          </div>
        </div>

        <div class="divide-y divide-gray-100">
          <!-- 2FA -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Fingerprint class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Authentification à deux facteurs</span>
              </div>
              <UToggle
                v-model="twoFactorEnabled"
                color="blue"
                @change="toggleTwoFactorSetting"
              />
            </div>
          </div>

          <!-- Session Management -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Laptop class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Sessions actives</span>
              </div>
              <UButton
                @click="openSessions"
                color="gray"
                variant="soft"
              >
                Gérer
              </UButton>
            </div>
          </div>
          
          <!-- Admin Users -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Users class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Administrateurs</span>
              </div>
              <UButton
                @click="openAddAdminModal"
                color="gray"
                variant="soft"
                icon="i-lucide-user-plus"
              >
                Ajouter
              </UButton>
            </div>
          </div>
          
          <!-- Maintenance Mode -->
          <div class="p-6 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-4">
                <Power class="w-5 h-5 text-gray-500" />
                <span class="text-gray-900">Mode maintenance</span>
              </div>
              <UToggle
                v-model="maintenanceMode"
                color="amber"
                @change="toggleMaintenanceModeSetting"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Profile Card -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center">
              <User class="w-6 h-6 text-gray-500" />
            </div>
            <h2 class="text-xl font-semibold text-gray-900">Profil</h2>
          </div>
        </div>

        <div class="p-6">
          <div class="space-y-4">
            <UFormGroup label="Nom complet">
              <UInput
                v-model="profile.name"
                placeholder="Votre nom"
              />
            </UFormGroup>
            
            <UFormGroup label="Email">
              <UInput
                v-model="profile.email"
                type="email"
                placeholder="votre@email.com"
              />
            </UFormGroup>
            
            <UButton
              @click="saveProfile"
              color="black"
              block
              :loading="profileLoading"
            >
              Enregistrer
            </UButton>
          </div>
        </div>
      </div>

      <!-- System Info Card -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center">
              <Info class="w-6 h-6 text-green-500" />
            </div>
            <h2 class="text-xl font-semibold text-gray-900">Informations</h2>
          </div>
        </div>

        <div class="p-6">
          <ul class="space-y-3">
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Version</span>
              <span class="font-medium text-gray-900">{{ systemInfo.version }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Environnement</span>
              <span class="font-medium text-gray-900">{{ systemInfo.environment }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Base de données</span>
              <span class="font-medium text-gray-900">{{ systemInfo.database }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Dernier déploiement</span>
              <span class="font-medium text-gray-900">{{ systemInfo.lastDeployment }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    
    <!-- SMTP Settings Modal -->
    <UModal v-model="showSmtpModal">
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900">Configuration SMTP</h3>
          </div>
        </template>
        
        <div class="space-y-4 py-4">
          <UFormGroup label="Serveur SMTP">
            <UInput v-model="smtpConfig.host" placeholder="smtp.example.com" />
          </UFormGroup>
          
          <UFormGroup label="Port">
            <UInput v-model="smtpConfig.port" placeholder="587" />
          </UFormGroup>
          
          <UFormGroup label="Utilisateur">
            <UInput v-model="smtpConfig.username" placeholder="user@example.com" />
          </UFormGroup>
          
          <UFormGroup label="Mot de passe">
            <UInput v-model="smtpConfig.password" type="password" placeholder="••••••••" />
          </UFormGroup>
          
          <UFormGroup>
            <UToggle v-model="smtpConfig.secure">
              <span class="text-sm text-gray-700">Utiliser TLS/SSL</span>
            </UToggle>
          </UFormGroup>
        </div>
        
        <template #footer>
          <div class="flex justify-end gap-3">
            <UButton
              color="gray"
              variant="soft"
              @click="showSmtpModal = false"
            >
              Annuler
            </UButton>
            <UButton
              color="blue"
              @click="saveSmtpSettingsHandler"
              :loading="smtpLoading"
            >
              Enregistrer
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
    
    <!-- Add Admin Modal -->
    <UModal v-model="showAddAdminModal">
      <UCard>
        <template #header>
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center">
              <UserPlus class="w-5 h-5 text-blue-500" />
            </div>
            <h3 class="text-lg font-semibold">Ajouter un administrateur</h3>
          </div>
        </template>
        
        <div class="space-y-4">
          <UFormGroup label="Nom complet" required>
            <UInput 
              v-model="newAdmin.name" 
              placeholder="Nom de l'administrateur"
              :error="validationErrors.name"
            />
          </UFormGroup>
          
          <UFormGroup label="Email" required>
            <UInput 
              v-model="newAdmin.email" 
              type="email" 
              placeholder="email@example.com"
              :error="validationErrors.email"
            />
          </UFormGroup>
          
          <UFormGroup label="Mot de passe" required>
            <UInput 
              v-model="newAdmin.password" 
              type="password" 
              placeholder="Mot de passe sécurisé"
              :error="validationErrors.password"
            />
            <template #hint>
              <p class="text-xs text-gray-500">
                Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre
              </p>
            </template>
          </UFormGroup>
          
          <UFormGroup label="Rôle">
            <USelect
              v-model="newAdmin.role"
              :options="adminRoles"
              option-attribute="label"
              value-attribute="value"
            />
          </UFormGroup>
        </div>
        
        <template #footer>
          <div class="flex justify-end gap-3">
            <UButton
              color="gray"
              variant="soft"
              @click="showAddAdminModal = false"
            >
              Annuler
            </UButton>
            <UButton
              color="blue"
              @click="addNewAdmin"
              :loading="addingAdmin"
            >
              Ajouter
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { 
  Settings, User, Mail, Database, Shield,
  Fingerprint, Laptop, Trash2, Power, Info,
  Users, UserPlus
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSettings } from '~/composables/useSettings'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const { 
  settings, 
  isLoading, 
  loadAllSettings, 
  saveSmtpSettings, 
  toggleMaintenanceMode, 
  toggleTwoFactor, 
  updateBackupInfo, 
  updateCacheInfo 
} = useSettings()

// State
const twoFactorEnabled = computed({
  get: () => settings.security?.two_factor_enabled || false,
  set: (value) => toggleTwoFactorSetting(value)
})

const maintenanceMode = computed({
  get: () => settings.maintenance_mode || false,
  set: (value) => toggleMaintenanceModeSetting(value)
})

const backupLoading = ref(false)
const cacheLoading = ref(false)
const profileLoading = ref(false)
const smtpLoading = ref(false)
const showSmtpModal = ref(false)
const showAddAdminModal = ref(false)
const addingAdmin = ref(false)

// Nouvel administrateur
const newAdmin = reactive({
  name: '',
  email: '',
  password: '',
  role: 'admin'
})

const validationErrors = reactive({
  name: '',
  email: '',
  password: ''
})

const adminRoles = [
  { label: 'Administrateur', value: 'admin' },
  { label: 'Super administrateur', value: 'superadmin' },
  { label: 'Modérateur', value: 'moderator' }
]

// Computed properties
const lastBackup = computed(() => {
  if (!settings.backup?.last_backup) return 'Jamais'
  return formatDate(settings.backup.last_backup)
})

const lastCacheClear = computed(() => {
  if (!settings.cache?.last_cleared) return 'Jamais'
  return formatDate(settings.cache.last_cleared)
})

// Profile
const profile = reactive({
  name: 'Admin User',
  email: 'admin@example.com'
})

// SMTP Config
const smtpConfig = computed(() => settings.smtp || {
  host: '',
  port: '587',
  username: '',
  password: '',
  secure: true
})

// System Info
const systemInfo = computed(() => settings.app_info || {
  version: '1.0.0',
  environment: 'development',
  database: 'PostgreSQL',
  lastDeployment: 'Jamais'
})

// Methods
const openSmtpSettings = () => {
  showSmtpModal.value = true
}

const openAddAdminModal = () => {
  // Réinitialiser le formulaire
  Object.assign(newAdmin, {
    name: '',
    email: '',
    password: '',
    role: 'admin'
  })
  
  // Réinitialiser les erreurs
  Object.keys(validationErrors).forEach(key => {
    validationErrors[key] = ''
  })
  
  showAddAdminModal.value = true
}

const validateAdminForm = () => {
  let isValid = true
  
  // Valider le nom
  if (!newAdmin.name.trim()) {
    validationErrors.name = 'Le nom est requis'
    isValid = false
  } else {
    validationErrors.name = ''
  }
  
  // Valider l'email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!newAdmin.email.trim()) {
    validationErrors.email = 'L\'email est requis'
    isValid = false
  } else if (!emailRegex.test(newAdmin.email)) {
    validationErrors.email = 'L\'email n\'est pas valide'
    isValid = false
  } else {
    validationErrors.email = ''
  }
  
  // Valider le mot de passe
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/
  if (!newAdmin.password) {
    validationErrors.password = 'Le mot de passe est requis'
    isValid = false
  } else if (!passwordRegex.test(newAdmin.password)) {
    validationErrors.password = 'Le mot de passe ne respecte pas les critères de sécurité'
    isValid = false
  } else {
    validationErrors.password = ''
  }
  
  return isValid
}

const addNewAdmin = async () => {
  if (!validateAdminForm()) {
    return
  }
  
  try {
    addingAdmin.value = true
    
    // Vérifier si l'email existe déjà
    const { data: existingUsers, error: checkError } = await supabase
      .from('users')
      .select('id')
      .eq('email', newAdmin.email)
      .limit(1)
    
    if (checkError) throw checkError
    
    if (existingUsers && existingUsers.length > 0) {
      validationErrors.email = 'Cet email est déjà utilisé'
      return
    }
    
    // Créer l'utilisateur dans Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: newAdmin.email,
      password: newAdmin.password,
      email_confirm: true,
      user_metadata: {
        full_name: newAdmin.name,
        role: newAdmin.role
      }
    })
    
    if (authError) throw authError
    
    // Ajouter l'utilisateur à la table users si nécessaire
    // (selon votre architecture, cela pourrait être fait par un trigger)
    
    showToast.success('Administrateur ajouté avec succès', 'success')
    showAddAdminModal.value = false
    
  } catch (error) {
    console.error('Erreur lors de l\'ajout de l\'administrateur:', error)
    showToast.error('Impossible d\'ajouter l\'administrateur', 'error')
  } finally {
    addingAdmin.value = false
  }
}

const saveSmtpSettingsHandler = async () => {
  try {
    smtpLoading.value = true
    await saveSmtpSettings(smtpConfig.value)
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Enregistrer l'activité (sans exposer les informations sensibles)
      await supabase
        .from('activities')
        .insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'smtp_settings',
          entity_id: null,
          details: { 
            host: smtpConfig.value.host,
            port: smtpConfig.value.port,
            secure: smtpConfig.value.secure
          }
        })
    }
    
    showSmtpModal.value = false
    showToast.success('Configuration SMTP enregistrée', 'success')
  } catch (error) {
    console.error('Erreur lors de la sauvegarde des paramètres SMTP:', error)
    showToast.error('Erreur lors de la sauvegarde', 'error')
  } finally {
    smtpLoading.value = false
  }
}

const startBackup = async () => {
  try {
    backupLoading.value = true
    // Simuler un délai de sauvegarde
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    await updateBackupInfo()
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Enregistrer l'activité
      await supabase
        .from('activities')
        .insert({
          user_id: user.id,
          action_type: 'create',
          entity_type: 'backup',
          entity_id: null,
          details: { timestamp: new Date().toISOString() }
        })
    }
    
    showToast.success('Sauvegarde effectuée avec succès', 'success')
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    showToast.error('Erreur lors de la sauvegarde', 'error')
  } finally {
    backupLoading.value = false
  }
}

const clearCache = async () => {
  try {
    cacheLoading.value = true
    // Simuler un délai de nettoyage
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    await updateCacheInfo()
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Enregistrer l'activité
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

const openSessions = () => {
  // Implémenter la logique de gestion des sessions
}

const saveProfile = async () => {
  try {
    profileLoading.value = true
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('Utilisateur non connecté')
    }
    
    // Mettre à jour les métadonnées de l'utilisateur dans Auth
    const { error: authUpdateError } = await supabase.auth.updateUser({
      data: {
        full_name: profile.name
      }
    })
    
    if (authUpdateError) throw authUpdateError
    
    // Mettre à jour l'email si nécessaire
    if (user.email !== profile.email) {
      const { error: emailUpdateError } = await supabase.auth.updateUser({
        email: profile.email
      })
      
      if (emailUpdateError) throw emailUpdateError
    }
    
    // Mettre à jour la table users si vous avez une table utilisateurs personnalisée
    const { error: dbUpdateError } = await supabase
      .from('users')
      .update({
        full_name: profile.name,
        email: profile.email,
        updated_at: new Date()
      })
      .eq('id', user.id)
    
    if (dbUpdateError) throw dbUpdateError
    
    // Enregistrer l'activité
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

const toggleTwoFactorSetting = async (value) => {
  try {
    await toggleTwoFactor(value)
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Enregistrer l'activité
      await supabase
        .from('activities')
        .insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'security_setting',
          entity_id: null,
          details: { setting: 'two_factor', value: value }
        })
    }
    
    showToast.success(
      value ? 'Authentification à deux facteurs activée' : 'Authentification à deux facteurs désactivée',
      'success'
    )
  } catch (error) {
    console.error('Erreur lors de la modification de l\'authentification à deux facteurs:', error)
    showToast.error('Erreur lors de la modification des paramètres', 'error')
  }
}

const toggleMaintenanceModeSetting = async (value) => {
  try {
    await toggleMaintenanceMode(value)
    
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Enregistrer l'activité
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

// Helper methods
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', { 
    day: '2-digit', 
    month: 'long', 
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Load initial data
onMounted(async () => {
  await loadAllSettings()
})

definePageMeta({
  layout: 'admin'
})
</script>