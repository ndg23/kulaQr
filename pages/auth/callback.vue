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

    // Récupérer l'utilisateur
    const { data: user } = await supabase.auth.getUser()
    if (!user) throw new Error('Utilisateur non trouvé')

    // Vérifier si l'utilisateur existe dans la table users
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('id, full_name, email')
      .eq('id', user.user.id)
      .single()

    // Si l'utilisateur n'existe pas dans notre table, le créer
    if (userError && userError.code === 'PGRST116') {
      console.log('👤 Création de l\'utilisateur dans la table users...')
      
      const { error: createUserError } = await supabase
        .from('users')
        .insert({
          id: user.user.id,
          full_name: user.user.user_metadata?.full_name || user.user.email?.split('@')[0],
          email: user.user.email,
          role: 'owner',
          subscription_tier: 'free',
          is_active: true,
          subscription_ends_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
        })

      if (createUserError) {
        console.error('❌ Erreur création utilisateur:', createUserError)
        throw createUserError
      }
      
      console.log('✅ Utilisateur créé dans la table users')
    }

    // Vérifier si l'utilisateur a un établissement
    const { data: establishments, error: establishmentError } = await supabase
      .from('establishments')
      .select('id')
      .eq('user_id', user.user.id)
      .single()

    if (establishmentError && establishmentError.code !== 'PGRST116') {
      throw establishmentError
    }

    // Rediriger vers l'inscription si pas d'établissement
    if (!establishments) {
      console.log('🏪 Pas d\'établissement, redirection vers register avec données utilisateur')
      
      // Préparer les données utilisateur à passer au register
      const userInfo = {
        email: user.user.email,
        fullName: user.user.user_metadata?.full_name || user.user.email?.split('@')[0],
        provider: user.user.app_metadata?.provider || 'google'
      }
      
      // Encoder les données en base64 pour les passer en paramètre
      const encodedData = btoa(JSON.stringify(userInfo))
      
      router.push(`/auth/register?step=2&data=${encodedData}`)
      return
    }

    // Rediriger vers le dashboard
    console.log('✅ Établissement trouvé, redirection vers dashboard')
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