/**
 * Acción Cooperativa R.L. - Service Worker (PWA v1)
 * Cache-first para recursos estáticos del tema (CSS, JS, logos, fuentes).
 * Network-first para transacciones y consultas financieras en vivo.
 */
const CACHE_NAME = 'accion-coop-cache-v1';
const STATIC_ASSETS = [
  '/gtcop_theme/theme-modern.css?v=m3',
  '/gtcop_theme/skin-yellow.css?v=cdpe',
  '/gtcop_theme/Site.css?v=cdpe',
  '/gtcop_theme/theme-toggle.js?v=cdpe',
  '/gtcop_theme/form-wizard.js?v=m3',
  '/gtcop_theme/anti-error.js?v=m3',
  '/gtcop_theme/pos-caja.js?v=m3',
  '/gtcop_theme/logo_cdpe.png',
  '/gtcop_theme/logo_cdpe_icon.png',
  '/gtcop_theme/icon-192.png',
  '/gtcop_theme/icon-512.png',
  '/gtcop_theme/favicon.ico?v=cdpe'
];

self.addEventListener('install', event => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(STATIC_ASSETS).catch(err => {
        console.warn('[SW] Fallo cacheando assets estaticos:', err);
      });
    })
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.map(key => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Solo cachear assets estáticos de gtcop_theme
  if (url.pathname.startsWith('/gtcop_theme/')) {
    event.respondWith(
      caches.match(event.request).then(cachedResponse => {
        if (cachedResponse) {
          // Stale-while-revalidate en background
          fetch(event.request).then(networkResponse => {
            if (networkResponse && networkResponse.status === 200) {
              caches.open(CACHE_NAME).then(cache => cache.put(event.request, networkResponse));
            }
          }).catch(() => {});
          return cachedResponse;
        }
        return fetch(event.request).then(networkResponse => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, responseToCache));
          }
          return networkResponse;
        });
      })
    );
    return;
  }

  // Network-first para todas las operaciones financieras
  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});
