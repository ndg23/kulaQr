// Endpoint pour créer un utilisateur de test et vérifier le trigger

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const { email, password, fullName } = body
    
    const supabase = await useServiceSupabase()
    
    // 1. Créer l'utilisateur dans auth.users
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: fullName
      }
    })
    
    if (authError) {
      throw createError({
        statusCode: 400,
        statusMessage: authError.message
      })
    }
    
    // 2. Créer l'utilisateur dans users (sans spécifier subscription_tier pour tester le trigger)
    const { data: userData, error: userError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        full_name: fullName,
        role: 'owner',
        // subscription_tier: volontairement omis pour tester le trigger
        is_active: false
      })
      .select()
      .single()
    
    if (userError) {
      console.error('❌ Erreur création utilisateur:', userError)
      throw createError({
        statusCode: 400,
        statusMessage: userError.message
      })
    }
    
    // 3. Récupérer l'utilisateur créé pour voir le résultat
    const { data: createdUser, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', authData.user.id)
      .single()
    
    return {
      success: true,
      authUser: authData.user,
      dbUser: createdUser,
      message: 'Utilisateur de test créé avec succès'
    }
    
  } catch (error) {
    console.error('❌ Erreur:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Erreur serveur'
    })
  }
})