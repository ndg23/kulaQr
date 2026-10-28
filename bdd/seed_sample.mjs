// Données d'exemple pour tester le back-office : utilisateurs, établissements, menu, tables, commandes.
// Idempotent : relancer le script ne crée pas de doublons (clés : email, slug, nom, numéro de table).
//
//   node bdd/seed_sample.mjs
//
// Lit SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY dans .env. Le mot de passe commun des comptes d'exemple
// vient de SEED_PASSWORD (sinon il est généré) et est écrit dans bdd/.seed-credentials (ignoré par git).
import { createClient } from '@supabase/supabase-js'
import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { randomBytes } from 'node:crypto'

const env = Object.fromEntries(
  readFileSync(new URL('../.env', import.meta.url), 'utf8')
    .split(/\r?\n/)
    .filter((l) => /^[A-Z_]+=/.test(l))
    .map((l) => [l.slice(0, l.indexOf('=')), l.slice(l.indexOf('=') + 1).replace(/^"|"$/g, '')])
)

const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false }
})

const credsFile = new URL('./.seed-credentials', import.meta.url)
const password =
  process.env.SEED_PASSWORD ||
  (existsSync(credsFile) ? readFileSync(credsFile, 'utf8').match(/password=(.*)/)?.[1]?.trim() : '') ||
  randomBytes(9).toString('base64url')

const must = (label, { data, error }) => {
  if (error) throw new Error(`${label}: ${error.message}`)
  return data
}

// ---------------------------------------------------------------- utilisateurs
const SAMPLE_USERS = [
  { email: 'amina.diallo@example.com', full_name: 'Amina Diallo', phone: '+221770000001', role: 'owner', tier: 'pro' },
  { email: 'moussa.ndiaye@example.com', full_name: 'Moussa Ndiaye', phone: '+221770000002', role: 'owner', tier: 'basic' },
  { email: 'fatou.sow@example.com', full_name: 'Fatou Sow', phone: '+221770000003', role: 'manager', tier: 'free' },
  { email: 'ibrahima.fall@example.com', full_name: 'Ibrahima Fall', phone: '+221770000004', role: 'owner', tier: 'free' }
]

const { data: existingList } = await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 })
const authByEmail = new Map((existingList?.users || []).map((u) => [u.email, u]))

const userIds = {}
for (const u of SAMPLE_USERS) {
  let authUser = authByEmail.get(u.email)
  if (!authUser) {
    authUser = must(
      `createUser ${u.email}`,
      await supabase.auth.admin.createUser({
        email: u.email,
        password,
        email_confirm: true,
        user_metadata: { full_name: u.full_name }
      })
    ).user
  }
  userIds[u.email] = authUser.id

  // Le trigger handle_new_user crée la ligne users ; on complète ici (service role : colonnes privilégiées autorisées)
  must(
    `users ${u.email}`,
    await supabase.from('users').upsert(
      {
        id: authUser.id,
        email: u.email,
        full_name: u.full_name,
        phone: u.phone,
        role: u.role,
        status: 'active',
        is_active: true,
        subscription_tier: u.tier,
        subscription_status: 'active',
        subscription_starts_at: new Date().toISOString(),
        subscription_ends_at: new Date(Date.now() + 365 * 864e5).toISOString()
      },
      { onConflict: 'id' }
    )
  )
}
console.log(`utilisateurs : ${SAMPLE_USERS.length}`)

// ---------------------------------------------------------------- types d'établissement
const TYPES = [
  { name: 'Restaurant', slug: 'restaurant', icon: 'utensils', description: 'Restaurant avec service à table' },
  { name: 'Café', slug: 'cafe', icon: 'coffee', description: 'Café et salon de thé' },
  { name: 'Bar', slug: 'bar', icon: 'wine', description: 'Bar et lounge' }
]
must('establishment_types', await supabase.from('establishment_types').upsert(TYPES, { onConflict: 'slug' }))
const types = must('types', await supabase.from('establishment_types').select('id, slug'))
const typeId = Object.fromEntries(types.map((t) => [t.slug, t.id]))

// ---------------------------------------------------------------- établissements + contenu
const SAMPLE_ESTABLISHMENTS = [
  {
    owner: 'amina.diallo@example.com',
    name: 'Le Baobab',
    slug: 'le-baobab',
    type: 'restaurant',
    address: 'Corniche Ouest, Dakar',
    phone: '+221338000001',
    description: 'Cuisine sénégalaise et grillades au bord de mer.',
    tables: 8,
    menu: {
      Entrées: [['Salade avocat-crevettes', 3500], ['Pastels au poisson', 2500], ['Accras de niébé', 2000]],
      Plats: [['Thieboudienne', 5500], ['Yassa poulet', 5000], ['Dibi agneau', 6500], ['Poisson grillé', 7000]],
      Desserts: [['Thiakry', 1800], ['Salade de fruits', 2000]],
      Boissons: [['Bissap', 1000], ['Jus de gingembre', 1000], ['Eau minérale', 500]]
    }
  },
  {
    owner: 'moussa.ndiaye@example.com',
    name: 'Café Teranga',
    slug: 'cafe-teranga',
    type: 'cafe',
    address: 'Rue 10, Saint-Louis',
    phone: '+221338000002',
    description: 'Café, pâtisseries et petit-déjeuner.',
    tables: 5,
    menu: {
      Cafés: [['Espresso', 1000], ['Cappuccino', 1500], ['Café Touba', 800]],
      Pâtisseries: [['Croissant', 700], ['Pain au chocolat', 800], ['Gâteau du jour', 1800]],
      Brunch: [['Omelette garnie', 3000], ['Pancakes', 2800]]
    }
  }
]

const STAFF_BY_SLUG = {
  'le-baobab': [
    { username: 'fatou', full_name: 'Fatou Sow', role: 'manager', pin: '4821' },
    { username: 'cheikh', full_name: 'Cheikh Ba', role: 'waiter', pin: '7305' },
    { username: 'awa', full_name: 'Awa Gueye', role: 'kitchen', pin: '1196' }
  ],
  'cafe-teranga': [{ username: 'omar', full_name: 'Omar Sy', role: 'staff', pin: '5538' }]
}

const STATUSES = ['pending', 'confirmed', 'processing', 'completed', 'completed', 'completed']

for (const e of SAMPLE_ESTABLISHMENTS) {
  const est = must(
    `establishment ${e.slug}`,
    await supabase
      .from('establishments')
      .upsert(
        {
          name: e.name,
          slug: e.slug,
          description: e.description,
          address: e.address,
          phone: e.phone,
          user_id: userIds[e.owner],
          owner_id: userIds[e.owner],
          created_by: userIds[e.owner],
          type_id: typeId[e.type],
          establishment_type_id: typeId[e.type],
          is_active: true,
          currency: 'XOF'
        },
        { onConflict: 'slug' }
      )
      .select('id')
      .single()
  )

  // Catégories et produits
  const products = []
  let catOrder = 0
  for (const [catName, items] of Object.entries(e.menu)) {
    const cat = must(
      `category ${catName}`,
      await supabase
        .from('categories')
        .upsert(
          { establishment_id: est.id, name: catName, order_number: catOrder++, is_active: true, product_count: items.length },
          { onConflict: 'establishment_id,name' }
        )
        .select('id')
        .single()
    )
    let prodOrder = 0
    for (const [name, price] of items) {
      const prod = must(
        `product ${name}`,
        await supabase
          .from('products')
          .upsert(
            { establishment_id: est.id, category_id: cat.id, name, price, order_number: prodOrder++, is_available: true },
            { onConflict: 'category_id,name' }
          )
          .select('id, price')
          .single()
      )
      products.push(prod)
    }
  }

  // Tables
  const tableRows = Array.from({ length: e.tables }, (_, i) => ({
    establishment_id: est.id,
    table_number: String(i + 1),
    capacity: i % 3 === 0 ? 6 : 4,
    type: i === 0 ? 'VIP' : 'STANDARD',
    section_name: i < Math.ceil(e.tables / 2) ? 'SALLE' : 'TERRASSE',
    status: 'available',
    is_active: true
  }))
  const tables = must('tables', await supabase.from('tables').upsert(tableRows, { onConflict: 'establishment_id,table_number' }).select('id, table_number'))

  // QR codes (un par table)
  must(
    'qr_codes',
    await supabase.from('qr_codes').upsert(
      tables.map((t) => ({ establishment_id: est.id, table_number: Number(t.table_number) })),
      { onConflict: 'establishment_id,table_number' }
    )
  )

  // Personnel
  const staffRows = (STAFF_BY_SLUG[e.slug] || []).map((s) => ({ ...s, establishment_id: est.id, is_active: true }))
  const staff = staffRows.length
    ? must('staff', await supabase.from('staff').upsert(staffRows, { onConflict: 'establishment_id,username' }).select('id'))
    : []

  // Commandes : seulement si l'établissement n'en a pas encore (évite les doublons à chaque exécution)
  const { count } = await supabase.from('orders').select('id', { count: 'exact', head: true }).eq('establishment_id', est.id)
  if (!count) {
    for (let i = 0; i < 12; i++) {
      const table = tables[i % tables.length]
      const lines = Array.from({ length: 1 + (i % 3) }, (_, k) => {
        const p = products[(i * 2 + k * 3) % products.length]
        const quantity = 1 + ((i + k) % 3)
        return { product_id: p.id, quantity, unit_price: p.price, subtotal: p.price * quantity }
      })
      const order = must(
        'order',
        await supabase
          .from('orders')
          .insert({
            establishment_id: est.id,
            table_id: table.id,
            table_number: Number(table.table_number),
            staff_id: staff.length ? staff[i % staff.length].id : null,
            status: STATUSES[i % STATUSES.length],
            total_amount: lines.reduce((sum, l) => sum + l.subtotal, 0),
            payment_status: i % 3 === 2 ? 'paid' : 'unpaid',
            created_at: new Date(Date.now() - i * 45 * 60 * 1000).toISOString()
          })
          .select('id')
          .single()
      )
      must('order_items', await supabase.from('order_items').insert(lines.map((l) => ({ ...l, order_id: order.id }))))
    }
  }

  console.log(`${e.name} : ${products.length} produits, ${tables.length} tables, ${staff.length} personnel`)
}

writeFileSync(credsFile, `# Comptes d'exemple (fichier local, ignoré par git)\npassword=${password}\n${SAMPLE_USERS.map((u) => `${u.email}  (${u.role})`).join('\n')}\n`)
console.log('Terminé. Identifiants : bdd/.seed-credentials')
