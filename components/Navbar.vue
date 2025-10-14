<template>
  <nav class="fixed top-0 left-0 right-0 z-40 bg-white/80 backdrop-blur-xl border-b border-gray-100/50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <div class="flex items-center">
          <NuxtLink to="/" class="flex items-center space-x-2 group">
            <div class="w-8 h-8 bg-black rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform duration-200">
              <span class="text-white text-sm font-bold">KQ</span>
            </div>
            <span class="text-xl font-semibold text-gray-900 group-hover:text-gray-700 transition-colors">
              KulaQr
            </span>
          </NuxtLink>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-8">
          <a href="#features" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Fonctionnalités
          </a>
          <a href="#pricing" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Tarifs
          </a>
          <a href="#testimonials" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Témoignages
          </a>
          <a href="#contact" class="text-gray-600 hover:text-gray-900 transition-colors font-medium">
            Contact
          </a>
        </div>

        <!-- Desktop CTA Buttons / User Menu -->
        <div class="hidden md:flex items-center space-x-4">
        <!-- Si utilisateur connecté -->
        <div v-if="user" class="flex items-center space-x-4">
          <!-- Debug info -->
          <!-- <div class="text-xs text-gray-500">
            User: {{ user ? 'Yes' : 'No' }} | Role: {{ userRole }}
          </div> -->
            <!-- Notifications (optionnel) -->
            <button class="text-gray-600 hover:text-gray-900 transition-colors p-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4 19h6v-6H4v6zM4 5h6V1H4v4zM15 3h5l-5-5v5z"/>
              </svg>
            </button>
            
            <!-- User Dropdown -->
            <div class="relative" ref="userDropdown">
              <button 
                @click="toggleUserMenu"
                class="flex items-center space-x-2 text-gray-700 hover:text-gray-900 transition-colors"
              >
                <!-- Avatar -->
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-white font-medium text-sm"
                     :class="userRole === 'admin' ? 'bg-red-500' : 'bg-blue-500'">
                  {{ userInitials }}
                </div>
                <!-- Nom utilisateur -->
                  <span class="font-medium">{{ user.full_name || '' }}</span>
                <!-- Chevron -->
                <svg class="w-4 h-4 transition-transform" :class="{ 'rotate-180': userMenuOpen }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>
              
              <!-- Dropdown Menu -->
              <div v-if="userMenuOpen" class="absolute right-0 mt-2 w-56 bg-white rounded-lg shadow-xl border border-gray-200 py-2 z-[100] transform transition-all duration-200 ease-in-out">
                <!-- User Info -->
                <div class="px-4 py-3 border-b border-gray-100">
                  <p class="text-sm font-medium text-gray-900">{{ user.full_name || 'Utilisateur' }}</p>
                  <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mt-1"
                        :class="userRole === 'admin' ? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800'">
                    {{ userRole === 'admin' ? 'Administrateur' : 'Propriétaire' }}
                  </span>
                </div>
                
                <!-- Menu Items -->
                <div class="py-1">
                  <!-- Dashboard selon le rôle -->
                  <NuxtLink 
                    :to="userRole === 'admin' ? '/admin' : '/manager/'+user.establishment_id"
                    @click="userMenuOpen = false"
                    class="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
                    </svg>
                    {{ userRole === 'admin' ? 'Dashboard Admin' : 'Mon Dashboard' }}
                  </NuxtLink>
                  
                  <!-- Profil -->
                  <NuxtLink 
                    :to="userRole === 'admin' ? '/admin/users/' + user.id : '/manager/'+user.establishment_id+'/settings'"
                    @click="userMenuOpen = false"
                    class="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                    Mon Profil
                  </NuxtLink>
                  
                  <!-- Paramètres -->
                  <NuxtLink 
                    :to="userRole === 'admin' ? '/admin/settings' : '/manager/'+user.establishment_id+'/settings'"
                    @click="userMenuOpen = false"
                    class="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    </svg>
                    Paramètres
                  </NuxtLink>
                  
                  <!-- Séparateur -->
                  <div class="border-t border-gray-100 my-1"></div>
                  
                  <!-- Déconnexion -->
                  <button 
                    @click="handleLogout"
                    :disabled="isLoggingOut"
                    class="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <svg v-if="!isLoggingOut" class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                    <svg v-else class="w-4 h-4 mr-3 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    {{ isLoggingOut ? 'Déconnexion...' : 'Se déconnecter' }}
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Si utilisateur non connecté -->
          <template v-else>
            <NuxtLink 
              to="/auth/login" 
              class="text-gray-600 hover:text-gray-900 transition-colors font-medium"
            >
              Se connecter
            </NuxtLink>
            <NuxtLink 
              to="/auth/register"
              class="bg-black text-white px-6 py-2 rounded-full font-medium hover:bg-gray-800 transition-colors shadow-sm hover:shadow-md"
            >
              Commencer
            </NuxtLink>
          </template>
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden">
          <button 
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="text-gray-600 hover:text-gray-900 transition-colors p-2"
          >
            <svg v-if="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
            <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile Navigation Menu -->
      <div v-if="mobileMenuOpen" class="md:hidden border-t border-gray-100 bg-white/95 backdrop-blur-xl">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <a href="#features" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Fonctionnalités
          </a>
          <a href="#pricing" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Tarifs
          </a>
          <a href="#testimonials" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Témoignages
          </a>
          <a href="#contact" @click="mobileMenuOpen = false" class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors">
            Contact
          </a>
          <div class="border-t border-gray-100 pt-4 mt-4">
            <!-- Si utilisateur connecté (mobile) -->
            <div v-if="user" class="space-y-2">
              <!-- User Info -->
              <div class="px-3 py-2 bg-gray-50 rounded-md">
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 rounded-full flex items-center justify-center text-white font-medium text-sm"
                       :class="userRole === 'admin' ? 'bg-red-500' : 'bg-blue-500'">
                    {{ userInitials }}
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ user.full_name || 'Utilisateur' }}</p>
                  </div>
                </div>
              </div>
              
              <!-- Mobile Menu Items -->
              <NuxtLink 
                :to="userRole === 'admin' ? '/admin' : '/manager/'+user.establishment_id"
                @click="mobileMenuOpen = false"
                class="flex items-center px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
              >
                <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
                </svg>
                {{ userRole === 'admin' ? 'Dashboard Admin' : 'Mon Dashboard' }}
              </NuxtLink>
              
              <NuxtLink 
                :to="userRole === 'admin' ? '/admin/users/' + user.id : '/manager/'+user.establishment_id+'/settings'"
                @click="mobileMenuOpen = false"
                class="flex items-center px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
              >
                <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
                Mon Profil
              </NuxtLink>
              
              <button 
                @click="handleLogout"
                :disabled="isLoggingOut"
                class="flex items-center w-full px-3 py-2 text-red-600 hover:bg-red-50 rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <svg v-if="!isLoggingOut" class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                </svg>
                <svg v-else class="w-4 h-4 mr-3 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                </svg>
                {{ isLoggingOut ? 'Déconnexion...' : 'Se déconnecter' }}
              </button>
            </div>
            
            <!-- Si utilisateur non connecté (mobile) -->
            <template v-else>
              <NuxtLink 
                to="/auth/login" 
                @click="mobileMenuOpen = false"
                class="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
              >
                Se connecter
              </NuxtLink>
              <NuxtLink 
                to="/auth/register"
                @click="mobileMenuOpen = false"
                class="block mx-3 mt-2 bg-black text-white px-4 py-2 rounded-full font-medium hover:bg-gray-800 transition-colors text-center"
              >
                Commencer
              </NuxtLink>
            </template>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <!-- Logout Confirmation Modal -->
  <div v-if="showLogoutConfirm" class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cancelLogout"></div>

      <!-- Modal panel -->
      <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
          <div class="sm:flex sm:items-start">
            <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
              <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              </svg>
            </div>
            <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Confirmer la déconnexion
              </h3>
              <div class="mt-2">
                <p class="text-sm text-gray-500">
                  Êtes-vous sûr de vouloir vous déconnecter ? Vous devrez vous reconnecter pour accéder à votre compte.
                </p>
              </div>
            </div>
          </div>
        </div>
        <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
          <button
            @click="confirmLogout"
            :disabled="isLoggingOut"
            class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isLoggingOut ? 'Déconnexion...' : 'Se déconnecter' }}
          </button>
          <button
            @click="cancelLogout"
            :disabled="isLoggingOut"
            class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Annuler
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface User {
  id: string
  full_name: string | null
  role: string
  establishment_id?: string
  establishment_slug?: string
}

const supabase = useSupabaseClient()
const router = useRouter()

// Mobile menu state
const mobileMenuOpen = ref(false)
const userMenuOpen = ref(false)

// User state
const user = ref<User | null>(null)
const userRole = ref('owner')
const userInitials = ref('')

// Logout state
const isLoggingOut = ref(false)
const showLogoutConfirm = ref(false)

// Computed properties
const userDropdown = ref<HTMLElement | null>(null)

// Get user initials
const getUserInitials = (name: string | null) => {
  if (name) {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
  }
  return 'U' // Fallback pour utilisateur sans nom
}

// Toggle user menu
const toggleUserMenu = () => {
  console.log('🔄 Toggle user menu:', !userMenuOpen.value)
  userMenuOpen.value = !userMenuOpen.value
}

// Handle logout
const handleLogout = async () => {
  showLogoutConfirm.value = true
}

// Confirm logout
const confirmLogout = async () => {
  isLoggingOut.value = true
  showLogoutConfirm.value = false
  
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    // Reset user state
    user.value = null
    userRole.value = 'owner'
    userInitials.value = ''
    
    // Close menus
    userMenuOpen.value = false
    mobileMenuOpen.value = false
    
    // Redirect to home
    await router.push('/')
  } catch (error) {
    console.error('Erreur lors de la déconnexion:', error)
    // Afficher un toast d'erreur si vous en avez un
  } finally {
    isLoggingOut.value = false
  }
}

// Cancel logout
const cancelLogout = () => {
  showLogoutConfirm.value = false
}

// Fetch user data
const fetchUserData = async () => {
  try {
    const { data: { user: authUser } } = await supabase.auth.getUser()
    console.log('🔍 Auth user:', authUser)
    
    if (authUser) {
      // Get user data from our users table
      const { data: userData, error } = await supabase
        .from('users')
        .select('id, full_name, role')
        .eq('id', authUser.id)
        .single()
      
      if (userData && !error) {
        const userInfo = userData as any
        
        // Récupérer l'établissement de l'utilisateur
        const { data: establishment, error: establishmentError } = await supabase
          .from('establishments')
          .select('id, slug')
          .eq('user_id', userInfo.id)
          .single()
        
        user.value = {
          id: userInfo.id,
          full_name: userInfo.full_name || '',
          role: userInfo.role || 'owner',
          establishment_id: (establishment as any)?.id,
          establishment_slug: (establishment as any)?.slug
        }
        userRole.value = userInfo.role || 'owner'
        userInitials.value = getUserInitials(userInfo.full_name)
        console.log('✅ User data loaded:', user.value)
      } else {
        // Fallback to auth user data
        // Récupérer l'établissement de l'utilisateur
        const { data: establishment, error: establishmentError } = await supabase
          .from('establishments')
          .select('id, slug')
          .eq('user_id', authUser.id)
          .single()
        
        user.value = {
          id: authUser.id,
          full_name: authUser.user_metadata?.full_name || '',
          role: 'owner',
          establishment_id: (establishment as any)?.id,
          establishment_slug: (establishment as any)?.slug
        }
        userRole.value = 'owner'
        userInitials.value = getUserInitials(user.value?.full_name)
      }
    }
  } catch (error) {
    console.error('Erreur lors de la récupération des données utilisateur:', error)
  }
}

// Listen to auth state changes
onMounted(() => {
  // Initial fetch
  fetchUserData()
  
  // Listen to auth changes
  const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN' && session) {
      fetchUserData()
    } else if (event === 'SIGNED_OUT') {
      user.value = null
      userRole.value = 'owner'
      userInitials.value = ''
    }
  })
  
  // Close mobile menu when clicking outside
  const handleClickOutside = (event: Event) => {
    const target = event.target as HTMLElement
    
    // Close mobile menu
    if (mobileMenuOpen.value && !target.closest('nav')) {
      mobileMenuOpen.value = false
    }
    
    // Close user menu
    if (userMenuOpen.value && userDropdown.value && !userDropdown.value.contains(target)) {
      console.log('🔄 Closing user menu - clicked outside')
      userMenuOpen.value = false
    }
  }
  
  document.addEventListener('click', handleClickOutside)
  
  onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside)
    subscription.unsubscribe()
  })
})
</script>

<style scoped>
/* Smooth scrolling for anchor links */
a[href^="#"] {
  scroll-behavior: smooth;
}
</style>
