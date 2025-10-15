<template>
  <div v-if="showBanner" class="fixed top-0 left-0 right-0 z-50 bg-blue-500 text-white shadow-lg">
    <div class="max-w-4xl mx-auto px-4 py-3">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center">
            <Clock class="w-4 h-4" />
          </div>
          <div>
            <p class="font-semibold">Commande en cours</p>
            <p class="text-sm opacity-90">
              {{ sessionInfo?.totalItems }} article{{ sessionInfo?.totalItems > 1 ? 's' : '' }} 
              {{ sessionInfo?.tableNumber ? `• Table ${sessionInfo.tableNumber}` : '' }}
              • Il y a {{ sessionInfo?.timeAgo }}
            </p>
          </div>
        </div>
        
        <div class="flex items-center gap-2">
          <button
            @click="continueOrder"
            class="px-4 py-2 bg-white text-blue-500 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
          >
            Continuer
          </button>
          <button
            @click="dismissBanner"
            class="p-2 hover:bg-white/20 rounded-lg transition-colors"
          >
            <X class="w-4 h-4" />
          </button>
        </div>
      </div>
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
