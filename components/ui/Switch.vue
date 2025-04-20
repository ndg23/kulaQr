<template>
  <button
    type="button"
    :class="[
      modelValue ? 'bg-blue-600' : 'bg-gray-200',
      'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2'
    ]"
    role="switch"
    :aria-checked="modelValue"
    @click="$emit('update:modelValue', !modelValue)"
  >
    <span
      :class="[
        modelValue ? 'translate-x-5' : 'translate-x-0',
        'pointer-events-none relative inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out'
      ]"
    >
      <span
        :class="[
          modelValue 
            ? 'opacity-0 duration-100 ease-out' 
            : 'opacity-100 duration-200 ease-in',
          'absolute inset-0 flex h-full w-full items-center justify-center transition-opacity'
        ]"
        aria-hidden="true"
      >
        <Icon name="x" class="h-3 w-3 text-gray-400" />
      </span>
      <span
        :class="[
          modelValue 
            ? 'opacity-100 duration-200 ease-in' 
            : 'opacity-0 duration-100 ease-out',
          'absolute inset-0 flex h-full w-full items-center justify-center transition-opacity'
        ]"
        aria-hidden="true"
      >
        <Icon name="check" class="h-3 w-3 text-blue-600" />
      </span>
    </span>
  </button>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: boolean
}>()

defineEmits<{
  (e: 'update:modelValue', value: boolean): void
}>()
</script> 