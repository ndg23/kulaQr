import Hashids from 'hashids'

// Sel des codes de table. QR_SECRET est lu au build pour le navigateur (define de nuxt.config.ts) et à l'exécution
// sur le serveur : les deux côtés calculent donc le même code. Ce n'est de l'obfuscation, pas un secret fort :
// la vraie protection est la vérification de la table côté base (create_customer_order).
declare const __QR_SALT__: string | undefined

// Ancien sel, celui des QR codes déjà imprimés : on sait toujours les lire
const LEGACY_SECRET = 'default-salt'

const currentSecret = (): string => {
  if (typeof __QR_SALT__ !== 'undefined' && __QR_SALT__) return __QR_SALT__
  if (typeof process !== 'undefined' && process.env?.QR_SECRET) return process.env.QR_SECRET
  return ''
}

const getHashids = (establishmentId: string, secret: string) =>
  new Hashids(`${secret}-${establishmentId}`, 8) // IDs de 8 caractères minimum

/**
 * Encode avec Hashids (sel courant ; ancien sel tant que QR_SECRET n'est pas défini)
 */
export const encodeTableHashids = (
  tableNumber: number,
  establishmentId: string
): string => {
  return getHashids(establishmentId, currentSecret() || LEGACY_SECRET).encode(tableNumber)
}

/**
 * Décode avec Hashids : sel courant d'abord, puis ancien sel pour les QR déjà imprimés
 */
export const decodeTableHashids = (
  encoded: string,
  establishmentId: string
): number | null => {
  const secrets = [currentSecret(), LEGACY_SECRET].filter((s, i, all) => s && all.indexOf(s) === i)
  for (const secret of secrets) {
    try {
      const decoded = getHashids(establishmentId, secret).decode(encoded)
      if (decoded.length > 0) return decoded[0] as number
    } catch (error) {
      console.error('Erreur décodage Hashids:', error)
    }
  }
  return null
}
