import { useSupabaseWrapper } from '~/composables/useSupabase'

export default defineNuxtRouteMiddleware((to, from) => {
  // Vérifier si c'est un scan QR (URL contient un paramètre spécial)
  if (to.query.scan === 'true' && to.params.slug) {
    // Tracker le scan de manière asynchrone
    trackQrScan(to.params.slug as string  , {
      userAgent: navigator.userAgent,
      referrer: document.referrer,
      timestamp: new Date().toISOString()
    })
  }
})

// Fonction pour tracker le scan
async function trackQrScan(establishmentSlug: string, scanData: any = {}) {
  try {
    const { client: supabase } = useSupabaseWrapper()
    
    // Récupérer l'ID de l'établissement
    const { data: establishment } = await supabase
      .from('establishments')
      .select('id')
      .eq('slug', establishmentSlug)
      .single()
    
    if (establishment) {
      // Enregistrer le scan
      await supabase
        .from('qr_scans')
        .insert({
          establishment_id: establishment.id,
          user_agent: scanData.userAgent,
          referrer: scanData.referrer
        })
    }
  } catch (error) {
    console.error('Erreur tracking QR scan:', error)
  }
}
