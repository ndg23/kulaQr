<template>
    <div class="p-6 lg:p-8 w-full max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">Gestion des Abonnements</h1>
            <p class="text-lg text-gray-600">Surveillez et gérez les abonnements des utilisateurs</p>
        </div>

        <!-- Actions rapides -->
        <div class="mb-8 flex gap-4">
            <button @click="manualCheck" :disabled="checking"
                class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2">
                <RefreshCw :class="{ 'animate-spin': checking }" class="w-5 h-5" />
                {{ checking ? 'Vérification en cours...' : 'Vérifier maintenant' }}
            </button>

            <button @click="loadStats"
                class="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors flex items-center gap-2">
                <BarChart3 class="w-5 h-5" />
                Actualiser les stats
            </button>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8" v-if="stats">
            <div v-for="stat in statsDisplay" :key="stat.label" class="bg-white p-6 rounded-2xl border border-gray-100">
                <div class="flex items-center justify-between mb-4">
                    <div class="w-12 h-12 rounded-xl flex items-center justify-center" :class="stat.bgColor">
                        <component :is="stat.icon" :class="stat.iconColor" class="w-6 h-6" />
                    </div>
                    <span v-if="stat.badge" class="px-2 py-1 text-xs font-medium rounded-full" :class="stat.badgeClass">
                        {{ stat.badge }}
                    </span>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-1">{{ stat.value }}</h3>
                <p class="text-sm text-gray-600">{{ stat.label }}</p>
            </div>
        </div>

        <!-- Utilisateurs qui vont expirer -->
        <div v-if="expiring && expiring.length > 0" class="mb-8">
            <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden">
                <div class="p-6 border-b border-gray-100 bg-amber-50">
                    <div class="flex items-center gap-3">
                        <AlertTriangle class="w-6 h-6 text-amber-600" />
                        <div>
                            <h2 class="text-xl font-bold text-gray-900">
                                Abonnements expirant bientôt
                            </h2>
                            <p class="text-sm text-gray-600">
                                {{ expiring.length }} utilisateur(s) à renouveler dans les 7 prochains jours
                            </p>
                        </div>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Utilisateur
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Abonnement
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Expire dans
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Date d'expiration
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Actions
                                </th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <tr v-for="user in expiring" :key="user.user_id" class="hover:bg-gray-50">
                                <td class="px-6 py-4">
                                    <div>
                                        <div class="font-medium text-gray-900">{{ user.user_name }}</div>
                                        <div class="text-sm text-gray-500">{{ user.email }}</div>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-medium"
                                        :class="getSubscriptionBadgeClass(user.subscription_tier)">
                                        {{ formatSubscriptionTier(user.subscription_tier) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-medium" :class="user.days_remaining <= 1
                                            ? 'bg-red-100 text-red-800'
                                            : user.days_remaining <= 3
                                                ? 'bg-orange-100 text-orange-800'
                                                : 'bg-yellow-100 text-yellow-800'
                                        ">
                                        {{ user.days_remaining }} jour(s)
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ formatDate(user.expires_at) }}
                                </td>
                                <td class="px-6 py-4">
                                    <button @click="openReactivateModal(user)"
                                        class="text-blue-600 hover:text-blue-800 font-medium text-sm flex items-center gap-1">
                                        <Zap class="w-4 h-4" />
                                        Prolonger
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Logs de blocage récents -->
        <div v-if="recentBlocks && recentBlocks.length > 0" class="mb-8">
            <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden">
                <div class="p-6 border-b border-gray-100">
                    <h2 class="text-xl font-bold text-gray-900">Historique des blocages</h2>
                    <p class="text-sm text-gray-600 mt-1">
                        Derniers utilisateurs bloqués automatiquement
                    </p>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Utilisateur
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Bloqué le
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Abonnement
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Jours expiré
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Statut
                                </th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                    Actions
                                </th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <tr v-for="block in recentBlocks" :key="block.id" class="hover:bg-gray-50">
                                <td class="px-6 py-4">
                                    <div>
                                        <div class="font-medium text-gray-900">
                                            {{ block.users?.full_name || 'N/A' }}
                                        </div>
                                        <div class="text-sm text-gray-500">{{ block.users?.email || 'N/A' }}</div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ formatDate(block.blocked_at) }}
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-medium"
                                        :class="getSubscriptionBadgeClass(block.subscription_tier)">
                                        {{ formatSubscriptionTier(block.subscription_tier) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-sm text-red-600 font-medium">
                                        {{ block.days_expired }} jour(s)
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span v-if="block.reactivated_at"
                                        class="px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                        Réactivé
                                    </span>
                                    <span v-else
                                        class="px-3 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                        Bloqué
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <button v-if="!block.reactivated_at"
                                        @click="openReactivateModal({ user_id: block.user_id, user_name: block.users?.full_name, email: block.users?.email, subscription_tier: block.subscription_tier })"
                                        class="text-green-600 hover:text-green-800 font-medium text-sm flex items-center gap-1">
                                        <CheckCircle class="w-4 h-4" />
                                        Réactiver
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Modal de réactivation -->
        <UModal v-model="showReactivateModal" size="md" :actionButtonText="'Réactiver'" @action="reactivateUser">
            <div class="p-6">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center">
                        <Zap class="w-6 h-6 text-green-600" />
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Réactiver l'abonnement</h2>
                        <p class="text-sm text-gray-500">{{ selectedUser?.user_name }}</p>
                    </div>
                </div>

                <form @submit.prevent="reactivateUser" class="space-y-4">
                    <div>
                        <FloatLabelSelect id="subscription_tier" v-model="reactivationForm.subscriptionTier"
                            label="Type d'abonnement" required>
                            <option value="demo">Demo (7 jours)</option>
                            <option value="pro">Pro (30 jours)</option>
                            <option value="premium">Premium (90 jours)</option>
                        </FloatLabelSelect>
                    </div>

                    <div>
                        <FloatLabelInput id="duration" v-model.number="reactivationForm.durationDays" type="number"
                            label="Durée (jours)" required min="1" />
                    </div>

                    <div v-if="reactivationError" class="p-4 bg-red-50 border border-red-200 rounded-lg">
                        <p class="text-sm text-red-900">{{ reactivationError }}</p>
                    </div>
                </form>
            </div>
        </UModal>
    </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
    RefreshCw,
    BarChart3,
    AlertTriangle,
    Zap,
    CheckCircle,
    Users,
    UserCheck,
    UserX,
    Clock
} from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'
import UModal from '~/components/UModal.vue'
import FloatLabelSelect from '~/components/FloatLabelSelect.vue'
import FloatLabelInput from '~/components/FloatLabelInput.vue'

const { showToast } = useCustomToast()

const checking = ref(false)
const stats = ref<any>(null)
const expiring = ref<any[]>([])
const recentBlocks = ref<any[]>([])
const showReactivateModal = ref(false)
const selectedUser = ref<any>(null)
const reactivationError = ref('')

const reactivationForm = ref({
    subscriptionTier: 'pro',
    durationDays: 30
})

// Charger les données
const loadStats = async () => {
    try {
        const response = await $fetch('/api/admin-dev/subscriptions/stats')

        if (response.success) {
            stats.value = response.stats
            expiring.value = response.expiring || []
            recentBlocks.value = response.recentBlocks || []
        }
    } catch (error) {
        console.error('Erreur lors du chargement des stats:', error)
        showToast.error('Impossible de charger les statistiques')
    }
}

// Vérification manuelle
const manualCheck = async () => {
    checking.value = true
    try {
        const response = await $fetch('/api/cron/check-subscriptions', {
            method: 'POST',
            headers: {
                Authorization: `Bearer ${useRuntimeConfig().public.cronSecret || 'a7f3c9e2b1d4f8a6c3e7b9d2f4a8c6e3b7d9f2a4c8e6b3d7f9a2c4e8b6d3f7a9'}`,
            }
        });

        if (response.success) {
            showToast.success(
                'Vérification terminée',
                `${response.result.blocked_users} utilisateur(s) bloqué(s)`
            )
            await loadStats()
        }
    } catch (error) {
        console.error('Erreur lors de la vérification:', error)
        showToast.error('Erreur lors de la vérification')
    } finally {
        checking.value = false
    }
}

// Ouvrir le modal de réactivation
const openReactivateModal = (user: any) => {
    selectedUser.value = user

    // Définir les valeurs par défaut selon le tier actuel
    if (user.subscription_tier === 'demo') {
        reactivationForm.value = { subscriptionTier: 'pro', durationDays: 30 }
    } else {
        reactivationForm.value = { subscriptionTier: user.subscription_tier, durationDays: 30 }
    }

    reactivationError.value = ''
    showReactivateModal.value = true
}

// Réactiver un utilisateur
const reactivateUser = async () => {
    try {
        reactivationError.value = ''

        const response = await $fetch('/api/admin-dev/subscriptions/reactivate', {
            method: 'POST',
            body: {
                userId: selectedUser.value.user_id,
                subscriptionTier: reactivationForm.value.subscriptionTier,
                durationDays: reactivationForm.value.durationDays
            }
        })

        if (response.success) {
            showToast.success(
                'Utilisateur réactivé',
                `Abonnement ${reactivationForm.value.subscriptionTier} pour ${reactivationForm.value.durationDays} jours`
            )
            showReactivateModal.value = false
            await loadStats()
        }
    } catch (error: any) {
        console.error('Erreur lors de la réactivation:', error)
        reactivationError.value = error.data?.message || 'Une erreur est survenue'
    }
}

// Stats display
const statsDisplay = computed(() => {
    if (!stats.value || stats.value.length === 0) return []

    const totalUsers = stats.value.reduce((sum: number, s: any) => sum + s.total_users, 0)
    const totalActive = stats.value.reduce((sum: number, s: any) => sum + s.active_users, 0)
    const totalBlocked = stats.value.reduce((sum: number, s: any) => sum + s.blocked_users, 0)
    const totalExpiring = stats.value.reduce((sum: number, s: any) => sum + (s.expiring_soon || 0), 0)

    return [
        {
            label: 'Total utilisateurs',
            value: totalUsers,
            icon: Users,
            bgColor: 'bg-blue-50',
            iconColor: 'text-blue-600'
        },
        {
            label: 'Actifs',
            value: totalActive,
            icon: UserCheck,
            bgColor: 'bg-green-50',
            iconColor: 'text-green-600',
            badge: `${Math.round((totalActive / totalUsers) * 100)}%`,
            badgeClass: 'bg-green-100 text-green-800'
        },
        {
            label: 'Bloqués',
            value: totalBlocked,
            icon: UserX,
            bgColor: 'bg-red-50',
            iconColor: 'text-red-600',
            badge: totalBlocked > 0 ? `${Math.round((totalBlocked / totalUsers) * 100)}%` : null,
            badgeClass: 'bg-red-100 text-red-800'
        },
        {
            label: 'Expirent bientôt',
            value: totalExpiring,
            icon: Clock,
            bgColor: 'bg-amber-50',
            iconColor: 'text-amber-600',
            badge: totalExpiring > 0 ? 'Action requise' : null,
            badgeClass: 'bg-amber-100 text-amber-800'
        }
    ]
})

// Helper functions
const getSubscriptionBadgeClass = (tier: string) => {
    const classes: Record<string, string> = {
        demo: 'bg-gray-100 text-gray-800',
        pro: 'bg-blue-100 text-blue-800',
        premium: 'bg-purple-100 text-purple-800'
    }
    return classes[tier] || 'bg-gray-100 text-gray-800'
}

const formatSubscriptionTier = (tier: string) => {
    const formats: Record<string, string> = {
        demo: 'Demo (7j)',
        pro: 'Pro (30j)',
        premium: 'Premium (90j)'
    }
    return formats[tier] || tier
}

const formatDate = (dateString: string) => {
    if (!dateString) return 'N/A'
    const date = new Date(dateString)
    return date.toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
}

// Charger les données au montage
onMounted(() => {
    loadStats()
})

// Mise à jour automatique toutes les 5 minutes
setInterval(() => {
    loadStats()
}, 5 * 60 * 1000)

definePageMeta({
    layout: 'admin'
})
</script>
