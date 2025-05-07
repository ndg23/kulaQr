<template>
    <TransitionRoot appear :show="modelValue" as="template">
      <Dialog as="div" @close="closeModal" class="relative z-50">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black/30" />
        </TransitionChild>
  
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel 
                class="w-full transform overflow-hidden rounded-3xl bg-white dark:bg-gray-900 p-8 border border-gray-100 dark:border-gray-800 shadow-xl transition-all"
                :class="size === 'lg' ? 'max-w-2xl' : size === 'xl' ? 'max-w-4xl' : 'max-w-md'"
              >
                <!-- Header -->
                <slot name="header">
                  <DialogTitle 
                    as="h3" 
                    class="text-xl font-semibold text-gray-900 dark:text-white flex justify-between items-center"
                  >
                    {{ title }}
                    <button 
                      @click="closeModal" 
                      class="text-gray-400 hover:text-gray-500 focus:outline-none"
                    >
                      <span class="sr-only">Fermer</span>
                      <i class="fas fa-times"></i>
                    </button>
                  </DialogTitle>
                </slot>
                
                <!-- Content -->
                <div class="mt-6">
                  <slot></slot>
                </div>
  
                <!-- Footer -->
                <slot name="footer">
                  <div class="mt-8 flex justify-end space-x-4">
                    <button
                      class="px-6 py-4 text-base font-semibold border border-gray-300 bg-white text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-2xl focus:outline-none focus:ring-2 focus:ring-gray-200 dark:focus:ring-gray-700 transition-all"
                      @click="closeModal"
                    >
                      Annuler
                    </button>
                    <button
                      class="px-6 py-4 text-base font-semibold border border-gray-300 bg-sky-600 text-white hover:bg-sky-700 rounded-2xl focus:outline-none focus:ring-2 focus:ring-gray-200 dark:focus:ring-gray-700 transition-all"
                      @click="handleAction"
                    >
                      {{ actionButtonText }}
                    </button>
                    <slot name="actions"></slot>
                  </div>
                </slot>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </template>
  
  <script setup lang="ts">
  import {
    Dialog,
    DialogPanel,
    DialogTitle,
    TransitionChild,
    TransitionRoot,
  } from '@headlessui/vue';
  
  const props = defineProps({
    modelValue: {
      type: Boolean,
      required: true,
    },
    title: {
      type: String,
      default: '',
    },
    actionButtonText: {
      type: String,
      default: 'Enregistrer',
    },
    size: {
      type: String,
      default: 'md',
      validator: (value: string) => ['sm', 'md', 'lg', 'xl'].includes(value),
    },
  });
  
  const emit = defineEmits(['update:modelValue', 'action']);
  
  const closeModal = () => {
    emit('update:modelValue', false);
  };
  
  const handleAction = () => {
    emit('action');
  };
  </script> 
  