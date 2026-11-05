<template>
  <div class="space-y-4 sm:space-y-6">
    <ManagerModernHeader
      title="Emplacements"
      subtitle="Gérez les emplacements de votre établissement"
      :icon="Table"
      :primary-action="{
        label: 'Nouvel emplacement',
        icon: Plus,
        action: openTableModal
      }"
    />

    <!-- La grande carte : les emplacements et leurs QR -->
    <HeroCard
      label="Emplacements"
      :value="tables.length"
      :icon="Table"
      :chips="[
        { label: 'QR prêts', value: qrCodesGenerated },
        { label: 'Sans QR', value: tables.length - qrCodesGenerated, alert: tables.length - qrCodesGenerated > 0 },
        { label: 'VIP', value: vipTables }
      ]"
    />

    <!-- Recherche et actualisation -->
    <div class="flex items-center gap-2">
      <div class="relative flex-1 max-w-md">
        <Search class="w-5 h-5 text-gray-400 absolute left-5 top-1/2 -translate-y-1/2" />
        <input
          v-model="searchQuery"
          type="search"
          placeholder="Rechercher un emplacement"
          class="w-full h-12 pl-12 pr-5 rounded-full bg-gray-100 border-0 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-black"
        />
      </div>
      <button
        type="button"
        aria-label="Actualiser"
        :disabled="loading"
        class="w-12 h-12 flex-shrink-0 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center disabled:opacity-50 active:scale-[0.94] transition-all"
        @click="refreshData"
      >
        <RefreshCw :class="{ 'animate-spin': loading }" class="w-5 h-5 text-gray-900" :stroke-width="2.5" />
      </button>
    </div>

    <!-- Chargement -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4" aria-busy="true">
      <div v-for="i in 6" :key="i" class="h-60 rounded-[2rem] bg-gray-100 animate-pulse"></div>
    </div>

    <!-- Vide -->
    <div v-else-if="filteredTables.length === 0" class="rounded-[2rem] bg-gray-100 px-6 py-14 text-center">
      <Table class="w-10 h-10 text-gray-400 mx-auto" />
      <h3 class="mt-3 text-lg font-black text-gray-900">Aucun emplacement trouvé</h3>
      <p class="mt-1 text-sm font-semibold text-gray-500">
        {{ searchQuery ? 'Aucun emplacement ne correspond à votre recherche' : 'Commencez par créer votre premier emplacement' }}
      </p>
      <button
        v-if="!searchQuery"
        type="button"
        class="mt-5 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
        @click="openTableModal"
      >Créer un emplacement</button>
    </div>

    <!-- Cartes -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
      <article v-for="table in filteredTables" :key="table.id" class="rounded-[2rem] bg-gray-100 p-5 flex flex-col gap-4">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <span class="inline-flex items-center h-10 px-5 rounded-full bg-black text-white text-lg font-black">N° {{ table.table_number || table.number }}</span>
            <span
              v-if="table.type === 'VIP'"
              class="ml-2 inline-flex items-center h-7 px-3 rounded-full bg-[#FB6A00] text-black text-xs font-extrabold align-middle"
            >VIP</span>
          </div>
          <span
            class="inline-flex items-center h-8 px-3 rounded-full text-xs font-extrabold flex-shrink-0"
            :class="table.qr_code_generated ? 'bg-[#FB6A00] text-black' : 'bg-white text-gray-600'"
          >{{ table.qr_code_generated ? 'QR prêt' : 'Pas de QR' }}</span>
        </div>

        <div class="flex items-center gap-4">
          <span class="w-16 h-16 flex-shrink-0 rounded-3xl bg-white flex items-center justify-center">
            <QrCode class="w-8 h-8" :class="table.qr_code_generated ? 'text-black' : 'text-gray-300'" :stroke-width="2" />
          </span>
          <p class="text-sm font-semibold text-gray-600 leading-snug line-clamp-3 min-w-0">
            <span v-if="table.location_description">{{ table.location_description }}</span>
            <span v-else-if="table.section_name || table.floor_level">
              {{ table.section_name || 'Section non spécifiée' }}{{ table.floor_level ? ` · ${table.floor_level}` : '' }}
            </span>
            <span v-else>{{ table.description || 'Aucune description.' }}</span>
          </p>
        </div>

        <div class="mt-auto flex gap-2">
          <button
            type="button"
            class="flex-1 h-11 rounded-full bg-white text-gray-900 text-sm font-extrabold hover:bg-gray-50 active:scale-[0.97] transition-all"
            @click="editTable(table)"
          >Modifier</button>
          <button
            v-if="!table.qr_code_generated"
            type="button"
            class="flex-1 h-11 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
            @click="generateQrCode(table)"
          >Générer QR</button>
          <button
            v-else
            type="button"
            class="flex-1 h-11 inline-flex items-center justify-center gap-1.5 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all"
            @click="viewMenuTable(table)"
          >Menu <ArrowRight class="w-4 h-4" :stroke-width="2.5" /></button>
          <button
            v-if="table.qr_code_generated"
            type="button"
            aria-label="Imprimer la carte QR"
            class="w-11 h-11 flex-shrink-0 rounded-full bg-white text-gray-900 flex items-center justify-center active:scale-[0.92] transition-all"
            @click="showQrCodeCard(table)"
          ><QrCode class="w-4 h-4" :stroke-width="2.5" /></button>
          <button
            type="button"
            aria-label="Supprimer l'emplacement"
            class="w-11 h-11 flex-shrink-0 rounded-full bg-white text-gray-500 hover:text-[#C54E00] flex items-center justify-center active:scale-[0.92] transition-all"
            @click="deleteTable(table.id)"
          ><Trash2 class="w-4 h-4" :stroke-width="2.5" /></button>
        </div>
      </article>
    </div>
  </div>
</template>

<script setup lang="ts">
import HeroCard from '~/components/ui/HeroCard.vue'
import { ref, computed, onMounted } from 'vue'
import { 
  Table, Users, CheckCircle, ShoppingCart, Plus, Search, 
  RefreshCw, Loader2, Trash2, X, QrCode, Download, Eye, View, ArrowRight 
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useEstablishment } from '~/composables/useEstablishment'
import { encodeTableHashids } from '~/utils/secure-encoding'
// import jsPDF from 'jspdf'

const { showToast } = useCustomToast()
const { client: supabase } = useSupabaseWrapper()
const { establishment, fetchEstablishmentByUserId } = useEstablishment()
definePageMeta({
  layout: 'manager'
})
// State
const loading = ref(false)
const tables = ref<any[]>([])
const searchQuery = ref('')


// Computed
const filteredTables = computed(() => {
  if (!searchQuery.value) return tables.value
  
  return tables.value.filter(table => 
    String(table.table_number ?? table.number ?? '').includes(searchQuery.value) ||
    (table.zone && table.zone.toLowerCase().includes(searchQuery.value.toLowerCase()))
  )
})

const vipTables = computed(() => 
  tables.value.filter(table => table.type === 'VIP').length
)

const qrCodesGenerated = computed(() => 
  tables.value.filter(table => table.qr_code_generated).length
)

// Load tables
const loadTables = async () => {
  if (!establishment.value) return
  
  try {
    loading.value = true
    
    const { data, error } = await supabase
      .from('tables')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })

    if (error) throw error
    
    tables.value = data || []
  } catch (err) {
    console.error('Error loading tables:', err)
    showToast.error('Erreur', 'Impossible de charger les tables')
  } finally {
    loading.value = false
  }
}

const viewMenuTable = (table: any) => {
 return navigateTo(`${table.qr_code_url}`, { external: true })
  // showToast.success('Ouverture', 'Menu ouvert dans un nouvel onglet')
}

// Chaque action a sa page
const openTableModal = () => navigateTo(`/manager/${establishment.value?.id}/tables/new`)

const editTable = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/edit`)

const generateQrCode = async (table: any) => {
  if (!establishment.value) return

  try {
    loading.value = true
    
    // Encoder le numéro de table pour le cacher
    const encodedTableNumber = encodeTableHashids(parseInt(table.table_number ?? table.number, 10), establishment.value.id)
    
    // Générer l'URL du menu pour cette table spécifique avec le numéro encodé
    const tableMenuUrl = `${window.location.origin}/qr/${establishment.value.id}?q=${encodedTableNumber}`
    
    // Mettre à jour la table avec l'URL du QR code
    const { error } = await supabase
      .from('tables')
      .update({
        qr_code_url: tableMenuUrl,
        qr_code_generated: true
      })
      .eq('id', table.id)

    if (error) throw error

    // Mettre à jour les données locales
    const index = tables.value.findIndex(t => t.id === table.id)
    if (index !== -1) {
      tables.value[index].qr_code_url = tableMenuUrl
      tables.value[index].qr_code_generated = true
    }
    
    showToast.success('QR Code généré', `QR code généré pour la table ${table.table_number ?? table.number}`)
  } catch (err) {
    console.error('Error generating QR code:', err)
    showToast.error('Erreur', 'Impossible de générer le QR code')
  } finally {
    loading.value = false
  }
}

const deleteTable = async (tableId: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette table ?')) return
  
  try {
    const { error } = await supabase
      .from('tables')
      .delete()
      .eq('id', tableId)

    if (error) throw error
    
    tables.value = tables.value.filter(t => t.id !== tableId)
    showToast.success('Table supprimée', 'La table a été supprimée avec succès')
  } catch (err) {
    console.error('Error deleting table:', err)
    showToast.error('Erreur', 'Impossible de supprimer la table')
  }
}


const downloadQrCodes = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/qr`)

const showQrCodeCard = (table: any) => navigateTo(`/manager/${establishment.value?.id}/tables/${table.id}/qr`)

// Initialize
onMounted(async () => {
  await fetchEstablishmentByUserId()
  if (establishment.value) {
    loadTables()
  }
})
</script>
