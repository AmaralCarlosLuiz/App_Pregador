const CACHE_NAME = 'pregador-pro-web-v20261123_7';

const SHELL_ASSETS = [
  './',
  'index.html',
  'styles.css',
  'sourceProtection.js',
  'app.js',
  'manifest.json',
  'favicon.png',
  'apple-touch-icon.png',
  'data/templates_150.json'
];

const BIBLE_ASSETS = [
  'assets/bible/pt_arc.json',
  'assets/bible/pt_ara.json',
  'assets/bible/pt_naa.json',
  'assets/bible/pt_nvi.json',
  'assets/bible/pt_acf.json',
  'assets/bible/pt_bkj.json'
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      await Promise.allSettled(
        SHELL_ASSETS.map((url) =>
          fetch(url, { cache: 'reload' }).then((res) => {
            if (res && res.ok) return cache.put(url, res);
          }).catch(() => { })
        )
      );
      // Pre-cache das 6 traducoes da Biblia sem travar a instalacao
      Promise.allSettled(
        BIBLE_ASSETS.map((url) =>
          fetch(url).then((res) => {
            if (res && res.ok) return cache.put(url, res);
          }).catch(() => { })
        )
      );
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  if (
    url.pathname.endsWith('/sw.js') ||
    url.pathname.endsWith('/Pregador_Pro.mobileconfig') ||
    url.pathname.endsWith('/Pregador_Pro.apk')
  ) {
    return;
  }

  // Network-First para arquivos de código da aplicação (Garante que updates entrem na hora)
  const isCodeAsset =
    url.pathname.endsWith('.js') ||
    url.pathname.endsWith('.html') ||
    url.pathname.endsWith('.css') ||
    url.pathname === '/' ||
    url.pathname.endsWith('/App_Pregador/') ||
    req.mode === 'navigate';

  if (isCodeAsset) {
    event.respondWith(
      fetch(req)
        .then((netRes) => {
          if (netRes && netRes.ok) {
            const clone = netRes.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, clone));
          }
          return netRes;
        })
        .catch(async () => {
          const cache = await caches.open(CACHE_NAME);
          const cached = await cache.match(req, { ignoreSearch: true });
          if (cached) return cached;
          if (req.mode === 'navigate') {
            return cache.match('index.html', { ignoreSearch: true });
          }
          return new Response('Offline', { status: 503 });
        })
    );
    return;
  }

  // Cache-First para arquivos estáticos pesados (Bíblia, Ícones, Templates)
  event.respondWith(
    caches.open(CACHE_NAME).then(async (cache) => {
      const cached = await cache.match(req, { ignoreSearch: true });
      if (cached) {
        return cached;
      }

      try {
        const netRes = await fetch(req);
        if (netRes && netRes.ok) {
          cache.put(req, netRes.clone());
        }
        return netRes;
      } catch (_) {
        return new Response('Offline', { status: 503 });
      }
    })
  );
});

