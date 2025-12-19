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
    
    <div class="relative">
      <input
        :id="id"
        :type="type"
        :value="modelValue"
        :placeholder="placeholder"
        :required="required"
        :disabled="disabled"
        :readonly="readonly"
        :maxlength="maxlength"
        :pattern="pattern"
        :class="[
          'block w-full px-3 py-2.5 text-sm border rounded-lg transition-all duration-150',
          'placeholder:text-gray-400',
          'focus:outline-none focus:ring-1',
          error 
            ? 'border-red-300 focus:border-red-300 focus:ring-red-200' 
            : 'border-gray-200 focus:border-gray-300 focus:ring-gray-200',
          disabled 
            ? 'bg-gray-50 text-gray-500 cursor-not-allowed' 
            : 'bg-white text-gray-900',
          readonly 
            ? 'bg-gray-50' 
            : ''
        ]"
        @input="updateValue"
        @blur="$emit('blur')"
        @focus="$emit('focus')"
      />
      
      <!-- Icon slot -->
      <div v-if="$slots.icon" class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
        <slot name="icon" />
      </div>
    </div>
    
    <p v-if="error" class="text-sm text-red-600">
      {{ error }}
    </p>
    
    <p v-else-if="hint" class="text-sm text-gray-500">
      {{ hint }}
    </p>
  </div>
</template>

<script setup lang="ts">
interface Props {
  id: string
  modelValue: string | number
  label?: string
  type?: string
  placeholder?: string
  required?: boolean
  disabled?: boolean
  readonly?: boolean
  error?: string
  hint?: string
  maxlength?: number
  pattern?: string
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  required: false,
  disabled: false,
  readonly: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  blur: []
  focus: []
}>()

const updateValue = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
}
</script>