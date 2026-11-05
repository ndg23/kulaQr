// État partagé de l'espace du personnel (connecté par PIN) : le membre, l'établissement, les commandes en temps réel.
// Il vit dans le layout /staff : toutes les pages (commandes, aujourd'hui) lisent la même liste, sans recharger.
import { useSupabaseWrapper } from '~/composables/useSupabase'
import { useCustomToast } from '~/composables/useToast'

export const STATUS_LABEL: Record<string, string> = {
  pending: 'À accepter',
  confirmed: 'À préparer',
  processing: 'En préparation',
  completed: 'Terminée',
  cancelled: 'Annulée'
}

// Étape suivante d'une commande : le libellé du bouton principal et le statut visé
export const NEXT_STEP: Record<string, { label: string, to: string } | undefined> = {
  pending: { label: 'Accepter', to: 'confirmed' },
  confirmed: { label: 'Lancer la préparation', to: 'processing' },
  processing: { label: 'Terminer', to: 'completed' }
}

export const ROLE_LABEL: Record<string, string> = {
  manager: 'Gérant',
  waiter: 'Serveur',
  kitchen: 'Cuisine',
  cashier: 'Caissier'
}

let channel: any = null
let poll: ReturnType<typeof setInterval> | null = null
let reloadTimer: ReturnType<typeof setTimeout> | null = null
let started = false

export const useStaffSpace = () => {
  const { client: supabase } = useSupabaseWrapper()
  const { showToast } = useCustomToast()

  const staff = useState<any | null>('staff.me', () => null)
  const establishment = useState<any | null>('staff.establishment', () => null)
  const orders = useState<any[]>('staff.orders', () => [])
  const loading = useState<boolean>('staff.loading', () => true)
  const loadError = useState<boolean>('staff.loadError', () => false)
  const connected = useState<boolean>('staff.connected', () => false)
  /** Commandes arrivées il y a quelques secondes : la carte clignote en orange */
  const fresh = useState<string[]>('staff.fresh', () => [])
  const soundOn = useState<boolean>('staff.sound', () => true)
  const autoPrint = useState<boolean>('staff.autoPrint', () => false)

  const SOUND_KEY = 'staff.sound'
  const PRINT_KEY = 'staff.autoPrint'

  const readSession = () => {
    try { return JSON.parse(localStorage.getItem('staff_session') || 'null') } catch { return null }
  }

  /** Le jeton est vérifié côté base : session valide, non expirée, compte toujours actif */
  const checkSession = async () => {
    const session = readSession()
    if (!session || session.auth_type !== 'pin') return null
    try {
      if (session.token) {
        const { data, error } = await (supabase as any).rpc('staff_session_info', { p_token: session.token })
        if (!error && data) return data
      } else if (session.staff_id) {
        const { data, error } = await supabase
          .from('staff')
          .select('id, username, full_name, role, establishment_id')
          .eq('id', session.staff_id)
          .eq('is_active', true)
          .maybeSingle()
        if (!error && data) return data
      }
    } catch { /* session invalide ci-dessous */ }
    localStorage.removeItem('staff_session')
    return null
  }

  const SELECT = `
    *,
    tables ( id, table_number, type, section_name, floor_level, capacity, location_description ),
    staff:staff_id ( id, username ),
    items:order_items ( id, quantity, unit_price, notes, products ( id, name, description, price ) )
  `

  const decorate = (rows: any[]) => {
    // N° du jour : 001, 002… dans l'ordre d'arrivée (stable, contrairement à la position dans la liste)
    const byDay = new Map<string, number>()
    const numbers = new Map<string, string>()
    ;[...rows].sort((a, b) => +new Date(a.created_at) - +new Date(b.created_at)).forEach((o) => {
      const day = new Date(o.created_at).toDateString()
      const n = (byDay.get(day) || 0) + 1
      byDay.set(day, n)
      numbers.set(o.id, String(n).padStart(3, '0'))
    })
    return rows.map(o => ({
      ...o,
      orderNumber: numbers.get(o.id),
      items: (o.items || []).map((i: any) => ({ ...i, name: i.products?.name || 'Produit' }))
    }))
  }

  const notifyArrivals = (previous: Set<string>, next: any[]) => {
    if (!previous.size) return // premier chargement : rien n'est « nouveau »
    const arrived = next.filter(o => !previous.has(o.id) && o.status === 'pending')
    if (!arrived.length) return
    fresh.value = [...fresh.value, ...arrived.map(o => o.id)]
    setTimeout(() => { fresh.value = fresh.value.filter(id => !arrived.some(o => o.id === id)) }, 8000)
    const o = arrived[0]
    const where = o.tables?.table_number || o.table_number
    showToast.success('Nouvelle commande', where ? `Table ${where}` : 'À emporter')
    if (soundOn.value) {
      new Audio('/sounds/new-order.mp3').play().catch(() => { /* autoplay bloqué : le clignotement suffit */ })
    }
    if (autoPrint.value) arrived.forEach(order => printTicket(order, establishment.value?.name || ''))
  }

  const load = async (silent = false) => {
    if (!establishment.value?.id) return
    if (!silent) loading.value = true
    try {
      let data: any[] | null = null
      const token = readSession()?.token

      // Le personnel (PIN) lit par une fonction SQL : sans elle il ne voit pas les articles (bdd/staff_list_orders.sql)
      if (token) {
        const res = await (supabase as any).rpc('staff_list_orders', { p_token: token, p_limit: 150 })
        if (!res.error) data = res.data || []
        else if (res.error.code === '28000') {
          localStorage.removeItem('staff_session')
          await navigateTo('/auth/pin')
          return
        } else if (!(res.error.code === 'PGRST202' || res.error.code === '42883' || /could not find the function/i.test(res.error.message || ''))) {
          throw res.error
        }
      }

      // Ancien chemin (fonction pas encore installée, ou session sans jeton)
      if (data === null) {
        const res = await supabase
          .from('orders')
          .select(SELECT)
          .eq('establishment_id', establishment.value.id)
          .order('created_at', { ascending: false })
          .limit(150)
        if (res.error) throw res.error
        data = res.data || []
      }

      const previous = new Set<string>(orders.value.map(o => o.id))
      const next = decorate(data)
      notifyArrivals(previous, next)
      orders.value = next
      loadError.value = false
    } catch (e) {
      console.error('Chargement des commandes :', e)
      if (!silent || !orders.value.length) loadError.value = true
    } finally {
      loading.value = false
    }
  }

  const scheduleReload = () => {
    if (reloadTimer) clearTimeout(reloadTimer)
    reloadTimer = setTimeout(() => load(true), 300)
  }

  const subscribe = () => {
    if (channel) channel.unsubscribe()
    channel = supabase
      .channel(`staff-orders-${establishment.value.id}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'orders', filter: `establishment_id=eq.${establishment.value.id}` }, scheduleReload)
      .subscribe((status: string) => { connected.value = status === 'SUBSCRIBED' })
  }

  /** À appeler une fois, depuis le layout */
  const start = async () => {
    if (started) return
    started = true
    try { soundOn.value = localStorage.getItem(SOUND_KEY) !== '0' } catch { /* confort seulement */ }
    try { autoPrint.value = localStorage.getItem(PRINT_KEY) === '1' } catch { /* confort seulement */ }

    const me = await checkSession()
    if (!me) {
      started = false
      await navigateTo('/auth/pin')
      return
    }
    staff.value = me
    const { data: est } = await supabase.from('establishments').select('id, name, currency').eq('id', me.establishment_id).maybeSingle()
    establishment.value = est || { id: me.establishment_id, name: '' }
    await load()
    subscribe()
    // Filet de sécurité si le temps réel décroche : on relit toutes les 20 s
    poll = setInterval(() => { if (!connected.value) load(true) }, 20000)
  }

  const stop = () => {
    started = false
    if (channel) { channel.unsubscribe(); channel = null }
    if (poll) { clearInterval(poll); poll = null }
    if (reloadTimer) { clearTimeout(reloadTimer); reloadTimer = null }
  }

  /** Change le statut ; renvoie true si la commande a bien avancé */
  const setStatus = async (orderId: string, status: string) => {
    const session = readSession()
    try {
      if (session?.token) {
        // La base vérifie la session, l'établissement et la transition de statut
        const { data: ok, error } = await (supabase as any).rpc('staff_set_order_status', { p_token: session.token, p_order_id: orderId, p_status: status })
        if (error) throw error
        if (!ok) {
          showToast.error('Déjà mise à jour', 'Un collègue a déjà fait avancer cette commande')
          await load(true)
          return false
        }
      } else {
        const expected = status === 'confirmed' ? 'pending' : status === 'processing' ? 'confirmed' : 'processing'
        const patch: any = { status, updated_at: new Date().toISOString() }
        if (status === 'confirmed' || status === 'processing') patch.staff_id = staff.value?.id
        const { data: rows, error } = await (supabase as any).from('orders').update(patch).eq('id', orderId).eq('status', expected).select('id')
        if (error) throw error
        if (!rows?.length) {
          showToast.error('Déjà mise à jour', 'Un collègue a déjà fait avancer cette commande')
          await load(true)
          return false
        }
      }
      // Mise à jour locale immédiate : l'écran réagit avant le retour du temps réel
      orders.value = orders.value.map(o => o.id === orderId ? { ...o, status, staff_id: ['confirmed', 'processing'].includes(status) ? staff.value?.id : o.staff_id, staff: ['confirmed', 'processing'].includes(status) ? { id: staff.value?.id, username: staff.value?.username } : o.staff } : o)
      return true
    } catch (e) {
      console.error('Changement de statut :', e)
      showToast.error('Erreur', 'Impossible de mettre à jour la commande')
      return false
    }
  }

  const toggleSound = () => {
    soundOn.value = !soundOn.value
    try { localStorage.setItem(SOUND_KEY, soundOn.value ? '1' : '0') } catch { /* confort seulement */ }
  }
  const toggleAutoPrint = () => {
    autoPrint.value = !autoPrint.value
    try { localStorage.setItem(PRINT_KEY, autoPrint.value ? '1' : '0') } catch { /* confort seulement */ }
  }

  const logout = async () => {
    const session = readSession()
    try { if (session?.token) await (supabase as any).rpc('staff_logout', { p_token: session.token }) } catch { /* on déconnecte quand même */ }
    localStorage.removeItem('staff_session')
    stop()
    staff.value = null
    orders.value = []
    await navigateTo('/auth/pin')
  }

  return {
    staff, establishment, orders, loading, loadError, connected, fresh, soundOn, autoPrint,
    start, stop, load, setStatus, toggleSound, toggleAutoPrint, logout
  }
}

/** Minutes écoulées depuis la commande (pour la couleur d'urgence) */
export const ageMinutes = (createdAt: string, now = Date.now()) =>
  Math.max(0, Math.floor((now - new Date(createdAt).getTime()) / 60000))

export const ageLabel = (createdAt: string, now = Date.now()) => {
  const m = ageMinutes(createdAt, now)
  if (m < 1) return "À l'instant"
  if (m < 60) return `${m} min`
  const h = Math.floor(m / 60)
  return `${h} h ${String(m % 60).padStart(2, '0')}`
}
