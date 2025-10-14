<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Modern Header -->
    <div class="no-print">
      <ManagerModernHeader
        title="QR Code Menu"
        subtitle="Partagez votre menu digital"
        :icon="QrCode"
        status="En ligne"
        status-type="success"
        :secondary-actions="[
          {
            label: 'Télécharger',
            icon: Download,
            action: downloadQrCode
          },
          {
            label: 'Copier le lien',
            icon: Clipboard,
            action: copyLink
          },
        {
          label: 'Nouveau numéro',
          icon: MessageSquare,
          action: generateTableNumber
        },
        {
          label: 'Test QR',
          icon: QrCode,
          action: testQrCode
        },
        {
          label: 'Imprimer',
          icon: Printer,
          action: printQrCard
        }
        ]"
      />
            </div>

    <main class="max-w-4xl mx-auto px-6 py-8">
      <!-- Utilisation du composant QrCodeCard -->
      <div ref="qrCard">
        <QrCodeCard 
          ref="qrCodeCardRef"
          :restaurant-name="establishment?.name || 'Restaurant'"
          :menu-link="menuLink"
          :restaurant-id="establishment?.id || ''"
        />
        </div>

        <!-- Actions modernes -->
      <div class="mt-8">
        <ManagerModernCard>
          <template #footer>
            <div class="grid grid-cols-3 gap-3 no-print">
              <ManagerModernButton
                variant="secondary"
              @click="copyLink" 
                :icon="Clipboard"
              >
                Copier
              </ManagerModernButton>
              <ManagerModernButton
                variant="primary"
                @click="downloadQrCode"
                :icon="Download"
              >
              Télécharger
              </ManagerModernButton>
              <ManagerModernButton
                variant="secondary"
                @click="printQrCard"
                :icon="Printer"
              >
                Imprimer
              </ManagerModernButton>
          </div>
          </template>
        </ManagerModernCard>
      </div>

      <!-- Stats modernes -->
      <div class="mt-8 space-y-6 no-print">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Statistiques</h2>
        <div class="grid grid-cols-3 gap-6">
          <ManagerModernCard class="p-6">
            <div class="text-center">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.total_scans }}</div>
            <div class="text-sm text-gray-500 mt-1">Total scans</div>
          </div>
          </ManagerModernCard>
          <ManagerModernCard class="p-6">
            <div class="text-center">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.today_scans }}</div>
            <div class="text-sm text-gray-500 mt-1">Aujourd'hui</div>
          </div>
          </ManagerModernCard>
          <ManagerModernCard class="p-6">
            <div class="text-center">
            <div class="text-2xl font-bold text-gray-900">{{ scanStats.conversion_rate }}%</div>
            <div class="text-sm text-gray-500 mt-1">Conversion</div>
          </div>
          </ManagerModernCard>
        </div>

        <!-- Dernier scan -->
        <ManagerModernCard v-if="lastScan" class="p-6">
          <div class="flex items-center gap-4">
            <div class="relative">
              <div class="w-10 h-10 rounded-full bg-orange-50 flex items-center justify-center">
                <Smartphone class="w-5 h-5" style="color: #ff6b35;" />
              </div>
              <div class="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
            <div class="flex-1">
              <div class="text-sm font-medium text-gray-900">Dernier scan</div>
              <div class="text-sm text-gray-500">
                {{ formatTimeAgo(lastScan.created_at) }}
              </div>
            </div>
          </div>
        </ManagerModernCard>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { Share2, Download, Smartphone, QrCode, Clipboard, MessageSquare, UtensilsCrossed, Printer } from 'lucide-vue-next'
import { useEstablishment } from '~/composables/useEstablishment'
import { useCustomToast } from '~/composables/useToast'
import { useSupabaseClient } from '#imports'

// Récupérer le slug de l'URL
const route = useRoute()
const slug = route.params.slug as string

// États
const menuLink = ref('')
const tableNumber = ref('')
const { establishment } = useEstablishment()
const {showToast} = useCustomToast()
const scanStats = ref({
  total_scans: 0,
  today_scans: 0,
  conversion_rate: 0
})
const lastScan = ref<any>(null)
const supabase = useSupabaseClient()

// Générer l'URL du menu
const generateStaticUrl = () => {
  const baseUrl = useRuntimeConfig().public.baseURL || window.location.origin
  return `${baseUrl}/menu/${slug}`
}

// La génération du QR code est maintenant gérée par le composant QrCodeCard

// Copier le lien du menu
const copyLink = async () => {
  try {
    await navigator.clipboard.writeText(menuLink.value)
    showToast.success('Copié', 'Lien copié dans le presse-papier')
  } catch (err) {
    console.error('Copy error:', err)
    showToast.error('Erreur', 'Impossible de copier le lien')
  }
}

// Références
const qrCard = ref<HTMLElement>()
const qrCodeCardRef = ref()

// Télécharger la carte QR complète
const downloadQrCode = async () => {
  try {
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non généré')
      return
    }
    
    // Créer un canvas temporaire pour composer l'image complète
    const tempCanvas = document.createElement('canvas')
    const ctx = tempCanvas.getContext('2d')
    
    // Obtenir les dimensions de la carte QR
    const qrCardElement = qrCard.value
    const width = qrCardElement.offsetWidth
    const height = qrCardElement.offsetHeight
    
    // Configurer la taille du canvas (avec une résolution x2 pour meilleure qualité)
    tempCanvas.width = width * 2
    tempCanvas.height = height * 2
    ctx.scale(2, 2) // Augmenter la résolution
    
    // Remplir le fond
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)
    
    // Créer une image à partir du QR code
    const qrImage = new Image()
    
    // Attendre que l'image QR soit chargée avant de continuer
    await new Promise((resolve, reject) => {
      qrImage.onload = resolve
      qrImage.onerror = reject
      qrImage.src = qrCodeCardRef.value.qrCodeImage
    })
    
    // Recréer la structure de la carte QR avec les textes et l'image QR
    
    // 1. Dessiner l'arrière-plan et la bordure du conteneur
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)
    
    // 2. Dessiner les éléments d'en-tête (nom du restaurant + "Menu")
    ctx.font = '600 28px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#1d1d1f'
    ctx.textAlign = 'center'
    ctx.fillText(establishment.value?.name || 'Restaurant', width/2, 60)
    
    ctx.font = '400 15px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#86868b'
    ctx.fillText('Menu', width/2, 85)
    
    // 3. Dessiner le conteneur du QR code (bordure orange)
    const qrContainerWidth = 300
    const qrContainerHeight = 300
    const qrContainerX = (width - qrContainerWidth) / 2
    const qrContainerY = 120
    
    // Bordure orange
    ctx.strokeStyle = '#ff6b35'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.roundRect(qrContainerX, qrContainerY, qrContainerWidth, qrContainerHeight, 24)
    ctx.stroke()
    
    // 4. Dessiner l'image QR à l'intérieur du conteneur
    const qrSize = 280
    const qrX = (width - qrSize) / 2
    const qrY = qrContainerY + (qrContainerHeight - qrSize) / 2
    ctx.drawImage(qrImage, qrX, qrY, qrSize, qrSize)
    
    // 5. Dessiner les textes en dessous du QR code
    ctx.font = '600 22px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#ff6b35'
    ctx.fillText('Scannez pour voir le menu', width/2, qrContainerY + qrContainerHeight + 40)
    
    ctx.font = '400 15px system-ui, -apple-system, sans-serif'
    ctx.fillStyle = '#86868b'
    ctx.fillText('Pointez votre caméra vers le QR code', width/2, qrContainerY + qrContainerHeight + 70)
    
    // 6. Dessiner les features (Rapide, Sans contact)
    // Indicateurs ✓
    const featureY = qrContainerY + qrContainerHeight + 110
    
    // Premier indicateur
    ctx.beginPath()
    ctx.arc(width/2 - 50, featureY, 10, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    ctx.fillStyle = '#FFFFFF'
    ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    ctx.fillText('✓', width/2 - 50, featureY + 4)
    
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Rapide', width/2 - 20, featureY + 4)
    
    // Deuxième indicateur
    ctx.beginPath()
    ctx.arc(width/2 + 40, featureY, 10, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    ctx.fillStyle = '#FFFFFF'
    ctx.font = '600 10px system-ui, -apple-system, sans-serif'
    ctx.fillText('✓', width/2 + 40, featureY + 4)
    
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Sans contact', width/2 + 90, featureY + 4)
    
    // 7. Dessiner la ligne de séparation (divider)
    const dividerY = featureY + 40
    const gradient = ctx.createLinearGradient(0, dividerY, width, dividerY)
    gradient.addColorStop(0, 'rgba(255,255,255,0)')
    gradient.addColorStop(0.5, '#d2d2d7')
    gradient.addColorStop(1, 'rgba(255,255,255,0)')
    
    ctx.strokeStyle = gradient
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(width * 0.1, dividerY)
    ctx.lineTo(width * 0.9, dividerY)
    ctx.stroke()
    
    // 8. Dessiner le footer
    const footerY = dividerY + 40
    
    // Point orange
    ctx.beginPath()
    ctx.arc(width/2 - 40, footerY, 3, 0, Math.PI * 2)
    ctx.fillStyle = '#ff6b35'
    ctx.fill()
    
    // Texte "Par Kula Qr"
    ctx.fillStyle = '#86868b'
    ctx.font = '400 13px system-ui, -apple-system, sans-serif'
    ctx.fillText('Par Kula Qr', width/2 + 10, footerY + 4)
    
    // Télécharger l'image générée
    const dataURL = tempCanvas.toDataURL('image/png')
    const link = document.createElement('a')
    link.download = `menu-${establishment.value?.name || 'restaurant'}-${new Date().toISOString().split('T')[0]}.png`
    link.href = dataURL
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    showToast.success('Téléchargé', 'Carte QR téléchargée avec succès')
    
  } catch (error) {
    console.error('Erreur de téléchargement:', error)
    // Fallback au téléchargement direct du QR code
    downloadQrCodeFallback()
  }
}
// Méthode de fallback pour télécharger directement l'image QR
const downloadQrCodeFallback = () => {
  try {
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non disponible')
      return
    }
    
    const link = document.createElement('a')
    link.download = `qr-code-${establishment.value?.name || 'restaurant'}-${new Date().toISOString().split('T')[0]}.png`
    link.href = qrCodeCardRef.value.qrCodeImage
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    showToast.success('Téléchargé', 'QR code téléchargé (version simplifiée)')
  } catch (error) {
    console.error('Erreur fallback:', error)
    showToast.error('Erreur', 'Impossible de télécharger le QR code')
  }
}

// Fonction de test pour vérifier le QR code
const testQrCode = () => {
  if (!qrCodeCardRef.value?.qrCodeImage) {
    showToast.error('Test', 'QR code non généré')
    return
  }
  
  console.log('QR Code Image:', qrCodeCardRef.value.qrCodeImage)
  console.log('Menu Link:', menuLink.value)
  showToast.success('Test', 'QR code généré avec succès')
}

// Fonction d'impression directe
const printQrCard = () => {
  try {
    if (!qrCard.value) {
      showToast.error('Erreur', 'Carte QR non trouvée')
      return
    }
    
    // Vérifier que le QR code est généré
    if (!qrCodeCardRef.value?.qrCodeImage) {
      showToast.error('Erreur', 'QR code non généré')
      return
    }
    
    // Créer une nouvelle fenêtre pour l'impression
    const printWindow = window.open('', '_blank')
    if (!printWindow) {
      showToast.error('Erreur', 'Impossible d\'ouvrir la fenêtre d\'impression')
      return
    }
    
    // Générer le contenu HTML pour l'impression
    const printContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Menu QR Code - ${establishment.value?.name || 'Restaurant'}</title>
          <style>
            @page {
              size: A4;
              margin: 20mm;
            }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              margin: 0;
              padding: 0;
              background: white;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
            }
            .qr-card {
              background: white;
              border-radius: 32px;
              padding: 40px;
              max-width: 460px;
              width: 100%;
              text-align: center;
              box-shadow: 0 8px 32px rgba(0,0,0,0.08);
            }
            .header {
              margin-bottom: 40px;
            }
            .restaurant-name {
              font-size: 28px;
              font-weight: 600;
              color: #1d1d1f;
              margin-bottom: 6px;
              letter-spacing: -0.6px;
            }
            .menu-label {
              font-size: 15px;
              color: #86868b;
              font-weight: 400;
              letter-spacing: -0.1px;
            }
            .qr-section {
              margin: 0 auto 36px;
            }
            .qr-container {
              margin: 0 auto;
              width: fit-content;
              padding: 12px;
              border-radius: 24px;
              border: 2px solid #ff6b35;
            }
            .qr-image {
              background: white;
              display: inline-block;
              border-radius: 12px;
              padding: 4px;
              width: 280px;
              height: 280px;
            }
            .qr-image img {
              width: 100%;
              height: 100%;
              object-fit: contain;
            }
            .scan-text {
              color: #ff6b35;
              font-size: 22px;
              font-weight: 600;
              margin-bottom: 8px;
              letter-spacing: -0.4px;
            }
            .scan-subtitle {
              color: #86868b;
              font-size: 15px;
              line-height: 1.5;
              font-weight: 400;
              letter-spacing: -0.1px;
              margin-bottom: 32px;
            }
            .features {
              display: flex;
              justify-content: center;
              gap: 24px;
              margin-bottom: 32px;
            }
            .feature {
              display: flex;
              align-items: center;
              gap: 8px;
              color: #86868b;
              font-size: 13px;
            }
            .feature-icon {
              width: 20px;
              height: 20px;
              background: #ff6b35;
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              color: white;
              font-size: 12px;
            }
            .divider {
              width: 100%;
              height: 1px;
              background: linear-gradient(90deg, transparent, #d2d2d7, transparent);
              margin-bottom: 24px;
            }
            .footer {
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 6px;
              font-size: 13px;
              color: #86868b;
              font-weight: 400;
            }
            .footer-dot {
              width: 6px;
              height: 6px;
              background: #ff6b35;
              border-radius: 50%;
            }
            @media print {
              body {
                min-height: auto;
              }
              .qr-card {
                box-shadow: none;
                border: 1px solid #e5e5e7;
              }
            }
          </style>
        </head>
        <body>
          <div class="qr-card">
            <div class="header">
              <div class="restaurant-name">${establishment.value?.name || 'Restaurant'}</div>
              <div class="menu-label">Menu</div>
            </div>
            
            <div class="qr-section">
              <div class="qr-container">
                <div class="qr-image">
                  <img src="${qrCodeCardRef.value.qrCodeImage}" alt="QR Code Menu" />
                </div>
              </div>
            </div>
            
            <div class="scan-text">Scannez pour voir le menu</div>
            <div class="scan-subtitle">Pointez votre caméra vers le QR code</div>
            
            <div class="features">
              <div class="feature">
                <div class="feature-icon">✓</div>
                <span>Rapide</span>
              </div>
              <div class="feature">
                <div class="feature-icon">✓</div>
                <span>Sans contact</span>
              </div>
            </div>
            
            <div class="divider"></div>
            
            <div class="footer">
              <div class="footer-dot"></div>
              <span>Par Kula Qr</span>
            </div>
          </div>
        </body>
      </html>
    `
    
    // Écrire le contenu et déclencher l'impression
    printWindow.document.write(printContent)
    printWindow.document.close()
    
    // Attendre que les images soient chargées avant d'imprimer
    printWindow.onload = () => {
      setTimeout(() => {
        printWindow.print()
        printWindow.close()
      }, 500)
    }
    
    showToast.success('Impression', 'Fenêtre d\'impression ouverte')
    
  } catch (error) {
    console.error('Erreur d\'impression:', error)
    showToast.error('Erreur', 'Impossible d\'imprimer la carte QR')
  }
}

// Charger les statistiques avec la vue qr_scan_stats
const loadScanStats = async () => {
  try {
    if (!establishment.value?.id) return
    
    const { data, error } = await supabase
      .from('qr_scan_stats')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(1)
    
    if (error) throw error
    
    if (data) {
      scanStats.value = {
        total_scans: (data as any).total_scans || 0,
        today_scans: (data as any).today_scans || 0,
        conversion_rate: (data as any).conversion_rate || 0
      }
    }
  } catch (err) {
    console.error('Error loading scan stats:', err)
  }
}

// Charger le dernier scan
const loadLastScan = async () => {
  try {
    if (!establishment.value?.id) return
    
    const { data, error } = await supabase
      .from('qr_scans')
      .select('*')
      .eq('establishment_id', establishment.value.id)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()
    
    if (error && error.code !== 'PGRST116') throw error
    
    if (data && !error) {
      lastScan.value = data
    }
  } catch (err) {
    console.error('Error loading last scan:', err as Error)
  }
}

// Formater le temps écoulé
const formatTimeAgo = (dateString: string) => {
  const date = new Date(dateString)
  const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000)
  
  let interval = seconds / 31536000
  if (interval > 1) return `il y a ${Math.floor(interval)} an${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 2592000
  if (interval > 1) return `il y a ${Math.floor(interval)} mois`
  
  interval = seconds / 86400
  if (interval > 1) return `il y a ${Math.floor(interval)} jour${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 3600
  if (interval > 1) return `il y a ${Math.floor(interval)} heure${Math.floor(interval) > 1 ? 's' : ''}`
  
  interval = seconds / 60
  if (interval > 1) return `il y a ${Math.floor(interval)} minute${Math.floor(interval) > 1 ? 's' : ''}`
  
  return `il y a ${Math.floor(seconds)} seconde${Math.floor(seconds) > 1 ? 's' : ''}`
}

// Configurer l'écoute des scans en temps réel
let subscription: any
const setupRealtimeScans = () => {
  if (!establishment.value?.id) return
  
  if (subscription) {
    subscription.unsubscribe()
  }
  
  subscription = supabase
    .channel('qr-scans')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'qr_scans',
        filter: `establishment_id=eq.${establishment.value.id}`
      },
      (payload) => {
        console.log('Nouveau scan détecté:', payload)
        
        scanStats.value.total_scans++
        scanStats.value.today_scans++
        lastScan.value = payload.new
        
        showToast.success('Nouveau scan', 'Quelqu\'un a scanné votre QR code')
      }
    )
    .subscribe()
  
  onUnmounted(() => {
    if (subscription) subscription.unsubscribe()
  })
}

// Générer un numéro de table aléatoire
const generateTableNumber = () => {
  tableNumber.value = String(Math.floor(Math.random() * 20) + 1)
}

// Initialisation
onMounted(async () => {
  menuLink.value = generateStaticUrl()
  generateTableNumber()
  await Promise.all([
    loadScanStats(),
    loadLastScan()
  ])
  setupRealtimeScans()
})

watch(() => route.path, async (newPath, oldPath) => {
  if (newPath && newPath !== oldPath) {
    console.log('🔄 Restaurant changed:', newPath)
    await loadScanStats()
    await loadLastScan()
  }
}, { immediate: true })

definePageMeta({
  layout: 'manager'
})
</script>

<style scoped>
/* Apple-style design with orange accents */

button {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

button:hover {
  transform: translateY(-1px);
}

button:active {
  transform: translateY(0) scale(0.98);
}

img {
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
  
  .bg-white {
    background: white !important;
  }
  
  * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
}

button:focus {
  outline: 2px solid #ff6b35;
  outline-offset: 2px;
}

@media (max-width: 640px) {
  .grid-cols-3 {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>