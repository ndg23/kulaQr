<template>
  <!-- L'écran de travail : ce qui attend une action, la plus ancienne en premier, un seul bouton par commande -->
  <div class="space-y-4">
    <!-- Files d'attente : un coup d'œil, un appui -->
    <div class="grid grid-cols-4 gap-2" role="tablist" aria-label="Files de commandes">
      <button
        v-for="q in queues"
        :key="q.key"
        type="button"
        role="tab"
        :aria-selected="queueKey === q.key"
        class="rounded-3xl py-3 px-1 flex flex-col items-center gap-0.5 active:scale-[0.97] transition-all"
        :class="queueKey === q.key ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
        @click="queue = q.key"
      >
        <span
          class="text-2xl font-black tabular-nums leading-none"
          :class="queueKey !== q.key && q.count > 0 && q.alert ? 'text-[#C54E00]' : ''"
        >{{ q.count }}</span>
        <span class="text-[11px] font-extrabold leading-tight text-center" :class="queueKey === q.key ? 'text-white/80' : 'text-gray-500'">{{ q.label }}</span>
      </button>
    </div>

    <!-- Chargement -->
    <div v-if="loading && !orders.length" class="grid grid-cols-1 lg:grid-cols-2 gap-3" aria-busy="true">
      <div v-for="i in 4" :key="i" class="h-56 rounded-[2rem] bg-gray-100 animate-pulse"></div>
    </div>

    <!-- Erreur -->
    <div v-else-if="loadError && !orders.length" class="rounded-[2rem] bg-[#FFECD8] px-6 py-10 text-center" role="alert">
      <AlertTriangle class="w-10 h-10 text-[#C54E00] mx-auto" />
      <h3 class="mt-3 text-lg font-black text-gray-900">Impossible de charger les commandes</h3>
      <button type="button" class="mt-4 h-12 px-6 rounded-full bg-black text-white font-extrabold active:scale-[0.97] transition-all" @click="load()">Réessayer</button>
    </div>

    <!-- Rien à faire -->
    <div v-else-if="!visible.length" class="rounded-[2rem] bg-gray-100 px-6 py-16 text-center">
      <span class="w-16 h-16 mx-auto rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><Check class="w-8 h-8" :stroke-width="3.5" /></span>
      <h3 class="mt-4 text-xl font-black text-gray-900">Tout est à jour</h3>
      <p class="mt-1 text-sm font-semibold text-gray-500">Les nouvelles commandes apparaissent ici toutes seules.</p>
      <NuxtLink to="/staff/vendre" class="mt-5 inline-flex items-center gap-2 h-12 px-6 rounded-full bg-black text-white text-sm font-extrabold active:scale-[0.97] transition-all">
        <Plus class="w-4 h-4" :stroke-width="3" /> Prendre une commande
      </NuxtLink>
    </div>

    <!-- Les commandes, la plus ancienne d'abord -->
    <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-3 items-start">
      <article
        v-for="order in visible"
        :key="order.id"
        class="rounded-[2rem] bg-gray-100 p-4 sm:p-5 cursor-pointer active:scale-[0.99] transition-all"
        :class="fresh.includes(order.id) ? 'ring-4 ring-[#FB6A00] animate-pulse' : ''"
        @click="selectedId = order.id"
      >
        <div class="flex items-center justify-between gap-3">
          <div class="flex items-center gap-2 min-w-0">
            <span class="inline-flex items-center h-11 px-5 rounded-full bg-black text-white text-lg font-black">{{ tableOf(order) }}</span>
            <span v-if="order.tables?.type === 'VIP'" class="inline-flex items-center h-7 px-3 rounded-full bg-[#FB6A00] text-black text-xs font-black">VIP</span>
            <span v-if="order.tables?.section_name" class="text-xs font-bold text-gray-500 truncate">{{ order.tables.section_name }}</span>
          </div>
          <span
            class="inline-flex items-center gap-1.5 h-9 px-4 rounded-full text-sm font-black tabular-nums flex-shrink-0"
            :class="urgency(order)"
          >
            <Clock class="w-4 h-4" :stroke-width="2.5" />
            {{ ageLabel(order.created_at, now) }}
          </span>
        </div>

        <ul class="mt-3 space-y-1">
          <li v-for="item in order.items.slice(0, 4)" :key="item.id" class="flex gap-2 text-[15px]">
            <span class="font-black text-gray-900 tabular-nums w-8 flex-shrink-0">{{ item.quantity }}×</span>
            <span class="font-bold text-gray-900 min-w-0 break-words">{{ item.name }}<span v-if="item.notes" class="block text-xs font-semibold text-[#C54E00]">{{ item.notes }}</span></span>
          </li>
          <li v-if="order.items.length > 4" class="pl-10 text-xs font-extrabold text-gray-500">+{{ order.items.length - 4 }} autre{{ order.items.length - 4 > 1 ? 's' : '' }}</li>
        </ul>

        <p v-if="order.notes" class="mt-3 rounded-3xl bg-[#FFECD8] px-4 py-2 text-sm font-bold text-[#7C2900] break-words line-clamp-2">{{ order.notes }}</p>

        <div class="mt-4 flex items-center gap-2">
          <div class="leading-tight min-w-0">
            <p class="text-[11px] font-extrabold uppercase tracking-wide text-gray-500">{{ STATUS_LABEL[order.status] }}</p>
            <p class="text-lg font-black text-gray-900 tabular-nums">{{ money(order.total_amount) }}</p>
          </div>
          <button
            v-if="NEXT_STEP[order.status]"
            type="button"
            :disabled="busyId === order.id"
            class="ml-auto h-14 px-6 rounded-full bg-black text-white text-sm font-black uppercase tracking-wide disabled:opacity-50 active:scale-[0.96] transition-all"
            @click.stop="advance(order)"
          >{{ busyId === order.id ? '…' : NEXT_STEP[order.status]!.label }}</button>
        </div>
      </article>
    </div>

    <OrderSheet :order="selected" @close="selectedId = null" @status="onSheetStatus" @print="printOrder" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { AlertTriangle, Check, Clock, Plus } from 'lucide-vue-next'
import OrderSheet from '~/components/staff/OrderSheet.vue'

definePageMeta({ layout: 'staff' })

const { staff, establishment, orders, loading, loadError, fresh, load, setStatus } = useStaffSpace()

// Le temps qui passe : les durées et les couleurs d'urgence se mettent à jour sans recharger
const now = ref(Date.now())
let tick: ReturnType<typeof setInterval> | null = null
onMounted(() => { tick = setInterval(() => { now.value = Date.now() }, 20000) })
onBeforeUnmount(() => { if (tick) clearInterval(tick) })

const ACTIVE = ['pending', 'confirmed', 'processing']
const queue = ref<string>('')
// La cuisine arrive directement sur ce qu'elle doit préparer ; le reste sur tout ce qui est actif
const queueKey = computed(() => queue.value || (staff.value?.role === 'kitchen' ? 'confirmed' : 'active'))

const countOf = (status: string) => orders.value.filter(o => o.status === status).length
const queues = computed(() => [
  { key: 'active', label: 'Toutes', count: orders.value.filter(o => ACTIVE.includes(o.status)).length, alert: false },
  { key: 'pending', label: 'À accepter', count: countOf('pending'), alert: true },
  { key: 'confirmed', label: 'À préparer', count: countOf('confirmed'), alert: true },
  { key: 'processing', label: 'En cours', count: countOf('processing'), alert: false }
])

const visible = computed(() => {
  const wanted = queueKey.value === 'active' ? ACTIVE : [queueKey.value]
  return orders.value
    .filter(o => wanted.includes(o.status))
    // La plus ancienne d'abord : premier arrivé, premier servi
    .sort((a, b) => +new Date(a.created_at) - +new Date(b.created_at))
})

const tableOf = (o: any) => {
  const t = o.tables?.table_number || o.table_number
  return t ? `Table ${t}` : 'À emporter'
}

// Couleur d'urgence : calme, puis orange, puis noir plein
const urgency = (o: any) => {
  const m = ageMinutes(o.created_at, now.value)
  if (!ACTIVE.includes(o.status)) return 'bg-white text-gray-700'
  if (m >= 20) return 'bg-black text-white'
  if (m >= 10) return 'bg-[#FB6A00] text-black'
  return 'bg-white text-gray-900'
}

const money = (v: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(v) || 0)

// Un appui = la commande avance
const busyId = ref<string | null>(null)
const advance = async (order: any) => {
  const step = NEXT_STEP[order.status]
  if (!step || busyId.value) return
  busyId.value = order.id
  await setStatus(order.id, step.to)
  busyId.value = null
}

// Fiche détaillée en feuille
const selectedId = ref<string | null>(null)
const selected = computed(() => orders.value.find(o => o.id === selectedId.value) || null)
const onSheetStatus = async ({ id, status }: { id: string, status: string }) => {
  const ok = await setStatus(id, status)
  if (ok && ['completed', 'cancelled'].includes(status)) selectedId.value = null
}

const printOrder = (order: any) => {
  printTicket(order, establishment.value?.name || '')
}
</script>
