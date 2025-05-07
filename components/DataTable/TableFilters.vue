<template>
  <div class="flex flex-wrap items-center gap-4 pb-4">
    <!-- Recherche -->
    <div class="flex-1 min-w-[240px]">
      <div class="relative">
        <UIcon 
          name="i-heroicons-magnifying-glass" 
          class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
        />
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher..."
          class="w-full pl-10 pr-4 py-2 bg-white border border-gray-200 
            rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        />
      </div>
    </div>

    <!-- Filtres -->
    <UPopover v-if="filters.length">
      <UButton
        icon="i-heroicons-funnel"
        :variant="hasActiveFilters ? 'soft' : 'outline'"
        :color="hasActiveFilters ? 'primary' : 'gray'"
      >
        Filtres
        <UBadge
          v-if="activeFiltersCount"
          :value="activeFiltersCount"
          variant="solid"
          class="ml-2"
        />
      </UButton>

      <template #content>
        <div class="p-4 w-72 space-y-4">
          <div 
            v-for="filter in filters"
            :key="filter.key"
            class="space-y-2"
          >
            <label class="text-sm font-medium text-gray-700">
              {{ filter.label }}
            </label>
            
            <USelect
              v-if="filter.type === 'select'"
              v-model="activeFilters[filter.key]"
              :options="filter.options"
            />
          </div>

          <div class="flex justify-end gap-2 pt-2 border-t">
            <UButton
              variant="ghost"
              @click="resetFilters"
            >
              Réinitialiser
            </UButton>
            <UButton
              variant="solid"
              color="primary"
              @click="applyFilters"
            >
              Appliquer
            </UButton>
          </div>
        </div>
      </template>
    </UPopover>

    <!-- Date Range -->
    <UDatePicker
      v-if="dateRange"
      v-model="selectedDates"
      range
      :shortcuts="true"
      class="min-w-[240px]"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  // Valeur de recherche
  modelValue: {
    type: String,
    default: ''
  },
  // Configuration des filtres
  filters: {
    type: Array,
    default: () => []
  },
  // Activer le filtre de date
  dateRange: {
    type: Boolean,
    default: false
  },
  // Placeholder de la recherche
  searchPlaceholder: {
    type: String,
    default: 'Rechercher...'
  }
})

const emit = defineEmits(['update:modelValue', 'filter', 'date-change'])

// État local
const activeFilters = ref({})
const selectedDates = ref([])

// Computed
const search = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const hasActiveFilters = computed(() => 
  Object.values(activeFilters.value).some(value => value !== '')
)

const activeFiltersCount = computed(() => 
  Object.values(activeFilters.value).filter(value => value !== '').length
)

// Méthodes
const resetFilters = () => {
  activeFilters.value = {}
  emit('filter', {})
}

const applyFilters = () => {
  emit('filter', activeFilters.value)
}

// Watch dates
watch(selectedDates, (newDates) => {
  if (newDates?.length === 2) {
    emit('date-change', {
      start: newDates[0],
      end: newDates[1]
    })
  }
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style> 