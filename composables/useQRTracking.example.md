// Exemple d'utilisation du composable useQRTracking

// Dans un composant Vue
<script setup lang="ts">
import { useQRTracking } from '~/composables/useQRTracking'

const { trackScan } = useQRTracking()

// Exemple 1: Tracker quand un utilisateur visite une page produit
const trackProductView = async (productId: string, establishmentId: string) => {
  const success = await trackScan({
    establishmentId,
    tableNumber: undefined // Pas de numéro de table pour les vues de produits
  })

  if (success) {
    console.log('✅ Vue produit trackée')
  }
}

// Exemple 2: Tracker les interactions utilisateur
const trackUserInteraction = async (establishmentId: string, tableNumber?: number) => {
  await trackScan({
    establishmentId,
    tableNumber
  })
}

// Exemple 3: Dans un composant de bouton
const handleButtonClick = async () => {
  // Faire quelque chose...
  await trackScan({
    establishmentId: 'establishment-uuid',
    tableNumber: 5
  })
}
</script>

// Dans une API route (server/api/example.ts)
import { serverSupabaseClient } from '#supabase/server'
import { useQRTracking } from '~/composables/useQRTracking'

export default defineEventHandler(async (event) => {
  const supabase = serverSupabaseClient(event)
  const { trackScan } = useQRTracking()

  // Utiliser dans une API route
  const success = await trackScan({
    establishmentId: 'establishment-uuid',
    tableNumber: 1
  })

  return { success }
})

// Dans un composable personnalisé
export const useCustomTracking = () => {
  const { trackScan } = useQRTracking()

  const trackCustomEvent = async (eventType: string, establishmentId: string) => {
    // Logique personnalisée...
    await trackScan({
      establishmentId,
      tableNumber: undefined
    })
  }

  return {
    trackCustomEvent
  }
}