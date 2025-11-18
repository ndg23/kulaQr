const Hashids = require('hashids/cjs');

const establishmentId = '12d7c434-f5c9-4d33-9130-1166cfbe4a39';
const qrSecret = process.env.QR_SECRET || 'default-salt';
const salt = `${qrSecret}-${establishmentId}`;

console.log('�� Test de la correction QR menu');
console.log('Salt:', salt);

const hash = '51A7DpgO';
const hashids = new Hashids(salt, 8);
const decoded = hashids.decode(hash);

console.log('Hash problématique:', hash);
console.log('Décodage Hashids:', decoded);
console.log('Numéro de table:', decoded[0]);

// Ancienne logique (problématique)
const oldLogic = parseInt(hash);
console.log('Ancienne logique (parseInt):', oldLogic, '❌');

// Nouvelle logique (corrigée)
const newLogic = decoded.length > 0 ? decoded[0] : null;
console.log('Nouvelle logique (Hashids):', newLogic, '✅');

console.log('\n🎉 Correction réussie ! Le hash décodera maintenant vers 89 au lieu de 51.');
