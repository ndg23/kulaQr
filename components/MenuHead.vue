<template>
  <div></div>
</template>

<script setup lang="ts">
interface Props {
  establishment?: {
    id: string
    name: string
    description?: string
    image_url?: string
    address?: string
    phone?: string
    opening_hours?: string
    slug: string
  }
  categories?: Array<{
    id: string
    name: string
    description?: string
  }>
  products?: Array<{
    id: string
    name: string
    description?: string
    price: number
    category_id: string
    image_url?: string
  }>
  tableNumber?: string
  customTitle?: string
  customDescription?: string
  customImage?: string
}

const props = withDefaults(defineProps<Props>(), {
  establishment: undefined,
  categories: () => [],
  products: () => [],
  tableNumber: undefined,
  customTitle: undefined,
  customDescription: undefined,
  customImage: undefined
})

const route = useRoute()
const config = useRuntimeConfig()

// Computed properties
const productsCount = computed(() => props.products?.length || 0)
const categoriesCount = computed(() => props.categories?.length || 0)

const title = computed(() => {
  if (props.customTitle) return props.customTitle
  
  const baseName = props.establishment?.name || 'Établissement'
  const tableInfo = props.tableNumber ? ` - Emplacement ${props.tableNumber}` : ''
  
  return `${baseName}${tableInfo} | Catalogue Digital KulaQR`
})

const description = computed(() => {
  if (props.customDescription) return props.customDescription
  
  const establishmentDesc = props.establishment?.description
  const baseDesc = establishmentDesc || `Découvrez notre catalogue digital`
  const stats = productsCount.value > 0 
    ? ` avec ${productsCount.value} articles répartis en ${categoriesCount.value} catégories`
    : ''
  const tableInfo = props.tableNumber ? ` Commandez directement depuis votre emplacement ${props.tableNumber}` : ''
  
  return `${baseDesc}${stats}.${tableInfo} Commandez facilement avec KulaQR.`
})

const keywords = computed(() => {
  const baseKeywords = ['établissement', 'catalogue', 'digital', 'qr code', 'commande', 'kulaQR', 'menu', 'boutique', 'commerce']
  const establishmentKeywords = props.establishment?.name ? [props.establishment.name] : []
  const categoryKeywords = props.categories?.map(c => c.name.toLowerCase()) || []
  
  return [...baseKeywords, ...establishmentKeywords, ...categoryKeywords].join(', ')
})

const canonicalUrl = computed(() => {
  const baseUrl = config.public.siteUrl || 'https://kula-qr.vercel.app'
  return `${baseUrl}${route.fullPath}`
})

const imageUrl = computed(() => {
  if (props.customImage) return props.customImage
  if (props.establishment?.image_url) return props.establishment.image_url
  
  // Fallback OG image
  const baseUrl = config.public.siteUrl || 'https://kula-qr.vercel.app'
  return `${baseUrl}/images/pexels.jpg`
})

const imageAlt = computed(() => {
  if (props.establishment?.name) {
    return `Catalogue ${props.establishment.name}${props.tableNumber ? ` - Emplacement ${props.tableNumber}` : ''}`
  }
  return 'Catalogue Digital KulaQR'
})

const themeColor = computed(() => {
  return '#fc1e1e' // Red as primary brand color
})

// Structured data object
const structuredData = computed(() => ({
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": props.establishment?.name,
  "description": props.establishment?.description,
  "image": props.establishment?.image_url || imageUrl.value,
  "address": props.establishment?.address ? {
    "@type": "PostalAddress",
    "streetAddress": props.establishment.address
  } : undefined,
  "telephone": props.establishment?.phone,
  "openingHours": props.establishment?.opening_hours,
  "priceRange": "$$",
  "url": canonicalUrl.value,
  "hasOfferCatalog": {
    "@type": "OfferCatalog",
    "name": `Catalogue ${props.establishment?.name}`,
    "description": `Découvrez notre catalogue avec ${productsCount.value} articles`,
    "itemListElement": props.categories?.map((category, index) => ({
      "@type": "OfferCatalog",
      "position": index + 1,
      "name": category.name,
      "description": category.description,
      "itemListElement": props.products
        ?.filter(p => p.category_id === category.id)
        .map((product, productIndex) => ({
          "@type": "Offer",
          "position": productIndex + 1,
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "priceCurrency": "XOF",
          "availability": "https://schema.org/InStock"
        }))
    }))
  }
}))

// Use Head composable
useHead({
  title: title,
  meta: [
    { name: 'title', content: title },
    { name: 'description', content: description },
    { name: 'keywords', content: keywords },
    { name: 'robots', content: 'index, follow' },
    { name: 'language', content: 'French' },
    { name: 'author', content: 'KulaQR' },
    { name: 'viewport', content: 'width=device-width, initial-scale=1.0' },
    { name: 'format-detection', content: 'telephone=no' },
    { name: 'theme-color', content: themeColor },
    
    // Open Graph / Facebook
    { property: 'og:type', content: 'website' },
    { property: 'og:url', content: canonicalUrl },
    { property: 'og:title', content: title },
    { property: 'og:description', content: description },
    { property: 'og:image', content: imageUrl },
    { property: 'og:image:width', content: '1200' },
    { property: 'og:image:height', content: '630' },
    { property: 'og:image:alt', content: imageAlt },
    { property: 'og:image:type', content: 'image/jpeg' },
    { property: 'og:site_name', content: 'KulaQR' },
    { property: 'og:locale', content: 'fr_FR' },
    
    // Twitter Card
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:url', content: canonicalUrl },
    { name: 'twitter:title', content: title },
    { name: 'twitter:description', content: description },
    { name: 'twitter:image', content: imageUrl },
    { name: 'twitter:image:alt', content: imageAlt }
  ],
  link: [
    { rel: 'canonical', href: canonicalUrl }
  ],
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify(structuredData.value)
    }
  ]
})
</script>