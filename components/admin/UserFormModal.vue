<template>
  <UModal v-model="isOpen" size="lg" @action="handleSubmit" :actionButtonText="user ? 'Mettre à jour' : 'Enregistrer'">

              
              <div class="mt-4 p-6">
                <h2 class="text-xl font-semibold mb-4">

                  {{ modalTitle }}</h2>

                <form @submit.prevent="handleSubmit">
                  <div class="grid grid-cols-1  gap-6">
                    <div>
                      <FloatLabelInput
                        id="fullName"
                        v-model="form.full_name"
                        type="text"
                        label="Nom complet"
                        :error="errors.full_name"
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
                    
                    <div v-if="!isEdit">
                      <FloatLabelInput
                        id="password"
                        v-model="form.password" 
                        label="Mot de passe"
                        type="password"
                        :error="errors.password"
                        required
                      />
                    </div>
                    
                    <div>
                      <FloatLabelSelect
                        id="role"
                        v-model="form.role"
                        label="Rôle"
                        :error="errors.role"
                        required
                      >
                        <option value="admin">Administrateur</option>
                        <option value="manager">Manager</option>
                        <option value="user">Utilisateur</option>
                      </FloatLabelSelect>
                    </div>
                    
                    <div>
                      <FloatLabelSelect
                        id="subscription_tier"
                        v-model="form.subscription_tier"
                        label="Abonnement"
                        :error="errors.subscription_tier"
                        required
                      >
                        <option value="free">Gratuit</option>
                        <option value="premium">Premium</option>
                        <option value="pro">Pro</option>
                      </FloatLabelSelect>
                    </div>
                    
                    <div>
                      <FloatLabelSelect
                        id="is_active"
                        v-model="form.status"
                        label="Statut"
                        :error="errors.is_active"
                        required
                      >
                        <option value="active">Actif</option>
                        <option value="inactive">Inactif</option>
                      </FloatLabelSelect>
                    </div>
                    
                    <div v-if="form.subscription_tier !== 'free'">
                      <FloatLabelInput
                        id="subscription_ends_at"
                        v-model="form.subscription_ends_at"
                        type="date"
                        label="Fin d'abonnement"
                      />
                    </div>
                  </div>
                  
                  <div v-if="error" class="mt-4 text-red-500">
                    {{ error }}
                  </div>
                  
                  <!-- <div class="mt-6 flex justify-end space-x-3">
                    <button 
                      type="button" 
                      class="btn btn-secondary"
                      @click="closeModal"
                    >
                      Annuler
                    </button>
                    <button 
                      type="submit" 
                      class="btn btn-primary"
                      :disabled="loading"
                    >
                      <span v-if="loading" class="flex items-center">
                        <Loader2 class="w-4 h-4 animate-spin mr-2" />
                        Chargement...
                      </span>
                      <span v-else>
                        {{ isEdit ? 'Mettre à jour' : 'Ajouter' }}
                      </span>
                    </button>
                  </div> -->
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
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionChild,
  TransitionRoot,
} from '@headlessui/vue';

const props = defineProps({
  open: {
    type: Boolean,
    required: true
  },
  user: {
    type: Object,
    default: null
  },
  size: {
    type: String,
    default: 'lg'
  }
});
const isOpen = computed({
  get: () => props.open,
  set: (value) => {
    if (!value) {
      emit('close');
    }
  }
});


const emit = defineEmits(['close', 'submit']);

const { client: supabase } = useSupabaseWrapper();
const { showToast } = useCustomToast();

const loading = ref(false);
const error = ref('');
const errors = ref({
  full_name: '',
  email: '',
  password: '',
  role: '',
  is_active: '',
  subscription_tier: ''
});

const isEdit = computed(() => !!props.user);
const modalTitle = computed(() => isEdit.value ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur');

// Initialiser le formulaire avec des valeurs par défaut
const form = ref({
  full_name: '',
  email: '',
  password: '',
  role: 'user',
  status: 'active', // Changé de is_active à status
  subscription_tier: 'free',
  subscription_ends_at: ''
});

// Fonction pour formater une date pour un input de type date
const formatDateForInput = (date) => {
  if (!date) return '';
  const d = new Date(date);
  return d.toISOString().split('T')[0];
};

// Fonction pour réinitialiser le formulaire
const resetForm = () => {
  form.value = {
    full_name: '',
    email: '',
    password: '',
    role: 'user',
      status: 'active',
    subscription_tier: 'free',
    subscription_ends_at: ''
  };
  
  // Réinitialiser les erreurs
  errors.value = {
    full_name: '',
    email: '',
    password: '',
    role: '',
    is_active: '',
    subscription_tier: ''
  };
};

// Observer les changements de l'utilisateur sélectionné
watch([() => props.user, () => props.open], ([newUser, isOpened]) => {
  console.log('Modal watch triggered:', { newUser, isOpened });
  if (isOpened) {
    if (newUser) {
      form.value = {
        full_name: newUser.full_name || '',
        email: newUser.email || '',
        password: '',
        role: newUser.role || 'user',
        status: newUser.is_active ? 'active' : 'inactive',
        subscription_tier: newUser.subscription_tier || 'free',
        subscription_ends_at: newUser.subscription_ends_at ? formatDateForInput(newUser.subscription_ends_at) : ''
      };
    } else {
      resetForm();
    }
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
    full_name: '',
    email: '',
    password: '',
    role: '',
    is_active: '',
    subscription_tier: ''
  };
  
  if (!form.value.full_name || !form.value.full_name.trim()) {
    errors.value.full_name = 'Le nom complet est requis';
    isValid = false;
  }

  if (!form.value.email || !form.value.email.trim()) {
    errors.value.email = 'L\'email est requis';
    isValid = false;
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
    errors.value.email = 'Format d\'email invalide';
    isValid = false;
  }

  if (!isEdit.value && (!form.value.password || form.value.password.length < 8)) {
    errors.value.password = 'Le mot de passe doit contenir au moins 8 caractères';
    isValid = false;
  }

  if (!form.value.role) {
    errors.value.role = 'Le rôle est requis';
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
    
    const userData = {
      full_name: form.value.full_name,
      email: form.value.email,
      role: form.value.role,
      is_active: form.value.status === 'active',
      subscription_tier: form.value.subscription_tier,
      subscription_ends_at: form.value.subscription_ends_at ? new Date(form.value.subscription_ends_at).toISOString() : null
    };
    
    if (isEdit.value && props.user) {
      // Mise à jour d'un utilisateur existant
      const { error: updateError } = await supabase
        .from('users')
        .update(userData)
        .eq('id', props.user.id);
      
      if (updateError) throw updateError;
      
      // Si l'email a changé, mettre à jour via l'API
      if (props.user.email !== form.value.email) {
        const { error: emailUpdateError } = await useFetch('/api/admin/update-user-email', {
          method: 'POST',
          body: {
            userId: props.user.id,
            newEmail: form.value.email
          }
        });
        
        if (emailUpdateError) {
          throw new Error('Impossible de mettre à jour l\'email. Veuillez réessayer.');
        }
      }
      
      // Enregistrer l'activité
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from('activities').insert({
          user_id: user.id,
          action_type: 'update',
          entity_type: 'user',
          entity_id: props.user.id,
          details: { updated_fields: Object.keys(userData) }
        });
      }
      
      showToast.success('Utilisateur mis à jour avec succès', 'success');
    } else {
      // Création d'un nouvel utilisateur
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: form.value.email,
        password: form.value.password,
        options: {
          data: {
            full_name: form.value.full_name,
            role: form.value.role
          }
        }
      });
      
      if (authError) throw authError;
      
      // Compléter les données utilisateur dans la table users
      const { error: insertError } = await supabase
        .from('users')
        .insert({
          id: authData.user.id,
          ...userData
        });
      
      if (insertError) throw insertError;
      
      // Enregistrer l'activité
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from('activities').insert({
          user_id: user.id,
          action_type: 'create',
          entity_type: 'user',
          entity_id: authData.user.id,
          details: { email: form.value.email, role: form.value.role }
        });
      }
      
      showToast.success('Utilisateur créé avec succès', 'success');
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