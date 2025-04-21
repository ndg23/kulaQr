import { ref, computed } from 'vue'

export interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
  notes?: string
  image_url?: string
}

export interface Cart {
  items: CartItem[]
  tableNumber?: number
  notes?: string
  establishmentId: string
}

export const useCart = () => {
  const cart = ref<Cart>({
    items: [],
    establishmentId: '',
  })

  // Charger le panier du localStorage
  const loadCart = (establishmentId: string) => {
    const savedCart = localStorage.getItem(`cart-${establishmentId}`)
    if (savedCart) {
      cart.value = JSON.parse(savedCart)
    } else {
      cart.value = {
        items: [],
        establishmentId
      }
    }
  }

  // Sauvegarder le panier
  const saveCart = () => {
    localStorage.setItem(`cart-${cart.value.establishmentId}`, JSON.stringify(cart.value))
  }

  // Ajouter un produit
  const addToCart = (product: any, quantity: number = 1, notes?: string) => {
    const existingItem = cart.value.items.find(item => item.id === product.id)
    
    if (existingItem) {
      existingItem.quantity += quantity
      existingItem.notes = notes
    } else {
      cart.value.items.push({
        id: product.id,
        name: product.name,
        price: product.price,
        quantity,
        notes,
        image_url: product.image_url
      })
    }
    
    saveCart()
  }

  // Mettre à jour la quantité
  const updateQuantity = (productId: string, quantity: number) => {
    const item = cart.value.items.find(item => item.id === productId)
    if (item) {
      item.quantity = quantity
      if (quantity <= 0) {
        cart.value.items = cart.value.items.filter(item => item.id !== productId)
      }
      saveCart()
    }
  }

  // Vider le panier
  const clearCart = () => {
    cart.value.items = []
    cart.value.notes = undefined
    saveCart()
  }

  // Calculer le total
  const total = computed(() => {
    return cart.value.items.reduce((sum, item) => sum + (item.price * item.quantity), 0)
  })

  // Définir le numéro de table
  const setTableNumber = (number: number) => {
    cart.value.tableNumber = number
    saveCart()
  }

  return {
    cart,
    addToCart,
    updateQuantity,
    clearCart,
    total,
    setTableNumber,
    loadCart
  }
} 