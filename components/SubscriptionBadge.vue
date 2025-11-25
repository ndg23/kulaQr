<template>
  <span
    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium"
    :class="badgeClass"
  >
    <component
      v-if="showIcon"
      :is="icon"
      class="w-3.5 h-3.5"
    />
    <span>{{ label }}</span>
    <span v-if="daysRemaining !== null" class="ml-0.5 opacity-75">
      ({{ daysRemaining }}j)
    </span>
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Clock, Zap, Crown, Gift } from 'lucide-vue-next'

interface Props {
  tier: 'demo' | 'pro' | 'premium' | 'free'
  expiresAt?: string | null
  showIcon?: boolean
  showDaysRemaining?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showIcon: true,
  showDaysRemaining: true
})

// Calculer les jours restants
const daysRemaining = computed(() => {
  if (!props.showDaysRemaining || !props.expiresAt) return null
  
  const now = new Date()
  const expires = new Date(props.expiresAt)
  const diffTime = expires.getTime() - now.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  
  return diffDays > 0 ? diffDays : 0
})

// Label du badge
const label = computed(() => {
  const labels: Record<string, string> = {
    'demo': 'Demo',
    'pro': 'Pro',
    'premium': 'Premium',
    'free': 'Gratuit'
  }
  return labels[props.tier] || props.tier
})

// Classe CSS du badge
const badgeClass = computed(() => {
  const isExpiringSoon = daysRemaining.value !== null && daysRemaining.value <= 3 && daysRemaining.value > 0
  const isExpired = daysRemaining.value !== null && daysRemaining.value <= 0
  
  if (isExpired) {
    return 'bg-red-100 text-red-800 ring-1 ring-red-200'
  }
  
  if (isExpiringSoon) {
    return 'bg-orange-100 text-orange-800 ring-1 ring-orange-200 animate-pulse'
  }
  
  const classes: Record<string, string> = {
    'demo': 'bg-gray-100 text-gray-800 ring-1 ring-gray-200',
    'pro': 'bg-blue-100 text-blue-800 ring-1 ring-blue-200',
    'premium': 'bg-purple-100 text-purple-800 ring-1 ring-purple-200',
    'free': 'bg-green-100 text-green-800 ring-1 ring-green-200'
  }
  
  return classes[props.tier] || 'bg-gray-100 text-gray-800'
})

// Icône du badge
const icon = computed(() => {
  const icons: Record<string, any> = {
    'demo': Clock,
    'pro': Zap,
    'premium': Crown,
    'free': Gift
  }
  return icons[props.tier] || Clock
})
</script>
