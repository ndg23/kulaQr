<template>
  <PageForm
    title="Assigner des établissements"
    :subtitle="user?.full_name"
    back-to="/admin/users"
    back-label="Retour aux utilisateurs"
    :submit-label="selectedIds.length > 1 ? `Assigner ${selectedIds.length} établissements` : 'Assigner'"
    loading-label="Assignation..."
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !user"
    not-found-text="Marchand introuvable"
    :submit-disabled="!selectedIds.length"
    :error="error"
    @submit="handleSubmit"
  >
    <!-- Établissements déjà assignés -->
    <div class="rounded-3xl bg-gray-100 p-4">
      <p class="text-xs font-bold uppercase tracking-wide text-gray-500 mb-2">Déjà assignés ({{ owned.length }})</p>
      <div v-if="owned.length" class="flex flex-wrap gap-2">
        <span v-for="e in owned" :key="e.id" class="inline-flex items-center h-8 px-4 rounded-full bg-white text-sm font-bold text-gray-900">{{ e.name }}</span>
      </div>
      <p v-else class="text-sm text-gray-500">Aucun établissement pour le moment</p>
    </div>

    <div class="flex gap-2" role="radiogroup" aria-label="Établissements à afficher">
      <button
        v-for="f in filterChoices"
        :key="f.value"
        type="button"
        role="radio"
        :aria-checked="filter === f.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          filter === f.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="filter = f.value"
      >{{ f.label }}</button>
    </div>

    <div class="relative">
      <Search class="w-4 h-4 absolute left-5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
      <input
        v-model="search"
        type="search"
        placeholder="Rechercher un établissement"
        aria-label="Rechercher un établissement"
        class="w-full h-12 pl-12 pr-5 rounded-full border border-gray-200 focus:outline-none focus:border-gray-900"
      />
    </div>

    <ul v-if="visible.length" class="max-h-80 overflow-y-auto space-y-2 pr-1">
      <li v-for="e in visible" :key="e.id">
        <button
          type="button"
          :aria-pressed="selectedIds.includes(e.id)"
          :class="[
            'w-full flex items-center gap-3 rounded-full pl-2 pr-4 py-2 text-left transition-colors active:scale-[0.99]',
            selectedIds.includes(e.id) ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
          ]"
          @click="toggle(e.id)"
        >
          <span class="w-10 h-10 rounded-full bg-[#2962FF] text-white flex items-center justify-center flex-shrink-0">
            <Store class="w-5 h-5" :stroke-width="2.25" />
          </span>
          <span class="flex-1 min-w-0">
            <span class="block font-bold truncate">{{ e.name }}</span>
            <span :class="['block text-xs truncate', selectedIds.includes(e.id) ? 'text-white/70' : 'text-gray-500']">
              {{ e.user_id ? 'Sera transféré depuis son marchand actuel' : 'Sans marchand' }}{{ e.address ? ` · ${e.address}` : '' }}
            </span>
          </span>
          <Check v-if="selectedIds.includes(e.id)" class="w-4 h-4 flex-shrink-0" :stroke-width="3" />
        </button>
      </li>
    </ul>

    <div v-else class="rounded-3xl bg-gray-100 px-5 py-6 text-center">
      <p class="text-sm font-semibold text-gray-700">
        {{ filter === 'free' ? 'Tous les établissements ont déjà un marchand' : 'Aucun établissement trouvé' }}
      </p>
      <NuxtLink to="/admin/establishments/new" class="inline-block mt-2 text-sm font-bold text-gray-900 underline">
        Créer un établissement
      </NuxtLink>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Search, Store, Check } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const filterChoices = [
  { value: 'free', label: 'Sans marchand' },
  { value: 'all', label: 'Tous' }
]

const user = ref<any>(null)
const establishments = ref<any[]>([])
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')
const search = ref('')
const filter = ref('free')
const selectedIds = ref<string[]>([])

const owned = computed(() => establishments.value.filter(e => e.user_id === user.value?.id))

const visible = computed(() => {
  const q = search.value.trim().toLowerCase()
  return establishments.value.filter(e => {
    if (e.user_id === user.value?.id) return false
    if (filter.value === 'free' && e.user_id) return false
    return !q || [e.name, e.address].some(v => String(v || '').toLowerCase().includes(q))
  })
})

const toggle = (id: string) => {
  selectedIds.value = selectedIds.value.includes(id)
    ? selectedIds.value.filter(x => x !== id)
    : [...selectedIds.value, id]
}

onMounted(async () => {
  const [userRes, estRes] = await Promise.all([
    supabase.from('users').select('id, full_name, email').eq('id', route.params.id as string).maybeSingle(),
    supabase.from('establishments').select('id, name, address, user_id').order('name')
  ])
  if (userRes.error) error.value = userRes.error.message
  user.value = userRes.data
  establishments.value = estRes.data || []
  loadingData.value = false
})

const handleSubmit = async () => {
  if (!selectedIds.value.length) return
  loading.value = true
  error.value = ''
  try {
    const { error: updateError } = await supabase
      .from('establishments')
      .update({ user_id: user.value.id })
      .in('id', selectedIds.value)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert(selectedIds.value.map(id => ({
        user_id: admin.id,
        action_type: 'assign',
        entity_type: 'establishment',
        entity_id: id,
        details: { owner_id: user.value.id, owner_name: user.value.full_name }
      })))
    }
    showToast.success(selectedIds.value.length > 1 ? `${selectedIds.value.length} établissements assignés` : 'Établissement assigné')
    await navigateTo('/admin/establishments')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
