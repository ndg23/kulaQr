<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Vue d'ensemble</h1>
        <p class="text-gray-600">Tableau de bord</p>
      </div>
  
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div v-for="stat in stats" :key="stat.name" 
          class="bg-white p-6 rounded-3xl border border-gray-100 transition-all hover:scale-[1.02]"
        >
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" 
                class="w-6 h-6"
                :class="stat.iconColor" 
              />
            </div>
            <div>
              <p class="text-sm text-gray-500">{{ stat.name }}</p>
              <h3 class="text-2xl font-semibold text-gray-900 mt-1">{{ stat.value }}</h3>
            </div>
          </div>
        </div>
      </div>
  
      <!-- Main Content -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Orders -->
        <div class="bg-white rounded-3xl border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <h2 class="text-lg font-semibold text-gray-900">Commandes récentes</h2>
              </div>
            </div>
          </div>
  
          <div class="divide-y divide-gray-100">
            <div v-for="order in recentOrders" :key="order.id" 
              class="p-4 hover:bg-gray-50 transition-colors"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <Store class="w-5 h-5 text-gray-500" />
                  </div>
                  <div>
                    <div class="font-medium text-gray-900">{{ order.restaurant }}</div>
                    <div class="text-sm text-gray-500">{{ order.time }}</div>
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium text-gray-900">{{ order.amount }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Popular Restaurants -->
        <div class="bg-white rounded-3xl border border-gray-100 overflow-hidden">
          <div class="p-6 border-b border-gray-100">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <h2 class="text-lg font-semibold text-gray-900">Restaurants populaires</h2>
              </div>
            </div>
          </div>
  
          <div class="p-6">
            <div class="space-y-6">
              <div v-for="restaurant in popularRestaurants" :key="restaurant.id" 
                class="flex items-center justify-between"
              >
                <div class="flex items-center space-x-3">
                  <div class="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <Store class="w-6 h-6 text-gray-500" />
                  </div>
                  <div>
                    <div class="font-medium text-gray-900">{{ restaurant.name }}</div>
                    <div class="text-sm text-gray-500">{{ restaurant.orders }} commandes</div>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <Star class="w-4 h-4 text-yellow-400 fill-current" />
                  <span class="font-medium">{{ restaurant.rating }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import {
    Store, ShoppingBag, Star, Users, CreditCard
  } from 'lucide-vue-next'
  
  // Stats data
  const stats = [
    {
      name: 'Restaurants',
      value: '234',
      icon: Store,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    },
    {
      name: 'Clients',
      value: '1.4k',
      icon: Users,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    {
      name: 'Commandes',
      value: '12.5k',
      icon: ShoppingBag,
      iconBg: 'bg-purple-50',
      iconColor: 'text-purple-500'
    },
    {
      name: 'Revenu',
      value: '€45k',
      icon: CreditCard,
      iconBg: 'bg-orange-50',
      iconColor: 'text-orange-500'
    }
  ]
  
  // Recent orders
  const recentOrders = [
    {
      id: 1,
      restaurant: 'Le Bistrot Parisien',
      time: 'Il y a 5 minutes',
      amount: '€89.90'
    },
    {
      id: 2,
      restaurant: 'La Trattoria',
      time: 'Il y a 15 minutes',
      amount: '€124.50'
    },
    {
      id: 3,
      restaurant: 'Sushi Master',
      time: 'Il y a 45 minutes',
      amount: '€67.80'
    }
  ]
  
  // Popular restaurants
  const popularRestaurants = [
    {
      id: 1,
      name: 'Le Bistrot Parisien',
      orders: 1234,
      rating: 4.8
    },
    {
      id: 2,
      name: 'La Trattoria',
      orders: 987,
      rating: 4.7
    },
    {
      id: 3,
      name: 'Sushi Master',
      orders: 856,
      rating: 4.6
    }
  ]
  
  definePageMeta({
    layout: 'admin'
  })
  </script>