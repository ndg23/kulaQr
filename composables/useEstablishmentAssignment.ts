import { ref } from 'vue'

export type EstablishmentAssignmentMode = 'assign' | 'transfer' | 'create'

export interface EstablishmentAssignmentOptions {
  mode: EstablishmentAssignmentMode
  establishment?: any
}

export const useEstablishmentAssignment = () => {
  const modalOpen = ref(false)
  const modalOptions = ref<EstablishmentAssignmentOptions>({
    mode: 'assign'
  })

  /**
   * Ouvre le modal pour attribuer un établissement existant à un propriétaire
   */
  const assignEstablishment = (establishment: any) => {
    modalOptions.value = {
      mode: 'assign',
      establishment
    }
    modalOpen.value = true
  }

  /**
   * Ouvre le modal pour transférer un établissement vers un autre propriétaire
   */
  const transferEstablishment = (establishment: any) => {
    modalOptions.value = {
      mode: 'transfer',
      establishment
    }
    modalOpen.value = true
  }

  /**
   * Ouvre le modal pour créer un nouveau propriétaire avec son établissement
   */
  const createOwnerWithEstablishment = () => {
    modalOptions.value = {
      mode: 'create'
    }
    modalOpen.value = true
  }

  /**
   * Ferme le modal
   */
  const closeModal = () => {
    modalOpen.value = false
  }

  /**
   * Callback lors du succès d'une opération
   */
  const onSuccess = () => {
    closeModal()
    // Vous pouvez ajouter ici une logique de refresh des données
  }

  return {
    // State
    modalOpen,
    modalOptions,
    
    // Actions
    assignEstablishment,
    transferEstablishment,
    createOwnerWithEstablishment,
    closeModal,
    onSuccess
  }
}

/**
 * Helper pour déterminer les actions disponibles selon le contexte
 */
export const getEstablishmentActions = (establishment?: any) => {
  const actions = []

  if (establishment) {
    // Actions pour établissement existant
    if (!establishment.user_id) {
      actions.push({
        key: 'assign',
        label: 'Attribuer',
        description: 'Attribuer à un propriétaire',
        icon: 'Store'
      })
    } else {
      actions.push({
        key: 'transfer',
        label: 'Transférer',
        description: 'Changer de propriétaire',
        icon: 'ArrowRightLeft'
      })
    }
  }

  // Action pour créer nouveau
  actions.push({
    key: 'create',
    label: 'Créer',
    description: 'Nouveau propriétaire + établissement',
    icon: 'UserPlus'
  })

  return actions
}