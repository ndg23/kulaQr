import { useSupabaseWrapper } from '~/composables/useSupabase'

export default defineNuxtRouteMiddleware(async (to, from) => {
  // Vérifier si la route nécessite une authentification admin
  if (!to.path.startsWith('/admin')) {
    return
  }

  const { client: supabase } = useSupabaseWrapper()

  try {
    // Vérifier si l'utilisateur est connecté
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    if (authError || !user) {
      return navigateTo('/auth/login?redirect=' + encodeURIComponent(to.fullPath))
    }

    // Vérifier si l'utilisateur a le rôle admin
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('role, is_active')
      .eq('id', user.id)
      .single()

    if (userError || !userData) {
      throw createError({
        statusCode: 403,
        message: 'Données utilisateur non trouvées'
      })
    }

    // Vérifier le rôle admin
    if (userData.role !== 'admin') {
      throw createError({
        statusCode: 403,
        message: 'Accès non autorisé - Rôle administrateur requis'
      })
    }

    // Vérifier le statut actif
    if (userData.is_active !== true) {
      throw createError({
        statusCode: 403,
        message: 'Compte désactivé'
      })
    }

  } catch (error: any) {
    console.error('Erreur de vérification admin:', error)
    
    if (error.statusCode === 403) {
      throw createError({
        statusCode: 403,
        message: error.message
      })
    }

    // Rediriger vers la page de connexion en cas d'erreur
    return navigateTo('/auth/login?redirect=' + encodeURIComponent(to.fullPath))
  }
})
