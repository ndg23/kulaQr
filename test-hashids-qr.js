// Script de test pour générer un QR code avec encodage sécurisé
const Hashids = require('hashids/cjs')

// Configuration Hashids pour l'encodage des tables
const createTableHashids = (establishmentId) => {
  return new Hashids(`kula-qr-${establishmentId}`, 6, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789')
}

const encodeTableHashids = (tableNumber, establishmentId) => {
  const hashids = createTableHashids(establishmentId)
  return hashids.encode(tableNumber)
}

const decodeTableHashids = (encodedTable, establishmentId) => {
  try {
    const hashids = createTableHashids(establishmentId)
    const decoded = hashids.decode(encodedTable)
    return decoded.length > 0 ? decoded[0] : null
  } catch (error) {
    return null
  }
}

// Test de l'encodage/décodage
const establishmentId = 'test-establishment-123'
const tableNumber = 5

console.log('Testing Hashids encoding/decoding...')
console.log('Establishment ID:', establishmentId)
console.log('Table Number:', tableNumber)

const encoded = encodeTableHashids(tableNumber, establishmentId)
console.log('Encoded:', encoded)

const decoded = decodeTableHashids(encoded, establishmentId)
console.log('Decoded:', decoded)

if (decoded === tableNumber) {
  console.log('✅ Test passed: Encoding/decoding works correctly')
} else {
  console.log('❌ Test failed: Decoded value does not match original')
}

// Test avec un mauvais establishment ID
const decodedWrong = decodeTableHashids(encoded, 'wrong-establishment')
console.log('Decoded with wrong establishment ID:', decodedWrong)
if (decodedWrong === null) {
  console.log('✅ Security test passed: Wrong establishment ID rejected')
} else {
  console.log('❌ Security test failed: Wrong establishment ID accepted')
}

// Générer une URL de test
const testEstablishmentId = '550e8400-e29b-41d4-a716-446655440000' // UUID de test
const testTableNumber = 3
const encodedTable = encodeTableHashids(testTableNumber, testEstablishmentId)
const qrUrl = `http://localhost:3000/qr/${testEstablishmentId}?q=${encodedTable}`

console.log('\n🔗 Test QR URL:')
console.log(qrUrl)
console.log('\n📱 Pour tester, scannez ce QR code ou visitez l\'URL ci-dessus')