import { ref } from 'vue'
import type { Database } from '~/types/database'
import { useCustomToast } from './useToast'
export const useSupabaseWrapper = () => {
  const client = useSupabaseClient<Database>()
  const loading = ref(false)
  const error = ref<string | null>(null)
  // const toast = useToast()
    const {showToast} = useCustomToast()
  const handleError = (err: any) => {
    console.error(err)
    const errorMessage = err.message || 'Une erreur est survenue'
    error.value = errorMessage
    showToast.error(errorMessage)
  }

  const clearError = () => {
    error.value = null
  }

  const withLoading = async <T>(fn: () => Promise<T>): Promise<T | null> => {
    try {
      loading.value = true
      clearError()
      return await fn()
    } catch (err: any) {
      handleError(err)
      return null
    } finally {
      loading.value = false
    }
  }

  return {
    client,
    loading,
    error,
    clearError,
    withLoading
  }
}

export const useEstablishment = () => {
  const { client } = useSupabaseWrapper()

  const getEstablishment = async (id: string) => {
    const { data, error } = await client
      .from('establishments')
      .select(`
        *,
        categories:categories(
          *,
          products:products(*)
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error
    return data
  }

  const createEstablishment = async (establishment: any) => {
    const { data, error } = await client
      .from('establishments')
      .insert(establishment)
      .select()
      .single()

    if (error) throw error
    return data
  }

  return {
    getEstablishment,
    createEstablishment
  }
}

export const useOrders = () => {
  const { client } = useSupabaseWrapper()

  const createOrder = async (order: any) => {
    const { data, error } = await client
      .from('orders')
      .insert(order)
      .select()
      .single()

    if (error) throw error
    return data
  }

  const getOrder = async (id: string) => {
    const { data, error } = await client
      .from('orders')
      .select('*')
      .eq('id', id)
      .single()

    if (error) throw error
    return data
  }

  return {
    createOrder,
    getOrder
  }
} 