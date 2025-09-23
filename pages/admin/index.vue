<template>
    <div class="p-6 lg:p-8">
      <!-- Header -->
      <div class="mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Tableau de bord</h1>
        <p class="text-lg text-gray-600">Bienvenue sur votre espace d'administration</p>
      </div>
  
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-3 gap-8 mb-12">
        <div v-for="stat in statsDisplay" :key="stat.name" 
          class="bg-white p-8 rounded-[2rem] border border-gray-100 transition-all -hover:scale-[1.02] -hover:shadow-lg"
        >
          <div class="flex items-center space-x-6">
            <div class="w-16 h-16 rounded-2xl flex items-center justify-center"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" class="w-8 h-8" :class="stat.iconColor" />
            </div>
            <div>
              <p class="text-base text-gray-500 mb-1">{{ stat.name }}</p>
              <h3 class="text-3xl font-bold text-gray-900">{{ stat.value }}</h3>
            </div>
          </div>
        </div>
      </div>
  
      <!-- Recent Activity -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden mb-12">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">Activité récente</h2>
            <UButton
              icon="i-lucide-refresh-cw"
              color="gray"
              variant="ghost"
              :loading="loadingActivity"
              @click="loadRecentActivity"
            />
          </div>
        </div>
        
        <div class="p-6">
          <div v-if="loadingActivity" class="flex justify-center py-8">
            <Loader2 class="w-8 h-8 animate-spin text-gray-400" />
          </div>
          
          <div v-else-if="recentActivity.length === 0" class="py-8 text-center text-gray-500">
            <Info class="w-12 h-12 mx-auto mb-3 text-gray-300" />
            <p>Aucune activité récente</p>
          </div>
          
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="activity in recentActivity" :key="activity.id" class="py-4">
              <div class="flex items-start">
                <UAvatar
                  :text="getUserInitials(activity.user_name)"
                  :color="getUserColor(activity.user_id)"
                  size="sm"
                  class="mr-3 mt-0.5"
                />
                <div class="flex-1">
                  <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-gray-900">
                      {{ activity.user_name || 'Utilisateur inconnu' }}
                    </p>
                    <span class="text-xs text-gray-500">
                      {{ formatDate(activity.created_at, 'relative') }}
                    </span>
                  </div>
                  <p class="text-sm text-gray-600 mt-1">
                    {{ formatActivityMessage(activity) }}
                  </p>
                </div>
              </div>
            </li>
          </ul>
          
          <div v-if="recentActivity.length > 0" class="mt-4 text-center">
            <UButton
              v-if="hasMoreActivity"
              variant="ghost"
              color="gray"
              @click="loadMoreActivity"
              :loading="loadingMoreActivity"
            >
              Voir plus d'activités
            </UButton>
          </div>
        </div>
      </div>
  
      <!-- Recent Establishments -->
      <div class="bg-white rounded-[2rem] border border-gray-100 overflow-hidden mb-12">
        <div class="p-6 border-b border-gray-100">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">Établissements récents</h2>
            <UButton
              icon="i-lucide-refresh-cw"
              color="gray"
              variant="ghost"
              :loading="loadingEstablishments"
              @click="loadRecentEstablishments"
            />
          </div>
        </div>
        
        <div class="p-6">
          <div v-if="loadingEstablishments" class="flex justify-center py-8">
            <Loader2 class="w-8 h-8 animate-spin text-gray-400" />
          </div>
          
          <div v-else-if="recentEstablishments.length === 0" class="py-8 text-center text-gray-500">
            <Store class="w-12 h-12 mx-auto mb-3 text-gray-300" />
            <p>Aucun établissement récent</p>
          </div>
          
          <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div v-for="establishment in recentEstablishments" :key="establishment.id" 
              class="bg-gray-50 rounded-xl p-4 hover:bg-gray-100 transition-colors"
            >
              <div class="flex items-start">
                <div class="w-12 h-12 rounded-lg bg-white flex items-center justify-center mr-4">
                  <Store class="w-6 h-6 text-gray-500" />
                </div>
                <div class="flex-1">
                  <h3 class="font-medium text-gray-900">{{ establishment.name }}</h3>
                  <p class="text-sm text-gray-500 mt-1">
                    Créé le {{ formatDate(establishment.created_at, 'date') }}
                  </p>
                  <div class="flex items-center mt-2">
                    <UBadge
                      :color="establishment.is_active ? 'green' : 'red'"
                      variant="subtle"
                      size="sm"
                      class="mr-2"
                    >
                      {{ establishment.is_active ? 'Actif' : 'Inactif' }}
                    </UBadge>
                    <UButton
                      size="xs"
                      color="gray"
                      variant="ghost"
                      icon="i-lucide-external-link"
                      :to="`/admin/establishments/${establishment.id}`"
                    >
                      Voir
                    </UButton>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div v-if="recentEstablishments.length > 0" class="mt-6 text-center">
            <UButton
              to="/admin/establishments"
              variant="outline"
              color="gray"
            >
              Voir tous les établissements
            </UButton>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { 
    Users, UserCheck, Shield, Activity, Utensils, ShoppingBag, 
    Settings, RefreshCw, Info, Loader2, ChevronRight, Store,
    QrCode, Package, CreditCard, Calendar, TrendingUp
  } from 'lucide-vue-next'
  import { useCustomToast } from '~/composables/useToast'
  import { useSupabaseWrapper } from '~/composables/useSupabase'
  
  const { showToast } = useCustomToast()
  const { client: supabase } = useSupabaseWrapper()
  
  // Stats
  const adminStats = ref({
    total_users: 0,
    active_users_7d: 0,
    total_establishments: 0,
    active_establishments: 0,
    total_orders: 0,
    orders_24h: 0,
    total_revenue: 0,
    total_products: 0,
    total_qr_scans: 0,
    qr_scans_24h: 0
  })
  
  const loadStats = async () => {
    try {
      // Charger les statistiques depuis la vue admin_statistics
      const { data, error } = await supabase
        .from('admin_statistics')
        .select('*')
        .single()
      
      if (error) throw error
      
      if (data) {
        adminStats.value = data
      }
      
    } catch (error) {
      console.error('Error loading stats:', error)
      showToast.error('Impossible de charger les statistiques', 'error')
    }
  }
  
  // Stats display
  const statsDisplay = computed(() => [
    { 
      name: 'Utilisateurs', 
      value: adminStats.value.total_users.toString(),
      icon: Users,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-500'
    },
    { 
      name: 'Utilisateurs actifs', 
      value: adminStats.value.active_users_7d.toString(),
      icon: UserCheck,
      iconBg: 'bg-green-50',
      iconColor: 'text-green-500'
    },
    { 
      name: 'Établissements', 
      value: adminStats.value.total_establishments.toString(),
      icon: Store,
      iconBg: 'bg-purple-50',
      iconColor: 'text-purple-500'
    },
    { 
      name: 'Commandes', 
      value: adminStats.value.total_orders.toString(),
      icon: ShoppingBag,
      iconBg: 'bg-amber-50',
      iconColor: 'text-amber-500'
    },
    { 
      name: 'Produits', 
      value: adminStats.value.total_products.toString(),
      icon: Package,
      iconBg: 'bg-indigo-50',
      iconColor: 'text-indigo-500'
    },
    { 
      name: 'Scans QR', 
      value: adminStats.value.total_qr_scans.toString(),
      icon: QrCode,
      iconBg: 'bg-rose-50',
      iconColor: 'text-rose-500'
    }
  ])
  
  // Recent Activity
  const recentActivity = ref([])
  const loadingActivity = ref(false)
  const loadingMoreActivity = ref(false)
  const activityPage = ref(1)
  const activityLimit = 5
  const hasMoreActivity = ref(true)
  
  // Load recent activity
  const loadRecentActivity = async () => {
    try {
      loadingActivity.value = true
      activityPage.value = 1
      
      const { data, error } = await supabase
        .from('recent_activity')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(activityLimit)
      
      if (error) throw error
      
      recentActivity.value = data
      hasMoreActivity.value = data.length === activityLimit
      
    } catch (err) {
      console.error('Error loading activity:', err)
      showToast.error('Impossible de charger les activités récentes', 'error')
    } finally {
      loadingActivity.value = false
    }
  }
  
  // Load more activity
  const loadMoreActivity = async () => {
    if (loadingMoreActivity.value) return
    
    try {
      loadingMoreActivity.value = true
      activityPage.value += 1
      
      const { data, error } = await supabase
        .from('recent_activity')
        .select('*')
        .order('created_at', { ascending: false })
        .range((activityPage.value - 1) * activityLimit, activityPage.value * activityLimit - 1)
      
      if (error) throw error
      
      recentActivity.value = [...recentActivity.value, ...data]
      hasMoreActivity.value = data.length === activityLimit
      
    } catch (err) {
      console.error('Error loading more activity:', err)
      showToast.error('Impossible de charger plus d\'activités', 'error')
    } finally {
      loadingMoreActivity.value = false
    }
  }
  
  // Recent Establishments
  const recentEstablishments = ref([])
  const loadingEstablishments = ref(false)
  
  // Load recent establishments
  const loadRecentEstablishments = async () => {
    try {
      loadingEstablishments.value = true
      
      const { data, error } = await supabase
        .from('establishments')
        .select('id, name, created_at, is_active')
        .order('created_at', { ascending: false })
        .limit(6)
      
      if (error) throw error
      
      recentEstablishments.value = data
      
    } catch (err) {
      console.error('Error loading establishments:', err)
      showToast.error('Impossible de charger les établissements récents', 'error')
    } finally {
      loadingEstablishments.value = false
    }
  }
  
  // Format activity message
  const formatActivityMessage = (activity) => {
    const entityTypes = {
      'user': 'utilisateur',
      'restaurant': 'restaurant',
      'establishment': 'établissement',
      'menu': 'menu',
      'dish': 'plat',
      'product': 'produit',
      'order': 'commande'
    }
    
    const actionTypes = {
      'create': 'a créé',
      'update': 'a modifié',
      'delete': 'a supprimé',
      'login': 's\'est connecté',
      'logout': 's\'est déconnecté',
      'register': 's\'est inscrit'
    }
    
    const entityType = entityTypes[activity.entity_type] || activity.entity_type
    const actionType = actionTypes[activity.action_type] || activity.action_type
    
    let message = `${actionType} un ${entityType}`
    
    // Add details if available
    if (activity.details && typeof activity.details === 'object') {
      if (activity.details.name) {
        message += ` "${activity.details.name}"`
      } else if (activity.details.id) {
        message += ` #${activity.details.id}`
      }
    }
    
    return message
  }
  
  // Helper methods
  const getUserInitials = (name) => {
    if (!name) return '?'
    return name.split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase()
      .substring(0, 2)
  }
  
  const getUserColor = (id) => {
    const colors = ['blue', 'green', 'red', 'yellow', 'purple', 'pink', 'orange', 'cyan']
    const index = Math.abs(hashString(id?.toString() || '0') % colors.length)
    return colors[index]
  }
  
  const hashString = (str) => {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i)
      hash = hash & hash
    }
    return hash
  }
  
  // Format date helper
  const formatDate = (dateString, format = 'date') => {
    if (!dateString) return 'N/A'
    
    const date = new Date(dateString)
    
    if (format === 'date') {
      return date.toLocaleDateString('fr-FR')
    } else if (format === 'time') {
      return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
    } else if (format === 'relative') {
      const now = new Date()
      const diffMs = now - date
      const diffSec = Math.floor(diffMs / 1000)
      const diffMin = Math.floor(diffSec / 60)
      const diffHour = Math.floor(diffMin / 60)
      const diffDay = Math.floor(diffHour / 24)
      
      if (diffSec < 60) return 'à l\'instant'
      if (diffMin < 60) return `il y a ${diffMin} min`
      if (diffHour < 24) return `il y a ${diffHour} h`
      if (diffDay < 30) return `il y a ${diffDay} j`
      
      return date.toLocaleDateString('fr-FR')
    }
    
    return dateString
  }
  
  // Load initial data
  onBeforeMount(() => {
    // console.log('onBeforeMount')
    loadStats()
    loadRecentActivity()
    loadRecentEstablishments()
  })
  onMounted(() => {
    // console.log('onMounted')
    loadStats()
    loadRecentActivity()
    loadRecentEstablishments()
  })
  
  definePageMeta({
    layout: 'admin'
  })
  </script>
