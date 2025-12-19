<template>
  <div class="space-y-1.5">
    <label 
      v-if="label" 
      :for="id" 
      class="block text-sm font-medium text-gray-900"
    >
      {{ label }}
      <span v-if="required" class="text-red-500 ml-0.5">*</span>
    </label>
    
    <select
      :id="id"
      :value="modelValue"
      :required="required"
      :disabled="disabled"
      :class="[
        'block w-full px-3 py-2.5 text-sm border rounded-lg transition-all duration-150',
        'focus:outline-none focus:ring-1',
        error 
          ? 'border-red-300 focus:border-red-300 focus:ring-red-200' 
          : 'border-gray-200 focus:border-gray-300 focus:ring-gray-200',
        disabled 
          ? 'bg-gray-50 text-gray-500 cursor-not-allowed' 
          : 'bg-white text-gray-900'
      ]"
      @change="updateValue"
      @blur="$emit('blur')"
      @focus="$emit('focus')"
    >
      <option v-if="placeholder" value="" disabled>{{ placeholder }}</option>
      <option
        v-for="option in options"
        :key="option.value"
        :value="option.value"
      >
        {{ option.label }}
      </option>
    </select>
    
    <p v-if="error" class="text-sm text-red-600">
      {{ error }}
    </p>
    
    <p v-else-if="hint" class="text-sm text-gray-500">
      {{ hint }}
    </p>
  </div>
</template>

<script setup lang="ts">
interface Option {
  value: string | number
  label: string
}

interface Props {
  id: string
  modelValue: string | number
  options: Option[]
  label?: string
  placeholder?: string
  required?: boolean
  disabled?: boolean
  error?: string
  hint?: string
}

const props = withDefaults(defineProps<Props>(), {
  required: false,
  disabled: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  blur: []
  focus: []
}>()

const updateValue = (event: Event) => {
  const target = event.target as HTMLSelectElement
  emit('update:modelValue', target.value)
}
</script>