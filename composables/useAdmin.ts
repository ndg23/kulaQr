import { useSupabaseUser, useSupabaseClient } from '#imports'

export const useAdmin = () => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()
  const loading = ref(false)
  const adminData = ref(null)
  const error = ref(null)

  const fetchAdminData = async () => {
    if (!user.value?.id) return null

    try {
      loading.value = true
      const { data, error: err } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.value.id)
        .eq('role', 'admin')
        .single()

      if (err) throw err
      
      adminData.value = data
      return data
    } catch (err) {
      console.error('Error fetching admin data:', err)
      error.value = err.message
      return null
    } finally {
      loading.value = false
    }
  }

  const checkAdminAccess = async () => {
    const data = await fetchAdminData()
    if (!data) {
      throw createError({
        statusCode: 403,
        message: 'Accès non autorisé'
      })
    }
    return data
  }

  return {
    user,
    adminData,
    loading,
    error,
    fetchAdminData,
    checkAdminAccess
  }
}