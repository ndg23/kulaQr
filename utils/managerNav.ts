import {
  Home,
  BookOpen,
  List,
  QrCode,
  Clock,
  Users,
  Settings
} from 'lucide-vue-next'
import type { Tone } from '~/utils/palette'

export interface ManagerNavItem {
  name: string
  /** Suffixe après /manager/<id> ('' = accueil) */
  suffix: string
  icon: any
  tone: Tone
  /** Actif seulement sur ce chemin exact (sinon aussi sur les sous-pages) */
  exact?: boolean
  /** Absent du menu mais utilisé pour l'icône et la couleur de l'en-tête de page */
  hidden?: boolean
}

// Même logique de couleurs que le back-office admin : vue d'ensemble jaune, catalogue bleu,
// flux orange, personnes violet, lieux et QR rose, réglages noir
export const MANAGER_NAV: ManagerNavItem[] = [
  { name: 'Accueil', suffix: '', icon: Home, tone: 'yellow', exact: true },
  { name: 'Menu', suffix: '/menu', icon: BookOpen, tone: 'blue' },
  { name: 'Catégories', suffix: '/categories', icon: List, tone: 'violet' },
  { name: 'QR Codes', suffix: '/tables', icon: QrCode, tone: 'pink' },
  { name: 'Commandes', suffix: '/orders', icon: Clock, tone: 'orange' },
  { name: 'Personnel', suffix: '/staff', icon: Users, tone: 'green' },
  { name: 'Paramètres', suffix: '/settings', icon: Settings, tone: 'black' },
  { name: 'Produits', suffix: '/products', icon: BookOpen, tone: 'blue', hidden: true },
  { name: 'Support QR', suffix: '/qr-support', icon: QrCode, tone: 'pink', hidden: true },
  { name: 'Partage', suffix: '/share', icon: QrCode, tone: 'pink', hidden: true },
  { name: 'Activité', suffix: '/activity-logs', icon: Clock, tone: 'black', hidden: true }
]

export const isManagerNavActive = (item: ManagerNavItem, base: string, path: string) => {
  const target = base + item.suffix
  return item.exact ? path === target : path === target || path.startsWith(target + '/')
}

/** Entrée correspondant à une URL : la plus spécifique gagne */
export const managerNavForPath = (base: string, path: string): ManagerNavItem =>
  [...MANAGER_NAV].reverse().find(item => !item.exact && isManagerNavActive(item, base, path)) || MANAGER_NAV[0]
