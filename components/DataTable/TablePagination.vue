<template>
  <div class="flex items-center justify-between mt-4 px-2">
    <!-- Info pagination -->
    <div class="text-sm text-gray-700">
      Affichage de
      <span class="font-medium">{{ startIndex }}</span>
      à
      <span class="font-medium">{{ endIndex }}</span>
      sur
      <span class="font-medium">{{ total }}</span>
      résultats
    </div>

    <div class="flex items-center gap-4">
      <!-- Sélecteur de nombre par page -->
      <div class="flex items-center gap-2">
        <span class="text-sm text-gray-600">Afficher</span>
        <USelect
          v-model="perPage"
          :options="perPageOptions.map(n => ({ label: n.toString(), value: n }))"
          class="w-20"
        />
        <span class="text-sm text-gray-600">par page</span>
      </div>

      <!-- Boutons de pagination -->
      <div class="flex items-center gap-2">
        <UButton
          icon="i-heroicons-chevron-left"
          variant="outline"
          :disabled="currentPage === 1"
          @click="currentPage--"
        />
        
        <div class="flex items-center gap-1">
          <UButton
            v-for="pageNumber in visiblePages"
            :key="pageNumber"
            :variant="pageNumber === currentPage ? 'solid' : 'outline'"
            :color="pageNumber === currentPage ? 'primary' : 'gray'"
            @click="currentPage = pageNumber"
          >
            {{ pageNumber }}
          </UButton>
        </div>

        <UButton
          icon="i-heroicons-chevron-right"
          variant="outline"
          :disabled="currentPage === totalPages"
          @click="currentPage++"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  page: {
    type: Number,
    required: true
  },
  perPage: {
    type: Number,
    required: true
  },
  total: {
    type: Number,
    required: true
  },
  perPageOptions: {
    type: Array,
    default: () => [10, 25, 50, 100]
  }
})

const emit = defineEmits(['update:page', 'update:perPage'])

const currentPage = computed({
  get: () => props.page,
  set: (value) => emit('update:page', value)
})

const perPage = computed({
  get: () => props.perPage,
  set: (value) => emit('update:perPage', value)
})

const totalPages = computed(() => Math.ceil(props.total / props.perPage))
const startIndex = computed(() => ((props.page - 1) * props.perPage) + 1)
const endIndex = computed(() => Math.min(startIndex.value + props.perPage - 1, props.total))

const visiblePages = computed(() => {
  const delta = 2
  const range = []
  const rangeWithDots = []
  let l

  for (let i = 1; i <= totalPages.value; i++) {
    if (
      i === 1 ||
      i === totalPages.value ||
      i >= currentPage.value - delta &&
      i <= currentPage.value + delta
    ) {
      range.push(i)
    }
  }

  range.forEach(i => {
    if (l) {
      if (i - l === 2) {
        rangeWithDots.push(l + 1)
      } else if (i - l !== 1) {
        rangeWithDots.push('...')
      }
    }
    rangeWithDots.push(i)
    l = i
  })

  return rangeWithDots
})
</script> 