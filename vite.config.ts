import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig, type Plugin } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { fileURLToPath } from 'node:url'
import dns from 'node:dns'

// Node 17+ resolves `localhost` to IPv6 (`::1`) first. Vite then binds only
// that family, Rails `Socket.tcp("localhost")` can miss it on IPv4, and
// `autoBuild` kicks off a competing production build that looks like a crash.
dns.setDefaultResultOrder('ipv4first')

const railsPort = Number(process.env.PORT) || 3000

const redirectToRails = (): Plugin => ({
  name: 'redirect-bare-visits-to-rails',
  configureServer(server) {
    server.middlewares.use((req, res, next) => {
      const url = req.url ?? ''
      const isBare = url === '/' || url === '/vite-dev/' || url === '/vite-dev'
      const isHtml = req.headers.accept?.includes('text/html')
      if (isBare && isHtml) {
        res.writeHead(302, { Location: `http://127.0.0.1:${railsPort}` })
        res.end()
        return
      }
      next()
    })
  },
})

const listenOnAllIpv4 = (): Plugin => ({
  name: 'listen-on-all-ipv4',
  apply: 'serve',
  config() {
    return {
      server: {
        // vite-plugin-ruby copies config/vite.json `host` onto server.host.
        // 127.0.0.1 is correct for the Rails health check, but loopback-only
        // sockets are invisible to port forwarding. Listen on all IPv4
        // addresses; Rails still connects via 127.0.0.1.
        host: true,
        strictPort: true,
      },
    }
  },
})

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    RubyPlugin(),
    listenOnAllIpv4(),
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
