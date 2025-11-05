<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Modern Header -->
    <ManagerModernHeader
      title="Support QR"
      subtitle="Demandes de support pour les QR codes"
      :icon="HelpCircle"
      :primary-action="{
        label: 'Nouvelle demande',
        icon: Plus,
        action: openNewRequestModal
      }"
    />

    <main class="max-w-7xl mx-auto px-8 pb-16 mt-2">
      <!-- Stats Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
              <HelpCircle class="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.total_requests || 0 }}</p>
              <p class="text-sm text-gray-500">Total demandes</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-yellow-50 rounded-xl flex items-center justify-center">
              <Clock class="w-6 h-6 text-yellow-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.pending_requests || 0 }}</p>
              <p class="text-sm text-gray-500">En attente</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-orange-50 rounded-xl flex items-center justify-center">
              <Loader2 class="w-6 h-6 text-orange-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.in_progress_requests || 0 }}</p>
              <p class="text-sm text-gray-500">En cours</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-red-50 rounded-xl flex items-center justify-center">
              <AlertTriangle class="w-6 h-6 text-red-600" />
            </div>
            <div>
              <p class="text-2xl font-bold text-gray-900">{{ stats?.urgent_requests || 0 }}</p>
              <p class="text-sm text-gray-500">Urgentes</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
          <div class="flex items-center gap-2">
            <Filter class="w-5 h-5 text-gray-400" />
            <span class="text-sm font-medium text-gray-700">Filtrer par:</span>
          </div>

          <select
            v-model="statusFilter"
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
            v-model="priorityFilter"
            class="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Toutes les priorités</option>
            <option value="urgent">Urgent</option>
            <option value="high">Élevé</option>
            <option value="medium">Moyen</option>
            <option value="low">Faible</option>
          </select>

          <select
            v-model="typeFilter"
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
        </div>
      </div>

      <!-- Requests List -->
      <div class="space-y-4">
        <div
          v-for="request in filteredRequests"
          :key="request.id"
          class="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h3 class="text-lg font-semibold text-gray-900">{{ request.title }}</h3>
                <span
                  :class="getStatusBadgeClass(request.status)"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ getStatusText(request.status) }}
                </span>
                <span
                  :class="getPriorityBadgeClass(request.priority)"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ getPriorityText(request.priority) }}
                </span>
              </div>

              <p class="text-sm text-gray-600 mb-3">{{ request.description }}</p>

              <div class="flex items-center gap-4 text-sm text-gray-500">
                <span>Type: {{ getRequestTypeText(request.request_type) }}</span>
                <span v-if="request.table_number">Table: {{ request.table_number }}</span>
                <span>{{ formatDate(request.created_at) }}</span>
              </div>
            </div>

            <div class="flex items-center gap-2 ml-4">
              <button
                v-if="request.status === 'pending'"
                @click="editRequest(request)"
                class="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                title="Modifier"
              >
                <Edit class="w-5 h-5" />
              </button>

              <button
                v-if="request.status === 'pending'"
                @click="cancelRequest(request)"
                class="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                title="Annuler"
              >
                <X class="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="filteredRequests.length === 0 && !loading" class="text-center py-16">
        <div class="w-16 h-16 bg-gray-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
          <HelpCircle class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune demande de support</h3>
        <p class="text-gray-500 mb-6">
          {{ requests.length === 0 ? 'Créez votre première demande de support QR.' : 'Aucune demande ne correspond à vos filtres.' }}
        </p>
        <button
          @click="openNewRequestModal"
          class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-xl font-medium transition-colors shadow-sm hover:shadow-md"
        >
          Créer une demande
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-16">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        <span class="ml-3 text-gray-600">Chargement...</span>
      </div>
    </main>

    <!-- New Request Modal -->
    <TransitionRoot appear :show="showNewRequestModal" as="template">
      <Dialog as="div" class="relative z-50" @close="closeModal">
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
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-3xl bg-white shadow-2xl transition-all">
                <div class="p-6">
                  <div class="flex items-center justify-between mb-6">
                    <h3 class="text-lg font-semibold text-gray-900">
                      {{ editingRequest ? 'Modifier la demande' : 'Nouvelle demande de support' }}
                    </h3>
                    <button
                      @click="closeModal"
                      class="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100"
                    >
                      <X class="w-5 h-5" />
                    </button>
                  </div>

                  <form @submit.prevent="submitRequest" class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Type de demande *
                      </label>
                      <select
                        v-model="requestForm.request_type"
                        required
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      >
                        <option value="">Sélectionnez un type</option>
                        <option value="new_qr">Nouveau QR code</option>
                        <option value="qr_replacement">Remplacement de QR code</option>
                        <option value="qr_update">Mise à jour de QR code</option>
                        <option value="qr_deactivation">Désactivation de QR code</option>
                        <option value="bulk_qr_generation">Génération de QR codes en masse</option>
                        <option value="qr_customization">Personnalisation de QR code</option>
                        <option value="technical_issue">Problème technique</option>
                      </select>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Titre *
                      </label>
                      <input
                        v-model="requestForm.title"
                        type="text"
                        required
                        placeholder="Titre de votre demande"
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Numéro de table (optionnel)
                      </label>
                      <input
                        v-model.number="requestForm.table_number"
                        type="number"
                        min="1"
                        placeholder="Ex: 5"
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Priorité
                      </label>
                      <select
                        v-model="requestForm.priority"
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      >
                        <option value="low">Faible</option>
                        <option value="medium">Moyen</option>
                        <option value="high">Élevé</option>
                        <option value="urgent">Urgent</option>
                      </select>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">
                        Description *
                      </label>
                      <textarea
                        v-model="requestForm.description"
                        required
                        rows="4"
                        placeholder="Décrivez votre demande en détail..."
                        class="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                      ></textarea>
                    </div>

                    <div class="flex gap-3 pt-4">
                      <button
                        type="button"
                        @click="closeModal"
                        class="flex-1 px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                      >
                        Annuler
                      </button>
                      <button
                        type="submit"
                        :disabled="submitting"
                        class="flex-1 px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {{ submitting ? 'Envoi...' : (editingRequest ? 'Modifier' : 'Envoyer') }}
                      </button>
                    </div>
                  </form>
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
import { ref, computed, onMounted, watch } from 'vue'
import { TransitionRoot, TransitionChild, Dialog, DialogPanel } from '@headlessui/vue'
import {
  HelpCircle,
  Plus,
  Clock,
  Loader2,
  AlertTriangle,
  Filter,
  Edit,
  X
} from 'lucide-vue-next'
import { useQrSupport } from '~/composables/useQrSupport'
import { useEstablishment } from '~/composables/useEstablishment'
import { useSupabaseWrapper } from '~/composables/useSupabase'
// import ManagerModernHeader from '~/components/ManagerModernHeader.vue'
definePageMeta({
  layout: 'manager'
})
const route = useRoute()
const slug = route.params.slug

const { establishment } = useEstablishment()
const { client: supabase } = useSupabaseWrapper()
const {
  loading,
  requests,
  fetchRequests,
  createRequest,
  updateRequest,
  cancelRequest,
  getStats
} = useQrSupport()

// Local state
const showNewRequestModal = ref(false)
const editingRequest = ref(null)
const submitting = ref(false)
const stats = ref(null)

// Filters
const statusFilter = ref('')
const priorityFilter = ref('')
const typeFilter = ref('')

// Form data
const requestForm = ref({
  request_type: '',
  title: '',
  table_number: null as number | null,
  priority: 'medium',
  description: ''
})

// Computed
const filteredRequests = computed(() => {
  let filtered = requests.value

  if (statusFilter.value) {
    filtered = filtered.filter(r => r.status === statusFilter.value)
  }

  if (priorityFilter.value) {
    filtered = filtered.filter(r => r.priority === priorityFilter.value)
  }

  if (typeFilter.value) {
    filtered = filtered.filter(r => r.request_type === typeFilter.value)
  }

  return filtered
})

// Methods
const openNewRequestModal = () => {
  editingRequest.value = null
  requestForm.value = {
    request_type: '',
    title: '',
    table_number: null,
    priority: 'medium',
    description: ''
  }
  showNewRequestModal.value = true
}

const editRequest = (request: any) => {
  editingRequest.value = request
  requestForm.value = {
    request_type: request.request_type,
    title: request.title,
    table_number: request.table_number,
    priority: request.priority,
    description: request.description || ''
  }
  showNewRequestModal.value = true
}

const closeModal = () => {
  showNewRequestModal.value = false
  editingRequest.value = null
}

const submitRequest = async () => {
  if (!establishment.value?.id) return

  submitting.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('User not authenticated')

    const requestData = {
      establishment_id: establishment.value.id,
      requested_by: user.id,
      ...requestForm.value
    }

    if (editingRequest.value) {
      await updateRequest(editingRequest.value.id, requestForm.value)
    } else {
      await createRequest(requestData)
    }

    closeModal()
    await loadData()
  } catch (error) {
    console.error('Error submitting request:', error)
  } finally {
    submitting.value = false
  }
}

const confirmCancelRequest = (request: any) => {
  if (confirm('Êtes-vous sûr de vouloir annuler cette demande ?')) {
    cancelRequest(request.id)
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getStatusBadgeClass = (status: string) => {
  const classes = {
    pending: 'bg-yellow-100 text-yellow-800',
    in_progress: 'bg-blue-100 text-blue-800',
    completed: 'bg-green-100 text-green-800',
    cancelled: 'bg-gray-100 text-gray-800',
    rejected: 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const getPriorityBadgeClass = (priority: string) => {
  const classes = {
    low: 'bg-gray-100 text-gray-800',
    medium: 'bg-blue-100 text-blue-800',
    high: 'bg-orange-100 text-orange-800',
    urgent: 'bg-red-100 text-red-800'
  }
  return classes[priority] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status: string) => {
  const texts = {
    pending: 'En attente',
    in_progress: 'En cours',
    completed: 'Terminé',
    cancelled: 'Annulé',
    rejected: 'Rejeté'
  }
  return texts[status] || status
}

const getPriorityText = (priority: string) => {
  const texts = {
    low: 'Faible',
    medium: 'Moyen',
    high: 'Élevé',
    urgent: 'Urgent'
  }
  return texts[priority] || priority
}

const getRequestTypeText = (type: string) => {
  const texts = {
    new_qr: 'Nouveau QR',
    qr_replacement: 'Remplacement',
    qr_update: 'Mise à jour',
    qr_deactivation: 'Désactivation',
    bulk_qr_generation: 'Génération en masse',
    qr_customization: 'Personnalisation',
    technical_issue: 'Problème technique'
  }
  return texts[type] || type
}

const loadData = async () => {
  if (establishment.value?.id) {
    await fetchRequests(establishment.value.id)
    stats.value = await getStats(establishment.value.id)
  }
}

// Lifecycle
onMounted(loadData)

// Watch for establishment changes
watch(() => establishment.value?.id, loadData)
</script>

<style scoped>
/* Custom styles if needed */
</style>