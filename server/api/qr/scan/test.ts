import { serverSupabaseClient } from '#supabase/server'

interface QrScan {
  establishment_id: string
  user_agent: string | null
  ip_address: string | null
  referrer: string | null
}

interface Database {
  public: {
    Tables: {
      qr_scans: {
        Insert: QrScan
      }
      establishments: {
        Row: {
          id: string
          slug: string
          name: string
        }
      }
    }
  }
}

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient<Database>(event)
  const id = event.context.params?.id

  if (!id) {
    throw createError({
      statusCode: 400,
      message: 'ID manquant'
    })
  }

  try {
    // Enregistrer le scan
    const { error: scanError } = await client
      .from('qr_scans')
      .insert({
        establishment_id: id,
        user_agent: event.headers.get('user-agent'),
        ip_address: event.headers.get('x-forwarded-for') || event.headers.get('x-real-ip'),
        referrer: event.headers.get('referer')
      })

    if (scanError) throw scanError

    // Récupérer les infos de l'établissement
    const { data: establishment, error: estError } = await client
      .from('establishments')
      .select('id, slug, name')
      .eq('id', id)
      .single()

    if (estError || !establishment) {
      throw createError({
        statusCode: 404,
        message: 'Établissement non trouvé'
      })
    }

    return { 
      slug: establishment.slug 
    }
  } catch (error) {
    console.error('Erreur scan QR:', error)
    throw createError({
      statusCode: 500,
      message: 'Erreur lors du scan'
    })
  }
}) 