const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#FAF5F1',
          100: '#F5EBE3',
          200: '#E5D4C8',
          300: '#D4B9A6',
          400: '#C89B7B',
          500: '#C89B7B',
          DEFAULT: '#C89B7B',
          600: '#B8896B',
          700: '#A07658',
          800: '#7D5C45',
          900: '#5A4232',
        },
        secondary: {
          50: '#F4F6F7',
          100: '#E8ECEF',
          200: '#CDD5DB',
          300: '#9EADB8',
          400: '#6B8294',
          500: '#34495E',
          DEFAULT: '#2C3E50',
          600: '#2C3E50',
          700: '#1A252F',
          800: '#151E26',
          900: '#0F161C',
        },
        success: {
          50: '#ECFDF5',
          100: '#D1FAE5',
          DEFAULT: '#16A34A',
          600: '#16A34A',
          700: '#15803D',
        },
        danger: {
          50: '#FEF2F2',
          100: '#FEE2E2',
          DEFAULT: '#DC2626',
          600: '#DC2626',
          700: '#B91C1C',
        },
        warning: {
          50: '#FFFBEB',
          100: '#FEF3C7',
          DEFAULT: '#F97316',
          500: '#F59E0B',
          600: '#EA580C',
        },
      },
      fontFamily: {
        serif: ['Georgia', ...defaultTheme.fontFamily.serif],
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      },
      fontSize: {
        'hero': ['3.75rem', { lineHeight: '1.1', letterSpacing: '0.05em' }],
        'hero-sm': ['3rem', { lineHeight: '1.2', letterSpacing: '0.05em' }],
      },
      spacing: {
        'section': '4rem',
        'card': '2rem',
      },
      borderRadius: {
        'card': '0.5rem',
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0, 0, 0, 0.08)',
        'card-hover': '0 4px 16px rgba(0, 0, 0, 0.12)',
      },
      maxWidth: {
        'container': '80rem',
        'content': '65ch',
        'form': '32rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
}
