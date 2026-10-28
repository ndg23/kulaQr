import {
  LayoutDashboard,
  Store,
  Users,
  Settings,
  QrCode,
  ShoppingBag,
  CreditCard,
  Headphones
} from 'lucide-vue-next'
import type { Tone } from '~/utils/palette'

export interface AdminNavItem {
  name: string
  path: string
  icon: any
  tone: Tone
  /** Actif seulement sur ce chemin exact (sinon aussi sur les sous-pages) */
  exact?: boolean
  /** Absent du menu mais utilisé pour l'icône et la couleur de l'en-tête de page */
  hidden?: boolean
}

// Une couleur par fonction : vue d'ensemble jaune, lieux bleu, personnes violet, argent vert,
// flux orange, outils noir (même logique que xticket-office)
export const ADMIN_NAV: AdminNavItem[] = [
  { name: 'Accueil', path: '/admin', icon: LayoutDashboard, tone: 'yellow', exact: true },
  { name: 'Établissements', path: '/admin/establishments', icon: Store, tone: 'blue' },
  { name: 'Utilisateurs', path: '/admin/users', icon: Users, tone: 'violet' },
  { name: 'Abonnements', path: '/admin/subscriptions', icon: CreditCard, tone: 'green' },
  { name: 'Commandes', path: '/admin/orders', icon: ShoppingBag, tone: 'orange' },
  { name: 'QR Codes', path: '/admin/qr-codes', icon: QrCode, tone: 'pink' },
  { name: 'Paramètres', path: '/admin/settings', icon: Settings, tone: 'black' },
  { name: 'Demandes QR', path: '/admin/qr-support-requests', icon: Headphones, tone: 'pink', hidden: true },
  { name: 'Administrateurs', path: '/admin/admins', icon: Users, tone: 'violet', hidden: true }
]

export const isAdminNavActive = (item: AdminNavItem, path: string) =>
  item.exact ? path === item.path : path === item.path || path.startsWith(item.path + '/')

/** Entrée correspondant à une URL : la plus spécifique gagne */
export const adminNavForPath = (path: string): AdminNavItem =>
  [...ADMIN_NAV].reverse().find(item => !item.exact && isAdminNavActive(item, path)) || ADMIN_NAV[0]
