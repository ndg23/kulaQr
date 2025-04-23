export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  // Vérifier si l'utilisateur est connecté
  if (!user.value && !to.path.startsWith('/auth')) {
    return navigateTo('/auth/login')
  }

  // Vérifier si la session est valide
  const { data: { session }, error } = await supabase.auth.getSession()
  
  if (error || !session) {
    // Déconnecter l'utilisateur si la session n'est plus valide
    await supabase.auth.signOut()
    return navigateTo('/auth/login')
  }

  // Rediriger vers le dashboard si déjà connecté
  if (user.value && to.path.startsWith('/auth')) {
    const { data: establishment } = await supabase
      .from('establishments')
      .select('id, slug')
      .eq('user_id', user.value.id)
      .single()

    if (establishment?.slug) {
      return navigateTo(`/manager/${establishment.slug}/menu`)
    }
  }
}) 