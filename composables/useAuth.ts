import { ref, onMounted, onUnmounted } from 'vue'
import { useState } from '#app'
import { useSupabaseClient } from '#imports'

export interface UserMetadata {
  avatar_url?: string
  full_name?: string
}

export interface User {
  id: string
  email?: string
  user_metadata: UserMetadata
  app_metadata: any
  aud: string
  created_at: string
}

export const useAuth = () => {
  const user = useState('user', () => null)
  const isLoading = useState('auth_loading', () => true)
  const supabase = useSupabaseClient()
  const error = ref<string | null>(null)

  // Initialiser la session au démarrage
  const initSession = async () => {
    try {
      isLoading.value = true
      const { data: { session }, error: err } = await supabase.auth.getSession()
      if (err) throw err
      user.value = session?.user || null
    } catch (err) {
      console.error('Error loading session:', err)
      user.value = null
    } finally {
      isLoading.value = false
    }
  }

  // Écouter les changements de session
  onMounted(() => {
    initSession()
    
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      user.value = session?.user || null
      isLoading.value = false
    })

    onUnmounted(() => {
      subscription.unsubscribe()
    })
  })

  // Récupérer l'utilisateur courant
  const getCurrentUser = async () => {
    try {
      isLoading.value = true
      const { data: { user: currentUser }, error: err } = await supabase.auth.getUser()
      console.log(currentUser)
      if (err) throw err
      user.value = currentUser
      return currentUser
    } catch (err) {
      console.error('Erreur lors de la récupération de l\'utilisateur:', err)
      error.value = 'Impossible de récupérer les informations utilisateur'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Connexion avec email/password
  const login = async (email: string, password: string) => {
    try {
      isLoading.value = true
      error.value = null

      const { data, error: err } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (err) throw err

      user.value = data.user
      return data
    } catch (err) {
      console.error('Erreur de connexion:', err)
      error.value = 'Email ou mot de passe incorrect'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Connexion avec code PIN
  const loginWithPin = async (pin: string, establishmentId: string) => {
    try {
      isLoading.value = true
      error.value = null

      // Vérifier le PIN dans la table staff
      const { data, error: err } = await supabase
        .from('staff')
        .select('*')
        .eq('pin', pin)
        .eq('establishment_id', establishmentId)
        .single()

      if (err) throw err
      if (!data) throw new Error('PIN invalide')

      // Créer une session pour le staff
      const { data: sessionData, error: sessionError } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: pin // Utiliser le PIN comme mot de passe temporaire
      })

      if (sessionError) throw sessionError

      user.value = sessionData.user
      return sessionData
    } catch (err) {
      console.error('Erreur de connexion PIN:', err)
      error.value = 'PIN invalide'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Déconnexion
  const logout = async () => {
    try {
      isLoading.value = true
      error.value = null
      
      const { error: err } = await supabase.auth.signOut()
      if (err) throw err

      user.value = null
    } catch (err) {
      console.error('Erreur de déconnexion:', err)
      error.value = 'Impossible de se déconnecter'
    } finally {
      isLoading.value = false
    }
  }

  // Mise à jour du profil
  const updateProfile = async (profile: Partial<UserMetadata>) => {
    try {
      isLoading.value = true
      error.value = null

      const { data, error: err } = await supabase.auth.updateUser({
        data: profile
      })

      if (err) throw err

      user.value = data.user
      return data.user
    } catch (err) {
      console.error('Erreur de mise à jour du profil:', err)
      error.value = 'Impossible de mettre à jour le profil'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Initialiser l'état de l'authentification
  const initialize = async () => {
    const currentUser = await getCurrentUser()
    if (currentUser) {
      user.value = currentUser
    }
  }

  return {
    user,
    isLoading,
    error,
    login,
    loginWithPin,
    logout,
    updateProfile,
    getCurrentUser,
    initialize
  }
} 