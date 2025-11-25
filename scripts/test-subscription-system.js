/**
 * Script de test du système de gestion des abonnements
 * Usage: node scripts/test-subscription-system.js
 */

import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

// Charger les variables d'environnement
dotenv.config()

const supabaseUrl = process.env.SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Variables d environnement manquantes')
  console.error('   SUPABASE_URL:', supabaseUrl ? '✅' : '❌')
  console.error('   SUPABASE_SERVICE_ROLE_KEY:', supabaseServiceKey ? '✅' : '❌')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

console.log('============================================')
console.log('🧪 TEST DU SYSTÈME DE GESTION DES ABONNEMENTS')
console.log('============================================\n')

async function runTests() {
  try {
    // Test 1: Vérifier que les fonctions existent
    console.log('1️⃣  Test des fonctions SQL...')
    
    const { data: checkData, error: checkError } = await supabase
      .rpc('check_and_block_expired_subscriptions')
    
    if (checkError) {
      console.error('   ❌ Erreur:', checkError.message)
      return false
    }
    
    console.log('   ✅ Fonction check_and_block_expired_subscriptions OK')
    console.log('   📊 Résultat:', checkData)
    console.log('')

    // Test 2: Récupérer les abonnements expirants
    console.log('2️⃣  Test de récupération des abonnements expirants...')
    
    const { data: expiringData, error: expiringError } = await supabase
      .rpc('get_expiring_subscriptions', { days_before: 7 })
    
    if (expiringError) {
      console.error('   ❌ Erreur:', expiringError.message)
      return false
    }
    
    console.log('   ✅ Fonction get_expiring_subscriptions OK')
    console.log(`   📊 ${expiringData?.length || 0} abonnement(s) expire(nt) bientôt`)
    
    if (expiringData && expiringData.length > 0) {
      console.log('\n   Détails:')
      expiringData.forEach((user, index) => {
        console.log(`   ${index + 1}. ${user.user_name} (${user.email})`)
        console.log(`      - Abonnement: ${user.subscription_tier}`)
        console.log(`      - Expire dans: ${user.days_remaining} jour(s)`)
      })
    }
    console.log('')

    // Test 3: Statistiques
    console.log('3️⃣  Test des statistiques...')
    
    const { data: statsData, error: statsError } = await supabase
      .from('subscription_stats')
      .select('*')
    
    if (statsError) {
      console.error('   ❌ Erreur:', statsError.message)
      return false
    }
    
    console.log('   ✅ Vue subscription_stats OK')
    console.log('\n   📊 Statistiques par type d\'abonnement:')
    console.table(statsData)
    console.log('')

    // Test 4: Vérifier les notifications
    console.log('4️⃣  Test des notifications admin...')
    
    const { data: notificationsData, error: notificationsError } = await supabase
      .from('admin_notifications')
      .select('*')
      .eq('is_read', false)
      .order('created_at', { ascending: false })
      .limit(5)
    
    if (notificationsError) {
      console.error('   ❌ Erreur:', notificationsError.message)
      return false
    }
    
    console.log('   ✅ Table admin_notifications OK')
    console.log(`   📬 ${notificationsData?.length || 0} notification(s) non lue(s)`)
    
    if (notificationsData && notificationsData.length > 0) {
      console.log('\n   Dernières notifications:')
      notificationsData.forEach((notif, index) => {
        console.log(`   ${index + 1}. [${notif.severity}] ${notif.title}`)
        console.log(`      ${notif.message}`)
      })
    }
    console.log('')

    // Test 5: Logs de blocage
    console.log('5️⃣  Test des logs de blocage...')
    
    const { data: logsData, error: logsError } = await supabase
      .from('subscription_blocks_log')
      .select('*')
      .order('blocked_at', { ascending: false })
      .limit(5)
    
    if (logsError) {
      console.error('   ❌ Erreur:', logsError.message)
      return false
    }
    
    console.log('   ✅ Table subscription_blocks_log OK')
    console.log(`   📝 ${logsData?.length || 0} log(s) de blocage récent(s)`)
    console.log('')

    // Test 6: Compter les utilisateurs demo
    console.log('6️⃣  Test du comptage des utilisateurs demo...')
    
    const { count: demoCount, error: demoError } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })
      .eq('subscription_tier', 'demo')
    
    if (demoError) {
      console.error('   ❌ Erreur:', demoError.message)
      return false
    }
    
    console.log(`   ✅ ${demoCount} utilisateur(s) en demo`)
    console.log('')

    return true
  } catch (error) {
    console.error('💥 Erreur durant les tests:', error)
    return false
  }
}

async function main() {
  const success = await runTests()
  
  console.log('============================================')
  if (success) {
    console.log('✅ TOUS LES TESTS SONT PASSÉS')
  } else {
    console.log('❌ CERTAINS TESTS ONT ÉCHOUÉ')
  }
  console.log('============================================\n')
  
  process.exit(success ? 0 : 1)
}

main()
