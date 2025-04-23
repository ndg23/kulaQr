import { serverSupabaseClient } from '#supabase/server'

interface UserData {
  role: string
}

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)
  
  // Vérifier les permissions admin
  const { data: { user } } = await client.auth.getUser()
  
  if (!user?.id) {
    throw createError({
      statusCode: 401,
      message: 'Non authentifié'
    })
  }

  const { data: userData, error: userError } = await client
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single()

  if (userError || !userData) {
    throw createError({
      statusCode: 500,
      message: 'Erreur lors de la récupération des données utilisateur'
    })
  }

  const typedUserData = userData as UserData

  if (typedUserData.role !== 'admin') {
    throw createError({
      statusCode: 403,
      message: 'Accès non autorisé'
    })
  }

  // Récupérer les statistiques
  const { data: stats, error: statsError } = await client
    .from('admin_statistics')
    .select('*')
    .single()

  if (statsError) {
    throw createError({
      statusCode: 500,
      message: 'Erreur lors de la récupération des statistiques'
    })
  }

  // Récupérer les statistiques de croissance
  const { data: growthStats, error: growthError } = await client
    .from('monthly_growth_stats')
    .select('*')
    .order('month', { ascending: false })
    .limit(12)

  if (growthError) {
    throw createError({
      statusCode: 500,
      message: 'Erreur lors de la récupération des statistiques de croissance'
    })
  }

  return {
    current: stats,
    growth: growthStats
  }
}) 