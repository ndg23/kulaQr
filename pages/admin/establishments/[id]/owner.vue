<template>
  <PageForm
    :title="isTransfer ? 'Changer de marchand' : 'Assigner un marchand'"
    :subtitle="establishment?.name"
    back-to="/admin/establishments"
    back-label="Retour aux établissements"
    :submit-label="isTransfer ? 'Transférer' : 'Assigner'"
    loading-label="Enregistrement..."
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !establishment"
    not-found-text="Établissement introuvable"
    :error="error"
    @submit="handleSubmit"
  >
    <!-- Propriétaire actuel -->
    <div class="rounded-3xl bg-gray-100 p-4">
      <p class="text-xs font-bold uppercase tracking-wide text-gray-500 mb-1">Marchand actuel</p>
      <p class="font-extrabold text-gray-900">{{ currentOwner?.full_name || 'Non assigné' }}</p>
      <p v-if="currentOwner?.email" class="text-sm text-gray-500 break-words">{{ currentOwner.email }}</p>
    </div>

    <div class="flex gap-2" role="radiogroup" aria-label="Type de propriétaire">
      <button
        v-for="o in ownerChoices"
        :key="o.value"
        type="button"
        role="radio"
        :aria-checked="ownerType === o.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          ownerType === o.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="ownerType = o.value"
      >{{ o.label }}</button>
    </div>

    <!-- Marchand existant : recherche + liste à toucher -->
    <div v-if="ownerType === 'existing'" class="space-y-3">
      <div class="relative">
        <Search class="w-4 h-4 absolute left-5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
        <input
          v-model="ownerSearch"
          type="search"
          placeholder="Rechercher un marchand (nom, email, téléphone)"
          aria-label="Rechercher un marchand"
          class="w-full h-12 pl-12 pr-5 rounded-full border border-gray-200 focus:outline-none focus:border-gray-900"
        />
      </div>

      <ul v-if="filteredOwners.length" class="max-h-72 overflow-y-auto space-y-2 pr-1" role="listbox" aria-label="Marchands">
        <li v-for="o in filteredOwners" :key="o.id">
          <button
            type="button"
            role="option"
            :aria-selected="selectedOwnerId === o.id"
            :class="[
              'w-full flex items-center gap-3 rounded-full pl-2 pr-4 py-2 text-left transition-colors active:scale-[0.99]',
              selectedOwnerId === o.id ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
            ]"
            @click="selectedOwnerId = o.id"
          >
            <span class="w-10 h-10 rounded-full bg-[#7050FF] text-white flex items-center justify-center flex-shrink-0 font-bold">
              {{ initials(o.full_name || o.email) }}
            </span>
            <span class="flex-1 min-w-0">
              <span class="block font-bold truncate">{{ o.full_name || o.email }}</span>
              <span :class="['block text-xs truncate', selectedOwnerId === o.id ? 'text-white/70' : 'text-gray-500']">
                {{ [o.email, o.phone].filter(Boolean).join(' · ') }}
              </span>
            </span>
            <Check v-if="selectedOwnerId === o.id" class="w-4 h-4 flex-shrink-0" :stroke-width="3" />
          </button>
        </li>
      </ul>

      <div v-else class="rounded-3xl bg-gray-100 px-5 py-6 text-center">
        <p class="text-sm font-semibold text-gray-700">Aucun marchand trouvé</p>
        <button type="button" class="mt-2 text-sm font-bold text-gray-900 underline" @click="ownerType = 'new'">
          Créer un nouveau marchand
        </button>
      </div>

      <p v-if="errors.owner" class="text-sm font-semibold text-red-600 px-1">{{ errors.owner }}</p>
    </div>

    <template v-else>
      <FloatLabelInput id="ownerName" v-model="newOwner.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
      <FloatLabelInput id="ownerEmail" v-model="newOwner.email" type="email" label="Email" autocomplete="off" :error="errors.email" :show-char-count="false" pill required />
      <FloatLabelInput id="ownerPhone" v-model="newOwner.phone" type="tel" label="Téléphone" autocomplete="off" :show-char-count="false" pill />
      <FloatLabelInput id="ownerPassword" v-model="newOwner.password" type="password" label="Mot de passe" help-text="6 caractères minimum." autocomplete="new-password" :error="errors.password" :show-char-count="false" pill required />
    </template>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Search, Check } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()
const createAuthUser = useCreateAuthUser()

const ownerChoices = [
  { value: 'existing', label: 'Marchand existant' },
  { value: 'new', label: 'Nouveau marchand' }
]

const establishment = ref<any>(null)
const currentOwner = ref<any>(null)
const owners = ref<any[]>([])
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')
const errors = ref({ owner: '', full_name: '', email: '', password: '' })
const ownerType = ref('existing')
const selectedOwnerId = ref('')
const ownerSearch = ref('')
const newOwner = ref({ full_name: '', email: '', phone: '', password: '' })

const initials = (name?: string) =>
  (name || '?').split(/\s+/).filter(Boolean).map(w => w[0]).join('').slice(0, 2).toUpperCase()

const filteredOwners = computed(() => {
  const q = ownerSearch.value.trim().toLowerCase()
  if (!q) return owners.value
  return owners.value.filter(o => [o.full_name, o.email, o.phone].some(v => String(v || '').toLowerCase().includes(q)))
})

// Un établissement sans propriétaire est attribué, sinon il est transféré
const isTransfer = computed(() => !!establishment.value?.user_id)

onMounted(async () => {
  const { data, error: loadError } = await supabase
    .from('establishments')
    .select('id, name, user_id')
    .eq('id', route.params.id as string)
    .maybeSingle()
  if (loadError) error.value = loadError.message
  establishment.value = data

  if (data) {
    const { data: ownersData } = await supabase
      .from('users')
      .select('id, full_name, email, phone')
      .eq('role', 'owner')
      .order('full_name')
    currentOwner.value = (ownersData || []).find(o => o.id === data.user_id) || null
    if (!currentOwner.value && data.user_id) {
      const { data: u } = await supabase.from('users').select('id, full_name, email, phone').eq('id', data.user_id).maybeSingle()
      currentOwner.value = u
    }
    owners.value = (ownersData || []).filter(o => o.id !== data.user_id)
  }
  loadingData.value = false
})

const validate = () => {
  errors.value = { owner: '', full_name: '', email: '', password: '' }
  if (ownerType.value === 'existing') {
    if (!selectedOwnerId.value) errors.value.owner = 'Sélectionnez un marchand'
  } else {
    if (!newOwner.value.full_name.trim()) errors.value.full_name = 'Le nom complet est requis'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(newOwner.value.email)) errors.value.email = 'Email invalide'
    if (newOwner.value.password.length < 6) errors.value.password = 'Le mot de passe doit contenir au moins 6 caractères'
  }
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    let ownerId = selectedOwnerId.value

    if (ownerType.value === 'new') {
      ownerId = await createAuthUser({
        email: newOwner.value.email,
        password: newOwner.value.password,
        fullName: newOwner.value.full_name,
        phone: newOwner.value.phone
      })
      const { error: userError } = await supabase.from('users').update({
        full_name: newOwner.value.full_name.trim(),
        email: newOwner.value.email.trim(),
        phone: newOwner.value.phone.trim() || null,
        role: 'owner',
        is_active: true,
        subscription_tier: 'demo',
        subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
      }).eq('id', ownerId)
      if (userError) throw userError
    }

    const { error: updateError } = await supabase
      .from('establishments')
      .update({ user_id: ownerId })
      .eq('id', establishment.value.id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'assign',
        entity_type: 'establishment',
        entity_id: establishment.value.id,
        details: { establishment_name: establishment.value.name, owner_id: ownerId, previous_owner_id: establishment.value.user_id }
      })
    }

    showToast.success(isTransfer.value ? 'Établissement transféré au nouveau marchand' : 'Marchand assigné avec succès')
    await navigateTo('/admin/establishments')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
