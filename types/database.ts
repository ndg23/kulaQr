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
          order_number: number
        }
        Insert: {
          id?: string
          created_at?: string
          establishment_id: string
          name: string
          order_number?: number
        }
        Update: Partial<Insert>
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
        Update: Partial<Insert>
      }
    }
  }
} 