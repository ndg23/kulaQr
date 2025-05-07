<template>
  <UModal v-model="show" :ui="{ width: 'sm:max-w-lg' }">
    <div class="space-y-6">
      <!-- En-tête -->
      <div class="space-y-3">
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ title }}
        </h3>
        <p class="text-gray-500 dark:text-gray-400">
          {{ message }}
        </p>
      </div>

      <!-- Détails -->
      <div v-if="details?.length" class="bg-gray-50 dark:bg-gray-800/50 rounded-xl p-4 space-y-3">
        <div 
          v-for="(detail, index) in details" 
          :key="index"
          class="flex justify-between items-center"
        >
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ detail.label }}
          </span>
          <span 
            :class="[
              'text-sm font-medium',
              detail.type === 'badge' && getBadgeClasses(detail.variant),
              detail.type === 'money' && 'font-mono'
            ]"
          >
            {{ formatDetailValue(detail) }}
          </span>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex justify-end gap-3">
        <UButton
          variant="ghost"
          @click="onCancel"
        >
          {{ cancelText }}
        </UButton>
        <UButton
          :color="confirmColor"
          :loading="loading"
          @click="onConfirm"
        >
          {{ confirmText }}
        </UButton>
      </div>
    </div>
  </UModal>
</template>

<script setup>
const props = defineProps({
  modelValue: Boolean,
  title: {
    type: String,
    default: 'Confirmation'
  },
  message: {
    type: String,
    default: 'Êtes-vous sûr de vouloir effectuer cette action ?'
  },
  confirmText: {
    type: String,
    default: 'Confirmer'
  },
  cancelText: {
    type: String,
    default: 'Annuler'
  },
  confirmColor: {
    type: String,
    default: 'primary'
  },
  loading: Boolean,
  details: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'confirm', 'cancel'])

const show = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const getBadgeClasses = (variant) => {
  const variants = {
    success: 'text-green-700 bg-green-50 dark:text-green-400 dark:bg-green-900/50',
    danger: 'text-red-700 bg-red-50 dark:text-red-400 dark:bg-red-900/50',
    warning: 'text-yellow-700 bg-yellow-50 dark:text-yellow-400 dark:bg-yellow-900/50',
    info: 'text-blue-700 bg-blue-50 dark:text-blue-400 dark:bg-blue-900/50'
  }
  return `px-2 py-0.5 rounded-full ${variants[variant] || variants.info}`
}

const formatDetailValue = (detail) => {
  if (detail.type === 'money') {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'XOF'
    }).format(detail.value)
  }
  if (detail.type === 'date') {
    return new Date(detail.value).toLocaleDateString()
  }
  return detail.value
}

const onConfirm = () => emit('confirm')
const onCancel = () => emit('cancel')
</script> 