import { useSupabaseWrapper } from '~/composables/useSupabase'

/**
 * Envoie une image dans le bucket « images » et renvoie son URL publique.
 * Les dossiers (categories, products, ...) rangent les fichiers par type.
 */
export const useImageUpload = () => {
  const { client: supabase } = useSupabaseWrapper()

  return async (file: File, folder: string): Promise<string> => {
    const ext = file.name.split('.').pop() || 'jpg'
    const path = `${folder}/${crypto.randomUUID()}.${ext}`
    const { error } = await supabase.storage.from('images').upload(path, file)
    if (error) throw error
    return supabase.storage.from('images').getPublicUrl(path).data.publicUrl
  }
}
