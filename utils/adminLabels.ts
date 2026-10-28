// Libellés et pastilles partagés par les pages de formulaire du back-office.
// Les classes sont écrites en entier pour que Tailwind les détecte.

export const ROLE_OPTIONS = [
  { value: 'admin', label: 'Administrateur' },
  { value: 'owner', label: 'Propriétaire' },
  { value: 'manager', label: 'Manager' },
  { value: 'staff', label: 'Staff' }
]

export const TIER_OPTIONS = [
  { value: 'demo', label: 'Démo (7 jours)' },
  { value: 'pro', label: 'Pro (30 jours)' },
  { value: 'premium', label: 'Premium (90 jours)' }
]

export const SUBSCRIPTION_STATUS_OPTIONS = [
  { value: 'active', label: 'Actif' },
  { value: 'pending_activation', label: "En attente d'activation" },
  { value: 'expired', label: 'Expiré' },
  { value: 'cancelled', label: 'Annulé' },
  { value: 'suspended', label: 'Suspendu' }
]

const labelFrom = (options: { value: string, label: string }[], value?: string | null) =>
  options.find(o => o.value === value)?.label || value || '—'

export const roleLabel = (role?: string | null) => labelFrom(ROLE_OPTIONS, role)
export const tierLabel = (tier?: string | null) =>
  ({ demo: 'Démo', pro: 'Pro', premium: 'Premium', free: 'Gratuit' } as Record<string, string>)[tier || ''] || tier || '—'
export const subscriptionStatusLabel = (status?: string | null) =>
  ({ active: 'Actif', pending_activation: 'En attente', expired: 'Expiré', cancelled: 'Annulé', suspended: 'Suspendu' } as Record<string, string>)[status || ''] || status || '—'

// Pastilles pleines (rounded-full) : fond teinté + encre noire, contraste vérifié par la palette
export const roleBadgeClass = (role?: string | null) =>
  ({
    admin: 'bg-[#EFEAFF] text-[#4B2FCC]',
    owner: 'bg-[#FFEBD6] text-[#8A3F00]',
    manager: 'bg-[#E8EEFF] text-[#1741B8]',
    staff: 'bg-[#D6FBE6] text-[#00632F]'
  } as Record<string, string>)[role || ''] || 'bg-gray-100 text-gray-800'

export const tierBadgeClass = (tier?: string | null) =>
  ({
    demo: 'bg-[#E8EEFF] text-[#1741B8]',
    pro: 'bg-[#D6FBE6] text-[#00632F]',
    premium: 'bg-[#EFEAFF] text-[#4B2FCC]'
  } as Record<string, string>)[tier || ''] || 'bg-gray-100 text-gray-800'

export const subscriptionStatusBadgeClass = (status?: string | null) =>
  ({
    active: 'bg-[#D6FBE6] text-[#00632F]',
    pending_activation: 'bg-[#FFF9C2] text-[#6B5B00]',
    expired: 'bg-[#FFE0F0] text-[#A10054]',
    cancelled: 'bg-gray-100 text-gray-700',
    suspended: 'bg-[#FFEBD6] text-[#8A3F00]'
  } as Record<string, string>)[status || ''] || 'bg-gray-100 text-gray-700'
