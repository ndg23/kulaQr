import { createHmac } from 'crypto'
import { serverSupabaseClient } from '#supabase/server'

const SECRET_KEY = process.env.QR_SECRET_KEY || 'change-this-in-production'

export default defineEventHandler(async (event) => {
  // Récupérer l'ID d'établissement depuis l'URL
  const establishmentId = event.context.params?.id
  
  if (!establishmentId) {
    return { success: false, error: "Missing establishment ID" }
  }
  
  try {
    // Vérifier que l'établissement existe
    const supabase = await serverSupabaseClient(event)
    const { data: establishment, error } = await supabase
      .from('establishments')
      .select('id')
      .eq('id', establishmentId)
      .single()
    
    if (error || !establishment) {
      return { success: false, error: "Establishment not found" }
    }
    
    // Extraire le paramètre duration de la query string
    const query = getQuery(event)
    const durationMinutes = query.duration ? parseInt(query.duration as string) : 60
    
    // Générer le token
    const timestamp = Date.now()
    const expiresAt = timestamp + durationMinutes * 60 * 1000
    
    const payload = `${establishmentId}:${expiresAt}`
    const signature = createHmac('sha256', SECRET_KEY)
      .update(payload)
      .digest('hex')
    
    // Retourner le token complet
    return { 
      success: true, 
      token: `${payload}:${signature}`,
      expires_at: new Date(expiresAt).toISOString()
    }
  } catch (error) {
    return { success: false, error: "Failed to generate token" }
  }
}) 