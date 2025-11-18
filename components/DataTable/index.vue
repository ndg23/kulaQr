<template>
  <div class="bg-white dark:bg-gray-900 rounded-xl w-full border border-gray-200 dark:border-gray-800">
    <!-- Table Header avec recherche et filtres -->
    <div class="p-4 border-b border-gray-200 dark:border-gray-800">
      <div class="flex flex-col sm:flex-row justify-between items-center gap-4">
        <!-- Recherche -->
        <div class="relative w-full sm:w-64">
          <input
            v-model="localSearch"
            type="text"
            placeholder="Rechercher..."
            class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-800 dark:text-white font-inter"
          />
          <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
        </div>

        <!-- Actions groupées -->
        <div class="flex items-center gap-2 flex-wrap">
          <!-- Sélection par page -->
          <select
            v-model="localPerPage"
            class="border border-gray-300 dark:border-gray-700 rounded-full px-4 py-2 bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 font-inter text-sm hover:bg-gray-50 transition-colors cursor-pointer"
          >
            <option v-for="n in [10, 25, 50, 100]" :key="n" :value="n">
              {{ n }} par page
            </option>
          </select>

          <!-- Bouton Ajouter (Principal) -->
          <button
            v-if="showAddButton"
            @click="handleAdd"
            class="px-4 py-2 bg-black text-white rounded-full hover:bg-gray-800 transition-all font-inter font-semibold text-sm shadow-sm hover:shadow-md flex items-center gap-2"
          >
            <i class="fas fa-plus text-xs"></i>
            <span>{{ addButtonLabel }}</span>
          </button>

          <!-- Boutons génériques personnalisables -->
          <button
            v-for="(btn, index) in headerButtons"
            :key="index"
            @click="emit('button-click', btn.action)"
            :class="getButtonClass(btn.variant)"
            class="px-4 py-2 rounded-full transition-all font-inter font-semibold text-sm shadow-sm hover:shadow-md flex items-center gap-2"
          >
            <i v-if="btn.icon" :class="btn.icon + ' text-xs'"></i>
            <span>{{ btn.label }}</span>
          </button>

          <!-- Export (Secondaire) -->
          <button
            @click="exportData"
            class="px-4 py-2 bg-white border border-gray-300 dark:border-gray-700 text-gray-700 dark:text-gray-300 rounded-full hover:bg-gray-50 dark:hover:bg-gray-800 transition-all font-inter font-medium text-sm shadow-sm hover:shadow flex items-center gap-2"
          >
            <i class="fas fa-download text-xs"></i>
            <span>Exporter</span>
          </button>

        </div>
      </div>
    </div>

    <!-- Table Content -->
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-800 overflow-x-auto">
        <thead class="bg-gray-50 dark:bg-gray-800 bg-white border-b-2 border-gray-100 bg-gray-100">
          <tr class="text-left">
            <!-- Checkbox pour tout sélectionner -->
            <th scope="col" class="w-12 px-6 py-2.5">
              <input
                type="checkbox"
                v-model="allSelected"
                @click="toggleAll"
                class="rounded border-gray-300 text-primary-600 focus:ring-2 focus:ring-primary-500/20 focus:ring-offset-0"
              />
            </th>
            
            <!-- Colonnes -->
            <th
              v-for="column in columns"
              :key="column.key"
              scope="col"
              class="px-6 py-2.5 text-left text-xs font-semibold text-slate-900 tracking-wide uppercase border-r border-gray-100 font-inter"
              :class="[
                column.sortable !== false ? 'cursor-pointer select-none' : '',
                'hover:bg-gray-50/50 transition-colors duration-150'
              ]"
              @click="column.sortable !== false && sort(column.key)"
            >
              <div class="flex items-center gap-2">
                <span>{{ column.label }}</span>
                <span v-if="column.sortable !== false" class="text-gray-400">
                  <i class="fas fa-sort text-xs" :class="{
                    'opacity-50': sortKey !== column.key,
                    'fa-sort-up': sortKey === column.key && sortOrder === 'asc',
                    'fa-sort-down': sortKey === column.key && sortOrder === 'desc'
                  }"></i>
                </span>
              </div>
            </th>
          </tr>
        </thead>

        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-800">
          <!-- Loading State -->
          <tr v-if="loading"               class="px-6 text-left py-1.5 hover:bg-gray-100/50 transition-colors duration-200 text-sm border-r border-gray-200 divide-x divide-gray-200 text-truncate text-gray-600 whitespace-wrap z-0"
          >
            <td :colspan="columns.length + 1" class="px-6 py-8 text-center">
              <div class="flex items-center justify-center">
                <div class="animate-spin rounded-full h-8 w-8 border-2 border-primary-500 border-t-transparent"></div>
                <span class="ml-3 text-sm font-medium text-gray-600">{{ loadingText }}</span>
              </div>
            </td>
          </tr>

          <!-- Empty State -->
          <tr v-else-if="sortedItems.length === 0">
            <td :colspan="columns.length + 1" class="px-6 py-12 text-center">
              <div class="text-gray-400 dark:text-gray-600 mb-4">
                <i :class="[emptyIcon || 'fas fa-inbox', 'text-5xl']"></i>
              </div>
              <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
                {{ emptyTitle }}
              </h3>
              <p class="text-gray-500 dark:text-gray-400">
                {{ emptyDescription }}
              </p>
            </td>
          </tr>

          <!-- Data Rows -->
          <tr
            v-else
            v-for="item in filteredItems"
            :key="item.id"
            class="hover:bg-gray-50 dark:hover:bg-gray-800/50 px-6 py-1.5"
          >
            <!-- Checkbox -->
            <td class="w-12 px-6 py-1.5">
              <input
                type="checkbox"
                v-model="selectedItems"
                :value="item"
                class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
            </td>

            <!-- Data Cells -->
            <td
              v-for="column in columns"
              :key="column.key"
              class="px-6 py-2 whitespace-nowrap hover:bg-gray-100/50 transition-colors duration-200 text-sm border-r border-gray-200 divide-x divide-gray-200 text-truncate whitespace-wrap z-0"
              :class="{
                'text-md text-gray-900 dark:text-gray-100': !column.type,
                'date-cell': column.type === 'date' || column.type === 'datetime'
              }"
            >
              <slot
                :name="`cell-${column.key}`"
                :item="item"
                :value="getColumnValue(item, column.key)"
                :format="column.formatter"
              >
                <template v-if="column.type === 'date'">
                  <div class="text-sm  dark:text-gray-400">
                    {{ formatDate(getColumnValue(item, column.key)) }}
                  </div>
                </template>
                <template v-else-if="column.type === 'datetime'">
                  <div class="text-sm  dark:text-gray-400">
                    {{ formatDateTime(getColumnValue(item, column.key)) }}
                  </div>
                </template>
                <template v-else-if="column.type === 'seats'">
                  <div class="grid grid-cols-2 lg:grid-cols-2 gap-2 justify-items-center items-start">
                    <span 
                      v-for="seatRes in getColumnValue(item, column.key)" 
                      :key="seatRes.id"
                      class="d-block px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800"
                    >
                      {{ seatRes.seat.seatNumber }}
                    </span>
                  </div>
                </template>
                <template v-else-if="column.type === 'price'">
                  <div class="text-sm font-medium">
                    {{ formatPrice(getColumnValue(item, column.key)) }}
                  </div>
                </template>
                <template v-else-if="column.type === 'schedule'">
                  <div class="space-y-1">
                    <div class="text-sm font-medium text-gray-900">
                      {{ getColumnValue(item, 'schedule.departureStation.stationName') }} → 
                      {{ getColumnValue(item, 'schedule.arrivalStation.stationName') }}
                    </div>
                    <div class="text-xs text-gray-500">
                      {{ formatDateTime(getColumnValue(item, 'schedule.startDate')) }}
                    </div>
                    <div class="text-xs text-gray-500">
                      {{ getColumnValue(item, 'schedule.train.brand') }} 
                      {{ getColumnValue(item, 'schedule.train.model') }}
                    </div>
                  </div>
                </template>
                <template v-else>
                  {{ column.formatter ? column.formatter(item) : getColumnValue(item, column.key) }}
                </template>
              </slot>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div
      v-if="showPagination && totalPages > 0"
      class="flex items-center justify-between px-6 py-3 border-t border-gray-200 dark:border-gray-800"
    >
      <div class="flex items-center text-sm text-gray-700 dark:text-gray-300">
        Affichage de {{ paginationInfo.from }}-{{ paginationInfo.to }} sur {{ totalItems }} éléments
      </div>
      
      <div class="flex items-center space-x-2">
        <button
          @click="changePage(currentPage - 1)"
          :disabled="currentPage === 1"
          class="px-3 py-1 rounded-lg border border-gray-300 dark:border-gray-700 disabled:opacity-50"
        >
          <i class="fas fa-chevron-left"></i>
        </button>
        
        <div class="flex items-center space-x-1">
          <button
            v-for="page in displayedPages"
            :key="page"
            @click="changePage(page)"
            :class="[
              'px-3 py-1 rounded-lg',
              currentPage === page
                ? 'bg-primary-500 text-white'
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            ]"
          >
            {{ page }}
          </button>
        </div>
        
        <button
          @click="changePage(currentPage + 1)"
          :disabled="currentPage === totalPages"
          class="px-3 py-1 rounded-lg border border-gray-300 dark:border-gray-700 disabled:opacity-50"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>
    </div>

    <div class="actions" v-if="!isManager || isOwnedResource">
      <slot name="actions" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { saveAs } from 'file-saver';
import * as XLSX from 'xlsx';
import { formatDate, formatDateTime } from '~/utils/date';

// Types
interface Column {
  key: string;
  label: string;
  type?: 'text' | 'image' | 'status' | 'date' | 'datetime' | 'price' | 'boolean' | 'actions' | 'seats' | 'schedule';
  align?: 'left' | 'right';
  nowrap?: boolean;
  statusOptions?: Record<string, { label: string, class: string }>;
  sortable?: boolean;
  formatter?: (item: any) => string;
}

interface Props {
  items: any[];
  columns: Column[];
  loading?: boolean;
  loadingText?: string;
  emptyIcon?: string;
  emptyTitle?: string;
  emptyDescription?: string;
  itemKey?: string;
  currentPage: number;
  perPage: number;
  totalItems: number;
  showPagination?: boolean;
  item?: any;
  isManager?: boolean;
  managedAgencyId?: string;
  showAddButton?: boolean;
  addButtonLabel?: string;
  headerButtons?: Array<{
    label: string;
    icon?: string;
    variant?: 'primary' | 'secondary' | 'danger' | 'success';
    action: string;
  }>;
}

// Props
const props = withDefaults(defineProps<Props>(), {
  loading: false,
  loadingText: 'Chargement...',
  emptyIcon: 'fas fa-inbox',
  emptyTitle: 'Aucun élément',
  emptyDescription: 'Aucun élément à afficher',
  itemKey: 'id',
  showPagination: false,
  showAddButton: false,
  addButtonLabel: 'Ajouter',
  headerButtons: () => []
});

// Émissions
const emit = defineEmits<{
  (e: 'update:currentPage', page: number): void;
  (e: 'update:perPage', perPage: number): void;
  (e: 'sort', key: string, order: 'asc' | 'desc'): void;
  (e: 'selection-change', items: any[]): void;
  (e: 'page-change', page: number): void;
  (e: 'add'): void;
  (e: 'button-click', action: string): void;
}>();

// État local
const localSearch = ref('');
const localPerPage = ref(props.perPage);
const selectedItems = ref<any[]>([]);
const sortKey = ref('');
const sortOrder = ref<'asc' | 'desc'>('asc');

// Computed
const allSelected = computed({
  get: () => selectedItems.value.length === props.items.length,
  set: (value) => {
    selectedItems.value = value ? [...props.items] : [];
  }
});

const filteredItems = computed(() => {
  if (!props.isManager) return props.items;
  
  return props.items.filter(item => {
    // Vérifie l'agence directement ou via relations
    const agencyId = item.agencyId || 
                    item.agency?.id || 
                    item.train?.agency?.id ||
                    item.schedule?.train?.agency?.id;
                    
    return agencyId === props.managedAgencyId;
  });
});

const sortedItems = computed(() => {
  let result = [...filteredItems.value];
  
  // Recherche
  if (localSearch.value) {
    const search = localSearch.value.toLowerCase();
    result = result.filter(item =>
      Object.values(item).some(val =>
        String(val).toLowerCase().includes(search)
      )
    );
  }
  
  // Tri
  if (sortKey.value) {
    result.sort((a, b) => {
      const aVal = a[sortKey.value];
      const bVal = b[sortKey.value];
      
      if (aVal === bVal) return 0;
      const comparison = aVal > bVal ? 1 : -1;
      return sortOrder.value === 'asc' ? comparison : -comparison;
    });
  }
  
  return result;
});

const totalPages = computed(() =>
  Math.ceil((props.totalItems || sortedItems.value.length) / localPerPage.value)
);

const displayedPages = computed(() => {
  const delta = 2;
  const range = [];
  const rangeWithDots = [];
  let l;

  for (let i = 1; i <= totalPages.value; i++) {
    if (
      i === 1 ||
      i === totalPages.value ||
      (i >= props.currentPage - delta && i <= props.currentPage + delta)
    ) {
      range.push(i);
    }
  }

  range.forEach(i => {
    if (l) {
      if (i - l === 2) {
        rangeWithDots.push(l + 1);
      } else if (i - l !== 1) {
        rangeWithDots.push('...');
      }
    }
    rangeWithDots.push(i);
    l = i;
  });

  return rangeWithDots;
});

const paginationInfo = computed(() => {
  const from = (props.currentPage - 1) * localPerPage.value + 1;
  const to = Math.min(from + localPerPage.value - 1, props.totalItems || sortedItems.value.length);
  return { from, to };
});

// Méthodes
const getItemKey = (item: any, index: number) => {
  return item[props.itemKey] || index;
};

const getColumnValue = (item: any, key: string) => {
  if (!key.includes('.')) return item[key];
  
  return key.split('.').reduce((obj, k) => obj && obj[k], item);
};

const getStatusClass = (status: string, options?: Record<string, { label: string, class: string }>) => {
  if (!status || !options) return 'bg-gray-100 text-gray-800';
  return options[status]?.class || 'bg-gray-100 text-gray-800';
};

const getStatusLabel = (status: string, options?: Record<string, { label: string, class: string }>) => {
  if (!status || !options) return status;
  return options[status]?.label || status;
};

const toggleAll = () => {
  selectedItems.value = allSelected.value ? [] : [...filteredItems.value];
};

const sort = (key: string) => {
  if (sortKey.value === key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc';
  } else {
    sortKey.value = key;
    sortOrder.value = 'asc';
  }
};

const changePage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    emit('page-change', page);
  }
};

const handleAdd = () => {
  emit('add');
};

const getButtonClass = (variant?: 'primary' | 'secondary' | 'danger' | 'success') => {
  const classes = {
    primary: 'bg-blue-500 text-white hover:bg-blue-600',
    secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600',
    danger: 'bg-red-500 text-white hover:bg-red-600',
    success: 'bg-green-500 text-white hover:bg-green-600'
  };
  return classes[variant || 'secondary'];
};

const exportData = () => {
  const dataToExport = sortedItems.value.map(item => {
    const row: Record<string, any> = {};
    props.columns.forEach(column => {
      row[column.label] = column.formatter
        ? column.formatter(item)
        : item[column.key];
    });
    return row;
  });

  const ws = XLSX.utils.json_to_sheet(dataToExport);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Data');
  const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
  const data = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
  saveAs(data, 'export.xlsx');
};

const formatPrice = (price: any): string => {
  if (price === null || price === undefined) return '-';
  const numPrice = Number(price);
  if (isNaN(numPrice)) return '-';
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(numPrice);
};

// Watchers
watch(selectedItems, (items) => {
  emit('selection-change', items);
});

watch(localPerPage, (value) => {
  emit('update:perPage', value);
});

watch(() => props.perPage, (value) => {
  localPerPage.value = value;
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

.font-inter {
  font-family: 'Inter', sans-serif;
}

.date-cell {
  @apply text-sm text-gray-600 dark:text-gray-400;
}

.date-cell:hover .date-tooltip {
  @apply visible opacity-100;
}

.date-tooltip {
  @apply invisible opacity-0 absolute z-10 px-2 py-1 text-xs text-white bg-gray-900 rounded transition-opacity duration-200;
}

/* Animation pour les boutons d'action */
.group:hover button {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Animation pour les tooltips */
.group:hover div[class*="absolute"] {
  transform: translate(-50%, -2px);
}

/* Animation de ripple au clic */
button {
  position: relative;
  overflow: hidden;
}

button::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 5px;
  height: 5px;
  background: rgba(255, 255, 255, 0.5);
  opacity: 0;
  border-radius: 100%;
  transform: scale(1, 1) translate(-50%);
  transform-origin: 50% 50%;
}

@keyframes ripple {
  0% {
    transform: scale(0, 0);
    opacity: 0.5;
  }
  100% {
    transform: scale(40, 40);
    opacity: 0;
  }
}

button:focus:not(:active)::after {
  animation: ripple 1s ease-out;
}

/* Dark mode adjustments */
@media (prefers-color-scheme: dark) {
  button::after {
    background: rgba(255, 255, 255, 0.2);
  }
}
</style> 