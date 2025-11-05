// composables/useQRTracking.ts
export const useQRTracking = () => {
  const supabase = useSupabaseClient()

  /**
   * Enregistre un scan de QR code
   */
  const trackScan = async (params: {
    establishmentId: string
    tableNumber?: number
  }) => {
    try {
      // Générer un ID de session unique (stocké dans localStorage)
      let sessionId = localStorage.getItem('qr_session_id')
      if (!sessionId) {
        sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        localStorage.setItem('qr_session_id', sessionId)
      }
      

      // Enregistrer le scan
      const { error } = await supabase
        .from('qr_scans')
        .insert({
          establishment_id: params.establishmentId,
          table_number: params.tableNumber || null,
          session_id: sessionId,
          user_agent: navigator.userAgent
        })

      if (error) {
        console.error('Erreur tracking scan:', error)
        return false
      }

      console.log('✅ Scan enregistré')
      return true

    } catch (error) {
      console.error('Erreur tracking:', error)
      return false
    }
  }

  return {
    trackScan
  }
}