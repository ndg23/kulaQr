<template>
  <!-- Après création : le PIN généré n'est montré qu'ici -->
  <div v-if="createdPin" class="mx-auto max-w-2xl">
    <div class="rounded-[2rem] bg-white border border-gray-200 p-6 sm:p-10 text-center space-y-5">
      <span class="mx-auto w-14 h-14 rounded-full bg-[#00E676] text-black flex items-center justify-center">
        <Check class="w-7 h-7" :stroke-width="3" />
      </span>
      <div>
        <h1 class="text-2xl font-extrabold text-gray-900">Membre ajouté</h1>
        <p class="text-sm text-gray-500 mt-1">Communiquez-lui son identifiant et ce code PIN.</p>
      </div>

      <div class="rounded-3xl bg-gray-100 p-5 space-y-3">
        <div>
          <p class="text-xs font-bold uppercase tracking-wide text-gray-500">Identifiant</p>
          <p class="text-lg font-extrabold text-gray-900 break-words">{{ createdUsername }}</p>
        </div>
        <div>
          <p class="text-xs font-bold uppercase tracking-wide text-gray-500">Code PIN</p>
          <p class="text-4xl font-black tracking-[0.3em] text-gray-900 tabular-nums">{{ createdPin }}</p>
        </div>
      </div>

      <p class="text-xs text-gray-500">Vous pourrez régénérer ce code depuis la liste du personnel.</p>

      <div class="flex flex-col sm:flex-row gap-3 sm:justify-center">
        <button
          type="button"
          class="h-12 px-6 rounded-full bg-gray-100 text-gray-900 font-bold hover:bg-gray-200 active:scale-[0.97] transition-all"
          @click="addAnother"
        >
          Ajouter un autre membre
        </button>
        <NuxtLink
          :to="`/manager/${slug}/staff`"
          class="h-12 px-8 rounded-full bg-gray-900 text-white font-bold inline-flex items-center justify-center hover:bg-gray-800 active:scale-[0.97] transition-all"
        >
          Terminé
        </NuxtLink>
      </div>
    </div>
  </div>

  <PageForm
    v-else
    :title="member ? 'Modifier le membre' : 'Nouveau membre'"
    :subtitle="member ? member.username : 'Un code PIN sera généré automatiquement'"
    :back-to="`/manager/${slug}/staff`"
    back-label="Retour au personnel"
    :submit-label="member ? 'Mettre à jour' : 'Ajouter le membre'"
    :loading="loading"
    :error="error"
    @submit="handleSubmit"
  >
    <FloatLabelInput id="username" v-model="form.username" label="Nom d'utilisateur" autocomplete="off" :error="errors.username" :show-char-count="false" pill required />

    <FloatLabelSelect id="role" v-model="form.role" label="Rôle" pill>
      <option value="staff">Staff</option>
      <option value="waiter">Serveur</option>
      <option value="kitchen">Cuisine</option>
      <option value="manager">Manager</option>
    </FloatLabelSelect>

    <!-- Code PIN : visible à la demande, régénérable -->
    <div v-if="member" class="rounded-3xl bg-gray-100 p-4 flex items-center gap-3">
      <div class="flex-1 min-w-0">
        <p class="text-xs font-bold uppercase tracking-wide text-gray-500">Code PIN</p>
        <p class="text-2xl font-black tracking-[0.3em] text-gray-900 tabular-nums">{{ showPin ? currentPin : '••••' }}</p>
      </div>
      <button
        type="button"
        :aria-label="showPin ? 'Masquer le PIN' : 'Afficher le PIN'"
        class="w-11 h-11 rounded-full bg-white text-gray-700 flex items-center justify-center hover:bg-gray-200 active:scale-[0.95] transition-all"
        @click="showPin = !showPin"
      >
        <EyeOff v-if="showPin" class="w-5 h-5" />
        <Eye v-else class="w-5 h-5" />
      </button>
      <button
        type="button"
        :disabled="regenerating"
        class="h-11 px-4 rounded-full bg-gray-900 text-white text-sm font-bold inline-flex items-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all disabled:opacity-50"
        @click="regeneratePin"
      >
        <RefreshCw :class="['w-4 h-4', regenerating ? 'animate-spin' : '']" />
        Régénérer
      </button>
    </div>

    <div v-if="member" class="flex gap-2" role="radiogroup" aria-label="Statut du compte">
      <button
        v-for="s in statusChoices"
        :key="String(s.value)"
        type="button"
        role="radio"
        :aria-checked="form.is_active === s.value"
        :class="[
          'flex-1 h-12 rounded-full font-bold transition-colors active:scale-[0.97]',
          form.is_active === s.value ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
        ]"
        @click="form.is_active = s.value"
      >{{ s.label }}</button>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Check, Eye, EyeOff, RefreshCw } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

const props = defineProps<{
  slug: string
  member?: any
}>()

const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const statusChoices = [
  { value: true, label: 'Compte actif' },
  { value: false, label: 'Compte inactif' }
]

const loading = ref(false)
const error = ref('')
const errors = ref({ username: '' })
const createdPin = ref('')
const createdUsername = ref('')
const form = ref({
  username: props.member?.username || '',
  role: props.member?.role || 'staff',
  is_active: props.member?.is_active !== false
})

const showPin = ref(false)
const regenerating = ref(false)
const currentPin = ref(String(props.member?.pin ?? ''))

const regeneratePin = async () => {
  if (!props.member?.id) return
  if (!confirm("Générer un nouveau code PIN ? L'ancien ne fonctionnera plus.")) return
  regenerating.value = true
  try {
    const { data, error: rpcError } = await supabase.rpc('regenerate_staff_pin', { p_staff_id: props.member.id })
    if (rpcError) throw rpcError
    currentPin.value = String(data)
    showPin.value = true
    showToast.success('Nouveau code PIN généré')
  } catch (err: any) {
    showToast.error(err?.message || 'Impossible de régénérer le PIN')
  } finally {
    regenerating.value = false
  }
}

const addAnother = () => {
  createdPin.value = ''
  createdUsername.value = ''
  form.value = { username: '', role: 'staff', is_active: true }
}

const handleSubmit = async () => {
  errors.value = { username: '' }
  if (!form.value.username.trim()) {
    errors.value.username = "Le nom d'utilisateur est requis"
    return
  }
  loading.value = true
  error.value = ''
  try {
    if (props.member?.id) {
      const { error: updateError } = await supabase
        .from('staff')
        .update({
          username: form.value.username.trim(),
          role: form.value.role,
          is_active: form.value.is_active
        })
        .eq('id', props.member.id)
      if (updateError) throw updateError
      showToast.success('Membre mis à jour avec succès')
      await navigateTo(`/manager/${props.slug}/staff`)
      return
    }

    // La fonction génère un PIN aléatoire unique pour l'établissement (plus de PIN 1234 par défaut)
    const { data, error: rpcError } = await supabase.rpc('create_staff_pin', {
      p_username: form.value.username.trim(),
      p_establishment_id: props.slug,
      p_role: form.value.role
    })
    if (rpcError) {
      // staff(establishment_id, username) est unique
      throw new Error(rpcError.code === '23505' ? "Ce nom d'utilisateur existe déjà" : rpcError.message)
    }
    createdUsername.value = data?.username || form.value.username
    createdPin.value = String(data?.pin || '')
    showToast.success('Nouveau membre ajouté avec succès')
  } catch (err: any) {
    error.value = err?.message || 'Impossible de sauvegarder le membre'
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
