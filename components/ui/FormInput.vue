<template>
  <div class="relative">
    <input
      :id="id"
      :value="modelValue"
      @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
      :type="type"
      :required="required"
      :disabled="disabled"
      class="peer w-full h-14 px-4 pt-5 rounded-lg bg-gray--50 border border-gray-300 focus:outline-none focus:ring-2 focus:ring-facebook focus:border-facebook transition-all text-base placeholder-transparent"
      :placeholder="label"
    />
    <label
      :for="id"
      class="absolute left-4 text-gray-700 transition-all duration-200 transform
      peer-placeholder-shown:text-base peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2
      peer-focus:text-sm peer-focus:top-3 peer-focus:translate-y-0 peer-focus:text-facebook
      text-sm top-3 translate-y-0"
    >
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>
    <div v-if="$slots.append" class="absolute right-4 top-1/2 -translate-y-1/2">
      <slot name="append" />
    </div>
    <p v-if="error" class="mt-1 text-sm text-red-600">{{ error }}</p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  modelValue: string
  label: string
  type?: string
  error?: string
  required?: boolean
  disabled?: boolean
  id?: string
}>()

defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const id = computed(() => props.id || `input-${Math.random().toString(36).substr(2, 9)}`)
</script>

<style scoped>
/* Couleur Facebook */
.text-facebook {
  color: #1877F2;
}

.border-facebook {
  border-color: #1877F2;
}

.ring-facebook {
  --tw-ring-color: #1877F2;
}

/* Animation du label */
.peer:focus ~ label,
.peer:not(:placeholder-shown) ~ label {
  @apply text-sm top-3 translate-y-0;
}

.peer:focus ~ label {
  @apply text-facebook;
}

/* Style disabled */
.peer:disabled {
  @apply bg-gray-50 text-gray-500 cursor-not-allowed;
}

.peer:disabled ~ label {
  @apply text-gray-400;
}
</style> 