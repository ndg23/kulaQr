<template>
  <div class="min-h-dvh bg-white">
    <!-- Barre du haut : où je suis, est-ce en direct, qui je suis -->
    <header class="sticky top-0 z-40 bg-white/90 backdrop-blur border-b border-gray-100">
      <div class="max-w-5xl mx-auto px-4 h-14 flex items-center gap-3">
        <NuxtLink to="/staff" aria-label="Commandes" class="w-9 h-9 flex-shrink-0 rounded-full bg-[#FB6A00] text-black flex items-center justify-center text-sm font-black">
          {{ shopInitial }}
        </NuxtLink>
        <div class="min-w-0 flex-1 leading-tight">
          <p class="text-base font-black text-gray-900 truncate">{{ establishment?.name || 'Chargement…' }}</p>
          <p class="text-[11px] font-extrabold flex items-center gap-1.5" :class="connected ? 'text-gray-500' : 'text-[#C54E00]'">
            <span class="w-1.5 h-1.5 rounded-full" :class="connected ? 'bg-[#FB6A00] animate-pulse' : 'bg-[#C54E00]'"></span>
            {{ connected ? 'En direct' : 'Hors ligne · mise à jour toutes les 20 s' }}
          </p>
        </div>
        <button
          type="button"
          class="inline-flex items-center gap-2 h-10 pl-1.5 pr-4 rounded-full bg-gray-100 hover:bg-gray-200 active:scale-[0.96] transition-all"
          aria-label="Mon compte"
          @click="menuOpen = true"
        >
          <span class="w-7 h-7 rounded-full bg-black text-white flex items-center justify-center text-xs font-black">{{ myInitials }}</span>
          <span class="text-sm font-extrabold text-gray-900 max-w-[7rem] truncate">{{ firstName }}</span>
        </button>
      </div>
    </header>

    <main class="max-w-5xl mx-auto px-4 pt-4" :class="showBar ? 'pb-28' : 'pb-6'">
      <slot />
    </main>

    <!-- Navigation du bas : trois endroits, rien d'autre. Masquée pendant la prise de commande (panier en bas). -->
    <nav
      v-if="showBar"
      class="fixed inset-x-0 bottom-[calc(0.75rem+env(safe-area-inset-bottom))] z-40 px-4"
      aria-label="Navigation du personnel"
    >
      <div class="mx-auto max-w-md rounded-full bg-black p-1.5 flex items-center gap-1 shadow-xl shadow-black/20">
        <NuxtLink
          v-for="tab in tabs"
          :key="tab.to"
          :to="tab.to"
          class="relative flex-1 h-14 rounded-full flex flex-col items-center justify-center gap-0.5 text-[11px] font-extrabold transition-all active:scale-[0.96]"
          :class="tab.primary
            ? 'bg-[#FB6A00] text-black'
            : isActive(tab.to) ? 'bg-white text-black' : 'text-white/75 hover:text-white'"
          :aria-current="isActive(tab.to) ? 'page' : undefined"
        >
          <component :is="tab.icon" class="w-5 h-5" :stroke-width="2.5" />
          {{ tab.label }}
          <span
            v-if="tab.badge && tab.badge() > 0"
            class="absolute top-1.5 right-[22%] min-w-[20px] h-5 px-1.5 rounded-full bg-[#FB6A00] text-black text-[11px] font-black flex items-center justify-center"
          >{{ tab.badge() }}</span>
        </NuxtLink>
      </div>
    </nav>

    <!-- Mon compte -->
    <UiBottomSheet v-model="menuOpen" :title="staff?.full_name || staff?.username || 'Mon compte'" :subtitle="roleLabel">
      <div class="space-y-2">
        <div class="flex items-center justify-between gap-3 rounded-full bg-gray-100 pl-5 pr-3 h-14">
          <span class="inline-flex items-center gap-2 font-extrabold text-gray-900"><Volume2 class="w-4 h-4" :stroke-width="2.5" /> Son des nouvelles commandes</span>
          <AppleSwitch :model-value="soundOn" @update:model-value="toggleSound" />
        </div>
        <div class="flex items-center justify-between gap-3 rounded-full bg-gray-100 pl-5 pr-3 h-14">
          <span class="inline-flex items-center gap-2 font-extrabold text-gray-900"><Printer class="w-4 h-4" :stroke-width="2.5" /> Ticket automatique</span>
          <AppleSwitch :model-value="autoPrint" @update:model-value="toggleAutoPrint" />
        </div>
        <button
          type="button"
          class="w-full h-14 rounded-full bg-black text-white font-black uppercase tracking-wide inline-flex items-center justify-center gap-2 active:scale-[0.98] transition-all"
          @click="signOut"
        ><LogOut class="w-5 h-5" :stroke-width="2.5" /> Se déconnecter</button>
      </div>
    </UiBottomSheet>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ClipboardList, Plus, BarChart3, LogOut, Printer, Volume2 } from 'lucide-vue-next'
import UiBottomSheet from '~/components/ui/BottomSheet.vue'
import AppleSwitch from '~/components/AppleSwitch.vue'

const route = useRoute()
const space = useStaffSpace()
const { staff, establishment, orders, connected, soundOn, autoPrint, toggleSound, toggleAutoPrint, logout } = space

const menuOpen = ref(false)

const initialsOf = (name?: string) =>
  (name || '').split(/\s+/).filter(Boolean).map(w => w[0]).join('').toUpperCase().slice(0, 2)

const shopInitial = computed(() => initialsOf(establishment.value?.name) || 'K')
const myName = computed(() => staff.value?.full_name || staff.value?.username || '')
const myInitials = computed(() => initialsOf(myName.value) || 'U')
const firstName = computed(() => (myName.value || 'Moi').split(/\s+/)[0])
const roleLabel = computed(() => ROLE_LABEL[staff.value?.role] || staff.value?.role || '')

// Ce qui attend une action : nouvelles commandes à accepter + commandes à préparer
const todo = computed(() => orders.value.filter(o => ['pending', 'confirmed'].includes(o.status)).length)

const tabs = [
  { to: '/staff', label: 'Commandes', icon: ClipboardList, badge: () => todo.value },
  { to: '/staff/vendre', label: 'Nouvelle', icon: Plus, primary: true },
  { to: '/staff/aujourdhui', label: "Aujourd'hui", icon: BarChart3 }
]
const isActive = (to: string) => route.path === to
// Pendant la prise de commande, on masque la barre : le panier flottant prend sa place
const showBar = computed(() => route.path !== '/staff/vendre')

const signOut = async () => {
  menuOpen.value = false
  await logout()
}

onMounted(() => space.start())
onBeforeUnmount(() => space.stop())
</script>
