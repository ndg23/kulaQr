import { serverSupabaseClient } from '#supabase/server'
import { verifyQRToken } from '~/server/utils/qrSecurity'

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    
    // Vérifier le jeton
    if (!body.token) {
      return { success: false, error: "Missing token" }
    }
    
    // Vérifier le référent
    const referer = event.headers.get('referer') || ''
    const hostname = new URL(useRuntimeConfig().public.baseURL).hostname
    
    // Si le référent n'est pas vide et ne provient pas de notre domaine
    // (permettre null pour les appels mobiles qui n'ont pas toujours de référent)
    if (referer && !referer.includes(hostname)) {
      return { success: false, error: "Invalid referer" }
    }
    
    const { valid, establishmentId } = verifyQRToken(body.token)
    if (!valid) {
      return { success: false, error: "Invalid or expired token" }
    }
    
    // Vérifier que l'ID fourni correspond à celui du jeton
    if (body.establishment_id !== establishmentId) {
      return { success: false, error: "Token mismatch" }
    }
    
    // Limiter le nombre de scans par IP
    const clientIp = event.headers.get('x-forwarded-for') || '127.0.0.1'
    
    const supabase = await serverSupabaseClient(event)
    
    // Vérifier s'il y a eu trop de scans récents de cette IP
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000).toISOString()
    const { count, error: countError } = await supabase
      .from('qr_scans')
      .select('*', { count: 'exact', head: true })
      .eq('ip_address', clientIp)
      .gte('created_at', tenMinutesAgo)
    
    if (countError) {
      return { success: false, error: "Error checking rate limit" }
    }
    
    // Limiter à 5 scans par 10 minutes par IP
    if (count && count > 5) {
      return { success: false, error: "Rate limit exceeded" }
    }
    
    // Insérer le scan dans la base de données
    const { data, error } = await supabase
      .from('qr_scans')
      .insert({
        establishment_id: establishmentId,
        user_agent: event.headers.get('user-agent') || 'unknown',
        created_at: new Date().toISOString(),
        ip_address: clientIp,
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