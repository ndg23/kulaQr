# EstablishmentAssignmentModal - Guide d'utilisation

Ce modal remplace 3 anciens modaux pour une expérience unifiée et simplifiée :
- ✅ `EstablishmentOwnerModal` (supprimé)
- ✅ `EstablishmentTransferModal` (supprimé) 
- ✅ `ManagerWithEstablishmentModal` (supprimé)

## Fonctionnalités

### 1. Mode "assign" - Attribuer un établissement
Pour attribuer un établissement existant à un propriétaire (nouveau ou existant).

```vue
<script setup>
import { useEstablishmentAssignment } from '~/composables/useEstablishmentAssignment'

const assignmentModal = useEstablishmentAssignment()

// Attribuer un établissement
const assignToOwner = (establishment) => {
  assignmentModal.assignEstablishment(establishment)
}
</script>

<template>
  <EstablishmentAssignmentModal
    :open="assignmentModal.modalOpen"
    :mode="assignmentModal.modalOptions.mode"
    :establishment="assignmentModal.modalOptions.establishment"
    @close="assignmentModal.closeModal"
    @success="handleSuccess"
  />
</template>
```

### 2. Mode "transfer" - Transférer un établissement
Pour transférer un établissement d'un propriétaire vers un autre.

```vue
<script setup>
// Transférer un établissement
const transferToAnotherOwner = (establishment) => {
  assignmentModal.transferEstablishment(establishment)
}
</script>
```

### 3. Mode "create" - Créer propriétaire + établissement
Pour créer un nouveau propriétaire avec son établissement en une seule fois.

```vue
<script setup>
// Créer un nouveau propriétaire avec établissement
const createNewOwnerWithEstablishment = () => {
  assignmentModal.createOwnerWithEstablishment()
}
</script>
```

## Fonctionnalités par mode

### Mode "assign"
- ✅ Sélection propriétaire existant (dropdown)
- ✅ Création nouveau propriétaire (formulaire inline)
- ✅ Attribution simple et rapide

### Mode "transfer"  
- ✅ Sélection nouveau propriétaire (dropdown, filtre automatique)
- ✅ Options de notification (propriétaire sortant/entrant)
- ✅ Confirmation de transfert

### Mode "create"
- ✅ Formulaire propriétaire complet
- ✅ Formulaire établissement complet  
- ✅ Création atomique (tout ou rien)

## Design Apple-Style

- **Simplicité** : Un seul modal, 3 modes intelligents
- **Clarté** : Pas d'animations complexes, focus sur l'essentiel
- **Efficacité** : Dropdown au lieu de recherche complex
- **Cohérence** : Design uniforme avec font-black et espacements propres

## Migration depuis les anciens modaux

### EstablishmentOwnerModal → EstablishmentAssignmentModal (mode: assign)
```vue
<!-- AVANT -->
<EstablishmentOwnerModal :establishment="est" />

<!-- APRÈS -->
<script>
assignmentModal.assignEstablishment(est)
</script>
```

### EstablishmentTransferModal → EstablishmentAssignmentModal (mode: transfer)
```vue
<!-- AVANT -->
<EstablishmentTransferModal :establishment="est" />

<!-- APRÈS -->
<script>
assignmentModal.transferEstablishment(est)
</script>
```

### ManagerWithEstablishmentModal → EstablishmentAssignmentModal (mode: create)
```vue
<!-- AVANT -->
<ManagerWithEstablishmentModal />

<!-- APRÈS -->
<script>
assignmentModal.createOwnerWithEstablishment()
</script>
```

## Avantages

1. **DRY** : Plus de duplication de code
2. **UX cohérente** : Un seul design, une seule logique
3. **Maintenance** : Un seul composant à maintenir
4. **Performance** : Moins de composants à charger
5. **Apple-style** : Simple, efficace, impactful

## Architecture technique

```
EstablishmentAssignmentModal.vue (modal unifié)
├── Mode assign: Attribution établissement
├── Mode transfer: Transfert propriété  
├── Mode create: Création propriétaire + établissement
└── Forms dynamiques selon le mode

useEstablishmentAssignment.ts (composable)
├── assignEstablishment() 
├── transferEstablishment()
├── createOwnerWithEstablishment()
└── Gestion état modal
```

Ce refactoring élimine la redondance et simplifie l'expérience utilisateur selon les principes Apple : **simple, impactful, font-black** ! 🎯