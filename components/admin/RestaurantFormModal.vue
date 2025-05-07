<template>
  <UModal v-model="isOpen" size="lg" @action="handleSubmit" :actionButtonText="restaurant ? 'Mettre à jour' : 'Enregistrer'">
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
              label="Nom du restaurant"
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
            />
          </div>
          
          <div>
            <FloatLabelInput
              id="phone"
              v-model="form.phone"
              type="tel"
              label="Téléphone"
              :error="errors.phone"
            />
          </div>
          
          <div>
            <FloatLabelSelect
              id="type_id"
              v-model="form.type_id"
              label="Type d'établissement"
              :error="errors.type_id"
              required
            >
              <option v-for="type in establishmentTypes" :key="type.id" :value="type.id">
                {{ type.name }}
              </option>
            </FloatLabelSelect>
          </div>
          
          <div>
            <FloatLabelSelect
              id="owner_id"
              v-model="form.owner_id"
              label="Propriétaire"
              :error="errors.owner_id"
            >
              <option v-for="user in users" :key="user.id" :value="user.id">
                {{ user.full_name }}
              </option>
            </FloatLabelSelect>
          </div>
          
          <div>
            <FloatLabelSelect
              id="subscription_type"
              v-model="form.subscription_type"
              label="Type d'abonnement"
              :error="errors.subscription_type"
            >
              <option value="basic">Basique</option>
              <option value="premium">Premium</option>
              <option value="pro">Pro</option>
            </FloatLabelSelect>
          </div>
          
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
          
          <div>
            <FloatLabelInput
              id="currency"
              v-model="form.currency"
              type="text"
              label="Devise"
              :error="errors.currency"
            />
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
              id="qr_prefix"
              v-model="form.qr_prefix"
              type="text"
              label="Préfixe QR Code"
              :error="errors.qr_prefix"
            />
          </div>
          
          <div v-if="error" class="md:col-span-2 text-red-500">
            {{ error }}
          </div>
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
const users = ref([]);
const establishmentTypes = ref([]);

const errors = ref({
  name: '',
  address: '',
  phone: '',
  type_id: '',
  owner_id: '',
  is_active: '',
  subscription_type: '',
  currency: '',
  description: '',
  opening_hours: '',
  qr_prefix: ''
});

const isEdit = computed(() => !!props.restaurant);
const modalTitle = computed(() => isEdit.value ? 'Modifier le restaurant' : 'Ajouter un restaurant');

// Initialiser le formulaire avec des valeurs par défaut
const form = ref({
  name: '',
  slug: '',
  description: '',
  address: '',
  phone: '',
  opening_hours: '',
  user_id: '',
  owner_id: '',
  type_id: '',
  is_active: true,
  currency: 'XOF',
  subscription_type: 'basic',
  qr_prefix: ''
});

// Fonction pour réinitialiser le formulaire
const resetForm = () => {
  form.value = {
    name: '',
    slug: '',
    description: '',
    address: '',
    phone: '',
    opening_hours: '',
    user_id: '',
    owner_id: '',
    type_id: '',
    is_active: true,
    currency: 'XOF',
    subscription_type: 'basic',
    qr_prefix: ''
  };
  
  // Réinitialiser les erreurs
  errors.value = {
    name: '',
    address: '',
    phone: '',
    type_id: '',
    owner_id: '',
    is_active: '',
    subscription_type: '',
    currency: '',
    description: '',
    opening_hours: '',
    qr_prefix: ''
  };
};

// Observer les changements du restaurant sélectionné
watch(() => props.restaurant, (newRestaurant) => {
  if (newRestaurant) {
    form.value = {
      name: newRestaurant.name || '',
      slug: newRestaurant.slug || '',
      description: newRestaurant.description || '',
      address: newRestaurant.address || '',
      phone: newRestaurant.phone || '',
      opening_hours: newRestaurant.opening_hours || '',
      user_id: newRestaurant.user_id || '',
      owner_id: newRestaurant.owner_id || '',
      type_id: newRestaurant.type_id || '',
      is_active: typeof newRestaurant.is_active === 'boolean' ? newRestaurant.is_active : true,
      currency: newRestaurant.currency || 'XOF',
      subscription_type: newRestaurant.subscription_type || 'basic',
      qr_prefix: newRestaurant.qr_prefix || ''
    };
  } else {
    resetForm();
  }
}, { immediate: true });

// Fermer le modal
const closeModal = () => {
  emit('close');
};

// Charger les utilisateurs
const loadUsers = async () => {
  try {
    const { data, error: err } = await supabase
      .from('users')
      .select('id, full_name')
      .order('full_name');
    
    if (err) throw err;
    users.value = data || [];
  } catch (err) {
    console.error('Erreur lors du chargement des utilisateurs:', err);
  }
};

// Charger les types d'établissement
const loadEstablishmentTypes = async () => {
  try {
    const { data, error: err } = await supabase
      .from('establishment_types')
      .select('id, name')
      .order('name');
    
    if (err) throw err;
    establishmentTypes.value = data || [];
  } catch (err) {
    console.error('Erreur lors du chargement des types d\'établissement:', err);
  }
};

// Valider le formulaire
const validateForm = () => {
  let isValid = true;
  
  // Réinitialiser les erreurs
  errors.value = {
    name: '',
    address: '',
    phone: '',
    type_id: '',
    owner_id: '',
    is_active: '',
    subscription_type: '',
    currency: '',
    description: '',
    opening_hours: '',
    qr_prefix: ''
  };
  
  if (!form.value.name || !form.value.name.trim()) {
    errors.value.name = 'Le nom du restaurant est requis';
    isValid = false;
  }
  
  if (!form.value.type_id) {
    errors.value.type_id = 'Le type d\'établissement est requis';
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
    
    // Générer un slug si non fourni
    if (!form.value.slug) {
      form.value.slug = form.value.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '');
    }
    
    const restaurantData = {
      name: form.value.name,
      slug: form.value.slug,
      description: form.value.description,
      address: form.value.address,
      phone: form.value.phone,
      opening_hours: form.value.opening_hours,
      user_id: form.value.user_id,
      owner_id: form.value.owner_id,
      type_id: form.value.type_id,
      is_active: form.value.is_active,
      currency: form.value.currency,
      subscription_type: form.value.subscription_type,
      qr_prefix: form.value.qr_prefix
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
          details: { name: form.value.name, type: form.value.type_id }
        });
      }
      
      showToast.success('Restaurant créé avec succès', 'success');
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

// Charger les données nécessaires au chargement du composant
onMounted(() => {
  loadUsers();
  loadEstablishmentTypes();
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