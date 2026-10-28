<template>
  <PageForm
    title="Personnel"
    :subtitle="establishment?.name"
    back-to="/admin/establishments"
    back-label="Retour aux établissements"
    submit-label="Ajouter le membre"
    loading-label="Ajout..."
    :loading="loading"
    :loading-data="loadingData"
    :not-found="!loadingData && !establishment"
    not-found-text="Établissement introuvable"
    :submit-disabled="!canSubmit"
    :error="error"
    wide
    @submit="handleSubmit"
  >
    <!-- Personnel actuel -->
    <section>
      <div class="flex items-center justify-between px-1 mb-2">
        <h2 class="text-sm font-extrabold text-gray-900">Personnel actuel</h2>
        <span class="inline-flex items-center h-7 px-3 rounded-full bg-gray-100 text-xs font-bold text-gray-700">{{ staffList.length }} membre(s)</span>
      </div>

      <div v-if="staffList.length === 0" class="rounded-3xl bg-gray-100 py-8 text-center text-gray-500">
        <Users class="w-10 h-10 mx-auto mb-2 text-gray-300" />
        <p class="text-sm font-semibold">Aucun personnel assigné</p>
      </div>

      <ul v-else class="space-y-2">
        <li v-for="member in staffList" :key="member.id" class="flex items-center gap-3 rounded-full bg-gray-100 pl-2 pr-2 py-2">
          <span class="w-10 h-10 rounded-full bg-[#7050FF] text-white flex items-center justify-center flex-shrink-0 font-bold">
            {{ initials(member.full_name || member.username) }}
          </span>
          <div class="flex-1 min-w-0">
            <p class="font-bold text-gray-900 truncate">{{ member.full_name || member.username }}</p>
            <p class="text-xs text-gray-500 truncate">@{{ member.username }}{{ member.email ? ` · ${member.email}` : '' }}</p>
          </div>
          <button
            type="button"
            :aria-label="`Retirer ${member.full_name || member.username}`"
            :disabled="removingId === member.id"
            class="w-10 h-10 flex-shrink-0 rounded-full bg-white text-red-600 flex items-center justify-center hover:bg-red-50 active:scale-[0.95] transition-all disabled:opacity-50"
            @click="removeStaff(member)"
          >
            <X class="w-4 h-4" :stroke-width="2.5" />
          </button>
        </li>
      </ul>
    </section>

    <!-- Ajouter -->
    <h2 class="text-sm font-extrabold text-gray-900 px-1 pt-3">Ajouter un membre</h2>
    <p class="text-xs text-gray-500 px-1 -mt-2">Il se connecte avec son nom d'utilisateur et son code PIN de 4 chiffres.</p>

    <FloatLabelInput id="staff-name" v-model="staffForm.full_name" label="Nom complet" autocomplete="off" :error="errors.full_name" :show-char-count="false" pill required />
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <FloatLabelInput id="staff-username" v-model="staffForm.username" label="Nom d'utilisateur" autocomplete="off" :error="errors.username" :show-char-count="false" pill required />
      <FloatLabelInput id="staff-pin" v-model="staffForm.pin" type="password" label="Code PIN (4 chiffres)" :maxlength="4" pattern="[0-9]{4}" autocomplete="new-password" :error="errors.pin" :show-char-count="false" pill required />
    </div>
    <FloatLabelInput id="staff-email" v-model="staffForm.email" type="email" label="Email (optionnel)" autocomplete="off" :error="errors.email" :show-char-count="false" pill />

    <FloatLabelSelect id="staff-role" v-model="staffForm.role" label="Rôle" pill>
      <option value="staff">Staff</option>
      <option value="waiter">Serveur</option>
      <option value="kitchen">Cuisine</option>
      <option value="manager">Manager</option>
    </FloatLabelSelect>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Users, X } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const establishment = ref<any>(null)
const staffList = ref<any[]>([])
const loadingData = ref(true)
const loading = ref(false)
const removingId = ref('')
const error = ref('')
const errors = ref({ full_name: '', username: '', email: '', pin: '' })
const staffForm = ref({ full_name: '', username: '', email: '', pin: '', role: 'staff' })

const canSubmit = computed(() =>
  !!staffForm.value.full_name.trim() && !!staffForm.value.username.trim() && /^\d{4}$/.test(staffForm.value.pin)
)

const initials = (name: string) =>
  (name || '?').split(/\s+/).map(w => w[0]).join('').slice(0, 2).toUpperCase()

const loadStaff = async () => {
  const { data, error: loadError } = await supabase
    .from('staff')
    .select('id, full_name, username, email, role, is_active')
    .eq('establishment_id', route.params.id as string)
    .eq('is_active', true)
    .order('username')
  if (loadError) {
    showToast.error('Erreur lors du chargement du personnel')
    return
  }
  staffList.value = data || []
}

onMounted(async () => {
  const { data, error: loadError } = await supabase
    .from('establishments')
    .select('id, name')
    .eq('id', route.params.id as string)
    .maybeSingle()
  if (loadError) error.value = loadError.message
  establishment.value = data
  if (data) await loadStaff()
  loadingData.value = false
})

const validate = () => {
  errors.value = { full_name: '', username: '', email: '', pin: '' }
  if (!staffForm.value.full_name.trim()) errors.value.full_name = 'Le nom complet est requis'
  if (!staffForm.value.username.trim()) errors.value.username = "Le nom d'utilisateur est requis"
  if (staffForm.value.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(staffForm.value.email)) errors.value.email = 'Email invalide'
  if (!/^\d{4}$/.test(staffForm.value.pin)) errors.value.pin = 'Le code PIN doit contenir exactement 4 chiffres'
  return !Object.values(errors.value).some(Boolean)
}

const handleSubmit = async () => {
  if (!validate()) return
  loading.value = true
  error.value = ''
  try {
    const { error: insertError } = await supabase.from('staff').insert({
      establishment_id: establishment.value.id,
      full_name: staffForm.value.full_name.trim(),
      username: staffForm.value.username.trim(),
      email: staffForm.value.email.trim() || null,
      pin: staffForm.value.pin,
      role: staffForm.value.role,
      is_active: true
    })
    if (insertError) {
      // staff(establishment_id, username) est unique
      throw new Error(insertError.code === '23505' ? "Ce nom d'utilisateur existe déjà dans cet établissement" : insertError.message)
    }
    showToast.success('Membre ajouté avec succès')
    staffForm.value = { full_name: '', username: '', email: '', pin: '', role: 'staff' }
    await loadStaff()
  } catch (err: any) {
    error.value = err?.message || 'Une erreur est survenue'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}

// Le membre est désactivé et non supprimé : son historique de commandes est conservé
const removeStaff = async (member: any) => {
  if (!confirm(`Retirer ${member.full_name || member.username} du personnel ?`)) return
  removingId.value = member.id
  try {
    const { error: updateError } = await supabase.from('staff').update({ is_active: false }).eq('id', member.id)
    if (updateError) throw updateError
    showToast.success('Membre retiré du personnel')
    await loadStaff()
  } catch (err: any) {
    showToast.error(err?.message || 'Une erreur est survenue')
  } finally {
    removingId.value = ''
  }
}
</script>
