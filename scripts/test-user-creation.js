// Test pour créer un nouvel utilisateur et voir le comportement du trigger

const testUserCreation = async () => {
  const testEmail = `test-${Date.now()}@example.com`
  const testName = `Test User ${Date.now()}`
  
  try {
    console.log('🧪 Test création utilisateur avec:', { testEmail, testName })
    
    // 1. Créer l'utilisateur auth
    const { data: authData, error: authError } = await fetch('http://localhost:3006/api/debug/create-test-user', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'test123456',
        fullName: testName
      })
    }).then(r => r.json())
    
    if (authError) {
      console.log('❌ Erreur auth:', authError)
      return
    }
    
    console.log('✅ Utilisateur créé:', authData)
    
    // 2. Vérifier l'utilisateur dans la DB
    const checkResponse = await fetch(`http://localhost:3006/api/debug/check-user?email=${encodeURIComponent(testEmail)}`)
    const checkData = await checkResponse.json()
    
    console.log('🔍 Vérification utilisateur:', checkData)
    
  } catch (error) {
    console.log('❌ Erreur test:', error.message)
  }
}

console.log('🧪 Démarrage test création utilisateur...')
testUserCreation()