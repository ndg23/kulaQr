<template>
    <div class="relative w-full">
      <!-- Input principal -->
      <input
        :id="id"
        :type="type"
        :value="modelValue"
        @input="handleInput"
        @focus="handleFocus"
        @blur="handleBlur"
        class="float-input block w-full pl-6 pr-4 h-16 pt-3  text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700 rounded-2xl focus:ring-none focus:ring-none-400 focus:border-primary-500 transition-colors text-lg dark:bg-gray-800"
        :class="[
          error ? 'border-red-500 focus:ring-none focus:ring-none-400' : 
                 (isFocused ? 'border-gray-900 dark:border-white' : ''),
          disabled ? 'bg-gray-50 dark:bg-gray-900 opacity-60 cursor-not-allowed' : '',
          pill ? ('!rounded-full !pl-7 ' + ($slots.trailing ? '!pr-16' : '!pr-7')) : '',
          iconLeft ? 'pl-12' : '',
          iconRight ? 'pr-12' : ''
        ]"
        :placeholder="' '"
        :disabled="disabled"
        :required="required"
        :min="min"
        :max="max"
        :step="step"
        :maxlength="maxlength"
        :pattern="pattern"
        :autocomplete="autocomplete"
        :aria-invalid="!!error"
        :aria-describedby="error ? `${id}-error` : undefined"
      />
      
      <!-- Label flottant : au repos il occupe le champ, au focus / à la saisie il se réduit et monte -->
      <label
        :for="id"
        :class="[
          'absolute pointer-events-none origin-left select-none whitespace-nowrap',
          'transition-all duration-200 ease-out',
          iconLeft ? 'left-12' : (pill ? 'left-7' : 'left-6'),
          (isFocused || hasValue)
            ? 'top-2.5 translate-y-0 scale-[0.72] text-gray-500 dark:text-gray-400'
            : 'top-8 -translate-y-1/2 scale-100 text-base text-gray-500 dark:text-gray-400',
          isFocused && !error ? '!text-gray-900 dark:!text-white' : '',
          error ? '!text-red-500' : ''
        ]"
      >
        {{ label }}
        <span v-if="required" class="text-red-500 ml-0.5">*</span>
      </label>
      
      <!-- Contenu à droite du champ (ex. afficher / masquer le mot de passe) -->
      <div v-if="$slots.trailing" class="absolute right-3 top-8 -translate-y-1/2 flex items-center">
        <slot name="trailing" />
      </div>

      <!-- Icône à gauche -->
      <div 
        v-if="iconLeft" 
        class="absolute left-4 top-1/2 -translate-y-1/2 flex items-center justify-center w-6 h-6"
        :class="[error ? 'text-red-500' : (isFocused ? 'text-blue-500' : 'text-gray-400')]"
      >
        <i :class="iconLeft"></i>
      </div>
      
      <!-- Icône à droite / Icône de validation -->
      <!-- <div 
        v-if="iconRight || (isValid && showValidIcon)" 
        class="absolute right-4 top-1/2 -translate-y-1/2 flex items-center justify-center w-6 h-6 transition-all duration-200"
      >
        <i 
          v-if="iconRight" 
          :class="[iconRight, error ? 'text-red-500' : (isFocused ? 'text-blue-500' : 'text-gray-400')]"
        ></i>
        <svg 
          v-else-if="isValid && showValidIcon" 
          class="w-5 h-5 text-green-500" 
          fill="none" 
          stroke="currentColor" 
          viewBox="0 0 24 24" 
          xmlns="http://www.w3.org/2000/svg"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
      </div> -->
      
      <!-- Compteur de caractères -->
      <div 
        v-if="maxlength && showCharCount" 
        class="absolute right-3 top-0 pt-0.5 text-xs text-gray-400 dark:text-gray-500"
        :class="{'text-red-500': isNearMaxLength}"
      >
        {{ currentLength }}/{{ maxlength }}
      </div>
      
      <!-- Animation de l'indicateur de focus (style Facebook) -->
      
      
      <!-- Message d'erreur -->
      <div v-if="error" :id="`${id}-error`" class="flex items-center mt-1.5 text-xs text-red-500">
        <svg class="w-3.5 h-3.5 mr-1.5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9a1 1 0 00-1-1z" clip-rule="evenodd"></path>
        </svg>
        {{ error }}
      </div>
      
      <!-- Texte d'aide -->
      <p v-else-if="helpText" class="mt-1.5 text-xs text-gray-500 dark:text-gray-400">
        {{ helpText }}
      </p>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue';
  
  const props = defineProps({
    id: {
      type: String,
      required: true
    },
    modelValue: {
      type: [String, Number],
      default: ''
    },
    label: {
      type: String,
      required: true
    },
    type: {
      type: String,
      default: 'text'
    },
    error: {
      type: String,
      default: ''
    },
    helpText: {
      type: String,
      default: ''
    },
    disabled: {
      type: Boolean,
      default: false
    },
    required: {
      type: Boolean,
      default: false
    },
    iconLeft: {
      type: String,
      default: ''
    },
    iconRight: {
      type: String,
      default: ''
    },
    min: {
      type: [String, Number],
      default: undefined
    },
    max: {
      type: [String, Number],
      default: undefined
    },
    step: {
      type: [String, Number],
      default: undefined
    },
    maxlength: {
      type: [String, Number],
      default: undefined
    },
    pattern: {
      type: String,
      default: undefined
    },
    autocomplete: {
      type: String,
      default: 'off'
    },
    showCharCount: {
      type: Boolean,
      default: true
    },
    showValidIcon: {
      type: Boolean,
      default: true
    },
    validationRules: {
      type: Function,
      default: null
    },
    // Champ en pilule (rounded-full), label flottant décalé en conséquence
    pill: {
      type: Boolean,
      default: false
    }
  });
  
  const emit = defineEmits(['update:modelValue', 'focus', 'blur', 'validation']);
  
  // États locaux
  const isFocused = ref(false);
  const focusIndicatorWidth = ref('0%');
  const isValid = ref(false);
  const hasBeenFocused = ref(false);
  
  // Valeurs calculées
  const hasValue = computed(() => {
    return props.modelValue !== null && 
           props.modelValue !== undefined && 
           props.modelValue.toString().trim() !== '';
  });
  
  const currentLength = computed(() => {
    return props.modelValue ? props.modelValue.toString().length : 0;
  });
  
  const isNearMaxLength = computed(() => {
    if (!props.maxlength) return false;
    const max = Number(props.maxlength);
    const current = currentLength.value;
    return current >= max * 0.9;
  });
  
  // Gestionnaires d'événements
  const handleInput = (e: Event) => {
    const target = e.target as HTMLInputElement;
    emit('update:modelValue', target.value);
    validateInput(target.value);
  };
  
  const handleFocus = () => {
    isFocused.value = true;
    hasBeenFocused.value = true;
    focusIndicatorWidth.value = '100%';
    emit('focus');
  };
  
  const handleBlur = () => {
    isFocused.value = false;
    focusIndicatorWidth.value = '0%';
    emit('blur');
    validateInput(props.modelValue);
  };
  
  // Validation
  const validateInput = (value: any) => {
    if (props.validationRules) {
      isValid.value = props.validationRules(value);
      emit('validation', isValid.value);
    } else if (props.required) {
      isValid.value = hasValue.value;
      emit('validation', isValid.value);
    } else {
      isValid.value = true;
      emit('validation', true);
    }
  };
  
  // Initialiser l'état basé sur la valeur initiale
  onMounted(() => {
    if (hasValue.value) {
      validateInput(props.modelValue);
    }
  });
  
  // Observer les changements de valeur externes
  watch(() => props.modelValue, (newValue) => {
    validateInput(newValue);
  });
  </script>
  
  <style scoped>
  /* Animations et transitions */
  @keyframes focusIndicator {
    from { width: 0; }
    to { width: 100%; }
  }
  
  /* Prévenir les styles d'auto-remplissage du navigateur */
  input:-webkit-autofill,
  input:-webkit-autofill:hover,
  input:-webkit-autofill:focus {
    transition: background-color 5000s ease-in-out 0s;
    -webkit-text-fill-color: inherit;
  }
  
  
  
  /* Valeur remplie par le navigateur : le label monte même si le modèle est encore vide */
  input:-webkit-autofill ~ label {
    top: 0.625rem !important;
    --tw-translate-y: 0px !important;
    --tw-scale-x: 0.72 !important;
    --tw-scale-y: 0.72 !important;
  }

  /* Transition douce pour les changements d'état */
  label, input, .absolute {
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  }
  </style>