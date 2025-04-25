import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const id = event.context.params?.id
  
  if (!id) {
    throw createError({
      statusCode: 400,
      message: 'ID de QR code manquant'
    })
  }
  
  const supabase = serverSupabaseClient(event)
  
  try {
    // Récupérer les informations du QR code
    const { data: qrData, error: qrError } = await supabase
      .from('qr_codes')
      .select('id, table_number, establishment_id, establishments(id, name, slug)')
      .eq('id', id)
      .single()
    
    if (qrError || !qrData) {
      throw createError({
        statusCode: 404,
        message: 'QR code non trouvé'
      })
    }
    
    // Récupérer les informations de la requête
    const headers = getRequestHeaders(event)
    const userAgent = headers['user-agent'] || 'unknown'
    const referer = headers['referer'] || 'direct'
    
    // Enregistrer le scan dans la base de données
    await supabase.from('qr_scans').insert({
      qr_code_id: id,
      establishment_id: qrData.establishment_id,
      user_agent: userAgent,
      referrer: referer,
      table_number: qrData.table_number
    })
    
    // Retourner les informations nécessaires pour la redirection
    return {
      slug: qrData.establishments.slug,
      table: qrData.table_number,
      establishment: {
        id: qrData.establishment_id,
        name: qrData.establishments.name
      }
    }
    
  } catch (error) {
    console.error('Erreur lors du traitement du QR code:', error)
    throw createError({
      statusCode: 500,
      message: 'Erreur lors du traitement du QR code'
    })
  }
}) 