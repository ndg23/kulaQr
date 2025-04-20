<template>
  <div class="bg-white">
    <div class="relative">
      <img
        :src="data?.imageUrl || 'https://via.placeholder.com/800x300'"
        :alt="data?.name"
        class="w-full h-48 object-cover"
      />
    </div>
    <div class="px-6 py-6">
      <h1 class="text-3xl font-bold text-gray-900 mb-2 font-mono">{{ data?.name || "Restaurant Name" }}</h1>
      <div class="flex flex-wrap items-center text-sm text-gray-500 font-mono space-x-4">
        <div class="flex items-center">
          <Icon name="star" class="w-4 h-4 text-gray-400 mr-1" />
          <span>{{ data?.rating || "4.5" }}</span>
          <span class="ml-1 opacity-75">({{ data?.reviewCount || "500+" }})</span>
        </div>
        <div class="flex items-center">
          <Icon name="clock" class="w-4 h-4 mr-1" />
          <span>{{ data?.openingHours || "Open until 10 PM" }}</span>
        </div>
        <div class="flex items-center">
          <Icon name="map-pin" class="w-4 h-4 mr-1" />
          <span>{{ data?.address || "123 Main St, City" }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { EstablishmentData } from '~/types'

defineProps<{
  data: EstablishmentData
}>()
</script> 