<template>
  <PageForm
    title="QR code du menu"
    :subtitle="establishment?.name"
    back-to="/admin/establishments"
    back-label="Retour aux établissements"
    :loading-data="loadingData"
    :not-found="!loadingData && !establishment"
    not-found-text="Établissement introuvable"
    hide-actions
  >
    <p class="text-center text-sm text-gray-500">Scannez ce QR code pour accéder au menu</p>

    <div class="flex justify-center">
      <div ref="qrBox" class="p-4 bg-white rounded-[2rem] border border-gray-200">
        <QRCodeVue3
          v-if="menuUrl"
          :value="menuUrl"
          :size="240"
          level="H"
          :margin="2"
          class="rounded-2xl overflow-hidden"
          :dotsOptions="{ type: 'square', color: '#000000' }"
          :cornersSquareOptions="{ type: 'square', color: '#000000' }"
          :cornersDotOptions="{ type: 'square', color: '#000000' }"
          :backgroundOptions="{ color: '#FFFFFF' }"
        />
      </div>
    </div>

    <div>
      <label for="menuUrl" class="block text-sm font-extrabold text-gray-900 px-1 mb-2">URL du menu</label>
      <div class="flex gap-2">
        <input
          id="menuUrl"
          type="text"
          readonly
          :value="menuUrl"
          class="flex-1 min-w-0 h-12 px-5 text-sm bg-gray-100 border border-transparent rounded-full"
        />
        <button
          type="button"
          class="h-12 px-5 flex-shrink-0 rounded-full bg-gray-900 text-white font-bold hover:bg-gray-800 active:scale-[0.97] transition-all"
          @click="copyUrl"
        >
          Copier
        </button>
      </div>
    </div>

    <div class="flex flex-col sm:flex-row gap-3 pt-2">
      <button
        type="button"
        class="flex-1 h-12 rounded-full bg-gray-100 text-gray-900 font-bold inline-flex items-center justify-center gap-2 hover:bg-gray-200 active:scale-[0.97] transition-all"
        @click="downloadQr"
      >
        <Download class="w-4 h-4" />
        Télécharger
      </button>
      <button
        type="button"
        class="flex-1 h-12 rounded-full bg-gray-900 text-white font-bold inline-flex items-center justify-center gap-2 hover:bg-gray-800 active:scale-[0.97] transition-all"
        @click="printQr"
      >
        <Printer class="w-4 h-4" />
        Imprimer
      </button>
    </div>
  </PageForm>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Download, Printer } from 'lucide-vue-next'
import QRCodeVue3 from 'qrcode-vue3'
import html2canvas from 'html2canvas'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

definePageMeta({ layout: 'admin' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const { showToast } = useCustomToast()

const establishment = ref<any>(null)
const loadingData = ref(true)
const menuUrl = ref('')
const qrBox = ref<HTMLElement | null>(null)

onMounted(async () => {
  const { data } = await supabase
    .from('establishments')
    .select('id, name, slug')
    .eq('id', route.params.id as string)
    .maybeSingle()
  establishment.value = data
  if (data) menuUrl.value = `${window.location.origin}/menu/${data.slug}`
  loadingData.value = false
})

const copyUrl = async () => {
  try {
    await navigator.clipboard.writeText(menuUrl.value)
    showToast.success('URL copiée dans le presse-papier')
  } catch {
    showToast.error("Impossible de copier l'URL")
  }
}

const renderPng = async (): Promise<string | null> => {
  if (!qrBox.value) return null
  const canvas = await html2canvas(qrBox.value)
  return canvas.toDataURL('image/png')
}

const downloadQr = async () => {
  try {
    const dataUrl = await renderPng()
    if (!dataUrl) return
    const link = document.createElement('a')
    link.href = dataUrl
    link.download = `qrcode-${establishment.value?.slug || 'etablissement'}.png`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    showToast.success('QR code téléchargé')
  } catch {
    showToast.error('Impossible de télécharger le QR code')
  }
}

// Le nom vient de la base : on l'échappe avant de l'écrire dans la fenêtre d'impression
const escapeHtml = (value: string) =>
  value.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c] as string))

const printQr = async () => {
  try {
    const dataUrl = await renderPng()
    if (!dataUrl) return
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      showToast.error('Veuillez autoriser les popups pour imprimer')
      return
    }
    const name = escapeHtml(establishment.value?.name || 'Établissement')
    printWindow.document.write(`<!doctype html>
<html>
  <head>
    <title>QR Code - ${name}</title>
    <style>
      body { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; font-family: system-ui, -apple-system, sans-serif; }
      .container { text-align: center; }
      h1 { font-size: 24px; margin-bottom: 8px; }
      p { font-size: 14px; color: #666; margin-bottom: 24px; }
      img { max-width: 300px; border: 1px solid #eee; border-radius: 24px; padding: 16px; }
      .url { margin-top: 16px; font-size: 12px; color: #666; }
    </style>
  </head>
  <body onload="window.print(); window.close();">
    <div class="container">
      <h1>${name}</h1>
      <p>Scannez ce QR code pour accéder au menu</p>
      <img src="${dataUrl}" alt="QR Code" />
      <div class="url">${escapeHtml(menuUrl.value)}</div>
    </div>
  </body>
</html>`)
    printWindow.document.close()
  } catch {
    showToast.error("Impossible d'imprimer le QR code")
  }
}
</script>
