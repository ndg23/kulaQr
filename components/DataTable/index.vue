<template>
  <div class="w-full rounded-2xl z-10">
    <!-- Barre de filtres -->
    <TableFilters 
      v-if="showFilters"
      v-model:search="searchQuery"
      :filters="filters"
      :date-range="dateRange"
      @filter="handleFilter"
      @date-change="handleDateChange"
    />

    <!-- Barre d'actions -->
    <TableActions 
      :entity-type="entityType"
      :data="data"
      @export="handleExport"
    />

    <!-- Table -->
    <div class="overflow-x-auto bg-white rounded-2xl border mt-5 border-gray-100">
      <table class="w-full relative">
        <thead class="bg-gray-100 border-b-2 border-gray-100">
          <tr>
            <th 
              v-for="column in columns" 
              :key="column.key"
              class="text-left px-6 py-2 text-sm font-semibold font-mono text-gray-700"
              :class="{ 'cursor-pointer': column.sortable }"
              @click="handleSort(column)"
            >
              <div class="flex items-center gap-2">
                {{ column.label }}
                <div v-if="column.sortable" class="w-4 h-4">
                  <UIcon
                    v-if="getSortDirection(column.key) === 'asc'"
                    name="i-heroicons-chevron-up"
                    class="text-gray-500"
                  />
                  <UIcon
                    v-else-if="getSortDirection(column.key) === 'desc'"
                    name="i-heroicons-chevron-down"
                    class="text-gray-500"
                  />
                  <UIcon
                    v-else
                    name="i-heroicons-arrows-up-down"
                    class="text-gray-300"
                  />
                </div>
              </div>
            </th>
          </tr>
        </thead>
        
        <tbody class="divide-y divide-gray-100">
          <tr 
            v-for="row in displayedData" 
            :key="row.id"
            class="hover:bg-gray-100/50 transition-colors duration-200"
          >
            <td 
              v-for="column in columns" 
              :key="column.key"
              class="px-6 py-2 text-sm text-gray-600"
            >
              <slot 
                :name="`column-${column.key}`" 
                :row="row"
                :value="row[column.key]"
              >
                {{ formatValue(row[column.key], column.type) }}
              </slot>
            </td>
            
            <!-- Actions -->
            <td v-if="hasActions" class="px-6 py-2">
              <div class="flex items-center gap-2 justify-end">
                <slot name="actions" :row="row">
                  <UButton
                    v-for="action in actions"
                    :key="action.key"
                    :icon="action.icon"
                    :variant="action.variant"
                    :tooltip="action.label"
                    @click="handleAction(action, row)"
                  />
                </slot>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <TablePagination 
      v-if="showPagination"
      v-model:page="currentPage"
      v-model:per-page="perPage"
      :total="totalItems"
      :loading="loading"
    />

    <!-- Modals -->
    <ConfirmModal
      v-model="showConfirmModal"
      :title="confirmModal.title"
      :message="confirmModal.message"
      :loading="confirmModal.loading"
      @confirm="handleConfirm"
    />
  </div>
</template>

<script setup>
import { ref, computed, watch, useSlots } from 'vue'
// import { useToast } from '@/composables/useToast'

const slots = useSlots()

const props = defineProps({
  // Données et colonnes
  data: {
    type: Array,
    required: true,
    default: () => []
  },
  columns: {
    type: Array,
    required: true,
    default: () => []
  },
  
  // Options de configuration
  loading: Boolean,
  showFilters: Boolean,
  showPagination: {
    type: Boolean,
    default: true
  },
  actions: {
    type: Array,
    default: () => []
  },
  
  // Pagination
  perPageOptions: {
    type: Array,
    default: () => [10, 25, 50, 100]
  },
  
  // Filtres
  filters: {
    type: Array,
    default: () => []
  },
  dateRange: Boolean,
  
  // Type d'entité pour l'export
  entityType: {
    type: String,
    default: 'data'
  },

  pagination: Object
})

const emit = defineEmits([
  'update:page',
  'update:perPage',
  'sort',
  'filter',
  'date-change',
  'action',
  'export'
])

// État local
const searchQuery = ref('')
const currentPage = ref(1)
const perPage = ref(props.perPageOptions[0])
const sortBy = ref({ key: '', direction: '' })
const activeFilters = ref({})
const confirmModal = ref({
  show: false,
  title: '',
  message: '',
  action: null,
  row: null,
  loading: false
})

// Toast
const toast = useToast()

// Computed
const displayedData = computed(() => {
  let filtered = [...props.data]
  
  // Recherche
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(row => 
      Object.values(row).some(val => 
        String(val).toLowerCase().includes(query)
      )
    )
  }
  
  // Tri
  if (sortBy.value.key) {
    filtered.sort((a, b) => {
      const aVal = a[sortBy.value.key]
      const bVal = b[sortBy.value.key]
      const direction = sortBy.value.direction === 'asc' ? 1 : -1
      return aVal > bVal ? direction : -direction
    })
  }
  
  return filtered
})

const hasActions = computed(() => 
  props.actions?.length > 0 || !!slots.actions
)

// Fonction pour obtenir la direction du tri pour une colonne
const getSortDirection = (columnKey) => {
  if (sortBy.value.key !== columnKey) return null
  return sortBy.value.direction
}

// Gestion du tri
const handleSort = (column) => {
  if (!column.sortable) return
  
  if (sortBy.value.key === column.key) {
    // Si la colonne est déjà triée, on change la direction
    sortBy.value.direction = sortBy.value.direction === 'asc' ? 'desc' : 'asc'
  } else {
    // Sinon, on trie par cette colonne en ordre ascendant
    sortBy.value = { key: column.key, direction: 'asc' }
  }
  
  emit('sort', sortBy.value)
}

const handleFilter = (filters) => {
  activeFilters.value = filters
  emit('filter', filters)
}

const handleAction = (action, row) => {
  if (action.confirm) {
    confirmModal.value = {
      show: true,
      title: action.confirmTitle || 'Confirmer l\'action',
      message: action.confirmMessage || 'Êtes-vous sûr de vouloir effectuer cette action ?',
      action,
      row,
      loading: false
    }
  } else {
    emit('action', { action, row })
  }
}

const handleConfirm = async () => {
  const { action, row } = confirmModal.value
  confirmModal.value.loading = true
  
  try {
    await emit('action', { action, row })
    toast.success('Action effectuée avec succès')
    confirmModal.value.show = false
  } catch (error) {
    toast.error('Une erreur est survenue')
  } finally {
    confirmModal.value.loading = false
  }
}

const formatValue = (value, type) => {
  switch (type) {
    case 'date':
      return new Date(value).toLocaleDateString()
    case 'currency':
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: 'XOF'
      }).format(value)
    case 'number':
      return new Intl.NumberFormat('fr-FR').format(value)
    default:
      return value
  }
}

// Watchers
watch([currentPage, perPage], () => {
  emit('update:page', currentPage.value)
  emit('update:perPage', perPage.value)
})

// Log pour déboguer
console.log('DataTable props:', {
  data: props.data,
  columns: props.columns
})
</script> 