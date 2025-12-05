/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        '42-cyan': '#00BABC',
        '42-dark': '#0E0E0E',
        '42-darker': '#000000',
        '42-gray': '#1A1A1A',
        '42-light-gray': '#2A2A2A',
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'Fira Code', 'Monaco', 'Courier New', 'monospace'],
      },
    },
  },
  plugins: [],
}
