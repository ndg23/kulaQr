<template>
  <div :class="['mx-auto', wide ? 'max-w-4xl' : 'max-w-2xl']">
    <!-- En-tête : bouton retour rond + titre -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        :to="backTo"
        :aria-label="backLabel"
        class="w-11 h-11 flex-shrink-0 rounded-full bg-gray-100 flex items-center justify-center text-gray-700 hover:bg-gray-200 active:scale-[0.96] transition-all"
      >
        <ArrowLeft class="w-5 h-5" :stroke-width="2.5" />
      </NuxtLink>
      <div class="min-w-0">
        <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900 break-words">{{ title }}</h1>
        <p v-if="subtitle" class="text-sm text-gray-500 break-words">{{ subtitle }}</p>
      </div>
    </div>

    <!-- Chargement de l'enregistrement à modifier -->
    <div v-if="loadingData" class="rounded-[2rem] bg-white border border-gray-200 p-10 flex items-center justify-center gap-3">
      <div class="animate-spin rounded-full h-6 w-6 border-2 border-gray-400 border-t-transparent" />
      <span class="text-sm font-medium text-gray-600">Chargement...</span>
    </div>

    <!-- Enregistrement introuvable -->
    <div v-else-if="notFound" class="rounded-[2rem] bg-white border border-gray-200 p-10 text-center">
      <p class="text-lg font-extrabold text-gray-900 mb-1">{{ notFoundText }}</p>
      <NuxtLink :to="backTo" class="inline-flex items-center justify-center h-11 px-6 mt-4 rounded-full bg-gray-900 text-white font-bold hover:bg-gray-800 transition-colors">
        Retour
      </NuxtLink>
    </div>

    <form
      v-else
      class="rounded-[2rem] bg-white border border-gray-200 p-5 sm:p-8 space-y-4"
      @submit.prevent="emit('submit')"
    >
      <slot />

      <div v-if="error" class="rounded-3xl bg-red-50 text-red-700 px-5 py-4 text-sm font-semibold flex items-start gap-3" role="alert">
        <AlertCircle class="w-5 h-5 flex-shrink-0 mt-0.5" />
        <span class="break-words min-w-0">{{ error }}</span>
      </div>

      <div v-if="!hideActions" class="flex flex-col-reverse sm:flex-row sm:justify-end gap-3 pt-2">
        <NuxtLink
          :to="backTo"
          class="h-12 px-6 rounded-full bg-gray-100 text-gray-900 font-bold inline-flex items-center justify-center hover:bg-gray-200 active:scale-[0.97] transition-all"
        >
          Annuler
        </NuxtLink>
        <button
          type="submit"
          :disabled="loading || submitDisabled"
          class="h-12 px-8 rounded-full bg-gray-900 text-white font-bold inline-flex items-center justify-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
          {{ loading ? loadingLabel : submitLabel }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, AlertCircle, Loader2 } from 'lucide-vue-next'

withDefaults(defineProps<{
  title: string
  subtitle?: string
  backTo: string
  backLabel?: string
  submitLabel?: string
  loadingLabel?: string
  loading?: boolean
  loadingData?: boolean
  notFound?: boolean
  notFoundText?: string
  error?: string
  submitDisabled?: boolean
  hideActions?: boolean
  wide?: boolean
}>(), {
  backLabel: 'Retour',
  submitLabel: 'Enregistrer',
  loadingLabel: 'Enregistrement...',
  notFoundText: 'Élément introuvable'
})

const emit = defineEmits<{ (e: 'submit'): void }>()
</script>
