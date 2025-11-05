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
        },
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
        },
        Update: {
          id?: string
          created_at?: string
          name?: string
          description?: string | null
          image_url?: string | null
          address?: string | null
          phone?: string | null
          opening_hours?: string | null
          rating?: number | null
          review_count?: number
          user_id?: string
          is_active?: boolean
        },
      },
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
        },
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
        },
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
        },
      },
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
        },
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
        },
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
        },
      },
      order_items: {
        Row: {
          id: string
          created_at: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          total_price: number
          notes: string | null
        },
        Insert: {
          id?: string
          created_at?: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          total_price: number
          notes?: string | null
        },
        Update: {
          id?: string
          created_at?: string
          order_id?: string
          product_id?: string
          quantity?: number
          unit_price?: number
          total_price?: number
          notes?: string | null
        },
      },
      staff: {
        Row: {
          id: string
          establishment_id: string
          username: string
          auth_user_id: string | null
          pin: string | null
          role: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active: boolean
          created_at: string
          updated_at: string
        },
        Insert: {
          id?: string
          establishment_id: string
          username: string
          auth_user_id?: string | null
          pin?: string | null
          role?: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active?: boolean
          created_at?: string
          updated_at?: string
        },
        Update: {
          id?: string
          establishment_id?: string
          username?: string
          auth_user_id?: string | null
          pin?: string | null
          role?: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active?: boolean
          created_at?: string
          updated_at?: string
        },
      },
        Row: {
          id: string
          created_at: string
          updated_at: string
          establishment_id: string
          requested_by: string
          request_type: 'new_qr' | 'qr_replacement' | 'qr_update' | 'qr_deactivation' | 'bulk_qr_generation' | 'qr_customization' | 'technical_issue'
          table_number: number | null
          title: string
          description: string | null
          priority: 'low' | 'medium' | 'high' | 'urgent'
          status: 'pending' | 'in_progress' | 'completed' | 'cancelled' | 'rejected'
          assigned_to: string | null
          resolved_at: string | null
          resolved_by: string | null
          resolution_notes: string | null
          attachments: Json
          internal_notes: string | null
          estimated_completion: string | null
        },
        Insert: {
          id?: string
          created_at?: string
          updated_at?: string
          establishment_id: string
          requested_by: string
          request_type: 'new_qr' | 'qr_replacement' | 'qr_update' | 'qr_deactivation' | 'bulk_qr_generation' | 'qr_customization' | 'technical_issue'
          table_number?: number | null
          title: string
          description?: string | null
          priority?: 'low' | 'medium' | 'high' | 'urgent'
          status?: 'pending' | 'in_progress' | 'completed' | 'cancelled' | 'rejected'
          assigned_to?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          resolution_notes?: string | null
          attachments?: Json
          internal_notes?: string | null
          estimated_completion?: string | null
        },
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          establishment_id?: string
          requested_by?: string
          request_type?: 'new_qr' | 'qr_replacement' | 'qr_update' | 'qr_deactivation' | 'bulk_qr_generation' | 'qr_customization' | 'technical_issue'
          table_number?: number | null
          title?: string
          description?: string | null
          priority?: 'low' | 'medium' | 'high' | 'urgent'
          status?: 'pending' | 'in_progress' | 'completed' | 'cancelled' | 'rejected'
          assigned_to?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          resolution_notes?: string | null
          attachments?: Json
          internal_notes?: string | null
          estimated_completion?: string | null
        },
      },
      staff: {
        Row: {
          id: string
          establishment_id: string
          username: string
          auth_user_id: string | null
          pin: string | null
          role: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active: boolean
          created_at: string
          updated_at: string
        },
        Insert: {
          id?: string
          establishment_id: string
          username: string
          auth_user_id?: string | null
          pin?: string | null
          role?: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active?: boolean
          created_at?: string
          updated_at?: string
        },
        Update: {
          id?: string
          establishment_id?: string
          username?: string
          auth_user_id?: string | null
          pin?: string | null
          role?: 'manager' | 'staff' | 'waiter' | 'kitchen'
          is_active?: boolean
          created_at?: string
          updated_at?: string
        },
      },
    },
    Functions: {
      get_restaurant_dashboard_kpis: {
        Args: {
          establishment_uuid: string
        },
        Returns: {
          qr_scans_today: number
          conversion_rate: number
          avg_qr_order_value: number
          customer_satisfaction: {
            average_rating: number
            total_reviews: number
          },
          avg_time_per_scan: number
          total_orders_today: number
          scans_growth: number
        },
      },
    },
  }
}