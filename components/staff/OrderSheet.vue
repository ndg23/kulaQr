<template>
  <!-- Fiche d'une commande : tout ce qu'il faut, sans quitter l'écran -->
  <UiBottomSheet
    :model-value="!!order"
    :title="order ? titleOf(order) : ''"
    :subtitle="order ? subtitleOf(order) : ''"
    @update:model-value="v => { if (!v) close() }"
  >
    <div v-if="order" class="space-y-3">
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center h-8 px-4 rounded-full text-xs font-extrabold" :class="statusPill(order.status)">{{ STATUS_LABEL[order.status] || order.status }}</span>
        <span v-if="order.staff?.username" class="inline-flex items-center h-8 px-4 rounded-full bg-gray-100 text-xs font-extrabold text-gray-900">{{ order.staff.username }}</span>
        <span class="inline-flex items-center h-8 px-4 rounded-full bg-gray-100 text-xs font-extrabold text-gray-900 tabular-nums">{{ clock(order.created_at) }}</span>
      </div>

      <ul class="space-y-2">
        <li v-for="item in order.items" :key="item.id" class="rounded-3xl bg-gray-100 px-4 py-3">
          <div class="flex items-start justify-between gap-3">
            <span class="font-extrabold text-gray-900 break-words min-w-0">{{ item.quantity }} × {{ item.name }}</span>
            <span class="font-black text-gray-900 tabular-nums flex-shrink-0">{{ money(item.unit_price * item.quantity) }}</span>
          </div>
          <p v-if="item.notes" class="mt-1 text-sm font-semibold text-[#C54E00] break-words">{{ item.notes }}</p>
        </li>
      </ul>

      <p v-if="order.notes" class="rounded-3xl bg-[#FFECD8] px-4 py-3 text-sm font-bold text-[#7C2900] break-words whitespace-pre-line">{{ order.notes }}</p>

      <div class="flex items-center justify-between rounded-full bg-[#FB6A00] px-5 h-14">
        <span class="text-sm font-extrabold text-black">Total</span>
        <span class="text-xl font-black text-black tabular-nums">{{ money(order.total_amount) }}</span>
      </div>

      <button
        v-if="NEXT_STEP[order.status]"
        type="button"
        :disabled="busy"
        class="w-full h-16 rounded-full bg-black text-white text-lg font-black uppercase tracking-wide disabled:opacity-50 active:scale-[0.98] transition-all"
        @click="advance"
      >{{ NEXT_STEP[order.status]!.label }}</button>

      <div class="grid gap-2" :class="canCancel ? 'grid-cols-2' : 'grid-cols-1'">
        <button
          type="button"
          class="h-12 rounded-full bg-gray-100 text-gray-900 font-extrabold inline-flex items-center justify-center gap-2 hover:bg-gray-200 active:scale-[0.97] transition-all"
          @click="$emit('print', order)"
        ><Printer class="w-4 h-4" :stroke-width="2.5" /> Ticket</button>

        <!-- Annuler en deux temps : pas de boîte de dialogue, le bouton demande confirmation -->
        <button
          v-if="canCancel"
          type="button"
          :disabled="busy"
          class="h-12 rounded-full font-extrabold active:scale-[0.97] transition-all disabled:opacity-50"
          :class="confirmCancel ? 'bg-[#C54E00] text-white' : 'bg-[#FFECD8] text-[#7C2900]'"
          @click="cancel"
        >{{ confirmCancel ? 'Confirmer l’annulation' : 'Annuler' }}</button>
      </div>
    </div>
  </UiBottomSheet>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Printer } from 'lucide-vue-next'
import UiBottomSheet from '~/components/ui/BottomSheet.vue'

const props = defineProps<{ order: any | null }>()
const emit = defineEmits<{
  (e: 'close'): void
  (e: 'status', payload: { id: string, status: string }): void
  (e: 'print', order: any): void
}>()

const busy = ref(false)
const confirmCancel = ref(false)
let confirmTimer: ReturnType<typeof setTimeout> | null = null

const canCancel = computed(() => props.order && ['pending', 'confirmed'].includes(props.order.status))

watch(() => [props.order?.id, props.order?.status], () => {
  confirmCancel.value = false
  busy.value = false
})

const close = () => emit('close')

const titleOf = (o: any) => {
  const table = o.tables?.table_number || o.table_number
  return table ? `Table ${table}` : 'À emporter'
}
const subtitleOf = (o: any) => `Commande n° ${o.orderNumber || ''}`

const money = (v: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(v) || 0)
const clock = (iso: string) =>
  new Date(iso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })

const statusPill = (status: string) => ({
  pending: 'bg-[#FB6A00] text-black',
  confirmed: 'bg-black text-white',
  processing: 'bg-[#FFB77A] text-black',
  completed: 'bg-white text-black ring-2 ring-black',
  cancelled: 'bg-gray-300 text-gray-700'
} as Record<string, string>)[status] || 'bg-gray-200 text-gray-900'

const advance = () => {
  if (!props.order) return
  const step = NEXT_STEP[props.order.status]
  if (!step) return
  busy.value = true
  emit('status', { id: props.order.id, status: step.to })
}

const cancel = () => {
  if (!props.order) return
  if (!confirmCancel.value) {
    confirmCancel.value = true
    if (confirmTimer) clearTimeout(confirmTimer)
    confirmTimer = setTimeout(() => { confirmCancel.value = false }, 4000)
    return
  }
  busy.value = true
  emit('status', { id: props.order.id, status: 'cancelled' })
}
</script>
