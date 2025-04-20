<template>
  <div class="min-h-screen bg-gray-100">
    <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <div class="bg-white shadow rounded-lg p-6">
          <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">Gestion du Menu</h1>
            <button 
              @click="generateQRCode"
              class="bg-blue-500 text-white px-4 py-2 rounded-md"
            >
              Générer QR Code
            </button>
          </div>

          <!-- Statistiques -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div class="bg-gray-50 p-4 rounded-lg">
              <h3 class="text-lg font-medium">Scans aujourd'hui</h3>
              <p class="text-2xl font-bold">{{ stats.todayScans }}</p>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <h3 class="text-lg font-medium">Commandes du jour</h3>
              <p class="text-2xl font-bold">{{ stats.todayOrders }}</p>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <h3 class="text-lg font-medium">Revenu du jour</h3>
              <p class="text-2xl font-bold">{{ formatPrice(stats.todayRevenue) }}</p>
            </div>
          </div>

          <!-- Gestion des catégories -->
          <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-semibold">Catégories</h2>
              <button 
                @click="showAddCategory = true"
                class="text-blue-500"
              >
                + Ajouter une catégorie
              </button>
            </div>
            
            <draggable 
              v-model="categories" 
              @end="updateCategoryOrder"
              class="space-y-4"
            >
              <div 
                v-for="category in categories" 
                :key="category.id"
                class="bg-gray-50 p-4 rounded-lg"
              >
                <div class="flex justify-between items-center">
                  <h3 class="text-lg font-medium">{{ category.name }}</h3>
                  <div class="flex space-x-2">
                    <button @click="editCategory(category)">
                      <span class="sr-only">Modifier</span>
                      ✏️
                    </button>
                    <button @click="deleteCategory(category.id)">
                      <span class="sr-only">Supprimer</span>
                      🗑️
                    </button>
                  </div>
                </div>
              </div>
            </draggable>
          </div>

          <!-- Gestion des produits -->
          <div>
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-semibold">Produits</h2>
              <button 
                @click="showAddProduct = true"
                class="text-blue-500"
              >
                + Ajouter un produit
              </button>
            </div>

            <div class="space-y-4">
              <div 
                v-for="product in products" 
                :key="product.id"
                class="bg-gray-50 p-4 rounded-lg flex justify-between items-center"
              >
                <div>
                  <h3 class="font-medium">{{ product.name }}</h3>
                  <p class="text-sm text-gray-500">{{ product.description }}</p>
                  <p class="text-sm font-medium">{{ formatPrice(product.price) }}</p>
                </div>
                <div class="flex space-x-2">
                  <button @click="editProduct(product)">
                    <span class="sr-only">Modifier</span>
                    ✏️
                  </button>
                  <button @click="deleteProduct(product.id)">
                    <span class="sr-only">Supprimer</span>
                    🗑️
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals pour l'édition -->
    <CategoryModal 
      v-if="showAddCategory"
      @close="showAddCategory = false"
      @save="saveCategory"
    />
    <ProductModal 
      v-if="showAddProduct"
      :categories="categories"
      @close="showAddProduct = false"
      @save="saveProduct"
    />
  </div>
</template>

<script setup lang="ts">
import draggable from 'vuedraggable'

const route = useRoute()
const { getEstablishment } = useEstablishment()
const supabase = useSupabaseClient()
const restaurantId = route.params.id as string

const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const stats = ref({
  todayScans: 0,
  todayOrders: 0,
  todayRevenue: 0
})

const showAddCategory = ref(false)
const showAddProduct = ref(false)
const showQRCode = ref(false)
const editingCategory = ref<Category | null>(null)
const editingProduct = ref<Product | null>(null)

// Chargement initial des données
onMounted(async () => {
  await loadData()
  await loadStats()
})

const loadData = async () => {
  try {
    const { data, error } = await supabase
      .from('categories')
      .select(`
        *,
        products (*)
      `)
      .eq('establishment_id', restaurantId)
      .order('order_number')

    if (error) throw error
    categories.value = data
    products.value = data.flatMap(cat => cat.products)
  } catch (err) {
    console.error('Error loading data:', err)
  }
}

const loadStats = async () => {
  const today = new Date().toISOString().split('T')[0]
  try {
    const { data: scans } = await supabase
      .from('qr_scans')
      .select('count')
      .eq('establishment_id', restaurantId)
      .gte('created_at', today)
      .single()

    const { data: orders } = await supabase
      .from('orders')
      .select('total_amount')
      .eq('establishment_id', restaurantId)
      .gte('created_at', today)

    stats.value = {
      todayScans: scans?.count || 0,
      todayOrders: orders?.length || 0,
      todayRevenue: orders?.reduce((sum, order) => sum + order.total_amount, 0) || 0
    }
  } catch (err) {
    console.error('Error loading stats:', err)
  }
}

// Gestion des catégories
const saveCategory = async (categoryData: { name: string }) => {
  try {
    const newCategory = {
      establishment_id: restaurantId,
      name: categoryData.name,
      order_number: categories.value.length
    }

    const { data, error } = await supabase
      .from('categories')
      .insert(newCategory)
      .select()
      .single()

    if (error) throw error
    categories.value.push(data)
    showAddCategory.value = false
  } catch (err) {
    console.error('Error saving category:', err)
  }
}

const updateCategoryOrder = async () => {
  try {
    const updates = categories.value.map((cat, index) => ({
      id: cat.id,
      order_number: index
    }))

    const { error } = await supabase
      .from('categories')
      .upsert(updates)

    if (error) throw error
  } catch (err) {
    console.error('Error updating category order:', err)
  }
}

// Gestion des produits
const saveProduct = async (productData: { categoryId: string; name: string; description: string; price: number }) => {
  try {
    const newProduct = {
      category_id: productData.categoryId,
      name: productData.name,
      description: productData.description,
      price: productData.price,
      order_number: products.value.filter(p => p.category_id === productData.categoryId).length
    }

    const { data, error } = await supabase
      .from('products')
      .insert(newProduct)
      .select()
      .single()

    if (error) throw error
    products.value.push(data)
    showAddProduct.value = false
  } catch (err) {
    console.error('Error saving product:', err)
  }
}

const generateQRCode = () => {
  showQRCode.value = true
}
</script> 