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

    // Test des fonctions principales
    console.log('🧪 Testing subscription functions...')

    // 1. Test des statistiques
    const { data: stats, error: statsError } = await supabase
      .from('subscription_stats')
      .select('*')

    if (statsError) {
      console.error('Stats error:', statsError)
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch stats',
        data: statsError
      })
    }

    // 2. Test des abonnements expirants
    const { data: expiring, error: expiringError } = await supabase
      .rpc('get_expiring_subscriptions', { days_before: 7 })

    if (expiringError) {
      console.error('Expiring error:', expiringError)
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch expiring subscriptions',
        data: expiringError
      })
    }

    // 3. Test des logs de blocage
    const { data: recentBlocks, error: blocksError } = await supabase
      .rpc('get_subscription_block_logs', { limit_count: 10 })

    if (blocksError) {
      console.error('Blocks error:', blocksError)
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch block logs',
        data: blocksError
      })
    }

    // 4. Test de la fonction principale
    const { data: checkResult, error: checkError } = await supabase
      .rpc('check_and_block_expired_subscriptions')

    if (checkError) {
      console.error('Check error:', checkError)
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to run check function',
        data: checkError
      })
    }

    return {
      success: true,
      message: 'All subscription functions working correctly',
      data: {
        stats: stats,
        expiring: expiring?.length || 0,
        recentBlocks: recentBlocks?.length || 0,
        lastCheck: checkResult
      }
    }
  } catch (error: any) {
    console.error('Error in test/subscriptions:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})