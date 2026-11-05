<template>
  <!-- Écran de prise de commande du personnel : même principe que la vente de l'agent dans le back-office web
       (grille de produits, panier noir flottant, validation en feuille, commande enregistrée) -->
  <div class="min-h-[calc(100dvh-8rem)] flex flex-col pb-32">
    <header class="flex items-center gap-3 mb-3">
      <NuxtLink
        to="/staff"
        aria-label="Retour aux commandes"
        class="w-11 h-11 flex-shrink-0 rounded-full bg-gray-100 flex items-center justify-center text-gray-900 hover:bg-gray-200 active:scale-[0.94] transition-all"
      >
        <ArrowLeft class="w-5 h-5" :stroke-width="2.5" />
      </NuxtLink>
      <h1 class="flex-1 text-2xl font-black tracking-tight text-gray-900">Nouvelle commande</h1>
      <span v-if="tableLabel" class="inline-flex items-center h-9 px-4 rounded-full bg-black text-white text-xs font-extrabold">{{ tableLabel }}</span>
    </header>

    <p v-if="fatal" class="rounded-3xl bg-[#FFD4AD] text-[#7C2900] text-sm font-bold px-5 py-4" role="alert">{{ fatal }}</p>

    <template v-else>
      <input
        v-model="search"
        type="search"
        placeholder="Rechercher un produit"
        class="w-full h-12 px-5 mb-3 rounded-full bg-gray-100 border-0 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-black"
      />

      <div v-if="categories.length > 1" class="flex gap-2 overflow-x-auto pb-2 mb-1 scrollbar-hide" role="tablist" aria-label="Catégories">
        <button
          type="button"
          role="tab"
          :aria-selected="!activeCategory"
          class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
          :class="!activeCategory ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
          @click="activeCategory = ''"
        >Tout</button>
        <button
          v-for="cat in categories"
          :key="cat.id"
          type="button"
          role="tab"
          :aria-selected="activeCategory === cat.id"
          class="h-10 px-4 rounded-full text-sm font-extrabold whitespace-nowrap flex-shrink-0 active:scale-[0.97] transition-all"
          :class="activeCategory === cat.id ? 'bg-black text-white' : 'bg-gray-100 text-gray-900 hover:bg-gray-200'"
          @click="activeCategory = cat.id"
        >{{ cat.name }}</button>
      </div>

      <div v-if="loading" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3" aria-busy="true">
        <div v-for="i in 8" :key="i" class="rounded-3xl bg-gray-100 animate-pulse" style="aspect-ratio: 1 / 1"></div>
      </div>
      <p v-else-if="!visibleProducts.length" class="rounded-3xl bg-gray-100 px-5 py-10 text-center text-sm font-semibold text-gray-500">
        {{ search ? 'Aucun résultat' : 'Aucun produit disponible' }}
      </p>

      <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
        <div v-for="p in visibleProducts" :key="p.id" class="relative">
          <button
            type="button"
            class="relative block w-full rounded-3xl overflow-hidden bg-gray-100 border border-gray-200 text-left active:scale-[0.97] transition-all"
            style="aspect-ratio: 1 / 1"
            :aria-label="`Ajouter ${p.name}`"
            @click="change(p.id, 1)"
          >
            <img v-if="p.image_url" :src="p.image_url" :alt="p.name" loading="lazy" class="absolute inset-0 w-full h-full object-cover" />
            <span v-else class="absolute inset-0 flex items-center justify-center bg-[#FB6A00] text-5xl font-black text-black">{{ (p.name || '?').charAt(0).toUpperCase() }}</span>
            <span class="absolute inset-x-2 bottom-2 rounded-2xl bg-white/95 text-black px-3 py-1.5 leading-tight">
              <span class="block text-sm font-black truncate">{{ p.name }}</span>
              <span class="block text-xs font-extrabold tabular-nums">{{ formatPrice(p.price) }}</span>
            </span>
          </button>
          <span
            v-if="quantities[p.id]"
            class="absolute -right-1.5 -top-1.5 min-w-[26px] h-[26px] px-1.5 rounded-full bg-[#FB6A00] text-black text-sm font-black flex items-center justify-center"
          >{{ quantities[p.id] }}</span>
          <button
            v-if="quantities[p.id]"
            type="button"
            :aria-label="`Retirer un ${p.name}`"
            class="absolute right-2 top-2 w-9 h-9 rounded-full bg-black text-white flex items-center justify-center active:scale-[0.92] transition-all"
            @click="change(p.id, -1)"
          ><Minus class="w-5 h-5" :stroke-width="3" /></button>
        </div>
      </div>
    </template>

    <!-- Panier flottant -->
    <div v-if="itemCount" class="fixed inset-x-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-30 mx-auto max-w-xl">
      <button
        type="button"
        class="w-full h-[68px] pl-6 pr-2 rounded-full bg-black text-white flex items-center gap-3 active:scale-[0.98] transition-all"
        @click="checkoutOpen = true"
      >
        <span class="min-w-0 flex-1 text-left leading-tight">
          <span class="block text-sm font-black">{{ itemCount }} article{{ itemCount > 1 ? 's' : '' }}</span>
          <span class="block text-[11px] font-semibold opacity-70 truncate">{{ recap }}</span>
        </span>
        <span class="text-xl font-black tabular-nums">{{ formatPrice(total) }}</span>
        <span class="w-[52px] h-[52px] flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><ArrowRight class="w-6 h-6" :stroke-width="3" /></span>
      </button>
    </div>

    <!-- Validation -->
    <UiBottomSheet v-model="checkoutOpen" title="Commande">
      <div class="rounded-[2rem] bg-[#FB6A00] text-black p-5 mb-3">
        <p class="text-xs font-extrabold uppercase">{{ itemCount }} article{{ itemCount > 1 ? 's' : '' }}</p>
        <p class="text-5xl font-black tabular-nums tracking-tight break-words">{{ formatPrice(total) }}</p>
      </div>

      <ul class="mb-3 space-y-2">
        <li v-for="line in lines" :key="line.id" class="flex items-center gap-3 rounded-3xl bg-gray-100 px-4 py-2.5">
          <span class="min-w-0 flex-1">
            <span class="block font-extrabold text-gray-900 break-words">{{ line.quantity }} × {{ line.name }}</span>
            <span class="block text-xs font-semibold text-gray-500">{{ formatPrice(line.price) }}</span>
          </span>
          <span class="font-black tabular-nums text-gray-900">{{ formatPrice(line.price * line.quantity) }}</span>
          <button type="button" :aria-label="`Retirer ${line.name}`" class="w-9 h-9 rounded-full bg-white flex items-center justify-center text-gray-600" @click="remove(line.id)"><X class="w-4 h-4" :stroke-width="2.5" /></button>
        </li>
      </ul>

      <!-- Table -->
      <p class="text-sm font-extrabold text-gray-900 px-1 mb-2">Table</p>
      <div role="radiogroup" aria-label="Table" class="flex flex-wrap gap-2 mb-3">
        <button
          type="button"
          role="radio"
          :aria-checked="!tableId"
          class="h-11 px-5 rounded-full text-sm font-extrabold active:scale-[0.97] transition-all"
          :class="!tableId ? 'bg-black text-white' : 'bg-gray-100 text-gray-900'"
          @click="tableId = ''"
        >À emporter</button>
        <button
          v-for="t in tables"
          :key="t.id"
          type="button"
          role="radio"
          :aria-checked="tableId === t.id"
          class="h-11 px-5 rounded-full text-sm font-extrabold active:scale-[0.97] transition-all"
          :class="tableId === t.id ? 'bg-black text-white' : 'bg-gray-100 text-gray-900'"
          @click="tableId = t.id"
        >{{ t.table_number }}</button>
      </div>

      <textarea
        v-model="notes"
        rows="2"
        placeholder="Notes (facultatif)"
        class="w-full px-5 py-3 rounded-3xl bg-gray-100 border-0 text-gray-900 placeholder-gray-400 resize-none focus:outline-none focus:ring-2 focus:ring-black"
      />

      <p v-if="errorText" class="mt-3 rounded-3xl bg-[#FFD4AD] text-[#7C2900] text-sm font-bold px-4 py-3" role="alert">{{ errorText }}</p>

      <button
        type="button"
        :disabled="validating || !itemCount"
        class="mt-4 w-full h-16 rounded-full bg-black text-white text-lg font-black uppercase disabled:opacity-40 active:scale-[0.98] transition-all"
        @click="validate"
      >{{ validating ? '…' : 'Envoyer la commande' }}</button>
    </UiBottomSheet>

    <!-- Commande enregistrée : fermer la feuille = nouvelle commande -->
    <UiBottomSheet v-model="doneOpen" title="Commande envoyée">
      <div class="flex flex-col items-center text-center py-2">
        <span class="w-20 h-20 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><Check class="w-10 h-10" :stroke-width="4" /></span>
        <p class="mt-4 text-5xl font-black tabular-nums tracking-tight text-gray-900 break-words">{{ formatPrice(receipt?.total || 0) }}</p>
        <p class="mt-2 text-sm font-extrabold text-gray-500">{{ receipt?.where }} · {{ receipt?.time }}</p>
      </div>
      <div class="space-y-2 mt-3">
        <button type="button" class="w-full h-16 rounded-full bg-black text-white text-lg font-black uppercase active:scale-[0.98] transition-all" @click="doneOpen = false">Nouvelle commande</button>
        <button type="button" class="w-full h-14 rounded-full bg-gray-100 text-gray-900 font-black uppercase inline-flex items-center justify-center gap-2 active:scale-[0.98] transition-all" @click="printReceipt"><Printer class="w-5 h-5" :stroke-width="2.5" /> Imprimer le ticket</button>
        <button type="button" class="w-full h-12 rounded-full text-gray-700 font-black uppercase" @click="goHome">Retour aux commandes</button>
      </div>
    </UiBottomSheet>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ArrowLeft, ArrowRight, Check, Minus, Printer, X } from 'lucide-vue-next'
import UiBottomSheet from '~/components/ui/BottomSheet.vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'staff' })

const { client: supabase } = useSupabaseWrapper()

const token = ref('')
const establishmentId = ref('')
const loading = ref(true)
const fatal = ref('')
const shopName = ref('')

const categories = ref<any[]>([])
const tables = ref<any[]>([])
const quantities = ref<Record<string, number>>({})
const search = ref('')
const activeCategory = ref('')
const tableId = ref('')
const notes = ref('')

const checkoutOpen = ref(false)
const doneOpen = ref(false)
const validating = ref(false)
const errorText = ref('')
const receipt = ref<{ total: number, where: string, time: string, ticket: any } | null>(null)

const products = computed(() => categories.value.flatMap(c => c.products))
const visibleProducts = computed(() => {
  const q = search.value.trim().toLowerCase()
  return categories.value
    .filter(c => !activeCategory.value || c.id === activeCategory.value)
    .flatMap(c => c.products)
    .filter(p => !q || String(p.name || '').toLowerCase().includes(q))
})
const lines = computed(() =>
  products.value
    .filter(p => quantities.value[p.id])
    .map(p => ({ id: p.id, name: p.name, price: Number(p.price), quantity: quantities.value[p.id] }))
)
const itemCount = computed(() => Object.values(quantities.value).reduce((n, q) => n + q, 0))
const total = computed(() => lines.value.reduce((sum, l) => sum + l.price * l.quantity, 0))
const recap = computed(() =>
  lines.value.map(l => `${l.quantity}× ${l.name.length > 22 ? l.name.slice(0, 21) + '…' : l.name}`).join(', ')
)
const tableLabel = computed(() => {
  const t = tables.value.find(x => x.id === tableId.value)
  return t ? `Table ${t.table_number}` : ''
})

const formatPrice = (value: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(value) || 0)

const change = (id: string, delta: number) => {
  const next = Math.min(99, (quantities.value[id] || 0) + delta)
  const copy = { ...quantities.value }
  if (next <= 0) delete copy[id]
  else copy[id] = next
  quantities.value = copy
}
const remove = (id: string) => {
  const copy = { ...quantities.value }
  delete copy[id]
  quantities.value = copy
  if (!itemCount.value) checkoutOpen.value = false
}

onMounted(async () => {
  try {
    const session = JSON.parse(localStorage.getItem('staff_session') || 'null')
    if (!session?.token || !session?.establishment_id) {
      await navigateTo('/auth/pin')
      return
    }
    token.value = session.token
    establishmentId.value = session.establishment_id

    const [tablesRes, categoriesRes, productsRes] = await Promise.all([
      supabase.from('tables').select('id, table_number, section_name').eq('establishment_id', establishmentId.value).eq('is_active', true).order('table_number'),
      supabase.from('categories').select('id, name').eq('establishment_id', establishmentId.value).order('order_number'),
      supabase.from('products').select('id, name, price, category_id, image_url').eq('establishment_id', establishmentId.value).eq('is_available', true).order('order_number')
    ])
    if (categoriesRes.error || productsRes.error) throw new Error('Impossible de charger le menu')
    tables.value = tablesRes.data || []
    const est = await supabase.from('establishments').select('name').eq('id', establishmentId.value).maybeSingle()
    shopName.value = (est.data as any)?.name || ''
    categories.value = (categoriesRes.data || [])
      .map((c: any) => ({ ...c, products: (productsRes.data || []).filter((p: any) => p.category_id === c.id) }))
      .filter((c: any) => c.products.length)
  } catch (e: any) {
    fatal.value = e?.message || 'Impossible de charger le menu'
  } finally {
    loading.value = false
  }
})

const validate = async () => {
  errorText.value = ''
  if (!itemCount.value) return
  validating.value = true
  try {
    const { data, error } = await (supabase as any).rpc('staff_create_order', {
      p_token: token.value,
      p_table_id: tableId.value || null,
      p_notes: notes.value.trim() || null,
      p_items: lines.value.map(l => ({ product_id: l.id, quantity: l.quantity }))
    })
    if (error) {
      // 28000 : session expirée, on repasse par la connexion
      if (error.code === '28000') {
        localStorage.removeItem('staff_session')
        await navigateTo('/auth/pin')
        return
      }
      throw new Error(error.message)
    }
    receipt.value = {
      total: Number(data?.total_amount ?? total.value),
      where: tableLabel.value || 'À emporter',
      time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
      // De quoi imprimer le ticket après la remise à zéro du panier
      ticket: {
        created_at: new Date().toISOString(),
        table_number: tables.value.find(x => x.id === tableId.value)?.table_number ?? null,
        status: 'confirmed',
        total_amount: Number(data?.total_amount ?? total.value),
        notes: notes.value.trim() || null,
        items: lines.value.map(l => ({ name: l.name, quantity: l.quantity, unit_price: l.price }))
      }
    }
    quantities.value = {}
    notes.value = ''
    checkoutOpen.value = false
    doneOpen.value = true
  } catch (e: any) {
    errorText.value = e?.message || "Impossible d'envoyer la commande. Réessayez."
  } finally {
    validating.value = false
  }
}

const printReceipt = () => {
  if (receipt.value?.ticket) printTicket(receipt.value.ticket, shopName.value)
}

const goHome = () => {
  doneOpen.value = false
  navigateTo('/staff')
}
</script>
