import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const supabase = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    // Vérifier que l'utilisateur est un admin
    if (!user) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Unauthorized'
      })
    }

    const { data: userData } = await supabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single()

    if (userData?.role !== 'admin') {
      throw createError({
        statusCode: 403,
        statusMessage: 'Forbidden - Admin access required'
      })
    }

    const body = await readBody(event)
    const { userId, subscriptionTier, durationDays } = body

    if (!userId || !subscriptionTier) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Missing required fields: userId, subscriptionTier'
      })
    }

    // Définir la durée par défaut selon le tier
    let duration = durationDays
    if (!duration) {
      duration = subscriptionTier === 'demo' ? 7 : subscriptionTier === 'pro' ? 30 : 90
    }

    // Appeler la fonction de réactivation
    const { data, error } = await supabase.rpc('reactivate_user_subscription', {
      p_user_id: userId,
      p_new_tier: subscriptionTier,
      p_duration_days: duration
    })

    if (error) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to update subscription',
        data: error
      })
    }

    // Logger l'action dans subscription_blocks_log
    if (data.success) {
      await supabase
        .from('subscription_blocks_log')
        .update({
          reactivated_at: new Date().toISOString(),
          reactivated_by: user.id,
          notes: `Réactivé par admin avec abonnement ${subscriptionTier} pour ${duration} jours`
        })
        .eq('user_id', userId)
        .is('reactivated_at', null)
    }

    return {
      success: true,
      data
    }
  } catch (error: any) {
    console.error('Error in admin/subscriptions/reactivate:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})
