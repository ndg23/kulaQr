<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <div class="bg-white border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Gestion des demandes QR</h1>
            <p class="text-sm text-gray-500 mt-1">Gérez les demandes de support pour les codes QR</p>
          </div>
          <div class="flex items-center space-x-3">
            <button
              @click="refreshData"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors"
            >
              <RefreshCw class="w-4 h-4 mr-2" />
              Actualiser
            </button>
          </div>
        </div>
      </div>
    </div>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Stats Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
        <div
          v-for="stat in stats"
          :key="stat.name"
          class="bg-white rounded-xl p-6 shadow-sm border border-gray-100"
        >
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-gray-50 rounded-xl flex items-center justify-center">
              <component :is="stat.icon" class="w-6 h-6 text-gray-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
              <p class="text-sm text-gray-500 mt-1">{{ stat.name }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
          <div class="flex items-center gap-2">
            <Filter class="w-5 h-5 text-gray-400" />
            <span class="text-sm font-medium text-gray-700">Filtres:</span>
          </div>

          <select
            v-model="selectedEstablishment"
            @change="filterRequests"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tous les établissements</option>
            <option v-for="establishment in establishments" :key="establishment.id" :value="establishment.id">
              {{ establishment.name }}
            </option>
          </select>

          <select
            v-model="selectedStatus"
            @change="filterRequests"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tous les statuts</option>
            <option value="pending">En attente</option>
            <option value="in_progress">En cours</option>
            <option value="completed">Terminé</option>
            <option value="cancelled">Annulé</option>
            <option value="rejected">Rejeté</option>
          </select>

          <select
            v-model="filters.priority"
            @change="applyFilters"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Toutes les priorités</option>
            <option value="low">Faible</option>
            <option value="medium">Moyenne</option>
            <option value="high">Élevée</option>
            <option value="urgent">Urgente</option>
          </select>

          <select
            v-model="filters.type"
            @change="applyFilters"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tous les types</option>
            <option value="new_qr">Nouveau QR</option>
            <option value="qr_replacement">Remplacement QR</option>
            <option value="qr_update">Mise à jour QR</option>
            <option value="qr_deactivation">Désactivation QR</option>
            <option value="bulk_qr_generation">Génération en masse</option>
            <option value="qr_customization">Personnalisation QR</option>
            <option value="technical_issue">Problème technique</option>
          </select>

          <div class="relative flex-1 max-w-sm">
            <Search class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              v-model="searchQuery"
              @input="applyFilters"
              type="text"
              placeholder="Rechercher par titre ou établissement..."
              class="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      <!-- Requests Table -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <!-- Loading State -->
        <div v-if="loading" class="flex flex-col items-center justify-center py-20">
          <div class="w-16 h-16 relative">
            <div class="w-16 h-16 bg-gray-100 rounded-full animate-pulse"></div>
            <Loader2 class="w-8 h-8 text-gray-400 animate-spin absolute inset-0 m-auto" />
          </div>
          <p class="text-sm text-gray-500 mt-4">Chargement des demandes...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredRequests.length === 0" class="text-center py-16">
          <div class="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
            <Inbox class="w-8 h-8 text-gray-400" />
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune demande trouvée</h3>
          <p class="text-gray-500">
            {{ searchQuery || filters.priority || filters.type ? "Aucune demande ne correspond à vos critères." : "Il n'y a pas encore de demandes de support QR." }}
          </p>
        </div>

        <!-- Table -->
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Demande
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Établissement
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Priorité
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Statut
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr
                v-for="request in filteredRequests"
                :key="request.id"
                class="hover:bg-gray-50 transition-colors"
              >
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                        <component :is="getRequestIcon(request.request_type)" class="h-5 w-5 text-gray-600" />
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ request.title }}</div>
                      <div class="text-sm text-gray-500">
                        Table {{ request.table_number || 'N/A' }}
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ getEstablishmentName(request.establishment_id) }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                        :class="getTypeBadgeClass(request.request_type)">
                    {{ getRequestTypeLabel(request.request_type) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                        :class="getPriorityBadgeClass(request.priority)">
                    {{ getPriorityLabel(request.priority) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                        :class="getStatusBadgeClass(request.status)">
                    {{ getStatusLabel(request.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(request.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex items-center space-x-2">
                    <button
                      @click="viewRequest(request)"
                      class="text-blue-600 hover:text-blue-900 transition-colors"
                    >
                      <Eye class="h-4 w-4" />
                    </button>
                    <button
                      @click="editRequest(request)"
                      class="text-gray-600 hover:text-gray-900 transition-colors"
                    >
                      <Edit class="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>

    <!-- Request Detail Modal -->
    <TransitionRoot appear :show="showRequestModal" as="template">
      <Dialog as="div" class="relative z-50" @close="closeRequestModal">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as="template"
              enter="duration-300 ease-out"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="duration-200 ease-in"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-2xl transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
                <div v-if="selectedRequest" class="p-8">
                  <!-- Header -->
                  <div class="flex items-start justify-between mb-6">
                    <div class="flex items-center space-x-3">
                      <div class="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center">
                        <component :is="getRequestIcon(selectedRequest.request_type)" class="w-6 h-6 text-gray-600" />
                      </div>
                      <div>
                        <h3 class="text-xl font-semibold text-gray-900">{{ selectedRequest.title }}</h3>
                        <p class="text-sm text-gray-500">
                          Table {{ selectedRequest.table_number || 'N/A' }} • {{ getEstablishmentName(selectedRequest.establishment_id) }}
                        </p>
                      </div>
                    </div>
                    <div class="flex items-center space-x-2">
                      <span class="inline-flex px-3 py-1 text-sm font-medium rounded-full"
                            :class="getPriorityBadgeClass(selectedRequest.priority)">
                        {{ getPriorityLabel(selectedRequest.priority) }}
                      </span>
                      <span class="inline-flex px-3 py-1 text-sm font-medium rounded-full"
                            :class="getStatusBadgeClass(selectedRequest.status)">
                        {{ getStatusLabel(selectedRequest.status) }}
                      </span>
                    </div>
                  </div>

                  <!-- Content -->
                  <div class="space-y-6">
                    <div>
                      <h4 class="text-sm font-medium text-gray-900 mb-2">Description</h4>
                      <p class="text-sm text-gray-600">{{ selectedRequest.description || 'Aucune description' }}</p>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                      <div>
                        <h4 class="text-sm font-medium text-gray-900 mb-2">Type de demande</h4>
                        <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                              :class="getTypeBadgeClass(selectedRequest.request_type)">
                          {{ getRequestTypeLabel(selectedRequest.request_type) }}
                        </span>
                      </div>
                      <div>
                        <h4 class="text-sm font-medium text-gray-900 mb-2">Date de création</h4>
                        <p class="text-sm text-gray-600">{{ formatDate(selectedRequest.created_at) }}</p>
                      </div>
                    </div>

                    <!-- Status Update -->
                    <div v-if="!viewOnly" class="border-t pt-6">
                      <h4 class="text-sm font-medium text-gray-900 mb-4">Mettre à jour le statut</h4>
                      <div class="space-y-4">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Nouveau statut</label>
                          <select
                            v-model="newStatus"
                            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                          >
                            <option value="pending">En attente</option>
                            <option value="in_progress">En cours</option>
                            <option value="completed">Terminé</option>
                            <option value="cancelled">Annulé</option>
                            <option value="rejected">Rejeté</option>
                          </select>
                        </div>
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-2">Notes de résolution (optionnel)</label>
                          <textarea
                            v-model="resolutionNotes"
                            rows="3"
                            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            placeholder="Ajouter des notes sur la résolution..."
                          ></textarea>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div class="flex justify-end space-x-3 mt-8 pt-6 border-t">
                    <button
                      @click="closeRequestModal"
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                    >
                      {{ viewOnly ? 'Fermer' : 'Annuler' }}
                    </button>
                    <button
                      v-if="!viewOnly"
                      @click="updateRequestStatus"
                      :disabled="updating"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-lg transition-colors"
                    >
                      <span v-if="updating">Mise à jour...</span>
                      <span v-else>Mettre à jour</span>
                    </button>
                  </div>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  RefreshCw, Filter, Search, Eye, Edit, Inbox, Loader2,
  QrCode, Settings, AlertTriangle, CheckCircle, XCircle, Clock,
  Plus, Smartphone, RotateCcw, Upload, Zap
} from 'lucide-vue-next'
import {
  TransitionRoot,
  TransitionChild,
  Dialog,
  DialogPanel
} from '@headlessui/vue'
import type { QrSupportRequest } from '~/types'

const supabase = useSupabaseClient()
const { showToast } = useCustomToast()

// State
const requests = ref<QrSupportRequest[]>([])
const establishments = ref<any[]>([])
const loading = ref(true)
const searchQuery = ref('')
const selectedEstablishment = ref('')
const selectedStatus = ref('')
const filters = ref({
  status: '',
  priority: '',
  type: ''
})
const showRequestModal = ref(false)
const selectedRequest = ref<QrSupportRequest | null>(null)
const viewOnly = ref(false)
const newStatus = ref('')
const resolutionNotes = ref('')
const updating = ref(false)

// Computed
const filteredRequests = computed(() => {
  let filtered = requests.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(request =>
      request.title.toLowerCase().includes(query) ||
      getEstablishmentName(request.establishment_id).toLowerCase().includes(query)
    )
  }

  // Priority filter (client-side only)
  if (filters.value.priority) {
    filtered = filtered.filter(request => request.priority === filters.value.priority)
  }

  // Type filter (client-side only)
  if (filters.value.type) {
    filtered = filtered.filter(request => request.request_type === filters.value.type)
  }

  return filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

const stats = computed(() => {
  const total = requests.value.length
  const pending = requests.value.filter(r => r.status === 'pending').length
  const inProgress = requests.value.filter(r => r.status === 'in_progress').length
  const completed = requests.value.filter(r => r.status === 'completed').length

  return [
    { name: 'Total', value: total, icon: QrCode },
    { name: 'En attente', value: pending, icon: Clock },
    { name: 'En cours', value: inProgress, icon: Settings },
    { name: 'Terminées', value: completed, icon: CheckCircle }
  ]
})

// Methods
const loadData = async () => {
  try {
    loading.value = true

    const { data: requestsData, error: requestsError } = await (supabase as any)
      .rpc('get_qr_support_requests_with_users', {
        establishment_filter: null,
        status_filter: null,
        limit_count: 1000, // Load all for admin
        offset_count: 0
      })

    if (requestsError) throw requestsError
    requests.value = requestsData || []

    // Load establishments for name resolution (already included in RPC)
    const { data: establishmentsData, error: establishmentsError } = await supabase
      .from('establishments')
      .select('id, name')

    if (establishmentsError) throw establishmentsError
    establishments.value = establishmentsData || []

  } catch (error) {
    console.error('Error loading data:', error)
    showToast.error('Erreur', 'Impossible de charger les données')
  } finally {
    loading.value = false
  }
}

const getEstablishmentName = (establishmentId: string) => {
  const establishment = establishments.value.find(e => e.id === establishmentId)
  return establishment?.name || 'Établissement inconnu'
}

const getRequestIcon = (type: string) => {
  switch (type) {
    case 'new_qr': return Plus
    case 'qr_replacement': return RotateCcw
    case 'qr_update': return Upload
    case 'qr_deactivation': return XCircle
    case 'bulk_qr_generation': return QrCode
    case 'qr_customization': return Settings
    case 'technical_issue': return AlertTriangle
    default: return QrCode
  }
}

const getRequestTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    'new_qr': 'Nouveau QR',
    'qr_replacement': 'Remplacement',
    'qr_update': 'Mise à jour',
    'qr_deactivation': 'Désactivation',
    'bulk_qr_generation': 'Génération en masse',
    'qr_customization': 'Personnalisation',
    'technical_issue': 'Problème technique'
  }
  return labels[type] || type
}

const getPriorityLabel = (priority: string) => {
  const labels: Record<string, string> = {
    'low': 'Faible',
    'medium': 'Moyenne',
    'high': 'Élevée',
    'urgent': 'Urgente'
  }
  return labels[priority] || priority
}

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    'pending': 'En attente',
    'in_progress': 'En cours',
    'completed': 'Terminé',
    'cancelled': 'Annulé',
    'rejected': 'Rejeté'
  }
  return labels[status] || status
}

const getTypeBadgeClass = (type: string) => {
  const classes: Record<string, string> = {
    'new_qr': 'bg-blue-100 text-blue-800',
    'qr_replacement': 'bg-orange-100 text-orange-800',
    'qr_update': 'bg-purple-100 text-purple-800',
    'qr_deactivation': 'bg-red-100 text-red-800',
    'bulk_qr_generation': 'bg-indigo-100 text-indigo-800',
    'qr_customization': 'bg-pink-100 text-pink-800',
    'technical_issue': 'bg-yellow-100 text-yellow-800'
  }
  return classes[type] || 'bg-gray-100 text-gray-800'
}

const getPriorityBadgeClass = (priority: string) => {
  const classes: Record<string, string> = {
    'low': 'bg-gray-100 text-gray-800',
    'medium': 'bg-yellow-100 text-yellow-800',
    'high': 'bg-orange-100 text-orange-800',
    'urgent': 'bg-red-100 text-red-800'
  }
  return classes[priority] || 'bg-gray-100 text-gray-800'
}

const getStatusBadgeClass = (status: string) => {
  const classes: Record<string, string> = {
    'pending': 'bg-yellow-100 text-yellow-800',
    'in_progress': 'bg-blue-100 text-blue-800',
    'completed': 'bg-green-100 text-green-800',
    'cancelled': 'bg-gray-100 text-gray-800',
    'rejected': 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const applyFilters = () => {
  // Server-side filters (establishment, status) are applied via RPC
  // Client-side filters (priority, type, search) are applied via computed property
  filterRequests()
}

const filterRequests = async () => {
  try {
    loading.value = true

    const { data: filteredData, error } = await (supabase as any)
      .rpc('get_qr_support_requests_with_users', {
        establishment_filter: selectedEstablishment.value || null,
        status_filter: selectedStatus.value || null,
        limit_count: 1000,
        offset_count: 0
      })

    if (error) throw error
    requests.value = filteredData || []

  } catch (error) {
    console.error('Error filtering requests:', error)
    showToast.error('Erreur', 'Impossible de filtrer les demandes')
  } finally {
    loading.value = false
  }
}

const refreshData = () => {
  loadData()
}

const viewRequest = (request: QrSupportRequest) => {
  selectedRequest.value = request
  viewOnly.value = true
  newStatus.value = request.status
  resolutionNotes.value = ''
  showRequestModal.value = true
}

const editRequest = (request: QrSupportRequest) => {
  selectedRequest.value = request
  viewOnly.value = false
  newStatus.value = request.status
  resolutionNotes.value = request.resolution_notes || ''
  showRequestModal.value = true
}

const closeRequestModal = () => {
  showRequestModal.value = false
  selectedRequest.value = null
  newStatus.value = ''
  resolutionNotes.value = ''
}

const updateRequestStatus = async () => {
  if (!selectedRequest.value) return

  try {
    updating.value = true

    const updateData = {
      status: newStatus.value,
      updated_at: new Date().toISOString()
    } as any

    if (resolutionNotes.value.trim()) {
      updateData.resolution_notes = resolutionNotes.value.trim()
    }

    if (newStatus.value === 'completed' || newStatus.value === 'cancelled' || newStatus.value === 'rejected') {
      updateData.resolved_at = new Date().toISOString()
      updateData.resolved_by = 'admin' // TODO: Get current admin user
    }

    const { error } = await (supabase as any)
      .from('qr_support_requests')
      .update(updateData)
      .eq('id', selectedRequest.value.id)

    if (error) throw error

    // Update local state
    const index = requests.value.findIndex(r => r.id === selectedRequest.value!.id)
    if (index !== -1) {
      requests.value[index] = { ...requests.value[index], ...updateData }
    }

    showToast.success('Statut mis à jour', 'La demande a été mise à jour avec succès')
    closeRequestModal()
    await loadData() // Refresh data

  } catch (error) {
    console.error('Error updating request:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour la demande')
  } finally {
    updating.value = false
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Lifecycle
onMounted(() => {
  loadData()
})

definePageMeta({
  layout: 'admin'
})
</script>

<style scoped>
/* Smooth element appearance animation */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

tbody tr {
  animation: fadeIn 0.3s ease-out;
  animation-fill-mode: both;
}

tbody tr:nth-child(1) { animation-delay: 0.05s; }
tbody tr:nth-child(2) { animation-delay: 0.1s; }
tbody tr:nth-child(3) { animation-delay: 0.15s; }
tbody tr:nth-child(4) { animation-delay: 0.2s; }
tbody tr:nth-child(5) { animation-delay: 0.25s; }
</style>