<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="bg-white/80 backdrop-blur-md sticky top-0 z-50 border-b border-gray-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="flex items-center justify-between h-16 sm:h-20">
          <NuxtLink to="/" class="flex items-center">
            <div class="w-8 sm:w-10 h-8 sm:h-10 bg-black rounded-lg flex items-center justify-center mr-3">
              <span class="text-white text-lg sm:text-xl font-bold">KQ</span>
            </div>
            <span class="text-black text-lg sm:text-xl font-medium">KulaQr</span>
          </NuxtLink>
          <div class="flex items-center space-x-6">
            <NuxtLink to="/legal/cgu" class="text-sm text-gray-500 hover:text-black transition-colors">
              CGU
            </NuxtLink>
            <NuxtLink to="/legal/privacy" class="text-sm text-gray-500 hover:text-black transition-colors">
              Confidentialité
            </NuxtLink>
            <NuxtLink to="/" class="text-sm text-gray-500 hover:text-black transition-colors">
              Accueil
            </NuxtLink>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-3xl mx-auto px-4 sm:px-6 py-12 sm:py-16">
      <div class="space-y-8">
        <!-- Legal Notice Section -->
        <section class="space-y-6">
          <h1 class="text-3xl sm:text-4xl font-semibold text-black">Mentions Légales</h1>
          
          <div class="prose prose-lg max-w-none text-gray-600">
            <p class="text-lg font-medium text-gray-800">
              Dernière mise à jour : 1er juin 2023
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">Éditeur du site</h2>
            <p>
              <strong>KulaQr SAS</strong><br>
              Société par actions simplifiée au capital de 10 000 €<br>
              Siège social : 14 Rue de la Paix, 75002 Paris, France<br>
              RCS Paris B 123 456 789<br>
              N° TVA : FR 12 345 678 901<br>
              Directeur de la publication : Jean Dupont
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">Hébergement</h2>
            <p>
              <strong>Vercel Inc.</strong><br>
              340 S Lemon Ave #4133<br>
              Walnut, CA 91789<br>
              États-Unis
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">Propriété intellectuelle</h2>
            <p>
              L'ensemble du contenu du site KulaQr (textes, graphismes, logos, images, vidéos, etc.) est protégé par le droit d'auteur. Toute reproduction ou représentation, totale ou partielle, du site ou de l'un de ses éléments, sans autorisation expresse de KulaQr, est interdite et constituerait une contrefaçon sanctionnée par les articles L.335-2 et suivants du Code de la propriété intellectuelle.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">Données personnelles</h2>
            <p>
              Conformément à la loi n° 78-17 du 6 janvier 1978 relative à l'informatique, aux fichiers et aux libertés, modifiée par le Règlement européen n°2016/679 du 27 avril 2016 relatif à la protection des données personnelles (RGPD), vous disposez d'un droit d'accès, de rectification, d'effacement, de limitation, de portabilité et d'opposition aux données vous concernant.
            </p>
            <p>
              Pour exercer ces droits, vous pouvez nous contacter à l'adresse suivante : privacy@kulaqr.com ou par courrier à l'adresse du siège social.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">Crédits</h2>
            <p>
              Conception et développement : KulaQr SAS<br>
              Photographies : Unsplash, Pexels<br>
              Icônes : Lucide Icons
            </p>
          </div>
        </section>
      </div>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-50 border-t border-gray-200 py-8">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="flex flex-col sm:flex-row justify-between items-center">
          <div class="text-gray-500 text-xs sm:text-sm mb-4 sm:mb-0">
            © 2025 KulaQr. Tous droits réservés.
          </div>
          <div class="flex flex-wrap justify-center gap-4 sm:gap-6">
            <NuxtLink to="/" class="text-gray-500 text-xs sm:text-sm hover:text-black transition-colors">
              Accueil
            </NuxtLink>
            <NuxtLink to="/legal/mentions-legales" class="text-gray-500 text-xs sm:text-sm hover:text-black transition-colors">
              Mentions légales
            </NuxtLink>
            <NuxtLink to="/legal/cgu" class="text-gray-500 text-xs sm:text-sm hover:text-black transition-colors">
              Conditions d'utilisation
            </NuxtLink>
            <NuxtLink to="/legal/privacy" class="text-gray-500 text-xs sm:text-sm hover:text-black transition-colors">
              Politique de confidentialité
            </NuxtLink>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'default'
})
</script>

<style scoped>
/* Apple-style typography and spacing */
h1, h2, h3, h4, h5, h6 {
  font-family: SF Pro Display, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

body {
  font-family: SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}
</style> 