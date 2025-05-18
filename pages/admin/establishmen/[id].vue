<template>
  <div class="min-h-screen bg-gray-50">
    <AdminHeader title="Détails de l'établissement" :back-link="'/admin/establishments'" />

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Loading state -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20">
        <Loader2 class="w-10 h-10 animate-spin text-gray-400 mb-4" />
        <p class="text-gray-500">Chargement des informations...</p>
      </div>

      <!-- Error state -->
      <div v-else-if="error" class="bg-white rounded-2xl shadow-sm p-8 text-center">
        <div class="w-16 h-16 mx-auto bg-red-50 rounded-2xl flex items-center justify-center mb-4">
          <AlertTriangle class="w-8 h-8 text-red-400" />
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Erreur de chargement</h3>
        <p class="text-gray-500 max-w-md mx-auto mb-4">
          Impossible de charger les informations de cet établissement.
        </p>
        <NuxtLink to="/admin/establishments" class="text-blue-600 hover:text-blue-800">
          Retour à la liste
        </NuxtLink>
      </div>

      <!-- Content -->
      <div v-else-if="establishment" class="flex flex-col gap-8">
        <!-- Header section -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <div class="flex flex-col lg:flex-row justify-between lg:items-center gap-4">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">{{ establishment.name }}</h1>
              <p class="text-gray-500">ID: {{ establishment.id }}</p>
            </div>
            <div class="flex items-center gap-3">
              <button 
                @click="openEditModal" 
                class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Edit3 class="w-4 h-4 mr-2 inline-block" />
                Modifier
              </button>
            </div>
          </div>
        </div>

        <!-- Details section -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Info Card -->
          <div class="bg-white rounded-2xl shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-4 text-gray-900">Informations générales</h2>
            <div class="space-y-4">
              <div>
                <p class="text-sm text-gray-500">Nom</p>
                <p class="font-medium text-gray-900">{{ establishment.name }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Description</p>
                <p class="font-medium text-gray-900">{{ establishment.description || 'Non spécifiée' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Type de cuisine</p>
                <p class="font-medium text-gray-900">{{ establishment.cuisine_type || 'Non spécifié' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Adresse</p>
                <p class="font-medium text-gray-900">{{ establishment.address || 'Non spécifiée' }}</p>
              </div>
            </div>
          </div>

          <!-- Contact Card -->
          <div class="bg-white rounded-2xl shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-4 text-gray-900">Contact</h2>
            <div class="space-y-4">
              <div>
                <p class="text-sm text-gray-500">Email</p>
                <p class="font-medium text-gray-900">{{ establishment.email || 'Non spécifié' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Téléphone</p>
                <p class="font-medium text-gray-900">{{ establishment.phone || 'Non spécifié' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Site web</p>
                <p v-if="establishment.website" class="font-medium text-blue-600">
                  <a :href="establishment.website" target="_blank" rel="noopener noreferrer">
                    {{ establishment.website }}
                  </a>
                </p>
                <p v-else class="font-medium text-gray-900">Non spécifié</p>
              </div>
            </div>
          </div>

          <!-- Settings Card -->
          <div class="bg-white rounded-2xl shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-4 text-gray-900">Paramètres</h2>
            <div class="space-y-4">
              <div>
                <p class="text-sm text-gray-500">Statut</p>
                <div class="mt-1">
                  <span 
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="establishment.active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                  >
                    {{ establishment.active ? 'Actif' : 'Inactif' }}
                  </span>
                </div>
              </div>
              <div>
                <p class="text-sm text-gray-500">Date de création</p>
                <p class="font-medium text-gray-900">{{ formatDate(establishment.created_at) }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500">Dernière mise à jour</p>
                <p class="font-medium text-gray-900">{{ formatDate(establishment.updated_at) }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Staff tab -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <h2 class="text-xl font-semibold mb-6 text-gray-900">Personnel</h2>
          <div v-if="isLoadingStaff" class="text-center py-8">
            <Loader2 class="w-6 h-6 animate-spin text-gray-400 mx-auto mb-2" />
            <p class="text-gray-500">Chargement du personnel...</p>
          </div>
          <div v-else-if="staffList.length === 0" class="text-center py-8 border border-dashed border-gray-300 rounded-xl">
            <UserX class="w-10 h-10 text-gray-300 mx-auto mb-2" />
            <p class="text-gray-500">Aucun membre du personnel associé à cet établissement</p>
            <button
              @click="openAddStaffModal"
              class="mt-4 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
            >
              <UserPlus class="w-4 h-4 mr-2 inline-block" />
              Ajouter un membre
            </button>
          </div>
          <div v-else>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Nom
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rôle
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Dernière connexion
                    </th>
                    <th scope="col" class="relative px-6 py-3">
                      <span class="sr-only">Actions</span>
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="staff in staffList" :key="staff.id">
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="flex items-center">
                        <div class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-600">
                          {{ staff.username ? staff.username.charAt(0).toUpperCase() : 'S' }}
                        </div>
                        <div class="ml-4">
                          <div class="text-sm font-medium text-gray-900">{{ staff.username || 'Sans nom' }}</div>
                          <div class="text-sm text-gray-500">ID: {{ staff.id.substring(0, 8) }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                        {{ staff.role || 'Staff' }}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {{ staff.email || 'Non spécifié' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {{ staff.last_login ? formatDate(staff.last_login) : 'Jamais' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button class="text-blue-600 hover:text-blue-900 mr-3">Modifier</button>
                      <button class="text-red-600 hover:text-red-900">Supprimer</button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="mt-4 flex justify-end">
              <button
                @click="openAddStaffModal"
                class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                <UserPlus class="w-4 h-4 mr-2 inline-block" />
                Ajouter un membre
              </button>
            </div>
          </div>
        </div>

        <!-- QR Code section -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <h2 class="text-xl font-semibold mb-6 text-gray-900">QR Code</h2>
          <div class="flex flex-col sm:flex-row items-center gap-8">
            <div class="bg-white p-4 rounded-xl border border-gray-200 shadow-sm">
              <img 
                :src="`https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${qrCodeUrl}`" 
                alt="QR Code de l'établissement"
                class="w-48 h-48"
              />
            </div>
            <div class="space-y-4 flex-1">
              <div>
                <p class="text-sm text-gray-500 mb-1">URL du menu</p>
                <div class="flex items-center gap-2">
                  <input 
                    type="text" 
                    readonly 
                    :value="qrCodeUrl" 
                    class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                  <button 
                    @click="copyToClipboard(qrCodeUrl)" 
                    class="p-2.5 text-gray-500 rounded-lg hover:bg-gray-100"
                    title="Copier l'URL"
                  >
                    <Clipboard class="w-5 h-5" />
                  </button>
                </div>
              </div>
              <div class="flex flex-wrap gap-3">
                <button 
                  @click="downloadQRCode('png')" 
                  class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  <Download class="w-4 h-4 mr-2 inline-block" />
                  Télécharger PNG
                </button>
                <button 
                  @click="downloadQRCode('svg')" 
                  class="px-4 py-2 bg-blue-100 text-blue-800 rounded-lg hover:bg-blue-200 transition-colors"
                >
                  <Download class="w-4 h-4 mr-2 inline-block" />
                  Télécharger SVG
                </button>
                <button 
                  @click="printQRCode" 
                  class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  <Printer class="w-4 h-4 mr-2 inline-block" />
                  Imprimer
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals will go here -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useSupabaseClient } from '#imports'
import { useRoute, useRouter } from 'vue-router'
import { 
  Loader2, 
  AlertTriangle, 
  Edit3, 
  Download, 
  Clipboard, 
  Printer,
  UserPlus,
  UserX,
  Store
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'

const route = useRoute()
const router = useRouter()
const supabase = useSupabaseClient()
const {showToast} = useCustomToast()

// State
const isLoading = ref(true)
const isLoadingStaff = ref(true)
const error = ref(null)
const establishment = ref(null)
const staffList = ref([])

// Computed
const establishmentId = computed(() => route.params.id)
const qrCodeUrl = computed(() => {
  if (!establishment.value) return ''
  const baseUrl = window.location.origin
  return `${baseUrl}/menu/${establishment.value.id}`
})

// Methods
const loadEstablishment = async () => {
  try {
    isLoading.value = true
    error.value = null
    
    const { data, error: err } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', establishmentId.value)
      .single()
    
    if (err) throw err
    
    if (!data) {
      error.value = 'Établissement introuvable'
      return
    }
    
    establishment.value = data
  } catch (err) {
    console.error('Error loading establishment:', err)
    error.value = err.message || 'Une erreur est survenue lors du chargement'
  } finally {
    isLoading.value = false
  }
}

const loadStaff = async () => {
  try {
    isLoadingStaff.value = true
    
    const { data, error: err } = await supabase
      .from('staff')
      .select(`
        id,
        username,
        role,
        email,
        last_login,
        created_at
      `)
      .eq('establishment_id', establishmentId.value)
    
    if (err) throw err
    
    staffList.value = data || []
  } catch (err) {
    console.error('Error loading staff:', err)
    showToast.error('Erreur', 'Impossible de charger la liste du personnel')
  } finally {
    isLoadingStaff.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    showToast.success('Copié !', 'L\'URL a été copiée dans le presse-papier')
  } catch (err) {
    showToast.error('Erreur', 'Impossible de copier l\'URL')
  }
}

const downloadQRCode = (format) => {
  const baseUrl = 'https://api.qrserver.com/v1/create-qr-code/'
  const params = new URLSearchParams({
    size: '300x300',
    data: qrCodeUrl.value,
    format
  })
  
  const url = `${baseUrl}?${params.toString()}`
  const link = document.createElement('a')
  link.href = url
  link.download = `qrcode-${establishment.value.name.toLowerCase().replace(/\s+/g, '-')}.${format}`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const printQRCode = () => {
  const url = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(qrCodeUrl.value)}`
  const printWindow = window.open('', '_blank')
  printWindow.document.write(`<html>
       
    </html>
  `);
  printWindow.document.close();
}

const openEditModal = () => {
  // Implement this when you create the edit modal component
  showToast.info('Fonctionnalité à venir', 'L\'édition sera bientôt disponible')
}

const openAddStaffModal = () => {
  // Implement this when you create the add staff modal component
  showToast.info('Fonctionnalité à venir', 'L\'ajout de personnel sera bientôt disponible')
}

// Lifecycle
onMounted(async () => {
  await loadEstablishment()
  if (establishment.value) {
    await loadStaff()
  }
})
</script> 