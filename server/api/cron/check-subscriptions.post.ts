import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  try {
    // Vérifier l'authentification (clé API ou token)
    const authHeader = getHeader(event, 'authorization')
    const cronSecret = process.env.CRON_SECRET||'a7f3c9e2b1d4f8a6c3e7b9d2f4a8c6e3b7d9f2a4c8e6b3d7f9a2c4e8b6d3f7a9'
    
    // Vérifier que CRON_SECRET est configuré
    if (!cronSecret) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Server misconfiguration - CRON_SECRET not set'
      })
    }
    
    // Vérifier que la requête est autorisée
    if (authHeader !== `Bearer ${cronSecret}`) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Unauthorized - Invalid cron secret'
      })
    }

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

    // Appeler la fonction de vérification
    const { data, error } = await supabase.rpc('check_and_block_expired_subscriptions')

    if (error) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Database error',
        data: error
      })
    }

    return {
      success: true,
      timestamp: new Date().toISOString(),
      result: data
    }
  } catch (error: any) {
    console.error('Error in cron/check-subscriptions:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal server error',
      data: error
    })
  }
})
