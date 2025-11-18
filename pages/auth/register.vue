<template>
  <div class="min-h-screen  flex items-center justify-center p-4">
    <div class="w-full max-w-[480px]">
      <!-- Progress Indicator - Simplified -->
      <div class="mb-6">
        <div class="flex items-center justify-center gap-2">
          <div 
            class="h-1.5 rounded-full transition-all duration-500"
            :class="step === 1 ? 'w-8 bg-kula-500' : 'w-1.5 bg-gray-300'"
          ></div>
          <div 
            class="h-1.5 rounded-full transition-all duration-500"
            :class="step === 2 ? 'w-8 bg-kula-500' : 'w-1.5 bg-gray-300'"
          ></div>
        </div>
      </div>

      <!-- Step 1: User Info -->
      <transition
        enter-active-class="transition-all duration-500 ease-out"
        enter-from-class="opacity-0 translate-y-8"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition-all duration-500 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-8"
        mode="out-in"
      >
        <div v-if="step === 1" class="space-y-10 pb-10">
          <!-- Header -->
          <div class="text-center space-y-3">
            <h1 class="text-3xl md:text-5xl font-black tracking-tight text-gray-900">
              Bienvenue
            </h1>
            <p class="text-lg text-gray-500 font-light">
              Créez votre compte en quelques instants
            </p>
          </div>

          <!-- Google Sign Up -->
          <button 
            @click="signInWithGoogle"
            type="button"
            class="group w-full h-14 bg-white border border-gray-200 rounded-2xl font-medium flex items-center justify-center hover:border-gray-300 hover:shadow-sm transition-all duration-200"
          >
            <svg class="w-5 h-5 mr-3" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            <span class="text-gray-700 group-hover:text-gray-900 transition-colors">
              Continuer avec Google
            </span>
          </button>

          <!-- Divider -->
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-200"></div>
            </div>
            <div class="relative flex justify-center">
              <span class="px-4 bg-gradient-to-b from-white to-gray-50 text-sm text-gray-400">ou</span>
            </div>
          </div>

          <!-- Form -->
          <form @submit.prevent="nextStep" class="space-y-5 justify-center items-center">
            <!-- Full Name Float Input -->
            <div class="relative">
              <input
                v-model="form.fullName"
                type="text"
                id="fullName"
                required
                class="peer w-full h-14 px-4 pt-6 pb-2 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200"
                :class="{ 'border-red-300 focus:border-red-500 focus:ring-red-500/10': errors.fullName }"
                placeholder=" "
              />
              <label
                for="fullName"
                class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                       peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                       peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
              >
                Nom complet
              </label>
              <p v-if="errors.fullName" class="text-sm text-red-500 mt-1 px-2">{{ errors.fullName }}</p>
            </div>

            <!-- Email Float Input -->
            <div class="relative">
              <input
                v-model="form.email"
                type="email"
                id="email"
                required
                class="peer w-full h-14 px-4 pt-6 pb-2 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200"
                :class="{ 'border-red-300 focus:border-red-500 focus:ring-red-500/10': errors.email }"
                placeholder=" "
              />
              <label
                for="email"
                class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                       peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                       peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
              >
                Adresse email
              </label>
              <p v-if="errors.email" class="text-sm text-red-500 mt-1 px-2">{{ errors.email }}</p>
            </div>

            <!-- Password Float Input -->
            <div class="relative">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                id="password"
                minlength="6"
                required
                class="peer w-full h-14 px-4 pt-6 pb-2 pr-12 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200"
                :class="{ 'border-red-300 focus:border-red-500 focus:ring-red-500/10': errors.password }"
                placeholder=" "
              />
              <label
                for="password"
                class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                       peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                       peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
              >
                Mot de passe
              </label>
              <button 
                type="button"
                @click="showPassword = !showPassword"
                class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Eye v-if="showPassword" class="w-5 h-5" />
                <EyeOff v-else class="w-5 h-5" />
              </button>
              <p v-if="errors.password" class="text-sm text-red-500 mt-1 px-2">{{ errors.password }}</p>
            </div>

            <button
              type="submit"
            class="group mx-auto  inline-flex items-center px-12 py-6 bg-kula-500 text-white rounded-full text-xl font-bold hover:bg-kula-600 transition-all duration-200"
              :disabled="loading"
            >
              <span v-if="!loading" class="flex items-center">
                <span>Continuer</span>
                <ArrowRight class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
              </span>
              <span v-else class="flex items-center">
                <Loader2 class="w-5 h-5 animate-spin" />
              </span>
            </button>
          </form>

          <!-- Sign In Link -->
          <div class="text-center pt-4">
            <p class="text-sm text-gray-500">
              Vous avez déjà un compte ?
              <NuxtLink to="/auth/login" class="text-kula-500 font-medium hover:text-kula-600 transition-colors ml-1">
                Se connecter
              </NuxtLink>
            </p>
          </div>
        </div>

        <!-- Step 2: Restaurant Info -->
        <div v-else class="space-y-10">
          <!-- Header -->
          <div class="text-center space-y-3">
            <h1 class="text-5xl font-semibold tracking-tight text-gray-900">
              Votre établissement
            </h1>
            <p class="text-lg text-gray-500 font-light">
              Dernière étape avant de commencer
            </p>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleRegister" class="space-y-5">
            <!-- Restaurant Name Float Input -->
            <div class="relative">
              <input
                v-model="form.restaurantName"
                type="text"
                id="restaurantName"
                required
                class="peer w-full h-14 px-4 pt-6 pb-2 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200"
                :class="{ 'border-red-300 focus:border-red-500 focus:ring-red-500/10': errors.restaurantName }"
                placeholder=" "
              />
              <label
                for="restaurantName"
                class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                       peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                       peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
              >
                Nom de l'établissement
              </label>
              <p v-if="errors.restaurantName" class="text-sm text-red-500 mt-1 px-2">{{ errors.restaurantName }}</p>
            </div>

            <!-- Type Select Float -->
            <div class="relative">
              <select
                v-model="form.type"
                id="type"
                required
                class="peer w-full h-14 px-4 pt-6 pb-2 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200 appearance-none bg-no-repeat"
                :class="{ 
                  'border-red-300 focus:border-red-500 focus:ring-red-500/10': errors.type,
                  'text-gray-900': form.type,
                  'text-transparent': !form.type
                }"
                style="background-image: url('data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2716%27 height=%2716%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23999%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3E%3Cpath d=%27M6 9l6 6 6-6%27/%3E%3C/svg%3E'); background-position: right 1.25rem center; background-size: 1.25em;"
              >
                <option value="" disabled selected></option>
                <option v-for="type in establishmentTypes" :key="type.id" :value="type.id">
                  {{ type.name }}
                </option>
              </select>
              <label
                for="type"
                class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                       peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500"
                :class="form.type ? 'top-3 text-xs text-gray-500' : ''"
              >
                Type d'établissement
              </label>
              <p v-if="errors.type" class="text-sm text-red-500 mt-1 px-2">{{ errors.type }}</p>
            </div>

            <!-- Address Float Input with Geolocation -->
            <div class="space-y-3">
              <div class="relative">
                <input
                  v-model="form.address"
                  type="text"
                  id="address"
                  class="peer w-full h-14 px-4 pt-6 pb-2 pr-12 bg-white border border-gray-200 rounded-2xl text-base focus:outline-none focus:border-kula-500 focus:ring-1 focus:ring-kula-500/10 transition-all duration-200"
                  placeholder=" "
                />
                <label
                  for="address"
                  class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 transition-all duration-200 pointer-events-none
                         peer-focus:top-3 peer-focus:text-xs peer-focus:text-kula-500
                         peer-[:not(:placeholder-shown)]:top-3 peer-[:not(:placeholder-shown)]:text-xs peer-[:not(:placeholder-shown)]:text-gray-500"
                >
                  Adresse (optionnel)
                </label>
                
                <!-- Geolocation button -->
                <button
                  type="button"
                  @click="showLocationSheet = true"
                  class="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-kula-500  hover:bg-kula-50 rounded-full transition-all duration-200"
                  title="Utiliser ma position actuelle"
                >
                  <MapPin class="w-7 h-7 " />
                </button>
              </div>
              
              <!-- Helper text -->
              <p class="text-sm text-gray-500 px-2 flex items-center gap-2">
                <MapPin class="w-4 h-4" />
                <span>Cliquez sur l'icône pour localiser votre établissement</span>
              </p>
            </div>

            <!-- Buttons -->
            <div class="flex gap-3 pt-2">
              <button
                type="button"
                @click="step = 1"
                class="w-24 h-14 bg-gray-100 text-gray-700 rounded-3xl font-medium hover:bg-gray-200 active:scale-[0.98] transition-all duration-200 flex items-center justify-center"
              >
                <ArrowLeft class="w-5 h-5" />
              </button>

              <button
                type="submit"
            class="group inline-flex items-center px-12 py-6 bg-kula-500 text-white rounded-full text-xl font-bold hover:bg-kula-600 transition-all duration-200"
                :disabled="loading"
              >
                <span v-if="!loading">Créer mon compte</span>
                <span v-else class="flex items-center">
                  <Loader2 class="w-5 h-5 animate-spin mr-2" />
                  Création...
                </span>
              </button>
            </div>
          </form>
        </div>
      </transition>

      <!-- Footer -->
      <div class="mt-12 text-center space-y-4">
        <p class="text-xs text-gray-400 leading-relaxed">
          En continuant, vous acceptez nos
          <NuxtLink to="/terms" class="text-red-500 hover:text-gray-700 transition-colors">Conditions</NuxtLink>
          et notre
          <NuxtLink to="/privacy" class="text-red-500 hover:text-gray-700 transition-colors">Politique de confidentialité</NuxtLink>
        </p>
      </div>
    </div>

    <!-- Location Bottom Sheet -->
    <transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div 
        v-if="showLocationSheet" 
        class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-end sm:items-center sm:justify-center"
        @click.self="showLocationSheet = false"
      >
        <transition
          enter-active-class="transition-all duration-300 ease-out"
          enter-from-class="translate-y-full sm:translate-y-0 sm:scale-95 opacity-0"
          enter-to-class="translate-y-0 sm:scale-100 opacity-100"
          leave-active-class="transition-all duration-200 ease-in"
          leave-from-class="translate-y-0 sm:scale-100 opacity-100"
          leave-to-class="translate-y-full sm:translate-y-0 sm:scale-95 opacity-0"
        >
          <div 
            v-if="showLocationSheet"
            class="w-full sm:w-[90%] sm:max-w-2xl bg-white rounded-t-3xl sm:rounded-3xl shadow-2xl max-h-[85vh] flex flex-col"
          >
            <!-- Header -->
            <div class="flex items-center justify-between p-6 border-b border-gray-100">
              <div>
                <h3 class="text-xl font-bold text-gray-900">Localisation</h3>
                <p class="text-sm text-gray-500 mt-1">Où se trouve votre établissement ?</p>
              </div>
              <button
                @click="showLocationSheet = false"
                class="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <svg class="w-6 h-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>

            <!-- Map Container -->
            <div class="flex-1 bg-gray-100 relative overflow-hidden">
              <div id="map" class="w-full h-full min-h-[400px]"></div>
              
              <!-- Center marker -->
              <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full pointer-events-none z-[1000]">
                <MapPin class="w-10 h-10 text-kula-500 drop-shadow-lg" :fill="'currentColor'" />
              </div>
              
              <!-- Loading overlay -->
              <div v-if="loadingLocation" class="absolute inset-0 bg-white/80 backdrop-blur-sm flex items-center justify-center z-[1001]">
                <div class="text-center">
                  <Loader2 class="w-12 h-12 text-kula-500 animate-spin mx-auto mb-3" />
                  <p class="text-gray-600 font-medium">Localisation en cours...</p>
                </div>
              </div>
            </div>

            <!-- Address Display & Actions -->
            <div class="p-6 space-y-4 border-t border-gray-100">
              <!-- Selected Address -->
              <div v-if="selectedAddress" class="p-4 bg-gray-50 rounded-2xl">
                <p class="text-sm text-gray-500 mb-1">Adresse sélectionnée</p>
                <p class="text-gray-900 font-medium">{{ selectedAddress }}</p>
              </div>

              <!-- Actions -->
              <div class="flex flex-col sm:flex-row gap-3">
                <button
                  @click="getCurrentLocation"
                  :disabled="loadingLocation"
                  class="flex-1 h-14 bg-gray-100 text-gray-700 rounded-2xl font-semibold hover:bg-gray-200 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  <Loader2 v-if="loadingLocation" class="w-5 h-5 animate-spin" />
                  <Navigation v-else class="w-5 h-5" />
                  <span>{{ loadingLocation ? 'Localisation...' : 'Ma position actuelle' }}</span>
                </button>
                
                <button
                  @click="confirmLocation"
                  :disabled="!selectedAddress"
                  class="flex-1 h-14 bg-gradient-to-r from-kula-500 to-red-500 text-white rounded-2xl font-bold hover:shadow-lg transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Check class="w-5 h-5" />
                  <span>Confirmer cette adresse</span>
                </button>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { Eye, EyeOff, Loader2, ArrowRight, ArrowLeft, MapPin, Navigation, Check } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const showPassword = ref(false)
const loading = ref(false)
const loadingLocation = ref(false)
const showLocationSheet = ref(false)
const selectedAddress = ref('')
const error = ref('')

let map: any = null
let mapInitialized = false

const form = reactive({
  email: '',
  fullName: '',
  password: '',
  restaurantName: '',
  type: null as number | null,
  address: '',
  phone: '',
  latitude: null as number | null,
  longitude: null as number | null,
})

const errors = reactive({
  email: '',
  fullName: '',
  password: '',
  restaurantName: '',
  type: '',
  address: '',
  phone: '',
})

const { client: supabase } = useSupabaseWrapper()
const router = useRouter()
const { showToast } = useCustomToast()

const { data: establishmentTypes } = await supabase
  .from('establishment_types')
  .select('*')
  .eq('is_active', true)
  .order('name')

const selectedType = computed(() => 
  establishmentTypes?.find((type: any) => type.id === form.type)
)

const route = useRoute()
const step = ref(1)

// Initialize map when bottom sheet opens
watch(showLocationSheet, async (isOpen) => {
  if (isOpen && !mapInitialized) {
    await nextTick()
    initMap()
  }
})

// Initialize Leaflet map
const initMap = async () => {
  try {
    // Dynamically import Leaflet
    const L = (await import('leaflet')).default
    
    // Default center (Dakar, Senegal)
    const defaultCenter: [number, number] = [14.6928, -17.4467]
    
    map = L.map('map', {
      center: defaultCenter,
      zoom: 13,
      zoomControl: true,
      attributionControl: false
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
    }).addTo(map)

    // Get address on map move
    map.on('moveend', async () => {
      const center = map.getCenter()
      await reverseGeocode(center.lat, center.lng)
    })

    mapInitialized = true

    // Try to get current position
    if (navigator.geolocation) {
      getCurrentLocation()
    } else {
      await reverseGeocode(defaultCenter[0], defaultCenter[1])
    }
  } catch (error) {
    console.error('Error initializing map:', error)
    showToast.error('Erreur', 'Impossible de charger la carte')
  }
}

// Reverse geocode coordinates to address
const reverseGeocode = async (lat: number, lng: number) => {
  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=fr`
    )
    
    if (!response.ok) throw new Error('Geocoding failed')
    
    const data = await response.json()
    
    // Format court : Rue + Quartier uniquement
    const addr = data.address || {}
    const parts = []
    
    // Rue avec numéro (ex: "RUE 469, 12" ou "Avenue Bourguiba")
    if (addr.road) {
      parts.push(addr.road)
    } else if (addr.street) {
      parts.push(addr.street)
    }
    
    // Quartier/Suburb
    if (addr.suburb || addr.neighbourhood) {
      parts.push(addr.suburb || addr.neighbourhood)
    }
    
    // Ville si pas de quartier
    if (parts.length === 1 && addr.city) {
      parts.push(addr.city)
    }
    
    // Format final court
    selectedAddress.value = parts.length > 0 
      ? parts.join(', ')
      : data.display_name || `${lat}, ${lng}`
    
    // Store coordinates
    form.latitude = lat
    form.longitude = lng
  } catch (error) {
    console.error('Reverse geocoding error:', error)
    selectedAddress.value = `${lat.toFixed(6)}, ${lng.toFixed(6)}`
    form.latitude = lat
    form.longitude = lng
  }
}

// Récupérer la localisation actuelle
const getCurrentLocation = async () => {
  if (!navigator.geolocation) {
    showToast.error('Géolocalisation non disponible', 'Votre navigateur ne supporte pas la géolocalisation')
    return
  }

  loadingLocation.value = true

  navigator.geolocation.getCurrentPosition(
    async (position) => {
      try {
        const { latitude, longitude } = position.coords
        
        if (map) {
          const L = (await import('leaflet')).default
          map.setView([latitude, longitude], 16)
        }
        
        await reverseGeocode(latitude, longitude)
        showToast.success('Position trouvée !', 'Vous pouvez ajuster la carte si nécessaire')
      } catch (error) {
        console.error('Erreur géocodage:', error)
        // showToast.error('Erreur', 'Impossible de récupérer l\'adresse')
          const code = error.code
    loadingLocation.value = false
    if (code === 1) {
      showToast.error('Géolocalisation', 'Vous devez autoriser l’accès à votre position')
    } else if (code === 2) {
      showToast.error('Géolocalisation', 'Position indisponible')
    } else if (code === 3) {
      showToast.error('Géolocalisation', 'Délai dépassé. Réessayez.')
    } else {
      showToast.error('Géolocalisation', 'Impossible de récupérer la position')
    }
      } finally {
        loadingLocation.value = false
      }
    },
    (error) => {
      loadingLocation.value = false
      
      let message = 'Impossible d\'accéder à votre position'
      if (error.code === error.PERMISSION_DENIED) {
        message = 'Vous devez autoriser l\'accès à votre position'
      } else if (error.code === error.POSITION_UNAVAILABLE) {
        message = 'Position indisponible'
      } else if (error.code === error.TIMEOUT) {
        message = 'Délai d\'attente dépassé'
      }
      
      showToast.error('Géolocalisation', message)
    },
    {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0
    }
  )
}

// Confirm selected location
const confirmLocation = () => {
  if (selectedAddress.value) {
    form.address = selectedAddress.value
    showLocationSheet.value = false
    showToast.success('Adresse confirmée !', 'Vous pouvez la modifier si besoin')
  }
}

// Récupérer les données du callback si présentes
onMounted(() => {
  const stepParam = route.query.step
  const dataParam = route.query.data
  
  if (stepParam === '2' && dataParam) {
    try {
      const userData = JSON.parse(atob(dataParam as string))
      form.email = userData.email
      form.fullName = userData.fullName
      step.value = 2
    } catch (error) {
      console.error('❌ Erreur décodage données utilisateur:', error)
    }
  }
})

const handleRegister = async () => {
  let hasErrors = false
  
  if (!form.type) {
    errors.type = 'Veuillez sélectionner un type d\'établissement'
    hasErrors = true
  }
  
  if (!form.restaurantName || form.restaurantName.trim() === '') {
    errors.restaurantName = 'Le nom de l\'établissement est obligatoire'
    hasErrors = true
  }
  
  if (!form.fullName || form.fullName.trim() === '') {
    errors.fullName = 'Le nom complet est obligatoire'
    hasErrors = true
  }
  
  if (!form.email || form.email.trim() === '') {
    errors.email = 'L\'email est obligatoire'
    hasErrors = true
  }
  
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  const isAlreadyAuthenticated = !!currentUser
  
  if (!isAlreadyAuthenticated) {
    if (!form.password || form.password.length < 6) {
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères'
      hasErrors = true
    }
  }

  if (hasErrors) {
    return
  }
  
  loading.value = true
  error.value = ''
  
  try {
    let userId = currentUser?.id
    
    if (!isAlreadyAuthenticated) {
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: form.email,
        password: form.password,
        options: {
          data: {
            full_name: form.fullName,
            role: 'owner'
          },
          emailRedirectTo: `${window.location.origin}/auth/callback`
        }
      })
      
      if (authError) {
        errors.email = authError.message === 'User already registered'
          ? 'Cette adresse email est déjà utilisée'
          : 'Une erreur est survenue lors de l\'inscription'
        return
      }

      if (!authData.user?.id) {
        throw new Error('User ID not found')
      }
      
      userId = authData.user.id
    }

    const { data: existingUser, error: userCheckError } = await supabase
      .from('users')
      .select('id')
      .eq('id', userId)
      .single()
    
    if (userCheckError && userCheckError.code === 'PGRST116') {
      const { error: userError } = await supabase
        .from('users')
        .insert({
          id: userId,
          full_name: form.fullName,
          role: 'owner',
          subscription_tier: 'free',
          is_active: true,
          phone: form.phone || null,
          subscription_ends_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
        })

      if (userError) {
        console.error('❌ Erreur création utilisateur:', userError)
        error.value = 'Une erreur est survenue lors de la création du profil'
        return
      }
    }
    
    const { data: establishment, error: establishmentError } = await supabase
      .from('establishments')
      .insert({
        name: form.restaurantName,
        slug: form.restaurantName.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
        type_id: form.type,
        user_id: userId,
        created_by: userId,
        is_active: true,
        subscription_type: 'basic',
        address: form.address || null,
        phone: form.phone || null,
        latitude: form.latitude || null,
        longitude: form.longitude || null
      })
      .select()
    
    if (establishmentError) {
      console.error('❌ Erreur création établissement:', establishmentError)
      errors.restaurantName = 'Erreur lors de la création de l\'établissement'
      return
    }
    
    if (!isAlreadyAuthenticated) {
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: form.email,
        password: form.password
      })
      
      if (signInError) {
        console.error('❌ Erreur de connexion automatique:', signInError)
        navigateTo('/auth/login?registered=true&email=' + encodeURIComponent(form.email))
        return
      }
    }
    
    showToast.success('Configuration terminée !', 'Redirection vers votre dashboard...')
    navigateTo(`/manager/${establishment?.[0]?.slug || establishment?.[0]?.id}`)
    return
  } catch (err) {
    console.error('❌ Erreur inscription:', err)
    errors.restaurantName = 'Une erreur inattendue est survenue'
  } finally {
    loading.value = false
  }
}

const signInWithGoogle = async () => {
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    })
    if (error) throw error
  } catch (error) {
    errors.email = 'Erreur de connexion avec Google'
  }
}

const nextStep = () => {
  if (step.value === 1) {
    let hasErrors = false
    
    if (!form.fullName || form.fullName.trim() === '') {
      errors.fullName = 'Le nom complet est obligatoire'
      hasErrors = true
    }
    
    if (!form.email || form.email.trim() === '') {
      errors.email = 'L\'email est obligatoire'
      hasErrors = true
    }
    
    if (!form.password || form.password.length < 6) {
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères'
      hasErrors = true
    }
    
    if (hasErrors) {
      return
    }
    
    step.value = 2
    errors.fullName = ''
    errors.email = ''
    errors.password = ''
  }
}

definePageMeta({
  layout: 'auth'
})

// Add Leaflet CSS
useHead({
  link: [
    {
      rel: 'stylesheet',
      href: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css',
      integrity: 'sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=',
      crossorigin: ''
    },
  ],
  
})
</script>

<style scoped>
/* Select text color fix */
select option {
  color: #111827;
}

/* Map container */
#map {
  width: 100%;
  height: 100%;
}
</style>