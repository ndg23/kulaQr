<template>
  <!-- Fiche d'une commande : tout ce qu'il faut, sans quitter l'écran -->
  <UiBottomSheet
    :model-value="!!order"
    :title="order ? titleOf(order) : ''"
    :subtitle="order ? subtitleOf(order) : ''"
    @update:model-value="v => { if (!v) close() }"
  >
    <div v-if="order" class="space-y-3">
      <div class="rounded-3xl bg-white border-2 px-4 py-3 flex flex-wrap items-center gap-2" :class="tone.border">
        <span class="inline-flex items-center gap-2 h-8 px-4 rounded-full bg-white border-2 text-xs font-extrabold" :class="[tone.border, tone.text]">
          <span class="w-2 h-2 rounded-full" :class="tone.dot"></span>{{ STATUS_LABEL[order.status] || order.status }}
        </span>
        <span class="inline-flex items-center h-8 px-4 rounded-full bg-white border border-gray-300 text-xs font-extrabold text-gray-900 tabular-nums">Reçue à {{ clock(order.created_at) }}</span>
        <span v-if="order.staff?.username" class="inline-flex items-center h-8 px-4 rounded-full bg-white border border-gray-300 text-xs font-extrabold text-gray-900">{{ order.staff.username }}</span>
        <span class="inline-flex items-center h-8 px-4 rounded-full bg-white border-2 text-xs font-extrabold" :class="isPaid ? 'border-[#16A34A] text-[#15803D]' : 'border-[#FB6A00] text-[#C54E00]'">{{ payLabel }}</span>
      </div>

      <ul class="space-y-2">
        <li v-for="item in order.items" :key="item.id" class="rounded-full bg-white border border-gray-200 pl-2 pr-5 min-h-[3.5rem] py-2 flex items-center gap-3">
          <span class="w-10 h-10 flex-shrink-0 rounded-full bg-black text-white flex items-center justify-center text-sm font-black tabular-nums">{{ item.quantity }}×</span>
          <span class="min-w-0 flex-1 leading-tight">
            <span class="block font-extrabold text-gray-900 break-words">{{ item.name }}</span>
            <span v-if="item.notes" class="block text-xs font-semibold text-[#C54E00] break-words">{{ item.notes }}</span>
          </span>
          <span class="font-black text-gray-900 tabular-nums flex-shrink-0">{{ money(item.unit_price * item.quantity) }}</span>
        </li>
      </ul>

      <p v-if="order.notes" class="rounded-3xl bg-white border-2 border-[#FB6A00] px-4 py-3 text-sm font-bold text-[#7C2900] break-words whitespace-pre-line">{{ order.notes }}</p>

      <div class="flex items-center justify-between rounded-full bg-white border-2 px-5 h-14" :class="tone.border">
        <span class="text-sm font-extrabold text-gray-900">Total</span>
        <span class="text-xl font-black tabular-nums" :class="tone.text">{{ money(order.total_amount) }}</span>
      </div>

      <button
        v-if="NEXT_STEP[order.status]"
        type="button"
        :disabled="busy"
        class="w-full h-16 rounded-full text-white text-lg font-black uppercase tracking-wide disabled:opacity-50 active:scale-[0.98] transition-all"
        :class="order.status === 'pending' ? 'bg-[#16A34A] hover:bg-[#15803D]' : 'bg-black'"
        @click="advance"
      >{{ NEXT_STEP[order.status]!.label }}</button>

      <div class="grid gap-2" :class="canCancel ? 'grid-cols-2' : 'grid-cols-1'">
        <button
          type="button"
          class="h-12 rounded-full bg-white border-2 border-gray-300 text-gray-900 font-extrabold inline-flex items-center justify-center gap-2 hover:bg-gray-50 active:scale-[0.97] transition-all"
          @click="$emit('print', order)"
        ><Printer class="w-4 h-4" :stroke-width="2.5" /> Ticket</button>

        <!-- Annuler en deux temps : pas de boîte de dialogue, le bouton demande confirmation -->
        <button
          v-if="canCancel"
          type="button"
          :disabled="busy"
          class="h-12 rounded-full font-extrabold active:scale-[0.97] transition-all disabled:opacity-50"
          :class="confirmCancel ? 'bg-[#DC2626] border-2 border-[#DC2626] text-white' : 'bg-white border-2 border-[#DC2626] text-[#B91C1C]'"
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

// Mêmes couleurs que les cartes de la liste : orange = à traiter, vert = en cours / terminé, rouge = en retard ou annulé
const TONES = {
  red: { border: 'border-[#DC2626]', text: 'text-[#B91C1C]', dot: 'bg-[#DC2626]' },
  orange: { border: 'border-[#FB6A00]', text: 'text-[#C54E00]', dot: 'bg-[#FB6A00]' },
  green: { border: 'border-[#16A34A]', text: 'text-[#15803D]', dot: 'bg-[#16A34A]' }
}
const tone = computed(() => {
  const o = props.order
  if (!o) return TONES.green
  const active = ['pending', 'confirmed', 'processing'].includes(o.status)
  if (o.status === 'cancelled' || (active && ageMinutes(o.created_at) >= 20)) return TONES.red
  if (o.status === 'pending' || o.status === 'confirmed') return TONES.orange
  return TONES.green
})

const METHODS: Record<string, string> = { cash: 'Espèces', card: 'Carte', mobile_money: 'Mobile Money', wave: 'Wave', orange_money: 'Orange Money' }
const isPaid = computed(() => props.order?.payment_status === 'paid')
const payLabel = computed(() => {
  const o = props.order
  if (!o) return ''
  return isPaid.value ? `Payé${o.payment_method ? ' · ' + (METHODS[o.payment_method] || o.payment_method) : ''}` : 'À payer'
})

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
