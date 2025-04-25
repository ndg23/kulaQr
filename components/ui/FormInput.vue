<template>
  <div class="twitter-input-wrapper relative font-twitter">
    <div 
      class="relative border rounded-[25px] bg-white dark:bg-black transition-colors duration-200
      border-gray-200 dark:border-gray-700 focus-within:border-twitter-blue dark:focus-within:border-twitter-blue
      hover:border-gray-300 dark:hover:border-gray-600"
      :class="{ 'twitter-focus-ring': isFocused }"
    >
      <input
        :id="id"
        :value="modelValue"
        @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        @focus="isFocused = true"
        @blur="isFocused = false"
        :type="type"
        :required="required"
        :disabled="disabled"
        class="peer w-full pt-6 pb-2 pl-5 pr-1 bg-transparent text-black dark:text-white text-base focus:outline-none"
        :placeholder="' '"
      />
      <label
        :for="id"
        class="absolute left-5 top-2 text-xs font-medium text-gray-500 dark:text-gray-400 transition-all
        peer-placeholder-shown:text-base peer-placeholder-shown:top-3.5 peer-placeholder-shown:text-gray-500
        peer-focus:text-xs peer-focus:top-2 peer-focus:text-twitter-blue dark:peer-focus:text-twitter-blue"
      >
        {{ label }}
        <span v-if="required" class="text-red-500 ml-0.5">*</span>
      </label>
    </div>
    <div v-if="$slots.append" class="absolute right-3 top-5 -translate-y-1/2 text-twitter-blue">
      <slot name="append" />
    </div>
    <p v-if="error" class="mt-1 text-xs text-red-500 pl-1">{{ error }}</p>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

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

const id = computed(() => props.id || `twitter-input-${Math.random().toString(36).substr(2, 9)}`)
const isFocused = ref(false)
</script>

<style scoped>
/* Twitter 2021 specific styling */
.font-twitter {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

/* Twitter blue color from 2021 - slightly different from 2022 */
:root {
  --twitter-blue: #1DA1F2;
}

.text-twitter-blue {
  color: #1DA1F2;
}

.border-twitter-blue {
  border-color: #1DA1F2;
}

.focus-within\:border-twitter-blue:focus-within {
  border-color: #1DA1F2;
}

/* Custom focus ring class instead of using @apply with unavailable classes */
.twitter-focus-ring {
  box-shadow: 0 0 0 1px rgba(29, 161, 242, 0.4);
}

/* Twitter input height in 2021 was slightly shorter than in 2022 */
.twitter-input-wrapper {
  margin-bottom: 0.75rem;
}

/* Ensure clean transition between states */
input {
  transition: background-color 0.2s ease;
}

label {
  transition: all 0.15s ease;
  transform-origin: left top;
}

/* Handle disabled state more cleanly */
input:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

input:disabled + label {
  opacity: 0.6;
}
</style>