<template>
  <div>
    <h1 class="text-2xl font-semibold text-gray-900 mb-6">Tableau de bord</h1>
    
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 sm:px-6">
        <h2 class="text-lg leading-6 font-medium text-gray-900">
          Bienvenue, {{ staffSession.username }}
        </h2>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">
          Vous êtes connecté en tant que {{ getRoleName(staffSession.role) }}
        </p>
      </div>
      <div class="border-t border-gray-200 px-4 py-5 sm:p-6">
        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <!-- Quick access cards based on role -->
          <div v-if="['waiter', 'manager'].includes(staffSession.role)" class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-kula-100 rounded-md p-3">
                  <ClipboardList class="h-6 w-6 text-kula-600" />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Commandes
                    </dt>
                    <dd class="flex items-baseline">
                      <div class="text-2xl font-semibold text-gray-900">
                        {{ orderCount }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-4 sm:px-6">
              <div class="text-sm">
                <NuxtLink to="/staff/orders" class="font-medium text-kula-600 hover:text-kula-500">
                  Voir toutes les commandes
                </NuxtLink>
              </div>
            </div>
          </div>
          
          <div v-if="['kitchen', 'manager'].includes(staffSession.role)" class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-green-100 rounded-md p-3">
                  <ChefHat class="h-6 w-6 text-green-600" />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Commandes en cuisine
                    </dt>
                    <dd class="flex items-baseline">
                      <div class="text-2xl font-semibold text-gray-900">
                        {{ kitchenOrderCount }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-4 sm:px-6">
              <div class="text-sm">
                <NuxtLink to="/staff/kitchen" class="font-medium text-green-600 hover:text-green-500">
                  Voir les commandes en cuisine
                </NuxtLink>
              </div>
            </div>
          </div>
          
          <div v-if="staffSession.role === 'manager'" class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-blue-100 rounded-md p-3">
                  <Settings class="h-6 w-6 text-blue-600" />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Administration
                    </dt>
                    <dd class="flex items-baseline">
                      <div class="text-2xl font-semibold text-gray-900">
                        Gérer
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-4 sm:px-6">
              <div class="text-sm">
                <NuxtLink :to="`/manager/${staffSession.establishment_id}/dashboard`" class="font-medium text-blue-600 hover:text-blue-500">
                  Accéder à l'administration
                </NuxtLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ClipboardList, ChefHat, Settings } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'

const { client: supabase } = useSupabaseWrapper()
const staffSession = ref({})
const orderCount = ref(0)
const kitchenOrderCount = ref(0)

// Get role name
const getRoleName = (role) => {
  const roles = {
    manager: 'Manager',
    staff: 'Personnel',
    waiter: 'Serveur',
    kitchen: 'Cuisine'
  }
  return roles[role] || role
}

// Load data
const loadData = async () => {
  if (!staffSession.value.establishment_id) return
  
  try {
    // Load order count
    const { count: orderCountData } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true })
      .eq('establishment_id', staffSession.value.establishment_id)
      .eq('status', 'active')
    
    orderCount.value = orderCountData || 0
    
    // Load kitchen order count
    const { count: kitchenCountData } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true })
      .eq('establishment_id', staffSession.value.establishment_id)
      .eq('status', 'preparing')
    
    kitchenOrderCount.value = kitchenCountData || 0
  } catch (error) {
    console.error('Error loading dashboard data:', error)
  }
}

onMounted(() => {
  const session = localStorage.getItem('staff_session')
  if (session) {
    staffSession.value = JSON.parse(session)
    loadData()
  }
})

definePageMeta({
  middleware: ['staff-auth'],
  layout: 'staff'
})
</script> 