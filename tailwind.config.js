/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
    "./error.vue"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        'logo': ['Arial Rounded MT Bold', 'system-ui', '-apple-system', 'sans-serif'],

      },
      colors: {
        kula: {
          50: '#fff8f0',
          100: '#ffecd8',
          200: '#ffd4ad',
          300: '#ffb77a',
          400: '#fd9542',
          500: '#fb6a00', // Orange vif principal
          600: '#fa6900', // Variante d'orange
          700: '#fa6a00', // Autre nuance d'orange
          800: '#fb6b00', // Encore une teinte d'orange
          900: '#c54e00',
          950: '#7c2900',
        },
        primary: {
          50: '#fdf8ed',
          100: '#f9edc8',
          200: '#f5dd91',
          300: '#f0c95a',
          400: '#ecb832',
          500: '#e6a419', // Ocre doré (Couleur principale)
          600: '#cc8314',
          700: '#a66215',
          800: '#864d17',
          900: '#6e4019',
          950: '#422310',
        },
        accent: {
          50: '#f2f7f5',
          100: '#dfeee6',
          200: '#bfddd0',
          300: '#92c5b2',
          400: '#5fa88e',
          500: '#3c8d72', // Vert forêt africaine
          600: '#2b7057',
          700: '#245948',
          800: '#1f473c',
          900: '#1c3c33',
          950: '#0b211c',
        },
        terracotta: {
          50: '#fcf6f5',
          100: '#f9eae7',
          200: '#f4d5cf',
          300: '#ebb5ab',
          400: '#e28e7d',
          500: '#d56a54', // Terracotta
          600: '#c34f3d',
          700: '#a33d31',
          800: '#86352d',
          900: '#71302c',
          950: '#3d1714',
        },
        earth: {
          50: '#f9f7f5',
          100: '#f0ece7',
          200: '#e0d8cf',
          300: '#c9baa8',
          400: '#b09881',
          500: '#9a7d63', // Brun terre
          600: '#866859',
          700: '#6d5349',
          800: '#5c473f',
          900: '#4f3d37',
          950: '#2c201d',
        },
        night: {
          50: '#f4f5f7',
          100: '#e3e7ec',
          200: '#ccd3da',
          300: '#a9b5c2',
          400: '#8092a5',
          500: '#62768c',
          600: '#4d5e71',
          700: '#3e4a5b',
          800: '#364150',
          900: '#20262e', // Bleu nuit
          950: '#171c23',
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}