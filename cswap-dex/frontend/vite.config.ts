import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Listen on all addresses
    port: 3000,
    strictPort: true,
    hmr: {
      protocol: 'ws',
      host: 'cryptoswap.com',
      clientPort: 80
    },
    proxy: {
      '/api': {
        target: 'http://backend:8000',
        changeOrigin: true
      }
    }
  },
  preview: {
    host: '0.0.0.0',
    port: 3000
  }
})





