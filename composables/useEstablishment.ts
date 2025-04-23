import { ref, computed } from 'vue'
import { useSupabaseWrapper } from './useSupabase'
import { useCustomToast } from './useToast'
import type { Establishment } from '~/types'

export const useEstablishment = () => {
  const { client: supabase } = useSupabaseWrapper()
  // const toast = useToast()
  const user = useSupabaseUser()
  const establishment = ref<Establishment | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)
  const {showToast} = useCustomToast()
  // Get establishment by slug
  const fetchEstablishmentBySlug = async (slug: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: err } = await supabase
        .from('establishments')
        .select('*')
        .eq('id', slug)
        .single()
      
      if (err) throw err
      establishment.value = data
      
      // Store in localStorage for persistence
      if (process.client && data) {
        localStorage.setItem('current_establishment', JSON.stringify(data))
      }
      
      return data
    } catch (err) {
      console.error('Error fetching establishment by slug:', err)
      error.value = err as Error
      return null
    } finally {
      loading.value = false
    }
  }

  // Get establishment by user ID
  const fetchEstablishmentByUserId = async () => {
    if (!user.value?.id) {
      console.warn('No authenticated user found')
      return null
    }
    
    loading.value = true
    error.value = null
    
    try {
      // First try to get from localStorage for immediate display
      if (process.client) {
        const cached = localStorage.getItem('current_establishment')
        if (cached) {
          const parsed = JSON.parse(cached)
          if (parsed.user_id === user.value.id) {
            establishment.value = parsed
          }
        }
      }
      
      // Then fetch fresh data from the server
      const { data, error: err } = await supabase
        .from('establishments')
        .select('*')
        .eq('user_id', user.value.id)
        .single()
      
      if (err) {
        if (err.code === 'PGRST116') {
          // No establishment found for this user
          console.warn('No establishment found for user:', user.value.id)
          return null
        }
        throw err
      }
      
      establishment.value = data
      
      // Update localStorage
      if (process.client && data) {
        localStorage.setItem('current_establishment', JSON.stringify(data))
      }
      
      return data
    } catch (err) {
      console.error('Error fetching establishment by user ID:', err)
      error.value = err as Error
      return null
    } finally {
      loading.value = false
    }
  }

  // Create a new establishment
  const createEstablishment = async (establishmentData: Partial<Establishment>) => {
    if (!user.value?.id) {
      throw new Error('User must be authenticated to create an establishment')
    }
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: err } = await supabase
        .from('establishments')
        .insert({
          ...establishmentData,
          user_id: user.value.id,
          is_active: true
        })
        .select()
        .single()
      
      if (err) throw err
      showToast.success('Succès', 'Restaurant créé avec succès')  
      establishment.value = data
      
      // Store in localStorage
      if (process.client) {
        localStorage.setItem('current_establishment', JSON.stringify(data))
      }
      
      return data
    } catch (err) {
      showToast.error('Erreur', 'Une erreur est survenue lors de la création du restaurant')
      console.error('Error creating establishment:', err)
      error.value = err as Error
      throw err
    } finally {
      loading.value = false
    }
  }

  // Update an establishment
  const updateEstablishment = async (id: string, updates: Partial<Establishment>) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: err } = await supabase
        .from('establishments')
        .update(updates)
        .eq('id', id)
        .select()
        .single()
      
      if (err) throw err
      showToast.success('Succès', 'Restaurant mis à jour avec succès')
      establishment.value = data
      
      // Update localStorage
      if (process.client) {
        localStorage.setItem('current_establishment', JSON.stringify(data))
      }
      
      return data
    } catch (err) {
      showToast.error('Erreur', 'Une erreur est survenue lors de la mise à jour du restaurant')
      console.error('Error updating establishment:', err)
      error.value = err as Error
      throw err
    } finally {
      loading.value = false
    }
  }

  // Clear establishment data (for logout)
  const clearEstablishment = () => {
    establishment.value = null
    if (process.client) {
      localStorage.removeItem('current_establishment')
    }
  }

  // Restore establishment from localStorage on page load/refresh
  const restoreEstablishment = () => {
    if (process.client) {
      const cached = localStorage.getItem('current_establishment')
      if (cached) {
        try {
          establishment.value = JSON.parse(cached)
        } catch (err) {
          console.error('Error parsing cached establishment:', err)
          localStorage.removeItem('current_establishment')
        }
      }
    }
  }

  // Initialize on module load
  if (process.client) {
    restoreEstablishment()
  }

  return {
    establishment,
    loading,
    error,
    fetchEstablishmentBySlug,
    fetchEstablishmentByUserId,
    createEstablishment,
    updateEstablishment,
    clearEstablishment,
    restoreEstablishment
  }
} 