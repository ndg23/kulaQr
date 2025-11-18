import type { Establishment } from '~/types'

export const useAutoScroll = () => {
  const isAutoScrolling = ref(false)
  const currentSection = ref(0)
  const sections = ref<string[]>([])
  const autoScrollInterval = ref<NodeJS.Timeout | null>(null)

  const startAutoScroll = (sectionIds: string[], intervalMs: number = 4000) => {
    if (isAutoScrolling.value) return

    sections.value = sectionIds
    isAutoScrolling.value = true
    currentSection.value = 0

    // Scroll to first section immediately
    scrollToSection(sections.value[0])

    // Start auto-scrolling through sections
    autoScrollInterval.value = setInterval(() => {
      currentSection.value = (currentSection.value + 1) % sections.value.length
      scrollToSection(sections.value[currentSection.value])
    }, intervalMs)
  }

  const stopAutoScroll = () => {
    if (autoScrollInterval.value) {
      clearInterval(autoScrollInterval.value)
      autoScrollInterval.value = null
    }
    isAutoScrolling.value = false
  }

  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId)
    if (element) {
      const offsetTop = element.offsetTop - 80 // Account for navbar height
      window.scrollTo({
        top: offsetTop,
        behavior: 'smooth'
      })
    }
  }

  const goToSection = (sectionId: string) => {
    stopAutoScroll() // Stop auto-scroll when user manually navigates
    scrollToSection(sectionId)
  }

  // Pause auto-scroll on user interaction
  const pauseAutoScroll = () => {
    if (isAutoScrolling.value) {
      stopAutoScroll()
    }
  }

  // Resume auto-scroll after user interaction
  const resumeAutoScroll = (delayMs: number = 10000) => {
    setTimeout(() => {
      if (!isAutoScrolling.value && sections.value.length > 0) {
        startAutoScroll(sections.value)
      }
    }, delayMs)
  }

  // Handle user scroll events
  const handleUserScroll = () => {
    if (isAutoScrolling.value) {
      pauseAutoScroll()
      resumeAutoScroll()
    }
  }

  onMounted(() => {
    window.addEventListener('wheel', handleUserScroll)
    window.addEventListener('touchstart', handleUserScroll)
  })

  onUnmounted(() => {
    stopAutoScroll()
    window.removeEventListener('wheel', handleUserScroll)
    window.removeEventListener('touchstart', handleUserScroll)
  })

  return {
    isAutoScrolling,
    currentSection,
    startAutoScroll,
    stopAutoScroll,
    scrollToSection,
    goToSection,
    pauseAutoScroll,
    resumeAutoScroll
  }
}

export const useSeo = () => {
  const setPageMeta = (meta: {
    title?: string
    description?: string
    image?: string
    url?: string
    type?: string
    keywords?: string
  }) => {
    const siteName = 'Kula Qr'
    const baseUrl = 'https://kula-qr.vercel.app'
    
    // Title
    const title = meta.title ? `${meta.title} | ${siteName}` : siteName
    
    // Description
    const description = meta.description || 'Transformez votre activité commerciale avec des menus digitaux QR code. Solution moderne, sans contact et écologique.'
    
    // Image
    const image = meta.image || `${baseUrl}/images/logo.png`
    
    // URL
    const url = meta.url ? `${baseUrl}${meta.url}` : baseUrl
    
    // Type
    const type = meta.type || 'website'
    
    // Keywords
    const keywords = meta.keywords || 'QR code, menu digital, activité commerciale, sans contact, menu électronique, commande en ligne'

    useHead({
      title,
      meta: [
        { name: 'description', content: description },
        { name: 'keywords', content: keywords },
        { property: 'og:title', content: title },
        { property: 'og:description', content: description },
        { property: 'og:image', content: image },
        { property: 'og:url', content: url },
        { property: 'og:type', content: type },
        { property: 'og:site_name', content: siteName },
        { name: 'twitter:title', content: title },
        { name: 'twitter:description', content: description },
        { name: 'twitter:image', content: image },
        { name: 'twitter:card', content: 'summary_large_image' }
      ],
      link: [
        { rel: 'canonical', href: url }
      ]
    })
  }

  const setRestaurantMeta = (establishment: Establishment) => {
    const title = `Menu ${establishment.name} - QR Code Digital`
    const description = `Découvrez le menu de ${establishment.name}. Commandez facilement avec notre menu digital QR code. ${establishment.description || ''}`
    const image = establishment.image_url || 'https://kula-qr.vercel.app/images/pexels.jpg'
    const url = `/menu/${establishment.slug}`
    
    setPageMeta({
      title,
      description,
      image,
      url,
      type: 'website',
      keywords: `menu ${establishment.name}, QR code, commande en ligne, ${establishment.address || ''}`
    })
  }

  const setHomeMeta = () => {
    setPageMeta({
      title: 'Menu Digital QR Code pour Commerces',
      description: 'Transformez votre commerce avec des menus digitaux QR code. Solution moderne, sans contact et écologique. Créez votre menu en quelques minutes.',
      url: '/',
      keywords: 'QR code commerciale, menu digital, sans contact, menu électronique, solution commerciale, commande en ligne'
    })
  }

  const setAboutMeta = () => {
    setPageMeta({
      title: 'À propos de Kula Qr',
      description: 'Découvrez comment Kula Qr révolutionne l\'expérience commerciale avec des menus digitaux QR code. Solution moderne et écologique.',
      url: '/about',
      keywords: 'à propos kula qr, menu digital, solution commerciale, QR code, innovation'
    })
  }

  const setContactMeta = () => {
    setPageMeta({
      title: 'Contact - Kula Qr',
      description: 'Contactez l\'équipe Kula Qr pour toute question sur nos solutions de menu digital QR code pour commerces.',
      url: '/contact',
      keywords: 'contact kula qr, support, aide, menu digital, QR code activité commerciale'
    })
  }

  return {
    setPageMeta,
    setRestaurantMeta,
    setHomeMeta,
    setAboutMeta,
    setContactMeta
  }
}
