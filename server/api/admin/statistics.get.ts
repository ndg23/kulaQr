import { verifyAdminAccess } from '~/server/utils/adminAuth'

export default defineEventHandler(async (event) => {
  // Vérifier les permissions admin
  const { supabase } = await verifyAdminAccess(event)

  // Récupérer les statistiques
  const { data: stats, error: statsError } = await supabase
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
  const { data: growthStats, error: growthError } = await supabase
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