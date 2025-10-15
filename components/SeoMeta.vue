<template>
  <!-- Ce composant gère les meta tags via useHead -->
</template>

<script setup lang="ts">
interface SeoMetaProps {
  title?: string
  description?: string
  image?: string
  url?: string
  type?: string
  keywords?: string
  noindex?: boolean
}

const props = withDefaults(defineProps<SeoMetaProps>(), {
  type: 'website',
  noindex: false
})

const siteName = 'Kula Qr'
const baseUrl = 'https://kulaqr.com'

// Construction des meta tags
const title = props.title ? `${props.title} | ${siteName}` : siteName
const description = props.description || 'Transformez votre restaurant avec des menus digitaux QR code. Solution moderne, sans contact et écologique.'
const image = props.image || `${baseUrl}/og-image.jpg`
const url = props.url ? `${baseUrl}${props.url}` : baseUrl
const robots = props.noindex ? 'noindex, nofollow' : 'index, follow'

useHead({
  title,
  meta: [
    { name: 'description', content: description },
    { name: 'keywords', content: props.keywords || 'QR code, menu digital, restaurant, sans contact, menu électronique, commande en ligne' },
    { name: 'robots', content: robots },
    { property: 'og:title', content: title },
    { property: 'og:description', content: description },
    { property: 'og:image', content: image },
    { property: 'og:url', content: url },
    { property: 'og:type', content: props.type },
    { property: 'og:site_name', content: siteName },
    { property: 'og:locale', content: 'fr_FR' },
    { name: 'twitter:title', content: title },
    { name: 'twitter:description', content: description },
    { name: 'twitter:image', content: image },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:site', content: '@kulaqr' }
  ],
  link: [
    { rel: 'canonical', href: url }
  ]
})
</script>
