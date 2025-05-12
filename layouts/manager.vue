<template>
  <div class="min-h-screen bg-white">
    <div class="mx-auto max-w-7xl flex h-screen">
      <!-- Sidebar -->
      <div class="w-[68px] md:w-[275px] flex flex-col h-full fixed border-r border-gray-100">
        <!-- Logo -->
        <div class="p-3">
          <div class="md:hidden flex justify-center">
            <div class="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center">
              <img 
                :src="establishment?.logo || '/default-logo.png'"
                class="w-7 h-7"
                alt="Logo"
              />
            </div>
          </div>
          <div class="hidden md:flex items-center gap-3 px-3">
            <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center">
              <img 
                :src="establishment?.logo || '/default-logo.png'"
                class="w-6 h-6"
                alt="Logo"
              />
            </div>
            <h1 class="text-xl font-bold text-gray-900">
              {{ establishment?.name || 'Dashboard' }}
            </h1>
          </div>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-2 mt-4">
          <div class="space-y-1">
            <NuxtLink 
              v-for="item in navigationItems" 
              :key="item.path"
              :to="item.path"
              class="flex items-center md:gap-4 p-3 rounded-full text-[17px] transition-colors"
              :class="[
                route.path.includes(item.active)
                  ? 'font-bold text-blue-500' 
                  : 'text-gray-800 hover:text-blue-500 hover:bg-blue-50'
              ]"
            >
              <component :is="item.icon" class="w-[26px] h-[26px] min-w-[26px]" />
              <span class="hidden md:block">{{ item.name }}</span>
              <span 
                v-if="item.count"
                class="ml-auto bg-blue-500 text-white text-xs font-bold px-2 py-0.5 rounded-full"
              >
                {{ item.count }}
              </span>
            </NuxtLink>
          </div>
        </nav>

        <!-- Tweet Button -->
        <div class="px-3 mb-3">
          <button 
            @click="createNewItem"
            class="w-full bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 rounded-full transition-colors"
          >
            <span class="hidden md:inline">Créer</span>
            <PlusIcon class="w-6 h-6 md:hidden mx-auto" />
          </button>
        </div>

        <!-- User Menu -->
        <div class="p-3 mt-auto">
          <div class="flex items-center w-full p-2.5 rounded-full hover:bg-blue-50 cursor-pointer" @click="showUserMenu = !showUserMenu">
            <img 
              :src="user?.user_metadata?.avatar_url || '/default-avatar.png'"
              class="w-10 h-10 rounded-full"
              alt="Avatar"
            />
            <div class="hidden md:block flex-1 text-left ml-3">
              <p class="text-[15px] font-bold truncate max-w-[130px]">
                {{ user?.user_metadata?.full_name || user?.email }}
              </p>
              <p class="text-[13px] text-gray-500 truncate max-w-[130px]">
                @{{ user?.email?.split('@')[0] }}
              </p>
            </div>
            <ChevronDown class="hidden md:block w-4 h-4 text-gray-500" />
          </div>
          
          <!-- User Menu Dropdown -->
          <div 
            v-if="showUserMenu" 
            class="absolute bottom-20 left-3 md:left-auto md:right-3 w-[250px] bg-white shadow-lg rounded-xl border border-gray-100 overflow-hidden z-10"
          >
            <div class="p-3 border-b border-gray-100">
              <p class="text-[15px] font-bold">{{ user?.user_metadata?.full_name || user?.email }}</p>
              <p class="text-[13px] text-gray-500">@{{ user?.email?.split('@')[0] }}</p>
            </div>
            <button 
              @click="handleLogout"
              class="flex w-full items-center gap-3 px-4 py-3 text-[15px] hover:bg-gray-50"
            >
              <LogOut class="w-5 h-5" />
              <span>Se déconnecter</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <main class="ml-[68px] md:ml-[275px] flex-1 min-w-0 border-x border-gray-100">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  Home as LayoutDashboard,
  BookOpen as MenuIcon,
  QrCode,
  Share2,
  Settings,
  LogOut,
  Users,
  Clock,
  List,
  ChevronDown,
  Plus as PlusIcon
} from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useAuth } from '~/composables/useAuth'
import { ref } from 'vue'

const route = useRoute()
const router = useRouter()
const { establishment } = useEstablishment()
const { user, logout } = useAuth()
const showUserMenu = ref(false)

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
    path: `/manager/${establishment.value?.id}/qr-codes`,
    active: '/qr-codes',
    icon: QrCode
  },
  {
    name: 'Partage',
    path: `/manager/${establishment.value?.id}/share`,
    active: '/share',
    icon: Share2
  },
  {
    name: 'Commandes',
    path: `/manager/${establishment.value?.id}/orders`,
    active: '/orders',
    icon: Clock,
    count: 5
  },
  {
    name: 'Staff',
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

const createNewItem = () => {
  // Determine what to create based on current route
  if (route.path.includes('/menu')) {
    router.push(`/manager/${establishment.value?.id}/menu/new`)
  } else if (route.path.includes('/categories')) {
    router.push(`/manager/${establishment.value?.id}/categories/new`)
  } else {
    // Default action
    router.push(`/manager/${establishment.value?.id}/menu/new`)
  }
}

// Close menu when clicking outside
onMounted(() => {
  document.addEventListener('click', (e) => {
    if (showUserMenu.value && !e.target.closest('.user-menu')) {
      showUserMenu.value = false
    }
  })
})
</script>

<style scoped>
/* Twitter blue color */
:root {
  --twitter-blue: #1DA1F2;
  --twitter-blue-hover: #1a91da;
  --twitter-black: #14171A;
  --twitter-dark-gray: #657786;
  --twitter-light-gray: #AAB8C2;
  --twitter-extra-light-gray: #E1E8ED;
  --twitter-extra-extra-light-gray: #F5F8FA;
}
</style> 