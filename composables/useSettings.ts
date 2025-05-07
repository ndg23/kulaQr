import { ref, reactive } from 'vue'
import { useSupabaseWrapper } from './useSupabase'
import { useCustomToast } from './useToast'

export function useSettings() {
  const { client: supabase } = useSupabaseWrapper()
  const { showToast } = useCustomToast()
  
  const isLoading = ref(false)
  const settings = reactive({
    smtp: {
      host: '',
      port: '587',
      username: '',
      password: '',
      secure: true
    },
    security: {
      two_factor_enabled: false,
      password_expiry_days: 90,
      max_login_attempts: 5
    },
    maintenance_mode: false,
    backup: {
      last_backup: null,
      auto_backup: false,
      frequency: 'daily'
    },
    cache: {
      last_cleared: null,
      auto_clear: false,
      frequency: 'weekly'
    },
    app_info: {
      version: '1.0.0',
      environment: 'development',
      last_deployment: null
    }
  })

  // Charger tous les paramètres
  const loadAllSettings = async () => {
    try {
      isLoading.value = true
      
      const { data, error } = await supabase
        .from('system_settings')
        .select('key, value')
      
      if (error) throw error
      
      // Mettre à jour les paramètres
      data.forEach((item: { key: string, value: string }) => {
        if (typeof item.value === 'string') {
          try {
            // Pour les valeurs booléennes stockées comme chaînes
            if (item.value === 'true' || item.value === 'false') {
              settings[item.key] = item.value === 'true'
            } else {
              // Essayer de parser comme JSON
              settings[item.key] = JSON.parse(item.value)
            }
          } catch (e) {
            // Si ce n'est pas du JSON valide, utiliser la valeur telle quelle
            settings[item.key] = item.value
          }
        } else {
          // Si c'est déjà un objet (JSONB)
          settings[item.key] = item.value
        }
      })
      
      return true
    } catch (error) {
      console.error('Erreur lors du chargement des paramètres:', error)
      showToast.error('Impossible de charger les paramètres', 'error')
      return false
    } finally {
      isLoading.value = false
    }
  }

  // Sauvegarder un paramètre
  const saveSetting = async (key: string, value: any) => {
    try {
      isLoading.value = true
      
      const { error } = await supabase
        .from('system_settings')
        .update({ value })
        .eq('key', key)
      
      if (error) throw error
      
      // Mettre à jour l'état local
      settings[key] = value
      
      showToast.success('Paramètre enregistré avec succès', 'success')
      return true
    } catch (error) {
      console.error('Erreur lors de la sauvegarde du paramètre:', error)
      showToast.error('Impossible de sauvegarder le paramètre', 'error')
      return false
    } finally {
      isLoading.value = false
    }
  }

  // Fonctions spécifiques pour les paramètres courants
  const saveSmtpSettings = async (smtpConfig: any) => {
    return await saveSetting('smtp', smtpConfig)
  }

  const toggleMaintenanceMode = async (enabled: boolean) => {
    return await saveSetting('maintenance_mode', enabled)
  }

  const toggleTwoFactor = async (enabled: boolean) => {
    const securitySettings = { ...settings.security, two_factor_enabled: enabled }
    return await saveSetting('security', securitySettings)
  }

  const updateBackupInfo = async (lastBackupDate: string) => {
    const backupSettings = { 
      ...settings.backup, 
      last_backup: lastBackupDate || new Date().toISOString() 
    }
    return await saveSetting('backup', backupSettings)
  }

  const updateCacheInfo = async (lastClearedDate: string) => {
    const cacheSettings = { 
      ...settings.cache, 
      last_cleared: lastClearedDate || new Date().toISOString() 
    }
    return await saveSetting('cache', cacheSettings)
  }

  return {
    settings,
    isLoading,
    loadAllSettings,
    saveSetting,
    saveSmtpSettings,
    toggleMaintenanceMode,
    toggleTwoFactor,
    updateBackupInfo,
    updateCacheInfo
  }
} 