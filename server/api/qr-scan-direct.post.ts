import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    
    if (!body.establishment_id) {
      return { success: false, error: "Missing establishment_id" }
    }
    
    const supabase = await serverSupabaseClient(event)
    
    // Vérifier et convertir l'identifiant si nécessaire
    let establishmentId = body.establishment_id
    
    // Si ce n'est pas un UUID, tenter de le traiter comme un slug
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(establishmentId)) {
      const { data: establishment } = await supabase
        .from('establishments')
        .select('id')
        .eq('slug', establishmentId)
        .single()
      
      if (establishment) {
        establishmentId = establishment.id
      } else {
        return { success: false, error: "Establishment not found" }
      }
    }
    
    // Insertion dans la base de données
    const { data, error } = await supabase
      .from('qr_scans')
      .insert({
        establishment_id: establishmentId,
        user_agent: event.headers.get('user-agent') || 'direct',
        created_at: new Date().toISOString(),
        ip_address: event.headers.get('x-forwarded-for') || '127.0.0.1',
        referrer: event.headers.get('referer') || 'direct'
      })
      .select()
    
    if (error) {
      return { success: false, error: "Database insertion failed" }
    }
    
    return { success: true, message: "Scan recorded successfully" }
  } catch (error) {
    return { success: false, error: "Exception during processing" }
  }
}) 