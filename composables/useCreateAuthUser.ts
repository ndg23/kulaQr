import { createClient } from '@supabase/supabase-js'

/**
 * Crée un compte d'authentification sans toucher à la session de l'administrateur connecté.
 * Un signUp sur le client principal remplacerait la session courante par celle du nouveau compte :
 * on utilise donc un client jetable qui ne persiste rien.
 * Le trigger d'inscription crée la ligne `users` ; l'appelant la complète ensuite (droits admin).
 */
export const useCreateAuthUser = () => {
  const config = useRuntimeConfig()

  return async (params: { email: string; password: string; fullName: string; phone?: string }): Promise<string> => {
    const client = createClient(config.public.supabaseUrl as string, config.public.supabaseKey as string, {
      auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
    })
    const { data, error } = await client.auth.signUp({
      email: params.email.trim(),
      password: params.password,
      options: { data: { full_name: params.fullName.trim(), phone: params.phone?.trim() || undefined } }
    })
    if (error) throw error
    if (!data.user?.id) throw new Error("Le compte n'a pas pu être créé")
    return data.user.id
  }
}
