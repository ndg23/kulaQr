<template>
  <!-- Grande carte orange Kula (même construction que celle d'xticket-office) : un chiffre clé, des pastilles, et si on lui donne une série, 7 barres arrondies -->
  <section class="rounded-[2rem] bg-[#FB6A00] text-black p-5 sm:p-6 lg:p-8">
    <div class="flex items-start justify-between gap-4">
      <div class="min-w-0">
        <p v-if="eyebrow" class="text-sm font-semibold text-black/70 capitalize">{{ eyebrow }}</p>
        <p v-if="hint" class="text-sm font-semibold text-black break-words min-w-0">{{ hint }}</p>
      </div>
      <slot name="action">
        <span
          v-if="icon"
          class="hidden sm:flex w-12 h-12 rounded-full bg-black/10 items-center justify-center flex-shrink-0"
          aria-hidden="true"
        >
          <component :is="icon" class="w-6 h-6" :stroke-width="2.5" />
        </span>
      </slot>
    </div>

    <div class="mt-6 grid grid-cols-1 gap-8 items-end" :class="series?.length ? 'lg:grid-cols-5' : ''">
      <div class="min-w-0" :class="series?.length ? 'lg:col-span-2' : ''">
        <p class="text-sm font-semibold text-black/70">{{ label }}</p>
        <div class="mt-1 flex items-baseline gap-2 flex-wrap">
          <span class="text-[clamp(2.4rem,7vw,3.75rem)] font-extrabold tracking-tight leading-none tabular-nums break-all">{{ value }}</span>
          <span v-if="unit" class="text-lg font-bold text-black/60">{{ unit }}</span>
        </div>

        <div v-if="chips?.length" class="mt-4 flex flex-wrap gap-2">
          <component
            :is="chip.to ? NuxtLink : 'span'"
            v-for="chip in chips"
            :key="chip.label"
            :to="chip.to"
            :class="[
              'inline-flex items-center gap-2 h-8 px-4 rounded-full text-xs font-bold transition-colors',
              chip.alert ? 'bg-black text-white' : 'bg-white/85 text-black',
              chip.to ? 'hover:bg-white' : ''
            ]"
          >
            <span v-if="chip.dot" class="w-1.5 h-1.5 rounded-full bg-[#FB6A00]"></span>
            <span :class="chip.alert ? 'text-white/70' : 'text-black/70'">{{ chip.label }}</span>
            <span class="font-extrabold tabular-nums">{{ chip.value }}</span>
          </component>
        </div>
      </div>

      <div v-if="series?.length" class="lg:col-span-3 min-w-0" role="img" :aria-label="`${label} des derniers jours`">
        <div class="flex items-end gap-2 sm:gap-3 h-28">
          <div v-for="day in series" :key="day.key" class="group relative flex-1 h-full flex items-end">
            <div
              :class="['w-full rounded-full transition-all duration-200', day.isToday ? 'bg-black' : 'bg-black/20 group-hover:bg-black/40']"
              :style="{ height: Math.max(day.height, 4) + '%' }"
            ></div>
            <div class="pointer-events-none absolute bottom-full mb-2 left-1/2 -translate-x-1/2 z-10 whitespace-nowrap rounded-full bg-gray-900 px-3 py-1.5 text-xs font-bold text-white opacity-0 group-hover:opacity-100 transition-opacity">
              {{ day.longLabel }} · {{ day.total }}
            </div>
          </div>
        </div>
        <div class="flex gap-2 sm:gap-3 mt-2">
          <span
            v-for="day in series"
            :key="day.key"
            :class="['flex-1 text-center text-xs font-semibold', day.isToday ? 'text-black' : 'text-black/60']"
          >{{ day.label }}</span>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { resolveComponent } from 'vue'

export interface HeroChip { label: string; value: string | number; to?: string; alert?: boolean; dot?: boolean }
export interface HeroDay { key: string; label: string; longLabel: string; total: string | number; height: number; isToday: boolean }

withDefaults(defineProps<{
  label: string
  value: string | number
  unit?: string
  /** Petite ligne au-dessus du chiffre : par défaut la date du jour */
  eyebrow?: string
  hint?: string
  icon?: any
  chips?: HeroChip[]
  series?: HeroDay[]
}>(), {
  unit: '',
  eyebrow: () => new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }),
  hint: '',
  chips: () => [],
  series: () => []
})

const NuxtLink = resolveComponent('NuxtLink')
</script>
