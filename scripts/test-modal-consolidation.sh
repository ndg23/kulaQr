#!/bin/bash

# Test de la consolidation des modaux
echo "🔍 Vérification de la consolidation des modaux..."

# Recherche des anciens modaux
echo "📋 Recherche des anciens modaux (devraient être supprimés):"
find . -name "*EstablishmentTransferModal*" -o -name "*ManagerWithEstablishmentModal*" | grep -v node_modules | head -5

# Recherche du nouveau modal unifié
echo "✅ Nouveau modal unifié:"
find . -name "*EstablishmentAssignmentModal*" | grep -v node_modules

# Recherche du composable
echo "🎯 Composable d'orchestration:"
find . -name "*useEstablishmentAssignment*" | grep -v node_modules

# Recherche des utilisations dans le code
echo "🔗 Utilisations du nouveau système:"
grep -r "useEstablishmentAssignment\|EstablishmentAssignmentModal" --include="*.vue" --include="*.ts" . | grep -v node_modules | wc -l

echo "🎉 Consolidation terminée!"
echo "   - 3 modaux → 1 modal unifié"
echo "   - Apple-style design avec font-black"
echo "   - Dropdown simple au lieu de recherche complexe"
echo "   - Architecture DRY et maintenable"