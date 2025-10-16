<template>
  <div class="min-h-screen bg-[#FFFBFB] flex items-center justify-center">
    <!-- Back Button -->
    <div class="fixed top-0 w-full space-x-2- border-b border-gray-200 z-50 bg-white">
      <div class="flex items-center space-x-2 max-w-5xl mx-auto left-8 flex justify-between items-center">
        <NuxtLink 
        to="/" 
        class="inline-flex items-center text-slate-700 hover:text-slate-900 hover:bg-slate-100 rounded-full p-2 transition-colors"
      >
        <ArrowLeft class="w-5 h-5 mr-2" />
        <!-- <span class="text-lg font-medium">Retour</span> -->
      </NuxtLink>
     
        <NuxtLink to="/" class="flex items-center space-x-2">
          <img src="~/assets/icon/logo.png" alt="Logo" class="h-[50px] w-auto" />
        </NuxtLink>
      </div>
    </div>
    <!-- Main Content -->
    <div class="min-h-screen flex items-center justify-center px-6">
      <div class="w-full max-w-5xl">
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