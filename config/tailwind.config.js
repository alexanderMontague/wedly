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
          DEFAULT: '#C89B7B',
          light: '#E5D4C8',
          dark: '#B8896B',
        },
        secondary: {
          DEFAULT: '#2C3E50',
          light: '#34495E',
          dark: '#1A252F',
        },
      },
      fontFamily: {
        serif: ['Georgia', 'serif'],
        sans: ['-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Roboto', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
