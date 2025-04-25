export default defineNuxtRouteMiddleware((to, from) => {
  // Skip middleware if on server
  if (process.server) return
  
  // Check if user is logged in as waiter
  const session = localStorage.getItem('staff_pin_session')
  if (!session) {
    return navigateTo('/auth/pin')
  }
  
  try {
    const sessionData = JSON.parse(session)
    const loggedInTime = new Date(sessionData.logged_in_at).getTime()
    const now = new Date().getTime()
    
    // Session valid for 12 hours (12 * 60 * 60 * 1000 milliseconds)
    if ((now - loggedInTime) >= 12 * 60 * 60 * 1000) {
      // Session expired
      localStorage.removeItem('staff_pin_session')
      return navigateTo('/auth/pin')
    }
    
    // Check role for specific areas
    if (to.path.startsWith('/kitchen') && sessionData.role !== 'kitchen') {
      return navigateTo('/waiter')
    }
    
    if (to.path.startsWith('/waiter') && sessionData.role === 'kitchen') {
      return navigateTo('/kitchen')
    }
  } catch (e) {
    localStorage.removeItem('staff_pin_session')
    return navigateTo('/auth/pin')
  }
}) 