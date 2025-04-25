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
            <NuxtLink to="/legal/mentions-legales" class="text-sm text-gray-500 hover:text-black transition-colors">
              Mentions légales
            </NuxtLink>
            <NuxtLink to="/legal/cgu" class="text-sm text-gray-500 hover:text-black transition-colors">
              CGU
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
        <!-- Privacy Policy Section -->
        <section class="space-y-6">
          <h1 class="text-3xl sm:text-4xl font-semibold text-black">Politique de Confidentialité</h1>
          
          <div class="prose prose-lg max-w-none text-gray-600">
            <p class="text-lg font-medium text-gray-800">
              Dernière mise à jour : 1er juin 2023
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">1. Collecte des données</h2>
            <p>
              KulaQr collecte les données personnelles suivantes :
            </p>
            <ul class="list-disc pl-6 space-y-2">
              <li>Informations d'identification (nom, prénom, adresse email)</li>
              <li>Informations de facturation</li>
              <li>Informations sur l'établissement (nom, adresse, type de cuisine)</li>
              <li>Données d'utilisation du service</li>
            </ul>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">2. Utilisation des données</h2>
            <p>
              Les données collectées sont utilisées pour :
            </p>
            <ul class="list-disc pl-6 space-y-2">
              <li>Fournir et améliorer le service</li>
              <li>Gérer votre compte et votre abonnement</li>
              <li>Vous contacter concernant votre compte ou le service</li>
              <li>Analyser l'utilisation du service</li>
            </ul>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">3. Partage des données</h2>
            <p>
              KulaQr ne vend pas vos données personnelles. Nous pouvons partager vos données avec :
            </p>
            <ul class="list-disc pl-6 space-y-2">
              <li>Nos prestataires de services (hébergement, paiement)</li>
              <li>Les autorités compétentes si la loi l'exige</li>
            </ul>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">4. Sécurité des données</h2>
            <p>
              KulaQr met en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données contre la perte, l'accès non autorisé, la divulgation ou la destruction.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">5. Conservation des données</h2>
            <p>
              Nous conservons vos données aussi longtemps que nécessaire pour fournir le service et respecter nos obligations légales. Après résiliation de votre compte, vos données sont conservées pendant une période de 12 mois avant d'être anonymisées ou supprimées.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">6. Vos droits</h2>
            <p>
              Conformément au RGPD, vous disposez des droits suivants :
            </p>
            <ul class="list-disc pl-6 space-y-2">
              <li>Droit d'accès à vos données</li>
              <li>Droit de rectification</li>
              <li>Droit à l'effacement</li>
              <li>Droit à la limitation du traitement</li>
              <li>Droit à la portabilité des données</li>
              <li>Droit d'opposition</li>
            </ul>
            <p>
              Pour exercer ces droits, contactez-nous à privacy@kulaqr.com.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">7. Cookies</h2>
            <p>
              KulaQr utilise des cookies pour améliorer votre expérience. Vous pouvez configurer votre navigateur pour refuser les cookies, mais certaines fonctionnalités du service pourraient ne pas fonctionner correctement.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">8. Modifications de la politique</h2>
            <p>
              Nous pouvons modifier cette politique de confidentialité à tout moment. Les modifications seront publiées sur cette page et, si elles sont significatives, nous vous en informerons par email.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">9. Contact</h2>
            <p>
              Pour toute question concernant cette politique de confidentialité, contactez notre Délégué à la Protection des Données à privacy@kulaqr.com.
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