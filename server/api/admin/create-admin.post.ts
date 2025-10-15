import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { email, password, fullName } = body

  // Validation des données
  if (!email || !password || !fullName) {
    throw createError({
      statusCode: 400,
      message: 'Email, mot de passe et nom complet requis'
    })
  }

  // Validation du mot de passe
  if (password.length < 8) {
    throw createError({
      statusCode: 400,
      message: 'Le mot de passe doit contenir au moins 8 caractères'
    })
  }

  const supabase = await serverSupabaseClient(event)

  try {
    // Vérifier si l'email existe déjà
    const { data: existingUser, error: checkError } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .limit(1)

    if (checkError) throw checkError

    if (existingUser && existingUser.length > 0) {
      throw createError({
        statusCode: 409,
        message: 'Cet email est déjà utilisé'
      })
    }

    // Créer l'utilisateur dans Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: fullName,
        role: 'admin'
      }
    })

    if (authError) throw authError

    // Insérer l'utilisateur dans la table users
    const { data: userData, error: userError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email,
        full_name: fullName,
        role: 'admin',
        status: 'active'
      })
      .select()
      .single()

    if (userError) throw userError

    return {
      success: true,
      message: 'Administrateur créé avec succès',
      user: {
        id: userData.id,
        email: userData.email,
        full_name: userData.full_name,
        role: userData.role
      }
    }

  } catch (error: any) {
    console.error('Erreur lors de la création de l\'admin:', error)
    
    throw createError({
      statusCode: error.statusCode || 500,
      message: error.message || 'Erreur lors de la création de l\'administrateur'
    })
  }
})
