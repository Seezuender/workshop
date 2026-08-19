/* Service Worker: haelt die Oberflaeche offline verfuegbar.
   Auftragsdaten kommen immer frisch aus Google Drive, werden also nie zwischengespeichert. */
const CACHE = 'werkstatt-v43';
const HUELLE = ['./', './index.html', './manifest.webmanifest', './icon-192.png', './icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(HUELLE)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(k => Promise.all(k.filter(n => n !== CACHE).map(n => caches.delete(n))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET') return;
  if (u.hostname.endsWith('googleapis.com') || u.hostname.endsWith('google.com')) return;
  // Eigene Dateien immer frisch holen – sonst liefert der Browser-Zwischen-
  // speicher (bei GitHub Pages rund 10 Minuten) noch die alte Fassung aus.
  const anfrage = (u.origin === location.origin)
    ? new Request(e.request, {cache: 'no-store'})
    : e.request;
  e.respondWith(
    fetch(anfrage).then(r => {
      if (u.origin === location.origin) {
        const kopie = r.clone();
        caches.open(CACHE).then(c => c.put(e.request, kopie));
      }
      return r;
    }).catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
  );
});
