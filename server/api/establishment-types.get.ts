import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)
  
  const { data, error } = await client
    .from('establishment_types')
    .select('*')
    .eq('is_active', true)
    .order('name')

  if (error) {
    throw createError({
      statusCode: 500,
      message: 'Erreur lors de la récupération des types d\'établissements'
    })
  }

  return data
}) 