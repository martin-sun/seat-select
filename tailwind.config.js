/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#6F50F5',
        'primary-light': '#C26DFE',
        'bg-gray': '#f3f4f6',
        'text-gray': '#888888'
      }
    }
  },
  plugins: []
}
