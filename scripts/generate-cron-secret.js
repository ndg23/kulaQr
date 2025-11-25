#!/usr/bin/env node

/**
 * Script pour générer une clé CRON_SECRET sécurisée
 * Usage: node scripts/generate-cron-secret.js
 */

const crypto = require('crypto')

console.log('\n🔐 Génération de clé CRON_SECRET\n')
console.log('='.repeat(60))

// Générer une clé aléatoire de 32 bytes (64 caractères hex)
const secret = crypto.randomBytes(32).toString('hex')

console.log('\n✅ Clé générée avec succès!\n')
console.log('📋 Copiez cette clé dans votre fichier .env:\n')
console.log(`CRON_SECRET=${secret}\n`)
console.log('='.repeat(60))

console.log('\n📝 Instructions:\n')
console.log('1. Ouvrir votre fichier .env')
console.log('2. Ajouter ou remplacer la ligne CRON_SECRET')
console.log('3. Sur Vercel: Settings → Environment Variables → Add')
console.log('   - Name: CRON_SECRET')
console.log(`   - Value: ${secret}`)
console.log('   - Environments: Production, Preview, Development ✅\n')

console.log('='.repeat(60))
console.log('\n🔒 IMPORTANT: Ne partagez jamais cette clé publiquement!\n')

// Essayer de copier dans le presse-papier (macOS/Linux uniquement)
try {
  const { execSync } = require('child_process')
  
  // Détection de l'OS
  const platform = process.platform
  
  if (platform === 'darwin') {
    // macOS
    execSync(`echo "${secret}" | pbcopy`)
    console.log('✅ Clé copiée dans le presse-papier (macOS)!\n')
  } else if (platform === 'linux') {
    // Linux (avec xclip installé)
    try {
      execSync(`echo "${secret}" | xclip -selection clipboard`)
      console.log('✅ Clé copiée dans le presse-papier (Linux)!\n')
    } catch {
      console.log('ℹ️  Installez xclip pour copier automatiquement: sudo apt install xclip\n')
    }
  } else if (platform === 'win32') {
    // Windows
    execSync(`echo ${secret} | clip`)
    console.log('✅ Clé copiée dans le presse-papier (Windows)!\n')
  }
} catch (err) {
  // Pas grave si ça ne marche pas
  console.log('ℹ️  Copiez manuellement la clé ci-dessus\n')
}
