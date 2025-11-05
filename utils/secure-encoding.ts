import Hashids from 'hashids'


const getHashids = (establishmentId: string) => {
  const salt = `${process.env.QR_SECRET || 'default-salt'}-${establishmentId}`
  return new Hashids(salt, 8) // IDs de 8 caractères minimum
}

/**
 * Encode avec Hashids
 */
export const encodeTableHashids = (
  tableNumber: number,
  establishmentId: string
): string => {
  const hashids = getHashids(establishmentId)
  return hashids.encode(tableNumber)
}

/**
 * Décode avec Hashids
 */
export const decodeTableHashids = (
  encoded: string,
  establishmentId: string
): number | null => {
  try {
    const hashids = getHashids(establishmentId)
    const decoded = hashids.decode(encoded)
    
    if (decoded.length === 0) {
      // Fallback: nombre direct
      const direct = parseInt(encoded)
      return !isNaN(direct) ? direct : null
    }
    
    return decoded[0] as number
    
  } catch (error) {
    console.error('Erreur décodage Hashids:', error)
    return null
  }
}