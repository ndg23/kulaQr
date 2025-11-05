import { ref, computed } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

interface QrSupportRequest {
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
  attachments: any[]
  internal_notes: string | null
  estimated_completion: string | null
  establishment?: { name: string; slug: string }
  requested_by_user?: { full_name: string }
  assigned_to_user?: { full_name: string }
  resolved_by_user?: { full_name: string }
}

interface QrSupportRequestInsert {
  establishment_id: string
  requested_by: string
  request_type: QrSupportRequest['request_type']
  table_number?: number | null
  title: string
  description?: string | null
  priority?: QrSupportRequest['priority']
  attachments?: any[]
}

interface QrSupportRequestUpdate {
  request_type?: QrSupportRequest['request_type']
  table_number?: number | null
  title?: string
  description?: string | null
  priority?: QrSupportRequest['priority']
  status?: QrSupportRequest['status']
  assigned_to?: string | null
  resolution_notes?: string | null
  internal_notes?: string | null
  estimated_completion?: string | null
}

export const useQrSupport = () => {
  const { client: supabase } = useSupabaseWrapper()
  const { showToast } = useCustomToast()

  const loading = ref(false)
  const requests = ref<QrSupportRequest[]>([])

  // Get all support requests for current user's establishments
  const fetchRequests = async (establishmentId?: string) => {
    loading.value = true
    try {
      let query = supabase
        .from('qr_support_requests')
        .select(`
          *
        `)
        .order('created_at', { ascending: false })

      if (establishmentId) {
        query = query.eq('establishment_id', establishmentId)
      }

      const { data, error } = await query

      if (error) throw error
      requests.value = data || []
    } catch (error) {
      console.error('Error fetching QR support requests:', error)
      showToast.error('Erreur', 'Impossible de charger les demandes de support')
    } finally {
      loading.value = false
    }
  }

  // Create a new support request
  const createRequest = async (requestData: QrSupportRequestInsert) => {
    loading.value = true
    try {
      const { data, error } = await supabase
        .from('qr_support_requests')
        .insert(requestData)
        .select()
        .single()

      if (error) throw error

      requests.value.unshift(data)
      showToast.success('Demande créée', 'Votre demande de support a été envoyée')

      return data
    } catch (error) {
      console.error('Error creating QR support request:', error)
      showToast.error('Erreur', 'Impossible de créer la demande de support')
      throw error
    } finally {
      loading.value = false
    }
  }

  // Update a support request
  const updateRequest = async (id: string, updates: QrSupportRequestUpdate) => {
    loading.value = true
    try {
      const { data, error } = await supabase
        .from('qr_support_requests')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (error) throw error

      // Update local state
      const index = requests.value.findIndex(r => r.id === id)
      if (index !== -1) {
        requests.value[index] = data
      }

      showToast.success('Demande mise à jour', 'Les modifications ont été enregistrées')

      return data
    } catch (error) {
      console.error('Error updating QR support request:', error)
      showToast.error('Erreur', 'Impossible de mettre à jour la demande')
      throw error
    } finally {
      loading.value = false
    }
  }

  // Cancel a support request
  const cancelRequest = async (id: string, reason?: string) => {
    return updateRequest(id, {
      status: 'cancelled',
      resolution_notes: reason || 'Annulé par l\'utilisateur'
    })
  }

  // Get support request statistics
  const getStats = async (establishmentId?: string) => {
    try {
      const { data, error } = await supabase.rpc('get_qr_support_stats', {
        establishment_uuid: establishmentId
      })

      if (error) throw error
      return data[0]
    } catch (error) {
      console.error('Error fetching QR support stats:', error)
      return null
    }
  }

  // Computed properties
  const pendingRequests = computed(() =>
    requests.value.filter(r => r.status === 'pending')
  )

  const inProgressRequests = computed(() =>
    requests.value.filter(r => r.status === 'in_progress')
  )

  const completedRequests = computed(() =>
    requests.value.filter(r => r.status === 'completed')
  )

  const urgentRequests = computed(() =>
    requests.value.filter(r => r.priority === 'urgent' && !['completed', 'cancelled', 'rejected'].includes(r.status))
  )

  return {
    // State
    loading,
    requests,

    // Computed
    pendingRequests,
    inProgressRequests,
    completedRequests,
    urgentRequests,

    // Methods
    fetchRequests,
    createRequest,
    updateRequest,
    cancelRequest,
    getStats
  }
}