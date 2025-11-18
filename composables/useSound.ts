import { ref } from 'vue'

interface SoundOptions {
  volume?: number
  loop?: boolean
}

export function useSound() {
  const audioContext = ref<AudioContext | null>(null)
  const isEnabled = ref(getSoundEnabledFromStorage())

  // Initialize audio context (required for some browsers)
  const initAudioContext = () => {
    if (!audioContext.value && typeof window !== 'undefined') {
      try {
        audioContext.value = new (window.AudioContext || (window as any).webkitAudioContext)()
      } catch (error) {
        console.warn('AudioContext not supported:', error)
      }
    }
  }

  // Get sound enabled status from localStorage
  function getSoundEnabledFromStorage(): boolean {
    if (typeof window === 'undefined') return true
    const stored = localStorage.getItem('sound-notifications-enabled')
    return stored !== null ? JSON.parse(stored) : true
  }

  // Save sound enabled status to localStorage
  function saveSoundEnabledToStorage(enabled: boolean) {
    if (typeof window !== 'undefined') {
      localStorage.setItem('sound-notifications-enabled', JSON.stringify(enabled))
    }
  }

  // Play a sound file
  const playSound = async (soundPath: string, options: SoundOptions = {}) => {
    if (!isEnabled.value) return

    try {
      initAudioContext()

      const audio = new Audio(soundPath)
      audio.volume = options.volume ?? 0.7
      audio.loop = options.loop ?? false

      // Resume audio context if suspended (required by some browsers)
      if (audioContext.value?.state === 'suspended') {
        await audioContext.value.resume()
      }

      await audio.play()
      return audio
    } catch (error) {
      console.warn('Failed to play sound:', error)
      return null
    }
  }

  // Play new order notification sound
  const playNewOrderSound = () => {
    return playSound('/sounds/new-order.mp3', { volume: 0.8 })
  }

  // Play success sound
  const playSuccessSound = () => {
    return playSound('/sounds/success.mp3', { volume: 0.6 })
  }

  // Play error sound
  const playErrorSound = () => {
    return playSound('/sounds/error.mp3', { volume: 0.6 })
  }

  // Enable/disable sound notifications
  const setEnabled = (enabled: boolean) => {
    isEnabled.value = enabled
    saveSoundEnabledToStorage(enabled)
  }

  // Check if sound is enabled
  const getEnabled = () => {
    return isEnabled.value
  }

  return {
    playSound,
    playNewOrderSound,
    playSuccessSound,
    playErrorSound,
    setEnabled,
    getEnabled,
    isEnabled
  }
}