<template>
  <div class="adm min-h-dvh bg-white">
    <!-- Mobile / tablet header -->
    <header class="lg:hidden bg-white/95 backdrop-blur border-b border-gray-200 sticky top-0 z-40">
      <div class="px-4 h-14 flex items-center justify-between gap-3">
        <NuxtLink to="/admin" class="flex items-center gap-2 min-w-0">
          <span class="w-8 h-8 rounded-full bg-[#00E676] flex items-center justify-center flex-shrink-0">
            <span class="text-base font-black text-black">K</span>
          </span>
          <span class="flex flex-col leading-tight min-w-0">
            <span class="text-base font-black text-black truncate">KulaQr</span>
            <span class="text-[11px] font-bold text-red-600 truncate">ADMINISTRATEUR</span>
          </span>
        </NuxtLink>

        <button
          class="w-10 h-10 -mr-1 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
          :aria-label="showMobileMenu ? 'Fermer le menu' : 'Ouvrir le menu'"
          :aria-expanded="showMobileMenu"
          @click="showMobileMenu = !showMobileMenu"
        >
          <MenuIcon v-if="!showMobileMenu" class="w-5 h-5" />
          <X v-else class="w-5 h-5" />
        </button>
      </div>
    </header>

    <!-- Mobile drawer -->
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
        class="lg:hidden fixed inset-0 bg-black/30 z-40"
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
      <aside
        v-if="showMobileMenu"
        class="lg:hidden fixed left-0 top-0 h-full w-72 max-w-[85vw] bg-white shadow-xl z-50 flex flex-col"
      >
        <div class="h-14 px-4 border-b border-gray-100 flex items-center justify-between flex-shrink-0">
          <NuxtLink to="/admin" class="flex items-center gap-2" @click="showMobileMenu = false">
            <span class="w-8 h-8 rounded-full bg-[#00E676] flex items-center justify-center">
              <span class="text-base font-black text-black">K</span>
            </span>
            <span class="text-base font-black text-black">KulaQr</span>
          </NuxtLink>
          <button
            class="w-10 h-10 -mr-1 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
            aria-label="Fermer le menu"
            @click="showMobileMenu = false"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <nav class="flex-1 min-h-0 overflow-y-auto overscroll-contain p-2 space-y-1" aria-label="Navigation principale">
          <NuxtLink
            v-for="item in navigationItems"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-3 min-h-[3rem] px-2 py-1.5 rounded-full transition-colors"
            :class="isActive(item) ? navActive : navIdle"
            :aria-current="isActive(item) ? 'page' : undefined"
          >
            <IconBadge :icon="item.icon" :tone="item.tone" />
            <span class="text-base leading-tight">{{ item.name }}</span>
          </NuxtLink>
        </nav>

        <div class="p-3 border-t border-gray-100 flex-shrink-0">
          <div class="flex items-center gap-3 px-2 py-2">
            <div class="w-10 h-10 rounded-full bg-[#2962FF] flex items-center justify-center flex-shrink-0">
              <span class="text-base font-bold text-white">{{ userInitials }}</span>
            </div>
            <div class="min-w-0">
              <p class="text-sm font-bold text-gray-900 truncate">{{ userName }}</p>
              <p class="text-xs text-gray-500 truncate">{{ userEmail }}</p>
            </div>
          </div>
          <button
            class="flex w-full items-center gap-3 min-h-[3rem] px-2 py-1.5 text-red-600 font-semibold hover:bg-gray-100 rounded-full transition-colors"
            @click="handleLogout"
          >
            <IconBadge :icon="LogOut" tone="pink" />
            <span>Déconnexion</span>
          </button>
        </div>
      </aside>
    </Transition>

    <!-- Desktop sidebar -->
    <aside class="hidden lg:flex w-64 xl:w-72 border-r border-gray-100 flex-col h-dvh fixed left-0 top-0 bg-white z-30">
      <div class="p-4 flex-shrink-0">
        <NuxtLink
          to="/admin"
          class="group inline-flex items-center p-3 hover:bg-gray-100 rounded-full transition-colors"
        >
          <span class="w-10 h-10 rounded-full bg-[#00E676] flex items-center justify-center">
            <span class="text-xl font-black text-black group-hover:scale-110 transition-transform">K</span>
          </span>
          <span class="ml-3 flex flex-col leading-tight">
            <span class="text-xl font-black text-black">KulaQr</span>
            <span class="text-xs font-bold text-red-600">ADMINISTRATEUR</span>
          </span>
        </NuxtLink>
      </div>

      <nav class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-2 pb-2 space-y-1 [scrollbar-width:thin]" aria-label="Navigation principale">
        <NuxtLink
          v-for="item in navigationItems"
          :key="item.path"
          :to="item.path"
          class="flex items-center gap-3 min-h-[3rem] px-2 py-1.5 text-lg rounded-full transition-colors"
          :class="isActive(item) ? navActive : navIdle"
          :aria-current="isActive(item) ? 'page' : undefined"
        >
          <IconBadge :icon="item.icon" :tone="item.tone" />
          <span class="leading-tight min-w-0 break-words">{{ item.name }}</span>
        </NuxtLink>
      </nav>

      <div class="border-t border-gray-100 p-3 flex-shrink-0 relative" ref="userMenuRoot">
        <button
          class="flex w-full items-center gap-3 p-3 rounded-full hover:bg-gray-100 transition-colors"
          :aria-expanded="showUserMenu"
          @click="showUserMenu = !showUserMenu"
        >
          <span class="relative flex-shrink-0">
            <span class="w-10 h-10 bg-[#2962FF] rounded-full flex items-center justify-center">
              <span class="text-lg font-bold text-white">{{ userInitials }}</span>
            </span>
            <span class="absolute -bottom-1 -right-1 w-5 h-5 bg-gray-100 rounded-full flex items-center justify-center border-2 border-white">
              <MoreHorizontal class="w-3 h-3 text-gray-600" />
            </span>
          </span>
          <span class="flex-1 min-w-0 text-left">
            <span class="block font-medium text-gray-900 truncate">{{ userName }}</span>
            <span class="block text-sm text-gray-500 truncate">{{ userEmail }}</span>
          </span>
        </button>

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
            class="absolute bottom-full left-3 right-3 mb-2 bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden"
          >
            <div class="p-4 border-b border-gray-100">
              <span class="inline-block px-3 py-1 text-sm font-medium rounded-full bg-red-100 text-red-700">Administrateur</span>
            </div>
            <button
              class="flex items-center w-full gap-3 px-4 py-3 text-red-600 hover:bg-gray-100 transition-colors"
              @click="handleLogout"
            >
              <LogOut class="w-5 h-5" />
              <span>Se déconnecter</span>
            </button>
          </div>
        </Transition>
      </div>
    </aside>

    <!-- Contenu : un seul <slot />, le même conteneur pour toutes les pages admin -->
    <main class="lg:ml-64 xl:ml-72 min-h-dvh min-w-0 pb-[env(safe-area-inset-bottom)]">
      <div class="max-w-7xl mx-auto px-3 sm:px-6 xl:px-8 py-4 sm:py-6">
        <slot />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import {
  User,
  LogOut,
  Menu as MenuIcon,
  MoreHorizontal,
  X
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import IconBadge from '~/components/ui/IconBadge.vue'
import { ADMIN_NAV, isAdminNavActive, type AdminNavItem } from '~/utils/adminNav'
import '~/assets/css/admin.css'

const route = useRoute()
const router = useRouter()
const { client: supabase } = useSupabaseWrapper()

const showMobileMenu = ref(false)
const showUserMenu = ref(false)
const userMenuRoot = ref<HTMLElement | null>(null)
const userName = ref('Administrateur')
const userEmail = ref('@admin')

const navigationItems = ADMIN_NAV.filter(item => !item.hidden)

const navActive = 'font-black text-black bg-gray-100 ring-2 ring-black'
const navIdle = 'font-semibold text-gray-700 hover:bg-gray-100'

const userInitials = computed(() =>
  (userName.value || 'A').split(/\s+/).map(w => w[0]).join('').slice(0, 2).toUpperCase()
)

const isActive = (item: AdminNavItem) => isAdminNavActive(item, route.path)

const handleLogout = async () => {
  try {
    await supabase.auth.signOut()
    await router.push('/auth/login')
  } catch (error) {
    console.error('Logout error:', error)
  }
}

const fetchUserSession = async () => {
  try {
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) throw error
    if (user) {
      userName.value = user.user_metadata?.full_name || user.email?.split('@')[0] || 'Administrateur'
      userEmail.value = `@${user.email?.split('@')[0] || 'admin'}`
    }
  } catch (error) {
    console.error('Error fetching user session:', error)
    await router.push('/auth/login')
  }
}

const handleClickOutside = (event: Event) => {
  if (userMenuRoot.value && !userMenuRoot.value.contains(event.target as Node)) {
    showUserMenu.value = false
  }
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    showMobileMenu.value = false
    showUserMenu.value = false
  }
}

watch(() => route.path, () => {
  showMobileMenu.value = false
})

// Empêche le défilement de la page derrière le tiroir mobile
watch(showMobileMenu, (open) => {
  if (import.meta.client) document.body.style.overflow = open ? 'hidden' : ''
})

onMounted(async () => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
  await fetchUserSession()
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
  if (import.meta.client) document.body.style.overflow = ''
})
</script>
