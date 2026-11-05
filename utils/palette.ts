// Palette « Flat Bold » du back-office : définie UNE seule fois.
// Chaque ton fournit : un aplat (pastille d'icône, bouton principal), une teinte douce (fond de tuile),
// une couleur de barre de graphique. Les classes sont écrites en entier pour que Tailwind les détecte.
//
// Charte Kula : orange (#FB6A00) et noir. Les noms de tons restent ceux de l'ancienne palette pour ne pas toucher
// aux pages ; chacun pointe maintenant vers une nuance d'orange ou le noir.
// Encre sur aplat : noir sur orange clair et vif, blanc sur orange foncé et noir. Chaque rapport de contraste est ≥ 4,5.

export type Tone = 'yellow' | 'blue' | 'pink' | 'green' | 'violet' | 'orange' | 'black'

export interface ToneStyle {
  /** Couleur de l'aplat, en hexadécimal (graphiques, JSON-LD, styles en ligne). */
  hex: string
  /** Aplat plein + couleur d'encre de l'icône posée dessus. */
  solid: string
  /** Fond de tuile très clair (sombre : la couleur à 15 % sur la surface sombre). */
  tint: string
  /** Barre ou point de graphique. */
  bar: string
}

export const TONES: Record<Tone, ToneStyle> = {
  yellow: {
    hex: '#FB6A00',
    solid: 'bg-[#FB6A00] text-black',
    tint: 'bg-[#FFECD8] dark:bg-[#FB6A00]/15',
    bar: 'bg-[#FB6A00]'
  },
  blue: {
    hex: '#1A1A1A',
    solid: 'bg-[#1A1A1A] text-white',
    tint: 'bg-[#EDEAE7] dark:bg-white/10',
    bar: 'bg-[#1A1A1A] dark:bg-white'
  },
  pink: {
    hex: '#C54E00',
    solid: 'bg-[#C54E00] text-white',
    tint: 'bg-[#FFD4AD] dark:bg-[#C54E00]/25',
    bar: 'bg-[#C54E00]'
  },
  green: {
    hex: '#FFB77A',
    solid: 'bg-[#FFB77A] text-black',
    tint: 'bg-[#FFF8F0] dark:bg-[#FFB77A]/15',
    bar: 'bg-[#FFB77A]'
  },
  violet: {
    hex: '#7C2900',
    solid: 'bg-[#7C2900] text-white',
    tint: 'bg-[#FFECD8] dark:bg-[#7C2900]/30',
    bar: 'bg-[#7C2900]'
  },
  orange: {
    hex: '#FD9542',
    solid: 'bg-[#FD9542] text-black',
    tint: 'bg-[#FFECD8] dark:bg-[#FD9542]/20',
    bar: 'bg-[#FD9542]'
  },
  black: {
    hex: '#000000',
    // En thème sombre, une pastille noire disparaîtrait : elle s'inverse.
    solid: 'bg-black text-white dark:bg-white dark:text-black',
    tint: 'bg-gray-200 dark:bg-white/10',
    bar: 'bg-black dark:bg-white'
  }
}

export const toneOf = (tone?: Tone | string | null): ToneStyle => TONES[(tone as Tone) || 'black'] || TONES.black

// Tons utilisés à tour de rôle pour des tuiles de chiffres qui n'ont pas de couleur propre.
const CYCLE: Tone[] = ['yellow', 'blue', 'orange', 'pink', 'black', 'green']
export const cycleTone = (index: number): Tone => CYCLE[index % CYCLE.length]
