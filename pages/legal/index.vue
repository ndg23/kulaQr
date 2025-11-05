<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="bg-white/80 backdrop-blur-md sticky top-0 z-50 border-b border-gray-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="flex items-center justify-between h-16 sm:h-20">
          <NuxtLink to="/" class="flex items-center">
           <img src="/images/logo.png" alt="Kula QR" class="h-8 sm:h-10" />
            <span class="text-black text-lg sm:text-xl font-medium">Kula QR</span>
          </NuxtLink>
          <NuxtLink to="/" class="text-sm text-gray-500 hover:text-black transition-colors">
            Retour à l'accueil
          </NuxtLink>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 sm:px-6 py-12 sm:py-16">
      <div class="space-y-8">
        <h1 class="text-3xl sm:text-4xl font-semibold text-black text-center">Informations Légales</h1>
        <p class="text-lg text-gray-600 text-center max-w-2xl mx-auto">
          Consultez nos documents légaux pour en savoir plus sur nos conditions d'utilisation, notre politique de confidentialité et nos mentions légales.
        </p>
        
        <div class="grid md:grid-cols-3 gap-6 mt-12">
          <NuxtLink to="/legal/mentions-legales" class="bg-white border border-gray-200 rounded-xl p-6 hover:shadow-md transition-shadow">
            <h2 class="text-xl font-medium text-black mb-2">Mentions Légales</h2>
            <p class="text-gray-600 text-sm">Informations sur l'éditeur du site, l'hébergement et les droits de propriété intellectuelle.</p>
            <div class="mt-4 text-blue-600 flex items-center text-sm font-medium">
              Consulter
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </div>
          </NuxtLink>
          
          <NuxtLink to="/legal/cgu" class="bg-white border border-gray-200 rounded-xl p-6 hover:shadow-md transition-shadow">
            <h2 class="text-xl font-medium text-black mb-2">Conditions d'Utilisation</h2>
            <p class="text-gray-600 text-sm">Règles et conditions régissant l'utilisation de notre service KulaQr.</p>
            <div class="mt-4 text-blue-600 flex items-center text-sm font-medium">
              Consulter
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </div>
          </NuxtLink>
          
          <NuxtLink to="/legal/privacy" class="bg-white border border-gray-200 rounded-xl p-6 hover:shadow-md transition-shadow">
            <h2 class="text-xl font-medium text-black mb-2">Politique de Confidentialité</h2>
            <p class="text-gray-600 text-sm">Comment nous collectons, utilisons et protégeons vos données personnelles.</p>
            <div class="mt-4 text-blue-600 flex items-center text-sm font-medium">
              Consulter
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </div>
          </NuxtLink>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-50 border-t border-gray-200 py-8">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="flex flex-col sm:flex-row justify-between items-center">
          <div class="text-gray-500 text-xs sm:text-sm mb-4 sm:mb-0">
            © 2025 Kula QR. Tous droits réservés.
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