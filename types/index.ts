export interface Product {
  id: string;
  category_id: string;
  name: string;
  description?: string;
  price: number;
  image_url?: string;
  is_available: boolean;
  order_number: number;
  created_at: string;
}

export interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  notes?: string;
}

export interface Cart {
  items: CartItem[];
  tableNumber?: number;
  notes?: string;
}

export interface Category {
  id: string;
  establishment_id: string;
  name: string;
  order_number: number;
  created_at: string;
}

export interface EstablishmentData {
  _id: string;
  name: string;
  categories: Category[];
}

export interface OrderData {
  _id: string;
  establishmentId: string;
  products: {
    productId: string;
    quantity: number;
    name: string;
    price: number;
  }[];
  totalAmount: number;
  status: 'pending' | 'completed' | 'cancelled';
}

export interface Establishment {
  id: string;
  created_at: string;
  name: string;
  description?: string;
  image_url?: string;
  address?: string;
  phone?: string;
  opening_hours?: string;
  rating: number;
  review_count: number;
  user_id: string;
  is_active: boolean;
}

export interface Order {
  id: string;
  establishment_id: string;
  table_number?: number;
  status: 'pending' | 'processing' | 'completed' | 'cancelled';
  total_amount: number;
  created_at: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  quantity: number;
  price: number;
  created_at: string;
} 