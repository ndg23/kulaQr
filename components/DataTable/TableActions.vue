<template>
  <div class="flex items-center justify-end gap-2 mb-4">
    <div class="bg-white/80 p-2 flex items-center gap-2">
      <!-- Export CSV -->
      <UButton
        class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium text-green-700 border border-green-200/50 hover:border-green-300/50"
        @click="exportData('csv')"
      >
        <div class="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center">
          <UIcon name="i-heroicons-document-arrow-down" class="w-4 h-4" />
        </div>
        <span>CSV</span>
      </UButton>

      <!-- Export Excel -->
      <UButton
        class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium text-blue-700 border border-blue-200/50 hover:border-blue-300/50"
        @click="exportData('excel')"
      >
        <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
          <UIcon name="i-heroicons-table-cells" class="w-4 h-4" />
        </div>
        <span>Excel</span>
      </UButton>

      <!-- Export JSON -->
      <UButton
        class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium text-purple-700 border border-purple-200/50 hover:border-purple-300/50"
        @click="exportData('json')"
      >
        <div class="w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center">
          <UIcon name="i-heroicons-code-bracket" class="w-4 h-4" />
        </div>
        <span>JSON</span>
      </UButton>

      <div class="w-px h-8 bg-gray-200/50" />

      <!-- Print -->
      <UButton
        class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium text-orange-700 border border-orange-200/50 hover:border-orange-300/50"
        @click="printData"
      >
        <div class="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center">
          <UIcon name="i-heroicons-printer" class="w-4 h-4" />
        </div>
        <span>Imprimer</span>
      </UButton>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  data: {
    type: Array,
    required: true
  },
  entityType: {
    type: String,
    default: 'data'
  }
})

const emit = defineEmits(['export'])

const exportData = (type) => {
  const filename = `export-${props.entityType}-${new Date().toISOString().split('T')[0]}`
  emit('export', { type, filename, data: props.data })
}

const printData = () => {
  const printWindow = window.open('', '_blank')
  // ... logique d'impression similaire à l'exemple React
  emit('export', { type: 'print', data: props.data })
}
</script> 