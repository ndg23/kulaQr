<template>
  <div class="bg-white rounded-2xl overflow-hidden">
    <div class="p-6 border-b border-gray-100">
      <h2 class="text-lg font-semibold text-gray-900">
        {{ category ? 'Modifier la catégorie' : 'Nouvelle catégorie' }}
      </h2>
    </div>
    
    <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
      <!-- Category Image -->
      <div class="space-y-2">
        <label class="block text-sm font-medium text-gray-700">Image</label>
        <div class="flex items-center space-x-4">
          <div class="relative h-24 w-24 rounded-xl bg-gray-50 border-2 border-gray-100 overflow-hidden">
            <img
              v-if="imagePreview || form.image_url"
              :src="imagePreview || form.image_url"
              class="h-full w-full object-cover"
              alt="Category preview"
            />
            <div v-else class="flex h-full items-center justify-center">
              <ImageIcon class="h-8 w-8 text-gray-300" />
            </div>
            
            <!-- Remove image button -->
            <button 
              v-if="imagePreview || form.image_url"
              type="button"
              @click="removeImage"
              class="absolute top-1 right-1 p-1 bg-white rounded-full shadow-sm hover:bg-gray-100"
            >
              <X class="w-3.5 h-3.5 text-gray-500" />
            </button>
          </div>
          
          <div>
            <button
              type="button"
              @click="triggerFileInput"
              class="inline-flex items-center px-3 py-1.5 text-sm font-medium rounded-lg border border-gray-300 bg-white hover:bg-gray-50 text-gray-700"
            >
              <Upload class="w-4 h-4 mr-1.5" />
              Choisir une image
            </button>
            <p class="mt-1 text-xs text-gray-500">JPG, PNG ou GIF. 2MB max.</p>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="handleFileChange"
            />
          </div>
        </div>
      </div>
      
      <!-- Category Name -->
      <div class="relative group mb-4">
        <FormInput
          v-model="form.name"
          type="text"
          required
          label="Nom de la catégorie"
          placeholder="Plat, Dessert, Boisson..."
        />
      </div>
      
      <!-- Order Number -->
      <div class="relative group">
        <FormInput
          v-model.number="form.order_number"
          type="number"
          step="1"
          min="1"
          placeholder="1, 2, 3..."
          label="Ordre d'affichage"
        />
      </div>
      
      <!-- Actions -->
      <div class="flex justify-end space-x-3 pt-4">
        <button
          type="button"
          @click="$emit('close')"
          class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
        >
          Annuler
        </button>
        <button
          type="submit"
          class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
          :disabled="loading"
        >
          <span v-if="loading" class="flex items-center">
            <Loader2 class="w-4 h-4 animate-spin mr-2" />
            Enregistrement...
          </span>
          <span v-else>
            {{ category ? 'Mettre à jour' : 'Créer' }}
          </span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { 
  Upload, ImageIcon, X, Loader2, UtensilsCrossed
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import FormInput from '~/components/ui/FormInput.vue'
const props = defineProps({
  category: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'submit'])
const { client: supabase } = useSupabaseWrapper()
const {showToast} = useCustomToast()
const fileInput = ref(null)
const imagePreview = ref('')
const loading = ref(false)

// Form state
const form = reactive({
  name: '',
  order_number: 1,
  image_url: '',
  image_file: null
})

// Initialize form with category data if editing
onMounted(() => {
  initializeForm()
})

// Watch for category changes
watch(() => props.category, () => {
  initializeForm()
}, { deep: true })

// Initialize form data
const initializeForm = () => {
  if (props.category) {
    form.name = props.category.name || ''
    form.order_number = props.category.order_number || 1
    form.image_url = props.category.image_url || ''
  } else {
    // Default values for new category
    form.name = ''
    form.order_number = 1
    form.image_url = ''
    form.image_file = null
    imagePreview.value = ''
  }
}

// Trigger file input click
const triggerFileInput = () => {
  if (fileInput.value) {
    fileInput.value.click()
  }
}

// Handle file selection
const handleFileChange = (event) => {
  const file = event.target.files[0]
  if (!file) return
  
  // Check file size (2MB max)
  if (file.size > 2 * 1024 * 1024) {
    showToast.error('Erreur', 'L\'image est trop volumineuse. Veuillez choisir une image de moins de 2MB.')
    return
  }
  
  form.image_file = file
  
  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target.result
  }
  reader.readAsDataURL(file)
}

// Remove image
const removeImage = () => {
  form.image_file = null
  form.image_url = ''
  imagePreview.value = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Upload image to storage
const uploadImage = async () => {
  if (!form.image_file) return form.image_url
  
  try {
    const fileExt = form.image_file.name.split('.').pop()
    const fileName = `${Math.random().toString(36).substring(2, 15)}.${fileExt}`
    const filePath = `categories/${fileName}`
    
    const { error: uploadError } = await supabase.storage
      .from('images')
      .upload(filePath, form.image_file)
    
    if (uploadError) throw uploadError
    
    const { data } = supabase.storage
      .from('images')
      .getPublicUrl(filePath)
    
    return data.publicUrl
  } catch (error) {
    console.error('Error uploading image:', error)
    showToast.error('Erreur', 'Impossible de télécharger l\'image')
    throw error
  }
}

// Handle form submission
const handleSubmit = async () => {
  if (!form.name.trim()) {
    showToast.error('Erreur', 'Veuillez entrer un nom de catégorie')
    return
  }
  
  loading.value = true
  
  try {
    // Upload image if there's a new one
    let imageUrl = form.image_url
    if (form.image_file) {
      imageUrl = await uploadImage()
    }
    
    // Prepare data for submission
    const categoryData = {
      name: form.name,
      order_number: form.order_number || 1,
      image_url: imageUrl,
      icon: 'default' // Keep a default icon for backward compatibility
    }
    
    // Send data to parent component
    emit('submit', categoryData)
  } catch (error) {
    console.error('Error submitting category:', error)
    showToast.error('Erreur', 'Une erreur est survenue lors de la sauvegarde')
    loading.value = false
  }
}
</script>

<style scoped>
.backdrop-blur-sm {
  backdrop-filter: blur(8px);
}
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}
.peer:placeholder-shown ~ label {
  cursor: text;
  top: 50%;
  transform: translateY(-50%);
}

.peer:focus ~ label {
  top: 0.5rem;
  transform: translateY(0);
  font-size: 0.875rem;
}

.peer:-webkit-autofill {
  -webkit-background-clip: text;
}

/* Animation du loader */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style> 