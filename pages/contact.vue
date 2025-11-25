
<template>
  <div class="w-full">
    <!-- Hero Section -->
    <section class="w-full pt-32 pb-24 md:pt-40 md:pb-32 bg-white">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="max-w-3xl mx-auto text-center">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase mb-8 block">Contact</span>
          <h1 class="text-4xl sm:text-5xl md:text-6xl font-semibold tracking-tight text-gray-900 mb-8">
            Parlons de votre projet
          </h1>
          <p class="text-xl text-gray-500 leading-relaxed">
            Notre équipe est là pour vous accompagner dans la digitalisation de votre établissement.
          </p>
        </div>
      </div>
    </section>

    <!-- Contact Methods Grid -->
    <section class="w-full py-16 md:py-24 bg-gray-50">
      <div class="max-w-6xl mx-auto px-4 sm:px-6">
        <div class="grid md:grid-cols-3 gap-8 md:gap-12 mb-16">
          <!-- Email -->
          <div class="text-center">
            <div class="w-16 h-16 bg-black rounded-full flex items-center justify-center mx-auto mb-6">
              <Mail class="w-8 h-8 text-white" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Email</h3>
            <p class="text-gray-500 mb-4">Notre équipe vous répond sous 24h</p>
            <a href="mailto:ndgallogho@gmail.com" class="text-black hover:text-gray-600 font-medium">
              ndgallogho@gmail.com
            </a>
          </div>

          <!-- Phone -->
          <div class="text-center">
            <div class="w-16 h-16 bg-black rounded-full flex items-center justify-center mx-auto mb-6">
              <Phone class="w-8 h-8 text-white" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Téléphone</h3>
            <p class="text-gray-500 mb-4">Du lundi au vendredi, 9h-18h</p>
            <a href="tel:+221783835597" class="text-black hover:text-gray-600 font-medium">
              +221 78 383 55 97
            </a>
            <span class="text-gray-400 mx-2">|</span>
            <a href="tel:+221783739055" class="text-black hover:text-gray-600 font-medium">
              +221 78 373 90 55
            </a>
          </div>

          <!-- Office -->
          <div class="text-center">
            <div class="w-16 h-16 bg-black rounded-full flex items-center justify-center mx-auto mb-6">
              <MapPin class="w-8 h-8 text-white" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Bureau</h3>
            <p class="text-gray-500 mb-4">Rencontrons-nous à Dakar</p>
            <p class="text-black font-medium">
              Point E, Rue de Saint-Louis<br/>
              Dakar, Sénégal
            </p>
          </div>
        </div>

        <!-- Contact Form -->
        <div class="max-w-2xl d-none mx-auto bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
          <form @submit.prevent="handleSubmit" class="p-8 md:p-12">
            <div class="space-y-6">
              <!-- Name -->
              <div>
                <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Nom complet</label>
                <input
                  id="name"
                  v-model="form.name"
                  type="text"
                  required
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-black focus:border-transparent transition-shadow"
                  placeholder="Votre nom"
                />
              </div>

              <!-- Email -->
              <div>
                <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input
                  id="email"
                  v-model="form.email"
                  type="email"
                  required
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-black focus:border-transparent transition-shadow"
                  placeholder="vous@exemple.com"
                />
              </div>

              <!-- Phone -->
              <div>
                <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                <input
                  id="phone"
                  v-model="form.phone"
                  type="tel"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-black focus:border-transparent transition-shadow"
                  placeholder="+221 78 383 55 97"
                />
              </div>

              <!-- Subject -->
              <div>
                <label for="subject" class="block text-sm font-medium text-gray-700 mb-2">Sujet</label>
                <select
                  id="subject"
                  v-model="form.subject"
                  required
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-black focus:border-transparent transition-shadow"
                >
                  <option value="">Sélectionnez un sujet</option>
                  <option value="demo">Demande de démonstration</option>
                  <option value="quote">Devis personnalisé</option>
                  <option value="support">Support technique</option>
                  <option value="other">Autre demande</option>
                </select>
              </div>

              <!-- Message -->
              <div>
                <label for="message" class="block text-sm font-medium text-gray-700 mb-2">Message</label>
                <textarea
                  id="message"
                  v-model="form.message"
                  required
                  rows="4"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-black focus:border-transparent transition-shadow"
                  placeholder="Comment pouvons-nous vous aider ?"
                ></textarea>
              </div>

              <!-- Submit Button -->
              <button
                type="submit"
                class="w-full px-8 py-4 bg-black text-white rounded-full text-lg font-medium hover:opacity-90 transition-all flex items-center justify-center"
                :disabled="loading"
              >
                <span v-if="!loading">Envoyer le message</span>
                <span v-else class="flex items-center">
                  <Loader2 class="w-5 h-5 animate-spin mr-2" />
                  Envoi en cours...
                </span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="w-full py-24 bg-white">
      <div class="max-w-4xl mx-auto px-4 sm:px-6">
        <div class="text-center mb-16">
          <span class="text-sm font-semibold tracking-widest text-gray-500 uppercase">FAQ</span>
          <h2 class="mt-4 text-4xl font-semibold text-gray-900">Questions fréquentes</h2>
        </div>

        <div class="space-y-8">
          <div v-for="(faq, index) in faqs" :key="index" class="border-b border-gray-100 pb-8">
            <h3 class="text-xl font-medium text-gray-900 mb-4">{{ faq.question }}</h3>
            <p class="text-gray-600">{{ faq.answer }}</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useSeo } from '~/composables/useSeo'
import { Mail, Phone, MapPin, Loader2 } from 'lucide-vue-next'
import { useCustomToast } from '~/composables/useToast'

const { showToast } = useCustomToast()
const loading = ref(false)
const form = ref({
  name: '',
  email: '',
  phone: '',
  subject: '',
  message: ''
})

const faqs = [
  {
    question: "Combien de temps pour mettre en place le menu QR code ?",
    answer: "La mise en place est immédiate. Dès votre inscription, vous pouvez créer votre menu et générer votre QR code en quelques minutes."
  },
  {
    question: "Proposez-vous une démonstration gratuite ?",
    answer: "Oui, nous proposons une démo gratuite de 7 jours avec toutes les fonctionnalités premium pour tester notre solution."
  },
  {
    question: "Quels sont les moyens de paiement acceptés ?",
    answer: "Nous acceptons les paiements par Wave, Orange Money, carte bancaire et virement bancaire."
  },
  {
    question: "Le support est-il disponible en français ?",
    answer: "Oui, notre équipe basée à Dakar propose un support en français et en wolof, disponible 7j/7."
  }
]

// Configuration SEO pour la page Contact
const { setContactMeta } = useSeo()
setContactMeta()

const handleSubmit = async () => {
  loading.value = true
  try {
    // Simuler l'envoi du formulaire
    await new Promise(resolve => setTimeout(resolve, 1500))
    // Reset form
    form.value = {
      name: '',
      email: '',
      phone: '',
      subject: '',
      message: ''
    }
    await window.open('mailto:ndgallogho@gmail.com?subject=' + encodeURIComponent('Nouveau message de ' + form.value.name + ' - ' + form.value.email) + '&body=' + encodeURIComponent(form.value.message + '\n\n' + 'Téléphone: ' + form.value.phone + '\n\n' + 'Sujet: ' + form.value.subject), '_blank')
    showToast.success('Message envoyé avec succès !')
  } catch (error) {
    showToast.error('Une erreur est survenue. Veuillez réessayer.')
  } finally {
    loading.value = false
  }
}
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
</style> 