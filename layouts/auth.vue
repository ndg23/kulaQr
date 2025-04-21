<template>
  <div class="min-h-screen bg-white">
    <!-- Back Button -->
    <div class="fixed top-8 left-8">
      <NuxtLink 
        to="/" 
        class="inline-flex items-center text-gray-500 hover:text-gray-900 transition-colors"
      >
        <ArrowLeft class="w-5 h-5 mr-2" />
        <span class="text-sm font-medium">Retour</span>
      </NuxtLink>
    </div>

    <!-- Main Content -->
    <div class="min-h-screen flex items-center justify-center px-6">
      <div class="w-full max-w-[400px] py-12">
        <!-- Logo -->
        <!-- <div class="mb-16 text-center">
          <NuxtLink to="/" class="inline-flex items-center space-x-3">
            <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center">
              <QrCode class="w-7 h-7 text-white" />
            </div>
          </NuxtLink>
        </div> -->

        <!-- Page Content -->
        <slot />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { QrCode, ArrowLeft } from 'lucide-vue-next'
</script> 