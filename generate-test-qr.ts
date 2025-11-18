// Script pour générer une URL QR de test
import { encodeTableHashids } from './utils/secure-encoding'
const establishmentId = 'test-establishment-123'
const tableNumber = 5



const encoded = encodeTableHashids(tableNumber, establishmentId)
const qrUrl = `http://localhost:3005/qr/${establishmentId}?q=${encoded}`

console.log('Test QR URL generated:')
console.log('Establishment ID:', establishmentId)
console.log('Table Number:', tableNumber)
console.log('Encoded Table:', encoded)
console.log('Full QR URL:', qrUrl)
console.log('')
console.log('To test the QR system:')
console.log('1. Start the Nuxt dev server: npm run dev')
console.log('2. Visit the URL above in your browser')
console.log('3. Check if it redirects to the menu with table number 5')