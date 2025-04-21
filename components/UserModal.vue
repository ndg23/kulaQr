<template>
    <TransitionRoot appear :show="isOpen" as="template">
      <Dialog as="div" @close="close" class="relative z-50">
        <TransitionChild
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/25" />
        </TransitionChild>
  
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-lg rounded-2xl bg-white p-6">
                <DialogTitle class="text-lg font-semibold text-gray-900">
                  {{ editingUser ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur' }}
                </DialogTitle>
  
                <form @submit.prevent="handleSubmit" class="mt-6 space-y-6">
                  <!-- User Info -->
                  <div class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Nom complet
                      </label>
                      <input 
                        v-model="form.name"
                        type="text"
                        required
                        class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                      />
                    </div>
  
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Email
                      </label>
                      <input 
                        v-model="form.email"
                        type="email"
                        required
                        class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                      />
                    </div>
  
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Rôle
                      </label>
                      <select 
                        v-model="form.role"
                        required
                        class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                      >
                        <option value="admin">Admin</option>
                        <option value="manager">Manager</option>
                        <option value="user">Utilisateur</option>
                      </select>
                    </div>
  
                    <div v-if="!editingUser">
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Mot de passe
                      </label>
                      <input 
                        v-model="form.password"
                        type="password"
                        :required="!editingUser"
                        class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                      />
                    </div>
                  </div>
  
                  <!-- Actions -->
                  <div class="flex justify-end space-x-4 pt-4">
                    <button
                      type="button"
                      class="px-4 py-2 bg-white border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors"
                      @click="close"
                    >
                      Annuler
                    </button>
                    <button
                      type="submit"
                      class="px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
                      :disabled="loading"
                    >
                      <template v-if="loading">
                        <Loader2 class="w-4 h-4 animate-spin" />
                      </template>
                      <template v-else>
                        {{ editingUser ? 'Enregistrer' : 'Créer' }}
                      </template>
                    </button>
                  </div>
                </form>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </template>
  
  <script setup lang="ts">
  import {
    Dialog,
    DialogPanel,
    DialogTitle,
    TransitionRoot,
    TransitionChild
  } from '@headlessui/vue'
  import { Loader2 } from 'lucide-vue-next'
  
  const props = defineProps<{
    isOpen: boolean
    editingUser?: any
  }>()
  
  const emit = defineEmits(['close', 'submit'])
  
  const loading = ref(false)
  const form = reactive({
    name: '',
    email: '',
    role: 'user',
    password: ''
  })
  
  // Remplir le formulaire si on édite un utilisateur
  watch(() => props.editingUser, (user) => {
    if (user) {
      Object.assign(form, {
        name: user.name,
        email: user.email,
        role: user.role
      })
    } else {
      // Réinitialiser le formulaire
      Object.assign(form, {
        name: '',
        email: '',
        role: 'user',
        password: ''
      })
    }
  }, { immediate: true })
  
  const close = () => {
    emit('close')
  }
  
  const handleSubmit = async () => {
    loading.value = true
    try {
      await emit('submit', { ...form })
      close()
    } finally {
      loading.value = false
    }
  }
  </script>