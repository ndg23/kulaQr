<template>
  <!-- Le bilan de la journée : pour regarder, pas pour travailler -->
  <div class="space-y-4">
    <HeroCard
      label="Ventes du jour"
      :value="money(total)"
      :hint="`${served.length} commande${served.length > 1 ? 's' : ''} servie${served.length > 1 ? 's' : ''}`"
      :chips="[
        { label: 'En cours', value: inProgress },
        { label: 'Panier moyen', value: money(average) },
        { label: 'Annulées', value: cancelled.length }
      ]"
    />

    <section v-if="mine.length" class="rounded-[2rem] bg-gray-100 p-5 flex items-center gap-4">
      <span class="w-12 h-12 flex-shrink-0 rounded-full bg-black text-white flex items-center justify-center"><User class="w-6 h-6" :stroke-width="2.5" /></span>
      <div class="min-w-0 flex-1">
        <p class="text-xs font-extrabold uppercase tracking-wide text-gray-500">Mes commandes</p>
        <p class="font-black text-gray-900">{{ mine.length }} aujourd'hui · {{ money(mineTotal) }}</p>
      </div>
    </section>

    <div v-if="loading && !orders.length" class="space-y-2" aria-busy="true">
      <div v-for="i in 5" :key="i" class="h-16 rounded-full bg-gray-100 animate-pulse"></div>
    </div>

    <p v-else-if="!today.length" class="rounded-[2rem] bg-gray-100 px-6 py-12 text-center text-sm font-semibold text-gray-500">
      Aucune commande aujourd'hui pour le moment.
    </p>

    <!-- L'historique du jour, la plus récente d'abord -->
    <ul v-else class="space-y-2">
      <li v-for="order in today" :key="order.id">
        <button
          type="button"
          class="w-full min-h-[4rem] pl-2 pr-5 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center gap-3 text-left active:scale-[0.99] transition-all"
          :class="order.status === 'cancelled' ? 'opacity-60' : ''"
          @click="selectedId = order.id"
        >
          <span class="w-12 h-12 flex-shrink-0 rounded-full bg-black text-white flex items-center justify-center text-sm font-black">{{ tableShort(order) }}</span>
          <span class="min-w-0 flex-1 leading-tight">
            <span class="block font-extrabold text-gray-900 truncate">{{ summary(order) }}</span>
            <span class="block text-xs font-semibold text-gray-500">{{ clock(order.created_at) }} · n° {{ order.orderNumber }}</span>
          </span>
          <span class="text-right flex-shrink-0 leading-tight">
            <span class="block font-black text-gray-900 tabular-nums" :class="order.status === 'cancelled' ? 'line-through' : ''">{{ money(order.total_amount) }}</span>
            <span class="inline-flex items-center h-5 px-2 rounded-full text-[10px] font-extrabold" :class="pill(order.status)">{{ STATUS_LABEL[order.status] }}</span>
          </span>
        </button>
      </li>
    </ul>

    <OrderSheet :order="selected" @close="selectedId = null" @status="onSheetStatus" @print="printOrder" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { User } from 'lucide-vue-next'
import HeroCard from '~/components/ui/HeroCard.vue'
import OrderSheet from '~/components/staff/OrderSheet.vue'

definePageMeta({ layout: 'staff' })

const { staff, establishment, orders, loading, setStatus } = useStaffSpace()

const startOfDay = () => { const d = new Date(); d.setHours(0, 0, 0, 0); return d.getTime() }

const today = computed(() => {
  const start = startOfDay()
  return orders.value
    .filter(o => new Date(o.created_at).getTime() >= start)
    .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
})
const served = computed(() => today.value.filter(o => o.status === 'completed'))
const cancelled = computed(() => today.value.filter(o => o.status === 'cancelled'))
const inProgress = computed(() => today.value.filter(o => ['pending', 'confirmed', 'processing'].includes(o.status)).length)
const sum = (rows: any[]) => rows.reduce((s, o) => s + (Number(o.total_amount) || 0), 0)
const total = computed(() => sum(served.value))
const average = computed(() => (served.value.length ? Math.round(total.value / served.value.length) : 0))
const mine = computed(() => today.value.filter(o => o.status !== 'cancelled' && o.staff_id && o.staff_id === staff.value?.id))
const mineTotal = computed(() => sum(mine.value))

const money = (v: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(v) || 0)
const clock = (iso: string) => new Date(iso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
const tableShort = (o: any) => o.tables?.table_number || o.table_number || '↗'
const summary = (o: any) => {
  const names = (o.items || []).map((i: any) => `${i.quantity}× ${i.name}`)
  return names.length ? names.slice(0, 2).join(', ') + (names.length > 2 ? '…' : '') : 'Commande'
}
const pill = (status: string) => ({
  pending: 'bg-[#FB6A00] text-black',
  confirmed: 'bg-black text-white',
  processing: 'bg-[#FFB77A] text-black',
  completed: 'bg-white text-black ring-1 ring-black',
  cancelled: 'bg-gray-300 text-gray-700'
} as Record<string, string>)[status] || 'bg-gray-200 text-gray-900'

const selectedId = ref<string | null>(null)
const selected = computed(() => orders.value.find(o => o.id === selectedId.value) || null)
const onSheetStatus = async ({ id, status }: { id: string, status: string }) => {
  const ok = await setStatus(id, status)
  if (ok && ['completed', 'cancelled'].includes(status)) selectedId.value = null
}
const printOrder = (order: any) => printTicket(order, establishment.value?.name || '')
</script>
