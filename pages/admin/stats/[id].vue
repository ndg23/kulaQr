<template>
  <div class="min-h-screen bg-gray-100">
    <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <div class="bg-white shadow rounded-lg p-6">
          <h1 class="text-2xl font-bold mb-6">Statistiques</h1>
          
          <!-- Période sélectionnée -->
          <div class="flex space-x-4 mb-6">
            <button 
              v-for="period in periods"
              :key="period"
              @click="selectedPeriod = period"
              :class="[
                'px-4 py-2 rounded-md',
                selectedPeriod === period 
                  ? 'bg-blue-500 text-white' 
                  : 'bg-gray-100'
              ]"
            >
              {{ period }}
            </button>
          </div>

          <!-- Graphiques -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-gray-50 p-4 rounded-lg">
              <h3 class="text-lg font-medium mb-4">Commandes</h3>
              <!-- Insérer le composant de graphique ici -->
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <h3 class="text-lg font-medium mb-4">Revenus</h3>
              <!-- Insérer le composant de graphique ici -->
            </div>
          </div>

          <!-- Produits populaires -->
          <div class="mt-6">
            <h2 class="text-xl font-semibold mb-4">Produits les plus commandés</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div 
                v-for="product in popularProducts" 
                :key="product.id"
                class="bg-gray-50 p-4 rounded-lg"
              >
                <h3 class="font-medium">{{ product.name }}</h3>
                <p class="text-sm text-gray-500">{{ product.orderCount }} commandes</p>
                <p class="text-sm font-medium">{{ formatPrice(product.revenue) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template> 