import type { Establishment } from '~/types'

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
    const description = meta.description || 'Transformez votre restaurant avec des menus digitaux QR code. Solution moderne, sans contact et écologique.'
    
    // Image
    const image = meta.image || `${baseUrl}/og-image.jpg`
    
    // URL
    const url = meta.url ? `${baseUrl}${meta.url}` : baseUrl
    
    // Type
    const type = meta.type || 'website'
    
    // Keywords
    const keywords = meta.keywords || 'QR code, menu digital, restaurant, sans contact, menu électronique, commande en ligne'

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

  const setRestaurantMeta = (restaurant: Establishment) => {
    const title = `Menu ${restaurant.name} - QR Code Digital`
    const description = `Découvrez le menu de ${restaurant.name}. Commandez facilement avec notre menu digital QR code. ${restaurant.description || ''}`
    const image = restaurant.image_url || 'https://kula-qr.vercel.app/og-restaurant.jpg'
    const url = `/menu/${restaurant.slug}`
    
    setPageMeta({
      title,
      description,
      image,
      url,
      type: 'restaurant',
      keywords: `menu ${restaurant.name}, ${restaurant.cuisine_type || 'restaurant'}, QR code, commande en ligne, ${restaurant.city || ''}`
    })
  }

  const setHomeMeta = () => {
    setPageMeta({
      title: 'Menu Digital QR Code pour Restaurants',
      description: 'Transformez votre restaurant avec des menus digitaux QR code. Solution moderne, sans contact et écologique. Créez votre menu en quelques minutes.',
      url: '/',
      keywords: 'QR code restaurant, menu digital, sans contact, menu électronique, solution restaurant, commande en ligne'
    })
  }

  const setAboutMeta = () => {
    setPageMeta({
      title: 'À propos de Kula Qr',
      description: 'Découvrez comment Kula Qr révolutionne l\'expérience restaurant avec des menus digitaux QR code. Solution moderne et écologique.',
      url: '/about',
      keywords: 'à propos kula qr, menu digital, solution restaurant, QR code, innovation'
    })
  }

  const setContactMeta = () => {
    setPageMeta({
      title: 'Contact - Kula Qr',
      description: 'Contactez l\'équipe Kula Qr pour toute question sur nos solutions de menu digital QR code pour restaurants.',
      url: '/contact',
      keywords: 'contact kula qr, support, aide, menu digital, QR code restaurant'
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
