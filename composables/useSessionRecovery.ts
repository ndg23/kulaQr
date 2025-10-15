import { ref, computed } from 'vue'

export interface SessionData {
  cart: any[]
  establishmentId: string
  tableNumber?: number
  notes?: string
  timestamp: number
  sessionId: string
}

export const useSessionRecovery = () => {
  const sessionId = ref<string>('')
  const hasRecoveredSession = ref(false)

  // Générer un ID de session unique
  const generateSessionId = () => {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  // Sauvegarder la session actuelle
  const saveSession = (cart: any[], establishmentId: string, tableNumber?: number, notes?: string) => {
    if (!sessionId.value) {
      sessionId.value = generateSessionId()
    }

    const sessionData: SessionData = {
      cart,
      establishmentId,
      tableNumber,
      notes,
      timestamp: Date.now(),
      sessionId: sessionId.value
    }

    // Sauvegarder dans localStorage avec une clé unique
    localStorage.setItem(`session_${establishmentId}`, JSON.stringify(sessionData))
    
    // Sauvegarder aussi dans sessionStorage pour la session courante
    sessionStorage.setItem(`current_session_${establishmentId}`, JSON.stringify(sessionData))
    
    console.log('💾 Session sauvegardée:', sessionData)
  }

  // Récupérer une session sauvegardée
  const recoverSession = (establishmentId: string): SessionData | null => {
    try {
      // D'abord essayer sessionStorage (session courante)
      const currentSession = sessionStorage.getItem(`current_session_${establishmentId}`)
      if (currentSession) {
        const sessionData = JSON.parse(currentSession)
        console.log('🔄 Session courante récupérée:', sessionData)
        return sessionData
      }

      // Sinon essayer localStorage (session persistante)
      const savedSession = localStorage.getItem(`session_${establishmentId}`)
      if (savedSession) {
        const sessionData = JSON.parse(savedSession)
        
        // Vérifier si la session n'est pas trop ancienne (24h max)
        const maxAge = 24 * 60 * 60 * 1000 // 24 heures
        if (Date.now() - sessionData.timestamp < maxAge) {
          sessionId.value = sessionData.sessionId
          hasRecoveredSession.value = true
          console.log('🔄 Session récupérée:', sessionData)
          return sessionData
        } else {
          // Session trop ancienne, la supprimer
          clearSession(establishmentId)
          console.log('🗑️ Session expirée supprimée')
        }
      }
    } catch (error) {
      console.error('Erreur lors de la récupération de session:', error)
    }
    
    return null
  }

  // Vérifier s'il y a une session en attente
  const hasPendingSession = (establishmentId: string): boolean => {
    const currentSession = sessionStorage.getItem(`current_session_${establishmentId}`)
    const savedSession = localStorage.getItem(`session_${establishmentId}`)
    
    if (currentSession) return true
    
    if (savedSession) {
      try {
        const sessionData = JSON.parse(savedSession)
        const maxAge = 24 * 60 * 60 * 1000
        return Date.now() - sessionData.timestamp < maxAge
      } catch {
        return false
      }
    }
    
    return false
  }

  // Nettoyer une session
  const clearSession = (establishmentId: string) => {
    localStorage.removeItem(`session_${establishmentId}`)
    sessionStorage.removeItem(`current_session_${establishmentId}`)
    sessionId.value = ''
    hasRecoveredSession.value = false
    console.log('🗑️ Session nettoyée pour:', establishmentId)
  }

  // Marquer une commande comme terminée (nettoyer la session)
  const markOrderCompleted = (establishmentId: string) => {
    clearSession(establishmentId)
    console.log('✅ Commande terminée, session nettoyée')
  }

  // Obtenir les informations de session pour affichage
  const getSessionInfo = (establishmentId: string) => {
    const session = recoverSession(establishmentId)
    if (!session) return null

    const timeAgo = Date.now() - session.timestamp
    const minutesAgo = Math.floor(timeAgo / (1000 * 60))
    const hoursAgo = Math.floor(timeAgo / (1000 * 60 * 60))

    return {
      itemsCount: session.cart.length,
      totalItems: session.cart.reduce((sum, item) => sum + item.quantity, 0),
      timeAgo: hoursAgo > 0 ? `${hoursAgo}h` : `${minutesAgo}min`,
      tableNumber: session.tableNumber
    }
  }

  return {
    sessionId,
    hasRecoveredSession,
    saveSession,
    recoverSession,
    hasPendingSession,
    clearSession,
    markOrderCompleted,
    getSessionInfo
  }
}
