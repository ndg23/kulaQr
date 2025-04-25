<template>
  <div class="w-full">
    <div 
      class="border-2 border-dashed rounded-lg p-4 text-center cursor-pointer hover:bg-gray-50 transition-colors"
      :class="[
        isDragging ? 'border-kula-500 bg-kula-50' : 'border-gray-300',
        error ? 'border-red-300' : ''
      ]"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="onDrop"
      @click="$refs.fileInput.click()"
    >
      <input 
        ref="fileInput" 
        type="file" 
        class="hidden" 
        accept="image/*"
        @change="onFileSelected" 
      />
      
      <div v-if="preview" class="mb-3 relative mx-auto" :style="{ width: previewSize + 'px', height: previewSize + 'px' }">
        <img :src="preview" alt="Preview" class="w-full h-full object-cover rounded" />
        <button 
          @click.stop="removeImage" 
          class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
          title="Supprimer l'image"
        >
          <XIcon class="w-4 h-4" />
        </button>
      </div>
      
      <div v-else>
        <UploadIcon class="w-10 h-10 mx-auto text-gray-400" />
        <p class="mt-2 text-sm text-gray-600">
          Glissez-déposez une image ici ou cliquez pour sélectionner
        </p>
        <p class="text-xs text-gray-500 mt-1">PNG, JPG ou WEBP (max. 2MB)</p>
      </div>
      
      <div v-if="uploading" class="mt-2">
        <div class="w-full bg-gray-200 rounded-full h-2.5">
          <div class="bg-kula-500 h-2.5 rounded-full" :style="{ width: `${uploadProgress}%` }"></div>
        </div>
        <p class="text-xs text-gray-500 mt-1">{{ uploadProgress }}% téléchargé</p>
      </div>
    </div>
    
    <p v-if="error" class="mt-1 text-sm text-red-600">{{ error }}</p>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { UploadIcon, XIcon } from 'lucide-vue-next'
import { useSupabase } from '~/composables/useSupabase'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  bucket: {
    type: String,
    default: 'establishments'
  },
  folder: {
    type: String,
    required: true
  },
  previewSize: {
    type: Number,
    default: 150
  },
  maxSizeMB: {
    type: Number,
    default: 2
  }
})

const emit = defineEmits(['update:modelValue', 'error', 'success'])

const supabase = useSupabase()
const preview = ref('')
const isDragging = ref(false)
const uploading = ref(false)
const uploadProgress = ref(0)
const error = ref('')
const fileInput = ref(null)

// Initialiser la prévisualisation si une valeur est déjà définie
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    preview.value = newValue
  } else {
    preview.value = ''
  }
}, { immediate: true })

const onDrop = (e) => {
  isDragging.value = false
  const files = e.dataTransfer.files
  if (files.length) {
    handleFile(files[0])
  }
}

const onFileSelected = (e) => {
  const files = e.target.files
  if (files.length) {
    handleFile(files[0])
  }
}

const handleFile = async (file) => {
  // Vérifier le type de fichier
  if (!file.type.match('image.*')) {
    error.value = 'Veuillez sélectionner une image'
    emit('error', 'Veuillez sélectionner une image')
    return
  }
  
  // Vérifier la taille du fichier
  if (file.size > props.maxSizeMB * 1024 * 1024) {
    error.value = `L'image ne doit pas dépasser ${props.maxSizeMB}MB`
    emit('error', `L'image ne doit pas dépasser ${props.maxSizeMB}MB`)
    return
  }
  
  error.value = ''
  
  // Créer une prévisualisation
  const reader = new FileReader()
  reader.onload = (e) => {
    preview.value = e.target.result
  }
  reader.readAsDataURL(file)
  
  // Télécharger le fichier
  await uploadFile(file)
}

const uploadFile = async (file) => {
  try {
    uploading.value = true
    uploadProgress.value = 0
    
    // Générer un nom de fichier unique
    const fileExt = file.name.split('.').pop()
    const fileName = `${props.folder}/${Date.now()}.${fileExt}`
    
    // Télécharger le fichier avec suivi de progression
    const { data, error: uploadError } = await supabase.storage
      .from(props.bucket)
      .upload(fileName, file, {
        cacheControl: '3600',
        upsert: true,
        onUploadProgress: (progress) => {
          uploadProgress.value = Math.round((progress.loaded / progress.total) * 100)
        }
      })
    
    if (uploadError) throw uploadError
    
    // Obtenir l'URL publique
    const { data: { publicUrl } } = supabase.storage
      .from(props.bucket)
      .getPublicUrl(fileName)
    
    // Mettre à jour la valeur
    emit('update:modelValue', publicUrl)
    emit('success', publicUrl)
    
  } catch (err) {
    console.error('Erreur de téléchargement:', err)
    error.value = 'Erreur lors du téléchargement de l\'image'
    emit('error', err.message || 'Erreur lors du téléchargement de l\'image')
    preview.value = props.modelValue // Restaurer la prévisualisation précédente
  } finally {
    uploading.value = false
    if (fileInput.value) {
      fileInput.value.value = '' // Réinitialiser l'input file
    }
  }
}

const removeImage = () => {
  preview.value = ''
  emit('update:modelValue', '')
}
</script> 