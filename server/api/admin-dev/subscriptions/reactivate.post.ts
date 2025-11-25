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

    console.log('Reactivating user:', { userId, subscriptionTier, duration })

    // Réactiver l'utilisateur directement via SQL
    const newExpirationDate = new Date()
    newExpirationDate.setDate(newExpirationDate.getDate() + duration)

    const { data, error } = await supabase
      .from('users')
      .update({
        is_active: true,
        subscription_tier: subscriptionTier,
        subscription_ends_at: newExpirationDate.toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', userId)
      .select('id, full_name, phone, subscription_tier, subscription_ends_at')
      .single()

    if (error) {
      console.error('Reactivation error:', error)
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to update subscription',
        data: error
      })
    }

    console.log('Reactivation success:', data)

    // Créer une notification admin
    await supabase
      .from('admin_notifications')
      .insert({
        type: 'user_reactivated',
        user_id: userId,
        title: 'Utilisateur réactivé',
        message: `L'utilisateur ${data.full_name || 'Utilisateur'} (${data.phone || 'N/A'}) a été réactivé avec un abonnement ${subscriptionTier} de ${duration} jours`,
        severity: 'success'
      })

    return {
      success: true,
      data: {
        success: true,
        user_id: userId,
        new_tier: subscriptionTier,
        duration_days: duration,
        expires_at: newExpirationDate.toISOString(),
        message: 'Utilisateur réactivé avec succès'
      },
      message: 'User reactivated successfully (dev mode)'
    }
  } catch (error: any) {
    console.error('Error in admin-dev/subscriptions/reactivate:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})