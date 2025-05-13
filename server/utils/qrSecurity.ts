import { createHmac } from 'crypto'

const SECRET_KEY = process.env.QR_SECRET_KEY || 'change-this-in-production'

export function verifyQRToken(token: string): { valid: boolean; establishmentId?: string } {
  try {
    // Décompose le jeton
    const [establishmentId, expiresAt, signature] = token.split(':')
    
    // Vérifie si le jeton a expiré
    if (parseInt(expiresAt) < Date.now()) {
      return { valid: false }
    }
    
    // Recalcule la signature pour vérifier qu'elle correspond
    const expectedSignature = createHmac('sha256', SECRET_KEY)
      .update(`${establishmentId}:${expiresAt}`)
      .digest('hex')
    
    // Vérifie que la signature est valide
    if (signature !== expectedSignature) {
      return { valid: false }
    }
    
    return { valid: true, establishmentId }
  } catch (err) {
    return { valid: false }
  }
}