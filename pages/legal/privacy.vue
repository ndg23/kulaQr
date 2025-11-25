<template>
  <div class="w-full">
    <!-- Hero Section -->
    <section class="w-full pt-32 pb-24 md:pt-40 md:pb-32 bg-white">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="max-w-3xl mx-auto text-center">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase mb-8 block">Confidentialité</span>
          <h1 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900 mb-8">
            Politique de Confidentialité
          </h1>
          <p class="text-xl text-gray-500 leading-relaxed">
            Dernière mise à jour : {{ new Date().toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }) }}
          </p>
        </div>
      </div>
    </section>

    <!-- Content Section -->
    <section class="w-full py-16 md:py-24 bg-gray-50">
      <div class="max-w-3xl mx-auto px-4 sm:px-6">
        <div class="prose prose-lg">
          <!-- Introduction -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Introduction</h2>
            <p class="text-gray-600">
              KulaQr, basée à Dakar, Sénégal, s'engage à protéger la vie privée des utilisateurs de notre plateforme. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations personnelles.
            </p>
          </div>

          <!-- Collecte des données -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Collecte des données</h2>
            <p class="text-gray-600 mb-4">
              Nous collectons les informations suivantes :
            </p>
            <ul class="list-disc pl-6 text-gray-600 space-y-2">
              <li>Informations d'identification (nom, prénom, adresse)</li>
              <li>Coordonnées professionnelles de votre établissement</li>
              <li>Informations de paiement sécurisées</li>
              <li>Données d'utilisation de la plateforme</li>
              <li>Statistiques de consultation des menus</li>
            </ul>
          </div>

          <!-- Utilisation des données -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Utilisation des données</h2>
            <p class="text-gray-600 mb-4">
              Vos données sont utilisées pour :
            </p>
            <ul class="list-disc pl-6 text-gray-600 space-y-2">
              <li>Fournir et améliorer nos services</li>
              <li>Personnaliser votre expérience</li>
              <li>Gérer votre compte et vos abonnements</li>
              <li>Vous informer des mises à jour importantes</li>
              <li>Analyser et optimiser nos services</li>
            </ul>
          </div>

          <!-- Protection des données -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Protection des données</h2>
            <p class="text-gray-600 mb-4">
              Nous mettons en œuvre des mesures de sécurité conformes aux standards internationaux :
            </p>
            <ul class="list-disc pl-6 text-gray-600 space-y-2">
              <li>Chiffrement des données sensibles</li>
              <li>Hébergement sécurisé au Sénégal et en Europe</li>
              <li>Accès restreint aux données personnelles</li>
              <li>Surveillance continue de notre infrastructure</li>
            </ul>
          </div>

          <!-- Conformité légale -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Conformité légale</h2>
            <p class="text-gray-600 mb-4">
              Notre politique de confidentialité est conforme aux réglementations suivantes :
            </p>
            <ul class="list-disc pl-6 text-gray-600 space-y-2">
              <li>Loi sénégalaise sur la protection des données personnelles</li>
              <li>Règlement Général sur la Protection des Données (RGPD)</li>
              <li>Directives de la CDP (Commission de Protection des Données Personnelles du Sénégal)</li>
              <li>Standards de sécurité de l'industrie du paiement (PCI DSS)</li>
            </ul>
          </div>

          <!-- Droits des utilisateurs -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Vos droits</h2>
            <p class="text-gray-600 mb-4">
              En tant qu'utilisateur basé en Afrique de l'Ouest, vous disposez des droits suivants :
            </p>
            <ul class="list-disc pl-6 text-gray-600 space-y-2">
              <li>Accéder à vos données personnelles</li>
              <li>Rectifier vos informations</li>
              <li>Supprimer votre compte et vos données</li>
              <li>Vous opposer au traitement de vos données</li>
              <li>Obtenir une copie de vos données</li>
            </ul>
          </div>

          <!-- Conservation des données -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Conservation des données</h2>
            <p class="text-gray-600 mb-4">
              Nous conservons vos données pendant la durée nécessaire à la fourniture de nos services et conformément aux obligations légales en vigueur au Sénégal. Les données sont supprimées ou anonymisées lorsqu'elles ne sont plus nécessaires.
            </p>
          </div>

          <!-- Transfert des données -->
          <div class="mb-16">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Transfert des données</h2>
            <p class="text-gray-600 mb-4">
              Vos données sont principalement traitées au Sénégal. Certaines données peuvent être transférées vers des pays offrant un niveau de protection adéquat, notamment pour des besoins d'hébergement et de sauvegarde.
            </p>
          </div>

          <!-- Contact Section -->
          <div class="bg-gray-100 p-8 rounded-2xl">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Nous contacter</h2>
            <p class="text-gray-600 mb-6">
              Pour toute question concernant vos données personnelles, contactez notre délégué à la protection des données :
            </p>
            <ul class="text-gray-600 mb-8 space-y-2">
              <li>Email : privacy@kulaqr.com</li>
              <li>Téléphone : +221 78 383 55 97 | +221 78 373 90 55</li>
              <li>Adresse : Point E, Rue de Saint-Louis, Dakar, Sénégal</li>
            </ul>
            <NuxtLink 
              to="/contact"
              class="inline-flex items-center px-6 py-3 bg-black text-white rounded-full text-base font-medium hover:opacity-90 transition-all"
            >
              Nous contacter
              <ArrowRight class="w-4 h-4 ml-2" />
            </NuxtLink>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ArrowRight } from 'lucide-vue-next'
</script>

<style scoped>
/* Apple-style typography */
h1, h2, h3, h4, h5, h6 {
  font-family: SF Pro Display, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

body {
  font-family: SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Custom prose styles */
.prose {
  max-width: none;
}

.prose h2 {
  margin-top: 0;
  margin-bottom: 1rem;
}

.prose p {
  margin-top: 0;
  margin-bottom: 1.5rem;
}

.prose ul {
  margin-top: 0;
  margin-bottom: 1.5rem;
}
</style> 