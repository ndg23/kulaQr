<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <Loader2 class="w-8 h-8 text-gray-400 animate-spin mx-auto mb-4" />
      <p class="text-gray-600">Authentification en cours...</p>
    </div>
  </div>
</template>

<script setup>
import { Loader2 } from 'lucide-vue-next'

const supabase = useSupabaseClient()
const router = useRouter()

// Gérer le callback OAuth
onMounted(async () => {
  try {
    const { error } = await supabase.auth.getSession()
    if (error) throw error

    // Récupérer l'établissement de l'utilisateur
    const { data: user } = await supabase.auth.getUser()
    if (!user) throw new Error('Utilisateur non trouvé')

    const { data: establishments, error: establishmentError } = await supabase
      .from('establishments')
      .select('id')
      .eq('user_id', user.user.id)
      .single()

    if (establishmentError && establishmentError.code !== 'PGRST116') {
      throw establishmentError
    }

    // Rediriger vers la configuration si pas d'établissement
    if (!establishments) {
      router.push('/restaurant-setup')
      return
    }

    // Rediriger vers le dashboard
    router.push('/manager')
  } catch (error) {
    console.error('Erreur de callback:', error)
    router.push('/auth/login?error=callback')
  }
})

// Empêcher le rendu du layout auth
definePageMeta({
  layout: false
})
</script>

<style scoped>
@keyframes spin {
  to { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>