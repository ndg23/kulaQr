<template>
  <div class="space-y-4 sm:space-y-6">
    <ManagerModernHeader
      title="Gestion du personnel"
      subtitle="Gérez les membres de votre équipe et leurs accès"
      :icon="Users"
      :primary-action="{
        label: 'Ajouter un membre',
        icon: Plus,
        action: openStaffModal
      }"
    />

    <!-- La grande carte : l'équipe -->
    <HeroCard
      label="Membres de l'équipe"
      :value="staffMembers.length"
      :icon="Users"
      :chips="[
        { label: 'Actifs', value: staffMembers.filter(m => m.is_active).length },
        { label: 'Avec PIN', value: staffMembers.filter(m => m.pin).length },
        { label: 'Sans PIN', value: staffMembers.filter(m => !m.pin).length, alert: staffMembers.some(m => !m.pin), dot: staffMembers.some(m => !m.pin) }
      ]"
    />

    <main>
      <!-- Chargement -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 sm:gap-4" aria-busy="true">
        <div v-for="i in 3" :key="i" class="h-48 rounded-[2rem] bg-gray-100 animate-pulse"></div>
      </div>

      <!-- Vide -->
      <div v-else-if="staffMembers.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
        <Users class="w-10 h-10 text-gray-400 mx-auto" />
        <h3 class="mt-3 text-lg font-black text-gray-900">Aucun membre du personnel</h3>
        <p class="mt-1 text-sm font-semibold text-gray-500 max-w-md mx-auto">
          Vous n'avez pas encore ajouté de membres à votre équipe. Commencez par ajouter votre premier membre.
        </p>
        <button
          type="button"
          class="mt-5 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
          @click="openStaffModal()"
        >Ajouter un membre</button>
      </div>

      <!-- Membres -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 sm:gap-4">
        <article
          v-for="member in staffMembers"
          :key="member.id"
          class="rounded-[2rem] bg-gray-100 p-5 flex flex-col gap-4"
          :class="member.is_active ? '' : 'opacity-70'"
        >
          <div class="flex items-center gap-3">
            <span class="w-12 h-12 flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center">
              <User class="w-6 h-6" :stroke-width="2.5" />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="font-black text-gray-900 truncate">{{ member.username }}</h3>
              <span class="inline-flex items-center h-6 px-3 mt-0.5 rounded-full bg-white text-xs font-extrabold text-gray-900">{{ getRoleName(member.role) }}</span>
            </div>
            <AppleSwitch
              :model-value="member.is_active"
              @update:model-value="toggleStaffStatus(member, $event)"
            />
          </div>

          <!-- PIN -->
          <div class="flex items-center justify-between rounded-full bg-white pl-5 pr-2 h-12">
            <span class="inline-flex items-center gap-2 text-sm font-bold text-gray-600"><Key class="w-4 h-4" :stroke-width="2.5" /> PIN</span>
            <span class="flex items-center gap-2">
              <span class="font-mono font-black text-gray-900 tracking-widest">{{ member.pin || '----' }}</span>
              <button
                v-if="member.pin"
                type="button"
                aria-label="Régénérer le PIN"
                class="w-9 h-9 rounded-full bg-gray-100 text-gray-900 flex items-center justify-center active:scale-[0.92] transition-all"
                @click="regeneratePin(member)"
              ><RefreshCw class="w-4 h-4" :stroke-width="2.5" /></button>
              <button
                v-else
                type="button"
                aria-label="Générer un PIN"
                class="w-9 h-9 rounded-full bg-black text-white flex items-center justify-center active:scale-[0.92] transition-all"
                @click="generatePin(member)"
              ><Plus class="w-4 h-4" :stroke-width="2.5" /></button>
            </span>
          </div>

          <div class="mt-auto flex gap-2">
            <button
              type="button"
              class="flex-1 h-11 inline-flex items-center justify-center gap-2 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
              @click="openStaffModal(member)"
            ><Edit class="w-4 h-4" :stroke-width="2.5" /> Modifier</button>
            <button
              type="button"
              :aria-label="`Supprimer ${member.username}`"
              class="w-11 h-11 flex-shrink-0 rounded-full bg-white text-gray-500 hover:text-[#C54E00] flex items-center justify-center active:scale-[0.92] transition-all"
              @click="confirmDeleteStaff(member)"
            ><Trash2 class="w-4 h-4" :stroke-width="2.5" /></button>
          </div>
        </article>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import HeroCard from '~/components/ui/HeroCard.vue'
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { 
  User, 
  Users, 
  Edit, 
  Trash2, 
  Plus, 
  Loader2,
  RefreshCw,
  Key
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import AppleSwitch from '~/components/AppleSwitch.vue'

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const { slug } = route.params

// State
const staffMembers = ref([] as any[])
const loading = ref(true)

definePageMeta({
  layout: 'manager'
})

// Get role name
const getRoleName = (role: string) => {
  const roles = {
    manager: 'Manager',
    staff: 'Personnel',
    waiter: 'Serveur',
    kitchen: 'Cuisine'
  }
  return roles[role] || role
}

// Load staff members
const loadStaffMembers = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('staff')
      .select('*')
      .eq('establishment_id', slug)
      .order('created_at', { ascending: false })
      .limit(100)
    
    if (error) throw error
    
    staffMembers.value = data || [] as any[]
  } catch (error) {
    console.error('Error loading staff members:', error)
    showToast.error('Erreur', 'Impossible de charger les membres du personnel')
  } finally {
    loading.value = false
  }
}

// Toggle staff status
const toggleStaffStatus = async (member, newStatus) => {
  try {
    const { error } = await supabase
      .from('staff')
      .update({ 
        is_active: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', member.id)
    
    if (error) throw error
    
    // Update local state
    const index = staffMembers.value.findIndex(s => s.id === member.id)
    if (index !== -1) {
      staffMembers.value[index].is_active = newStatus
    }
    
    showToast.success('Succès', `${member.username} est maintenant ${newStatus ? 'actif' : 'inactif'}`)
  } catch (error) {
    console.error('Error toggling staff status:', error)
    showToast.error('Erreur', 'Impossible de modifier le statut')
  }
}

// Chaque action a sa page
const openStaffModal = (staff: any = null) =>
  navigateTo(staff?.id ? `/manager/${slug}/staff/${staff.id}/edit` : `/manager/${slug}/staff/new`)

// Generate PIN
const generatePin = async (staff) => {
  try {
    const { data, error } = await supabase.rpc('create_staff_pin', {
      p_username: staff.username,
      p_establishment_id: slug,
      p_role: staff.role
    })
    
    if (error) throw error
    
    await loadStaffMembers()
    showToast.success('PIN généré', `PIN: ${data.pin}`)
  } catch (error) {
    console.error('Error generating PIN:', error)
    showToast.error('Erreur', 'Impossible de générer un PIN')
  }
}

// Regenerate PIN
const regeneratePin = async (staff) => {
  try {
    const { data, error } = await supabase.rpc('regenerate_staff_pin', {
      p_staff_id: staff.id
    })
    
    if (error) throw error
    
    const index = staffMembers.value.findIndex(s => s.id === staff.id)
    if (index !== -1) {
      staffMembers.value[index].pin = data
    }
    
    showToast.success('PIN régénéré', `Nouveau PIN: ${data}`)
  } catch (error) {
    console.error('Error regenerating PIN:', error)
    showToast.error('Erreur', 'Impossible de régénérer le PIN')
  }
}

// Confirm delete
const confirmDeleteStaff = (staff) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer ${staff.username} ?`)) {
    deleteStaff(staff.id)
  }
}

// Delete staff
const deleteStaff = async (id) => {
  try {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    staffMembers.value = staffMembers.value.filter((s: any) => s.id !== id)
    showToast.success('Succès', 'Membre supprimé avec succès')
  } catch (error) {
    console.error('Error deleting staff:', error)
    showToast.error('Erreur', 'Impossible de supprimer ce membre')
  }
}

onMounted(() => {
  loadStaffMembers()
})

watch(() => route.path, async (newPath, oldPath) => {
  if (newPath !== oldPath) {
    await loadStaffMembers()
  }
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>