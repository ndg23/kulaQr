<template>
  <div class="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-end sm:items-center justify-center z-50 p-0 sm:p-4" @click.self="$emit('close')">
    <div class="bg-white rounded-t-[2rem] sm:rounded-[2rem] shadow-xl w-full max-w-md max-h-[92dvh] overflow-y-auto p-5 pb-[calc(1.25rem+env(safe-area-inset-bottom))]" role="dialog" aria-modal="true" aria-label="Récapitulatif">
      <div class="flex flex-col items-center text-center pt-2 pb-4">
        <span class="w-16 h-16 rounded-full bg-[#FB6A00] text-black flex items-center justify-center"><Check class="w-8 h-8" :stroke-width="3.5" /></span>
        <h2 class="mt-3 text-2xl font-black text-gray-900">Bon appétit !</h2>
        <p class="text-sm font-semibold text-gray-500">
          Commande n° {{ order.orderNumber }}<span v-if="order.table"> · Table {{ order.table }}</span>
        </p>
      </div>

      <ul class="space-y-2">
        <li v-for="(item, i) in order.items" :key="i" class="flex items-start justify-between gap-3 rounded-3xl bg-gray-100 px-4 py-3">
          <span class="min-w-0">
            <span class="block font-extrabold text-gray-900 break-words">{{ item.quantity }} × {{ item.name }}</span>
            <span v-if="item.notes || item.note" class="block text-xs font-semibold text-[#C54E00] break-words">{{ item.notes || item.note }}</span>
          </span>
          <span class="font-black tabular-nums text-gray-900 flex-shrink-0">{{ money(item.price * item.quantity) }}</span>
        </li>
      </ul>

      <div class="mt-3 flex items-center justify-between rounded-full bg-[#FB6A00] px-5 h-14">
        <span class="text-sm font-extrabold text-black">Total</span>
        <span class="text-xl font-black text-black tabular-nums">{{ money(order.total_amount) }}</span>
      </div>

      <button type="button" class="mt-3 w-full h-14 rounded-full bg-black text-white font-black uppercase active:scale-[0.98] transition-all" @click="$emit('close')">Fermer</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Check } from 'lucide-vue-next'

defineProps<{ order: any }>()
defineEmits<{ (e: 'close'): void }>()

const money = (v: number | string) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(Number(v) || 0)
</script>
