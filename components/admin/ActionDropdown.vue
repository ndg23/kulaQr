<template>
  <Menu as="div" class="relative inline-block text-left">
    <div>
      <MenuButton class="inline-flex w-full justify-center items-center gap-2 rounded-lg bg-white px-3 py-2 text-sm font-medium text-gray-700 border border-gray-200 hover:bg-gray-50 hover:border-gray-300 transition-all duration-200">
        <component :is="triggerIcon" class="w-4 h-4" />
        {{ triggerText }}
        <ChevronDown class="w-3 h-3 text-gray-400" aria-hidden="true" />
      </MenuButton>
    </div>

    <transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="transform opacity-0 scale-95 translate-y-1"
      enter-to-class="transform opacity-100 scale-100 translate-y-0"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="transform opacity-100 scale-100 translate-y-0"
      leave-to-class="transform opacity-0 scale-95 translate-y-1"
    >
      <MenuItems class="absolute right-0 z-50 mt-1 w-48 origin-top-right rounded-lg bg-white shadow-xl border border-gray-100 focus:outline-none backdrop-blur-sm">
        <!-- Primary Actions -->
        <div v-if="primaryActions.length > 0" class="py-1">
          <MenuItem
            v-for="action in primaryActions"
            :key="action.id"
            v-slot="{ active }"
          >
            <button
              @click="handleAction(action)"
              :class="[
                active ? 'bg-gray-50' : '',
                'group flex items-center px-3 py-2.5 text-sm w-full text-left transition-all duration-150',
                action.disabled ? 'opacity-40 cursor-not-allowed' : 'text-gray-700 hover:text-gray-900'
              ]"
              :disabled="action.disabled"
            >
              <component
                :is="action.icon"
                class="mr-3 h-4 w-4 text-gray-500"
                aria-hidden="true"
              />
              <span class="font-medium">{{ action.label }}</span>
              <span v-if="action.badge" class="ml-auto">
                <span :class="getBadgeClass(action.badge.variant)" class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium">
                  {{ action.badge.text }}
                </span>
              </span>
            </button>
          </MenuItem>
        </div>

        <!-- Secondary Actions -->
        <div v-if="secondaryActions.length > 0" class="py-1 border-t border-gray-100">
          <MenuItem
            v-for="action in secondaryActions"
            :key="action.id"
            v-slot="{ active }"
          >
            <button
              @click="handleAction(action)"
              :class="[
                active ? 'bg-gray-50' : '',
                'group flex items-center px-3 py-2.5 text-sm w-full text-left transition-all duration-150',
                action.disabled ? 'opacity-40 cursor-not-allowed' : 'text-gray-600 hover:text-gray-800'
              ]"
              :disabled="action.disabled"
            >
              <component
                :is="action.icon"
                class="mr-3 h-4 w-4 text-gray-400"
                aria-hidden="true"
              />
              <span>{{ action.label }}</span>
              <span v-if="action.badge" class="ml-auto">
                <span :class="getBadgeClass(action.badge.variant)" class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium">
                  {{ action.badge.text }}
                </span>
              </span>
            </button>
          </MenuItem>
        </div>

        <!-- Danger Actions -->
        <div v-if="dangerActions.length > 0" class="py-1 border-t border-gray-100">
          <MenuItem
            v-for="action in dangerActions"
            :key="action.id"
            v-slot="{ active }"
          >
            <button
              @click="handleAction(action)"
              :class="[
                active ? 'bg-red-50' : '',
                'group flex items-center px-3 py-2.5 text-sm w-full text-left transition-all duration-150',
                action.disabled ? 'opacity-40 cursor-not-allowed' : 'text-red-600 hover:text-red-700'
              ]"
              :disabled="action.disabled"
            >
              <component
                :is="action.icon"
                class="mr-3 h-4 w-4 text-red-500"
                aria-hidden="true"
              />
              <span>{{ action.label }}</span>
              <span v-if="action.badge" class="ml-auto">
                <span :class="getBadgeClass(action.badge.variant)" class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium">
                  {{ action.badge.text }}
                </span>
              </span>
            </button>
          </MenuItem>
        </div>
      </MenuItems>
    </transition>
  </Menu>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue'
import { ChevronDown, MoreHorizontal } from 'lucide-vue-next'

interface ActionBadge {
  text: string
  variant: 'success' | 'warning' | 'error' | 'info' | 'neutral'
}

interface DropdownAction {
  id: string
  label: string
  icon: any
  variant: 'primary' | 'secondary' | 'danger'
  disabled?: boolean
  badge?: ActionBadge
  callback?: () => void
}

const props = defineProps<{
  actions: DropdownAction[]
  triggerText?: string
  triggerIcon?: any
}>()

const emit = defineEmits<{
  action: [action: DropdownAction]
}>()

// Computed actions by variant
const primaryActions = computed(() => 
  props.actions.filter(action => action.variant === 'primary')
)

const secondaryActions = computed(() => 
  props.actions.filter(action => action.variant === 'secondary')
)

const dangerActions = computed(() => 
  props.actions.filter(action => action.variant === 'danger')
)

// Default values
const triggerText = computed(() => props.triggerText || 'Actions')
const triggerIcon = computed(() => props.triggerIcon || MoreHorizontal)

// Handle action click
const handleAction = (action: DropdownAction) => {
  if (action.disabled) return
  
  if (action.callback) {
    action.callback()
  }
  
  emit('action', action)
}

// Style helpers
const getActionColor = (variant: string) => {
  const colorMap: Record<string, string> = {
    primary: 'text-blue-500',
    secondary: 'text-gray-500',
    danger: 'text-red-500'
  }
  return colorMap[variant] || 'text-gray-500'
}

const getBadgeClass = (variant: string) => {
  const badgeMap: Record<string, string> = {
    success: 'bg-green-100 text-green-800',
    warning: 'bg-yellow-100 text-yellow-800',
    error: 'bg-red-100 text-red-800',
    info: 'bg-blue-100 text-blue-800',
    neutral: 'bg-gray-100 text-gray-800'
  }
  return badgeMap[variant] || 'bg-gray-100 text-gray-800'
}
</script>