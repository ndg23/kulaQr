<template>
  <div class="mx-auto max-w-5xl pb-32">
    <!-- En-tête : retour, titre, table -->
    <header class="flex items-center gap-3 mb-4">
      <NuxtLink
        :to="`/manager/${slug}/orders`"
        aria-label="Retour aux commandes"
        class="w-11 h-11 flex-shrink-0 rounded-full bg-gray-100 flex items-center justify-center text-gray-900 hover:bg-gray-200 active:scale-[0.94] transition-all"
      >
        <ArrowLeft class="w-5 h-5" :stroke-width="2.5" />
      </NuxtLink>
      <div class="flex-1 min-w-0">
        <h1 class="text-2xl lg:text-3xl font-black tracking-tight text-gray-900">Nouvelle commande</h1>
        <p class="text-sm font-semibold text-gray-500">Saisie manuelle</p>
      </div>
      <select
        v-model="tableId"
        aria-label="Table"
        class="h-11 max-w-[45%] rounded-full bg-black text-white text-sm font-extrabold px-4 border-0 focus:outline-none focus:ring-2 focus:ring-[#FB6A00]"
      >
        <option value="">À emporter</option>
        <option v-for="t in tables" :key="t.id" :value="t.id">Table {{ t.table_number }}{{ t.section_name ? ` · ${t.section_name}` : '' }}</option>
      </select>
    </header>

    <p v-if="error" class="mb-3 rounded-3xl bg-[#FFECD8] text-[#7C2900] text-sm font-bold px-5 py-4" role="alert">{{ error }}</p>

    <!-- Chargement -->
    <div v-if="loadingData" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3" aria-busy="true">
      <div v-for="i in 8" :key="i" class="rounded-3xl bg-gray-100 animate-pulse" style="aspect-ratio: 1 / 1"></div>
    </div>

    <template v-else>
      <!-- Recherche et catégories -->
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

      <div v-if="!categories.length" class="rounded-3xl bg-gray-100 px-5 py-10 text-center">
        <p class="text-sm font-semibold text-gray-700">Aucun produit disponible</p>
        <NuxtLink :to="`/manager/${slug}/menu/new`" class="inline-flex items-center h-11 px-6 mt-3 rounded-full bg-black text-white text-sm font-extrabold">Ajouter un produit</NuxtLink>
      </div>
      <p v-else-if="!visibleProducts.length" class="rounded-3xl bg-gray-100 px-5 py-10 text-center text-sm font-semibold text-gray-500">Aucun résultat</p>

      <!-- Grille de produits : un appui ajoute, le rond noir retire -->
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

    <!-- Le panier flottant : ouvre la validation -->
    <div v-if="itemCount" class="fixed inset-x-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-30 mx-auto max-w-xl lg:ml-[calc(17.5rem+1rem)] xl:ml-[calc(21rem+1rem)] lg:max-w-xl">
      <button
        type="button"
        class="w-full h-[68px] pl-6 pr-2 rounded-full bg-black text-white flex items-center gap-3 active:scale-[0.98] transition-all"
        @click="sheetOpen = true"
      >
        <span class="min-w-0 flex-1 text-left leading-tight">
          <span class="block text-sm font-black">{{ itemCount }} article{{ itemCount > 1 ? 's' : '' }}</span>
          <span class="block text-[11px] font-semibold opacity-70 truncate">{{ recap }}</span>
        </span>
        <span class="text-xl font-black tabular-nums">{{ formatPrice(total) }}</span>
        <span class="w-[52px] h-[52px] flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><ArrowRight class="w-6 h-6" :stroke-width="3" /></span>
      </button>
    </div>

    <!-- Validation en feuille -->
    <Transition
      enter-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      leave-active-class="transition-opacity duration-150"
      leave-to-class="opacity-0"
    >
      <div v-if="sheetOpen" class="fixed inset-0 z-50 bg-black/40 flex items-end sm:items-center justify-center" @click.self="sheetOpen = false">
        <div class="w-full sm:max-w-lg max-h-[92dvh] overflow-y-auto rounded-t-[2rem] sm:rounded-[2rem] bg-white p-5 sm:p-6" role="dialog" aria-modal="true" aria-label="Valider la commande">
          <div class="flex items-center justify-between gap-3 mb-3">
            <h2 class="text-xl font-black text-gray-900">Commande</h2>
            <button type="button" aria-label="Fermer" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center" @click="sheetOpen = false"><X class="w-5 h-5" :stroke-width="2.5" /></button>
          </div>

          <div class="rounded-[2rem] bg-[#FB6A00] text-black p-5 mb-3">
            <p class="text-xs font-extrabold uppercase">{{ itemCount }} article{{ itemCount > 1 ? 's' : '' }}{{ tableLabel ? ` · ${tableLabel}` : '' }}</p>
            <p class="text-4xl sm:text-5xl font-black tabular-nums tracking-tight break-words">{{ formatPrice(total) }}</p>
          </div>

          <ul class="space-y-2 mb-3">
            <li v-for="line in lines" :key="line.id" class="flex items-center gap-3 rounded-3xl bg-gray-100 px-4 py-2.5">
              <span class="min-w-0 flex-1">
                <span class="block font-extrabold text-gray-900 break-words">{{ line.quantity }} × {{ line.name }}</span>
                <span class="block text-xs font-semibold text-gray-500">{{ formatPrice(line.price) }}</span>
              </span>
              <span class="font-black tabular-nums text-gray-900">{{ formatPrice(line.price * line.quantity) }}</span>
              <button type="button" :aria-label="`Retirer ${line.name}`" class="w-9 h-9 rounded-full bg-white flex items-center justify-center text-gray-600" @click="remove(line.id)"><X class="w-4 h-4" :stroke-width="2.5" /></button>
            </li>
          </ul>

          <textarea
            v-model="notes"
            rows="2"
            placeholder="Notes spéciales (facultatif)"
            class="w-full px-5 py-3 rounded-3xl bg-gray-100 border-0 text-gray-900 placeholder-gray-400 resize-none focus:outline-none focus:ring-2 focus:ring-black"
          />

          <button
            type="button"
            :disabled="loading || !itemCount"
            class="mt-4 w-full h-16 rounded-full bg-black text-white text-lg font-black uppercase disabled:opacity-40 active:scale-[0.98] transition-all"
            @click="handleSubmit"
          >{{ loading ? 'Création…' : 'Valider la commande' }}</button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ArrowLeft, ArrowRight, Minus, X } from 'lucide-vue-next'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const slug = String(route.params.slug)
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const tables = ref<any[]>([])
const categories = ref<any[]>([])
const quantities = ref<Record<string, number>>({})
const tableId = ref('')
const notes = ref('')
const search = ref('')
const activeCategory = ref('')
const sheetOpen = ref(false)
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')

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
  const next = (quantities.value[id] || 0) + delta
  const copy = { ...quantities.value }
  if (next <= 0) delete copy[id]
  else copy[id] = next
  quantities.value = copy
  if (!itemCount.value) sheetOpen.value = false
}
const remove = (id: string) => {
  const copy = { ...quantities.value }
  delete copy[id]
  quantities.value = copy
  if (!itemCount.value) sheetOpen.value = false
}

onMounted(async () => {
  const [tablesRes, categoriesRes, productsRes] = await Promise.all([
    supabase.from('tables').select('id, table_number, section_name').eq('establishment_id', slug).eq('is_active', true).order('table_number'),
    supabase.from('categories').select('id, name').eq('establishment_id', slug).order('order_number'),
    supabase.from('products').select('id, name, price, category_id, image_url').eq('establishment_id', slug).eq('is_available', true).order('order_number')
  ])
  tables.value = tablesRes.data || []
  categories.value = (categoriesRes.data || [])
    .map(c => ({ ...c, products: (productsRes.data || []).filter(p => p.category_id === c.id) }))
    .filter(c => c.products.length)
  loadingData.value = false
})

const handleSubmit = async () => {
  if (!itemCount.value) return
  loading.value = true
  error.value = ''
  try {
    const selectedTable = tables.value.find(t => t.id === tableId.value)
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        establishment_id: slug,
        table_id: tableId.value || null,
        table_number: selectedTable ? parseInt(selectedTable.table_number, 10) || null : null,
        status: 'confirmed',
        total_amount: total.value,
        notes: notes.value.trim() || null
      })
      .select('id')
      .single()
    if (orderError) throw orderError

    const items = products.value
      .filter(p => quantities.value[p.id])
      .map(p => ({
        order_id: order.id,
        product_id: p.id,
        quantity: quantities.value[p.id],
        unit_price: Number(p.price),
        subtotal: quantities.value[p.id] * Number(p.price)
      }))
    const { error: itemsError } = await supabase.from('order_items').insert(items)
    if (itemsError) {
      // Pas de commande vide : on annule celle qu'on vient de créer
      await supabase.from('orders').delete().eq('id', order.id)
      throw itemsError
    }

    showToast.success('Commande créée')
    await navigateTo(`/manager/${slug}/orders`)
  } catch (err: any) {
    error.value = err?.message || 'Impossible de créer la commande'
    sheetOpen.value = false
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
