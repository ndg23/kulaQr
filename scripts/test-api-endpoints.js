#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

// Charger les variables d'environnement
dotenv.config()

const CRON_SECRET = process.env.CRON_SECRET
const BASE_URL = 'http://localhost:3006'

console.log('============================================')
console.log('🔧 TEST DES ENDPOINTS API')
console.log('============================================')

// Fonction utilitaire pour les requêtes
async function makeRequest(endpoint, options = {}) {
  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    })
    
    const data = await response.json()
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${data.message || data.statusMessage}`)
    }
    
    return data
  } catch (error) {
    throw new Error(`Request failed: ${error.message}`)
  }
}

async function testEndpoints() {
  // 1. Test endpoint simple
  console.log('\n1️⃣  Test endpoint simple...')
  try {
    const result = await makeRequest('/api/test/simple')
    console.log('   ✅ Endpoint simple OK')
    console.log('   📊 Résultat:', result.message)
  } catch (error) {
    console.log('   ❌ Erreur endpoint simple:', error.message)
  }

  // 2. Test endpoint cron (avec authentification)
  console.log('\n2️⃣  Test endpoint cron (avec auth)...')
  if (!CRON_SECRET) {
    console.log('   ❌ CRON_SECRET non configuré')
    return
  }
  
  try {
    const result = await makeRequest('/api/cron/check-subscriptions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${CRON_SECRET}`
      }
    })
    console.log('   ✅ Endpoint cron OK')
    console.log('   📊 Résultat:', result.result.message)
  } catch (error) {
    console.log('   ❌ Erreur endpoint cron:', error.message)
  }

  // 3. Test endpoint cron (sans auth)
  console.log('\n3️⃣  Test endpoint cron (sans auth - doit échouer)...')
  try {
    const result = await makeRequest('/api/cron/check-subscriptions', {
      method: 'POST'
    })
    console.log('   ❌ ERREUR: L\'endpoint cron ne devrait pas fonctionner sans auth!')
  } catch (error) {
    if (error.message.includes('401') || error.message.includes('Unauthorized')) {
      console.log('   ✅ Sécurité OK - accès refusé sans auth')
    } else {
      console.log('   ❌ Erreur inattendue:', error.message)
    }
  }

  // 4. Test endpoints admin (sans auth - doivent échouer)
  console.log('\n4️⃣  Test endpoints admin (sans auth - doivent échouer)...')
  const adminEndpoints = [
    '/api/admin/subscriptions/stats',
    '/api/admin/subscriptions/reactivate'
  ]
  
  for (const endpoint of adminEndpoints) {
    try {
      const result = await makeRequest(endpoint)
      console.log(`   ❌ ERREUR: ${endpoint} ne devrait pas fonctionner sans auth!`)
    } catch (error) {
      if (error.message.includes('401') || error.message.includes('Unauthorized') || error.message.includes('Auth session missing')) {
        console.log(`   ✅ Sécurité OK - ${endpoint} protégé`)
      } else {
        console.log(`   ❌ Erreur inattendue sur ${endpoint}:`, error.message)
      }
    }
  }

  console.log('\n============================================')
  console.log('✅ TESTS DES ENDPOINTS TERMINÉS')
  console.log('============================================')
}

// Lancer les tests
testEndpoints().catch(console.error)