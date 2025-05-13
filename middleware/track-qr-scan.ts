import { verifyQRToken } from '~/server/utils/qrSecurity'

// Simplifier le middleware
export default defineNuxtRouteMiddleware(async (to) => {
  // Only run on menu pages
  if (!to.path.startsWith('/menu/')) {
    return
  }

  // Check if this is a tracked QR scan
  if (to.query.track === 'true' && to.query.token) {
    const token = to.query.token as string
    const { valid, establishmentId } = verifyQRToken(token)
    
    if (!valid) {
      // Token invalide ou expiré
      return navigateTo({ path: to.path }, { replace: true })
    }
    
    const tableNumber = to.query.table
    
    try {
      // Record the scan via API
      await $fetch('/api/qr-scan', {
        method: 'POST',
        body: {
          establishment_id: establishmentId,
          table_number: tableNumber,
          token: token // Pour une vérification supplémentaire côté serveur
        }
      })
      
      // Redirections
      if (tableNumber) {
        return navigateTo({ path: to.path, query: { table: tableNumber.toString() } }, { replace: true })
      } else {
        return navigateTo({ path: to.path }, { replace: true })
      }
    } catch (err) {
      return navigateTo({ path: to.path }, { replace: true })
    }
  }
}) 