import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { userId, newEmail } = body

  if (!userId || !newEmail) {
    throw createError({
      statusCode: 400,
      message: 'userId et newEmail sont requis'
    })
  }

  const client = await serverSupabaseClient(event)

  try {
    // Mettre à jour l'email dans auth.users
    const { error: authError } = await client.auth.admin.updateUserById(
      userId,
      { email: newEmail }
    )

    if (authError) {
      throw createError({
        statusCode: 500,
        message: authError.message
      })
    }

    // Mettre à jour l'email dans la table users
    const { error: dbError } = await client
      .from('users')
      .update({ email_verified: false })
      .eq('id', userId)

    if (dbError) {
      throw createError({
        statusCode: 500,
        message: dbError.message
      })
    }

    return { success: true }
  } catch (error) {
    throw createError({
      statusCode: 500,
      message: error.message
    })
  }
})