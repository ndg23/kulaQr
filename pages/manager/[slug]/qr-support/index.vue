<template>
  <div>
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

    <main>
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

  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
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
  cancelRequest,
  getStats
} = useQrSupport()

// Local state
const stats = ref(null)

// Filters
const statusFilter = ref('')
const priorityFilter = ref('')
const typeFilter = ref('')


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
// Chaque action a sa page
const openNewRequestModal = () => navigateTo(`/manager/${slug}/qr-support/new`)

const editRequest = (request: any) => navigateTo(`/manager/${slug}/qr-support/${request.id}/edit`)

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