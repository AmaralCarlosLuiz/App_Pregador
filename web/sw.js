// Pregador Pro - Service Worker Offline-First v20261118
// Garante abertura instantanea no iPhone/iPad mesmo sem sinal 4G/5G ou em Modo Aviao.

const CACHE_NAME = 'pregador-pro-offline-v20261118';

// Recursos principais do app para cache imediato na instalacao
const CORE_ASSETS = [
  './',
  'index.html',
  'manifest.json',
  'favicon.png',
  'apple-touch-icon.png',
  'flutter_bootstrap.js',
  'main.dart.js',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/packages/wakelock_plus/assets/no_sleep.js',
  'assets/shaders/ink_sparkle.frag',
  'assets/shaders/stretch_effect.frag',
  'assets/assets/bible/pt_arc.json',
  'assets/assets/bible/pt_ara.json',
  'assets/assets/bible/pt_naa.json',
  'assets/assets/bible/pt_nvi.json',
  'assets/assets/bible/pt_acf.json',
  'assets/assets/bible/pt_bkj.json'
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return Promise.allSettled(
        CORE_ASSETS.map((url) =>
          fetch(url, { cache: 'reload' })
            .then((res) => {
              if (res && res.ok) {
                return cache.put(url, res);
              }
            })
            .catch(() => {})
        )
      );
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Nunca intercepta APIs externas (Supabase BaaS, Gemini AI, etc.)
  if (url.origin !== self.location.origin) {
    // Fontes estaticas externas (ex: fonts.gstatic.com): cache-first com timeout curto
    if (url.hostname.endsWith('gstatic.com')) {
      event.respondWith(
        caches.match(req).then((cached) => {
          if (cached) return cached;
          return fetch(req)
            .then((res) => {
              if (res && (res.ok || res.type === 'opaque')) {
                const copy = res.clone();
                caches.open(CACHE_NAME).then((c) => c.put(req, copy));
              }
              return res;
            })
            .catch(() => new Response('', { status: 408 }));
        })
      );
    }
    return;
  }

  // Instaladores e o proprio sw.js sempre tentam rede fresca
  if (
    url.pathname.endsWith('/sw.js') ||
    url.pathname.endsWith('/Pregador_Pro.mobileconfig') ||
    url.pathname.endsWith('/Pregador_Pro.apk')
  ) {
    return;
  }

  // Estrategia Cache-First + Stale-While-Revalidate para 0ms de abertura offline
  event.respondWith(
    caches.open(CACHE_NAME).then(async (cache) => {
      const cached = await cache.match(req, { ignoreSearch: true });
      if (cached) {
        // Revalidacao silenciosa em segundo plano quando houver rede
        event.waitUntil(
          fetch(req)
            .then((networkRes) => {
              if (networkRes && networkRes.ok) {
                return cache.put(req, networkRes.clone());
              }
            })
            .catch(() => {})
        );
        return cached;
      }

      try {
        const networkRes = await fetch(req);
        if (networkRes && networkRes.ok) {
          cache.put(req, networkRes.clone());
        }
        return networkRes;
      } catch (_) {
        if (req.mode === 'navigate') {
          const fallback = await cache.match('index.html', { ignoreSearch: true });
          if (fallback) return fallback;
        }
        return new Response('Offline', { status: 503, statusText: 'Offline' });
      }
    })
  );
});

