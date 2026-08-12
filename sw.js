/* Service worker for Chess Trainer.
 *
 * The app is one file with the engine compiled into it, so "offline" just means
 * holding on to that file. Cache-first, with a network refresh in the
 * background, and index.html as the fallback for any navigation.
 */
const CACHE = "chess-trainer-v1";
const CORE = ["./", "./index.html"];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(CORE))
      .then(() => self.skipWaiting())
      .catch(() => self.skipWaiting())   // a failed precache must not wedge install
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if(req.method !== "GET" || !req.url.startsWith(self.location.origin)) return;

  e.respondWith(
    caches.match(req, {ignoreSearch: true}).then(hit => {
      const live = fetch(req).then(res => {
        if(res && res.ok){
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
        }
        return res;
      }).catch(() => hit || caches.match("./index.html"));
      return hit || live;
    })
  );
});
