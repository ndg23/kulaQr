import { defineNuxtPlugin, navigateTo } from '#app'
import { useEstablishment } from '~/composables/useEstablishment'
// import { useSupabaseWrapper } from '~/composables/useSupabase'

export default defineNuxtPlugin(async (nuxtApp) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const router = useRouter()
  const { fetchEstablishmentByUserId, clearEstablishment } = useEstablishment()

  // Handle auth state changes
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN') {
      console.log('User signed in')
      
      // Fetch user's establishment
      const establishment = await fetchEstablishmentByUserId()
      
      // Redirect based on whether they have an establishment
      if (establishment) {
        // User has an establishment, redirect to dashboard
        navigateTo(`/manager/${establishment.id}`)
      } else {
        // User doesn't have an establishment, redirect to onboarding
        navigateTo('/onboarding')
      }
    } else if (event === 'SIGNED_OUT') {
      console.log('User signed out')
      clearEstablishment()
      navigateTo('/auth/login')
    }
  })

  // Add navigation guard for protected routes
  router.beforeEach(async (to, from) => {
    // Skip for auth pages
    if (to.path.startsWith('/auth/')) {
      return true
    }
    
    // Check if route requires authentication
    if (to.meta.auth) {
      const currentUser = user.value
      
      if (!currentUser) {
        // User not authenticated, redirect to login
        return navigateTo('/auth/login')
      }
      
      // If accessing manager routes, ensure they have an establishment
      if (to.path.startsWith('/manager/')) {
        const { establishment } = useEstablishment()
        
        if (!establishment.value) {
          // Try to fetch establishment
          const fetchedEstablishment = await fetchEstablishmentByUserId()
          
          if (!fetchedEstablishment) {
            // No establishment found, redirect to onboarding
            return navigateTo('/onboarding')
          }
        }
      }
    }
    
    return true
  })
}) 