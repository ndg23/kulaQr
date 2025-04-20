import { ref } from 'vue'

interface Toast {
  id: number
  type: 'success' | 'error' | 'info'
  title: string
  message: string
  duration?: number
}

const toasts = ref<Toast[]>([])
let counter = 0

export const useToast = () => {
  const addToast = (toast: Omit<Toast, 'id'>) => {
    const id = counter++
    const newToast = { ...toast, id }
    toasts.value.push(newToast)

    if (toast.duration !== 0) {
      setTimeout(() => {
        removeToast(id)
      }, toast.duration || 3000)
    }
  }

  const removeToast = (id: number) => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  const success = (title: string, message: string, duration?: number) => {
    addToast({ type: 'success', title, message, duration })
  }

  const error = (title: string, message: string, duration?: number) => {
    addToast({ type: 'error', title, message, duration })
  }

  const info = (title: string, message: string, duration?: number) => {
    addToast({ type: 'info', title, message, duration })
  }

  return {
    toasts,
    success,
    error,
    info,
    removeToast
  }
} 