<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Paramètres</h1>
        <p class="text-gray-600">Gérez les paramètres de votre plateforme</p>
      </div>
  
      <!-- Settings Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Settings -->
        <div class="lg:col-span-2 space-y-6">
          <!-- General Settings -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Paramètres généraux</h2>
            </div>
            <div class="p-6">
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Nom de la plateforme
                  </label>
                  <input 
                    v-model="settings.platformName"
                    type="text"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Email de contact
                  </label>
                  <input 
                    v-model="settings.contactEmail"
                    type="email"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Fuseau horaire par défaut
                  </label>
                  <select 
                    v-model="settings.timezone"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  >
                    <option value="Europe/Paris">Europe/Paris</option>
                    <option value="UTC">UTC</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Email Settings -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Configuration des emails</h2>
            </div>
            <div class="p-6">
              <div class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    SMTP Host
                  </label>
                  <input 
                    v-model="settings.smtpHost"
                    type="text"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    SMTP Port
                  </label>
                  <input 
                    v-model="settings.smtpPort"
                    type="number"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Email d'envoi
                  </label>
                  <input 
                    v-model="settings.fromEmail"
                    type="email"
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Sidebar -->
        <div class="space-y-6">
          <!-- Quick Actions -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Actions rapides</h2>
            </div>
            <div class="p-6">
              <div class="space-y-3">
                <button 
                  @click="saveSettings"
                  class="w-full flex items-center justify-center px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
                  :disabled="loading"
                >
                  <template v-if="loading">
                    <Loader2 class="w-4 h-4 animate-spin" />
                  </template>
                  <template v-else>
                    <Save class="w-4 h-4 mr-2" />
                    Enregistrer les modifications
                  </template>
                </button>
                <button 
                  @click="resetSettings"
                  class="w-full flex items-center justify-center px-4 py-2 bg-gray-50 text-gray-700 rounded-lg hover:bg-gray-100 text-sm font-medium transition-colors"
                >
                  <RotateCcw class="w-4 h-4 mr-2" />
                  Réinitialiser
                </button>
              </div>
            </div>
          </div>
  
          <!-- System Info -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Informations système</h2>
            </div>
            <div class="p-6">
              <div class="space-y-4">
                <div>
                  <div class="text-sm text-gray-500">Version</div>
                  <div class="font-medium">v1.0.0</div>
                </div>
                <div>
                  <div class="text-sm text-gray-500">Dernière mise à jour</div>
                  <div class="font-medium">{{ new Date().toLocaleDateString() }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-500">Environnement</div>
                  <div class="font-medium">Production</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { Save, RotateCcw, Loader2 } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const loading = ref(false)
  
  // Settings data
  const settings = reactive({
    platformName: 'Kula QR',
    contactEmail: 'contact@kulaqr.com',
    timezone: 'Europe/Paris',
    smtpHost: 'smtp.example.com',
    smtpPort: 587,
    fromEmail: 'noreply@kulaqr.com'
  })
  
  // Initial settings for reset
  const initialSettings = { ...settings }
  
  const saveSettings = async () => {
    loading.value = true
    try {
      // Simulation d'appel API
      await new Promise(resolve => setTimeout(resolve, 1000))
      toast.success('Paramètres enregistrés', 'Les modifications ont été enregistrées avec succès')
    } catch (error) {
      toast.error('Erreur', "Une erreur s'est produite lors de l'enregistrement")
    } finally {
      loading.value = false
    }
  }
  
  const resetSettings = () => {
    if (confirm('Êtes-vous sûr de vouloir réinitialiser les paramètres ?')) {
      Object.assign(settings, initialSettings)
      toast.success('Paramètres réinitialisés', 'Les paramètres ont été réinitialisés avec succès')
    }
  }
  
  definePageMeta({
    layout: 'admin'
  })
  </script>