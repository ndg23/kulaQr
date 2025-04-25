<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-lg mx-auto px-4">
      <div class="bg-white rounded-lg shadow p-6">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-xl font-semibold">Ajouter au menu</h1>
          <NuxtLink 
            :to="`/admin/restaurant/${restaurantId}`"
            class="text-gray-600"
          >
            ✕
          </NuxtLink>
        </div>

        <!-- Formulaire simplifié -->
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Type de plat (remplace les catégories) -->
          <div class="flex gap-2">
            <button 
              v-for="type in menuTypes" 
              :key="type.id"
              type="button"
              @click="form.categoryId = type.id"
              :class="[
                'px-4 py-2 rounded-full text-sm',
                form.categoryId === type.id 
                  ? 'bg-blue-500 text-white' 
                  : 'bg-gray-100 text-gray-700'
              ]"
            >
              {{ type.name }}
            </button>
          </div>

          <!-- Nom et prix sur la même ligne -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Nom du plat
              </label>
              <input 
                v-model="form.name"
                type="text"
                placeholder="ex: Pizza Margherita"
                class="w-full px-3 py-2 border rounded-lg"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Prix
              </label>
              <div class="relative">
                <input 
                  v-model="form.price"
                  type="number"
                  step="0.50"
                  placeholder="0.00"
                  class="w-full px-3 py-2 border rounded-lg pl-7"
                />
                <span class="absolute left-3 top-2 text-gray-500"></span>
              </div>
            </div>
          </div>

          <!-- Description -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Description (optionnelle)
            </label>
            <textarea 
              v-model="form.description"
              rows="2"
              placeholder="ex: Sauce tomate, mozzarella, basilic"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>

          <!-- Boutons d'action -->
          <div class="flex gap-3 pt-4">
            <button 
              type="submit"
              class="flex-1 bg-blue-500 text-white py-3 rounded-lg font-medium hover:bg-blue-600"
            >
              Ajouter au menu
            </button>
            <button 
              type="button"
              @click="addAnother"
              class="flex-1 bg-gray-100 text-gray-700 py-3 rounded-lg font-medium hover:bg-gray-200"
            >
              Ajouter un autre
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const router = useRouter()
const supabase = useSupabaseClient()

const restaurantId = route.params.id as string

// Types de plats prédéfinis pour simplifier
const menuTypes = [
  { id: 'entrees', name: 'Entrées' },
  { id: 'plats', name: 'Plats' },
  { id: 'desserts', name: 'Desserts' },
  { id: 'boissons', name: 'Boissons' }
]

const form = ref({
  categoryId: menuTypes[0].id,
  name: '',
  description: '',
  price: 0
})

const handleSubmit = async () => {
  try {
    // Vérifier si la catégorie existe déjà
    let categoryId = form.value.categoryId
    const { data: existingCategory } = await supabase
      .from('categories')
      .select('id')
      .eq('establishment_id', restaurantId)
      .eq('name', menuTypes.find(t => t.id === form.value.categoryId)?.name)
      .single()

    if (!existingCategory) {
      // Créer la catégorie si elle n'existe pas
      const { data: newCategory, error: categoryError } = await supabase
        .from('categories')
        .insert({
          establishment_id: restaurantId,
          name: menuTypes.find(t => t.id === form.value.categoryId)?.name,
          order_number: menuTypes.findIndex(t => t.id === form.value.categoryId)
        })
        .select()
        .single()

      if (categoryError) throw categoryError
      categoryId = newCategory.id
    }

    // Ajouter le produit
    const { error: productError } = await supabase
      .from('products')
      .insert({
        category_id: categoryId,
        name: form.value.name,
        description: form.value.description,
        price: form.value.price,
        order_number: 0
      })

    if (productError) throw productError
    router.push(`/admin/restaurant/${restaurantId}`)
  } catch (err) {
    console.error('Error:', err)
    alert('Erreur lors de l\'ajout du plat')
  }
}

// Pour ajouter un autre plat
const addAnother = async () => {
  await handleSubmit()
  form.value = {
    categoryId: form.value.categoryId, // Garde la même catégorie
    name: '',
    description: '',
    price: 0
  }
}
</script> 