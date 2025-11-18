<template>
    <div 
      v-if="showModal"
      class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 p-4"
    >
      <div class="bg-white rounded-xl w-full max-w-sm p-4 shadow-lg">
        <h3 class="text-lg font-medium mb-3">Note pour {{ currentItem?.name }}</h3>
        
        <textarea
          v-model="noteText"
          placeholder="Instructions spéciales..."
          class="w-full border border-gray-200 rounded-lg p-3 h-24"
          ref="noteInput"
          maxlength="25"
        ></textarea>
        
        <div class="flex justify-between mt-4">
          <button 
            @click="closeModal"
            class="px-4 py-2 border rounded-lg text-gray-600"
          >
            Annuler
          </button>
          <button 
            @click="saveNote"
            class="px-4 py-2 bg-black text-white rounded-lg"
          >
            Enregistrer
          </button>
        </div>
      </div>
    </div>
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