<template>
    <div class="min-h-screen bg-gray-50">
      <!-- Sidebar -->
      <aside class="fixed inset-y-0 left-0 w-72 bg-white border-r border-gray-100">
        <!-- Logo -->
        <div class="h-16 flex items-center px-6 border-b border-gray-100">
          <NuxtLink to="/admin" class="flex items-center">
            <img src="~/assets/icon/logo.png" class="w-[100px] h-[100px]" alt="Logo" />
            <span class="text-xl font-logo ml-3 text-gray-900">Kula QR</span>
          </NuxtLink>
        </div>
  
        <!-- Navigation -->
        <nav class="p-3 space-y-1 mt-2">
          <NuxtLink
            v-for="item in navigationItems"
            :key="item.name"
            :to="item.to"
            :class="[
              isActive(item.to)
                ? 'bg-blue-50 text-blue-500'
                : 'text-gray-700 hover:bg-gray-50',
              'flex items-center px-5 py-3 text-lg font-medium rounded-full transition-colors'
            ]"
          >
            <component :is="item.icon" class="w-6 h-6 mr-4" />
            {{ item.name }}
          </NuxtLink>
        </nav>
  
        <!-- Tweet Button (Twitter-inspired action button) -->
        <div class="px-3 mt-4">
          <NuxtLink 
            to="/admin/restaurants/new" 
            class="flex items-center justify-center w-full py-3 bg-blue-500 hover:bg-blue-600 text-white font-bold rounded-full transition-colors"
          >
            <Plus class="w-5 h-5 mr-2" />
            Nouveau Restaurant
          </NuxtLink>
        </div>
  
        <!-- User Menu -->
        <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-100">
          <Menu as="div" class="relative">
            <MenuButton class="flex items-center w-full px-4 py-3 text-sm font-medium text-gray-700 rounded-full hover:bg-gray-50">
              <div class="flex items-center flex-1">
                <div class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                  <User class="w-5 h-5 text-gray-500" />
                </div>
                <div class="ml-3 text-left">
                  <p class="font-bold text-gray-900">Admin</p>
                  <p class="text-gray-500 text-sm">@admin</p>
                </div>
              </div>
              <MoreHorizontal class="w-5 h-5 text-gray-500" />
            </MenuButton>
  
            <transition
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <MenuItems class="absolute bottom-full left-0 right-0 mb-2 w-full origin-bottom-right rounded-2xl bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                <div class="py-1">
                  <MenuItem v-slot="{ active }">
                    <a
                      href="#"
                      :class="[
                        active ? 'bg-gray-50 text-gray-900' : 'text-gray-700',
                        'block px-4 py-3 text-sm'
                      ]"
                    >
                      <div class="flex items-center">
                        <Settings class="w-5 h-5 mr-3" />
                        Paramètres
                      </div>
                    </a>
                  </MenuItem>
                  <MenuItem v-slot="{ active }">
                    <button
                      @click="handleLogout"
                      :class="[
                        active ? 'bg-gray-50 text-red-600' : 'text-red-600',
                        'block w-full text-left px-4 py-3 text-sm'
                      ]"
                    >
                      <div class="flex items-center">
                        <LogOut class="w-5 h-5 mr-3" />
                        Se déconnecter
                      </div>
                    </button>
                  </MenuItem>
                </div>
              </MenuItems>
            </transition>
          </Menu>
        </div>
      </aside>
  
      <!-- Main Content -->
      <main class="ml-72 min-h-screen">
        <slot />
      </main>
    </div>
  </template>
  
  <script setup lang="ts">
  import {
    Menu,
    MenuButton,
    MenuItem,
    MenuItems
  } from '@headlessui/vue'
  import {
    LayoutDashboard,
    Store,
    Users,
    Settings,
    User,
    MoreHorizontal,
    LogOut,
    Plus
  } from 'lucide-vue-next'
  import { useToast } from '~/composables/useToast'
  
  const route = useRoute()
  const router = useRouter()
  const toast = useToast()
  
  const navigationItems = [
    {
      name: 'Vue d\'ensemble',
      to: '/admin',
      icon: LayoutDashboard
    },
    {
      name: 'Restaurants',
      to: '/admin/restaurants',
      icon: Store
    },
    {
      name: 'Utilisateurs',
      to: '/admin/users',
      icon: Users
    },
    {
      name: 'Paramètres',
      to: '/admin/settings',
      icon: Settings
    }
  ]
  
  const isActive = (path: string) => {
    return route.path === path || route.path.startsWith(`${path}/`)
  }
  
  const handleLogout = async () => {
    // Logique de déconnexion
    router.push('/auth/login')
    toast.success('Déconnexion réussie', 'À bientôt !')
  }
  </script>