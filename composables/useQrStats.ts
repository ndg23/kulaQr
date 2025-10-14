export const useQrStats = () => {
  const supabase = useSupabaseClient()
  
  // Charger les statistiques de scans QR pour un établissement
  const getQrScanStats = async (establishmentId: string) => {
    try {
      const { data, error } = await supabase
        .from('qr_scans')
        .select('*')
        .eq('establishment_id', establishmentId)
        .order('created_at', { ascending: false })
      
      if (error) throw error
      
      return {
        total: data.length,
        today: data.filter(scan => {
          const today = new Date().toDateString()
          const scanDate = new Date(scan.created_at).toDateString()
          return today === scanDate
        }).length,
        thisWeek: data.filter(scan => {
          const weekAgo = new Date()
          weekAgo.setDate(weekAgo.getDate() - 7)
          return new Date(scan.created_at) >= weekAgo
        }).length,
        thisMonth: data.filter(scan => {
          const monthAgo = new Date()
          monthAgo.setMonth(monthAgo.getMonth() - 1)
          return new Date(scan.created_at) >= monthAgo
        }).length,
        scans: data
      }
    } catch (error) {
      console.error('Erreur chargement stats QR:', error)
      return {
        total: 0,
        today: 0,
        thisWeek: 0,
        thisMonth: 0,
        scans: []
      }
    }
  }
  
  // Obtenir les scans par jour (pour graphique)
  const getQrScansByDay = async (establishmentId: string, days: number = 30) => {
    try {
      const { data, error } = await supabase
        .from('qr_scans')
        .select('created_at')
        .eq('establishment_id', establishmentId)
        .gte('created_at', new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString())
        .order('created_at', { ascending: true })
      
      if (error) throw error
      
      // Grouper par jour
      const scansByDay = data.reduce((acc, scan) => {
        const date = new Date(scan.created_at).toDateString()
        acc[date] = (acc[date] || 0) + 1
        return acc
      }, {})
      
      return scansByDay
    } catch (error) {
      console.error('Erreur chargement scans par jour:', error)
      return {}
    }
  }
  
  // Obtenir les statistiques en temps réel
  const getRealtimeQrStats = async (establishmentId: string) => {
    try {
      const { data, error } = await supabase
        .from('qr_scans')
        .select('*')
        .eq('establishment_id', establishmentId)
        .order('created_at', { ascending: false })
        .limit(1)
      
      if (error) throw error
      
      return data[0] || null
    } catch (error) {
      console.error('Erreur stats temps réel:', error)
      return null
    }
  }
  
  return {
    getQrScanStats,
    getQrScansByDay,
    getRealtimeQrStats
  }
}
