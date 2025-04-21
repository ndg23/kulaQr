<template>
    <div class="min-h-screen bg-white">
      <!-- Header with Logo -->
      <header class="fixed top-0 left-0 right-0 h-16 bg-white border-b border-gray-100 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center justify-between">
          <NuxtLink to="/" class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
              <img src="/logo.png" class="w-6 h-6 text-white" />
            </div>
            <span class="text-xl font-bold text-gray-900">KulaQr</span>
          </NuxtLink>
  
          <!-- Right Side Navigation -->
          <nav class="flex items-center space-x-6">
            <NuxtLink 
              to="/login" 
              class="text-sm font-medium text-gray-500 hover:text-gray-900"
            >
              Se connecter
            </NuxtLink>
            <NuxtLink 
              to="/register" 
              class="inline-flex h-9 px-4 items-center justify-center bg-black text-white rounded-full text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Créer un compte
            </NuxtLink>
          </nav>
        </div>
      </header>
  
      <!-- Main Content with Header Offset -->
      <main class="pt-16">
        <slot />
      </main>
    </div>
  </template>
  
  <script setup lang="ts">
  import { QrCode } from 'lucide-vue-next'
  </script>  