<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="sticky top-0 z-50 bg-white/80 backdrop-blur-sm border-b border-gray-100">
      <div class="max-w-2xl mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <NuxtLink 
              :to="`/staff/${establishmentId}`"
              class="p-2 -ml-2 hover:bg-gray-50 rounded-full"
            >
              <ArrowLeft class="w-5 h-5" />
            </NuxtLink>
            <h1 class="text-xl font-bold">Personnel</h1>
          </div>
          <button 
            @click="openAddStaffModal"
            class="flex items-center gap-2 px-4 py-2 bg-black text-white rounded-full font-medium hover:bg-gray-900"
          >
            <Plus class="w-4 h-4" />
            <span>Ajouter</span>
          </button>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="max-w-2xl mx-auto px-4 py-4">
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 3" :key="i" class="animate-pulse">
          <div class="flex items-center gap-4 p-4">
            <div class="w-12 h-12 bg-gray-100 rounded-full"></div>
            <div class="flex-1">
              <div class="h-4 bg-gray-100 rounded w-1/4"></div>
              <div class="h-4 bg-gray-100 rounded w-1/3 mt-2"></div>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="staffList.length === 0" class="text-center py-12">
        <Users class="w-12 h-12 text-gray-300 mx-auto mb-4" />
        <p class="text-gray-600">Aucun personnel ajouté</p>
      </div>

      <div v-else class="divide-y divide-gray-100">
        <div 
          v-for="staff in staffList" 
          :key="staff.id"
          class="flex items-center justify-between py-4"
        >
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
              <User2 class="w-6 h-6 text-gray-400" />
            </div>
            <div>
              <div class="font-medium">{{ staff.name }}</div>
              <div class="text-sm text-gray-500 mt-0.5">PIN: {{ staff.pin }}</div>
            </div>
          </div>
          
          <div class="flex items-center gap-1">
            <button 
              @click="regeneratePin(staff.id)"
              class="p-2 text-gray-600 hover:bg-gray-50 rounded-full"
              title="Nouveau PIN"
            >
              <RefreshCw class="w-5 h-5" />
            </button>
            <button 
              @click="toggleStaffStatus(staff.id, !staff.is_active)"
              class="p-2 rounded-full"
              :class="staff.is_active ? 'text-green-600 hover:bg-green-50' : 'text-gray-400 hover:bg-gray-50'"
            >
              <ToggleLeft class="w-5 h-5" />
            </button>
            <button 
              @click="deleteStaff(staff.id)"
              class="p-2 text-red-600 hover:bg-red-50 rounded-full"
            >
              <Trash2 class="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal d'ajout simplifié -->
    <Modal v-model="showAddModal">
      <div class="p-4">
        <h2 class="text-xl font-bold mb-4">Nouveau serveur</h2>
        <form @submit.prevent="addStaff">
          <input 
            type="text" 
            v-model="newStaff.name"
            placeholder="Nom du serveur"
            class="w-full px-4 py-2 border border-gray-200 rounded-full focus:outline-none focus:border-black"
            required
          />
          <div class="flex justify-end gap-2 mt-4">
            <button 
              type="button"
              @click="showAddModal = false"
              class="px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-full"
            >
              Annuler
            </button>
            <button 
              type="submit"
              class="px-4 py-2 bg-black text-white rounded-full hover:bg-gray-900"
              :disabled="loading"
            >
              {{ loading ? 'Création...' : 'Ajouter' }}
            </button>
          </div>
        </form>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { 
  ArrowLeft, Plus, Users, User2,
  RefreshCw, ToggleLeft, Trash2
} from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const route = useRoute()

const establishmentId = route.params.establishmentId
const loading = ref(false)
const staffList = ref([])
const showAddModal = ref(false)
const newStaff = ref({
  name: ''
})

// Charger la liste du personnel
const loadStaffList = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('staff_pins')
      .select('*')
      .eq('establishment_id', establishmentId)
      .order('created_at', { ascending: false })

    if (error) throw error

    staffList.value = data
  } catch (error) {
    console.error('Erreur de chargement du personnel:', error)
    showToast.error('Erreur', 'Impossible de charger la liste du personnel')
  } finally {
    loading.value = false
  }
}

// Ajouter un nouveau serveur
const addStaff = async () => {
  try {
    loading.value = true
    
    // Créer un nouveau PIN pour le serveur
    const { data, error } = await supabase
      .rpc('create_staff_pin', {
        p_name: newStaff.value.name,
        p_establishment_id: establishmentId
      })

    if (error) throw error

    showToast.success('Succès', 'Serveur ajouté avec succès')
    showAddModal.value = false
    newStaff.value.name = ''
    await loadStaffList()
  } catch (error) {
    console.error('Erreur d\'ajout du serveur:', error)
    showToast.error('Erreur', 'Impossible d\'ajouter le serveur')
  } finally {
    loading.value = false
  }
}

// Régénérer un PIN
const regeneratePin = async (staffId) => {
  try {
    const { error } = await supabase
      .rpc('regenerate_staff_pin', {
        p_staff_id: staffId
      })

    if (error) throw error

    showToast.success('Succès', 'PIN régénéré avec succès')
    await loadStaffList()
  } catch (error) {
    console.error('Erreur de régénération du PIN:', error)
    showToast.error('Erreur', 'Impossible de régénérer le PIN')
  }
}

// Activer/désactiver un serveur
const toggleStaffStatus = async (staffId, newStatus) => {
  try {
    const { error } = await supabase
      .from('staff_pins')
      .update({ is_active: newStatus })
      .eq('id', staffId)

    if (error) throw error

    showToast.success('Succès', `Serveur ${newStatus ? 'activé' : 'désactivé'} avec succès`)
    await loadStaffList()
  } catch (error) {
    console.error('Erreur de mise à jour du statut:', error)
    showToast.error('Erreur', 'Impossible de mettre à jour le statut')
  }
}

// Supprimer un serveur
const deleteStaff = async (staffId) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce serveur ?')) return

  try {
    const { error } = await supabase
      .from('staff_pins')
      .delete()
      .eq('id', staffId)

    if (error) throw error

    showToast.success('Succès', 'Serveur supprimé avec succès')
    await loadStaffList()
  } catch (error) {
    console.error('Erreur de suppression du serveur:', error)
    showToast.error('Erreur', 'Impossible de supprimer le serveur')
  }
}

// Ouvrir le modal d'ajout
const openAddStaffModal = () => {
  newStaff.value.name = ''
  showAddModal.value = true
}

onMounted(() => {
  loadStaffList()
})

definePageMeta({
  layout: 'staff'
})
</script> 