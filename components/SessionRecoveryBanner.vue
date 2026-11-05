<template>
  <div v-if="showBanner" class="fixed top-0 left-0 right-0 z-50 px-3 pt-3">
    <div class="max-w-2xl mx-auto rounded-full bg-black text-white shadow-xl pl-2 pr-2 py-2 flex items-center gap-3">
      <span class="w-10 h-10 flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><Clock class="w-5 h-5" :stroke-width="2.5" /></span>
      <div class="min-w-0 flex-1 leading-tight">
        <p class="text-sm font-black">Commande en cours</p>
        <p class="text-[11px] font-semibold text-white/70 truncate">
          {{ sessionInfo?.totalItems }} article{{ sessionInfo?.totalItems > 1 ? 's' : '' }}
          {{ sessionInfo?.tableNumber ? `· Table ${sessionInfo.tableNumber}` : '' }}
          · il y a {{ sessionInfo?.timeAgo }}
        </p>
      </div>
      <button type="button" class="h-10 px-4 rounded-full bg-[#FB6A00] text-black text-sm font-black active:scale-[0.96] transition-all" @click="continueOrder">Continuer</button>
      <button type="button" aria-label="Ignorer" class="w-10 h-10 flex-shrink-0 rounded-full bg-white/10 flex items-center justify-center active:scale-[0.92] transition-all" @click="dismissBanner">
        <X class="w-4 h-4" :stroke-width="2.5" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Clock, X } from 'lucide-vue-next'
import { useSessionRecovery } from '~/composables/useSessionRecovery'

const props = defineProps<{
  establishmentId: string
}>()

const emit = defineEmits<{
  continue: [sessionData: any]
  dismiss: []
}>()

const { hasPendingSession, recoverSession, getSessionInfo } = useSessionRecovery()

const showBanner = ref(false)
const sessionInfo = ref<any>(null)

const checkForPendingSession = () => {
  if (hasPendingSession(props.establishmentId)) {
    sessionInfo.value = getSessionInfo(props.establishmentId)
    showBanner.value = true
  }
}

const continueOrder = () => {
  const sessionData = recoverSession(props.establishmentId)
  if (sessionData) {
    emit('continue', sessionData)
    showBanner.value = false
  }
}

const dismissBanner = () => {
  showBanner.value = false
  emit('dismiss')
}

onMounted(() => {
  checkForPendingSession()
})

defineExpose({
  checkForPendingSession
})
</script>
