<template>
  <Transition
    enter-active-class="transition-opacity duration-200"
    enter-from-class="opacity-0"
    leave-active-class="transition-opacity duration-150"
    leave-to-class="opacity-0"
  >
    <div v-if="showModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-end sm:items-center justify-center z-[60] p-0 sm:p-4" @click.self="closeModal">
      <div class="bg-white rounded-t-[2rem] sm:rounded-[2rem] w-full max-w-md p-5 pb-[calc(1.25rem+env(safe-area-inset-bottom))]" role="dialog" aria-modal="true">
        <h3 class="text-lg font-black text-gray-900 mb-3 break-words">Note pour {{ currentItem?.name }}</h3>
        <textarea
          v-model="noteText"
          placeholder="Sans piment, bien cuit…"
          class="w-full rounded-3xl bg-gray-100 border-0 px-5 py-4 h-24 text-gray-900 placeholder-gray-400 resize-none focus:outline-none focus:ring-2 focus:ring-black"
          ref="noteInput"
          maxlength="25"
        ></textarea>
        <p class="mt-1 text-right text-xs font-bold text-gray-400 tabular-nums">{{ noteText.length }}/25</p>
        <div class="mt-3 grid grid-cols-2 gap-2">
          <button type="button" class="h-14 rounded-full bg-gray-100 text-gray-900 font-extrabold active:scale-[0.97] transition-all" @click="closeModal">Annuler</button>
          <button type="button" class="h-14 rounded-full bg-black text-white font-black active:scale-[0.97] transition-all" @click="saveNote">Enregistrer</button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
  import { ref, computed, nextTick } from 'vue'
  
  const props = defineProps(['cart'])
  const emit = defineEmits(['update:cart'])
  
  const showModal = ref(false)
  const currentItemId = ref(null)
  const noteText = ref('')
  const noteInput = ref(null)
  
  const currentItem = computed(() => {
    if (!currentItemId.value) return null
    return props.cart.find(item => item.id === currentItemId.value)
  })
  
  const openModal = (itemId) => {
    currentItemId.value = itemId
    const item = props.cart.find(item => item.id === itemId)
    noteText.value = item?.note || ''
    showModal.value = true
    
    nextTick(() => {
      if (noteInput.value) noteInput.value.focus()
    })
  }
  
  const closeModal = () => {
    showModal.value = false
  }
  
  const saveNote = () => {
    if (!currentItemId.value) return
    
    const updatedCart = props.cart.map(item => {
      if (item.id === currentItemId.value) {
        return { ...item, note: noteText.value.trim() }
      }
      return item
    })
    
    emit('update:cart', updatedCart)
    closeModal()
  }
  
  defineExpose({ openModal })
  </script>