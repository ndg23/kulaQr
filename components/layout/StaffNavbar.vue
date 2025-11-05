<template>
  <div>
    <!-- Header principal avec le nom de l'établissement -->
    <header class="bg-white/70 backdrop-blur-lg sticky top-0 z-50 border-b border-gray-100">
      <div class="max-w-4xl mx-auto px-4 py-4 sm:px-6 flex justify-between items-center">
        <div class="flex items-center">
          <img class="h-8 w-auto mr-3" src="~/assets/icon/logo.png" alt="Logo" />
          <h1 class="text-xl font-bold text-gray-900">
            {{ establishment.name || 'Chargement...' }}
          </h1>
        </div>
        <div class="flex items-center space-x-4">
          <!-- Indicateur de connexion en temps réel -->
          <!-- <span v-if="realtimeStatus === 'connected'" class="hidden sm:flex items-center text-sm text-green-600">
            <span class="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></span>
            En direct
          </span> -->
          
          <!-- Badge du rôle -->
          <!-- <span class="hidden sm:inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium" 
            :class="getRoleBadgeClass(staffSession.role)">
            {{ getRoleName(staffSession.role) }}
          </span> -->
          
          <!-- Menu utilisateur -->
          <div class="relative" ref="userMenuContainer">
            <button 
              @click="toggleUserMenu" 
              class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kula-500"
            >
              <div class="h-8 w-8 rounded-full bg-kula-100 flex items-center justify-center text-kula-600 font-medium">
                {{ staffSession.username ? staffSession.username.charAt(0).toUpperCase() : 'U' }}
              </div>
            </button>
            
            <!-- Menu déroulant -->
            <div v-if="userMenuOpen" 
              class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none z-40"
            >
              <div class="px-4 py-2 border-b border-gray-100">
                <p class="text-sm font-medium text-gray-900">{{ staffSession.username }}</p>
                <p class="text-xs text-gray-500">{{ getRoleName(staffSession.role) }}</p>
              </div>
              <button 
                @click="logout" 
                class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
              >
                Déconnexion
              </button>
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Navigation principale -->
    <!-- <nav class="bg-white border-b border-gray-100">
      <div class="max-w-5xl mx-auto px-4 sm:px-6">
        <div class="flex justify-between h-14">
          <div class="flex">
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <NuxtLink 
                to="/staff" 
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                :class="{ 'border-kula-500 text-gray-900': $route.path === '/staff' }"
                exact
              >
                <Home class="h-5 w-5 mr-1.5" />
                Accueil
              </NuxtLink>
              
              <NuxtLink 
                v-if="['waiter', 'manager'].includes(staffSession.role)"
                to="/staff/orders" 
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                :class="{ 'border-kula-500 text-gray-900': $route.path === '/staff/orders' }"
              >
                <ClipboardList class="h-5 w-5 mr-1.5" />
                Commandes
              </NuxtLink>
              
              <NuxtLink 
                v-if="['kitchen', 'manager'].includes(staffSession.role)"
                to="/staff/kitchen" 
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                :class="{ 'border-kula-500 text-gray-900': $route.path === '/staff/kitchen' }"
              >
                <Utensils class="h-5 w-5 mr-1.5" />
                Cuisine
              </NuxtLink>
              
              <NuxtLink 
                v-if="staffSession.role === 'manager'"
                :to="`/manager/${staffSession.establishment_id}/dashboard`" 
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                :class="{ 'border-kula-500 text-gray-900': $route.path.includes('/manager/') }"
              >
                <Settings class="h-5 w-5 mr-1.5" />
                Administration
              </NuxtLink>
            </div>
          </div>
          
          <div class="sm:hidden">
            <button 
              @click="mobileMenuOpen = !mobileMenuOpen" 
              class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-kula-500"
            >
              <span class="sr-only">Ouvrir le menu</span>
              <Menu v-if="!mobileMenuOpen" class="block h-6 w-6" />
              <X v-else class="block h-6 w-6" />
            </button>
          </div>
        </div>
      </div>
      
      <div v-if="mobileMenuOpen" class="sm:hidden">
        <div class="pt-2 pb-3 space-y-1">
          <NuxtLink 
            to="/staff" 
            class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 block pl-3 pr-4 py-2 border-l-4 border-transparent text-base font-medium"
            :class="{ 'bg-kula-50 border-kula-500 text-kula-700': $route.path === '/staff' }"
            @click="mobileMenuOpen = false"
            exact
          >
            Accueil
          </NuxtLink>
          
          <NuxtLink 
            v-if="['waiter', 'manager'].includes(staffSession.role)"
            to="/staff/orders" 
            class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 block pl-3 pr-4 py-2 border-l-4 border-transparent text-base font-medium"
            :class="{ 'bg-kula-50 border-kula-500 text-kula-700': $route.path === '/staff/orders' }"
            @click="mobileMenuOpen = false"
          >
            Commandes
          </NuxtLink>
          
          <NuxtLink 
            v-if="['kitchen', 'manager'].includes(staffSession.role)"
            to="/staff/kitchen" 
            class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 block pl-3 pr-4 py-2 border-l-4 border-transparent text-base font-medium"
            :class="{ 'bg-kula-50 border-kula-500 text-kula-700': $route.path === '/staff/kitchen' }"
            @click="mobileMenuOpen = false"
          >
            Cuisine
          </NuxtLink>
          
          <NuxtLink 
            v-if="staffSession.role === 'manager'"
            :to="`/manager/${staffSession.establishment_id}/dashboard`" 
            class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 block pl-3 pr-4 py-2 border-l-4 border-transparent text-base font-medium"
            :class="{ 'bg-kula-50 border-kula-500 text-kula-700': $route.path.includes('/manager/') }"
            @click="mobileMenuOpen = false"
          >
            Administration
          </NuxtLink>
        </div>
      </div>
    </nav> -->
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { 
  LogOut, Home, ClipboardList, Utensils, 
  Settings, Menu, X, User
} from 'lucide-vue-next'

const router = useRouter()
const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()

// État
const staffSession = ref({})
const establishment = ref({})
const userMenuOpen = ref(false)
const mobileMenuOpen = ref(false)
const userMenuContainer = ref(null)
const realtimeStatus = ref('disconnected')

// Charger les données de session
onMounted(async () => {
  // Charger la session
  const session = localStorage.getItem('staff_session')
  if (session) {
    staffSession.value = JSON.parse(session)
    await loadEstablishmentData()
  }
  
  // Fermer le menu utilisateur lors d'un clic à l'extérieur
  document.addEventListener('click', handleClickOutside)
  
  // Configurer la connexion en temps réel
  setupRealtimeConnection()
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

// Charger les données de l'établissement
const loadEstablishmentData = async () => {
  if (!staffSession.value.establishment_id) return
  
  try {
    const { data, error } = await supabase
      .from('establishments')
      .select('name')
      .eq('id', staffSession.value.establishment_id)
      .single()
    
    if (error) throw error
    
    establishment.value = data
  } catch (err) {
    console.error('Erreur lors du chargement des données de l\'établissement:', err)
  }
}

// Configurer la connexion en temps réel
const setupRealtimeConnection = () => {
  const channel = supabase.channel('staff-realtime')
  
  channel
    .on('system', { event: 'presence_state' }, () => {
      realtimeStatus.value = 'connected'
    })
    .subscribe((status) => {
      if (status === 'SUBSCRIBED') {
        realtimeStatus.value = 'connected'
      } else {
        realtimeStatus.value = 'disconnected'
      }
    })
}

// Gérer les clics à l'extérieur du menu utilisateur
const handleClickOutside = (event) => {
  if (userMenuContainer.value && !userMenuContainer.value.contains(event.target)) {
    userMenuOpen.value = false
  }
}

// Basculer l'état du menu utilisateur
const toggleUserMenu = () => {
  userMenuOpen.value = !userMenuOpen.value
}

// Obtenir le nom du rôle
const getRoleName = (role) => {
  const roles = {
    waiter: 'Serveur',
    kitchen: 'Cuisine',
    manager: 'Manager',
    admin: 'Administrateur'
  }
  return roles[role] || role
}

// Obtenir la classe CSS pour le badge de rôle
const getRoleBadgeClass = (role) => {
  const classes = {
    waiter: 'bg-blue-100 text-blue-800',
    kitchen: 'bg-yellow-100 text-yellow-800',
    manager: 'bg-purple-100 text-purple-800',
    admin: 'bg-red-100 text-red-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

// Déconnexion
const logout = async () => {
  try {
    // Enregistrer l'activité de déconnexion si la fonction existe
    if (staffSession.value && staffSession.value.staff_id) {
      try {
        await supabase.rpc('close_staff_session', {
          p_staff_id: staffSession.value.staff_id,
          p_reason: 'manual_logout'
        })
      } catch (e) {
        // Fallback si la fonction RPC n'existe pas
        await supabase.from('staff_activity_logs').insert({
          staff_id: staffSession.value.staff_id,
          establishment_id: staffSession.value.establishment_id,
          action: 'logout',
          details: { method: 'manual' },
          user_agent: navigator.userAgent
        }).catch(err => console.error('Erreur lors de l\'enregistrement de l\'activité:', err))
      }
    }
  } catch (e) {
    console.error('Erreur lors de la déconnexion:', e)
  } finally {
    // Supprimer la session
    localStorage.removeItem('staff_session')
    showToast.success('Déconnexion réussie', 'À bientôt !')
    router.push('/auth/pin')
  }
}
</script>

<style scoped>
.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
</style> 