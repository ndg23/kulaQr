// Script pour vérifier directement si le trigger existe dans la DB

const checkTrigger = async () => {
  try {
    // Test de requête simple pour vérifier les triggers
    const response = await fetch('http://localhost:3006/api/debug/sql-query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: `
          SELECT 
            t.tgname AS trigger_name,
            c.relname AS table_name,
            p.proname AS function_name,
            t.tgenabled
          FROM pg_trigger t
          JOIN pg_class c ON t.tgrelid = c.oid
          JOIN pg_proc p ON t.tgfoid = p.oid
          WHERE t.tgname = 'trigger_assign_demo_subscription'
        `
      })
    })
    
    const result = await response.json()
    console.log('🔍 Résultat vérification trigger:', result)
    
    if (result.data && result.data.length === 0) {
      console.log('❌ PROBLÈME : Le trigger assign_demo_subscription n\'existe PAS !')
      console.log('   C\'est pourquoi l\'utilisateur a eu "free" au lieu de "demo"')
    }
    
  } catch (error) {
    console.log('❌ Erreur vérification:', error.message)
  }
}

console.log('🔍 Vérification du trigger assign_demo_subscription...')
checkTrigger()