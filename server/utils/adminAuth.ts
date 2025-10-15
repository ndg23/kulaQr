import { serverSupabaseClient } from '#supabase/server'

export async function verifyAdminAccess(event: any) {
  const supabase = await serverSupabaseClient(event)
  
  // Vérifier l'authentification
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  
  if (authError || !user?.id) {
    throw createError({
      statusCode: 401,
      message: 'Non authentifié'
    })
  }

  // Vérifier le rôle admin
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('role, status')
    .eq('id', user.id)
    .single()

  if (userError || !userData) {
    throw createError({
      statusCode: 403,
      message: 'Données utilisateur non trouvées'
    })
  }

  if (userData.role !== 'admin') {
    throw createError({
      statusCode: 403,
      message: 'Accès non autorisé - Rôle administrateur requis'
    })
  }

  if (userData.status !== 'active') {
    throw createError({
      statusCode: 403,
      message: 'Compte désactivé'
    })
  }

  return { user, userData, supabase }
}
