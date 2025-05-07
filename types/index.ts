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
  establishment_id: string;
}

export interface Category {
  id: string;
  name: string;
  description?: string;
  order_number: number;
  establishment_id: string;
  created_at: string;
  updated_at?: string;
  icon_name?: string;
  image_url?: string;
  // Métadonnées UI (non stockées en DB)
  icon?: any;
  iconBg?: string;
  iconColor?: string;
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
  establishmentId: string;
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

export interface OrderItem {
  id: string;
  name: string;
  quantity: number;
  price: number;
  note: string | null;
  products?: {
    name: string;
  };
  order_id?: string;
  unit_price: number;
}

export interface Order {
  id: string;
  orderNumber: string;
  table: number;
  status: OrderStatus;
  created_at: string;
  total: number;
  items: OrderItem[];
  table_number?: number;
  total_amount?: number;
}

export type OrderStatus = 'pending' | 'accepted' | 'preparing' | 'ready' | 'completed' | 'rejected';

export interface StatusMessage {
  [key: string]: string;
  accepted: string;
  rejected: string;
  preparing: string;
  ready: string;
  completed: string;
} 