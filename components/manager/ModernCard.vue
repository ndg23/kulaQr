<template>
  <div class="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow duration-200">
    <!-- Card Header -->
    <div v-if="title || $slots.header" class="p-6 border-b border-gray-100">
      <slot name="header">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div v-if="icon" class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
              <component :is="icon" class="w-4 h-4 text-gray-600" />
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">{{ title }}</h3>
              <p v-if="subtitle" class="text-sm text-gray-500">{{ subtitle }}</p>
            </div>
          </div>
          <div v-if="$slots.actions" class="flex items-center gap-2">
            <slot name="actions" />
          </div>
        </div>
      </slot>
    </div>

    <!-- Card Content -->
    <div class="p-6">
      <slot />
    </div>

    <!-- Card Footer -->
    <div v-if="$slots.footer" class="p-6 border-t border-gray-100 bg-gray-50 rounded-b-2xl">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  title?: string
  subtitle?: string
  icon?: any
}

defineProps<Props>()
</script>

<style scoped>
/* Design Twitter 2024 - Cartes modernes */
.rounded-2xl {
  border-radius: 1rem;
}

/* Transitions fluides */
.transition-shadow {
  transition: box-shadow 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Hover effects subtils */
.hover\:shadow-md:hover {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Ombres subtiles */
.shadow-sm {
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}
</style>
