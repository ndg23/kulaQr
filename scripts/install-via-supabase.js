#!/usr/bin/env node

/**
 * Installation du système d'abonnements via l'API Supabase
 * Pas besoin de psql !
 * Usage: node scripts/install-via-supabase.js
 */

const { createClient } = require('@supabase/supabase-js')
const fs = require('fs')
const path = require('path')

// Charger les variables d'environnement
require('dotenv').config()

const supabaseUrl = process.env.SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

console.log('\n============================================')
console.log('🚀 Installation du Système d\'Abonnements')
console.log('============================================\n')

// Vérifier les variables d'environnement
if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Erreur: Variables d\'environnement manquantes\n')
  console.error('Variables requises:')
  console.error('  - SUPABASE_URL:', supabaseUrl ? '✅' : '❌')
  console.error('  - SUPABASE_SERVICE_ROLE_KEY:', supabaseServiceKey ? '✅' : '❌')
  console.error('\n💡 Créez un fichier .env avec ces variables\n')
  process.exit(1)
}

console.log('✅ Variables d\'environnement détectées\n')

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function executeSqlFile(filePath, description) {
  try {
    console.log(`\n📄 ${description}...`)
    
    const sqlContent = fs.readFileSync(filePath, 'utf8')
    
    // Supabase n'accepte qu'une seule requête à la fois via l'API REST
    // On utilise donc une approche différente
    console.log('   ℹ️  Pour ce fichier, veuillez utiliser le SQL Editor de Supabase Dashboard')
    console.log(`   📁 Fichier: ${filePath}`)
    
    // Copier dans le presse-papier si possible (macOS)
    try {
      const { execSync } = require('child_process')
      if (process.platform === 'darwin') {
        execSync(`cat "${filePath}" | pbcopy`)
        console.log('   ✅ Contenu copié dans le presse-papier!')
        console.log('   👉 Collez-le dans Supabase SQL Editor et cliquez "Run"')
      }
    } catch (err) {
      console.log('   👉 Ouvrez le fichier et copiez son contenu dans Supabase SQL Editor')
    }
    
    return true
  } catch (error) {
    console.error(`   ❌ Erreur:`, error.message)
    return false
  }
}

async function updateExistingUsers() {
  try {
    console.log('\n📊 Mise à jour des utilisateurs existants...')
    
    // Récupérer les utilisateurs à mettre à jour
    const { data: usersToUpdate, error: fetchError } = await supabase
      .from('users')
      .select('id, email, subscription_tier')
      .or('subscription_tier.is.null,subscription_tier.eq.free')
    
    if (fetchError) {
      console.error('   ❌ Erreur de récupération:', fetchError.message)
      return false
    }
    
    if (!usersToUpdate || usersToUpdate.length === 0) {
      console.log('   ℹ️  Aucun utilisateur à mettre à jour')
      return true
    }
    
    console.log(`   📝 ${usersToUpdate.length} utilisateur(s) à mettre à jour`)
    
    // Calculer la date d'expiration (7 jours)
    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + 7)
    
    // Mettre à jour en batch
    const { error: updateError } = await supabase
      .from('users')
      .update({
        subscription_tier: 'demo',
        subscription_ends_at: expiresAt.toISOString()
      })
      .or('subscription_tier.is.null,subscription_tier.eq.free')
    
    if (updateError) {
      console.error('   ❌ Erreur de mise à jour:', updateError.message)
      return false
    }
    
    console.log('   ✅ Utilisateurs mis à jour avec succès!')
    console.log(`   📊 ${usersToUpdate.length} utilisateur(s) → subscription_tier: 'demo', expires: 7 jours`)
    
    return true
  } catch (error) {
    console.error('   ❌ Erreur:', error.message)
    return false
  }
}

async function verifyInstallation() {
  try {
    console.log('\n🔍 Vérification de l\'installation...')
    
    // Vérifier que les tables existent
    const tables = ['subscription_blocks_log', 'admin_notifications']
    
    for (const table of tables) {
      const { error } = await supabase
        .from(table)
        .select('*')
        .limit(1)
      
      if (error && error.code === '42P01') {
        console.log(`   ⚠️  Table '${table}' non trouvée - Exécutez le SQL principal`)
        return false
      } else if (!error) {
        console.log(`   ✅ Table '${table}' existe`)
      }
    }
    
    // Tester une fonction RPC
    const { data, error } = await supabase
      .rpc('check_and_block_expired_subscriptions')
    
    if (error) {
      if (error.message.includes('not find function')) {
        console.log('   ⚠️  Fonctions SQL non trouvées - Exécutez le SQL principal')
        return false
      }
      console.log(`   ⚠️  ${error.message}`)
      return false
    }
    
    console.log('   ✅ Fonctions SQL actives!')
    console.log('   📊 Résultat du test:', data)
    
    return true
  } catch (error) {
    console.error('   ❌ Erreur:', error.message)
    return false
  }
}

async function showStatistics() {
  try {
    console.log('\n📊 Statistiques actuelles...')
    
    const { data, error } = await supabase
      .from('subscription_stats')
      .select('*')
    
    if (error) {
      console.log('   ℹ️  Vue subscription_stats non disponible (normal avant installation SQL)')
      return
    }
    
    if (data && data.length > 0) {
      console.log('\n   Statistiques par type d\'abonnement:')
      console.table(data)
    }
  } catch (error) {
    // Pas grave si ça échoue
  }
}

async function main() {
  console.log('📋 ÉTAPES D\'INSTALLATION:\n')
  
  // Étape 1: Instructions pour le SQL principal
  console.log('='.repeat(60))
  console.log('ÉTAPE 1/3: Installation des fonctions SQL')
  console.log('='.repeat(60))
  
  await executeSqlFile(
    path.join(__dirname, '..', 'bdd', 'subscription_auto_block.sql'),
    'Fichier principal des fonctions'
  )
  
  console.log('\n⏸️  PAUSE: Allez exécuter ce SQL dans Supabase Dashboard')
  console.log('   1. Ouvrez: https://supabase.com/dashboard')
  console.log('   2. Sélectionnez votre projet')
  console.log('   3. SQL Editor → New query')
  console.log('   4. Collez le contenu (déjà copié!) et cliquez "Run"\n')
  
  // Demander confirmation avant de continuer
  const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  })
  
  await new Promise((resolve) => {
    readline.question('✅ SQL principal exécuté? (y/n) ', (answer) => {
      readline.close()
      if (!answer.match(/^[Yy]$/)) {
        console.log('\n❌ Installation annulée')
        process.exit(0)
      }
      resolve()
    })
  })
  
  // Étape 2: Mise à jour des utilisateurs
  console.log('\n' + '='.repeat(60))
  console.log('ÉTAPE 2/3: Mise à jour des utilisateurs existants')
  console.log('='.repeat(60))
  
  const updateSuccess = await updateExistingUsers()
  
  if (!updateSuccess) {
    console.log('\n⚠️  La mise à jour a échoué, mais vous pouvez continuer')
  }
  
  // Étape 3: Vérification
  console.log('\n' + '='.repeat(60))
  console.log('ÉTAPE 3/3: Vérification')
  console.log('='.repeat(60))
  
  const verifySuccess = await verifyInstallation()
  
  if (verifySuccess) {
    console.log('\n✅ INSTALLATION VÉRIFIÉE!')
  } else {
    console.log('\n⚠️  Certaines fonctions ne sont pas encore disponibles')
    console.log('   Assurez-vous d\'avoir bien exécuté le SQL principal')
  }
  
  // Afficher les stats
  await showStatistics()
  
  // Prochaines étapes
  console.log('\n' + '='.repeat(60))
  console.log('🎉 INSTALLATION TERMINÉE!')
  console.log('='.repeat(60))
  console.log('\n📝 Prochaines étapes:\n')
  console.log('1. Générer CRON_SECRET:')
  console.log('   node scripts/generate-cron-secret.js\n')
  console.log('2. Tester le système:')
  console.log('   node scripts/test-subscription-system.js\n')
  console.log('3. Lancer le serveur:')
  console.log('   npm run dev\n')
  console.log('4. Accéder au dashboard:')
  console.log('   http://localhost:3000/admin/subscriptions\n')
  console.log('📖 Documentation: docs/QUICK_START.md\n')
  
  process.exit(0)
}

main().catch((error) => {
  console.error('\n💥 Erreur fatale:', error)
  process.exit(1)
})
