<template>
    <div class="relative">
      <select
        :id="id"
        :value="modelValue"
        @input="$emit('update:modelValue', $event.target.value)"
        class="block w-full pl-6 pr-4 h-16 pt-3 text-gray-900 appearance-none dark:text-white border border-gray-200 dark:border-gray-700 rounded-2xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors text-lg dark:bg-gray-800"
        :class="[
          error ? 'border-red-500 focus:border-red-500 focus:ring-red-500' : '',
          disabled ? 'bg-gray-100 dark:bg-gray-900 cursor-not-allowed' : ''
        ]"
        :disabled="disabled"
        :required="required"
        :aria-invalid="!!error"
        :aria-describedby="error ? `${id}-error` : undefined"
      >
        <option v-if="placeholder" value="" disabled selected>{{ placeholder }}</option>
        <slot></slot>
      </select>
      
      <label
        :for="id"
        class="absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-3 scale-75 top-4 z-10 origin-[0] left-4 peer-focus:text-primary-600 dark:peer-focus:text-primary-400 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-3"
        :class="[
          error ? 'text-red-500 peer-focus:text-red-500' : ''
        ]"
      >
        {{ label }}
      </label>
      
      <!-- Icône de flèche -->
      <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
        <i class="fas fa-chevron-down text-gray-400 dark:text-gray-500"></i>
      </div>
      
      <!-- Message d'erreur -->
      <p v-if="error" :id="`${id}-error`" class="mt-1 text-xs text-red-500">
        {{ error }}
      </p>
      
      <!-- Texte d'aide -->
      <p v-else-if="helpText" class="mt-1 text-xs text-gray-500 dark:text-gray-400">
        {{ helpText }}
      </p>
    </div>
  </template>
  
  <script setup lang="ts">
  const props = defineProps({
    id: {
      type: String,
      required: true
    },
    modelValue: {
      type: [String, Number],
      default: ''
    },
    label: {
      type: String,
      required: true
    },
    placeholder: {
      type: String,
      default: ''
    },
    error: {
      type: String,
      default: ''
    },
    helpText: {
      type: String,
      default: ''
    },
    disabled: {
      type: Boolean,
      default: false
    },
    required: {
      type: Boolean,
      default: false
    }
  });
  
  defineEmits(['update:modelValue']);
  </script> 