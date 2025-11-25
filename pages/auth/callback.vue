<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <Loader2 class="w-16 h-16 text-orange-400 animate-spin mx-auto mb-4" />
      <p class="text-gray-600">{{ loadingMessage }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Loader2 } from 'lucide-vue-next'

const supabase = useSupabaseClient()
const router = useRouter()
const loadingMessage = ref('Authentification en cours...')

// Gérer le callback OAuth
onMounted(async () => {
  try {
    loadingMessage.value = 'Vérification de la session...'
    
    // Attendre un peu pour que Supabase traite le callback
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // Récupérer la session actuelle
    const { data: { session }, error: sessionError } = await supabase.auth.getSession()
    
    if (sessionError) {
      console.error('❌ Erreur session:', sessionError)
      throw sessionError
    }
    
    if (!session) {
      console.error('❌ Aucune session trouvée, tentative de récupération...')
      
      // Essayer de récupérer la session via l'URL
      const { data: { session: urlSession }, error: urlError } = await supabase.auth.getSession()
      
      if (urlError || !urlSession) {
        console.error('❌ Impossible de récupérer la session depuis l\'URL')
        throw new Error('Aucune session trouvée')
      }
      
      console.log('✅ Session récupérée depuis l\'URL')
    }

    // Utiliser la session récupérée
    const currentSession = session || urlSession
    console.log('✅ Session récupérée:', currentSession.user.id)
    loadingMessage.value = 'Vérification du profil...'

    // Récupérer l'utilisateur
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    
    if (userError || !user) {
      console.error('❌ Erreur utilisateur:', userError)
      throw new Error('Utilisateur non trouvé')
    }

    console.log('✅ Utilisateur récupéré:', user.id)

    // Vérifier si l'utilisateur existe dans la table users
    const { data: userData, error: userDbError } = await supabase
      .from('users')
      .select('id, full_name, role, subscription_tier')
      .eq('id', user.id)
      .maybeSingle()

    // Si l'utilisateur n'existe pas dans notre table, le créer
    if (!userData) {
      console.log('👤 Création de l\'utilisateur dans la table users...')
      loadingMessage.value = 'Création de votre profil...'
      
      const fullName = user.user_metadata?.full_name || 
                       user.user_metadata?.name || 
                       user.email?.split('@')[0] || 
                       'Utilisateur'
      
      const { error: createUserError } = await supabase
        .from('users')
        .insert({
          id: user.id,
          full_name: fullName,
          role: 'owner',
          subscription_tier: 'demo', // CORRIGÉ : demo au lieu de free
          is_active: false, // CORRIGÉ : inactif par défaut comme pour l'inscription normale
          subscription_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString() // CORRIGÉ : 7 jours pour demo
        })

      if (createUserError) {
        console.error('❌ Erreur création utilisateur:', createUserError)
        throw createUserError
      }
      
      console.log('✅ Utilisateur créé dans la table users')
    } else {
      console.log('✅ Utilisateur existe déjà dans la base de données')
    }

    loadingMessage.value = 'Vérification de votre établissement...'

    // Vérifier si l'utilisateur a un établissement
    const { data: establishments, error: establishmentError } = await supabase
      .from('establishments')
      .select('id, slug')
      .eq('created_by', user.id)
      .maybeSingle()

    if (establishmentError) {
      console.error('❌ Erreur lors de la vérification de l\'établissement:', establishmentError)
      throw establishmentError
    }

    // Rediriger vers l'inscription si pas d'établissement
    if (!establishments) {
      console.log('🏪 Pas d\'établissement, redirection vers register avec données utilisateur')
      loadingMessage.value = 'Redirection vers la création de votre établissement...'
      
      // Préparer les données utilisateur à passer au register
      const userInfo = {
        email: user.email,
        fullName: user.user_metadata?.full_name || 
                 user.user_metadata?.name || 
                 user.email?.split('@')[0] || 
                 'Utilisateur',
        provider: user.app_metadata?.provider || 'google'
      }
      
      // Encoder les données en base64 pour les passer en paramètre
      const encodedData = btoa(JSON.stringify(userInfo))
      
      // Petit délai pour que l'utilisateur voie le message
      await new Promise(resolve => setTimeout(resolve, 500))
      
      await router.push(`/auth/register?step=2&data=${encodedData}`)
      return
    }

    // Rediriger vers le dashboard
    console.log('✅ Établissement trouvé, redirection vers dashboard')
    loadingMessage.value = 'Redirection vers votre tableau de bord...'
    
    // Petit délai pour que l'utilisateur voie le message
    await new Promise(resolve => setTimeout(resolve, 900))
    if (establishments) {
      await router.push(`/manager/${establishments.id}`)
    } else {
      await router.push('/admin')
    }
  } catch (error) {
    console.error('❌ Erreur de callback:', error)
    console.error('❌ URL actuelle:', window.location.href)
    console.error('❌ Paramètres URL:', window.location.search)
    
    loadingMessage.value = 'Une erreur est survenue...'
    
    // Attendre un peu avant de rediriger
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Rediriger vers login avec plus d'informations d'erreur
    const errorMessage = error.message || 'Erreur inconnue'
    await router.push(`/auth/login?error=callback&message=${encodeURIComponent(errorMessage)}`)
  }
})

// Empêcher le rendu du layout auth
definePageMeta({
  layout: false
})
</script>

<style scoped>
/* Le style animate-spin est déjà fourni par Tailwind CSS, pas besoin de le redéfinir */
</style>