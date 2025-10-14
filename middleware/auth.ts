import { useSupabaseWrapper } from '~/composables/useSupabase'

export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  // Pas de user → on redirige
  if (!user.value && !to.path.startsWith('/auth')) {
    return navigateTo('/auth/login')
  }

  // User connecté → pas besoin d’aller sur /auth
  if (user.value && to.path.startsWith('/auth')) {
    const { client: supabase } = useSupabaseWrapper()
    supabase.from('establishments')
      .select('id, slug')
      .eq('user_id', user.value.id)
      .single()
      .then(({ data: establishment }) => {
        if (establishment?.slug) {
          navigateTo(`/manager/${establishment.slug}/menu`)
        }
      })
  }
})
