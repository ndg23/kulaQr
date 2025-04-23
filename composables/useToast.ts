import { useState } from '#app'

interface Toast {
  id: string
  title: string
  description?: string
  type: 'success' | 'error' | 'info' | 'warning'
}

export function useCustomToast() {
  const toasts = useState<Toast[]>('toasts', () => [])

  const addToast = (toast: Omit<Toast, 'id'>) => {
    const id = Math.random().toString(36).substring(2, 9)
    toasts.value = [...toasts.value, { ...toast, id }]

    // Auto remove after 4 seconds
    setTimeout(() => {
      removeToast(id)
    }, 4000)
  }

  const removeToast = (id: string) => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  const showToast = {
    success: (title: string, description?: string) => {
      addToast({
        title,
        description,
        type: 'success'
      })
    },
    error: (title: string, description?: string) => {
      addToast({
        title,
        description,
        type: 'error'
      })
    },
    info: (title: string, description?: string) => {
      addToast({
        title,
        description,
        type: 'info'
      })
    },
    warning: (title: string, description?: string) => {
      addToast({
        title,
        description,
        type: 'warning'
      })
    }
  }

  return {
    toasts,
    showToast,
    removeToast
  }
} 