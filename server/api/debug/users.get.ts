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

    // Récupérer TOUS les utilisateurs avec leurs abonnements
    const { data: allUsers, error: usersError } = await supabase
      .from('users')
      .select('id, full_name, phone, subscription_tier, subscription_ends_at, is_active, created_at')
      .order('created_at', { ascending: false })
      .limit(50)

    if (usersError) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to fetch users',
        data: usersError
      })
    }

    // Compter par tier (incluant free et autres)
    const tierCounts = {}
    allUsers.forEach(user => {
      const tier = user.subscription_tier || 'null'
      if (!tierCounts[tier]) {
        tierCounts[tier] = { total: 0, active: 0, blocked: 0 }
      }
      tierCounts[tier].total++
      if (user.is_active) {
        tierCounts[tier].active++
      } else {
        tierCounts[tier].blocked++
      }
    })

    // Trouver les utilisateurs récents
    const recentUsers = allUsers.slice(0, 10)

    return {
      success: true,
      allUsers: recentUsers,
      tierCounts,
      totalUsers: allUsers.length,
      message: 'All users retrieved successfully'
    }
  } catch (error: any) {
    console.error('Error in debug/users:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})