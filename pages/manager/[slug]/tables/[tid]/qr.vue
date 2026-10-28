<template>
  <PageForm
    :title="table ? `QR code · Table ${table.table_number}` : 'QR code'"
    :subtitle="establishment?.name"
    :back-to="`/manager/${route.params.slug}/tables`"
    back-label="Retour aux emplacements"
    :loading-data="loadingData"
    :not-found="!loadingData && !table"
    not-found-text="Emplacement introuvable"
    hide-actions
  >
    <div v-if="table && !table.qr_code_url" class="rounded-3xl bg-[#FFF9C2] p-5 text-center space-y-3">
      <p class="text-sm font-semibold text-gray-800">Aucun QR code n'a encore été généré pour cet emplacement.</p>
      <button
        type="button"
        :disabled="generating"
        class="h-11 px-6 rounded-full bg-gray-900 text-white font-bold hover:bg-gray-800 active:scale-[0.97] transition-all disabled:opacity-50"
        @click="generate"
      >
        {{ generating ? 'Génération...' : 'Générer le QR code' }}
      </button>
    </div>

    <template v-else-if="table">
      <div class="flex justify-center">
        <QrCodeCard
          ref="qrCodeCardRef"
          :table-number="table.table_number"
          :restaurant-name="establishment?.name || 'Menu'"
          :menu-link="table.qr_code_url"
          :restaurant-id="String(route.params.slug)"
        />
      </div>

      <div class="flex flex-col sm:flex-row gap-3 pt-2">
        <button
          type="button"
          class="flex-1 h-12 rounded-full bg-gray-100 text-gray-900 font-bold inline-flex items-center justify-center gap-2 hover:bg-gray-200 active:scale-[0.97] transition-all"
          @click="download"
        >
          <Download class="w-4 h-4" />
          Télécharger
        </button>
        <button
          type="button"
          class="flex-1 h-12 rounded-full bg-gray-900 text-white font-bold inline-flex items-center justify-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all"
          @click="print"
        >
          <Printer class="w-4 h-4" />
          Imprimer
        </button>
      </div>
    </template>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Download, Printer } from 'lucide-vue-next'
import QrCodeCard from '~/components/QrCodeCard.vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'
import { encodeTableHashids } from '~/utils/secure-encoding'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const slug = String(route.params.slug)
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const table = ref<any>(null)
const establishment = ref<any>(null)
const loadingData = ref(true)
const generating = ref(false)
const qrCodeCardRef = ref<any>(null)

onMounted(async () => {
  const [tableRes, estRes] = await Promise.all([
    supabase.from('tables').select('*').eq('id', route.params.tid as string).eq('establishment_id', slug).maybeSingle(),
    supabase.from('establishments').select('id, name').eq('id', slug).maybeSingle()
  ])
  table.value = tableRes.data
  establishment.value = estRes.data
  loadingData.value = false
})

const generate = async () => {
  generating.value = true
  try {
    const url = `${window.location.origin}/qr/${slug}?q=${encodeTableHashids(parseInt(table.value.table_number, 10), slug)}`
    const { error } = await supabase
      .from('tables')
      .update({ qr_code_url: url, qr_code_generated: true })
      .eq('id', table.value.id)
    if (error) throw error
    table.value = { ...table.value, qr_code_url: url, qr_code_generated: true }
    showToast.success('QR code généré')
  } catch (err: any) {
    showToast.error(err?.message || 'Impossible de générer le QR code')
  } finally {
    generating.value = false
  }
}

// Carte imprimable 10 × 12 cm à 300 DPI : numéro, nom, QR code, consignes
const buildCard = async (): Promise<string | null> => {
  const qrSrc = qrCodeCardRef.value?.qrCodeImage
  if (!qrSrc) {
    showToast.error('QR code non prêt')
    return null
  }
  const DPI = 300
  const CM_TO_INCH = 0.393701
  const width = Math.round(10 * CM_TO_INCH * DPI)
  const height = Math.round(12 * CM_TO_INCH * DPI)
  const margin = Math.round(0.5 * CM_TO_INCH * DPI)
  const printableWidth = width - margin * 2

  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('Impossible de créer le contexte canvas')

  ctx.fillStyle = '#FFFFFF'
  ctx.fillRect(0, 0, width, height)
  ctx.save()
  ctx.translate(margin, margin)

  const qrImage = new Image()
  await new Promise((resolve, reject) => {
    qrImage.onload = resolve
    qrImage.onerror = reject
    qrImage.src = qrSrc
  })

  ctx.textAlign = 'center'
  ctx.textBaseline = 'top'

  ctx.font = `800 ${Math.round(DPI * 0.5)}px monospace`
  ctx.fillStyle = '#f91919'
  ctx.fillText(`${table.value.table_number}`, printableWidth / 2, DPI * 0.2)

  ctx.font = `600 ${Math.round(DPI * 0.18)}px "Helvetica Neue", Arial, sans-serif`
  ctx.fillStyle = '#1d1d1f'
  ctx.fillText(establishment.value?.name || '--', printableWidth / 2, DPI * 0.7)

  const qrSize = Math.round(5 * CM_TO_INCH * DPI)
  const qrY = DPI * 0.95
  ctx.drawImage(qrImage, (printableWidth - qrSize) / 2, qrY, qrSize, qrSize)

  ctx.font = `600 ${Math.round(DPI * 0.2)}px "Helvetica Neue", Arial, sans-serif`
  ctx.fillStyle = '#f91919'
  ctx.fillText('Scannez pour commander', printableWidth / 2, qrY + qrSize + DPI * 0.35)

  ctx.font = `400 ${Math.round(DPI * 0.13)}px "Helvetica Neue", Arial, sans-serif`
  ctx.fillStyle = '#000000'
  ctx.fillText('Pointez votre caméra vers le QR code', printableWidth / 2, qrY + qrSize + DPI * 0.65)

  ctx.restore()
  return canvas.toDataURL('image/png', 1.0)
}

const download = async () => {
  try {
    const dataUrl = await buildCard()
    if (!dataUrl) return
    const link = document.createElement('a')
    link.download = `qr-${table.value.table_number}-${establishment.value?.name || 'restaurant'}.png`
    link.href = dataUrl
    link.click()
    showToast.success('Carte QR (10×12 cm, 300 DPI) prête pour impression')
  } catch {
    showToast.error('Impossible de générer le QR code')
  }
}

const print = async () => {
  try {
    const dataUrl = await buildCard()
    if (!dataUrl) return
    const win = window.open('', '_blank')
    if (!win) {
      showToast.error('Veuillez autoriser les popups pour imprimer')
      return
    }
    win.document.write(`<!doctype html><html><head><title>QR Table ${table.value.table_number}</title>
<style>@page { size: 10cm 12cm; margin: 0 } body { margin: 0 } img { width: 10cm; height: 12cm; display: block }</style>
</head><body onload="window.print(); window.close();"><img src="${dataUrl}" alt="QR code" /></body></html>`)
    win.document.close()
  } catch {
    showToast.error("Impossible d'imprimer le QR code")
  }
}
</script>
