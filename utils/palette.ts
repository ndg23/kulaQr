// Palette « Flat Bold » du back-office : définie UNE seule fois.
// Chaque ton fournit : un aplat (pastille d'icône, bouton principal), une teinte douce (fond de tuile),
// une couleur de barre de graphique. Les classes sont écrites en entier pour que Tailwind les détecte.
//
// Encre sur aplat : noir sur jaune, vert, orange, rose ; blanc sur bleu et violet (jamais blanc sur rose,
// jamais noir sur bleu ou violet). Chaque rapport de contraste est ≥ 4,5.

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
    hex: '#FFEA00',
    solid: 'bg-[#FFEA00] text-black',
    tint: 'bg-[#FFF9C2] dark:bg-[#FFEA00]/15',
    bar: 'bg-[#FFEA00]'
  },
  blue: {
    hex: '#2962FF',
    solid: 'bg-[#2962FF] text-white',
    tint: 'bg-[#E8EEFF] dark:bg-[#2962FF]/20',
    bar: 'bg-[#2962FF]'
  },
  pink: {
    hex: '#FF007F',
    solid: 'bg-[#FF007F] text-black',
    tint: 'bg-[#FFE0F0] dark:bg-[#FF007F]/20',
    bar: 'bg-[#FF007F]'
  },
  green: {
    hex: '#00E676',
    solid: 'bg-[#00E676] text-black',
    tint: 'bg-[#D6FBE6] dark:bg-[#00E676]/15',
    bar: 'bg-[#00E676]'
  },
  violet: {
    hex: '#7050FF',
    solid: 'bg-[#7050FF] text-white',
    tint: 'bg-[#EFEAFF] dark:bg-[#7050FF]/20',
    bar: 'bg-[#7050FF]'
  },
  orange: {
    hex: '#FF7A00',
    solid: 'bg-[#FF7A00] text-black',
    tint: 'bg-[#FFEBD6] dark:bg-[#FF7A00]/20',
    bar: 'bg-[#FF7A00]'
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
const CYCLE: Tone[] = ['blue', 'green', 'violet', 'orange', 'pink', 'yellow']
export const cycleTone = (index: number): Tone => CYCLE[index % CYCLE.length]
