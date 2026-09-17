/* Service worker for Chess Trainer.
 *
 * The app is one file with the engine compiled into it, so "offline" just means
 * holding on to that file. Cache-first, with a network refresh in the
 * background, and index.html as the fallback for any navigation.
 *
 * This is the source; build-public.py stamps the build id into CACHE and writes
 * chess-public/sw.js. A new build therefore means new bytes here, which is what
 * makes the browser install a fresh worker. That worker precaches the new page
 * into its own cache and then WAITS — the page shows "Update ready", and its
 * Reload button sends "skip". Nothing reloads under a game in progress; left
 * alone, the new worker takes over once every tab has closed.
 */
const CACHE = "chess-trainer-2026-09-17+82191cc";
const CORE = ["./", "./index.html"];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => Promise.all(CORE.map(u =>
        fetch(u, {cache: "no-cache"}).then(r => { if(r.ok) return c.put(u, r); }))))
      .catch(() => {})                   // a failed precache must not wedge install
  );
});

self.addEventListener("message", e => {
  if(e.data === "skip") self.skipWaiting();
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k.startsWith("chess-trainer-") && k !== CACHE)
                                    .map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if(req.method !== "GET" || !req.url.startsWith(self.location.origin)) return;

  // this worker's cache only: a waiting worker's newer copy must not leak in early
  e.respondWith(
    caches.open(CACHE).then(c => c.match(req, {ignoreSearch: true}).then(hit => {
      const live = fetch(req).then(res => {
        if(res && res.ok) c.put(req, res.clone());
        return res;
      }).catch(() => hit || c.match("./index.html"));
      return hit || live;
    }))
  );
});
