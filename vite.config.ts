import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig, type Plugin } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { fileURLToPath } from 'node:url'

const railsPort = 3000

// vite-plugin-ruby sets server.host to "localhost", which binds loopback only
// and hides the Vite client from Cloud Agent port forwarding. This hook runs
// after that plugin and listens on all interfaces while keeping generated
// asset URLs on localhost (so the browser still hits the forwarded port).
const listenOnAllInterfaces = (): Plugin => ({
  name: 'listen-on-all-interfaces',
  config() {
    return {
      server: {
        host: '0.0.0.0',
        allowedHosts: true,
      },
    }
  },
})

const redirectToRails = (): Plugin => ({
  name: 'redirect-bare-visits-to-rails',
  configureServer(server) {
    server.middlewares.use((req, res, next) => {
      const url = req.url ?? ''
      const isBare = url === '/' || url === '/vite-dev/' || url === '/vite-dev'
      const isHtml = req.headers.accept?.includes('text/html')
      if (isBare && isHtml) {
        res.writeHead(302, { Location: `http://localhost:${railsPort}` })
        res.end()
        return
      }
      next()
    })
  },
})

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    RubyPlugin(),
    listenOnAllInterfaces(),
    redirectToRails(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/frontend', import.meta.url)),
    },
  },
  // SSR. `bin/vite build --ssr` bundles app/javascript/ssr/ssr.tsx (the
  // vite-plugin-ruby default `ssrEntrypoint`) into public/vite-ssr/ssr.js.
  // noExternal: true bundles every dependency into the output so the Node
  // process can boot without resolving anything from node_modules.
  ssr: {
    noExternal: true,
  },
})
