<template>
  <UModal v-model="isOpen" size="lg" @action="handleSubmit" :actionButtonText="restaurant ? 'Mettre à jour' : 'Enregistrer'">
    <div class="mt-4 p-6">
      <h2 class="text-xl font-semibold mb-4">
        {{ modalTitle }}
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Nom du restaurant -->
        <div>
          <FloatLabelInput
            id="name"
            v-model="form.name"
            type="text"
            label="Nom du restaurant"
            :error="errors.name"
            required
          />
        </div>
        
        <!-- Adresse -->
        <div>
          <FloatLabelInput
            id="address"
            v-model="form.address"
            type="text"
            label="Adresse"
            :error="errors.address"
          />
        </div>
        
        <!-- Téléphone -->
        <div>
          <FloatLabelInput
            id="phone"
            v-model="form.phone"
            type="tel"
            label="Téléphone"
            :error="errors.phone"
          />
        </div>
        
        <!-- Statut -->
        <div>
          <FloatLabelSelect
            id="is_active"
            v-model="form.is_active"
            label="Statut"
            :error="errors.is_active"
          >
            <option :value="true">Actif</option>
            <option :value="false">Inactif</option>
          </FloatLabelSelect>
        </div>
        
        <!-- Message d'erreur -->
        <div v-if="error" class="text-red-500 text-sm">
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

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  restaurant: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['close', 'submit']);

const { client: supabase } = useSupabaseWrapper();
const { showToast } = useCustomToast();

const isOpen = ref(props.open);
const loading = ref(false);
const error = ref('');

const errors = ref({
  name: '',
  address: '',
  phone: '',
  is_active: ''
});

const isEdit = computed(() => !!props.restaurant);
const modalTitle = computed(() => isEdit.value ? 'Modifier le restaurant' : 'Ajouter un restaurant');

// Initialiser le formulaire avec des valeurs par défaut
const form = ref({
  name: '',
  address: '',
  phone: '',
  is_active: true
});

// Fonction pour réinitialiser le formulaire
const resetForm = () => {
  form.value = {
    name: '',
    address: '',
    phone: '',
    is_active: true
  };
  
  // Réinitialiser les erreurs
  errors.value = {
    name: '',
    address: '',
    phone: '',
    is_active: ''
  };
};

// Observer les changements du restaurant sélectionné
watch(() => props.restaurant, (newRestaurant) => {
  if (newRestaurant) {
    form.value = {
      name: newRestaurant.name || '',
      address: newRestaurant.address || '',
      phone: newRestaurant.phone || '',
      is_active: typeof newRestaurant.is_active === 'boolean' ? newRestaurant.is_active : true
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
    phone: '',
    is_active: ''
  };
  
  if (!form.value.name || !form.value.name.trim()) {
    errors.value.name = 'Le nom du restaurant est requis';
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
    
    const restaurantData = {
      name: form.value.name,
      address: form.value.address,
      phone: form.value.phone,
      is_active: form.value.is_active
    };
    
    if (isEdit.value && props.restaurant) {
      // Mise à jour d'un restaurant existant
      const { error: updateError } = await supabase
        .from('establishments')
        .update(restaurantData)
        .eq('id', props.restaurant.id);
      
      if (updateError) throw updateError;
      
      // Enregistrer l'activité
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from('activities').insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'establishment',
          entity_id: props.restaurant.id,
          details: { updated_fields: Object.keys(restaurantData) }
        });
      }
      
      showToast.success('Restaurant mis à jour avec succès', 'success');
    } else {
      // Création d'un nouveau restaurant
      const { data, error: insertError } = await supabase
        .from('establishments')
        .insert(restaurantData)
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
          details: { name: form.value.name }
        });
      }
      
      showToast.success('Restaurant créé avec succès', 'success');
    }
    
    emit('submit');
    closeModal();
  } catch (err) {
    console.error('Erreur lors de la soumission du formulaire:', err);
    error.value = (err as any)?.message || 'Une erreur est survenue';
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