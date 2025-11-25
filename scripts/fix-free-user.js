// Script pour corriger l'utilisateur "free"

const fixFreeUser = async () => {
  const userId = '8e4a574e-ba35-489d-93ba-67e8991548cf'
  
  const fixData = {
    userId: userId,
    subscriptionTier: 'demo',
    durationDays: 7
  }
  
  try {
    const response = await fetch('http://localhost:3006/api/admin-dev/subscriptions/reactivate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(fixData)
    })
    
    const result = await response.json()
    
    if (response.ok) {
      console.log('✅ Utilisateur "free" corrigé vers demo:', result)
    } else {
      console.log('❌ Erreur correction:', result)
    }
  } catch (error) {
    console.log('❌ Erreur réseau:', error.message)
  }
}

console.log('🔧 Correction de l\'utilisateur "free" vers "demo"...')
fixFreeUser()