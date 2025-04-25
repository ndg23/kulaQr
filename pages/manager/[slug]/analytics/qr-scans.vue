<template>
  <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    <!-- En-tête -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Analyse des scans QR</h1>
        <p class="mt-1 text-sm text-gray-500">Suivez l'utilisation des QR codes de votre établissement</p>
      </div>
      
      <!-- Filtres de date -->
      <div class="flex space-x-4">
        <select 
          v-model="period" 
          class="rounded-md border-gray-300 shadow-sm focus:border-kula-500 focus:ring-kula-500"
          @change="loadData"
        >
          <option value="today">Aujourd'hui</option>
          <option value="yesterday">Hier</option>
          <option value="week">7 derniers jours</option>
          <option value="month">30 derniers jours</option>
          <option value="all">Tout</option>
        </select>
        
        <button 
          @click="loadData" 
          class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kula-500"
        >
          <RefreshCw class="h-4 w-4 mr-1.5" :class="{ 'animate-spin': loading }" />
          Actualiser
        </button>
      </div>
    </div>

    <!-- Cartes de statistiques -->
    <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-kula-100 rounded-md p-3">
              <QrCode class="h-6 w-6 text-kula-600" />
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Total des scans</dt>
                <dd class="flex items-baseline">
                  <div class="text-2xl font-semibold text-gray-900">{{ stats.totalScans }}</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-green-100 rounded-md p-3">
              <TrendingUp class="h-6 w-6 text-green-600" />
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Scans aujourd'hui</dt>
                <dd class="flex items-baseline">
                  <div class="text-2xl font-semibold text-gray-900">{{ stats.todayScans }}</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-blue-100 rounded-md p-3">
              <Users class="h-6 w-6 text-blue-600" />
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Visiteurs uniques</dt>
                <dd class="flex items-baseline">
                  <div class="text-2xl font-semibold text-gray-900">{{ stats.uniqueVisitors }}</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-purple-100 rounded-md p-3">
              <ShoppingCart class="h-6 w-6 text-purple-600" />
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Taux de conversion</dt>
                <dd class="flex items-baseline">
                  <div class="text-2xl font-semibold text-gray-900">{{ stats.conversionRate }}%</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Graphique des scans par jour -->
    <div class="bg-white shadow rounded-lg p-6 mb-8">
      <h2 class="text-lg font-medium text-gray-900 mb-4">Scans par jour</h2>
      <div class="h-64">
        <!-- Intégrer ici un composant de graphique (Chart.js, ApexCharts, etc.) -->
        <div v-if="loading" class="h-full flex items-center justify-center">
          <Loader2 class="h-8 w-8 text-kula-500 animate-spin" />
        </div>
        <div v-else-if="!chartData.labels.length" class="h-full flex items-center justify-center text-gray-500">
          Aucune donnée disponible pour la période sélectionnée
        </div>
        <canvas v-else ref="chartCanvas" class="h-full w-full"></canvas>
      </div>
    </div>

    <!-- Tableau des scans récents -->
    <div class="bg-white shadow rounded-lg overflow-hidden">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <h2 class="text-lg font-medium text-gray-900">Scans récents</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Table
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Appareil
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Source
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-if="loading">
              <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">
                Chargement...
              </td>
            </tr>
            <tr v-else-if="!recentScans.length">
              <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">
                Aucun scan récent
              </td>
            </tr>
            <tr v-for="scan in recentScans" :key="scan.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(scan.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                Table {{ scan.table_number }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ getDeviceType(scan.user_agent) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ getReferrerSource(scan.referrer) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="bg-gray-50 px-4 py-3 border-t border-gray-200 sm:px-6">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            Affichage de <span class="font-medium">{{ recentScans.length }}</span> scans récents
          </div>
          <div>
            <button 
              @click="loadMoreScans" 
              class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              :disabled="!hasMoreScans || loading"
            >
              Voir plus
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { QrCode, TrendingUp, Users, ShoppingCart, RefreshCw, Loader2 } from 'lucide-vue-next'
import Chart from 'chart.js/auto'

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const establishmentId = ref('')
const slug = ref(route.params.slug)

// État
const loading = ref(false)
const period = ref('week')
const stats = ref({
  totalScans: 0,
  todayScans: 0,
  uniqueVisitors: 0,
  conversionRate: 0
})
const recentScans = ref([])
const hasMoreScans = ref(true)
const scanLimit = 10
const scanOffset = ref(0)
const chartCanvas = ref(null)
const chartInstance = ref(null)
const chartData = ref({
  labels: [],
  datasets: [{
    label: 'Nombre de scans',
    data: [],
    backgroundColor: 'rgba(99, 102, 241, 0.2)',
    borderColor: 'rgba(99, 102, 241, 1)',
    borderWidth: 1
  }]
})

// Charger les données
const loadData = async () => {
  loading.value = true
  
  try {
    // Récupérer l'ID de l'établissement à partir du slug
    if (!establishmentId.value) {
      const { data: estData } = await supabase
        .from('establishments')
        .select('id')
        .eq('slug', slug.value)
        .single()
      
      if (estData) {
        establishmentId.value = estData.id
      }
    }
    
    // Charger les statistiques
    await Promise.all([
      loadStats(),
      loadRecentScans(),
      loadChartData()
    ])
    
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
  } finally {
    loading.value = false
  }
}

// Charger les statistiques
const loadStats = async () => {
  try {
    // Total des scans
    const { count: totalCount } = await supabase
      .from('qr_scans')
      .select('id', { count: 'exact' })
      .eq('establishment_id', establishmentId.value)
    
    stats.value.totalScans = totalCount || 0
    
    // Scans aujourd'hui
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    const { count: todayCount } = await supabase
      .from('qr_scans')
      .select('id', { count: 'exact' })
      .eq('establishment_id', establishmentId.value)
      .gte('created_at', today.toISOString())
    
    stats.value.todayScans = todayCount || 0
    
    // Visiteurs uniques (approximation basée sur user_agent)
    const { data: uniqueAgents } = await supabase
      .from('qr_scans')
      .select('user_agent')
      .eq('establishment_id', establishmentId.value)
      .is('user_agent', 'not.null')
    
    const uniqueAgentSet = new Set(uniqueAgents?.map(scan => scan.user_agent))
    stats.value.uniqueVisitors = uniqueAgentSet.size
    
    // Taux de conversion (scans qui ont mené à une commande)
    const { count: ordersCount } = await supabase
      .from('orders')
      .select('id', { count: 'exact' })
      .eq('establishment_id', establishmentId.value)
    
    stats.value.conversionRate = stats.value.totalScans 
      ? Math.round((ordersCount / stats.value.totalScans) * 100) 
      : 0
    
  } catch (error) {
    console.error('Erreur lors du chargement des statistiques:', error)
  }
}

// Charger les scans récents
const loadRecentScans = async () => {
  try {
    const { data } = await supabase
      .from('qr_scans')
      .select('id, created_at, table_number, user_agent, referrer')
      .eq('establishment_id', establishmentId.value)
      .order('created_at', { ascending: false })
      .range(scanOffset.value, scanOffset.value + scanLimit - 1)
    
    if (data) {
      if (scanOffset.value === 0) {
        recentScans.value = data
      } else {
        recentScans.value = [...recentScans.value, ...data]
      }
      
      hasMoreScans.value = data.length === scanLimit
    }
    
  } catch (error) {
    console.error('Erreur lors du chargement des scans récents:', error)
  }
}

// Charger plus de scans
const loadMoreScans = () => {
  scanOffset.value += scanLimit
  loadRecentScans()
}

// Charger les données du graphique
const loadChartData = async () => {
  try {
    let startDate
    const endDate = new Date()
    
    // Déterminer la date de début en fonction de la période
    switch (period.value) {
      case 'today':
        startDate = new Date()
        startDate.setHours(0, 0, 0, 0)
        break
      case 'yesterday':
        startDate = new Date()
        startDate.setDate(startDate.getDate() - 1)
        startDate.setHours(0, 0, 0, 0)
        endDate.setDate(endDate.getDate() - 1)
        endDate.setHours(23, 59, 59, 999)
        break
      case 'week':
        startDate = new Date()
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'month':
        startDate = new Date()
        startDate.setDate(startDate.getDate() - 30)
        break
      default:
        // Pour 'all', on récupère les données des 90 derniers jours maximum
        startDate = new Date()
        startDate.setDate(startDate.getDate() - 90)
    }
    
    // Récupérer les scans par jour
    const { data } = await supabase
      .from('qr_scans')
      .select('created_at')
      .eq('establishment_id', establishmentId.value)
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString())
      .order('created_at')
    
    if (!data || !data.length) {
      chartData.value.labels = []
      chartData.value.datasets[0].data = []
      return
    }
    
    // Regrouper les scans par jour
    const scansByDay = {}
    
    data.forEach(scan => {
      const date = new Date(scan.created_at)
      const dateStr = date.toISOString().split('T')[0]
      
      if (!scansByDay[dateStr]) {
        scansByDay[dateStr] = 0
      }
      
      scansByDay[dateStr]++
    })
    
    // Préparer les données pour le graphique
    const labels = Object.keys(scansByDay).sort()
    const values = labels.map(label => scansByDay[label])
    
    chartData.value.labels = labels.map(label => {
      const date = new Date(label)
      return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
    })
    chartData.value.datasets[0].data = values
    
    // Mettre à jour le graphique
    updateChart()
    
  } catch (error) {
    console.error('Erreur lors du chargement des données du graphique:', error)
  }
}

// Mettre à jour le graphique
const updateChart = () => {
  if (chartInstance.value) {
    chartInstance.value.destroy()
  }
  
  if (chartCanvas.value && chartData.value.labels.length) {
    chartInstance.value = new Chart(chartCanvas.value, {
      type: 'bar',
      data: chartData.value,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      }
    })
  }
}

// Formater la date
const formatDate = (dateStr) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Déterminer le type d'appareil
const getDeviceType = (userAgent) => {
  if (!userAgent) return 'Inconnu'
  
  if (userAgent.match(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i)) {
    return 'Mobile'
  } else {
    return 'Ordinateur'
  }
}

// Déterminer la source du scan
const getReferrerSource = (referrer) => {
  if (!referrer || referrer === 'direct') return 'Direct'
  
  if (referrer.includes('staff_app')) {
    return 'Application personnel'
  } else if (referrer.includes('google')) {
    return 'Google'
  } else if (referrer.includes('facebook')) {
    return 'Facebook'
  } else if (referrer.includes('instagram')) {
    return 'Instagram'
  } else {
    return 'Autre'
  }
}

// Observer les changements de période
watch(period, () => {
  loadData()
})

// Charger les données au montage
onMounted(() => {
  loadData()
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