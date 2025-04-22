// import { useSupabaseClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const supabase = useSupabaseClient()
  
  const { data, error } = await supabase
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