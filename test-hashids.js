// Test script pour vérifier l'encodage Hashids
const Hashids = require('hashids/cjs')

const getHashids = (establishmentId) => {
  const salt = `default-salt-${establishmentId}`
  return new Hashids(salt, 8)
}

const encodeTableHashids = (tableNumber, establishmentId) => {
  const hashids = getHashids(establishmentId)
  return hashids.encode(tableNumber)
}

const decodeTableHashids = (encoded, establishmentId) => {
  try {
    const hashids = getHashids(establishmentId)
    const decoded = hashids.decode(encoded)

    if (decoded.length === 0) {
      const direct = parseInt(encoded)
      return !isNaN(direct) ? direct : null
    }

    return decoded[0]

  } catch (error) {
    console.error('Erreur décodage Hashids:', error)
    return null
  }
}

// Test
const establishmentId = 'test-establishment-123'
const tableNumber = 5

console.log('Testing Hashids encoding/decoding...')
console.log('Establishment ID:', establishmentId)
console.log('Table Number:', tableNumber)

try {
  const encoded = encodeTableHashids(tableNumber, establishmentId)
  console.log('Encoded:', encoded)

  const decoded = decodeTableHashids(encoded, establishmentId)
  console.log('Decoded:', decoded)

  if (decoded === tableNumber) {
    console.log('✅ Test passed: Hashids encoding/decoding works correctly')
  } else {
    console.log('❌ Test failed: Decoded value does not match original')
  }

  // Test avec un mauvais establishment ID
  const decodedWrong = decodeTableHashids(encoded, 'wrong-establishment')
  console.log('Decoded with wrong establishment ID:', decodedWrong)
  if (decodedWrong === null || decodedWrong !== tableNumber) {
    console.log('✅ Security test passed: Wrong establishment ID gives different result')
  } else {
    console.log('❌ Security test failed: Wrong establishment ID accepted')
  }

} catch (error) {
  console.error('❌ Test failed with error:', error)
}