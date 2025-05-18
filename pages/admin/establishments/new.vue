<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <div class="flex items-center space-x-3">
            <NuxtLink 
              to="/admin"
              class="text-gray-500 hover:text-gray-700"
            >
              <ArrowLeft class="w-5 h-5" />
            </NuxtLink>
            <h1 class="text-2xl font-bold text-gray-900">Nouveau restaurant</h1>
          </div>
          <p class="text-gray-600 mt-1">Créez un nouveau restaurant et configurez ses paramètres</p>
        </div>
      </div>
  
      <!-- Form -->
      <div class="max-w-3xl">
        <form @submit.prevent="createRestaurant" class="space-y-6">
          <!-- Restaurant Info -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Informations du restaurant</h2>
            </div>
            <div class="p-6">
              <div class="grid grid-cols-2 gap-6">
                <div class="col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Nom du restaurant
                  </label>
                  <input 
                    v-model="form.name"
                    type="text"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="Ex: Le Bistrot Parisien"
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
                    placeholder="contact@restaurant.fr"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Téléphone
                  </label>
                  <input 
                    v-model="form.phone"
                    type="tel"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="+33 1 23 45 67 89"
                  />
                </div>
  
                <div class="col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Adresse complète
                  </label>
                  <input 
                    v-model="form.address"
                    type="text"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="123 Rue de Paris, 75001 Paris"
                  />
                </div>
              </div>
            </div>
          </div>
  
          <!-- Owner Info -->
          <div class="bg-white rounded-xl border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100">
              <h2 class="text-lg font-semibold text-gray-900">Propriétaire</h2>
            </div>
            <div class="p-6">
              <div class="grid grid-cols-2 gap-6">
                <div class="col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Nom complet
                  </label>
                  <input 
                    v-model="form.ownerName"
                    type="text"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="Jean Dupont"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Email du propriétaire
                  </label>
                  <input 
                    v-model="form.ownerEmail"
                    type="email"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="jean@restaurant.fr"
                  />
                </div>
  
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Téléphone du propriétaire
                  </label>
                  <input 
                    v-model="form.ownerPhone"
                    type="tel"
                    required
                    class="w-full h-10 px-3 border border-gray-200 rounded-lg focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    placeholder="+33 6 12 34 56 78"
                  />
                </div>
              </div>
            </div>
          </div>
  
          <!-- Submit -->
          <div class="flex justify-end space-x-4">
            <NuxtLink
              to="/admin"
              class="px-4 py-2 bg-white border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors"
            >
              Annuler
            </NuxtLink>
            <button
              type="submit"
              class="px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 text-sm font-medium transition-colors"
              :disabled="loading"
            >
              <template v-if="loading">
                <Loader2 class="w-4 h-4 animate-spin" />
              </template>
              <template v-else>
                Créer le restaurant
              </template>
            </button>
          </div>
        </form>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ArrowLeft, Loader2 } from 'lucide-vue-next'
  import { useCustomToast } from '~/composables/useToast'
  import { useSupabaseWrapper } from '~/composables/useSupabase'
  
  const { showToast } = useCustomToast()
  const { client: supabase } = useSupabaseWrapper()
  const router = useRouter()
  const loading = ref(false)
  
  const form = reactive({
    name: '',
    email: '',
    phone: '',
    address: '',
    ownerName: '',
    ownerEmail: '',
    ownerPhone: ''
  })
  
  const createRestaurant = async () => {
    loading.value = true
    
    try {
      // First check if the owner email already exists
      const { data: existingUser, error: userError } = await supabase
        .from('users')
        .select('id')
        .eq('email', form.ownerEmail)
        .single()
      
      let userId
      
      if (userError && userError.code === 'PGRST116') {
        // User doesn't exist, create a new one
        const { data: newUser, error: createError } = await supabase
          .from('users')
          .insert({
            email: form.ownerEmail,
            full_name: form.ownerName,
            phone: form.ownerPhone,
            role: 'manager',
            status: 'active'
          })
          .select('id')
          .single()
        
        if (createError) throw createError
        userId = newUser.id
      } else if (userError) {
        throw userError
      } else {
        // User exists
        userId = existingUser.id
      }
      
      // Now create the establishment
      const { data: establishment, error: estError } = await supabase
        .from('establishments')
        .insert({
          name: form.name,
          email: form.email,
          phone: form.phone,
          address: form.address,
          user_id: userId,
          is_active: true,
          subscription_type: 'basic'
        })
        .select('id')
        .single()
      
      if (estError) throw estError
      
      showToast.success('Restaurant créé', 'Le restaurant a été créé avec succès')
      router.push(`/admin/restaurants/${establishment.id}`)
      
    } catch (error) {
      console.error('Error creating restaurant:', error)
      showToast.error('Erreur', "Une erreur s'est produite lors de la création")
    } finally {
      loading.value = false
    }
  }
  
  definePageMeta({
    layout: 'admin'
  })
  </script>