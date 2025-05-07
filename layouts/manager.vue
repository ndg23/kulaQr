<template>
  <div class="min-h-screen bg-white">
    <div class="mx-auto max-w-7xl flex h-screen">
      <!-- Left Margin -->
      <div class="w-[68px] xl:w-[275px] shrink-0" />

      <!-- Sidebar -->
      <div class="w-[68px] xl:w-[275px] flex flex-col h-full fixed">
        <!-- Logo -->
        <div class="p-3">
          <div class="xl:hidden flex justify-center">
            <div class="w-11 h-11 rounded-full bg-black flex items-center justify-center">
              <img 
                :src="establishment?.logo || '/default-logo.png'"
                class="w-6 h-6"
                alt="Logo"
              />
            </div>
          </div>
          <h1 class="hidden xl:block text-xl font-bold px-4">
            {{ establishment?.name || 'Dashboard' }}
          </h1>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-2">
          <!-- Primary Navigation -->
          <div class="space-y-0.5 mb-8">
            <NuxtLink 
              v-for="item in primaryNavigation"
              :key="item.path"
              :to="item.path"
              class="flex items-center xl:gap-3 p-3 rounded-full text-[17px] transition-colors"
              :class="[
                route.path.includes(item.active) 
                  ? 'font-bold text-black bg-gray-100' 
                  : 'text-gray-800 hover:bg-gray-50'
              ]"
            >
              <component :is="item.icon" class="w-[24px] h-[24px] min-w-[24px]" />
              <span class="hidden xl:block">{{ item.name }}</span>
              <span 
                v-if="item.count"
                class="ml-auto bg-[#F91880] text-white text-xs font-bold px-2 py-0.5 rounded-full"
              >
                {{ item.count }}
              </span>
            </NuxtLink>
          </div>

          <!-- Secondary Navigation -->
          <div class="space-y-0.5">
            <p class="hidden xl:block text-xs font-semibold text-gray-500 uppercase px-4 mb-2">
              Configuration
            </p>
            <NuxtLink 
              v-for="item in secondaryNavigation"
              :key="item.path"
              :to="item.path"
              class="flex items-center xl:gap-3 p-3 rounded-full text-[15px] transition-colors"
              :class="[
                route.path.includes(item.active) 
                  ? 'font-bold text-black bg-gray-100' 
                  : 'text-gray-800 hover:bg-gray-50'
              ]"
            >
              <component :is="item.icon" class="w-[20px] h-[20px] min-w-[20px]" />
              <span class="hidden xl:block">{{ item.name }}</span>
            </NuxtLink>
          </div>
        </nav>

        <!-- User Menu -->
        <div class="p-3 mt-auto">
          <Menu as="div" class="relative">
            <MenuButton class="flex items-center w-full p-2.5 rounded-full hover:bg-gray-50">
              <img 
                :src="user?.user_metadata?.avatar_url || '/default-logo.png'"
                class="w-9 h-9 rounded-full"
              />
              <div class="hidden xl:block flex-1 text-left ml-3">
                <p class="text-[15px] font-bold truncate max-w-[130px]">
                  {{ user?.user_metadata?.full_name }}
                </p>
                <p class="text-[13px] text-gray-500 truncate max-w-[130px]">
                  {{ user?.email }}
                </p>
              </div>
              <ChevronDown class="hidden xl:block w-4 h-4 text-gray-500" />
            </MenuButton>

            <MenuItems 
              class="absolute bottom-full right-0 mb-2 w-[260px] bg-white shadow-lg rounded-xl border border-gray-100 overflow-hidden"
            >
              <MenuItem v-slot="{ active }">
                <button
                  @click="handleLogout"
                  class="flex w-full items-center gap-3 px-4 py-3 text-[15px] hover:bg-gray-50"
                >
                  <LogOut class="w-5 h-5" />
                  <span>Se déconnecter</span>
                </button>
              </MenuItem>
            </MenuItems>
          </Menu>
        </div>
      </div>

      <!-- Main Content -->
      <main class="flex-1 min-w-0 border-x border-[#EFF3F4]">
        <slot />
      </main>

      <!-- Right Margin -->
      <div class="w-[350px] shrink-0 hidden xl:block" />
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Package,
  ShoppingCart,
  BarChart2,
  Settings,
  Users,
  QrCode,
  Share2,
  ChevronDown,
  LogOut
} from 'lucide-vue-next'
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/vue'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'

const route = useRoute()
const { establishment } = useEstablishment()
const { user, logout } = useAuth()

const orderCount = ref(0)

// Navigation principale adaptée au type d'établissement
const primaryNavigation = computed(() => [
  {
    name: 'Catalogue',
    path: `/manager/${establishment.value?.id}/menu`,
    active: '/menu',
    icon: Package
  },
  {
    name: 'Commandes',
    path: `/manager/${establishment.value?.id}/orders`,
    active: '/orders',
    icon: ShoppingCart,
    count: orderCount.value
  },
  {
    name: 'Statistiques',
    path: `/manager/${establishment.value?.id}/analytics`,
    active: '/analytics',
    icon: BarChart2
  }
])

// Navigation secondaire commune
const secondaryNavigation = computed(() => [
  {
    name: 'QR Codes',
    path: `/manager/${establishment.value?.id}/qr`,
    active: '/qr',
    icon: QrCode
  },
  {
    name: 'Partage',
    path: `/manager/${establishment.value?.id}/share`,
    active: '/share',
    icon: Share2
  },
  {
    name: 'Équipe',
    path: `/manager/${establishment.value?.id}/staff`,
    active: '/staff',
    icon: Users
  },
  {
    name: 'Paramètres',
    path: `/manager/${establishment.value?.id}/settings`,
    active: '/settings',
    icon: Settings
  }
])

const handleLogout = async () => {
  await logout()
  navigateTo('/auth/login')
}
</script>

<style scoped>
.pattern-grid {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Cpath fill='%23000000' d='M8 21H4a1 1 0 0 1-1-1v-4a1 1 0 0 0-2 0v4a3 3 0 0 0 3 3h4a1 1 0 0 0 0-2m14-6a1 1 0 0 0-1 1v4a1 1 0 0 1-1 1h-4a1 1 0 0 0 0 2h4a3 3 0 0 0 3-3v-4a1 1 0 0 0-1-1M20 1h-4a1 1 0 0 0 0 2h4a1 1 0 0 1 1 1v4a1 1 0 0 0 2 0V4a3 3 0 0 0-3-3M2 9a1 1 0 0 0 1-1V4a1 1 0 0 1 1-1h4a1 1 0 0 0 0-2H4a3 3 0 0 0-3 3v4a1 1 0 0 0 1 1'/%3E%3C/svg%3E");
  background-repeat: repeat;
  background-size: 48px 48px;
  animation: patternFloat 60s linear infinite;
}

@keyframes patternFloat {
  0% { background-position: 0 0; }
  100% { background-position: 48px 48px; }
}
</style> 