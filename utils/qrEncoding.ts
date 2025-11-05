// Utils pour l'encodage/décodage des numéros de table dans les QR codes

/**
 * Encode un numéro de table pour le cacher dans l'URL
 */
export const encodeTableNumber = (tableNumber: number, establishmentId: string): string => {
  const data = `table_${tableNumber}_${establishmentId}`
  return btoa(data)
}

/**
 * Décode un numéro de table encodé
 */
export const decodeTableNumber = (encodedTable: string, establishmentId: string): number | null => {
  try {
    const decoded = atob(encodedTable)
    const parts = decoded.split('_')

    // Vérifier le format: table_NUMERO_ESTABLISHMENT_ID
    if (parts.length === 3 && parts[0] === 'table') {
      const tableNum = parseInt(parts[1])
      const decodedEstablishmentId = parts[2]

      // Vérifier que l'establishment correspond pour la sécurité
      if (decodedEstablishmentId === establishmentId) {
        return tableNum
      }
    }

    return null
  } catch (error) {
    console.warn('Erreur de décodage du numéro de table:', error)
    return null
  }
}

/**
 * Décode un numéro de table côté serveur (Node.js)
 */
export const decodeTableNumberServer = (encodedTable: string, establishmentId: string): number | null => {
  try {
    const decoded = Buffer.from(encodedTable, 'base64').toString()
    const parts = decoded.split('_')

    // Vérifier le format: table_NUMERO_ESTABLISHMENT_ID
    if (parts.length === 3 && parts[0] === 'table') {
      const tableNum = parseInt(parts[1])
      const decodedEstablishmentId = parts[2]

      // Vérifier que l'establishment correspond pour la sécurité
      if (decodedEstablishmentId === establishmentId) {
        return tableNum
      }
    }

    return null
  } catch (error) {
    console.warn('Erreur de décodage du numéro de table:', error)
    return null
  }
}