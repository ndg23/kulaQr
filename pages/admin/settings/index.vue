<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Paramètres</h1>
        <p class="text-gray-600">Configuration système et paramètres utilisateur</p>
      </div>
  
      <!-- Settings Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Main Settings Column -->
        <div class="lg:col-span-2 space-y-8">
          <!-- System Settings Card -->
          <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-2xl bg-blue-50 flex items-center justify-center">
                  <Settings class="w-5 h-5 text-blue-500" />
                </div>
                <div>
                  <h2 class="text-lg font-semibold text-gray-900">Paramètres système</h2>
                  <p class="text-sm text-gray-500">Configuration générale de l'application</p>
                </div>
              </div>
            </div>
  
            <div class="divide-y divide-gray-100">
              <!-- SMTP Settings -->
              <div class="p-6 hover:bg-gray-50 transition-colors">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center">
                      <Mail class="w-4 h-4 text-purple-500" />
                    </div>
                    <div>
                      <h3 class="text-base font-medium text-gray-900">Configuration SMTP</h3>
                      <p class="text-sm text-gray-500">Paramètres d'envoi des emails</p>
                    </div>
                  </div>
                  <button 
                    @click="openSmtpSettings"
                    class="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition-colors shadow-sm"
                  >
                    Configurer
                  </button>
                </div>
              </div>
  
              <!-- API Keys -->
              <div class="p-6 hover:bg-gray-50 transition-colors">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-xl bg-green-50 flex items-center justify-center">
                      <Key class="w-4 h-4 text-green-500" />
                    </div>
                    <div>
                      <h3 class="text-base font-medium text-gray-900">Clés API</h3>
                      <p class="text-sm text-gray-500">Gérez vos clés d'API</p>
                    </div>
                  </div>
                  <button 
                    @click="openApiKeys"
                    class="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition-colors shadow-sm"
                  >
                    Gérer
                  </button>
                </div>
              </div>
  
              <!-- Database Backup -->
              <div class="p-6 hover:bg-gray-50 transition-colors">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-xl bg-orange-50 flex items-center justify-center">
                      <Database class="w-4 h-4 text-orange-500" />
                    </div>
                    <div>
                      <h3 class="text-base font-medium text-gray-900">Sauvegarde</h3>
                      <p class="text-sm text-gray-500">Dernière sauvegarde: {{ lastBackup }}</p>
                    </div>
                  </div>
                  <button 
                    @click="startBackup"
                    class="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition-colors shadow-sm"
                  >
                    Sauvegarder
                  </button>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Security Settings Card -->
          <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-2xl bg-red-50 flex items-center justify-center">
                  <Shield class="w-5 h-5 text-red-500" />
                </div>
                <div>
                  <h2 class="text-lg font-semibold text-gray-900">Sécurité</h2>
                  <p class="text-sm text-gray-500">Paramètres de sécurité avancés</p>
                </div>
              </div>
            </div>
  
            <div class="divide-y divide-gray-100">
              <!-- 2FA -->
              <div class="p-6 hover:bg-gray-50 transition-colors">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-xl bg-indigo-50 flex items-center justify-center">
                      <Fingerprint class="w-4 h-4 text-indigo-500" />
                    </div>
                    <div>
                      <h3 class="text-base font-medium text-gray-900">Authentification à deux facteurs</h3>
                      <p class="text-sm text-gray-500">Renforcez la sécurité de votre compte</p>
                    </div>
                  </div>
                  <Switch
                    v-model="twoFactorEnabled"
                    class="relative inline-flex h-6 w-11 items-center rounded-full"
                    :class="twoFactorEnabled ? 'bg-blue-500' : 'bg-gray-200'"
                  >
                    <span class="sr-only">Activer 2FA</span>
                    <span
                      class="inline-block h-4 w-4 transform rounded-full bg-white transition shadow-sm"
                      :class="twoFactorEnabled ? 'translate-x-6' : 'translate-x-1'"
                    />
                  </Switch>
                </div>
              </div>
  
              <!-- Session Management -->
              <div class="p-6 hover:bg-gray-50 transition-colors">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-xl bg-cyan-50 flex items-center justify-center">
                      <Laptop class="w-4 h-4 text-cyan-500" />
                    </div>
                    <div>
                      <h3 class="text-base font-medium text-gray-900">Sessions actives</h3>
                      <p class="text-sm text-gray-500">Gérez vos sessions connectées</p>
                    </div>
                  </div>
                  <button 
                    @click="openSessions"
                    class="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-50 transition-colors shadow-sm"
                  >
                    Voir les sessions
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Sidebar -->
        <div class="space-y-8">
          <!-- Profile Card -->
          <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-2xl bg-gray-50 flex items-center justify-center">
                  <User class="w-5 h-5 text-gray-500" />
                </div>
                <div>
                  <h2 class="text-lg font-semibold text-gray-900">Profil</h2>
                  <p class="text-sm text-gray-500">Informations personnelles</p>
                </div>
              </div>
            </div>
  
            <div class="p-6">
              <div class="flex items-center space-x-4 mb-6">
                <div class="w-20 h-20 rounded-2xl bg-gray-100 flex items-center justify-center">
                  <User class="w-8 h-8 text-gray-400" />
                </div>
                <button class="px-4 py-2 bg-gray-50 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-100 transition-colors">
                  Changer la photo
                </button>
              </div>
  
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Nom complet
                  </label>
                  <input 
                    v-model="profile.name"
                    type="text"
                    class="w-full h-10 px-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Email
                  </label>
                  <input 
                    v-model="profile.email"
                    type="email"
                    class="w-full h-10 px-3 border border-gray-200 rounded-xl focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>
  
                <button 
                  @click="saveProfile"
                  class="w-full px-4 py-2 bg-black text-white rounded-xl hover:bg-gray-800 text-sm font-medium transition-colors shadow-sm"
                >
                  Enregistrer le profil
                </button>
              </div>
            </div>
          </div>
  
          <!-- Quick Actions -->
          <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
            <div class="p-6 border-b border-gray-100">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-2xl bg-yellow-50 flex items-center justify-center">
                  <Zap class="w-5 h-5 text-yellow-500" />
                </div>
                <div>
                  <h2 class="text-lg font-semibold text-gray-900">Actions rapides</h2>
                  <p class="text-sm text-gray-500">Actions système</p>
                </div>
              </div>
            </div>
  
            <div class="p-6">
              <div class="space-y-3">
                <button class="w-full px-4 py-3 bg-gray-50 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-100 transition-colors text-left flex items-center space-x-2">
                  <Trash2 class="w-4 h-4" />
                  <span>Vider le cache</span>
                </button>
                <button class="w-full px-4 py-3 bg-gray-50 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-100 transition-colors text-left flex items-center space-x-2">
                  <RefreshCw class="w-4 h-4" />
                  <span>Réinitialiser les paramètres</span>
                </button>
                <button class="w-full px-4 py-3 bg-red-50 text-red-600 rounded-xl text-sm font-medium hover:bg-red-100 transition-colors text-left flex items-center space-x-2">
                  <Power class="w-4 h-4" />
                  <span>Mode maintenance</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, reactive } from 'vue'
  import { Switch } from '@headlessui/vue'
  import { 
    Settings, User, Mail, Key, Database, Shield,
    Fingerprint, Laptop, Zap, Trash2, RefreshCw,
    Power
  } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const toast = useToast()
  const twoFactorEnabled = ref(false)
  const lastBackup = ref('20 Avril 2025 15:30')
  
  const profile = reactive({
    name: 'Admin User',
    email: 'admin@kulaqr.com'
  })
  
  const openSmtpSettings = () => {
    // Implémenter la logique d'ouverture des paramètres SMTP
  }
  
  const openApiKeys = () => {
    // Implémenter la logique de gestion des clés API
  }
  
  const startBackup = () => {
    toast.success('Sauvegarde lancée', 'La sauvegarde a été initiée avec succès')
  }
  
  const openSessions = () => {
    // Implémenter la logique de gestion des sessions
  }
  
  const saveProfile = () => {
    toast.success('Profil mis à jour', 'Vos informations ont été enregistrées')
  }
  
  definePageMeta({
    layout: 'admin'
  })
  </script>