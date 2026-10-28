<template>
  <div class="space-y-2">
    <p class="text-sm font-extrabold text-gray-900 px-1">{{ label }}</p>
    <div class="flex items-center gap-4">
      <div class="relative h-24 w-24 flex-shrink-0 rounded-[1.75rem] bg-gray-100 overflow-hidden flex items-center justify-center">
        <img v-if="preview || currentUrl" :src="preview || currentUrl" :alt="label" class="h-full w-full object-cover" />
        <ImageIcon v-else class="h-8 w-8 text-gray-300" />
      </div>

      <div class="min-w-0 space-y-2">
        <div class="flex flex-wrap gap-2">
          <button
            type="button"
            class="h-10 px-4 rounded-full bg-gray-900 text-white text-sm font-bold inline-flex items-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all"
            @click="input?.click()"
          >
            <Upload class="w-4 h-4" />
            Choisir une image
          </button>
          <button
            v-if="preview || currentUrl"
            type="button"
            class="h-10 px-4 rounded-full bg-gray-100 text-gray-900 text-sm font-bold inline-flex items-center gap-2 hover:bg-gray-200 active:scale-[0.97] transition-all"
            @click="remove"
          >
            <X class="w-4 h-4" />
            Retirer
          </button>
        </div>
        <p class="text-xs text-gray-500 px-1">JPG, PNG ou GIF. {{ maxMb }} Mo max.</p>
        <p v-if="error" class="text-xs font-semibold text-red-600 px-1">{{ error }}</p>
      </div>

      <input ref="input" type="file" accept="image/*" class="hidden" @change="onChange" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from 'vue'
import { Upload, ImageIcon, X } from 'lucide-vue-next'

// v-model:file = nouveau fichier choisi ; url = image déjà enregistrée ; removed = l'image existante est retirée
const props = withDefaults(defineProps<{
  label?: string
  url?: string
  file?: File | null
  maxMb?: number
}>(), { label: 'Image', url: '', file: null, maxMb: 2 })

const emit = defineEmits<{
  (e: 'update:file', file: File | null): void
  (e: 'update:url', url: string): void
}>()

const input = ref<HTMLInputElement | null>(null)
const preview = ref('')
const error = ref('')
const currentUrl = ref(props.url)

watch(() => props.url, (v) => { currentUrl.value = v })

const revoke = () => {
  if (preview.value) URL.revokeObjectURL(preview.value)
  preview.value = ''
}

const onChange = (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  error.value = ''
  if (!file.type.startsWith('image/')) {
    error.value = "Ce fichier n'est pas une image"
    return
  }
  if (file.size > props.maxMb * 1024 * 1024) {
    error.value = `L'image dépasse ${props.maxMb} Mo`
    return
  }
  revoke()
  preview.value = URL.createObjectURL(file)
  emit('update:file', file)
}

const remove = () => {
  revoke()
  currentUrl.value = ''
  if (input.value) input.value.value = ''
  emit('update:file', null)
  emit('update:url', '')
}

onBeforeUnmount(revoke)
</script>
