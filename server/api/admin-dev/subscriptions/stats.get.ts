import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const supabase = createClient(
      config.public.supabaseUrl,
      config.supabaseServiceKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Récupérer les statistiques
    const { data: stats, error: statsError } = await supabase
      .from('subscription_stats')
      .select('*')
      .limit(100)

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

    // Récupérer les logs de blocage récents (contournement temporaire)
    const { data: recentBlocks, error: blocksError } = await supabase
      .from('subscription_blocks_log')
      .select(`
        id,
        user_id,
        subscription_tier,
        subscription_ended_at,
        blocked_at,
        days_expired,
        created_at
      `)
      .order('blocked_at', { ascending: false })
      .limit(100)

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
      recentBlocks,
      message: 'Admin stats retrieved successfully (dev mode)'
    }
  } catch (error: any) {
    console.error('Error in admin-dev/subscriptions/stats:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})