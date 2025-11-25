<template>
  <div class="min-h-screen bg-white flex items-start sm:items-center justify-center p-4 sm:p-6 overflow-y-auto">
    <div class="w-full max-w-[400px] py-4 sm:py-0">
      <!-- Progress Indicator - Enhanced -->
      <div class="mb-8 sm:mb-10">
        <div class="flex items-center gap-2">
          <div v-for="i in 3" :key="i" class="relative h-1 flex-1 rounded-full bg-gray-200 overflow-hidden">
            <div
              class="absolute inset-0 bg-black origin-left transition-transform duration-500 ease-out"
              :class="step >= i ? 'scale-x-100' : 'scale-x-0'"></div>
          </div>
        </div>
        <div class="mt-3 text-center">
          <p class="text-xs sm:text-sm font-medium text-gray-500">Étape {{ step }} sur 3</p>
        </div>
      </div>

      <!-- Step 1: Personal Info -->
      <transition enter-active-class="transition-all duration-300 ease-out" enter-from-class="opacity-0 translate-x-8"
        enter-to-class="opacity-100 translate-x-0" leave-active-class="transition-all duration-200 ease-in"
        leave-from-class="opacity-100 translate-x-0" leave-to-class="opacity-0 -translate-x-8" mode="out-in">
        <div v-if="step === 1" class="space-y-6 sm:space-y-8 animate-fade-in">
          <!-- Header -->
          <div class="space-y-1 sm:space-y-2">
            <h1 class="text-[27px] sm:text-[31px] font-bold text-gray-900 leading-tight">
              Créer votre compte
            </h1>
          </div>

          <!-- Form -->
          <form @submit.prevent="nextStep" class="space-y-4 sm:space-y-5">
            <!-- Full Name -->
            <div>
              <input v-model="form.fullName" type="text" id="fullName" required placeholder="Nom complet"
                @focus="scrollToInput"
                class="w-full h-[52px] sm:h-[56px] px-4 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500': errors.fullName }" />
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.fullName" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.fullName }}</p>
              </transition>
            </div>

            <!-- Phone Number -->
            <div>
              <div class="flex gap-2">
                <!-- Country Code Select -->
                <select v-model="form.countryCode"
                  class="w-20 sm:w-24 h-[52px] sm:h-[56px] px-2 sm:px-3 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200">
                  <option value="+221">🇸🇳 +221</option>
                  <option value="+242">🇨🇬 +242</option>
                  <option value="+241">🇬🇦 +241</option>
                  <option value="+243">🇨🇩 +243</option>
                  <option value="+225">🇨🇮 +225</option>
                  <option value="+229">🇧🇯 +229</option>
                </select>

                <!-- Phone Number Input -->
                <input v-model="form.phone" type="tel" id="phone" required placeholder="77 123 45 67"
                  @focus="scrollToInput"
                  class="flex-1 h-[52px] sm:h-[56px] px-3 sm:px-4 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                  :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500': errors.phone }" />
              </div>
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.phone" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.phone }}</p>
              </transition>
            </div>

            <button type="submit"
              class="w-full h-[48px] sm:h-[52px] bg-black text-white rounded-full text-[15px] sm:text-[17px] font-bold hover:bg-gray-800 active:scale-[0.97] transition-all duration-200 flex items-center justify-center"
              :disabled="loading">
              <span v-if="!loading">Suivant</span>
              <Loader2 v-else class="w-5 h-5 animate-spin" />
            </button>
          </form>

          <!-- Sign In Link -->
          <div class="pt-4 sm:pt-5 border-t border-gray-300">
            <p class="text-[14px] sm:text-[15px] text-gray-600">
              Vous avez déjà un compte ?
              <NuxtLink to="/auth/login" class="text-blue-500 hover:underline ml-1">
                Se connecter
              </NuxtLink>
            </p>
          </div>
        </div>

        <!-- Step 2: Account Info -->
        <div v-else-if="step === 2" class="space-y-6 sm:space-y-8 animate-fade-in">
          <!-- Header -->
          <div class="space-y-1 sm:space-y-2">
            <h1 class="text-[27px] sm:text-[31px] font-bold text-gray-900 leading-tight">
              Sécurisez votre compte
            </h1>
          </div>

          <!-- Form -->
          <form @submit.prevent="nextStep" class="space-y-4 sm:space-y-5">
            <!-- Email -->
            <div>
              <input v-model="form.email" type="email" id="email" required placeholder="Email"
                @focus="scrollToInput"
                class="w-full h-[52px] sm:h-[56px] px-4 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500': errors.email }" />
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.email" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.email }}</p>
              </transition>
            </div>

            <!-- Password -->
            <div>
              <div class="relative">
                <input v-model="form.password" :type="showPassword ? 'text' : 'password'" id="password" minlength="6"
                  required placeholder="Mot de passe"
                  @focus="scrollToInput"
                  class="w-full h-[52px] sm:h-[56px] px-4 pr-12 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                  :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500': errors.password }" />
                <button type="button" @click="showPassword = !showPassword"
                  class="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-gray-500 hover:text-gray-900 transition-colors">
                  <Eye v-if="showPassword" class="w-4 h-4 sm:w-5 sm:h-5" />
                  <EyeOff v-else class="w-4 h-4 sm:w-5 sm:h-5" />
                </button>
              </div>
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.password" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.password }}</p>
              </transition>
            </div>

            <div class="flex gap-2 sm:gap-3">
              <button type="button" @click="step = 1"
                class="h-[48px] sm:h-[52px] px-5 sm:px-6 bg-white border border-gray-300 rounded-full text-[15px] sm:text-[17px] font-bold text-gray-900 hover:bg-gray-50 transition-colors duration-200">
                Retour
              </button>
              <button type="submit"
                class="flex-1 h-[48px] sm:h-[52px] bg-black text-white rounded-full text-[15px] sm:text-[17px] font-bold hover:bg-gray-800 active:scale-[0.97] transition-all duration-200 flex items-center justify-center"
                :disabled="loading">
                <span v-if="!loading">Suivant</span>
                <Loader2 v-else class="w-5 h-5 animate-spin" />
              </button>
            </div>
          </form>

          <!-- Divider -->
          <div class="relative my-1">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center">
              <span class="px-2 bg-white text-[14px] sm:text-[15px] text-gray-500">ou</span>
            </div>
          </div>

          <!-- Google Sign Up -->
          <button @click="signInWithGoogle" type="button"
            class="w-full h-[48px] sm:h-[52px] bg-white border border-gray-300 rounded-full text-[14px] sm:text-[15px] font-bold flex items-center justify-center hover:bg-gray-50 transition-colors duration-200">
            <svg class="w-4 h-4 sm:w-[18px] sm:h-[18px] mr-2" viewBox="0 0 24 24">
              <path fill="#4285F4"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
              <path fill="#34A853"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
              <path fill="#FBBC05"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" />
              <path fill="#EA4335"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
            </svg>
            <span class="text-gray-900">
              Continuer avec Google
            </span>
          </button>
        </div>

        <!-- Step 3: Restaurant Info -->
        <div v-else class="space-y-6 sm:space-y-8 animate-fade-in">
          <!-- Header -->
          <div class="space-y-1 sm:space-y-2">
            <h1 class="text-[27px] sm:text-[31px] font-bold text-gray-900 leading-tight">
              Votre établissement
            </h1>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleRegister" class="space-y-4 sm:space-y-5">
            <!-- Restaurant Name -->
            <div>
              <input v-model="form.restaurantName" type="text" id="restaurantName" required
                placeholder="Nom de l'établissement"
                @focus="scrollToInput"
                class="w-full h-[52px] sm:h-[56px] px-4 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500': errors.restaurantName }" />
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.restaurantName" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.restaurantName
                  }}</p>
              </transition>
            </div>

            <!-- Type Select -->
            <div>
              <select v-model="form.type" id="type" required
                @focus="scrollToInput"
                class="w-full h-[52px] sm:h-[56px] px-4 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200"
                :class="{
                  'border-red-500 focus:border-red-500 focus:ring-red-500': errors.type,
                  'text-gray-900': form.type,
                  'text-gray-500': !form.type
                }">
                <option value="" disabled selected>Type d'établissement</option>
                <option v-for="type in establishmentTypes" :key="type.id" :value="type.id">
                  {{ type.name }}
                </option>
              </select>
              <transition enter-active-class="transition-all duration-200" enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0">
                <p v-if="errors.type" class="text-xs sm:text-sm text-red-600 mt-2">{{ errors.type }}</p>
              </transition>
            </div>

            <!-- Address with Location -->
            <div>
              <div class="relative">
                <input v-model="form.address" type="text" id="address" placeholder="Adresse (optionnel)"
                  @focus="scrollToInput"
                  class="w-full h-[52px] sm:h-[56px] px-4 pr-11 sm:pr-12 bg-white border border-gray-300 rounded text-[15px] sm:text-[17px] placeholder:text-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 transition-all duration-200" />
                <button type="button" @click="showLocationSheet = true"
                  class="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-gray-500 hover:text-gray-900 transition-colors"
                  title="Localiser sur la carte">
                  <MapPin class="w-4 h-4 sm:w-5 sm:h-5" />
                </button>
              </div>
            </div>

            <div class="flex gap-2 sm:gap-3">
              <button type="button" @click="step = 2"
                class="h-[48px] sm:h-[52px] px-5 sm:px-6 bg-white border border-gray-300 rounded-full text-[15px] sm:text-[17px] font-bold text-gray-900 hover:bg-gray-50 transition-colors duration-200">
                Retour
              </button>
              <button type="submit"
                class="flex-1 h-[48px] sm:h-[52px] bg-black text-white rounded-full text-[15px] sm:text-[17px] font-bold hover:bg-gray-800 active:scale-[0.97] transition-all duration-200 flex items-center justify-center"
                :disabled="loading">
                <span v-if="!loading">Créer mon compte</span>
                <span v-else class="flex items-center gap-2">
                  <Loader2 class="w-4 h-4 sm:w-5 sm:h-5 animate-spin" />
                  <span class="hidden sm:inline">Création...</span>
                </span>
              </button>
            </div>
          </form>
        </div>
      </transition>

      <!-- Footer -->
      <div class="mt-6 sm:mt-8 text-center">
        <p class="text-[11px] sm:text-xs text-gray-500 leading-relaxed">
          En continuant, vous acceptez nos
          <NuxtLink to="/legal/terms" class="text-gray-600 hover:underline">Conditions
          </NuxtLink>
          et notre
          <NuxtLink to="/legal/privacy" class="text-gray-600 hover:underline">Politique de confidentialité</NuxtLink>
        </p>
      </div>
    </div>

    <!-- Location Bottom Sheet - Uber Style -->
    <transition enter-active-class="transition-opacity duration-200" enter-from-class="opacity-0"
      enter-to-class="opacity-100" leave-active-class="transition-opacity duration-200" leave-from-class="opacity-100"
      leave-to-class="opacity-0">
      <div v-if="showLocationSheet"
        class="fixed inset-0 bg-black/40 z-50 flex items-end sm:items-center sm:justify-center"
        @click.self="showLocationSheet = false">
        <transition enter-active-class="transition-all duration-300 ease-out"
          enter-from-class="translate-y-full sm:translate-y-0 sm:scale-95" enter-to-class="translate-y-0 sm:scale-100"
          leave-active-class="transition-all duration-200 ease-in" leave-from-class="translate-y-0 sm:scale-100"
          leave-to-class="translate-y-full sm:translate-y-0 sm:scale-95">
          <div v-if="showLocationSheet"
            class="w-full sm:w-[90%] sm:max-w-2xl bg-white rounded-t-3xl sm:rounded-2xl shadow-2xl max-h-[85vh] flex flex-col overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between p-6 border-b border-gray-100">
              <div>
                <h3 class="text-xl font-bold text-gray-900">Localisation</h3>
                <p class="text-sm text-gray-500 mt-1">Placez le marqueur sur votre établissement</p>
              </div>
              <button @click="showLocationSheet = false" class="p-2 hover:bg-gray-100 rounded-full transition-colors">
                <svg class="w-6 h-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <!-- Map Container -->
            <div class="flex-1 bg-gray-100 relative">
              <div id="map" class="w-full h-full min-h-[400px]"></div>

              <!-- Center marker -->
              <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full pointer-events-none z-[1000]">
                <MapPin class="w-10 h-10 text-black drop-shadow-lg" :fill="'currentColor'" />
              </div>

              <!-- Loading overlay -->
              <div v-if="loadingLocation"
                class="absolute inset-0 bg-white/90 flex items-center justify-center z-[1001]">
                <div class="text-center">
                  <Loader2 class="w-10 h-10 text-black animate-spin mx-auto mb-3" />
                  <p class="text-gray-600 font-medium">Localisation...</p>
                </div>
              </div>
            </div>

            <!-- Address Display & Actions -->
            <div class="p-6 space-y-4 bg-white">
              <!-- Selected Address -->
              <div v-if="selectedAddress" class="p-4 bg-gray-50 rounded-xl">
                <p class="text-xs text-gray-500 mb-1">Adresse sélectionnée</p>
                <p class="text-gray-900 font-medium">{{ selectedAddress }}</p>
              </div>

              <!-- Actions -->
              <div class="flex gap-3">
                <button @click="getCurrentLocation" :disabled="loadingLocation"
                  class="flex-1 h-14 bg-gray-100 text-gray-900 rounded-full font-medium hover:bg-gray-200 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-50">
                  <Loader2 v-if="loadingLocation" class="w-5 h-5 animate-spin" />
                  <Navigation v-else class="w-5 h-5" />
                  <span>{{ loadingLocation ? 'Localisation...' : 'Me localiser' }}</span>
                </button>

                <button @click="confirmLocation" :disabled="!selectedAddress"
                  class="flex-1 h-14 bg-black text-white rounded-full font-medium hover:bg-gray-900 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-50 disabled:bg-gray-300">
                  <Check class="w-5 h-5" />
                  <span>Confirmer</span>
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
  countryCode: '+221', // Sénégal par défaut
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

// Scroll to input when focused (pour éviter que le clavier cache l'input)
const scrollToInput = (event: FocusEvent) => {
  // Délai pour laisser le clavier s'ouvrir
  setTimeout(() => {
    const target = event.target as HTMLElement
    if (target) {
      // Calculer la position de l'input
      const rect = target.getBoundingClientRect()
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop
      const targetPosition = rect.top + scrollTop
      
      // Scroll avec un offset pour centrer l'input au-dessus du clavier
      const offset = window.innerHeight * 0.3 // 30% de la hauteur de l'écran
      
      window.scrollTo({
        top: targetPosition - offset,
        behavior: 'smooth'
      })
    }
  }, 300) // Délai pour l'ouverture du clavier mobile
}
const step = ref(1)

// Validate phone number
const validatePhone = (phone: string): boolean => {
  // Nettoyer le numéro (retirer les espaces)
  const cleanPhone = phone.replace(/\s/g, '')
  
  // Doit contenir uniquement des chiffres
  if (!/^\d+$/.test(cleanPhone)) {
    return false
  }
  
  // Longueur valide entre 8 et 15 chiffres (standard international)
  const length = cleanPhone.length
  if (length < 8 || length > 15) {
    return false
  }
  
  // Vérifications spécifiques par pays selon l'indicatif sélectionné
  const validations: { [key: string]: number[] } = {
    '+221': [9], // Sénégal: 9 chiffres (ex: 77 123 45 67)
    '+237': [9], // Cameroun: 9 chiffres
    '+242': [9], // Congo-Brazzaville: 9 chiffres
    '+243': [9, 10], // RD Congo: 9-10 chiffres
    '+241': [9], // Gabon: 9 chiffres
    '+225': [10], // Côte d'Ivoire: 10 chiffres
    '+229': [8], // Bénin: 8 chiffres
    '+33': [9], // France: 9 chiffres (sans le 0)
    '+1': [10], // USA/Canada: 10 chiffres
    '+44': [10], // UK: 10 chiffres
  }
  
  const allowedLengths = validations[form.countryCode]
  
  // Si on a des règles spécifiques pour ce pays, les appliquer
  if (allowedLengths) {
    return allowedLengths.includes(length)
  }
  
  // Sinon, accepter 8-15 chiffres (règle générale)
  return true
}

// Get full phone number with country code
const getFullPhoneNumber = (): string => {
  return `${form.countryCode} ${form.phone}`.trim()
}

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
          subscription_tier: 'demo', // Demo par défaut (7 jours)
          is_active: false, // Compte inactif par défaut (activé par admin)
          phone: getFullPhoneNumber() || null,
          subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 jours de démo
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
        is_active: false, // Établissement inactif par défaut
        subscription_type: 'basic',
        address: form.address || null,
        phone: getFullPhoneNumber() || null,
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

    // Déconnexion immédiate pour empêcher l'accès
    await supabase.auth.signOut()

    // Afficher le message de succès et rediriger vers la page de confirmation
    showToast.success('Compte créé !', 'Votre compte a été créé avec succès')
    navigateTo('/auth/pending-activation?name=' + encodeURIComponent(form.fullName) + '&email=' + encodeURIComponent(form.email))
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
    // Reset errors
    errors.fullName = ''
    errors.phone = ''

    let hasErrors = false

    if (!form.fullName || form.fullName.trim() === '') {
      errors.fullName = 'Le nom complet est obligatoire'
      hasErrors = true
    }

    if (!form.phone || form.phone.trim() === '') {
      errors.phone = 'Le numéro de téléphone est obligatoire'
      hasErrors = true
    } else if (!validatePhone(form.phone)) {
      // Message d'erreur personnalisé selon le pays
      const errorMessages: { [key: string]: string } = {
        '+221': 'Format invalide. Ex: 77 123 45 67 (9 chiffres)',
        '+237': 'Format invalide. Ex: 6 12 34 56 78 (9 chiffres)',
        '+242': 'Format invalide. Ex: 6 12 34 56 78 (9 chiffres)',
        '+243': 'Format invalide. Ex: 81 234 5678 (9-10 chiffres)',
        '+241': 'Format invalide. Ex: 1 23 45 67 (7-8 chiffres)',
        '+225': 'Format invalide. Ex: 01 23 45 67 89 (10 chiffres)',
        '+229': 'Format invalide. Ex: 12 34 56 78 (8 chiffres)',
        '+33': 'Format invalide. Ex: 6 12 34 56 78 (9 chiffres)',
        '+1': 'Format invalide. Ex: 555 123 4567 (10 chiffres)',
      }
      errors.phone = errorMessages[form.countryCode] || 'Format invalide. Vérifiez votre numéro'
      hasErrors = true
    }

    if (hasErrors) {
      return
    }

    step.value = 2
  } else if (step.value === 2) {
    // Reset errors
    errors.email = ''
    errors.password = ''

    let hasErrors = false

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

    step.value = 3
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
/* Uber-inspired impactful styles */
select option {
  color: #111827;
}

#map {
  width: 100%;
  height: 100%;
}

/* Remove spinner from number inputs */
input[type="tel"]::-webkit-inner-spin-button,
input[type="tel"]::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

input[type="tel"] {
  appearance: textfield;
  -moz-appearance: textfield;
}

/* Smooth transitions */
* {
  -webkit-tap-highlight-color: transparent;
}

/* Custom fade-in animation */
@keyframes fade-in {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

/* Enhanced focus styles */
input:focus,
select:focus {
  outline: none;
}

/* Button press effect */
button:active:not(:disabled) {
  transform: scale(0.98);
}

/* Gradient background animation */
@keyframes gradient {
  0% {
    background-position: 0% 50%;
  }

  50% {
    background-position: 100% 50%;
  }

  100% {
    background-position: 0% 50%;
  }
}
</style>