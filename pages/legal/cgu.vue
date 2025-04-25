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
        <!-- CGU Section -->
        <section class="space-y-6">
          <h1 class="text-3xl sm:text-4xl font-semibold text-black">Conditions Générales d'Utilisation</h1>
          
          <div class="prose prose-lg max-w-none text-gray-600">
            <p class="text-lg font-medium text-gray-800">
              Dernière mise à jour : 1er juin 2023
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">1. Acceptation des conditions</h2>
            <p>
              L'utilisation du service KulaQr est soumise aux présentes conditions générales d'utilisation. En utilisant notre service, vous reconnaissez avoir pris connaissance de ces conditions et les accepter sans réserve.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">2. Description du service</h2>
            <p>
              KulaQr est une solution de menu digital par QR code destinée aux restaurants et établissements de restauration. Le service permet de créer, gérer et mettre à jour des menus digitaux accessibles via QR code.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">3. Compte utilisateur</h2>
            <p>
              Pour utiliser le service, vous devez créer un compte. Vous êtes responsable de la confidentialité de vos identifiants et de toutes les activités effectuées sous votre compte. Vous vous engagez à fournir des informations exactes et à les maintenir à jour.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">4. Abonnements et paiements</h2>
            <p>
              KulaQr propose différentes formules d'abonnement. Les prix sont indiqués en euros et hors taxes. Le paiement s'effectue par prélèvement automatique selon la périodicité choisie. Tout mois commencé est dû intégralement.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">5. Responsabilités</h2>
            <p>
              KulaQr s'efforce d'assurer la disponibilité du service 24h/24 et 7j/7, mais ne peut garantir une disponibilité sans interruption. KulaQr ne saurait être tenu responsable des dommages directs ou indirects résultant de l'utilisation du service.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">6. Propriété intellectuelle</h2>
            <p>
              Le contenu créé par les utilisateurs reste leur propriété. En utilisant le service, vous accordez à KulaQr une licence non exclusive pour utiliser, reproduire et afficher ce contenu dans le cadre du service.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">7. Résiliation</h2>
            <p>
              Vous pouvez résilier votre abonnement à tout moment depuis votre espace client. La résiliation prendra effet à la fin de la période d'abonnement en cours. KulaQr se réserve le droit de résilier ou suspendre votre compte en cas de violation des présentes conditions.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">8. Modification des conditions</h2>
            <p>
              KulaQr se réserve le droit de modifier les présentes conditions à tout moment. Les utilisateurs seront informés des modifications par email ou via le service. L'utilisation continue du service après notification vaut acceptation des nouvelles conditions.
            </p>

            <h2 class="text-xl sm:text-2xl font-medium text-black mt-8 mb-4">9. Droit applicable et juridiction compétente</h2>
            <p>
              Les présentes conditions sont régies par le droit français. Tout litige relatif à l'interprétation ou à l'exécution des présentes conditions relèvera de la compétence exclusive des tribunaux de Paris.
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