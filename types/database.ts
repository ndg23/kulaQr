export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      establishments: {
        Row: {
          id: string
          created_at: string
          name: string
          description: string | null
          image_url: string | null
          address: string | null
          phone: string | null
          opening_hours: string | null
          rating: number | null
          review_count: number
          user_id: string
          is_active: boolean
        }
        Insert: {
          id?: string
          created_at?: string
          name: string
          description?: string | null
          image_url?: string | null
          address?: string | null
          phone?: string | null
          opening_hours?: string | null
          rating?: number | null
          review_count?: number
          user_id: string
          is_active?: boolean
        }
        Update: Partial<Insert>
      }
      categories: {
        Row: {
          id: string
          created_at: string
          establishment_id: string
          name: string
          description: string | null
          image_url: string | null
          order_number: number
          is_active: boolean
          product_count: number
        }
        Insert: {
          id?: string
          created_at?: string
          establishment_id: string
          name: string
          description?: string | null
          image_url?: string | null
          order_number?: number
          is_active?: boolean
          product_count?: number
        }
        Update: {
          id?: string
          created_at?: string
          establishment_id?: string
          name?: string
          description?: string | null
          image_url?: string | null
          order_number?: number
          is_active?: boolean
          product_count?: number
        }
      }
      products: {
        Row: {
          id: string
          created_at: string
          category_id: string
          name: string
          description: string | null
          price: number
          image_url: string | null
          is_available: boolean
          order_number: number
        }
        Insert: {
          id?: string
          created_at?: string
          category_id: string
          name: string
          description?: string | null
          price: number
          image_url?: string | null
          is_available?: boolean
          order_number?: number
        }
        Update: {
          id?: string
          created_at?: string
          category_id?: string
          name?: string
          description?: string | null
          price?: number
          image_url?: string | null
          is_available?: boolean
          order_number?: number
        }
      }
      orders: {
        Row: {
          id: string
          created_at: string
          establishment_id: string
          table_id: string | null
          table_number: number | null
          status: string
          total_amount: number
          payment_status: string | null
          payment_method: string | null
          notes: string | null
          rating: number | null
          rating_comment: string | null
          updated_at: string
        }
        Insert: {
          id?: string
          created_at?: string
          establishment_id: string
          table_id?: string | null
          table_number?: number | null
          status?: string
          total_amount?: number
          payment_status?: string | null
          payment_method?: string | null
          notes?: string | null
          rating?: number | null
          rating_comment?: string | null
          updated_at?: string
        }
        Update: {
          id?: string
          created_at?: string
          establishment_id?: string
          table_id?: string | null
          table_number?: number | null
          status?: string
          total_amount?: number
          payment_status?: string | null
          payment_method?: string | null
          notes?: string | null
          rating?: number | null
          rating_comment?: string | null
          updated_at?: string
        }
      }
      order_items: {
        Row: {
          id: string
          created_at: string
          order_id: string
          product_id: string | null
          quantity: number
          unit_price: number
          subtotal: number
          notes: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          order_id: string
          product_id?: string | null
          quantity?: number
          unit_price: number
          subtotal?: number
          notes?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          order_id?: string
          product_id?: string | null
          quantity?: number
          unit_price?: number
          subtotal?: number
          notes?: string | null
        }
      }
    }
  }
}