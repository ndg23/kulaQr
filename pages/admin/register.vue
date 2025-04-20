<template>
  <div class="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
    <div class="relative py-3 sm:max-w-xl sm:mx-auto">
      <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
        <div class="max-w-md mx-auto">
          <div class="divide-y divide-gray-200">
            <div class="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
              <h2 class="text-3xl font-bold text-gray-900 mb-8">Inscrivez votre restaurant</h2>
              
              <form @submit.prevent="handleSubmit" class="space-y-6">
                <div>
                  <label class="block text-sm font-medium text-gray-700">Nom du restaurant</label>
                  <input 
                    v-model="form.name"
                    type="text"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Email</label>
                  <input 
                    v-model="form.email"
                    type="email"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Mot de passe</label>
                  <input 
                    v-model="form.password"
                    type="password"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Adresse</label>
                  <input 
                    v-model="form.address"
                    type="text"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Téléphone</label>
                  <input 
                    v-model="form.phone"
                    type="tel"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </div>

                <button 
                  type="submit"
                  class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  S'inscrire
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const router = useRouter()

const form = ref({
  name: '',
  email: '',
  password: '',
  address: '',
  phone: ''
})

const handleSubmit = async () => {
  try {
    // Créer un compte utilisateur
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.value.email,
      password: form.value.password
    })

    if (authError) throw authError

    // Créer l'établissement
    const { data: establishment, error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: form.value.name,
        address: form.value.address,
        phone: form.value.phone,
        user_id: authData.user?.id
      })
      .select()
      .single()

    if (establishmentError) throw establishmentError

    // Rediriger vers le dashboard
    router.push(`/admin/restaurant/${establishment.id}`)
  } catch (error) {
    console.error('Error during registration:', error)
    alert('Une erreur est survenue lors de l\'inscription')
  }
}
</script> 