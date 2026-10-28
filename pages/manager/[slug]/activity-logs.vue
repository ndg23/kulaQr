<template>
    <div>
      <PageHeader title="Journaux d'activité" description="Suivez les activités de votre personnel">
        <template #actions>
          <select
            v-model="filters.staffId"
            class="h-12 px-5 rounded-full bg-gray-100 border-0 font-bold text-gray-900 focus:ring-2 focus:ring-gray-900"
          >
            <option value="">Tous les membres</option>
            <option v-for="member in staffMembers" :key="member.id" :value="member.id">
              {{ member.username }}
            </option>
          </select>

          <select
            v-model="filters.action"
            class="h-12 px-5 rounded-full bg-gray-100 border-0 font-bold text-gray-900 focus:ring-2 focus:ring-gray-900"
          >
            <option value="">Toutes les actions</option>
            <option value="login">Connexion</option>
            <option value="logout">Déconnexion</option>
            <option value="order_created">Commande créée</option>
            <option value="order_updated">Commande mise à jour</option>
            <option value="order_completed">Commande terminée</option>
          </select>

          <button
            class="inline-flex items-center gap-2 h-12 px-5 rounded-full bg-gray-900 text-white font-bold hover:bg-gray-800 transition-colors"
            @click="loadLogs"
          >
            <RefreshCw class="h-4 w-4" :class="{ 'animate-spin': loading }" />
            Actualiser
          </button>
        </template>
      </PageHeader>

      <!-- Loading State -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-12">
        <Loader2 class="w-10 h-10 text-gray-900 animate-spin mb-4" />
        <p class="text-sm text-gray-500">Chargement des journaux d'activité...</p>
      </div>
  
      <!-- Empty State -->
      <div v-else-if="logs.length === 0" class="bg-white rounded-[2rem] border border-gray-200 p-12 text-center">
        <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
          <ClipboardList class="w-8 h-8 text-gray-900" />
        </div>
        <h3 class="text-lg font-extrabold text-gray-900 mb-2">Aucune activité enregistrée</h3>
        <p class="text-gray-500 mb-6 max-w-md mx-auto">
          Aucune activité n'a été enregistrée pour le moment ou selon les filtres sélectionnés.
        </p>
      </div>
  
      <!-- Logs Table -->
      <div v-else class="bg-white rounded-[2rem] border border-gray-200 overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-100">
          <h2 class="text-lg font-extrabold text-gray-900">Journaux d'activité</h2>
        </div>
        
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-100">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">
                  Date
                </th>
                <th scope="col" class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">
                  Membre
                </th>
                <th scope="col" class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">
                  Action
                </th>
                <th scope="col" class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">
                  Détails
                </th>
                <th scope="col" class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">
                  Appareil
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-100">
              <tr v-for="log in logs" :key="log.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(log.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="h-10 w-10 flex-shrink-0">
                      <div class="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
                        <User class="h-5 w-5 text-green-900" />
                      </div>
                    </div>
                    <div class="ml-3">
                      <div class="text-sm font-bold text-gray-900">
                        {{ getStaffName(log.staff_id) }}
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-3 h-7 inline-flex items-center text-xs font-bold rounded-full" :class="getActionClass(log.action)">
                    {{ getActionName(log.action) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDetails(log.details) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatUserAgent(log.user_agent) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Pagination -->
        <div class="bg-white px-4 py-4 flex items-center justify-between border-t border-gray-100 sm:px-6">
          <div class="flex-1 flex justify-between sm:hidden">
            <button
              @click="page > 1 ? page-- : null"
              :disabled="page <= 1"
              class="relative inline-flex items-center h-10 px-5 text-sm font-bold rounded-full text-gray-900 bg-gray-100 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Précédent
            </button>
            <button
              @click="page < totalPages ? page++ : null"
              :disabled="page >= totalPages"
              class="ml-3 relative inline-flex items-center h-10 px-5 text-sm font-bold rounded-full text-gray-900 bg-gray-100 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Suivant
            </button>
          </div>
          <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p class="text-sm text-gray-700">
                Affichage de <span class="font-bold">{{ (page - 1) * perPage + 1 }}</span> à <span class="font-bold">{{ Math.min(page * perPage, totalLogs) }}</span> sur <span class="font-bold">{{ totalLogs }}</span> résultats
              </p>
            </div>
            <div>
              <nav class="relative z-0 inline-flex rounded-full gap-1" aria-label="Pagination">
                <button
                  @click="page > 1 ? page-- : null"
                  :disabled="page <= 1"
                  class="inline-flex items-center justify-center h-10 w-10 rounded-full bg-gray-100 text-gray-900 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span class="sr-only">Précédent</span>
                  <ChevronLeft class="h-5 w-5" />
                </button>
                <button
                  @click="page < totalPages ? page++ : null"
                  :disabled="page >= totalPages"
                  class="inline-flex items-center justify-center h-10 w-10 rounded-full bg-gray-100 text-gray-900 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span class="sr-only">Suivant</span>
                  <ChevronRight class="h-5 w-5" />
                </button>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, reactive, computed, onMounted, watch } from 'vue'
  import { useRoute } from 'vue-router'
  import { 
    User, Loader2, RefreshCw, ClipboardList,
    ChevronLeft, ChevronRight
  } from 'lucide-vue-next'
  import { useSupabaseWrapper } from '~/composables/useSupabase'
  import { useCustomToast } from '~/composables/useToast'
  import { useEstablishment } from '~/composables/useEstablishment'
  
  const route = useRoute()
  const { client: supabase } = useSupabaseWrapper()
  const { showToast } = useCustomToast()
  const { establishment } = useEstablishment()
  
  // State
  const logs = ref([])
  const staffMembers = ref([])
  const loading = ref(true)
  const totalLogs = ref(0)
  const page = ref(1)
  const perPage = ref(10)
  const filters = reactive({
    staffId: '',
    action: ''
  })
  
  // Computed
  const totalPages = computed(() => {
    return Math.ceil(totalLogs.value / perPage.value)
  })
  
  // Methods
  const loadLogs = async () => {
    loading.value = true
    
    try {
      // Build query
      let query = supabase
        .from('staff_activity_logs')
        .select('*', { count: 'exact' })
        .eq('establishment_id', establishment.value?.id)
        .order('created_at', { ascending: false })
        .range((page.value - 1) * perPage.value, page.value * perPage.value - 1)
      
      // Apply filters
      if (filters.staffId) {
        query = query.eq('staff_id', filters.staffId)
      }
      
      if (filters.action) {
        query = query.eq('action', filters.action)
      }
      
      // Execute query
      const { data, error, count } = await query
      
      if (error) throw error
      
      logs.value = data || []
      totalLogs.value = count || 0
    } catch (err) {
      console.error('Error loading logs:', err)
      showToast.error('Erreur', 'Impossible de charger les journaux d\'activité')
    } finally {
      loading.value = false
    }
  }
  
  const loadStaffMembers = async () => {
    try {
      const { data, error } = await supabase
        .from('staff')
        .select('id, username')
        .eq('establishment_id', establishment.value?.id)
        .order('username')
      
      if (error) throw error
      
      staffMembers.value = data || []
    } catch (err) {
      console.error('Error loading staff members:', err)
    }
  }
  
  const getStaffName = (staffId) => {
    const staff = staffMembers.value.find(s => s.id === staffId)
    return staff ? staff.username : 'Inconnu'
  }
  
  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  }
  
  const getActionName = (action) => {
    const actions = {
      login: 'Connexion',
      logout: 'Déconnexion',
      order_created: 'Commande créée',
      order_updated: 'Commande mise à jour',
      order_completed: 'Commande terminée'
    }
    return actions[action] || action
  }
  
  const getActionClass = (action) => {
    const classes = {
      login: 'bg-green-100 text-green-900',
      logout: 'bg-gray-100 text-gray-900',
      order_created: 'bg-blue-100 text-blue-900',
      order_updated: 'bg-yellow-100 text-yellow-900',
      order_completed: 'bg-purple-100 text-purple-900'
    }
    return classes[action] || 'bg-gray-100 text-gray-800'
  }
  
  const formatDetails = (details) => {
    if (!details) return '-'
    
    try {
      if (typeof details === 'string') {
        details = JSON.parse(details)
      }
      
      // Format based on action type
      if (details.method) {
        return `Méthode: ${details.method}`
      }
      
      return Object.entries(details)
        .map(([key, value]) => `${key}: ${value}`)
        .join(', ')
    } catch (e) {
      return String(details)
    }
  }
  
  const formatUserAgent = (userAgent) => {
    if (!userAgent) return '-'
    
    // Simplify user agent string
    if (userAgent.includes('Mobile')) {
      return 'Mobile'
    } else if (userAgent.includes('iPad') || userAgent.includes('Tablet')) {
      return 'Tablette'
    } else {
      return 'Ordinateur'
    }
  }
  
  // Watch for changes in filters or pagination
  watch([filters, page], () => {
    loadLogs()
  })
  
  // Load data on mount
  onMounted(async () => {
    await Promise.all([
      loadStaffMembers(),
      loadLogs()
    ])
  })
  
  definePageMeta({
    layout: 'manager'
  })
  </script>
  
  <style scoped>
  .animate-spin {
    animation: spin 1s linear infinite;
  }
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  </style>