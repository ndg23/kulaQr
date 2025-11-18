import { serverSupabaseClient } from '#supabase/server'
import { encodeTableHashids,decodeTableHashids } from '~/utils/secure-encoding'

export default defineEventHandler(async (event) => {
  const id = event.context.params?.id
  
  if (!id) {
    throw createError({
      statusCode: 400,
      message: 'ID de QR code manquant'
    })
  }
  
  const supabase = await serverSupabaseClient(event)
  const query = getQuery(event)
  const tableParam = query.q as string | undefined
  
  try {
    // Récupérer les informations de l'établissement
    const { data: establishmentData, error: establishmentError } = await supabase
      .from('establishments')
      .select('*')
      .eq('id', id)
      .single() 
    if (establishmentError || !establishmentData) {
      throw createError({
        statusCode: 404,
        message: 'Établissement non trouvé'
      })
    }
    
    // Décoder le numéro de table si fourni
    let actualTableNumber = null
    if (tableParam) {
      const decoded = decodeTableHashids(tableParam, establishmentData.id)
      if (decoded !== null) {
        actualTableNumber = decoded
      }
    }
    
    // Récupérer les informations de la requête
    const headers = getRequestHeaders(event)
    const userAgent = headers['user-agent'] || 'unknown'
    const referer = headers['referer'] || 'direct'
      const ip = headers['x-forwarded-for'] || headers['x-real-ip'] || ''

    // Enregistrer le scan dans la base de données
    const { error: scanError } = await supabase
      .from('qr_scans')
      .insert({
        establishment_id: establishmentData.id,
        table_number: actualTableNumber,
        user_agent: userAgent,
        referrer: referer,
        ip_address: ip
      } as any)
    
    setCookie(event, 'kula_scan_session', 'ok', {
      maxAge: 60 * 5, // 5 minutes
      httpOnly: false,
      sameSite: 'lax',
    })
    
    if (scanError) {
 throw createError({
      statusCode: 500,
      message: 'Erreur lors du traitement du QR code'
    })  
  
  }
    // console.log('✅ Scan QR enregistré pour établissement', establishmentData.id, 'table', actualTableNumber)
    // Retourner les informations nécessaires pour la redirection
    return {
      slug: establishmentData.slug,
      table: actualTableNumber,
      establishment: {
        id: establishmentData.id,
        name: establishmentData.name
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