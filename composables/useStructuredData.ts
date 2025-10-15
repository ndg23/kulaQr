import type { Establishment } from '~/types'

export const useStructuredData = () => {
  const generateRestaurantSchema = (restaurant: Establishment) => {
    return {
      '@context': 'https://schema.org',
      '@type': 'Restaurant',
      name: restaurant.name,
      description: restaurant.description || `Menu digital de ${restaurant.name}`,
      url: `https://kulaqr.com/menu/${restaurant.slug}`,
      image: restaurant.image_url || 'https://kulaqr.com/logo.png',
      telephone: restaurant.phone,
      address: {
        '@type': 'PostalAddress',
        streetAddress: restaurant.address,
        addressLocality: restaurant.city,
        addressCountry: 'FR'
      },
      geo: restaurant.latitude && restaurant.longitude ? {
        '@type': 'GeoCoordinates',
        latitude: restaurant.latitude,
        longitude: restaurant.longitude
      } : undefined,
      openingHours: restaurant.opening_hours || 'Mo-Su 00:00-23:59',
      priceRange: '€€',
      servesCuisine: restaurant.cuisine_type || 'Française',
      hasMenu: {
        '@type': 'Menu',
        name: `Menu de ${restaurant.name}`,
        url: `https://kulaqr.com/menu/${restaurant.slug}`
      },
      aggregateRating: {
        '@type': 'AggregateRating',
        ratingValue: '4.5',
        reviewCount: '10'
      }
    }
  }

  const generateWebSiteSchema = () => {
    return {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: 'Kula Qr',
      description: 'Solution de menu digital QR code pour restaurants',
      url: 'https://kulaqr.com',
      potentialAction: {
        '@type': 'SearchAction',
        target: 'https://kulaqr.com/search?q={search_term_string}',
        'query-input': 'required name=search_term_string'
      }
    }
  }

  const generateOrganizationSchema = () => {
    return {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'Kula Qr',
      description: 'Plateforme de menu digital pour restaurants',
      url: 'https://kulaqr.com',
      logo: 'https://kulaqr.com/logo.png',
      contactPoint: {
        '@type': 'ContactPoint',
        telephone: '+33-1-23-45-67-89',
        contactType: 'customer service',
        availableLanguage: 'French'
      },
      sameAs: [
        'https://twitter.com/kulaqr',
        'https://facebook.com/kulaqr',
        'https://linkedin.com/company/kulaqr'
      ]
    }
  }

  const generateBreadcrumbSchema = (breadcrumbs: Array<{name: string, url: string}>) => {
    return {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: breadcrumbs.map((item, index) => ({
        '@type': 'ListItem',
        position: index + 1,
        name: item.name,
        item: item.url
      }))
    }
  }

  return {
    generateRestaurantSchema,
    generateWebSiteSchema,
    generateOrganizationSchema,
    generateBreadcrumbSchema
  }
}
