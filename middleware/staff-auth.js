export default defineNuxtRouteMiddleware((to, from) => {
  // Skip middleware on server
  if (process.server) return
  
  // Check if staff is logged in
  const staffSession = localStorage.getItem('staff_session')
  
  if (!staffSession) {
    // Redirect to PIN login page
    return navigateTo('/auth/pin')
  }
  
  // Parse session data
  const session = JSON.parse(staffSession)
  
  // Check if session has required fields
  if (!session.staff_id || !session.role || !session.establishment_id) {
    // Invalid session, clear it and redirect
    localStorage.removeItem('staff_session')
    return navigateTo('/auth/pin')
  }
  
  // Check role-specific access
  if (to.path.startsWith('/staff/kitchen') && session.role !== 'kitchen' && session.role !== 'manager') {
    return navigateTo('/staff/dashboard')
  }
  
  if (to.path.startsWith('/manager') && session.role !== 'manager') {
    return navigateTo('/staff/dashboard')
  }
}) 