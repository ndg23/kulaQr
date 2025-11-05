#!/usr/bin/env node

// Script pour exécuter les fonctions KPI dans Supabase
// Usage: node scripts/execute-kpi-functions.js

const fs = require('fs');
const path = require('path');

// Charger les variables d'environnement
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Variables d\'environnement SUPABASE_URL et SUPABASE_KEY requises');
  process.exit(1);
}

// Fonction pour exécuter une requête SQL via l'API REST
async function executeSQL(sql) {
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'apikey': SUPABASE_KEY
      },
      body: JSON.stringify({ sql })
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('❌ Erreur lors de l\'exécution SQL:', error.message);
    throw error;
  }
}

async function main() {
  try {
    console.log('🚀 Exécution des fonctions KPI du dashboard...\n');

    // Lire le fichier SQL des fonctions KPI
    const sqlFile = path.join(__dirname, '..', 'bdd', 'dashboard_kpi_functions.sql');
    const sqlContent = fs.readFileSync(sqlFile, 'utf8');

    // Diviser le fichier SQL en statements individuels
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    console.log(`📄 ${statements.length} statements SQL à exécuter\n`);

    // Exécuter chaque statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i] + ';';
      console.log(`⚡ Exécution du statement ${i + 1}/${statements.length}...`);

      try {
        await executeSQL(statement);
        console.log('✅ Statement exécuté avec succès\n');
      } catch (error) {
        console.log('⚠️  Statement ignoré (peut-être déjà existant)\n');
      }
    }

    console.log('🎉 Fonctions KPI créées avec succès!');
    console.log('\n📊 Fonctions disponibles:');
    console.log('   - get_qr_scans_today(establishment_uuid)');
    console.log('   - get_qr_orders_today(establishment_uuid)');
    console.log('   - get_avg_qr_order_value_today(establishment_uuid)');
    console.log('   - get_customer_satisfaction(establishment_uuid)');
    console.log('   - get_avg_time_per_scan(establishment_uuid)');
    console.log('   - get_total_orders_today(establishment_uuid)');
    console.log('   - get_restaurant_dashboard_kpis(establishment_uuid) [FONCTION PRINCIPALE]');

  } catch (error) {
    console.error('❌ Erreur lors de l\'exécution:', error.message);
    process.exit(1);
  }
}

main();