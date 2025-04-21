<template>
  <div class="min-h-screen bg-[#F8FAFC]">
    <!-- Header -->
    <header class="sticky top-0 z-30 bg-white border-b border-gray-100">
      <div class="max-w-7xl mx-auto">
        <div class="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
          <!-- Left side -->
          <div class="flex items-center">
            <NuxtLink to="/" class="flex items-center">
              <span class="text-2xl font-logo">Kula QR</span>
            </NuxtLink>
          </div>

          <!-- Navigation -->
          <nav class="hidden md:flex items-center space-x-1">
            <NuxtLink
              v-for="item in navigationItems"
              :key="item.name"
              :to="item.to"
              :class="[
                isActive(item.to)
                  ? 'bg-gray-50 text-gray-900'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900',
                'px-3 py-2 rounded-lg text-sm font-medium transition-colors duration-200'
              ]"
            >
              <div class="flex items-center space-x-2">
                <component :is="item.icon" class="w-4 h-4" />
                <span>{{ item.name }}</span>
              </div>
            </NuxtLink>
          </nav>

          <!-- Right side -->
          <div class="flex items-center space-x-4">
            <!-- Notifications -->
            <Menu as="div" class="relative">
              <MenuButton class="relative p-2 rounded-full hover:bg-gray-50">
                <span class="sr-only">Notifications</span>
                <Bell class="w-5 h-5 text-gray-600" />
                <span class="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-400 ring-2 ring-white" />
              </MenuButton>
              <transition
                enter-active-class="transition ease-out duration-100"
                enter-from-class="transform opacity-0 scale-95"
                enter-to-class="transform opacity-100 scale-100"
                leave-active-class="transition ease-in duration-75"
                leave-from-class="transform opacity-100 scale-100"
                leave-to-class="transform opacity-0 scale-95"
              >
                <MenuItems class="absolute right-0 mt-2 w-80 origin-top-right rounded-xl bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  <div class="px-4 py-2 border-b border-gray-100">
                    <h3 class="text-sm font-semibold text-gray-900">Notifications</h3>
                  </div>
                  <div class="max-h-96 overflow-y-auto">
                    <MenuItem v-slot="{ active }">
                      <a
                        href="#"
                        :class="[
                          active ? 'bg-gray-50' : '',
                          'block px-4 py-3'
                        ]"
                      >
                        <div class="flex items-start">
                          <div class="flex-shrink-0">
                            <span class="inline-flex h-8 w-8 items-center justify-center rounded-full bg-blue-50">
                              <ShoppingCart class="h-4 w-4 text-blue-500" />
                            </span>
                          </div>
                          <div class="ml-3 w-0 flex-1">
                            <p class="text-sm font-medium text-gray-900">Nouvelle commande</p>
                            <p class="mt-1 text-sm text-gray-500">Table 4 - 3 articles</p>
                            <p class="mt-1 text-xs text-gray-400">Il y a 2 minutes</p>
                          </div>
                        </div>
                      </a>
                    </MenuItem>
                  </div>
                </MenuItems>
              </transition>
            </Menu>

            <!-- Profile dropdown -->
            <Menu as="div" class="relative">
              <MenuButton class="flex items-center space-x-3">
                <img
                  src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix"
                  alt="Avatar"
                  class="h-8 w-8 rounded-full"
                />
                <ChevronDown class="w-4 h-4 text-gray-600" />
              </MenuButton>
              <transition
                enter-active-class="transition ease-out duration-100"
                enter-from-class="transform opacity-0 scale-95"
                enter-to-class="transform opacity-100 scale-100"
                leave-active-class="transition ease-in duration-75"
                leave-from-class="transform opacity-100 scale-100"
                leave-to-class="transform opacity-0 scale-95"
              >
                <MenuItems class="absolute right-0 mt-2 w-48 origin-top-right rounded-xl bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  <MenuItem v-slot="{ active }">
                    <a
                      href="#"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'block px-4 py-2 text-sm text-gray-700'
                      ]"
                    >
                      <div class="flex items-center">
                        <User class="w-4 h-4 mr-2" />
                        Mon profil
                      </div>
                    </a>
                  </MenuItem>
                  <MenuItem v-slot="{ active }">
                    <a
                      href="#"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'block px-4 py-2 text-sm text-gray-700'
                      ]"
                    >
                      <div class="flex items-center">
                        <Settings class="w-4 h-4 mr-2" />
                        Paramètres
                      </div>
                    </a>
                  </MenuItem>
                  <div class="border-t border-gray-100 my-1" />
                  <MenuItem v-slot="{ active }">
                    <a
                      href="#"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'block px-4 py-2 text-sm text-red-600'
                      ]"
                    >
                      <div class="flex items-center">
                        <LogOut class="w-4 h-4 mr-2" />
                        Déconnexion
                      </div>
                    </a>
                  </MenuItem>
                </MenuItems>
              </transition>
            </Menu>
          </div>
        </div>
      </div>
    </header>

    <!-- Mobile navigation -->
    <div class="fixed bottom-0 left-0 right-0 z-30 bg-white border-t border-gray-100 md:hidden">
      <nav class="flex justify-around">
        <NuxtLink
          v-for="item in navigationItems"
          :key="item.name"
          :to="item.to"
          :class="[
            isActive(item.to)
              ? 'text-blue-500'
              : 'text-gray-600',
            'flex flex-col items-center py-2 px-3'
          ]"
        >
          <component :is="item.icon" class="w-6 h-6" />
          <span class="text-xs mt-1">{{ item.name }}</span>
        </NuxtLink>
      </nav>
    </div>

    <!-- Main content -->
    <main class="pb-16 md:pb-0">
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
  QrCode,
  ChartBar,
  Settings,
  Bell,
  User,
  LogOut,
  ChevronDown,
  ShoppingCart,
  
} from 'lucide-vue-next'

const route = useRoute()

const navigationItems = [
  {
    name: 'Dashboard',
    to: `/manager/${route.params.slug}`,
    icon: LayoutDashboard
  },
  {
    name: 'Menu',
    to: `/manager/${route.params.slug}/products`,
    icon: Store
  },
  {
    name: 'QR Codes',
    to: `/manager/${route.params.slug}/qr-codes`,
    icon: QrCode
  },
  {
    name: 'Paramètres',
    to: `/manager/${route.params.slug}/settings`,
    icon: Settings
  }
]

const isActive = (path: string) => {
  return route.path === path
}
</script> 