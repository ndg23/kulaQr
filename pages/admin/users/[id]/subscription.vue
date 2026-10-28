<template>
  <PageForm
    title="Abonnement"
    :subtitle="user?.full_name"
    back-to="/admin/users"
    back-label="Retour aux utilisateurs"
    submit-label="Mettre à jour"
    loading-label="Mise à jour..."
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !user"
    not-found-text="Utilisateur introuvable"
    :submit-disabled="!canSubmit"
    :error="error"
    @submit="handleSubmit"
  >
    <!-- Abonnement actuel -->
    <div class="rounded-3xl bg-gray-100 p-4 space-y-2">
      <p class="text-xs font-bold uppercase tracking-wide text-gray-500">Abonnement actuel</p>
      <div class="flex flex-wrap items-center gap-2">
        <span :class="['inline-flex items-center h-8 px-4 rounded-full text-sm font-bold', tierBadgeClass(user?.subscription_tier)]">
          {{ tierLabel(user?.subscription_tier) }}
        </span>
        <span :class="['inline-flex items-center h-8 px-4 rounded-full text-sm font-bold', subscriptionStatusBadgeClass(user?.subscription_status)]">
          {{ subscriptionStatusLabel(user?.subscription_status) }}
        </span>
      </div>
      <p v-if="user?.subscription_ends_at" class="text-sm text-gray-600">
        Expire le {{ formatDate(user.subscription_ends_at) }}
      </p>
    </div>

    <h2 class="text-sm font-extrabold text-gray-900 px-1 pt-2">Nouveau plan</h2>

    <FloatLabelSelect id="tier" v-model="subscriptionForm.tier" label="Plan d'abonnement" :error="errors.tier" pill required>
      <option v-for="t in TIER_OPTIONS" :key="t.value" :value="t.value">{{ t.label }}</option>
    </FloatLabelSelect>

    <FloatLabelSelect id="status" v-model="subscriptionForm.status" label="Statut" :error="errors.status" pill required>
      <option v-for="s in SUBSCRIPTION_STATUS_OPTIONS" :key="s.value" :value="s.value">{{ s.label }}</option>
    </FloatLabelSelect>

    <template v-if="subscriptionForm.status === 'active'">
      <div class="flex gap-2" role="radiogroup" aria-label="Durée">
        <button
          v-for="d in durationChoices"
          :key="d.value"
          type="button"
          role="radio"
          :aria-checked="subscriptionForm.duration === d.value"
          :class="[
            'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
            subscriptionForm.duration === d.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
          ]"
          @click="subscriptionForm.duration = d.value"
        >{{ d.label }}</button>
      </div>

      <FloatLabelInput
        v-if="subscriptionForm.duration === 'custom'"
        id="endDate"
        v-model="subscriptionForm.custom_end_date"
        type="date"
        label="Date de fin"
        :error="errors.custom_end_date"
        :show-char-count="false"
        pill
        required
      />
    </template>

    <!-- Note administrative -->
    <div>
      <label for="adminNote" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">Note administrative (optionnelle)</label>
      <textarea
        id="adminNote"
        v-model="adminNote"
        rows="3"
        placeholder="Raison du changement d'abonnement..."
        class="w-full px-5 py-4 border border-gray-200 rounded-3xl focus:outline-none focus:border-gray-900 resize-none"
      />
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import {
  TIER_OPTIONS, SUBSCRIPTION_STATUS_OPTIONS, tierLabel, subscriptionStatusLabel,
  tierBadgeClass, subscriptionStatusBadgeClass
} from '~/utils/adminLabels'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const durationChoices = [
  { value: 'default', label: 'Durée par défaut' },
  { value: 'custom', label: 'Date personnalisée' }
]

const user = ref<any>(null)
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')
const adminNote = ref('')
const subscriptionForm = ref({ tier: 'demo', status: 'active', duration: 'default', custom_end_date: '' })
const errors = ref({ tier: '', status: '', custom_end_date: '' })

const formatDate = (value: string) => new Date(value).toLocaleDateString('fr-FR')

const canSubmit = computed(() => {
  const f = subscriptionForm.value
  if (!f.tier || !f.status) return false
  if (f.status === 'active' && f.duration === 'custom') return !!f.custom_end_date
  return true
})

onMounted(async () => {
  const { data, error: loadError } = await supabase
    .from('users')
    .select('*')
    .eq('id', route.params.id as string)
    .maybeSingle()
  if (loadError) error.value = loadError.message
  user.value = data
  if (data) {
    subscriptionForm.value = {
      tier: data.subscription_tier || 'demo',
      status: data.subscription_status || 'pending_activation',
      duration: 'default',
      custom_end_date: ''
    }
  }
  loadingData.value = false
})

const DAYS: Record<string, number> = { demo: 7, pro: 30, premium: 90 }

const endDate = () => {
  const f = subscriptionForm.value
  if (f.duration === 'custom' && f.custom_end_date) return new Date(f.custom_end_date)
  const d = new Date()
  d.setDate(d.getDate() + (DAYS[f.tier] || 7))
  return d
}

const validate = () => {
  const f = subscriptionForm.value
  errors.value = { tier: '', status: '', custom_end_date: '' }
  if (!f.tier) errors.value.tier = "Le plan d'abonnement est requis"
  if (!f.status) errors.value.status = 'Le statut est requis'
  if (f.status === 'active' && f.duration === 'custom') {
    if (!f.custom_end_date) errors.value.custom_end_date = 'La date de fin est requise'
    else if (new Date(f.custom_end_date) <= new Date()) errors.value.custom_end_date = 'La date de fin doit être dans le futur'
  }
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!user.value?.id || !validate()) return
  loading.value = true
  error.value = ''
  try {
    const f = subscriptionForm.value
    const isActive = f.status === 'active'
    // Un abonnement actif réactive le compte ; expiré, annulé ou suspendu le bloque (comme le blocage automatique)
    const updateData = {
      subscription_tier: f.tier,
      subscription_status: f.status,
      subscription_ends_at: isActive ? endDate().toISOString() : null,
      is_active: isActive ? true : f.status === 'pending_activation' ? user.value.is_active : false
    }
    const { error: updateError } = await supabase.from('users').update(updateData).eq('id', user.value.id)
    if (updateError) throw updateError

    const { data: { user: admin } } = await supabase.auth.getUser()
    if (admin) {
      await supabase.from('activities').insert({
        user_id: admin.id,
        action_type: 'update',
        entity_type: 'subscription',
        entity_id: user.value.id,
        details: {
          user_name: user.value.full_name,
          from_tier: user.value.subscription_tier,
          to_tier: f.tier,
          from_status: user.value.subscription_status,
          to_status: f.status,
          admin_note: adminNote.value
        }
      })
    }
    showToast.success('Abonnement mis à jour avec succès')
    await navigateTo('/admin/users')
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
