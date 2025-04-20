<template>
  <div class="bg-white border-b">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <div class="flex items-center">
          <h1 class="text-xl font-medium">{{ establishment?.name }}</h1>
        </div>
        <nav class="flex items-center space-x-8">
          <NuxtLink 
            v-for="item in navItems" 
            :key="item.path"
            :to="item.path"
            class="text-gray-500 hover:text-gray-900"
            :class="{ 'text-blue-600': isCurrentPath(item.path) }"
          >
            {{ item.name }}
          </NuxtLink>
        </nav>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const slug = route.params.slug as string

const navItems = [
  { name: 'Menu', path: `/manager/${slug}` },
  { name: 'Produits', path: `/manager/${slug}/products` },
  { name: 'Catégories', path: `/manager/${slug}/categories` },
  { name: 'QR Codes', path: `/manager/${slug}/qr-codes` }
]

const isCurrentPath = (path: string) => route.path === path
</script> 