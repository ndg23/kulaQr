<template>
  <div class="fixed inset-0 bg-black/30 backdrop-blur-sm flex items-center justify-center z-50">
    <div class="bg-white w-full max-w-lg mx-4 rounded-[2rem] shadow-xl" @click.stop>
      <!-- Header -->
      <div class="p-6 pb-0">
        <h2 class="text-2xl font-bold text-gray-900">
          {{ props.category ? 'Modifier la catégorie' : 'Nouvelle catégorie' }}
        </h2>
        <p class="mt-1 text-sm text-gray-500">
          {{ props.category ? 'Modifiez les informations de la catégorie' : 'Ajoutez une nouvelle catégorie à votre menu' }}
        </p>
      </div>

      <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
        <!-- Name -->
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">
            Nom de la catégorie
          </label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200 transition-all duration-200"
            placeholder="Ex: Entrées, Plats, Desserts..."
          />
        </div>

        <!-- Icon Selection -->
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">
            Icône
          </label>
          <div class="grid grid-cols-4 gap-3">
            <button
              v-for="icon in availableIcons"
              :key="icon.name"
              type="button"
              @click="selectIcon(icon)"
              class="aspect-square rounded-xl border-2 flex items-center justify-center transition-all duration-200"
              :class="[
                form.icon === icon.component
                  ? 'border-blue-500 bg-blue-50 scale-[1.02]'
                  : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
              ]"
            >
              <component 
                :is="icon.component" 
                class="w-6 h-6 transition-colors duration-200" 
                :class="form.icon === icon.component ? 'text-blue-500' : 'text-gray-400'" 
              />
            </button>
          </div>
        </div>

        <!-- Description -->
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">
            Description (optionnelle)
          </label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200 transition-all duration-200"
            placeholder="Description de la catégorie..."
          />
        </div>

        <!-- Order Number -->
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">
            Ordre d'affichage
          </label>
          <input
            v-model="form.order_number"
            type="number"
            min="0"
            required
            class="w-full h-12 px-4 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring focus:ring-blue-200 transition-all duration-200"
          />
        </div>

        <!-- Actions -->
        <div class="flex items-center justify-end space-x-3 pt-6">
          <button
            type="button"
            @click="$emit('close')"
            class="px-6 py-2 bg-white text-gray-700 rounded-full text-sm font-medium border border-gray-200 hover:bg-gray-50 transition-all duration-200"
          >
            Annuler
          </button>
          <button
            type="submit"
            class="px-6 py-2 bg-black text-white rounded-full text-sm font-medium hover:bg-gray-900 transition-all duration-200"
          >
            {{ props.category ? 'Enregistrer' : 'Créer' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  Coffee, Pizza, IceCream, UtensilsCrossed,
  Wine, Beer, Sandwich, Salad,
  Soup, Cake, Fish, Beef
} from 'lucide-vue-next'
import type { Category } from '~/types'

const props = defineProps<{
  show: boolean
  category?: Partial<Category>
}>()

const emit = defineEmits<{
  close: []
  submit: [data: Partial<Category>]
}>()

const availableIcons = [
  { name: 'Entrées', component: UtensilsCrossed },
  { name: 'Pizza', component: Pizza },
  { name: 'Desserts', component: IceCream },
  { name: 'Boissons', component: Coffee },
  { name: 'Vins', component: Wine },
  { name: 'Bières', component: Beer },
  { name: 'Sandwichs', component: Sandwich },
  { name: 'Salades', component: Salad },
  { name: 'Soupes', component: Soup },
  { name: 'Pâtisseries', component: Cake },
  { name: 'Poissons', component: Fish },
  { name: 'Viandes', component: Beef }
]

const form = ref({
  name: props.category?.name || '',
  icon: props.category?.icon || UtensilsCrossed,
  description: props.category?.description || '',
  order_number: props.category?.order_number || 0
})

const selectIcon = (icon: { name: string, component: any }) => {
  form.value.icon = icon.component
}

const handleSubmit = () => {
  emit('submit', {
    ...form.value,
    id: props.category?.id
  })
}

// Close on escape key
onMounted(() => {
  const handleEscape = (e: KeyboardEvent) => {
    if (e.key === 'Escape') emit('close')
  }
  window.addEventListener('keydown', handleEscape)
  return () => window.removeEventListener('keydown', handleEscape)
})
</script>

<style scoped>
.backdrop-blur-sm {
  backdrop-filter: blur(8px);
}
</style> 