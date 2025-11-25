<template>
  <div class="min-h-screen bg-white">
    <!-- Mobile Header -->
    <header class="md:hidden bg-white border-b border-gray-200 sticky top-0 z-40">
      <div class="px-4 py-3">
        <div class="flex items-center justify-between">
          <NuxtLink :to="`/manager/${establishment?.id}`" class="flex items-center gap-2">
            <div class="w-9 h-9 rounded-full bg-orange-500 flex items-center justify-center">
              <span class="text-white text-sm font-bold">{{ getEstablishmentInitials() }}</span>
            </div>
          </NuxtLink>
          
          <button
            @click="showMobileMenu = !showMobileMenu"
            class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <Menu v-if="!showMobileMenu" class="w-5 h-5" />
            <X v-else class="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>

    <!-- Mobile Menu Overlay -->
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

    <!-- Mobile Menu -->
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
          <NuxtLink :to="`/manager/${establishment?.id}`" class="flex items-center gap-3" @click="showMobileMenu = false">
            <div class="w-8 h-8 rounded-full bg-orange-500 flex items-center justify-center">
              <span class="text-white text-xs font-bold">{{ getEstablishmentInitials() }}</span>
            </div>
            <span class="text-lg font-bold">{{ establishment?.name || 'Manager' }}</span>
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
            :to="`/manager/${establishment?.id}`"
            class="w-12 h-12 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <div class="w-8 h-8 rounded-full bg-orange-500 flex items-center justify-center">
              <span class="text-white text-sm font-bold">{{ getEstablishmentInitials() }}</span>
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
        </nav>

        <!-- User Section -->
        <div class="p-3 mb-4">
          <div class="relative">
            <button
              data-user-menu-button
              @click="toggleUserMenu"
              class="flex w-full items-center gap-3 px-3 py-3 rounded-full hover:bg-gray-100 transition-colors group"
            >
              <div class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center flex-shrink-0">
                <span class="text-gray-600 text-sm font-medium">{{ getUserInitials() }}</span>
              </div>
              <div class="flex-1 min-w-0 text-left">
                <p class="text-sm font-bold text-gray-900 truncate">{{ userName }}</p>
                <p class="text-sm text-gray-500 truncate">{{ userEmail }}</p>
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
                data-user-menu-dropdown
                class="absolute bottom-full left-0 mb-2 w-full bg-white shadow-xl rounded-2xl border border-gray-200 overflow-hidden"
              >
                <button
                  @click="handleLogout"
                  class="flex w-full items-center gap-3 px-4 py-3 text-sm font-bold hover:bg-gray-50 transition-colors"
                >
                  <LogOut class="w-4 h-4" />
                  <span>Déconnexion {{ userEmail }}</span>
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

// Computed properties for user data
const userName = computed(() => {
  return (user.value as any)?.user_metadata?.full_name || 'Utilisateur'
})

const userEmail = computed(() => {
  return (user.value as any)?.email || ''
})

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

const getEstablishmentInitials = () => {
  const name = establishment.value?.name || establishment.value?.id
  if (name) {
    return name.toString().split(' ').map((n: string) => n[0]).join('').toUpperCase().slice(0, 2)
  }
  return 'E'
}

const handleLogout = async () => {
  showUserMenu.value = false // Fermer le menu avant de déconnecter
  await logout()
  navigateTo('/auth/login')
}

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
}

// Gestionnaire de clic en dehors du menu - Fixed
const handleClickOutside = (event: MouseEvent) => {
  if (!showUserMenu.value) return
  
  const target = event.target as HTMLElement
  const userMenuButton = document.querySelector('[data-user-menu-button]')
  const userMenuDropdown = document.querySelector('[data-user-menu-dropdown]')
  
  // Si le clic n'est ni sur le bouton ni sur le dropdown, fermer
  if (userMenuButton && userMenuDropdown) {
    if (!userMenuButton.contains(target) && !userMenuDropdown.contains(target)) {
      showUserMenu.value = false
    }
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