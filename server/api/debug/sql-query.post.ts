// API pour exécuter des requêtes SQL de debug

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const { query } = body
    
    if (!query) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Query SQL requise'
      })
    }
    
    const supabase = await useServiceSupabase()
    
    const { data, error } = await supabase.rpc('exec_sql', { sql_query: query })
    
    if (error) {
      // Essayer avec une requête directe
      const { data: directData, error: directError } = await supabase
        .from('pg_trigger')
        .select(`
          tgname,
          pg_class!inner(relname),
          pg_proc!inner(proname)
        `)
        .eq('tgname', 'trigger_assign_demo_subscription')
      
      if (directError) {
        throw createError({
          statusCode: 400,
          statusMessage: directError.message
        })
      }
      
      return {
        success: true,
        data: directData,
        method: 'direct_query'
      }
    }
    
    return {
      success: true,
      data,
      method: 'rpc_exec_sql'
    }
    
  } catch (error) {
    console.error('❌ Erreur SQL:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Erreur serveur'
    })
  }
})