<template>
  <div class="min-h-screen bg-white">
    <!-- Mobile Header -->
    <header class="md:hidden bg-white border-b border-gray-200 sticky top-0 z-40">
      <div class="px-4 py-3">
        <div class="flex items-center justify-between">
          <NuxtLink to="/admin" class="flex items-center gap-2">
            <div class="w-9 h-9 rounded-full bg-black flex items-center justify-center">
              <span class="text-white text-sm font-bold">Y</span>
            </div>
          </NuxtLink>
          
          <button
            @click="showMobileMenu = !showMobileMenu"
            class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <MenuIcon v-if="!showMobileMenu" class="w-5 h-5" />
            <X v-else class="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>

    <!-- Mobile Menu -->
    <Transition
      enter-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-opacity duration-200"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="showMobileMenu"
        class="md:hidden fixed inset-0 bg-black/20 z-40"
        @click="showMobileMenu = false"
      />
    </Transition>

    <Transition
      enter-active-class="transition-transform duration-200"
      enter-from-class="-translate-x-full"
      enter-to-class="translate-x-0"
      leave-active-class="transition-transform duration-200"
      leave-from-class="translate-x-0"
      leave-to-class="-translate-x-full"
    >
      <div v-if="showMobileMenu" class="md:hidden fixed left-0 top-0 h-full w-64 bg-white shadow-xl z-50">
        <div class="p-4 border-b">
          <NuxtLink to="/admin" class="flex items-center gap-3" @click="showMobileMenu = false">
            <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
              <span class="text-white text-xs font-bold">Y</span>
            </div>
            <span class="text-lg font-bold">Admin</span>
          </NuxtLink>
        </div>

        <nav class="p-2">
          <NuxtLink
            v-for="item in navigationItems"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-4 px-4 py-3 rounded-full transition-colors"
            :class="[
              route.path === item.path || route.path.includes(item.active)
                ? 'font-bold'
                : 'hover:bg-gray-100'
            ]"
            @click="showMobileMenu = false"
          >
            <component :is="item.icon" class="w-6 h-6" :stroke-width="route.path.includes(item.active) ? 2.5 : 2" />
            <span class="text-lg">{{ item.name }}</span>
          </NuxtLink>
        </nav>

        <div class="absolute bottom-0 left-0 right-0 p-4 border-t">
          <button
            @click="handleLogout"
            class="flex w-full items-center gap-3 px-4 py-3 hover:bg-gray-100 rounded-full transition-colors"
          >
            <LogOut class="w-5 h-5" />
            <span>Déconnexion</span>
          </button>
        </div>
      </div>
    </Transition>

    <div class="hidden md:flex">
      <!-- Desktop Sidebar - Twitter Style -->
      <aside class="w-72 border-r border-gray-200 flex flex-col h-screen fixed left-0 top-0">
        <!-- Logo -->
        <div class="px-4 pt-2">
          <NuxtLink 
            to="/admin" 
            class="w-12 h-12 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
              <span class="text-white text-sm font-bold">Y</span>
            </div>
          </NuxtLink>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-2 pt-2 space-y-1">
          <NuxtLink
            v-for="item in navigationItems"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-5 px-4 py-3 rounded-full transition-colors group"
            :class="[
              route.path === item.path || route.path.includes(item.active)
                ? 'font-bold'
                : 'hover:bg-gray-100'
            ]"
          >
            <component 
              :is="item.icon" 
              class="w-7 h-7" 
              :stroke-width="route.path.includes(item.active) ? 2.5 : 2" 
            />
            <span class="text-xl">{{ item.name }}</span>
          </NuxtLink>

          <!-- Post Button Style (Optional) -->
          <button class="w-full mt-4 bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 rounded-full transition-colors">
            Nouveau
          </button>
        </nav>

        <!-- User Section -->
        <div class="p-3 mb-4">
          <div class="relative">
            <button
              @click="toggleUserMenu"
              class="flex w-full items-center gap-3 px-3 py-3 rounded-full hover:bg-gray-100 transition-colors group"
            >
              <div class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center flex-shrink-0">
                <User class="w-5 h-5 text-gray-600" />
              </div>
              <div class="flex-1 min-w-0 text-left">
                <p class="text-sm font-bold text-gray-900 truncate">Administrateur</p>
                <p class="text-sm text-gray-500 truncate">@admin</p>
              </div>
              <svg class="w-4 h-4 text-gray-900" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 13.5a1.5 1.5 0 110-3 1.5 1.5 0 010 3zm0-5a1.5 1.5 0 110-3 1.5 1.5 0 010 3zm0 10a1.5 1.5 0 110-3 1.5 1.5 0 010 3z"/>
              </svg>
            </button>

            <!-- Dropdown Menu -->
            <Transition
              enter-active-class="transition duration-100 ease-out"
              enter-from-class="transform scale-95 opacity-0"
              enter-to-class="transform scale-100 opacity-100"
              leave-active-class="transition duration-75 ease-in"
              leave-from-class="transform scale-100 opacity-100"
              leave-to-class="transform scale-95 opacity-0"
            >
              <div
                v-if="showUserMenu"
                class="absolute bottom-full left-0 mb-2 w-full bg-white shadow-xl rounded-2xl border border-gray-200 overflow-hidden"
              >
                <button
                  @click="handleLogout"
                  class="flex w-full items-center gap-3 px-4 py-3 text-sm font-bold hover:bg-gray-50 transition-colors"
                >
                  <LogOut class="w-4 h-4" />
                  <span>Déconnexion @admin</span>
                </button>
              </div>
            </Transition>
          </div>
        </div>
      </aside>

      <!-- Main Content -->
      <main class="ml-72 flex-1 min-h-screen">
        <slot />
      </main>
    </div>

    <!-- Mobile Main Content -->
    <main class="md:hidden">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import {
  LayoutDashboard,
  Store,
  Users,
  Settings,
  User,
  LogOut,
  Menu as MenuIcon,
  X,
  QrCode,
  BarChart3
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()

// State
const showMobileMenu = ref(false)
const showUserMenu = ref(false)

// Navigation items
const navigationItems = [
  {
    name: 'Accueil',
    path: '/admin',
    active: '/admin',
    icon: LayoutDashboard
  },
  {
    name: 'Établissements',
    path: '/admin/establishments',
    active: 'establishments',
    icon: Store
  },
  {
    name: 'Utilisateurs',
    path: '/admin/users',
    active: 'users',
    icon: Users
  },
  {
    name: 'QR Codes',
    path: '/admin/qr-codes',
    active: 'qr-codes',
    icon: QrCode
  },
  {
    name: 'Stats',
    path: '/admin/stats',
    active: 'stats',
    icon: BarChart3
  },
  {
    name: 'Paramètres',
    path: '/admin/settings',
    active: 'settings',
    icon: Settings
  }
]

// Toggle user menu
const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

// Handle logout
const handleLogout = async () => {
  try {
    // Add your logout logic here
    await router.push('/auth/login')
  } catch (error) {
    console.error('Logout error:', error)
  }
}

// Close menus when clicking outside
const handleClickOutside = (event: Event) => {
  const target = event.target as HTMLElement
  if (!target.closest('.group')) {
    showUserMenu.value = false
  }
}

// Close mobile menu when route changes
watch(() => route.path, () => {
  showMobileMenu.value = false
})

// Setup event listeners
onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>