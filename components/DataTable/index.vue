<template>
  <div class="bg-white rounded-[2rem] w-full border border-gray-200 overflow-hidden min-w-0">
    <!-- Barre d'outils : recherche + actions -->
    <div class="p-3 sm:p-4 border-b border-gray-200 space-y-3">
      <div class="flex flex-col lg:flex-row lg:items-center gap-3">
        <div class="relative w-full lg:max-w-xs">
          <Search class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
          <input
            v-model="localSearch"
            type="search"
            placeholder="Rechercher..."
            class="w-full h-10 pl-9 pr-3 border border-gray-300 rounded-full text-sm focus:outline-none focus:ring-2 focus:ring-black/10 focus:border-gray-400"
          />
        </div>

        <div class="flex items-center gap-2 flex-wrap lg:ml-auto">
          <select
            v-model="localPerPage"
            aria-label="Éléments par page"
            class="h-10 border border-gray-300 rounded-full px-3 bg-white text-gray-700 text-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-black/10 cursor-pointer"
          >
            <option v-for="n in [10, 25, 50, 100]" :key="n" :value="n">{{ n }} / page</option>
          </select>

          <button
            v-for="(btn, index) in headerButtons"
            :key="index"
            type="button"
            :class="getButtonClass(btn.variant)"
            class="h-10 px-3 sm:px-4 rounded-full transition-colors font-semibold text-sm flex items-center gap-2"
            @click="emit('button-click', btn.action)"
          >
            <component :is="getButtonIcon(btn)" class="w-4 h-4 flex-shrink-0" />
            <span :class="btn.icon ? 'hidden sm:inline' : ''">{{ btn.label }}</span>
          </button>

          <button
            type="button"
            aria-label="Exporter"
            class="h-10 px-3 sm:px-4 bg-white border border-gray-300 text-gray-700 rounded-full hover:bg-gray-50 transition-colors font-medium text-sm flex items-center gap-2"
            @click="exportData"
          >
            <Download class="w-4 h-4 flex-shrink-0" />
            <span class="hidden sm:inline">Exporter</span>
          </button>

          <button
            v-if="showAddButton"
            type="button"
            class="h-10 px-4 bg-black text-white rounded-full hover:bg-gray-800 transition-colors font-semibold text-sm flex items-center gap-2"
            @click="handleAdd"
          >
            <Plus class="w-4 h-4 flex-shrink-0" />
            <span>{{ addButtonLabel }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile : une carte par ligne -->
    <div v-if="isMobile" class="p-3 space-y-3">
      <div v-if="loading" class="px-4 py-10 flex items-center justify-center gap-3">
        <div class="animate-spin rounded-full h-6 w-6 border-2 border-gray-400 border-t-transparent" />
        <span class="text-sm font-medium text-gray-600">{{ loadingText }}</span>
      </div>

      <div v-else-if="sortedItems.length === 0" class="px-4 py-10 text-center">
        <Inbox class="w-10 h-10 mx-auto text-gray-300 mb-3" />
        <h3 class="text-base font-medium text-gray-900 mb-1">{{ emptyTitle }}</h3>
        <p class="text-sm text-gray-500">{{ emptyDescription }}</p>
      </div>

      <article
        v-for="(item, index) in pagedItems"
        v-else
        :key="getItemKey(item, index)"
        class="p-4 space-y-3 rounded-3xl border border-gray-200 bg-white"
      >
        <header class="flex items-start gap-3">
          <div class="flex-1 min-w-0">
            <slot
              v-if="primaryColumn"
              :name="`cell-${primaryColumn.key}`"
              :item="item"
              :value="getColumnValue(item, primaryColumn.key)"
              :format="primaryColumn.formatter"
            >
              <p class="font-medium text-gray-900 break-words">{{ displayValue(item, primaryColumn) }}</p>
            </slot>
          </div>
          <div v-if="actionsColumn" class="flex-shrink-0">
            <slot
              :name="`cell-${actionsColumn.key}`"
              :item="item"
              :value="getColumnValue(item, actionsColumn.key)"
              :format="actionsColumn.formatter"
            />
          </div>
        </header>

        <dl v-if="detailColumns.length" class="grid grid-cols-2 gap-x-4 gap-y-2.5">
          <div v-for="column in detailColumns" :key="column.key" class="min-w-0">
            <dt class="text-xs uppercase tracking-wide text-gray-500 mb-0.5">{{ column.label }}</dt>
            <dd class="text-sm text-gray-900 break-words">
              <slot
                :name="`cell-${column.key}`"
                :item="item"
                :value="getColumnValue(item, column.key)"
                :format="column.formatter"
              >
                {{ displayValue(item, column) }}
              </slot>
            </dd>
          </div>
        </dl>
      </article>
    </div>

    <!-- Desktop : tableau -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-100">
          <tr class="text-left">
            <th scope="col" class="w-12 px-4 lg:px-6 py-3">
              <input
                type="checkbox"
                :checked="allSelected"
                aria-label="Tout sélectionner"
                class="rounded border-gray-300"
                @change="toggleAll"
              />
            </th>

            <th
              v-for="column in columns"
              :key="column.key"
              scope="col"
              class="px-4 lg:px-6 py-3 text-left text-xs font-semibold text-slate-900 tracking-wide uppercase whitespace-nowrap"
              :class="column.sortable !== false ? 'cursor-pointer select-none hover:bg-gray-100 transition-colors' : ''"
              :aria-sort="sortKey === column.key ? (sortOrder === 'asc' ? 'ascending' : 'descending') : undefined"
              @click="column.sortable !== false && sort(column.key)"
            >
              <div class="flex items-center gap-1.5">
                <span>{{ column.label }}</span>
                <template v-if="column.sortable !== false">
                  <ChevronUp v-if="sortKey === column.key && sortOrder === 'asc'" class="w-3.5 h-3.5" />
                  <ChevronDown v-else-if="sortKey === column.key" class="w-3.5 h-3.5" />
                  <ChevronsUpDown v-else class="w-3.5 h-3.5 text-gray-400" />
                </template>
              </div>
            </th>
          </tr>
        </thead>

        <tbody class="bg-white divide-y divide-gray-100">
          <tr v-if="loading">
            <td :colspan="columns.length + 1" class="px-6 py-10 text-center">
              <div class="flex items-center justify-center gap-3">
                <div class="animate-spin rounded-full h-6 w-6 border-2 border-gray-400 border-t-transparent" />
                <span class="text-sm font-medium text-gray-600">{{ loadingText }}</span>
              </div>
            </td>
          </tr>

          <tr v-else-if="sortedItems.length === 0">
            <td :colspan="columns.length + 1" class="px-6 py-12 text-center">
              <Inbox class="w-10 h-10 mx-auto text-gray-300 mb-3" />
              <h3 class="text-lg font-medium text-gray-900 mb-1">{{ emptyTitle }}</h3>
              <p class="text-gray-500">{{ emptyDescription }}</p>
            </td>
          </tr>

          <tr
            v-for="(item, index) in pagedItems"
            v-else
            :key="getItemKey(item, index)"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="w-12 px-4 lg:px-6 py-3">
              <input
                v-model="selectedItems"
                type="checkbox"
                :value="item"
                aria-label="Sélectionner la ligne"
                class="rounded border-gray-300"
              />
            </td>

            <td
              v-for="column in columns"
              :key="column.key"
              class="px-4 lg:px-6 py-3 text-sm text-gray-900 align-middle"
              :class="column.nowrap === false ? '' : 'whitespace-nowrap'"
            >
              <slot
                :name="`cell-${column.key}`"
                :item="item"
                :value="getColumnValue(item, column.key)"
                :format="column.formatter"
              >
                <template v-if="column.type === 'seats'">
                  <div class="grid grid-cols-2 gap-2 justify-items-center items-start">
                    <span
                      v-for="seatRes in getColumnValue(item, column.key)"
                      :key="seatRes.id"
                      class="px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800"
                    >
                      {{ seatRes.seat.seatNumber }}
                    </span>
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
                  </div>
                </template>
                <template v-else>
                  <span :class="column.type === 'date' || column.type === 'datetime' ? 'text-gray-600' : ''">
                    {{ displayValue(item, column) }}
                  </span>
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
      class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 px-3 sm:px-6 py-3 sm:py-4 border-t border-gray-100 bg-gray-50/50"
    >
      <p class="text-sm text-gray-600 text-center sm:text-left">
        <span class="font-bold text-gray-900">{{ paginationInfo.from }}-{{ paginationInfo.to }}</span>
        sur <span class="font-bold text-gray-900">{{ totalCount }}</span>
      </p>

      <div class="flex items-center justify-center gap-1.5">
        <button
          type="button"
          aria-label="Page précédente"
          :disabled="props.currentPage === 1"
          class="h-9 w-9 flex items-center justify-center rounded-full border border-gray-300 disabled:opacity-40 hover:bg-gray-100 transition-colors"
          @click="changePage(props.currentPage - 1)"
        >
          <ChevronLeft class="w-4 h-4" />
        </button>

        <!-- Mobile : page courante seulement -->
        <span class="sm:hidden px-3 text-sm font-medium text-gray-700">
          {{ props.currentPage }} / {{ totalPages }}
        </span>

        <!-- Desktop : numéros de pages -->
        <div class="hidden sm:flex items-center gap-1">
          <template v-for="(page, i) in displayedPages" :key="`${page}-${i}`">
            <span v-if="page === '...'" class="px-1 text-gray-400">…</span>
            <button
              v-else
              type="button"
              class="h-9 min-w-[2.25rem] px-2 rounded-full text-sm font-medium transition-colors"
              :class="props.currentPage === page ? 'bg-black text-white font-bold' : 'hover:bg-gray-100 text-gray-700'"
              :aria-current="props.currentPage === page ? 'page' : undefined"
              @click="changePage(page as number)"
            >
              {{ page }}
            </button>
          </template>
        </div>

        <button
          type="button"
          aria-label="Page suivante"
          :disabled="props.currentPage === totalPages"
          class="h-9 w-9 flex items-center justify-center rounded-full border border-gray-300 disabled:opacity-40 hover:bg-gray-100 transition-colors"
          @click="changePage(props.currentPage + 1)"
        >
          <ChevronRight class="w-4 h-4" />
        </button>
      </div>
    </div>

    <div v-if="!isManager || isOwnedResource" class="actions">
      <slot name="actions" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue';
import { saveAs } from 'file-saver';
import * as XLSX from 'xlsx';
import {
  Search, Download, Plus, Inbox, ChevronUp, ChevronDown, ChevronsUpDown,
  ChevronLeft, ChevronRight, Store, Upload, RefreshCw, Users
} from 'lucide-vue-next';
import { formatDate, formatDateTime } from '~/utils/date';

interface Column {
  key: string;
  label: string;
  type?: 'text' | 'image' | 'status' | 'date' | 'datetime' | 'price' | 'boolean' | 'actions' | 'seats' | 'schedule';
  align?: 'left' | 'right';
  nowrap?: boolean;
  statusOptions?: Record<string, { label: string, class: string }>;
  sortable?: boolean;
  width?: string;
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
  isOwnedResource?: boolean;
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

const emit = defineEmits<{
  (e: 'update:currentPage', page: number): void;
  (e: 'update:perPage', perPage: number): void;
  (e: 'sort', key: string, order: 'asc' | 'desc'): void;
  (e: 'selection-change', items: any[]): void;
  (e: 'page-change', page: number): void;
  (e: 'add'): void;
  (e: 'button-click', action: string): void;
}>();

const localSearch = ref('');
const localPerPage = ref(props.perPage);
const selectedItems = ref<any[]>([]);
const sortKey = ref('');
const sortOrder = ref<'asc' | 'desc'>('asc');

// Affichage : cartes sous 768px (md), tableau au-dessus. Un seul mode est rendu à la fois.
const isMobile = ref(false);
let mediaQuery: MediaQueryList | null = null;
const syncMedia = () => { isMobile.value = !!mediaQuery?.matches; };
onMounted(() => {
  mediaQuery = window.matchMedia('(max-width: 767px)');
  syncMedia();
  mediaQuery.addEventListener('change', syncMedia);
});
onBeforeUnmount(() => mediaQuery?.removeEventListener('change', syncMedia));

// Cartes mobiles : 1re colonne = titre, colonne "actions" = en haut à droite, le reste = détails
const actionsColumn = computed(() => props.columns.find(c => c.key === 'actions' || c.type === 'actions'));
const primaryColumn = computed(() => props.columns.find(c => c !== actionsColumn.value));
const detailColumns = computed(() =>
  props.columns.filter(c => c !== actionsColumn.value && c !== primaryColumn.value)
);

const filteredItems = computed(() => {
  if (!props.isManager) return props.items;

  return props.items.filter(item => {
    const agencyId = item.agencyId ||
                    item.agency?.id ||
                    item.train?.agency?.id ||
                    item.schedule?.train?.agency?.id;

    return agencyId === props.managedAgencyId;
  });
});

const sortedItems = computed(() => {
  let result = [...filteredItems.value];

  if (localSearch.value) {
    const search = localSearch.value.toLowerCase();
    result = result.filter(item =>
      Object.values(item).some(val =>
        String(val).toLowerCase().includes(search)
      )
    );
  }

  if (sortKey.value) {
    const key = sortKey.value;
    result.sort((a, b) => {
      const aVal = getColumnValue(a, key);
      const bVal = getColumnValue(b, key);

      if (aVal === bVal) return 0;
      if (aVal === null || aVal === undefined) return 1;
      if (bVal === null || bVal === undefined) return -1;
      const comparison = aVal > bVal ? 1 : -1;
      return sortOrder.value === 'asc' ? comparison : -comparison;
    });
  }

  return result;
});

// Nombre d'éléments réellement affichables (après recherche) : sert à la pagination
const totalCount = computed(() => sortedItems.value.length);

const totalPages = computed(() =>
  Math.max(1, Math.ceil(totalCount.value / localPerPage.value))
);

const pagedItems = computed(() => {
  if (!props.showPagination) return sortedItems.value;
  const start = (props.currentPage - 1) * localPerPage.value;
  return sortedItems.value.slice(start, start + localPerPage.value);
});

const allSelected = computed(() =>
  pagedItems.value.length > 0 && pagedItems.value.every(i => selectedItems.value.includes(i))
);

const displayedPages = computed(() => {
  const delta = 2;
  const range: number[] = [];
  const rangeWithDots: Array<number | string> = [];
  let l: number | undefined;

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
  if (totalCount.value === 0) return { from: 0, to: 0 };
  const from = (props.currentPage - 1) * localPerPage.value + 1;
  const to = Math.min(from + localPerPage.value - 1, totalCount.value);
  return { from, to };
});

const getItemKey = (item: any, index: number) => {
  return item[props.itemKey] ?? index;
};

function getColumnValue(item: any, key: string) {
  if (!key.includes('.')) return item[key];

  return key.split('.').reduce((obj, k) => obj && obj[k], item);
}

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

// Texte affiché quand la page ne fournit pas de slot pour la colonne
const displayValue = (item: any, column: Column): string => {
  if (column.formatter) return column.formatter(item);
  const value = getColumnValue(item, column.key);
  if (column.type === 'date') return formatDate(value);
  if (column.type === 'datetime') return formatDateTime(value);
  if (column.type === 'price') return formatPrice(value);
  return value === null || value === undefined || value === '' ? '-' : String(value);
};

const toggleAll = () => {
  if (allSelected.value) {
    selectedItems.value = selectedItems.value.filter(i => !pagedItems.value.includes(i));
  } else {
    selectedItems.value = [...new Set([...selectedItems.value, ...pagedItems.value])];
  }
};

const sort = (key: string) => {
  if (sortKey.value === key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc';
  } else {
    sortKey.value = key;
    sortOrder.value = 'asc';
  }
  emit('sort', sortKey.value, sortOrder.value);
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
    secondary: 'bg-gray-100 text-gray-800 hover:bg-gray-200',
    danger: 'bg-red-500 text-white hover:bg-red-600',
    success: 'bg-green-500 text-white hover:bg-green-600'
  };
  return classes[variant || 'secondary'];
};

// Les pages passent des noms d'icônes Font Awesome (non chargé) : on les traduit en icônes lucide
const iconMap: Record<string, any> = {
  'fa-store': Store,
  'fa-upload': Upload,
  'fa-sync': RefreshCw,
  'fa-users': Users,
  'fa-plus': Plus,
  'fa-download': Download
};
const getButtonIcon = (btn: { icon?: string }) => {
  const key = Object.keys(iconMap).find(k => btn.icon?.includes(k));
  return key ? iconMap[key] : Plus;
};

const exportData = () => {
  const dataToExport = sortedItems.value.map(item => {
    const row: Record<string, any> = {};
    props.columns
      .filter(column => column.key !== 'actions')
      .forEach(column => {
        row[column.label] = displayValue(item, column);
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

watch(selectedItems, (items) => {
  emit('selection-change', items);
});

watch(localPerPage, (value) => {
  emit('update:perPage', value);
  emit('page-change', 1);
});

watch(localSearch, () => {
  emit('page-change', 1);
});

watch(() => props.perPage, (value) => {
  localPerPage.value = value;
});
</script>
