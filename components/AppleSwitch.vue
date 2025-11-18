<template>
  <button
    :class="[
      'relative inline-flex h-[31px] w-[51px] items-center rounded-full transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2',
      modelValue ? 'bg-green-500' : 'bg-gray-300'
    ]"
    role="switch"
    :aria-checked="modelValue"
    @click="toggle"
  >
    <span
      :class="[
        'inline-block h-[27px] w-[27px] transform rounded-full bg-white shadow-lg transition-transform duration-200 ease-in-out',
        modelValue ? 'translate-x-[22px]' : 'translate-x-[2px]'
      ]"
    />
  </button>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const toggle = () => {
  emit('update:modelValue', !props.modelValue)
}
</script>

<style scoped>
button {
  -webkit-tap-highlight-color: transparent;
}
</style>