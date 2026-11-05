// Ticket de commande pour imprimante thermique (rouleau 80 mm), en police à chasse fixe.
// Utilisé par l'écran du personnel et par les commandes du manager.

export interface TicketItem {
  name?: string
  quantity?: number
  unit_price?: number
  notes?: string | null
}

export interface TicketOrder {
  orderNumber?: string | number
  created_at?: string
  table_number?: number | string | null
  tables?: { table_number?: number | string | null } | null
  status?: string
  total_amount?: number
  notes?: string | null
  items?: TicketItem[]
  staff?: { username?: string } | null
}

const COLS = 32 // caractères par ligne sur du 80 mm en police 12 px

const escapeHtml = (value: unknown) =>
  String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')

// « 12 500 F » : espace insécable normale, pas de symbole monétaire qui déborde sur 32 colonnes
const money = (amount: number) =>
  new Intl.NumberFormat('fr-FR', { maximumFractionDigits: 0 }).format(Number(amount) || 0).replace(/[  ]/g, ' ') + ' F'

const center = (text: string) => {
  const t = text.length > COLS ? text.slice(0, COLS) : text
  return ' '.repeat(Math.floor((COLS - t.length) / 2)) + t
}

/** « 2 x Pizza ........ 5 000 F » sur une ligne, le nom est coupé s'il est trop long */
const line = (left: string, right: string) => {
  const room = COLS - right.length - 1
  const l = left.length > room ? left.slice(0, Math.max(0, room - 1)) + '…' : left
  return l + ' '.repeat(Math.max(1, COLS - l.length - right.length)) + right
}

const statusText = (status?: string) =>
  ({ pending: 'En attente', confirmed: 'Confirmée', processing: 'En préparation', completed: 'Terminée', cancelled: 'Annulée' } as Record<string, string>)[status || ''] || ''

/** Le texte brut du ticket (testable, et repris tel quel dans la page d'impression) */
export const ticketText = (order: TicketOrder, shopName = '') => {
  const when = order.created_at ? new Date(order.created_at) : new Date()
  const date = when.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
  const time = when.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  const table = order.tables?.table_number ?? order.table_number
  const rule = '-'.repeat(COLS)
  const out: string[] = []

  if (shopName) out.push(center(shopName.toUpperCase()), '')
  out.push(center(`COMMANDE ${order.orderNumber ? '#' + order.orderNumber : ''}`.trim()))
  out.push(rule)
  out.push(line('Date', `${date} ${time}`))
  out.push(line('Table', table ? String(table) : 'A emporter'))
  if (order.staff?.username) out.push(line('Serveur', order.staff.username))
  const st = statusText(order.status)
  if (st) out.push(line('Statut', st))
  out.push(rule)

  for (const item of order.items || []) {
    const qty = Number(item.quantity) || 0
    const total = (Number(item.unit_price) || 0) * qty
    out.push(line(`${qty} x ${item.name || 'Produit'}`, money(total)))
    if (qty > 1) out.push(`    (${money(Number(item.unit_price) || 0)} l'unité)`)
    if (item.notes) out.push(`    > ${item.notes}`)
  }

  out.push(rule)
  out.push(line('TOTAL', money(order.total_amount ?? 0)))
  if (order.notes) {
    out.push(rule, 'Notes :')
    out.push(...String(order.notes).split('\n').map(n => '  ' + n))
  }
  out.push(rule, center('Merci de votre visite !'), '', '')
  return out.join('\n')
}

/** Ouvre la fenêtre d'impression du navigateur avec le ticket (iframe cachée : pas de pop-up à autoriser) */
export const printTicket = (order: TicketOrder, shopName = '') => {
  if (typeof document === 'undefined') return false

  const html = `<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Ticket ${escapeHtml(order.orderNumber ?? '')}</title>
<style>
  @page { size: 80mm auto; margin: 0; }
  * { box-sizing: border-box; }
  html, body { margin: 0; padding: 0; background: #fff; }
  body { width: 80mm; padding: 4mm 3mm; }
  pre {
    margin: 0;
    font-family: 'Courier New', Courier, ui-monospace, 'SFMono-Regular', Menlo, Consolas, monospace;
    font-size: 12px;
    line-height: 1.35;
    color: #000;
    white-space: pre-wrap;
    word-break: break-word;
  }
</style>
</head>
<body><pre>${escapeHtml(ticketText(order, shopName))}</pre></body>
</html>`

  const frame = document.createElement('iframe')
  frame.setAttribute('aria-hidden', 'true')
  frame.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0;visibility:hidden'
  document.body.appendChild(frame)

  const doc = frame.contentDocument || frame.contentWindow?.document
  const win = frame.contentWindow
  if (!doc || !win) {
    frame.remove()
    return false
  }
  doc.open()
  doc.write(html)
  doc.close()

  // On laisse le temps à la mise en page, puis on imprime et on nettoie
  setTimeout(() => {
    try {
      win.focus()
      win.print()
    } finally {
      setTimeout(() => frame.remove(), 1000)
    }
  }, 250)
  return true
}
