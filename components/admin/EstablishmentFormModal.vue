<template>
  <UModal v-model="isOpen" size="lg" @action="handleSubmit" :actionButtonText="establishment ? 'Mettre à jour' : 'Enregistrer'">
    <div class="mt-4 p-6">
      <h2 class="text-xl font-semibold mb-4">
        {{ modalTitle }}
      </h2>

      <form @submit.prevent="handleSubmit">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <FloatLabelInput
              id="name"
              v-model="form.name"
              type="text"
              label="Nom de l'établissement"
              :error="errors.name"
              required
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="address"
              v-model="form.address"
              type="text"
              label="Adresse"
              :error="errors.address"
              required
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="city"
              v-model="form.city"
              type="text"
              label="Ville"
              :error="errors.city"
              required
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="postal_code"
              v-model="form.postal_code"
              type="text"
              label="Code postal"
              :error="errors.postal_code"
              required
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="phone"
              v-model="form.phone"
              type="tel"
              label="Téléphone"
              :error="errors.phone"
              required
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="email"
              v-model="form.email"
              type="email"
              label="Email"
              :error="errors.email"
              required
            />
          </div>
          
          <div>
            <FloatLabelSelect
              id="type"
              v-model="form.type"
              label="Type d'établissement"
              :error="errors.type"
              required
            >
              <option value="restaurant">Restaurant</option>
              <option value="cafe">Café</option>
              <option value="bar">Bar</option>
              <option value="hotel">Hôtel</option>
              <option value="other">Autre</option>
            </FloatLabelSelect>
          </div>
          
          <div>
            <FloatLabelSelect
              id="status"
              v-model="form.status"
              label="Statut"
              :error="errors.status"
              required
            >
              <option value="active">Actif</option>
              <option value="inactive">Inactif</option>
              <option value="pending">En attente</option>
            </FloatLabelSelect>
          </div>
          
          <div class="md:col-span-2">
            <FloatLabelInput
              id="description"
              v-model="form.description"
              type="textarea"
              label="Description"
              :error="errors.description"
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="opening_hours"
              v-model="form.opening_hours"
              type="text"
              label="Heures d'ouverture"
              :error="errors.opening_hours"
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="website"
              v-model="form.website"
              type="url"
              label="Site web"
              :error="errors.website"
            />
          </div>
        </div>
        
        <div v-if="error" class="mt-4 text-red-500">
          {{ error }}
        </div>
      </form>
    </div>
  </UModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useSupabaseWrapper } from '~/composables/useSupabase';
import { useCustomToast } from '~/composables/useToast';
import FloatLabelInput from '~/components/FloatLabelInput.vue';
import FloatLabelSelect from '~/components/FloatLabelSelect.vue';
import UModal from '~/components/UModal.vue';
import { Loader2 } from 'lucide-vue-next';

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  establishment: {
    type: Object,
    default: null
  },
  size: {
    type: String,
    default: 'lg'
  }
});

const isOpen = ref(props.open);

const emit = defineEmits(['close', 'submit']);

const { client: supabase } = useSupabaseWrapper();
const { showToast } = useCustomToast();

const loading = ref(false);
const error = ref('');
const errors = ref({
  name: '',
  address: '',
  city: '',
  postal_code: '',
  phone: '',
  email: '',
  type: '',
  status: '',
  description: '',
  opening_hours: '',
  website: ''
});

const isEdit = computed(() => !!props.establishment);
const modalTitle = computed(() => isEdit.value ? 'Modifier l\'établissement' : 'Ajouter un établissement');

// Initialiser le formulaire avec des valeurs par défaut
const form = ref({
  name: '',
  address: '',
  city: '',
  postal_code: '',
  phone: '',
  email: '',
  type: 'restaurant',
  status: 'active',
  description: '',
  opening_hours: '',
  website: ''
});

// Fonction pour réinitialiser le formulaire
const resetForm = () => {
  form.value = {
    name: '',
    address: '',
    city: '',
    postal_code: '',
    phone: '',
    email: '',
    type: 'restaurant',
    status: 'active',
    description: '',
    opening_hours: '',
    website: ''
  };
  
  // Réinitialiser les erreurs
  errors.value = {
    name: '',
    address: '',
    city: '',
    postal_code: '',
    phone: '',
    email: '',
    type: '',
    status: '',
    description: '',
    opening_hours: '',
    website: ''
  };
};

// Observer les changements de l'établissement sélectionné
watch(() => props.establishment, (newEstablishment) => {
  if (newEstablishment) {
    form.value = {
      name: newEstablishment.name || '',
      address: newEstablishment.address || '',
      city: newEstablishment.city || '',
      postal_code: newEstablishment.postal_code || '',
      phone: newEstablishment.phone || '',
      email: newEstablishment.email || '',
      type: newEstablishment.type || 'restaurant',
      status: newEstablishment.status || 'active',
      description: newEstablishment.description || '',
      opening_hours: newEstablishment.opening_hours || '',
      website: newEstablishment.website || ''
    };
  } else {
    resetForm();
  }
}, { immediate: true });

// Fermer le modal
const closeModal = () => {
  emit('close');
};

// Valider le formulaire
const validateForm = () => {
  let isValid = true;
  
  // Réinitialiser les erreurs
  errors.value = {
    name: '',
    address: '',
    city: '',
    postal_code: '',
    phone: '',
    email: '',
    type: '',
    status: '',
    description: '',
    opening_hours: '',
    website: ''
  };
  
  if (!form.value.name || !form.value.name.trim()) {
    errors.value.name = 'Le nom est requis';
    isValid = false;
  }

  if (!form.value.address || !form.value.address.trim()) {
    errors.value.address = 'L\'adresse est requise';
    isValid = false;
  }

  if (!form.value.city || !form.value.city.trim()) {
    errors.value.city = 'La ville est requise';
    isValid = false;
  }

  if (!form.value.postal_code || !form.value.postal_code.trim()) {
    errors.value.postal_code = 'Le code postal est requis';
    isValid = false;
  }

  if (!form.value.phone || !form.value.phone.trim()) {
    errors.value.phone = 'Le téléphone est requis';
    isValid = false;
  } else if (!/^\+?[0-9]{8,}$/.test(form.value.phone)) {
    errors.value.phone = 'Format de téléphone invalide';
    isValid = false;
  }

  if (!form.value.email || !form.value.email.trim()) {
    errors.value.email = 'L\'email est requis';
    isValid = false;
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
    errors.value.email = 'Format d\'email invalide';
    isValid = false;
  }

  if (!form.value.type) {
    errors.value.type = 'Le type d\'établissement est requis';
    isValid = false;
  }

  if (!form.value.status) {
    errors.value.status = 'Le statut est requis';
    isValid = false;
  }
  
  if (form.value.website && !/^https?:\/\//.test(form.value.website)) {
    errors.value.website = 'L\'URL doit commencer par http:// ou https://';
    isValid = false;
  }
  
  return isValid;
};

// Gérer la soumission du formulaire
const handleSubmit = async () => {
  if (!validateForm()) return;

  try {
    loading.value = true;
    error.value = '';
    
    const establishmentData = {
      name: form.value.name,
      address: form.value.address,
      city: form.value.city,
      postal_code: form.value.postal_code,
      phone: form.value.phone,
      email: form.value.email,
      type: form.value.type,
      status: form.value.status,
      description: form.value.description,
      opening_hours: form.value.opening_hours,
      website: form.value.website
    };
    
    if (isEdit.value && props.establishment) {
      // Mise à jour d'un établissement existant
      const { error: updateError } = await supabase
        .from('establishments')
        .update(establishmentData)
        .eq('id', props.establishment.id);
      
      if (updateError) throw updateError;
      
      // Enregistrer l'activité
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from('activities').insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'establishment',
          entity_id: props.establishment.id,
          details: { updated_fields: Object.keys(establishmentData) }
        });
      }
      
      showToast.success('Établissement mis à jour avec succès', 'success');
    } else {
      // Création d'un nouvel établissement
      const { data, error: insertError } = await supabase
        .from('establishments')
        .insert(establishmentData)
        .select();
      
      if (insertError) throw insertError;
      
      // Enregistrer l'activité
      const { data: { user } } = await supabase.auth.getUser();
      if (user && data && data[0]) {
        await supabase.from('activities').insert({
          user_id: user.id,
          action_type: 'create',
          entity_type: 'establishment',
          entity_id: data[0].id,
          details: { name: form.value.name, type: form.value.type }
        });
      }
      
      showToast.success('Établissement créé avec succès', 'success');
    }
    
    emit('submit');
    closeModal();
  } catch (err) {
    console.error('Erreur lors de la soumission du formulaire:', err);
    error.value = err.message || 'Une erreur est survenue';
    showToast.error(error.value, 'error');
  } finally {
    loading.value = false;
  }
};

// Surveiller les changements de la prop open
watch(() => props.open, (newValue) => {
  isOpen.value = newValue;
});

// Émettre l'événement close lorsque isOpen change
watch(() => isOpen.value, (newValue) => {
  if (!newValue) {
    emit('close');
  }
});
</script>

<style scoped>
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  font-weight: 500;
  border-radius: 0.375rem;
  transition: all 0.15s ease-in-out;
  cursor: pointer;
}

.btn-secondary {
  background-color: #f3f4f6;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background-color: #e5e7eb;
}

.btn-primary {
  background-color: #3b82f6;
  color: white;
  border: 1px solid transparent;
}

.btn-primary:hover {
  background-color: #2563eb;
}

.btn-primary:disabled {
  background-color: #93c5fd;
  cursor: not-allowed;
}
</style> 