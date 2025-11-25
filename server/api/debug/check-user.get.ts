// Endpoint pour vérifier un utilisateur par email

export default defineEventHandler(async (event) => {
  try {
    const query = getQuery(event)
    const { email } = query
    
    if (!email) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Email requis'
      })
    }
    
    const supabase = await useServiceSupabase()
    
    // Chercher l'utilisateur par email
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single()
    
    if (error && error.code !== 'PGRST116') {
      throw createError({
        statusCode: 400,
        statusMessage: error.message
      })
    }
    
    return {
      success: true,
      user: user || null,
      found: !!user,
      message: user ? 'Utilisateur trouvé' : 'Utilisateur non trouvé'
    }
    
  } catch (error) {
    console.error('❌ Erreur:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Erreur serveur'
    })
  }
})