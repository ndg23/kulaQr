#!/usr/bin/env node

// Test de la fonction de réactivation

const testReactivation = async () => {
  console.log('🔄 Test de la fonction de réactivation')
  
  // Trouver un utilisateur bloqué pour le test (nous utiliserons un ID d'un utilisateur actif pour le test)
  const testUserId = '579ffda1-349c-426c-973f-02b15252b557' // Jojo
  
  const testData = {
    userId: testUserId,
    subscriptionTier: 'pro',
    durationDays: 30
  }
  
  try {
    const response = await fetch('http://localhost:3006/api/admin-dev/subscriptions/reactivate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(testData)
    })
    
    const result = await response.json()
    
    if (response.ok) {
      console.log('✅ Réactivation réussie:', result)
    } else {
      console.log('❌ Erreur de réactivation:', result)
    }
  } catch (error) {
    console.log('❌ Erreur réseau:', error.message)
  }
}

// Lancer le test
testReactivation()