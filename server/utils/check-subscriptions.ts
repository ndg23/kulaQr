import { createClient } from '@supabase/supabase-js'

// Configuration Supabase
const supabaseUrl = process.env.SUPABASE_URL || ''
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || ''

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables')
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

/**
 * Vérifie et bloque automatiquement les abonnements expirés
 * Cette fonction doit être appelée quotidiennement via un cron job
 */
export async function checkExpiredSubscriptions() {
  try {
    console.log('🔍 Vérification des abonnements expirés...')
    console.log('Heure:', new Date().toISOString())

    // Appeler la fonction PostgreSQL qui gère tout
    const { data, error } = await supabase.rpc('check_and_block_expired_subscriptions')

    if (error) {
      console.error('❌ Erreur lors de la vérification des abonnements:', error)
      throw error
    }

    console.log('✅ Résultat de la vérification:', data)
    console.log(`📊 ${data.blocked_users} utilisateur(s) bloqué(s)`)
    console.log(`⚠️  ${data.expiring_soon} abonnement(s) expire(nt) bientôt`)

    // Envoyer une notification email aux admins si des utilisateurs ont été bloqués
    if (data.blocked_users > 0) {
      await notifyAdmins(data)
    }

    return data
  } catch (error) {
    console.error('💥 Erreur critique:', error)
    throw error
  }
}

/**
 * Récupère les utilisateurs qui vont expirer bientôt
 */
export async function getExpiringSubscriptions(daysBeforeExpiry: number = 2) {
  try {
    const { data, error } = await supabase.rpc('get_expiring_subscriptions', {
      days_before: daysBeforeExpiry
    })

    if (error) throw error

    return data
  } catch (error) {
    console.error('Erreur lors de la récupération des abonnements expirants:', error)
    throw error
  }
}

/**
 * Réactive un utilisateur et prolonge son abonnement
 */
export async function reactivateUserSubscription(
  userId: string,
  subscriptionTier: 'demo' | 'pro' | 'premium',
  durationDays: number
) {
  try {
    const { data, error } = await supabase.rpc('reactivate_user_subscription', {
      p_user_id: userId,
      p_subscription_tier: subscriptionTier,
      p_duration_days: durationDays
    })

    if (error) throw error

    console.log(`✅ Utilisateur ${userId} réactivé avec abonnement ${subscriptionTier} pour ${durationDays} jours`)
    return data
  } catch (error) {
    console.error('Erreur lors de la réactivation:', error)
    throw error
  }
}

/**
 * Obtient les statistiques des abonnements
 */
export async function getSubscriptionStats() {
  try {
    const { data, error } = await supabase
      .from('subscription_stats')
      .select('*')

    if (error) throw error

    return data
  } catch (error) {
    console.error('Erreur lors de la récupération des stats:', error)
    throw error
  }
}

/**
 * Récupère les notifications non lues pour les admins
 */
export async function getAdminNotifications(unreadOnly: boolean = true) {
  try {
    let query = supabase
      .from('admin_notifications')
      .select('*')
      .order('created_at', { ascending: false })

    if (unreadOnly) {
      query = query.eq('is_read', false)
    }

    const { data, error } = await query

    if (error) throw error

    return data
  } catch (error) {
    console.error('Erreur lors de la récupération des notifications:', error)
    throw error
  }
}

/**
 * Marque une notification comme lue
 */
export async function markNotificationAsRead(notificationId: string) {
  try {
    const { error } = await supabase
      .from('admin_notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .eq('id', notificationId)

    if (error) throw error

    return true
  } catch (error) {
    console.error('Erreur lors du marquage de la notification:', error)
    throw error
  }
}

/**
 * Envoie une notification aux administrateurs
 */
async function notifyAdmins(checkResult: any) {
  try {
    // Récupérer tous les admins
    const { data: admins, error } = await supabase
      .from('users')
      .select('email, full_name')
      .eq('role', 'admin')
      .eq('is_active', true)

    if (error) throw error

    console.log(`📧 Notification de ${admins.length} administrateur(s)...`)

    // TODO: Implémenter l'envoi d'emails
    // Pour l'instant, on log juste
    console.log('Admins à notifier:', admins.map(a => a.email).join(', '))
    console.log('Contenu:', checkResult.message)

    return true
  } catch (error) {
    console.error('Erreur lors de la notification des admins:', error)
    return false
  }
}

/**
 * Fonction principale à exécuter quotidiennement
 */
export async function dailySubscriptionCheck() {
  console.log('='.repeat(60))
  console.log('🚀 DÉMARRAGE DU CONTRÔLE QUOTIDIEN DES ABONNEMENTS')
  console.log('='.repeat(60))

  try {
    // 1. Vérifier et bloquer les abonnements expirés
    const result = await checkExpiredSubscriptions()

    // 2. Obtenir les statistiques
    const stats = await getSubscriptionStats()
    console.log('\n📊 STATISTIQUES DES ABONNEMENTS:')
    console.table(stats)

    // 3. Vérifier les abonnements qui expirent dans 2 jours
    const expiring = await getExpiringSubscriptions(2)
    if (expiring && expiring.length > 0) {
      console.log(`\n⚠️  ${expiring.length} ABONNEMENT(S) EXPIRE(NT) DANS 2 JOURS:`)
      console.table(expiring)
    }

    console.log('\n' + '='.repeat(60))
    console.log('✅ CONTRÔLE TERMINÉ AVEC SUCCÈS')
    console.log('='.repeat(60))

    return {
      success: true,
      result,
      stats,
      expiring
    }
  } catch (error) {
    console.log('\n' + '='.repeat(60))
    console.log('❌ ERREUR LORS DU CONTRÔLE')
    console.log('='.repeat(60))
    console.error(error)

    return {
      success: false,
      error
    }
  }
}

// Si ce fichier est exécuté directement (node check-subscriptions.ts)
if (require.main === module) {
  dailySubscriptionCheck()
    .then(() => {
      console.log('\n👋 Script terminé')
      process.exit(0)
    })
    .catch((error) => {
      console.error('💥 Erreur fatale:', error)
      process.exit(1)
    })
}
