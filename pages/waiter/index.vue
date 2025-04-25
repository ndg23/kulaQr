<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="sticky top-0 z-30 bg-white border-b border-gray-100">
      <div class="max-w-7xl mx-auto">
        <div class="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
          <!-- Left side -->
          <div class="flex items-center">
            <div class="flex items-center">
              <img src="~/assets/icon/logo.png" class="w-auto h-[50px]" alt="Logo" />
              <span class="text-xl font-logo ml-3 text-gray-900">Kula QR</span>
            </div>
          </div>

          <!-- Title -->
          <div class="text-center">
            <h1 class="text-lg font-medium text-gray-900">{{ establishmentName }}</h1>
          </div>

          <!-- Right side -->
          <div class="flex items-center space-x-4">
            <!-- User info -->
            <Menu as="div" class="relative">
              <MenuButton class="flex items-center space-x-3">
                <div class="flex items-center space-x-3">
                  <div class="h-8 w-8 rounded-full bg-kula-50 flex items-center justify-center">
                    <User class="h-4 w-4 text-kula-500" />
                  </div>
                  <span class="hidden md:block text-sm font-medium text-gray-700">
                    {{ username }}
                  </span>
                </div>
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
                    <button
                      @click="handleLogout"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'flex w-full items-center px-4 py-2 text-sm text-gray-700'
                      ]"
                    >
                      <LogOut class="mr-3 h-4 w-4 text-gray-400" />
                      Déconnexion
                    </button>
                  </MenuItem>
                </MenuItems>
              </transition>
            </Menu>
          </div>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="py-8 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Orders card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Commandes</h2>
            <ShoppingCart class="h-5 w-5 text-kula-500" />
          </div>
          <p class="text-gray-500 mb-4">Gérez les commandes en cours et nouvelles</p>
          <NuxtLink
            to="/staff/orders"
            class="inline-flex items-center px-4 py-2 bg-kula-500 text-white rounded-full text-sm font-medium hover:bg-kula-600 transition-colors"
          >
            <ClipboardList class="w-4 h-4 mr-1.5" />
            Voir les commandes
          </NuxtLink>
        </div>

        <!-- Tables card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Tables</h2>
            <LayoutGrid class="h-5 w-5 text-kula-500" />
          </div>
          <p class="text-gray-500 mb-4">Gérez les tables et leur statut</p>
          <NuxtLink
            to="/staff/tables"
            class="inline-flex items-center px-4 py-2 bg-kula-500 text-white rounded-full text-sm font-medium hover:bg-kula-600 transition-colors"
          >
            <Table class="w-4 h-4 mr-1.5" />
            Voir les tables
          </NuxtLink>
        </div>

        <!-- Menu card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Menu</h2>
            <BookOpen class="h-5 w-5 text-kula-500" />
          </div>
          <p class="text-gray-500 mb-4">Consultez le menu de l'établissement</p>
          <NuxtLink
            to="/staff/menu"
            class="inline-flex items-center px-4 py-2 bg-kula-500 text-white rounded-full text-sm font-medium hover:bg-kula-600 transition-colors"
          >
            <UtensilsCrossed class="w-4 h-4 mr-1.5" />
            Voir le menu
          </NuxtLink>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { 
  User, 
  ChevronDown, 
  LogOut, 
  ShoppingCart, 
  ClipboardList, 
  LayoutGrid, 
  Table, 
  BookOpen, 
  UtensilsCrossed 
} from 'lucide-vue-next'
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/vue'
import { useCustomToast } from '~/composables/useToast'

const router = useRouter()
const { showToast } = useCustomToast()

const username = ref('')
const establishmentName = ref('')
const staffSession = ref(null)

// Check if logged in
const checkAuth = () => {
  const session = localStorage.getItem('staff_pin_session')
  if (!session) {
    router.push('/auth/pin')
    return false
  }
  
  try {
    const sessionData = JSON.parse(session)
    const loggedInTime = new Date(sessionData.logged_in_at).getTime()
    const now = new Date().getTime()
    
    // Session valid for 12 hours
    if ((now - loggedInTime) < 12 * 60 * 60 * 1000) {
      staffSession.value = sessionData
      username.value = sessionData.username
      establishmentName.value = sessionData.establishment_name
      return true
    } else {
      // Session expired
      localStorage.removeItem('staff_pin_session')
      router.push('/auth/pin')
      return false
    }
  } catch (e) {
    localStorage.removeItem('staff_pin_session')
    router.push('/auth/pin')
    return false
  }
}

// Handle logout
const handleLogout = () => {
  localStorage.removeItem('staff_pin_session')
  showToast.success('Succès', 'Déconnexion réussie')
  router.push('/auth/pin')
}

onMounted(() => {
  checkAuth()
})

definePageMeta({
  middleware: ['waiter-auth']
})
</script> 