import { describe, it, expect } from 'vitest'
import { encodeTableHashids, decodeTableHashids } from '~/utils/secure-encoding'

describe('QR Encoding/Decoding', () => {
  it('encode et décode correctement', () => {
    const tableNumber = 5
    const encoded = encodeTableHashids(tableNumber)
    const decoded = decodeTableHashids(encoded)

    expect(decoded).toBe(tableNumber)
  })
  
  it('gère les nombres directs', () => {
    const decoded = decodeTableHashids('10')
    expect(decoded).toBe(10)
  })
  
  it('retourne null pour entrée invalide', () => {
    const decoded = decodeTableHashids('invalid-base64')
    expect(decoded).toBeNull()
  })
  
  it('gère différents numéros de table', () => {
    [1, 10, 42, 100, 999].forEach(num => {
      const encoded = encodeTableHashids(num)
      const decoded = decodeTableHashids(encoded)
      expect(decoded).toBe(num)
    })
  })
})