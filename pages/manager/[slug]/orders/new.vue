<template>
  <PageForm
    title="Nouvelle commande"
    subtitle="Saisie manuelle d'une commande"
    :back-to="`/manager/${slug}/orders`"
    back-label="Retour aux commandes"
    submit-label="Créer la commande"
    loading-label="Création..."
    :loading="loading"
    :loading-data="loadingData"
    :submit-disabled="!itemCount"
    :error="error"
    wide
    @submit="handleSubmit"
  >
    <FloatLabelSelect id="table" v-model="tableId" label="Table" pill>
      <option value="">Sans table (à emporter)</option>
      <option v-for="t in tables" :key="t.id" :value="t.id">Table {{ t.table_number }}{{ t.section_name ? ` · ${t.section_name}` : '' }}</option>
    </FloatLabelSelect>

    <!-- Produits -->
    <section class="space-y-4">
      <h2 class="text-sm font-extrabold text-gray-900 px-1">Produits</h2>

      <div v-if="!categories.length" class="rounded-3xl bg-gray-100 px-5 py-6 text-center">
        <p class="text-sm font-semibold text-gray-700">Aucun produit disponible</p>
        <NuxtLink :to="`/manager/${slug}/menu/new`" class="inline-block mt-2 text-sm font-bold text-gray-900 underline">Ajouter un produit</NuxtLink>
      </div>

      <div v-for="cat in categories" :key="cat.id" class="space-y-2">
        <h3 class="text-xs font-bold uppercase tracking-wide text-gray-500 px-1">{{ cat.name }}</h3>
        <ul class="space-y-2">
          <li
            v-for="p in cat.products"
            :key="p.id"
            :class="[
              'flex items-center gap-3 rounded-full pl-5 pr-2 py-2 transition-colors',
              quantities[p.id] ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-900'
            ]"
          >
            <div class="flex-1 min-w-0">
              <p class="font-bold truncate">{{ p.name }}</p>
              <p :class="['text-xs', quantities[p.id] ? 'text-white/70' : 'text-gray-500']">{{ formatPrice(p.price) }}</p>
            </div>
            <div class="flex items-center gap-1 flex-shrink-0">
              <button
                v-if="quantities[p.id]"
                type="button"
                :aria-label="`Retirer un ${p.name}`"
                class="w-10 h-10 rounded-full bg-white/15 flex items-center justify-center hover:bg-white/25 active:scale-[0.94] transition-all"
                @click="change(p.id, -1)"
              >
                <Minus class="w-4 h-4" :stroke-width="3" />
              </button>
              <span v-if="quantities[p.id]" class="w-6 text-center font-black tabular-nums">{{ quantities[p.id] }}</span>
              <button
                type="button"
                :aria-label="`Ajouter un ${p.name}`"
                :class="[
                  'w-10 h-10 rounded-full flex items-center justify-center active:scale-[0.94] transition-all',
                  quantities[p.id] ? 'bg-white text-gray-900 hover:bg-gray-100' : 'bg-gray-900 text-white hover:bg-gray-800'
                ]"
                @click="change(p.id, 1)"
              >
                <Plus class="w-4 h-4" :stroke-width="3" />
              </button>
            </div>
          </li>
        </ul>
      </div>
    </section>

    <div>
      <label for="notes" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">Notes</label>
      <textarea
        id="notes"
        v-model="notes"
        rows="3"
        placeholder="Notes spéciales..."
        class="w-full px-5 py-4 border border-gray-200 rounded-3xl focus:outline-none focus:border-gray-900 resize-none"
      />
    </div>

    <!-- Total -->
    <div class="flex items-center justify-between rounded-full bg-[#FFF9C2] px-6 h-14">
      <span class="font-bold text-gray-900">{{ itemCount }} article{{ itemCount > 1 ? 's' : '' }}</span>
      <span class="text-xl font-black text-gray-900 tabular-nums">{{ formatPrice(total) }}</span>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Plus, Minus } from 'lucide-vue-next'
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
const loadingData = ref(true)
const loading = ref(false)
const error = ref('')

const products = computed(() => categories.value.flatMap(c => c.products))
const itemCount = computed(() => Object.values(quantities.value).reduce((n, q) => n + q, 0))
const total = computed(() =>
  products.value.reduce((sum, p) => sum + (quantities.value[p.id] || 0) * Number(p.price), 0)
)

const formatPrice = (value: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(value) || 0)

const change = (id: string, delta: number) => {
  const next = (quantities.value[id] || 0) + delta
  const copy = { ...quantities.value }
  if (next <= 0) delete copy[id]
  else copy[id] = next
  quantities.value = copy
}

onMounted(async () => {
  const [tablesRes, categoriesRes, productsRes] = await Promise.all([
    supabase.from('tables').select('id, table_number, section_name').eq('establishment_id', slug).eq('is_active', true).order('table_number'),
    supabase.from('categories').select('id, name').eq('establishment_id', slug).order('order_number'),
    supabase.from('products').select('id, name, price, category_id').eq('establishment_id', slug).eq('is_available', true).order('order_number')
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
    showToast.error(error.value)
  } finally {
    loading.value = false
  }
}
</script>
