import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const supabase = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    // Vérifier que l'utilisateur est un admin
    // Pour le développement, on désactive temporairement l'auth admin
    // En production, réactiver cette vérification !
    
    // if (!user) {
    //   throw createError({
    //     statusCode: 401,
    //     statusMessage: 'Unauthorized'
    //   })
    // }

    // const { data: userData } = await supabase
    //   .from('users')
    //   .select('role')
    //   .eq('id', user.id)
    //   .single()

    // if (userData?.role !== 'admin') {
    //   throw createError({
    //     statusCode: 403,
    //     statusMessage: 'Forbidden - Admin access required'
    //   })
    // }

    // Récupérer les statistiques
    const { data: stats, error: statsError } = await supabase
      .from('subscription_stats')
      .select('*')

    if (statsError) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch stats',
        data: statsError
      })
    }

    // Récupérer les utilisateurs qui vont expirer
    const { data: expiring, error: expiringError } = await supabase
      .rpc('get_expiring_subscriptions', { days_before: 7 })

    if (expiringError) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch expiring subscriptions',
        data: expiringError
      })
    }

    // Récupérer les logs de blocage récents
    const { data: recentBlocks, error: blocksError } = await supabase
      .rpc('get_subscription_block_logs', { limit_count: 50 })

    if (blocksError) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch block logs',
        data: blocksError
      })
    }

    return {
      success: true,
      stats,
      expiring,
      recentBlocks
    }
  } catch (error: any) {
    console.error('Error in admin/subscriptions/stats:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})
