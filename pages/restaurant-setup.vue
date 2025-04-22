<template>
  <div class="min-h-screen bg-gray-50 py-12">
    <div class="max-w-3xl mx-auto">
      <!-- Header -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Configuration de votre restaurant</h1>
        <p class="mt-2 text-gray-600">Personnalisez votre espace pour vos clients</p>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6 space-y-8">
        <!-- Informations de base -->
        <div>
          <h2 class="text-xl font-semibold mb-4">Informations générales</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Description -->
            <div class="col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <textarea
                v-model="description"
                rows="3"
                class="w-full rounded-lg border-gray-300 focus:border-facebook focus:ring-facebook"
                placeholder="Décrivez votre établissement en quelques mots..."
              />
            </div>

            <!-- Téléphone -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Téléphone
              </label>
              <input
                v-model="phone"
                type="tel"
                class="w-full rounded-lg border-gray-300 focus:border-facebook focus:ring-facebook"
                placeholder="+33 6 12 34 56 78"
              />
            </div>

            <!-- Adresse -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Adresse
              </label>
              <input
                v-model="address"
                type="text"
                class="w-full rounded-lg border-gray-300 focus:border-facebook focus:ring-facebook"
                placeholder="123 rue de la Paix, 75000 Paris"
              />
            </div>
          </div>
        </div>

        <!-- Horaires -->
        <div>
          <h2 class="text-xl font-semibold mb-4">Horaires d'ouverture</h2>
          <div class="space-y-4">
            <div v-for="day in days" :key="day.id" class="flex items-center gap-4">
              <span class="w-24 font-medium">{{ day.name }}</span>
              <div class="flex items-center gap-2">
                <input
                  v-model="day.open"
                  type="time"
                  class="rounded-lg border-gray-300 focus:border-facebook focus:ring-facebook"
                />
                <span>-</span>
                <input
                  v-model="day.close"
                  type="time"
                  class="rounded-lg border-gray-300 focus:border-facebook focus:ring-facebook"
                />
              </div>
              <button
                type="button"
                class="text-gray-400 hover:text-gray-600"
                @click="day.closed = !day.closed"
              >
                {{ day.closed ? 'Ouvrir' : 'Fermer' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-4 pt-4">
          <button
            type="button"
            class="px-6 py-2 border border-gray-300 rounded-full text-gray-700 hover:bg-gray-50"
            @click="skipSetup"
          >
            Configurer plus tard
          </button>
          <button
            type="button"
            class="px-6 py-2 bg-facebook text-white rounded-full hover:bg-facebook-dark"
            :disabled="loading"
            @click="saveSetup"
          >
            <template v-if="loading">
              <Loader2 class="w-5 h-5 animate-spin" />
            </template>
            <template v-else>
              Terminer la configuration
            </template>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Loader2 } from 'lucide-vue-next'

const description = ref('')
const phone = ref('')
const address = ref('')
const loading = ref(false)

const days = ref([
  { id: 1, name: 'Lundi', open: '09:00', close: '22:00', closed: false },
  { id: 2, name: 'Mardi', open: '09:00', close: '22:00', closed: false },
  { id: 3, name: 'Mercredi', open: '09:00', close: '22:00', closed: false },
  { id: 4, name: 'Jeudi', open: '09:00', close: '22:00', closed: false },
  { id: 5, name: 'Vendredi', open: '09:00', close: '23:00', closed: false },
  { id: 6, name: 'Samedi', open: '10:00', close: '23:00', closed: false },
  { id: 7, name: 'Dimanche', open: '10:00', close: '22:00', closed: true }
])

const supabase = useSupabaseClient()

const saveSetup = async () => {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Non authentifié')

    const { data: establishment } = await supabase
      .from('establishments')
      .select('id')
      .eq('user_id', user.id)
      .single()

    await supabase
      .from('establishments')
      .update({
        description: description.value,
        phone: phone.value,
        address: address.value,
        opening_hours: JSON.stringify(days.value)
      })
      .eq('id', establishment.id)

    navigateTo('/manager')
  } catch (error) {
    console.error('Erreur:', error)
  } finally {
    loading.value = false
  }
}

const skipSetup = () => {
  navigateTo('/manager')
}

definePageMeta({
  middleware: 'auth'
})
</script> 