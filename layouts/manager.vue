<template>
  <div class="min-h-screen bg-white">
    <!-- Mobile Header -->
    <header class="md:hidden bg-white border-b border-gray-100 sticky top-0 z-40">
      <div class="px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-lg flex items-center justify-center">
            <img src="~/assets/icon/logo.png" alt="Logo" class="w-full h-full object-contain" />
          </div>
          <h1 class="text-xl font-semibold text-orange-500 truncate">
            {{ establishment?.name || 'Dashboard' }}
          </h1>
        </div>
        <button 
          @click="toggleMobileMenu"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
        >
          <Menu class="w-5 h-5 text-gray-600" />
        </button>
      </div>
    </header>

    <!-- Mobile Menu Overlay -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div 
        v-if="showMobileMenu"
        class="md:hidden fixed inset-0 bg-black bg-opacity-50 z-50"
        @click="showMobileMenu = false"
      ></div>
    </Transition>

    <!-- Mobile Menu -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="transform -translate-x-full"
      enter-to-class="transform translate-x-0"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="transform translate-x-0"
      leave-to-class="transform -translate-x-full"
    >
      <div 
        v-if="showMobileMenu"
        class="md:hidden fixed left-0 top-0 h-full w-80 bg-white shadow-2xl z-50"
      >
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-lg flex items-center justify-center">
              <img src="~/assets/icon/logo.png" alt="Logo" class="w-full h-full object-contain" />
            </div>
            <div>
              <h1 class="text-xl font-bold text-orange-500">
                {{ establishment?.name || 'Dashboard' }}
              </h1>
              <p class="text-sm text-gray-500">Gestion</p>
            </div>
          </div>
        </div>

        <nav class="flex-1 p-4">
          <div class="space-y-1">
            <NuxtLink 
              v-for="item in navigationItems" 
              :key="item.path"
              :to="item.path"
              @click="showMobileMenu = false"
              class="flex items-center gap-4 p-3 rounded-full text-base transition-all"
              :class="[
                route.path.includes(item.active)
                  ? 'bg-gray-100 text-gray-900 font-semibold' 
                  : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'
              ]"
            >
              <component :is="item.icon" class="w-6 h-6" />
              <span>{{ item.name }}</span>
            </NuxtLink>
          </div>
        </nav>

        <div class="p-4 border-t border-gray-100">
          <div class="relative">
            <div class="flex items-center gap-3 p-3 rounded-full hover:bg-gray-100 cursor-pointer user-menu" @click="toggleUserMenu">
              <div class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                <span class="text-gray-600 text-sm font-medium">
                  {{ getUserInitials() }}
                </span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-semibold text-gray-900 truncate">
                  {{ (user as any)?.user_metadata?.full_name || (user as any)?.email }}
                </p>
                <p class="text-xs text-gray-500 truncate">
                  @{{ (user as any)?.email?.split('@')[0] }}
                </p>
              </div>
              <ChevronDown class="w-4 h-4 text-gray-400" />
            </div>
            
            <!-- Mobile User Menu Dropdown -->
            <Transition
              enter-active-class="transition duration-200 ease-out"
              enter-from-class="transform scale-95 opacity-0"
              enter-to-class="transform scale-100 opacity-100"
              leave-active-class="transition duration-150 ease-in"
              leave-from-class="transform scale-100 opacity-100"
              leave-to-class="transform scale-95 opacity-0"
            >
              <div 
                v-if="showUserMenu"
                class="absolute bottom-full left-0 mb-2 w-full bg-white shadow-lg rounded-2xl border border-gray-100 overflow-hidden z-10"
              >
                <div class="p-3 border-b border-gray-100">
                  <p class="text-sm font-semibold text-gray-900">{{ (user as any)?.user_metadata?.full_name || (user as any)?.email }}</p>
                  <p class="text-xs text-gray-500">@{{ (user as any)?.email?.split('@')[0] }}</p>
                </div>
                <div class="p-1">
                  <button
                    @click="handleLogout"
                    class="flex w-full items-center gap-3 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-md transition-colors"
                  >
                    <LogOut class="w-4 h-4" />
                    <span>Se déconnecter</span>
                  </button>
                </div>
              </div>
            </Transition>
          </div>
        </div>
      </div>
    </Transition>

    <div class="hidden md:flex">
      <!-- Desktop Sidebar - Style Twitter 2024 -->
      <aside class="w-64 bg-white border-r border-gray-100 flex flex-col h-screen fixed left-0 top-0">
        <!-- Logo Section -->
        <div class="p-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg flex items-center justify-center">
              <img src="~/assets/icon/logo.png" alt="Logo" class="w-full h-full object-contain" />
            </div>
            <div>
            <h1 class="text-xl font-bold text-orange-500">
              {{ establishment?.name || 'Dashboard' }}
            </h1>
              <p class="text-sm text-gray-500">Gestion</p>
            </div>
          </div>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-3">
          <div class="space-y-1">
            <NuxtLink 
              v-for="item in navigationItems" 
              :key="item.path"
              :to="item.path"
              class="flex items-center gap-4 p-3 rounded-full text-lg transition-all group"
              :class="[
                route.path.includes(item.active)
                  ? 'bg-gray-100 text-gray-900 font-semibold' 
                  : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'
              ]"
            >
              <component :is="item.icon" class="w-6 h-6" />
              <span>{{ item.name }}</span>
            </NuxtLink>
          </div>
        </nav>

        <!-- User Section -->
        <div class="p-3">
          <div class="relative">
            <div class="flex items-center gap-3 p-3 rounded-full hover:bg-gray-100 cursor-pointer transition-colors user-menu" @click="toggleUserMenu">
              <div class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                <span class="text-gray-600 text-sm font-medium">
                  {{ getUserInitials() }}
                </span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-semibold text-gray-900 truncate">
                  {{ (user as any)?.user_metadata?.full_name || (user as any)?.email }}
                </p>
                <p class="text-xs text-gray-500 truncate">
                  @{{ (user as any)?.email?.split('@')[0] }}
                </p>
              </div>
              <ChevronDown 
                class="w-4 h-4 text-gray-400 transition-transform duration-200"
                :class="{ 'rotate-180': showUserMenu }"
              />
            </div>
            
            <!-- Desktop User Menu Dropdown -->
            <Transition
              enter-active-class="transition duration-200 ease-out"
              enter-from-class="transform scale-95 opacity-0"
              enter-to-class="transform scale-100 opacity-100"
              leave-active-class="transition duration-150 ease-in"
              leave-from-class="transform scale-100 opacity-100"
              leave-to-class="transform scale-95 opacity-0"
            >
              <div 
                v-if="showUserMenu"
                class="absolute bottom-full left-0 mb-2 w-full bg-white shadow-lg rounded-2xl border border-gray-100 overflow-hidden z-10"
              >
                <div class="p-3 border-b border-gray-100">
                  <p class="text-sm font-semibold text-gray-900">{{ (user as any)?.user_metadata?.full_name || (user as any)?.email }}</p>
                  <p class="text-xs text-gray-500">@{{ (user as any)?.email?.split('@')[0] }}</p>
                </div>
                <div class="p-1">
                  <button
                    @click="handleLogout"
                    class="flex w-full items-center gap-3 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-md transition-colors"
                  >
                    <LogOut class="w-4 h-4" />
                    <span>Se déconnecter</span>
                  </button>
                </div>
              </div>
            </Transition>
          </div>
        </div>
      </aside>

      <!-- Desktop Main Content -->
      <main class="ml-64 flex-1 min-h-screen bg-gray-50">
        <div class="max-w-7xl mx-auto">
        <slot />
        </div>
      </main>
    </div>

    <!-- Mobile Main Content -->
    <main class="md:hidden">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import { 
  Home as LayoutDashboard,
  BookOpen as MenuIcon,
  Menu,
  List as CategoriesIcon,
  QrCode,
  Share2,
  Settings,
  LogOut,
  Users,
  Clock,
  List,
  ChevronDown,
  Plus as PlusIcon,
  Table,
  HelpCircle
} from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'
import { ref, onMounted, onUnmounted, watch, watchEffect, computed } from 'vue'

const route = useRoute()
const router = useRouter()
const { establishment, fetchEstablishmentByUserId } = useEstablishment()
const { user, logout, isLoading } = useAuth()
const showUserMenu = ref(false)
const showMobileMenu = ref(false)
definePageMeta({

middleware: 'auth'
})
const navigationItems = computed(() => [
  {
    name: 'Accueil',
    path: `/manager/${establishment.value?.id}`,
    active: '/manager/[slug]',
    icon: LayoutDashboard
  },
  {
    name: 'Menu',
    path: `/manager/${establishment.value?.id}/menu`,
    active: '/menu',
    icon: MenuIcon
  },
  {
    name: 'Catégories',
    path: `/manager/${establishment.value?.id}/categories`,
    active: '/categories',
    icon: List
  },
  {
    name: 'QR Codes',
    path: `/manager/${establishment.value?.id}/tables`,
    active: '/tables',
    icon: QrCode
  },
  // {
  //   name: 'QR Codes',
  //   path: `/manager/${establishment.value?.id}/qr-codes`,
  //   active: '/qr-codes',
  //   icon: QrCode
  // },
  {
    name: 'Commandes',
    path: `/manager/${establishment.value?.id}/orders`,
    active: '/orders',
    icon: Clock
  },
  // {
  //   name: 'Support QR',
  //   path: `/manager/${establishment.value?.id}/qr-support`,
  //   active: '/qr-support',
  //   icon: HelpCircle
  // },
  {
    name: 'Personnel',
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

const getUserInitials = () => {
  const name = (user.value as any)?.user_metadata?.full_name || (user.value as any)?.email
  if (name) {
    return name.split(' ').map((n: string) => n[0]).join('').toUpperCase().slice(0, 2)
  }
  return 'U'
}

const handleLogout = async () => {
  await logout()
  navigateTo('/auth/login')
}

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
}

// Gestionnaire de clic en dehors du menu
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (showUserMenu.value && !target.closest('.user-menu')) {
    showUserMenu.value = false
  }
}

// Gestionnaire de touche Echap
const handleEscape = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && showUserMenu.value) {
    showUserMenu.value = false
  }
}

// Vérifier si l'utilisateur est authentifié
onMounted(async () => {
  // Si pas d'utilisateur et pas en cours de chargement, rediriger vers login
  if (!user.value && !isLoading.value) {
    navigateTo('/auth/login')
    return
  }

  // Charger l'établissement de l'utilisateur
  if (user.value) {
    await fetchEstablishmentByUserId()
  }

  // Ajouter les event listeners
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleEscape)
})

// Watch pour la session
watch(user, async (newUser) => {
  if (!newUser && !isLoading.value) {
    navigateTo('/auth/login')
  } else if (newUser) {
    // Recharger l'établissement quand l'utilisateur change
    await fetchEstablishmentByUserId()
  }
}, { immediate: true })

// Nettoyer les event listeners
onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleEscape)
})
</script>

<style scoped>
/* Design Twitter 2024 - Plus propre et moderne */
.rounded-full {
  border-radius: 9999px;
}

/* Transitions fluides */
.transition-all {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Hover effects subtils */
.hover\:bg-gray-100:hover {
  background-color: #f3f4f6;
}

/* Focus states pour l'accessibilité */
button:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Responsive design */
@media (max-width: 768px) {
  .w-80 {
    width: 20rem;
  }
}
</style> 